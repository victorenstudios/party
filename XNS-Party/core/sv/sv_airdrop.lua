ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
IsAirdropStarted    = false
AirdropState        = {}

AirdropCount        = 0
AirdropRemaining    = 0

Citizen.CreateThread(function()
	Citizen.Wait(1000)
    GetAirdrop()
end)

GetAirdrop = function()
    for k, v in pairs(Config["Airdrop"]) do
        AirdropState[k] = {
            HaveAirdrop =  true,
            Label = v.Label,
            NameAirdrop = v.Label,
            Text = "The game hasn't started yet.",
            Player = 0,
            Source = {},
            MaxPlayer = v.MaxPlayer,
            Dimension = v.Dimension,
            Coords = v.Coords,
            SpawnCoords = nil,
            Item = v.Item
        }
    end
end

ESX.RegisterServerCallback(script_name..":SV:GetAirdrop", function(source, cb, name)
    cb({AirdropState = AirdropState, IsAirdropStarted = IsAirdropStarted})
end)

RegisterCommand("airdrop", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == 'staff' then
        if not IsAirdropStarted then
		    GameStart()
        end
	end
end)

if Config["AutoTime"] then
    Citizen.CreateThread(function()
        while true do
            if not IsAirdropStarted then
                local date_local = os.date("%H:%M", os.time())
                for i, configTime in ipairs(Config["TimeAirdrop"]) do
                    if configTime == date_local then
                        GameStart()
                    end
                end
            end
            Citizen.Wait(10000)
        end
    end)
end

GameStart = function()
    if not IsAirdropStarted then
        AirdropRemaining = GetGameTimer() + Config["TimeToUnlock"]
        for k, v in pairs(AirdropState) do
            v.NameAirdrop = v.Label
            local rdm = math.random(1, #v.Coords)
            v.SpawnCoords = v.Coords[rdm]
            v.Player = 0
            v.Source = {}
            v.HaveAirdrop = true
            AirdropCount = AirdropCount + 1
        end
        IsAirdropStarted = true
        TriggerClientEvent(script_name .. ":CL:AirdropStart", -1, AirdropState)
        Citizen.CreateThread(function()
            while IsAirdropStarted and AirdropRemaining > 0 do
                Tiemdelay = AirdropRemaining - GetGameTimer()
                Tiemdelay = Tiemdelay / 1000
                for k, v in pairs(AirdropState) do
                    v.Text = ("เหลือเวลา %s"):format(secondsToClock(Tiemdelay))
                end
                if Tiemdelay <= 0 then
                    for k, v in pairs(AirdropState) do
                        v.Text = "Event in progress"
                    end
                    AirdropRemaining = 0
                    CoolDownAirdrop()
                end
                Citizen.Wait(1000)
            end
        end)
    end
end

CoolDownAirdrop = function()
    AirdropCooldown = GetGameTimer() + Config["TimeToRemove"]
    Citizen.CreateThread(function()
        while IsAirdropStarted and AirdropCooldown > 0 do
            Timeremove = AirdropCooldown - GetGameTimer()
            Timeremove = Timeremove / 1000
            if Timeremove <= 0 then
                AirdropCooldown = 0
                AirdropAutoDelete()
            end
            Citizen.Wait(1000)
        end
    end)
end

AirdropAutoDelete = function()
    IsAirdropStarted      = false
    AirdropCount          = 0
    AirdropRemaining      = 0
    -- for k, v in pairs(AirdropState) do
    --     if v.HaveAirdrop then
    --         v.HaveAirdrop = false
    --         v.Text = "No Processor"
    --         TriggerClientEvent(script_name .. ":CL:AirdropEnd", -1)
    --     end
    -- end
    for k, v in pairs(AirdropState) do
        if v.Label == name then
            if v.HaveAirdrop then
                v.Text = "No Processor"
                v.HaveAirdrop = false
                for k, v in pairs(v.Source) do
                    local xTarget = ESX.GetPlayerFromId(v)
                    if xTarget then
                        TriggerClientEvent(script_name..":CL:DeleteAirdrop", xTarget.source)
                    end
                end
            end
        end
    end
end

GameFinish = function()
    IsAirdropStarted      = false
    AirdropCount          = 0
    AirdropRemaining      = 0
end

RegisterServerEvent(script_name..":SV:JoinAirdrop")
AddEventHandler(script_name..":SV:JoinAirdrop",function(Name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(AirdropState) do
        if v.Label == Name then
            if v.Player < v.MaxPlayer then
                if AirdropRemaining > 0 then
                    local playerCoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
                    local formattedCoords = {x = ESX.Math.Round(playerCoords.x, 1), y = ESX.Math.Round(playerCoords.y, 1), z = ESX.Math.Round(playerCoords.z, 1)}
                    local formattedStatus = { Health = GetEntityHealth(GetPlayerPed(xPlayer.source)), Armour = GetPedArmour(GetPlayerPed(xPlayer.source)) }
                    MySQL.Async.execute('INSERT INTO xns_event(identifier, coords, status) VALUES (@identifier, @coords, @status)', {
                        ['@identifier'] = xPlayer.identifier,
                        ['@coords'] = json.encode(formattedCoords),
                        ['@status'] = json.encode(formattedStatus),
                    })
                    v.Player = v.Player + 1
                    table.insert(v.Source, xPlayer.source)
                    TriggerClientEvent(script_name..":CL:JoinAirdrop", xPlayer.source, Name, AirdropState)
                    SetPlayerRoutingBucket(xPlayer.source, v.Dimension)
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "Time Left To Join",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
            else
                TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                    text = "Event is full",
                    type = "error",
                    timeout = 5000,
                    layout = "top-right",
                    queue = "global"
                })
            end
        end
    end
end)

RegisterServerEvent(script_name .. ":SV:Getitem")
AddEventHandler(script_name .. ":SV:Getitem", function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(AirdropState) do
        if v.Label == name then
            if v.HaveAirdrop then
                for index , value in pairs(v.Item) do
                    if math.random(1, 100) <= value.Percent then
                        if value.Item then
                            local Count = math.random(value.Count[1], value.Count[2])
                            xPlayer.addInventoryItem(value.Item, Count)
                            -------------------------
                            local sendToDiscord = ''..xPlayer.name..' Received '..value.Item.. ' quantity ' ..Count
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Airdrop', sendToDiscord, xPlayer.source, '^3')
                        elseif value.Money then
                            local Money = math.random(value.Money[1], value.Money[2])
                            xPlayer.addMoney(Money)
                            -------------------------
                            local sendToDiscord = ''..xPlayer.name..' Received money quantity ' ..Money
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Airdrop', sendToDiscord, xPlayer.source, '^3')
                        elseif value.BlackMoney then
                            local BlackMoney = math.random(value.BlackMoney[1], value.BlackMoney[2])
                            xPlayer.addAccountMoney("black_money", BlackMoney)
                            -------------------------
                            local sendToDiscord = ''..xPlayer.name..' Received dirty money quantity ' ..BlackMoney
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Airdrop', sendToDiscord, xPlayer.source, '^3')
                        end
                    end
                end
            end
        end
    end
end)

RegisterServerEvent(script_name .. ":SV:DeleteAirdrop")
AddEventHandler(script_name .. ":SV:DeleteAirdrop", function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(AirdropState) do
        if v.Label == name then
            if v.HaveAirdrop then
                v.Text = "เกมจบแล้ว"
                v.HaveAirdrop = false
                v.NameAirdrop = xPlayer.getName()
                for k, v in pairs(v.Source) do
                    local xTarget = ESX.GetPlayerFromId(v)
                    if xTarget then
                        TriggerClientEvent(script_name..":CL:DeleteAirdrop", xTarget.source)
                    end
                end
                AirdropCount = AirdropCount - 1
                if AirdropCount == 0 then
                    GameFinish()
                end
            end
        end
    end
end)