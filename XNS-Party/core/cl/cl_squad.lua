ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

Squad = {}
IsBossSquad = false

SquadBlacklist = {}

-- Citizen.CreateThread(function()
-- 	Citizen.Wait(1000)
--     TriggerServerEvent(script_name..":SV:GetSquadName")
-- end)
RegisterNetEvent('framework:playerLoaded')
AddEventHandler('framework:playerLoaded', function(xPlayer)
    Citizen.Wait(1000)
    TriggerServerEvent(script_name..":SV:GetSquadName")
end)

RegisterNetEvent(script_name..":CL:TriggerGetSquadName")
AddEventHandler(script_name..":CL:TriggerGetSquadName", function()
    TriggerServerEvent(script_name..":SV:GetSquadName")
end)

RegisterNetEvent(script_name..":CL:GetSquadName")
AddEventHandler(script_name..":CL:GetSquadName", function(name)
    Squad = name
    print(ESX.DumpTable(Squad))
    Citizen.Wait(100)
    for k, v in pairs(Squad.Player) do
        if v.Identifier == ESX.GetPlayerData().identifier then
            if v.Boss then
                IsBossSquad = true
            else
                IsBossSquad = false
            end
        end
    end
    if IsOpen then
        SendNUIMessage({
            action = "RefreshPlayerInSquad",
            Name = Squad.Name,
            Player = Squad.Player,
            StatusSquad = Squad.Status,
            IsBossSquad = IsBossSquad
        })
    end
end)

RegisterNUICallback("JoinSquad", function(data, cb)
    if Squad.Name == nil then
        for k, v in pairs(SquadBlacklist) do
            if data.name == v.Name then
                if v.Time > 0 then
                    exports.pNotify:SendNotification({ text="โปรดรอ "..v.Time.. " วินาที", type="error"})
                    return
                end
            end
        end
        TriggerServerEvent(script_name..":SV:JoinSquad", data.name)
    end
end)

RegisterNUICallback("KickSquad", function(data, cb)
    if IsBossSquad then
        TriggerServerEvent(script_name..":SV:KickSquad", data.name, Squad.Name)
    end
end)

RegisterNUICallback("SubmitQuitSquad", function(data, cb)
    if Squad.Name ~= nil then
        TriggerServerEvent(script_name..":SV:SubmitQuitSquad", ESX.GetPlayerData().identifier, Squad.Name)
    end
end)

RegisterNUICallback("SubmitDeleteSquad", function(data, cb)
    if Squad.Name ~= nil then
        TriggerServerEvent(script_name..":SV:SubmitDeleteSquad", Squad.Name)
    end
end)

RegisterNUICallback("GetSquad", function(data, cb)
    if IsOpen then
        if Squad.Name == nil then
            ESX.TriggerServerCallback(script_name..":SV:GetSquad", function(data)
                SendNUIMessage({
                    action = "GetSquad",
                    DataSquad = data,
                    MySquad = Squad
                })
            end)
        else
            SendNUIMessage({
                action = "ManageSquad",
                Name = Squad.Name,
                Player = Squad.Player,
                StatusSquad = Squad.Status,
                IsBossSquad = IsBossSquad
            })
        end
    end
end)

RegisterNUICallback("CreateParty", function(data, cb)
    Wait(math.random(100))
    if Squad.Name == nil then
        if data.name ~= nil then
            if checkHasItem(Config["TicketSquad"]) then
                TriggerServerEvent(script_name..":SV:CreateParty", data.name)
            else
                exports.pNotify:SendNotification({ text="ต้องการ Ticket Party", type="error"})
            end
        else
            exports.pNotify:SendNotification({ text="โปรดใส่ชื่อปาร์ตี้", type="error"})
        end
    else
        exports.pNotify:SendNotification({ text="โปรดออกจากปาร์ตี้เก่าก่อน", type="error"})
    end
end)

RegisterNetEvent(script_name..":CL:KickSquad")
AddEventHandler(script_name..":CL:KickSquad", function(SquadName)
    Squad = {}
    IsBossSquad = false
    table.insert(SquadBlacklist, {
        Name = SquadName,
        Time = 60
    })
    SendNUIMessage({
        action = "closemenu"
    })
end)

RegisterNetEvent(script_name..":CL:QuitSquad")
AddEventHandler(script_name..":CL:QuitSquad", function()
    Squad = {}
    IsBossSquad = false
    SendNUIMessage({
        action = "closemenu"
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if #SquadBlacklist > 0 then
            for k, v in pairs(SquadBlacklist) do
                if v.Time > 0 then
                    v.Time = v.Time - 1
                end
            end
        end
    end
end)

RegisterNUICallback("StartSquad", function(data, cb)
    if Squad.Name ~= nil then
        TriggerServerEvent(script_name..":SV:StartSquad", Squad.Name)
    end
end)

function GetSquad()
    if Squad.Name == nil then
        return Config["Time"][1]
    else
        if Squad.Status then
            -- 
            local Player = 0
            for k, v in pairs(Squad.Player) do
                if v.Status then
                    Player = Player + 1
                end
            end
            return Config["Time"][Player]
        else
            return Config["Time"][1]
        end
    end
end
exports('GetSquad', GetSquad)