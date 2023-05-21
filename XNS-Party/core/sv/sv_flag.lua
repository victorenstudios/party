ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

IsFlagStarted    = false
FlagState        = {}
FlagRemaining    = 0

Citizen.CreateThread(function()
	Citizen.Wait(1000)
    GetFlag()
end)

GetFlag = function()
    for k, v in pairs(Config["Flag"]) do
        FlagState[k] = {
            HaveFlag = true,
            Label = v.Label,
            Text = "The game hasn't started yet.",
            PlayerText = "No players yet",
            PlayerHoldFlag = 0,
            PlayerFlag = nil,
            Player = 0,
            Source = {},
            MaxPlayer = v.MaxPlayer,
            Dimension = v.Dimension,
            Coords = v.Coords,
            RealCoords = v.Coords,
            HealCoords = v.HealCoords,
            SpawnPlayer = v.SpawnPlayer,
            Item = v.Item
        }
    end
end

ESX.RegisterServerCallback(script_name..":SV:GetFlag", function(source, cb, name)
    cb({FlagState = FlagState, IsFlagStarted = IsFlagStarted})
end)

RegisterCommand("flag", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == 'staff' then
        if not IsFlagStarted then
		    GameStartFlag()
        end
	end
end)

if Config["AutoTimeFlag"] then
    Citizen.CreateThread(function()
        while true do
            if not IsFlagStarted then
                local date_local = os.date("%H:%M", os.time())
                for i, configTime in ipairs(Config["TimeFlag"]) do
                    if configTime == date_local then
                        GameStartFlag()
                    end
                end
            end
            Citizen.Wait(10000)
        end
    end)
end

GameStartFlag = function()
    if not IsFlagStarted then
        FlagRemaining = GetGameTimer() + Config["TimeToPlayFlag"]
        FlagState = {}
        for k, v in pairs(Config["Flag"]) do
            FlagState[k] = {
                HaveFlag = true,
                Label = v.Label,
                Text = "The game hasn't started yet.",
                PlayerText = "No Players Yet",
                PlayerHoldFlag = 0,
                PlayerFlag = nil,
                Player = 0,
                Source = {},
                MaxPlayer = v.MaxPlayer,
                Dimension = v.Dimension,
                Coords = v.Coords,
                RealCoords = v.Coords,
                HealCoords = v.HealCoords,
                SpawnPlayer = v.SpawnPlayer,
                Item = v.Item
            }
        end
        IsFlagStarted = true
        TriggerClientEvent(script_name .. ":CL:FlagStart", -1, FlagState)
        Citizen.CreateThread(function()
            while IsFlagStarted and FlagRemaining > 0 do
                Tiemdelay = FlagRemaining - GetGameTimer()
                Tiemdelay = Tiemdelay / 1000
                for k, v in pairs(FlagState) do
                    if v.HaveFlag then
                        v.Text = ("Time Left %s"):format(secondsToClock(Tiemdelay))
                    end
                end
                if Tiemdelay <= 0 then
                    -- EndFlag
                    FlagFinish()
                    FlagRemaining = 0
                end
                Citizen.Wait(1000)
            end
        end)
    end
end

RegisterServerEvent(script_name..":SV:JoinFlag")
AddEventHandler(script_name..":SV:JoinFlag",function(Name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(FlagState) do
        if v.Label == Name then
            if v.Player < v.MaxPlayer then
                if FlagRemaining > 0 then
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
                    TriggerClientEvent(script_name..":CL:JoinFlag", xPlayer.source, Name, FlagState)
                    SetPlayerRoutingBucket(xPlayer.source, v.Dimension)
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "Time left to join",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
            else
                TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                    text = "Event Full",
                    type = "error",
                    timeout = 5000,
                    layout = "top-right",
                    queue = "global"
                })
            end
        end
    end
end)

RegisterServerEvent(script_name .. ":SV:PickFlag")
AddEventHandler(script_name .. ":SV:PickFlag", function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(FlagState) do
        if v.Label == name then
            if v.PlayerFlag == nil then
                v.PlayerText = xPlayer.getName()
                v.PlayerHoldFlag = GetGameTimer() + Config["TimeToHoldFlag"]
                v.PlayerFlag = xPlayer.source
                for kk, vv in pairs(v.Source) do
                    local xTarget = ESX.GetPlayerFromId(vv)
                    if xTarget then
                        TriggerClientEvent(script_name..":CL:PickFlag", xTarget.source, xPlayer.getName(), xPlayer.source)
                    end
                end
                Citizen.CreateThread(function()
                    while xPlayer.source == v.PlayerFlag and v.PlayerHoldFlag > 0 do
                        Tiemdelay = v.PlayerHoldFlag - GetGameTimer()
                        Tiemdelay = Tiemdelay / 1000
                        v.PlayerText = ("%s Holding a flag [%s]"):format(xPlayer.getName(), secondsToClock(Tiemdelay))
                        if Tiemdelay <= 0 then
                            -- EndFlag
                            v.PlayerHoldFlag = 0
                            HoldFlag(v.Label)
                        end
                        Citizen.Wait(1000)
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent(script_name .. ":SV:FlagDie")
AddEventHandler(script_name .. ":SV:FlagDie", function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(FlagState) do
        if v.Label == name then
            if v.PlayerFlag ~= nil then
                v.PlayerText = "No Players Yet"
                v.Coords = GetEntityCoords(GetPlayerPed(v.PlayerFlag))
                v.PlayerHoldFlag = 0
                for kk, vv in pairs(v.Source) do
                    local xTarget = ESX.GetPlayerFromId(vv)
                    if xTarget then
                        TriggerClientEvent(script_name..":CL:FlagDie", xTarget.source, "No Players Yet", GetEntityCoords(GetPlayerPed(v.PlayerFlag)))
                    end
                end
                v.PlayerFlag = nil
            end
        end
    end
end)

RegisterServerEvent(script_name..":SV:TooFar")
AddEventHandler(script_name..":SV:TooFar", function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(FlagState) do
        if v.Label == name then
            if v.PlayerFlag ~= nil then
                v.PlayerText = "No Players Yet"
                v.Coords = v.RealCoords
                v.PlayerHoldFlag = 0
                for kk, vv in pairs(v.Source) do
                    local xTarget = ESX.GetPlayerFromId(vv)
                    if xTarget then
                        TriggerClientEvent(script_name..":CL:FlagDie", xTarget.source, "No Players Yet", v.Coords)
                    end
                end
                v.PlayerFlag = nil
            end
        end
    end
end)

FlagFinish = function()
    IsFlagStarted    = false
    FlagRemaining    = 0
    for k, v in pairs(FlagState) do
        if v.HaveFlag then
            v.HaveFlag = false
            v.Text = 'Game Over'
            if v.PlayerFlag ~= nil then
                local xPlayer = ESX.GetPlayerFromId(v.PlayerFlag)
                v.PlayerText = xPlayer.name
                v.Label = xPlayer.name
                for index , value in pairs(v.Item) do
                    if math.random(1, 100) <= value.Percent then
                        if value.Item then
                            local Count = math.random(value.Count[1], value.Count[2])
                            xPlayer.addInventoryItem(value.Item, Count)
                            -------------------------
                            local sendToDiscord = ''..xPlayer.name..' Receive '..value.Item.. ' Quantity ' ..Count
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Flag', sendToDiscord, xPlayer.source, '^3')
                        elseif value.Money then
                            local Money = math.random(value.Money[1], value.Money[2])
                            xPlayer.addMoney(Money)
                            -------------------------
                            local sendToDiscord = ''..xPlayer.name..' Receive Cash Quantity ' ..Money
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Flag', sendToDiscord, xPlayer.source, '^3')
                        elseif value.BlackMoney then
                            local BlackMoney = math.random(value.BlackMoney[1], value.BlackMoney[2])
                            xPlayer.addAccountMoney("black_money", BlackMoney)
                            -------------------------
                            local sendToDiscord = ''..xPlayer.name..' Receive Dirty Money Quantity ' ..BlackMoney
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Flag', sendToDiscord, xPlayer.source, '^3')
                        end
                    end
                end
            end
            for index , value in pairs(v.Source) do
                local xTarget = ESX.GetPlayerFromId(value)
                if xTarget then
                    TriggerClientEvent(script_name..":CL:EndFlag", xTarget.source)
                end
            end
        end
    end
end

HoldFlag = function(name)
    for k, v in pairs(FlagState) do
        if v.Label == name then
            if v.HaveFlag then
                v.HaveFlag = false
                v.Text = 'Game Over'
                if v.PlayerFlag ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(v.PlayerFlag)
                    v.PlayerText = xPlayer.name
                    v.Label = xPlayer.name
                    for index , value in pairs(v.Item) do
                        if math.random(1, 100) <= value.Percent then
                            if value.Item then
                                local Count = math.random(value.Count[1], value.Count[2])
                                xPlayer.addInventoryItem(value.Item, Count)
                                -------------------------
                                local sendToDiscord = ''..xPlayer.name..' Receive '..value.Item.. ' Quantity ' ..Count
                                TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Flag', sendToDiscord, xPlayer.source, '^3')
                            elseif value.Money then
                                local Money = math.random(value.Money[1], value.Money[2])
                                xPlayer.addMoney(Money)
                                -------------------------
                                local sendToDiscord = ''..xPlayer.name..' Receive Cash Quantity ' ..Money
                                TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Flag', sendToDiscord, xPlayer.source, '^3')
                            elseif value.BlackMoney then
                                local BlackMoney = math.random(value.BlackMoney[1], value.BlackMoney[2])
                                xPlayer.addAccountMoney("black_money", BlackMoney)
                                -------------------------
                                local sendToDiscord = ''..xPlayer.name..' Receive Dirty Money Quantity ' ..BlackMoney
                                TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'Flag', sendToDiscord, xPlayer.source, '^3')
                            end
                        end
                    end
                end
                for index , value in pairs(v.Source) do
                    local xTarget = ESX.GetPlayerFromId(value)
                    if xTarget then
                        TriggerClientEvent(script_name..":CL:EndFlag", xTarget.source)
                    end
                end
            end
        end
    end
end