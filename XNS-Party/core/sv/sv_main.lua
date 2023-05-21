ESX = nil
script_name = GetCurrentResourceName()
TriggerEvent(Config["esx_routers"]['getSharedObject'], function(obj) ESX = obj end)

RegisterServerEvent(script_name..":SV:GetEvent")
AddEventHandler(script_name..":SV:GetEvent",function(Name)
    local _source = source
    if IsAirdropStarted then
        TriggerClientEvent(script_name .. ":CL:GetEventAirdrop", _source, {
            Time = GetGameTimer(),
            StartTime = AirdropRemaining
        }, AirdropState)
    end
    if IsFlagStarted then
        TriggerClientEvent(script_name .. ":CL:GetEventFlag", _source, {
            Time = GetGameTimer(),
            StartTime = FlagRemaining
        }, FlagState)
    end
    -- 
    local Notfound4 = false
    local Time4 = 15
    Citizen.CreateThread(function()
        while Time4 > 0 and not Notfound4 do
            Citizen.Wait(1000)
            if Time4 > 0 then
                Time4 = Time4 - 1
            end
        end
    end)
    Citizen.CreateThread(function() 
        while not Notfound4 do
            Wait(0)
            if Time4 == 0 then
                Notfound4 = true
            end
            for k, v in pairs(Squad) do
                for kk,vv in pairs(v.Player) do
                    local xPlayer = ESX.GetPlayerFromId(_source)
                    if vv.Identifier == xPlayer.identifier then
                        vv.Source = xPlayer.source
                        vv.Status = true
                        for kkk,vvv in pairs(v.Player) do
                            local xTarget = ESX.GetPlayerFromIdentifier(vvv.Identifier)
                            if xTarget then
                                TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xTarget.source)
                            end
                        end
                        Notfound4 = true
                    end
                end
            end
        end
    end)
end)

AddEventHandler(Config["esx_routers"]['playerDropped'], function(source)
	local _source = source
    -- print(_source)
	if _source ~= nil then
        -- Warzone
		local Notfound = false
        local Time = 15
        Citizen.CreateThread(function()
            while Time > 0 and not Notfound do
                Citizen.Wait(1000)
                if Time > 0 then
                    Time = Time - 1
                end
            end
        end)
        Citizen.CreateThread(function() 
            while not Notfound do
                Wait(0)
                if Time == 0 then
                    Notfound = true
                end
                for k, v in pairs(WarzoneState) do
                    for kk,vv in pairs(v.Source) do
                        if tonumber(vv) == tonumber(_source) then
                            v.Player = v.Player - 1
                            table.remove(v.Source, kk)
                            Notfound = true
                        end
                    end
                end
            end
        end)
        -- Airdrop
        local Notfound2 = false
        local Time2 = 15
        Citizen.CreateThread(function()
            while Time2 > 0 and not Notfound2 do
                Citizen.Wait(1000)
                if Time2 > 0 then
                    Time2 = Time2 - 1
                end
            end
        end)
        Citizen.CreateThread(function() 
            while not Notfound2 do
                Wait(0)
                if Time2 == 0 then
                    Notfound2 = true
                end
                for k, v in pairs(AirdropState) do
                    for kk,vv in pairs(v.Source) do
                        if tonumber(vv) == tonumber(_source) then
                            v.Player = v.Player - 1
                            table.remove(v.Source, kk)
                            Notfound2 = true
                        end
                    end
                end
            end
        end)
        -- Flag
        local Notfound3 = false
        local Time3 = 15
        Citizen.CreateThread(function()
            while Time3 > 0 and not Notfound3 do
                Citizen.Wait(1000)
                if Time3 > 0 then
                    Time3 = Time3 - 1
                end
            end
        end)
        Citizen.CreateThread(function() 
            while not Notfound3 do
                Wait(0)
                if Time3 == 0 then
                    Notfound3 = true
                end
                for k, v in pairs(FlagState) do
                    if v.PlayerFlag == tonumber(_source) then
                        v.PlayerText = "ยังไม่มีผู้ครอบครอง"
                        v.Coords = v.RealCoords
                        v.PlayerHoldFlag = 0
                        for kk, vv in pairs(v.Source) do
                            local xTarget = ESX.GetPlayerFromId(vv)
                            if xTarget then
                                TriggerClientEvent(script_name..":CL:FlagDie", xTarget.source, "ยังไม่มีผู้ครอบครอง", v.Coords)
                            end
                        end
                        v.PlayerFlag = nil
                    end
                    for kk,vv in pairs(v.Source) do
                        if tonumber(vv) == tonumber(_source) then
                            v.Player = v.Player - 1
                            table.remove(v.Source, kk)
                            Notfound3 = true
                        end
                    end
                end
            end
        end)
        -- Squad
        local Notfound4 = false
        local Time4 = 15
        Citizen.CreateThread(function()
            while Time4 > 0 and not Notfound4 do
                Citizen.Wait(1000)
                if Time4 > 0 then
                    Time4 = Time4 - 1
                end
            end
        end)
        Citizen.CreateThread(function() 
            while not Notfound4 do
                Wait(0)
                if Time4 == 0 then
                    Notfound4 = true
                end
                for k, v in pairs(Squad) do
                    for kk,vv in pairs(v.Player) do
                        if tonumber(vv.Source) == tonumber(_source) then
                            vv.Status = false
                            for kkk,vvv in pairs(v.Player) do
                                local xTarget = ESX.GetPlayerFromIdentifier(vvv.Identifier)
                                if xTarget then
                                    TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xTarget.source)
                                end
                            end
                            Notfound4 = true
                        end
                    end
                end
            end
        end)
	end	
end)

RegisterServerEvent(script_name..":SV:CheckEvent")
AddEventHandler(script_name..":SV:CheckEvent",function(Name)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM xns_event WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(sql)
        if sql[1] ~= nil then
            local Data = {
                Coords = json.decode(sql[1].coords),
                Status = json.decode(sql[1].status),
            }
            SetPlayerRoutingBucket(xPlayer.source, 0)
            for k, v in pairs(Config["Item"]) do
                local xItem = xPlayer.getInventoryItem(v)
                if xItem.count > 0 then
                    xPlayer.setInventoryItem(xItem.name, 0)
                end
            end
            TriggerClientEvent(script_name..":CL:CheckEvent", xPlayer.source, Data)
            MySQL.Async.execute('DELETE FROM xns_event WHERE identifier = @identifier',{
                ['@identifier'] = xPlayer.identifier
            })
        end
	end)
end)

RegisterServerEvent(script_name..":SV:asdwDZDG")
AddEventHandler(script_name..":SV:asdwDZDG",function(Type, Name)
    local _source = source
    if Type == 'Warzone' then
        local Notfound = false
        local Time = 15
        Citizen.CreateThread(function()
            while Time > 0 and not Notfound do
                Citizen.Wait(1000)
                if Time > 0 then
                    Time = Time - 1
                end
            end
        end)
        -- 
        Citizen.CreateThread(function() 
            while not Notfound do
                Wait(0)
                if Time == 0 then
                    Notfound = true
                end
                for k, v in pairs(WarzoneState) do
                    if k == Name then
                        for kk,vv in pairs(v.Source) do
                            if tonumber(vv) == tonumber(_source) then
                                v.Player = v.Player - 1
                                table.remove(v.Source, kk)
                                Notfound = true
                            end
                        end
                    end
                end
            end
        end)
    elseif Type == 'Airdrop' then
        local Notfound = false
        local Time = 15
        Citizen.CreateThread(function()
            while Time > 0 and not Notfound do
                Citizen.Wait(1000)
                if Time > 0 then
                    Time = Time - 1
                end
            end
        end)
        -- 
        Citizen.CreateThread(function() 
            while not Notfound do
                Wait(0)
                if Time == 0 then
                    Notfound = true
                end
                for k, v in pairs(AirdropState) do
                    if v.Label == Name then
                        for kk,vv in pairs(v.Source) do
                            if tonumber(vv) == tonumber(_source) then
                                v.Player = v.Player - 1
                                table.remove(v.Source, kk)
                                Notfound = true
                            end
                        end
                    end
                end
            end
        end)
    elseif Type == 'Flag' then
        local Notfound = false
        local Time = 15
        Citizen.CreateThread(function()
            while Time > 0 and not Notfound do
                Citizen.Wait(1000)
                if Time > 0 then
                    Time = Time - 1
                end
            end
        end)
        -- 
        Citizen.CreateThread(function() 
            while not Notfound do
                Wait(0)
                if Time == 0 then
                    Notfound = true
                end
                for k, v in pairs(FlagState) do
                    if v.Label == Name then
                        for kk,vv in pairs(v.Source) do
                            if tonumber(vv) == tonumber(_source) then
                                v.Player = v.Player - 1
                                table.remove(v.Source, kk)
                                Notfound = true
                            end
                        end
                    end
                end
            end
        end)
    end
end)

function secondsToClock(seconds)
    local hours = string.format("%02.f", math.floor(seconds / 3600))
    local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
    local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
    return mins .. ':' .. secs
end