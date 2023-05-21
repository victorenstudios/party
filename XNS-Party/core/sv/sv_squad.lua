ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Squad = {}

ESX.RegisterServerCallback(script_name..":SV:GetSquad", function(source, cb)
    cb(Squad)
end)

RegisterServerEvent(script_name..":SV:CreateParty")
AddEventHandler(script_name..":SV:CreateParty",function(DataName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xItem = xPlayer.getInventoryItem(Config["TicketSquad"])
    if xItem.count > 0 then
        local NameAgain = false
        for i=1, #Squad, 1 do
            local SquadName = Squad[i].Name
            if DataName == SquadName then
                NameAgain = true
                break
            end
        end
        if NameAgain then
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "มีคนใช้ชื่อปาร์ตี้นี้แล้ว",
                type = "error",
                timeout = 5000,
                layout = "top-right",
                queue = "global"
            })
        else
            local sendToDiscord = string.format("คุณ: %s\nได้สร้างปาร์ตี้ %s",xPlayer.name, DataName)
            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'creatsquad', sendToDiscord, xPlayer.source, '^1')
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "สร้างปาร์ตี้สำเร็จ",
                type = "suscess",
                timeout = 5000,
                layout = "top-right",
                queue = "global"
            })
            xPlayer.removeInventoryItem(xItem.name, 1)
            table.insert(Squad, {
                Name = DataName,
                Status = false,
                PlayerCount = 1,
                PlayerMax = 4,
                Player = {
                    {
                        Name = xPlayer.name,
                        Identifier = xPlayer.identifier,
                        Source = xPlayer.source,
                        Status = true,
                        Boss = true
                    }
                }
            })
            TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xPlayer.source)
        end
    end
end)

RegisterServerEvent(script_name..":SV:GetSquadName")
AddEventHandler(script_name..":SV:GetSquadName",function()
    local xPlayer = ESX.GetPlayerFromId(source)
    for i=1, #Squad, 1 do
        for k, v in pairs(Squad[i].Player) do
            if v.Identifier == xPlayer.identifier then
                TriggerClientEvent(script_name..":CL:GetSquadName", xPlayer.source, Squad[i])
            end
        end
    end
end)

RegisterServerEvent(script_name..":SV:JoinSquad")
AddEventHandler(script_name..":SV:JoinSquad",function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for i=1, #Squad, 1 do
        local SquadName = Squad[i].Name
        if name == SquadName then
            if not Squad[i].Status then
                if Squad[i].PlayerCount < Squad[i].PlayerMax then
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "เข้าร่วมปาร์ตี้สำเร็จ",
                        type = "suscess",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                    table.insert(Squad[i].Player, {
                        Name = xPlayer.name,
                        Identifier = xPlayer.identifier,
                        Source = xPlayer.source,
                        Status = true,
                        Boss = false
                    })
                    Squad[i].PlayerCount = Squad[i].PlayerCount + 1
                    for k, v in pairs(Squad[i].Player) do
                        local xTarget = ESX.GetPlayerFromIdentifier(v.Identifier)
                        if xTarget then
                            TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xTarget.source)
                        end
                    end
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "ปาร์ตี้เต็ม",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
            else
                TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                    text = "ปาร์ตี้เริ่มไปแล้ว",
                    type = "error",
                    timeout = 5000,
                    layout = "top-right",
                    queue = "global"
                })
            end
            break
        end
    end
end)

RegisterServerEvent(script_name..":SV:KickSquad")
AddEventHandler(script_name..":SV:KickSquad",function(Identifier, name)
    local xTarget = ESX.GetPlayerFromIdentifier(Identifier)
    for i=1, #Squad, 1 do
        local SquadName = Squad[i].Name
        if name == SquadName then
            for k, v in pairs(Squad[i].Player) do
                if v.Identifier == xTarget.identifier then
                    local xPlayer = ESX.GetPlayerFromId(source)
                    local sendToDiscord = string.format("คุณ: %s\nได้เตะ %s %s",xPlayer.name, xTarget.name, name)
                    TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'kicksquad', sendToDiscord, xPlayer.source, '^1')
                    
                    TriggerClientEvent(script_name..":CL:KickSquad", xTarget.source, SquadName)
                    TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                        text = "คุณโดนเตะออกจากปาร์ตี้",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                    table.remove(Squad[i].Player, k)
                    Squad[i].PlayerCount = Squad[i].PlayerCount - 1
                end
                local xPlayer = ESX.GetPlayerFromIdentifier(v.Identifier)
                if xPlayer then
                    TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xPlayer.source)
                end
            end
            break
        end
    end
end)

RegisterServerEvent(script_name..":SV:SubmitQuitSquad")
AddEventHandler(script_name..":SV:SubmitQuitSquad",function(Identifier, name)
    local xTarget = ESX.GetPlayerFromIdentifier(Identifier)
    for i=1, #Squad, 1 do
        local SquadName = Squad[i].Name
        if name == SquadName then
            for k, v in pairs(Squad[i].Player) do
                if v.Identifier == xTarget.identifier then
                    TriggerClientEvent(script_name..":CL:QuitSquad", xTarget.source)
                    TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                        text = "คุณได้ออกจากปาร์ตี้",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                    table.remove(Squad[i].Player, k)
                    Squad[i].PlayerCount = Squad[i].PlayerCount - 1
                end
                local xPlayer = ESX.GetPlayerFromIdentifier(v.Identifier)
                if xPlayer then
                    TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xPlayer.source)
                end
            end
            break
        end
    end
end)

RegisterServerEvent(script_name..":SV:SubmitDeleteSquad")
AddEventHandler(script_name..":SV:SubmitDeleteSquad",function(name)
    for i=1, #Squad, 1 do
        local SquadName = Squad[i].Name
        if name == SquadName then
            local xTarget = ESX.GetPlayerFromId(source)
            local sendToDiscord = string.format("คุณ: %s\nได้ลบปาร์ตี้ %s",xTarget.name, name)
            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'deletesquad', sendToDiscord, xTarget.source, '^1')
            for k, v in pairs(Squad[i].Player) do
                local xPlayer = ESX.GetPlayerFromIdentifier(v.Identifier)
                if xPlayer then
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "ปาร์ตี้ถูกลบ",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                    TriggerClientEvent(script_name..":CL:QuitSquad", xPlayer.source)
                    TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xPlayer.source)
                end
            end
            table.remove(Squad, i)
        end
    end
end)

RegisterServerEvent(script_name..":SV:StartSquad")
AddEventHandler(script_name..":SV:StartSquad",function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    for i=1, #Squad, 1 do
        local SquadName = Squad[i].Name
        if name == SquadName then
            if not Squad[i].Status then
                Squad[i].Status = true
                for k, v in pairs(Squad[i].Player) do
                    local xTarget = ESX.GetPlayerFromIdentifier(v.Identifier)
                    if xTarget then
                        TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                            text = "ปาร์ตี้เริ่มแล้ว",
                            type = "suscess",
                            timeout = 5000,
                            layout = "top-right",
                            queue = "global"
                        })
                        TriggerClientEvent(script_name..":CL:TriggerGetSquadName", xTarget.source)
                    end
                end
            end
            break
        end
    end
end)