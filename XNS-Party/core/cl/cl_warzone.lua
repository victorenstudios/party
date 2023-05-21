ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

IsWarzone = nil

IsDead = false

RegisterNetEvent(Config["esx_routers"]['playerLoaded'])
AddEventHandler(Config["esx_routers"]['playerLoaded'], function(xPlayer)
    Citizen.Wait(15000)
    TriggerServerEvent(script_name..":SV:CheckEvent")
end)

RegisterNUICallback("GetWarzone", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetWarzone", function(data)
        SendNUIMessage({
            action = "GetWarzone",
            Warzone = data
        })
    end)
end)

RegisterNUICallback("JoinWarzone", function(data, cb)
    if Drug > 0 then
        exports.pNotify:SendNotification({ text='โปรดรอ '..Drug..' วินาที แล้วทำการวาปใหม่', type="error"})
        return
    end
    if IsTpEvent then
        return
    end
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        exports.pNotify:SendNotification({ text="โปรดลงจากรถ", type="error"})
        return
    end
    if checkHasItem(Config["Ticket"]) then
        IsTpEvent = true
        exports["mythic_progbar"]:Progress({
            name = "IsTpEvent",
            duration = 1 * 1000,
            label = "กำลังวาป...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            },
            animation = {
                animDict = "rcmbarry",
                anim = "base",
            },
        }, function(status)
            if not status and not IsDead then
                TriggerServerEvent(script_name..":SV:JoinWarzone", data.Name)
            end
            IsTpEvent = false
        end)
    else
        exports.pNotify:SendNotification({ text="ต้องการ Ticket Warzone", type="error"})
    end
end)

RegisterNetEvent(script_name..":CL:JoinWarzone")
AddEventHandler(script_name..":CL:JoinWarzone", function(Name)
    for k, v in pairs(Config["Warzone"]) do
        if Name == v.Label then
            IsWarzone = k
            IsInEvent = true
            Teleport(vector3(v.Coords.x, v.Coords.y, v.Coords.z))
            break
        end
    end
end)

Citizen.CreateThread(function() 
    while true do
        local sleep = 500
        if IsWarzone ~= nil then
            sleep = 0
            local Coords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(Coords.x, Coords.y, Coords.z, Config["Warzone"][IsWarzone].Coords.x, Config["Warzone"][IsWarzone].Coords.y, Config["Warzone"][IsWarzone].Coords.z)

            if dist <= Config["Warzone"][IsWarzone].Coords.d then
                DrawMarker(1, Config["Warzone"][IsWarzone].Coords.x, Config["Warzone"][IsWarzone].Coords.y, Config["Warzone"][IsWarzone].Coords.z-1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config["Warzone"][IsWarzone].Coords.d*2, Config["Warzone"][IsWarzone].Coords.d*2, Config["Warzone"][IsWarzone].Coords.d, 255, 0, 0, 100, false, true, 2, false, false, false, false)
            else
                SetEntityCoords(PlayerPedId(), Config["Warzone"][IsWarzone].Coords.x, Config["Warzone"][IsWarzone].Coords.y, Config["Warzone"][IsWarzone].Coords.z)
            end
        end
        Citizen.Wait(sleep)
    end
end)

AddEventHandler(Config["esx_routers"]['onPlayerDeath'], function(data)
    if IsWarzone ~= nil then
        local Time = 10

        Citizen.CreateThread(function()
            while Time > 0 do
                Citizen.Wait(1000)
                Time = Time - 1
            end
        end)

        Citizen.CreateThread(function()
            while IsDead do
                Citizen.Wait(0)
                if Time > 0 then
                    Draw2DText(('เหลือเวลา ~q~%s ~s~วินาที'):format(Time), 0.5, 0.85)
                else
                    Draw2DText('กด ~q~H ~s~เพื่อเกิด', 0.5, 0.85)
                    if IsControlJustPressed(0, 74) then
                        TriggerEvent('esx_ambulancejob:revive')
                        Citizen.Wait(1000)
                        SetEntityHealth(PlayerPedId(), 200)
                        break
                    end
                end
            end
        end)
    end
end)