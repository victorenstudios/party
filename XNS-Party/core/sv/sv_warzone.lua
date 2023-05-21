ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

WarzoneState = {}

Citizen.CreateThread(function()
	Citizen.Wait(1000)
    GetWarzone()
end)

GetWarzone = function()
    for k, v in pairs(Config["Warzone"]) do
        WarzoneState[k] = {
            Label = v.Label,
            Player = 0,
            Source = {},
            MaxPlayer = v.MaxPlayer,
            Dimension = v.Dimension
        }
    end
end

ESX.RegisterServerCallback(script_name..":SV:GetWarzone", function(source, cb, name)
    cb(WarzoneState)
end)

RegisterServerEvent(script_name..":SV:JoinWarzone")
AddEventHandler(script_name..":SV:JoinWarzone",function(Name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xItem = xPlayer.getInventoryItem(Config["Ticket"])
    if xItem.count > 0 then
        for k, v in pairs(WarzoneState) do
            if v.Label == Name then
                if v.Player < v.MaxPlayer then
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
                    xPlayer.removeInventoryItem(xItem.name, 1)
                    for k, v in pairs(Config["Item"]) do
                        xPlayer.setInventoryItem(v, 1)
                    end
                    TriggerClientEvent(script_name..":CL:JoinWarzone", xPlayer.source, Name)
                    SetPlayerRoutingBucket(xPlayer.source, v.Dimension)
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "ไม่สามารถเข้าได้เนื่องจากคนเต็ม",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
            end
        end
    end
end)