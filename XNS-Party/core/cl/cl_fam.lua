ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

Family = {}
ChangeCooldown = 0
local SteamAPI = 'C63655A079C751F7F4378B47B94B5744'

RegisterNetEvent('framework:playerLoaded')
AddEventHandler('framework:playerLoaded', function(xPlayer)
    Citizen.Wait(1000)
    TriggerServerEvent(script_name..":SV:GetFamilyName")
    ESX.TriggerServerCallback(script_name..':avatars', function(data)
        if data[1].steamid then
            steamid = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. SteamAPI .. "&steamids=" .. data[1].steamid
        else
            steamid = 'null'
        end
        SendNUIMessage({
            action = "SetAvatar",
            Url = steamid,
            Name = data[1].Name,
            Hex = data[1].Hex
        })
    end)
end)
-- Citizen.CreateThread(function()
-- 	Citizen.Wait(1000)
--     TriggerServerEvent(script_name..":SV:GetFamilyName")
--     ESX.TriggerServerCallback(script_name..':avatars', function(data)
--         if data[1].steamid then
--             steamid = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. SteamAPI .. "&steamids=" .. data[1].steamid
--         else
--             steamid = 'null'
--         end
--         SendNUIMessage({
--             action = "SetAvatar",
--             Url = steamid,
--             Name = data[1].Name,
--             Hex = data[1].Hex
--         })
--     end)
-- end)

RegisterNetEvent(script_name..":CL:TriggerGetFamilyName")
AddEventHandler(script_name..":CL:TriggerGetFamilyName", function()
    TriggerServerEvent(script_name..":SV:GetFamilyName")
end)

RegisterNetEvent(script_name..":CL:GetFamilyName")
AddEventHandler(script_name..":CL:GetFamilyName", function(name)
    Family = name
    -- print(ESX.DumpTable(Family))
end)

RegisterNUICallback("GetFamily", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetFamily", function(data)
        SendNUIMessage({
            action = "GetFamily",
            CreateCost = ESX.Math.GroupDigits(Config["CreateFamilyCost"]),
            DataFamily = data,
            MyFamily = Family
        })
    end)
end)

RegisterNUICallback("GetFamilyInfo", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetFamilyInfo", function(fam)
        SendNUIMessage({
            action = "GetFamilyInfo",
            Family = fam,
            MyFamily = Family
        })
    end, data.name)
end)

RegisterNUICallback("SeeMember", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetFamilyInfo", function(fam)
        SendNUIMessage({
            action = "SeeMember",
            Member = json.decode(fam.member),
        })
    end, data.name)
end)

-- function checkMoney()
--     local data = ESX.GetPlayerData()
--     print(data.money)
-- end

-- RegisterCommand('checkmoney', function()
--     checkMoney()
-- end, false)

RegisterNUICallback("CreateFamily", function(data, cb)
    Wait(math.random(1000))
    local playerData = ESX.GetPlayerData()
    if Family.Name == nil then
        if data.name ~= nil then
            if playerData.money >= Config["CreateFamilyCost"] then
                TriggerServerEvent(script_name..":SV:CreateFamily", data.name)
            else
                exports.pNotify:SendNotification({ text="เงินไม่เพียงพอ", type="error"})
            end
        else
            exports.pNotify:SendNotification({ text="โปรดใส่ชื่อครอบครัว", type="error"})
        end
    else
        exports.pNotify:SendNotification({ text="โปรดออกจากครอบครัวเก่าก่อน", type="error"})
    end
end)

RegisterNUICallback("ApplyFamily", function(data, cb)
    if Family.Name == nil then
        TriggerServerEvent(script_name..":SV:ApplyFamily", data.name)
    else
        exports.pNotify:SendNotification({ text="โปรดออกจากครอบครัวเก่าก่อน", type="error"})
    end
end)

RegisterNUICallback("GetManageFamily", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetFamilyInfo", function(fam)
        local Request = json.decode(fam.request)
        local RequestCount = false
        if #Request > 0 then
            RequestCount = true
        end
        SendNUIMessage({
            action = "GetManageFamily",
            Family = fam,
            MyFamily = Family,
            Member = json.decode(fam.member),
            Identifier = ESX.GetPlayerData().identifier,
            RequestCount = RequestCount
        })
    end, Family.Name)
end)

RegisterNUICallback("GetManageRequest", function(data, cb)
    ESX.TriggerServerCallback(script_name..":SV:GetFamilyInfo", function(fam)
        SendNUIMessage({
            action = "GetManageRequest",
            Request = json.decode(fam.request)
        })
    end, Family.Name)
end)

RegisterNUICallback("SubmitManage", function(data, cb)
    if ChangeCooldown > 0 then
        exports.pNotify:SendNotification({ text="เหลือเวลาอีก "..ChangeCooldown.. " วินาทีถึงทำการแก้ไขได้", type="error"})
        return
    end
    if Family.Grage ~= 'Boss' then
        exports.pNotify:SendNotification({ text="ไม่สามารถแก้ไขได้เนื่องจากไม่ใช่หัวหน้า", type="error"})
        return
    end
    if data.Name == nil or data.Name == '' then
        exports.pNotify:SendNotification({ text="ไม่สามารถเว้นชื่อว่างได้", type="error"})
        return
    end
    if data.Img == nil or data.Img == '' then
        exports.pNotify:SendNotification({ text="ไม่สามารถเว้นรูปว่างได้", type="error"})
        return
    end
    if data.Bio == nil or data.Bio == '' then
        exports.pNotify:SendNotification({ text="ไม่สามารถเว้นสังเขปว่างได้", type="error"})
        return
    end
    if data.Name ~= nil or data.Name ~= '' then
        if data.Name ~= Family.Name then
            if not checkHasItem(Config["ItemChangeName"]) then
                exports.pNotify:SendNotification({ text="ต้องการบัตรเปลี่ยนชื่อ", type="error"})
                return
            else
                TriggerServerEvent(script_name..":SV:ASDSADWDSADSADASWDASDSADWADASDASXZVAE")
            end
        end
    end
    ChangeCooldown = 60
    Citizen.CreateThread(function()
        while ChangeCooldown > 0 do
            Citizen.Wait(1000)
            ChangeCooldown = ChangeCooldown - 1
        end
    end)
    TriggerServerEvent(script_name..":SV:SubmitManage", data, Family.Name)
end)

RegisterNUICallback("SubmitUpGrageSloty", function(data, cb)
    if not checkHasItem(Config["ItemUpSlot"]) then
        exports.pNotify:SendNotification({ text="ต้องการ Card Up Slot", type="error"})
        return
    else
        TriggerServerEvent(script_name..":SV:SubmitUpGrageSloty", Family.Name)
    end
end)

RegisterNUICallback("SubmitDeleteFamily", function(data, cb)
    TriggerServerEvent(script_name..":SV:SubmitDeleteFamily", Family.Name)
end)

RegisterNUICallback("AccpetRequest", function(data, cb)
    TriggerServerEvent(script_name..":SV:AccpetRequest", data.Name, Family.Name)
end)
RegisterNUICallback("DenyRequest", function(data, cb)
    TriggerServerEvent(script_name..":SV:DenyRequest", data.Name, Family.Name)
end)
RegisterNetEvent(script_name..":CL:RefreshRequest")
AddEventHandler(script_name..":CL:RefreshRequest", function()
    ESX.TriggerServerCallback(script_name..":SV:GetFamilyInfo", function(fam)
        SendNUIMessage({
            action = "GetManageRequest",
            Request = json.decode(fam.request)
        })
    end, Family.Name)
end)
RegisterNUICallback("SubmitQuitFamily", function(data, cb)
    TriggerServerEvent(script_name..":SV:SubmitQuitFamily", Family.Name)
end)

RegisterNetEvent(script_name..":CL:RefreshPlayerInFamily")
AddEventHandler(script_name..":CL:RefreshPlayerInFamily", function()
    ESX.TriggerServerCallback(script_name..":SV:GetFamilyInfo", function(fam)
        SendNUIMessage({
            action = "RefreshPlayerInFamily",
            Member = json.decode(fam.member),
            Identifier = ESX.GetPlayerData().identifier,
        })
    end, Family.Name)
end)
RegisterNUICallback("KickPlayer", function(data, cb)
    TriggerServerEvent(script_name..":SV:KickPlayer", data.Name, Family.Name, Family.Permission)
end)

RegisterNUICallback("GetRank", function(data, cb)
    local Rank = {}
    for k, v in pairs(Config["FamilyPermission"]) do
        if tonumber(Family.Permission) < tonumber(k) then
            table.insert(Rank, v)
        end
    end
    SendNUIMessage({
        action = "GetRank",
        Rank = Rank
    })
end)

RegisterNUICallback("UpRank", function(data, cb)
    TriggerServerEvent(script_name..":SV:UpRank", data, Family.Name, Family.Permission)
end)