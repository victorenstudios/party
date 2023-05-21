ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

AirdropRemaining        = 0
IsAirdropStarted        = false
IsAirdrop               = nil
AirdropProp             = nil
IsAnimation             = false
Health                  = 200
Armour                  = 100
Radius                  = Config["Radius"]

RegisterNetEvent(script_name .. ":CL:GetEventAirdrop")
AddEventHandler(script_name .. ":CL:GetEventAirdrop", function(time, data)
    local Timeaaa = time.StartTime - time.Time
    AirdropRemaining = GetGameTimer() + Timeaaa
    Citizen.CreateThread(function()
        local State = data
        while AirdropRemaining >= 1 do
            Tiemdelay = AirdropRemaining - GetGameTimer()
            Tiemdelay = Tiemdelay / 1000
            SendNUIMessage({
                action = "SyncAirdropTime",
                Airdrop = State,
                Time = ("Remaining Time %s"):format(secondsToClock(Tiemdelay))
            })
            SendNUIMessage({
                action = "AlertTime",
                Time = ("Time Left %s นาที"):format(secondsToClock(Tiemdelay))
            })
            if Tiemdelay < 1 then
                SendNUIMessage({
                    action = "CloseAlertTime",
                })
                AirdropRemaining = 0
                if IsInEvent then
                    SendNUIMessage({
                        action = "closemenu"
                    })
                end
                SendNUIMessage({
                    action = "SyncAirdropTime",
                    Airdrop = State,
                    Time = "game in progress"
                })
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNUICallback("GetAirdrop", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetAirdrop", function(data)
        SendNUIMessage({
            action = "GetAirdrop",
            Airdrop = data.AirdropState,
            StatusAirdrop = data.IsAirdropStarted
        })
    end)
end)

RegisterNUICallback("JoinAirdrop", function(data, cb)
    if Drug > 0 then
        exports.pNotify:SendNotification({ text='Please wait '..Drug..' seconds and remap', type="error"})
        return
    end
    if IsTpEvent then
        return
    end
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        exports.pNotify:SendNotification({ text="Please get out of the car", type="error"})
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
            TriggerServerEvent(script_name..":SV:JoinAirdrop", data.Name)
        end
        IsTpEvent = false
    end)
end)

RegisterNetEvent(script_name .. ":CL:AirdropStart")
AddEventHandler(script_name .. ":CL:AirdropStart", function(data)
    SendNUIMessage({
        action = 'eventalert',
        Text = '<i style="color:#ef60a1;" class="fa-solid fa-parachute-box"></i> AIRDROP START',
        Sound = 'airdrop'
    })
    Radius = Config["Radius"]
    AirdropRemaining = GetGameTimer() + Config["TimeToUnlock"]
    Citizen.CreateThread(function()
        local State = data
        while AirdropRemaining >= 1 do
            Tiemdelay = AirdropRemaining - GetGameTimer()
            Tiemdelay = Tiemdelay / 1000
            SendNUIMessage({
                action = "SyncAirdropTime",
                Airdrop = State,
				Time = ("Time left %s"):format(secondsToClock(Tiemdelay))
             })
             SendNUIMessage({
                 action = "AlertTime",
                 Time = ("%s minutes left"):format(secondsToClock(Tiemdelay))
            })
            if Tiemdelay < 1 then
                SendNUIMessage({
                    action = "CloseAlertTime",
                })
                AirdropRemaining = 0
                if IsInEvent then
                    SendNUIMessage({
                        action = "closemenu"
                    })
                end
                SendNUIMessage({
                    action = "SyncAirdropTime",
                    Airdrop = State,
                    Time = "Game in progress"
                })
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent(script_name..":CL:JoinAirdrop")
AddEventHandler(script_name..":CL:JoinAirdrop", function(Name, data)
    for k, v in pairs(data) do
        if Name == v.Label then
            IsAirdrop = v
            IsAirdropStarted = true
            IsInEvent = true
            local rdm = math.random(1, #IsAirdrop.SpawnCoords.SpawnPlayer)
            print(vector3(IsAirdrop.SpawnCoords.SpawnPlayer[rdm].x, IsAirdrop.SpawnCoords.SpawnPlayer[rdm].y, IsAirdrop.SpawnCoords.SpawnPlayer[rdm].z))
            Teleport(vector3(IsAirdrop.SpawnCoords.SpawnPlayer[rdm].x, IsAirdrop.SpawnCoords.SpawnPlayer[rdm].y, IsAirdrop.SpawnCoords.SpawnPlayer[rdm].z))
            SetEntityHealth(PlayerPedId(), 200)
            SyncAirdrop()
            break
        end
    end
end)

SyncAirdrop = function()
    ESX.Game.SpawnLocalObject(Config["Prop"], vector3(IsAirdrop.SpawnCoords.x, IsAirdrop.SpawnCoords.y, IsAirdrop.SpawnCoords.z-1.0), function(obj)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
        AirdropProp = obj
    end)

    Citizen.CreateThread(function()
        while IsAirdropStarted do
            Citizen.Wait(1000)
            if AirdropRemaining <= 0 then
                if Radius >= 5.0 then
                    Radius = Radius - 0.1
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while IsAirdropStarted do
            Citizen.Wait(500)
            if IsAirdropStarted and IsDead then
                if IsAnimation then
                    TriggerEvent("mythic_progbar:client:cancel")
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while IsAirdropStarted do
            Citizen.Wait(0)
            if AirdropRemaining > 1 then
                IFPRESS()
                Tiemdelay = AirdropRemaining - GetGameTimer()
                Tiemdelay = Tiemdelay / 1000
                SendNUIMessage({
                    action = "AirdropAlert",
                    Text = secondsToClock(Tiemdelay)
                })
            else
                SendNUIMessage({
                    action = "CloseAirdropAlert"
                })
            end
            --
            local Coords = IsAirdrop.SpawnCoords
            DrawMarker(28, Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Radius, Radius, Radius, 67, 94, 82, 155, false, true, 2, false, false, false, false)
            --
            local playerPed = PlayerPedId()
            local PlayerCoords = GetEntityCoords(playerPed)
            local dist = Vdist(Coords.x, Coords.y, Coords.z, PlayerCoords)
            if dist <= Radius then
                OutZoneAi = true
                if dist <= 4.0 then
                    if AirdropRemaining <= 0 then
                        if dist <= 1.5 and not IsDead and not IsAnimation then
                            ShowHelpNotification("Press ~INPUT_CONTEXT~ to open ~q~Airdrop")
                            if IsControlJustPressed(0, 51) then
                                Citizen.CreateThread(function()
                                    IsAnimation = true
                                    local rdm = math.random(1,500)
                                    Citizen.Wait(rdm)
                                    Health = GetEntityHealth(PlayerPedId())
                                    Armour = GetPedArmour(PlayerPedId())
                                    CheckHealth()
                                    KeepAirdrop()
                                end)
                            end
                        end
                    end
                end
            else
                if OutZoneAi and not IsDead then
                    OutZoneAi = false
                    Outzone()
                end
            end
        end
    end)
end

Outzone = function()
    Citizen.CreateThread(function()
        while not OutZoneAi and not IsDead and IsAirdropStarted do
            exports.pNotify:SendNotification({ text="Please enter within 1 second", type="error"})
            Citizen.Wait(1000)
            if not OutZoneAi and not IsDead and IsAirdropStarted then
                SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId())-10)
            end
        end
    end)
end

ClearPlayerState = function()
    IsAnimation           = false
    Health                = 200
    Armour                = 100
end

CheckHealth = function()
    Citizen.CreateThread(function()
        while IsAnimation do
            Citizen.Wait(0)
            if Health ~= GetEntityHealth(PlayerPedId()) then
                TriggerEvent("mythic_progbar:client:cancel")
            end
            if Armour ~= GetPedArmour(PlayerPedId()) then
                TriggerEvent("mythic_progbar:client:cancel")
            end
        end
    end)
end

KeepAirdrop = function()
    exports["mythic_progbar"]:Progress({
        name = "PickingAirdrop",
        duration = Config["TimeToPickingAirdrop"],
        label = Config["LabelToPickingAirdrop"],
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        },
        animation = {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
        },
    }, function(status)
        if not status and not IsDead and IsAnimation then
            TriggerServerEvent(script_name .. ":SV:Getitem", IsAirdrop.Label)
            TriggerServerEvent(script_name .. ":SV:DeleteAirdrop", IsAirdrop.Label)
        end
        ClearPlayerState()
    end)
end

RegisterNetEvent(script_name .. ":CL:DeleteAirdrop")
AddEventHandler(script_name .. ":CL:DeleteAirdrop", function()
    if IsAirdropStarted then
        if IsAnimation then
            TriggerEvent("mythic_progbar:client:cancel")
        end
        DeleteEntity(AirdropProp)
        TriggerServerEvent(script_name..":SV:asdwDZDG", "Airdrop", IsAirdrop.Label)
    end
    TriggerServerEvent(script_name..":SV:CheckEvent")
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteEntity(AirdropProp)
    end
end)