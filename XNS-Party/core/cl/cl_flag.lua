ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

FlagRemaining           = 0
IsFlagStarted           = false
IsFlag                  = nil

RegisterNetEvent(script_name .. ":CL:GetEventFlag")
AddEventHandler(script_name .. ":CL:GetEventFlag", function(time, data)
    local Timeaaa = time.StartTime - time.Time
    FlagRemaining = GetGameTimer() + Timeaaa
    Citizen.CreateThread(function()
        local State = data
        while FlagRemaining >= 1 do
            Tiemdelay = FlagRemaining - GetGameTimer()
            Tiemdelay = Tiemdelay / 1000
            SendNUIMessage({
                action = "SyncFlagTime",
                Flag = State,
                Time = ("Time Left %s"):format(secondsToClock(Tiemdelay))
            })
            SendNUIMessage({
                action = "AlertTime",
                Time = ("Time Left %s นาที"):format(secondsToClock(Tiemdelay))
            })
            if Tiemdelay < 1 then
                FlagRemaining = 0
                SendNUIMessage({
                    action = "CloseAlertTime",
                })
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNUICallback("GetFlag", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetFlag", function(data)
        SendNUIMessage({
            action = "GetFlag",
            Flag = data.FlagState,
            StatusFlag = data.IsFlagStarted
        })
    end)
end)

RegisterNUICallback("JoinFlag", function(data, cb)
    if Drug > 0 then
        exports.pNotify:SendNotification({ text='Please Wait '..Drug..' Seconds to Teleport', type="error"})
        return
    end
    if IsTpEvent then
        return
    end
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        exports.pNotify:SendNotification({ text="Exit Vehicle", type="error"})
        return
    end
    IsTpEvent = true
    exports["mythic_progbar"]:Progress({
        name = "IsTpEvent",
        duration = 1 * 1000,
        label = "Teleporting...",
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
            TriggerServerEvent(script_name..":SV:JoinFlag", data.Name)
        end
        IsTpEvent = false
    end)
end)

RegisterNetEvent(script_name .. ":CL:FlagStart")
AddEventHandler(script_name .. ":CL:FlagStart", function(data)
    SendNUIMessage({
        action = 'eventalert',
        Text = '　<i style="color:#ef60a1;" class="fa-solid fa-flag"></i> FLAGS START',
        Sound = 'flag'
    })
    FlagRemaining = GetGameTimer() + Config["TimeToPlayFlag"]
    Citizen.CreateThread(function()
        local State = data
        while FlagRemaining >= 1 do
            Tiemdelay = FlagRemaining - GetGameTimer()
            Tiemdelay = Tiemdelay / 1000
            SendNUIMessage({
                action = "SyncFlagTime",
                Flag = State,
                Time = ("Time Left %s"):format(secondsToClock(Tiemdelay))
            })
            SendNUIMessage({
                action = "AlertTime",
                Time = ("Time Left %s Minute"):format(secondsToClock(Tiemdelay))
            })
            if Tiemdelay < 1 then
                FlagRemaining = 0
                SendNUIMessage({
                    action = "CloseAlertTime",
                })
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent(script_name .. ":CL:EndFlag")
AddEventHandler(script_name .. ":CL:EndFlag", function()
    if IsFlagStarted then
        if IsAnimation then
            TriggerEvent("mythic_progbar:client:cancel")
        end
        TriggerServerEvent(script_name..":SV:asdwDZDG", "Flag", IsFlag.Label)
    end
    TriggerServerEvent(script_name..":SV:CheckEvent")
end)

RegisterNetEvent(script_name..":CL:JoinFlag")
AddEventHandler(script_name..":CL:JoinFlag", function(Name, data)
    for k, v in pairs(data) do
        if Name == v.Label then
            IsFlag = v
            IsFlagStarted = true
            IsInEvent = true
            Teleport(vector3(IsFlag.SpawnPlayer.x, IsFlag.SpawnPlayer.y, IsFlag.SpawnPlayer.z))
            SetEntityHealth(PlayerPedId(), 200)
            SyncFlag()
            break
        end
    end
end)

RegisterNetEvent(script_name..":CL:PickFlag")
AddEventHandler(script_name..":CL:PickFlag", function(PlayerText, PlayerFlag)
    IsFlag.PlayerText = PlayerText
    IsFlag.PlayerFlag = PlayerFlag
    IsFlag.PlayerHoldFlag = GetGameTimer() + Config["TimeToHoldFlag"]
    Citizen.CreateThread(function()
        while IsFlagStarted and PlayerFlag == IsFlag.PlayerFlag and IsFlag.PlayerHoldFlag > 0 do
            Tiemdelay = IsFlag.PlayerHoldFlag - GetGameTimer()
            Tiemdelay = Tiemdelay / 1000
            IsFlag.PlayerText = ("%s Holding a flag [%s]"):format(PlayerText, secondsToClock(Tiemdelay))
            if Tiemdelay <= 0 then
                IsFlag.PlayerHoldFlag = 0
            end
            Citizen.Wait(1000)
        end
    end)
    Citizen.Wait(100)
    if IsAnimation then
        TriggerEvent("mythic_progbar:client:cancel")
    end
end)

RegisterNetEvent(script_name..":CL:FlagDie")
AddEventHandler(script_name..":CL:FlagDie", function(PlayerText, Coords)
    IsFlag.PlayerText = PlayerText
    IsFlag.PlayerFlag = nil
    IsFlag.Coords = Coords
end)

AddEventHandler(Config["esx_routers"]['onPlayerDeath'], function(data)
    if IsFlag ~= nil then
        if IsFlag.PlayerFlag == GetPlayerServerId(PlayerId()) then
            TriggerServerEvent(script_name..":SV:FlagDie", IsFlag.Label)
        end
        Citizen.CreateThread(function() 
            local Count = 0
			while IsDead do
				Citizen.Wait(1000)
				Count = Count + 1
				if Count >= 10 and IsFlag ~= nil then
	                SetEntityCoords(PlayerPedId(), vector3(IsFlag.SpawnPlayer.x, IsFlag.SpawnPlayer.y, IsFlag.SpawnPlayer.z))
					TriggerEvent('esx_ambulancejob:revive')
                    Citizen.Wait(1000)
				end
			end
		end)
    end
end)

SyncFlag = function()
    Citizen.CreateThread(function()
        while IsFlagStarted do
            Citizen.Wait(500)
            if IsFlagStarted then
                if IsAnimation then
                    local xcoords = GetEntityCoords(PlayerPedId(), 0)
                    local Coords = IsFlag.Coords
                    if GetDistanceBetweenCoords(xcoords, Coords.x,Coords.y,Coords.z , false) > 4 then
                        TriggerEvent("mythic_progbar:client:cancel")
                        exports.pNotify:SendNotification({ text="ออกมาไกลจากจุดเก็บ", type="error"})
                    end
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while IsFlagStarted do
            Citizen.Wait(500)
            if IsFlagStarted and IsDead then
                if IsAnimation then
                    TriggerEvent("mythic_progbar:client:cancel")
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while IsFlagStarted do
            Citizen.Wait(0)
            local Coords = IsFlag.HealCoords
            local playerPed = PlayerPedId()
            local PlayerCoords = GetEntityCoords(playerPed)
            local dist = Vdist(Coords.x, Coords.y, Coords.z, PlayerCoords)
            DrawMarker(21, Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0, 180.0, 0.0, 180.0, 0.75, 0.75, 0.85, 0, 255, 0, 100, true, true, 2, false, false, false, false)
            if dist <= 2.0 and not IsDead and not IsAnimation then
                exports["XNS-Textui"]:ShowHelpNotification('Press ~INPUT_CONTEXT~ to heal')
                if IsControlJustPressed(0, 51) then
                    exports["mythic_progbar"]:Progress({
                        name = "heal",
                        duration = 5000,
                        label = "Preparing",
                        useWhileDead = false,
                        canCancel = false,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        },
                    }, function(status)
                        if not status then
                            SetEntityHealth(PlayerPedId(), 200)
                        end
                        ClearPlayerState()
                    end)
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        loadAnimDict('amb@medic@standing@kneel@base')
        loadAnimDict('anim@gangops@facility@servers@bodysearch@')
        while IsFlagStarted do
            Citizen.Wait(0)
            if FlagRemaining > 1 then
                Tiemdelay = FlagRemaining - GetGameTimer()
                Tiemdelay = Tiemdelay / 1000
                SendNUIMessage({
                    action = "FlagAlert",
                    Text = secondsToClock(Tiemdelay),
                    PlayerText = IsFlag.PlayerText,
                })
            end
            if IsFlag.PlayerFlag == nil then
                local Coords = IsFlag.Coords
                DrawMarker(20, Coords.x,Coords.y,Coords.z, 0.0, 0.0, 0.0, 180.0, 0.0, 180.0, 0.75, 0.75, 0.85, 255, 0, 0, 100, true, true, 2, false, false, false, false)
				DrawMarker(20, Coords.x,Coords.y,Coords.z+1.0, 0.0, 0.0, 0.0, 180.0, 0.0, 180.0, 0.75, 0.75, 0.85, 255, 100, 0, 100, true, true, 2, false, false, false, false)
                local playerPed = PlayerPedId()
                local PlayerCoords = GetEntityCoords(playerPed)
                local dist = Vdist(Coords.x, Coords.y, Coords.z, PlayerCoords)
                if dist <= 4.0 and not IsDead and not IsAnimation then
                    exports["XNS-Textui"]:ShowHelpNotification('Press ~INPUT_CONTEXT~ to Pickup the flag')
                    if IsControlJustPressed(0, 51) then
                        IsAnimation = true
                        TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
                        TaskPlayAnim(GetPlayerPed(-1), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
                        exports["mythic_progbar"]:Progress({
                            name = "Flag",
                            duration = Config["TimeToPickUPFlag"],
                            label = "Collecting the royal flag...",
                            useWhileDead = false,
                            canCancel = true,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true
                            },
                        }, function(status)
                            if not status then
                                TriggerServerEvent(script_name..":SV:PickFlag", IsFlag.Label)
                            end
                            ClearPlayerState()
                        end)
                    end
                end
            else
                local playerid = GetPlayerFromServerId(IsFlag.PlayerFlag)
                local ped = GetPlayerPed(playerid)
                if ped ~= GetPlayerPed(-1) then
                    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(ped,true))
                    DrawMarker(20, x,y,z+1.0, 0.0, 0.0, 0.0, 180.0, 0.0, 180.0, 0.75, 0.75, 0.85, 255, 0, 0, 100, true, true, 2, false, false, false, false)
                    DrawMarker(20, x,y,z+2.0, 0.0, 0.0, 0.0, 180.0, 0.0, 180.0, 0.75, 0.75, 0.85, 255, 100, 0, 100, true, true, 2, false, false, false, false)
                end
            end
        end
    end)
end