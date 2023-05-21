IsTpEvent   = false
IsInEvent   = false

IsOpen      = false

ESX = nil
script_name = GetCurrentResourceName()
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

RegisterNetEvent('framework:playerLoaded')
AddEventHandler('framework:playerLoaded', function(xPlayer)
    Citizen.Wait(1000)
    TriggerServerEvent(script_name..":SV:GetEvent")
end)

RegisterNetEvent(script_name..":CL:CloseMenu")
AddEventHandler(script_name..":CL:CloseMenu", function()
    SendNUIMessage({
        action = "closemenu"
    })
end)

AddEventHandler(Config["esx_routers"]['onPlayerDeath'], function(data)
    IsDead = true
    SendNUIMessage({
        action = "closemenu"
    })
    if IsTpEvent then
        TriggerEvent("mythic_progbar:client:cancel")
    end
end)

AddEventHandler(Config["esx_routers"]['playerSpawned'], function()
    IsDead = false
end)

RegisterCommand('Open-Menu', function()
    if not IsOpen and not IsTpEvent and not IsPedDeadOrDying(PlayerPedId()) then
        IsOpen = true
        TransitionToBlurred(1000)
        SendNUIMessage({
            action = "openmenu"
        })
        SetNuiFocus(true, true)
    end
end, false)

RegisterKeyMapping('Open-Menu', 'Open-Menu', 'keyboard', 'F7')

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        TransitionFromBlurred(1000)
    end
end)

RegisterNUICallback("cancel", function(data, cb)
    IsOpen = false
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end)




RegisterNetEvent(script_name..":CL:CheckEvent")
AddEventHandler(script_name..":CL:CheckEvent", function(data)
    IsInEvent = false
    -- Airdrop
    if IsAirdropStarted then
        IsAirdropStarted = false
        Citizen.Wait(100)
        IsAirdrop = nil
        IsAnimation = false
        SendNUIMessage({
            action = "CloseAirdropAlert"
        })
    end
    -- Flag
    if IsFlagStarted then
        if IsFlag.PlayerFlag == GetPlayerServerId(PlayerId()) then
            TriggerServerEvent(script_name..":SV:TooFar", IsFlag.Label)
        end
        IsFlagStarted = false
        Citizen.Wait(100)
        IsFlag = nil
        IsAnimation = false
        SendNUIMessage({
            action = "CloseFlag"
        })
    end
    -- Warzone
    if IsWarzone then
        IsWarzone = nil
    end
    -- 
    Teleport(vector3(data.Coords.x, data.Coords.y, data.Coords.z))
    SetStatuts(data.Status.Health, data.Status.Armour)
end)
RegisterNUICallback("GetEventMenu", function(data, cb)
    SendNUIMessage({
        action = "GetEventMenu",
        Status = IsInEvent
    })
end)
-- local A = false
-- Citizen.CreateThread(function() 
--     while true do
--         local sleep = 500
--         if IsTpEvent then
--             sleep = 100
--             loadAnimDict("missfam5_yoga")
--             if not A then
--                 A = true
--                 TaskPlayAnim(GetPlayerPed(-1), "missfam5_yoga", "c5_pose", 2.0, 2.0, -1, 1, 0, false, false, false)
--             else
--                 A = false
--                 TaskPlayAnim(GetPlayerPed(-1), "missfam5_yoga", "c6_pose", 2.0, 2.0, -1, 1, 0, false, false, false)
--             end
--         end
--         Citizen.Wait(sleep)
--     end
-- end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end


RegisterNUICallback("ExitEvent", function(data, cb)
    if IsWarzone then
        TriggerServerEvent(script_name..":SV:asdwDZDG", "Warzone", IsWarzone)
    elseif IsAirdropStarted then
        DeleteEntity(AirdropProp)
        TriggerServerEvent(script_name..":SV:asdwDZDG", "Airdrop", IsAirdrop.Label)
    elseif IsFlagStarted then
        TriggerServerEvent(script_name..":SV:asdwDZDG", "Flag", IsFlag.Label)
    end
    TriggerServerEvent(script_name..":SV:CheckEvent")
end)



function checkHasItem (item_name)
	local inventory = ESX.GetPlayerData().inventory
	for i=1, #inventory do
        local item = inventory[i]
        if item_name == item.name and item.count > 0 then
            return true
        end
	end
	return false
end

function Teleport(coords)
	-- DoScreenFadeOut(1000)
    -- Citizen.Wait(1000)
    TriggerEvent('XNS:Freeze')
	local playerPed = PlayerPedId()
	SetEntityCoords(playerPed, coords)
	-- Citizen.Wait(1000)
	-- DoScreenFadeIn(1000)
end

function SetStatuts(Health, Armour)
    if IsPedDeadOrDying(PlayerPedId()) then
        TriggerEvent('esx_ambulancejob:revive')
    end
    Citizen.Wait(1000)
    SetEntityHealth(PlayerPedId(), Health)
    SetPedArmour(PlayerPedId(), Armour)
end

RegisterFontFile('font4thai')
fontId = RegisterFontId('font4thai')
Draw2DText = function(textInput, x, y)
    SetTextFont(fontId)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(textInput)
    EndTextCommandDisplayText(x, y)
end

IFPRESS = function() --@ Custom function ( เวลา กด รั่วๆ หรือ ค้าง จะให้ทำไร )
    DisablePlayerFiring(PlayerPedId(), true)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 50, true)
    DisableControlAction(0, 68, true)
    DisableControlAction(0, 91, true)
    DisableControlAction(1, 37, true)
    DisableControlAction(0, 58, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 143, true)
    DisableControlAction(0, 263, true)
    DisableControlAction(0, 264, true)
    DisableControlAction(0, 257, true)
end

ShowHelpNotification = function(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function secondsToClock(seconds)
    local hours = string.format("%02.f", math.floor(seconds / 3600))
    local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
    local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
    return mins .. ':' .. secs
end

Drug = 0
RegisterNetEvent(script_name..":CL:Drug")
AddEventHandler(script_name..":CL:Drug", function()
    Drug = 5 * 60
end)

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1000)
        if Drug > 0 then
            Drug = Drug - 1
        end
    end
end)