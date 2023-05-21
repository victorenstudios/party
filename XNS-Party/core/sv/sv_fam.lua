ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback(script_name..":SV:GetFamily", function(source, cb)
    local Family = {}
    local Familys = MySQL.Sync.fetchAll('SELECT * FROM xns_family')
    for i=1, #Familys, 1 do
        local FamilyName = Familys[i].name
        table.insert(Family, {
            Name = Familys[i].name,
            Member = Familys[i].membercount,
            MaxMember = Familys[i].maxmembercount
        })
    end
    cb(Family)
end)

ESX.RegisterServerCallback(script_name..":SV:GetFamilyInfo", function(source, cb, name)
    MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
		['@name'] = name
	}, function(sql)
        cb(sql[1])
	end)
end)

RegisterServerEvent(script_name..":SV:SubmitManage")
AddEventHandler(script_name..":SV:SubmitManage",function(data, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local NameAgain = false
    local Familys = MySQL.Sync.fetchAll('SELECT * FROM xns_family')
    for i=1, #Familys, 1 do
        local FamilyName = Familys[i].name
        if FamilyName == data.Name and data.Name ~= name then
            NameAgain = true
            break
        end
    end
    if NameAgain then
        TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "มีครอบครัวใช้ชื่อนี้ไปแล้ว",
            type = "error",
            timeout = 5000,
            layout = "top-right",
            queue = "global"
        })
    else
        if data.Name ~= name then
            local sendToDiscord = string.format("คุณ: %s\nได้เปลี่ยนชื่อ จาก %s เป็น %s",xPlayer.name, name, data.Name)
            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'changnamefamily', sendToDiscord, xPlayer.source, '^1')
        end
        TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "บันทึกการเปลี่ยนแปลง",
            type = "suscess",
            timeout = 5000,
            layout = "top-right",
            queue = "global"
        })
        MySQL.Async.execute('UPDATE xns_family SET name = @name, bio = @bio, avatar_url = @avatar_url WHERE name = @realname', {
            ['@realname'] = name,
            ['@name'] = data.Name,
            ['@bio'] = data.Bio,
            ['@avatar_url'] = data.Img,
        })
        MySQL.Async.execute('UPDATE xns_family_members SET name = @name WHERE name = @realname', {
            ['@realname'] = name,
            ['@name'] = data.Name,
        })
    end
end)

RegisterServerEvent(script_name..":SV:ASDSADWDSADSADASWDASDSADWADASDASXZVAE")
AddEventHandler(script_name..":SV:ASDSADWDSADSADASWDASDSADWADASDASXZVAE",function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(Config["ItemChangeName"], 1)
end)

RegisterServerEvent(script_name..":SV:GetFamilyName")
AddEventHandler(script_name..":SV:GetFamilyName",function()
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM xns_family_members WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(sql)
		if sql[1] then
            local HaveRecruit = false
            local Permission = 0
            for k, v in pairs(Config["FamilyPermission"]) do
                if v.Grage == sql[1].grage then
                    if v.recruit then
                        HaveRecruit = true
                        Permission = k
                    end
                end
            end
            TriggerClientEvent(script_name..":CL:GetFamilyName", xPlayer.source, {
                Name = sql[1].name,
                Grage = sql[1].grage,
                HaveRecruit = HaveRecruit,
                Permission = Permission
            })
        else
            TriggerClientEvent(script_name..":CL:GetFamilyName", xPlayer.source, {})
		end
	end)
end)

RegisterServerEvent(script_name..":SV:CreateFamily")
AddEventHandler(script_name..":SV:CreateFamily",function(DataName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= Config["CreateFamilyCost"] then
        local NameAgain = false
        local Familys = MySQL.Sync.fetchAll('SELECT * FROM xns_family')
        for i=1, #Familys, 1 do
            local FamilyName = Familys[i].name
            if DataName == FamilyName then
                NameAgain = true
                break
            end
        end
        if NameAgain then
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "มีครอบครัวใช้ชื่อนี้ไปแล้ว",
                type = "error",
                timeout = 5000,
                layout = "top-right",
                queue = "global"
            })
        else
            local sendToDiscord = string.format("คุณ: %s\nได้สร้างครอบครัว %s",xPlayer.name, DataName)
            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'createfamily', sendToDiscord, xPlayer.source, '^1')
            xPlayer.removeMoney(Config["CreateFamilyCost"])
            local Member = {}
            table.insert(Member, {
                Name = xPlayer.name,
                Identifier = xPlayer.identifier,
                Grage = "Boss",
                Label = "หัวหน้า",
                Permission = 1
            })
            MySQL.Async.execute('INSERT INTO xns_family(name, member, boss, request, avatar_url, membercount, maxmembercount) VALUES (@name, @member, @boss, @request, @avatar_url, @membercount, @maxmembercount)', {
                ['@name'] = DataName,
                ['@member'] = json.encode(Member),
                ['@boss'] = xPlayer.name,
                ['@request'] = json.encode({}),
                ['@avatar_url'] = 'https://cdn.discordapp.com/attachments/998476679708160020/1065004160140984442/No-Image-Placeholder.svg.png',
                ['@membercount'] = 1,
                ['@maxmembercount'] = 20
            }, function(rows)
                if rows then
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "สร้างครอบครัวสำเร็จ",
                        type = "success",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
            end)
            MySQL.Async.execute('INSERT INTO xns_family_members(identifier, grage, name) VALUES (@identifier, @grage, @name)', {
                ['@identifier'] = xPlayer.identifier,
                ['@grage'] = "Boss",
                ['@name'] = DataName,
            })
            TriggerClientEvent(script_name..":CL:TriggerGetFamilyName", xPlayer.source)
        end
    end
end)

RegisterServerEvent(script_name..":SV:ApplyFamily")
AddEventHandler(script_name..":SV:ApplyFamily",function(DataName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local IsRequest = false
    MySQL.Async.fetchAll('SELECT * FROM xns_family_cooldown WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
    }, function(result)
        if (result[1] ~= nil) then
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "สามารถเข้าร่วมได้ใน "..result[1].date,
                type = "error",
                timeout = 5000,
                layout = "top-right",
                queue = "global"
            })
        else
            MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
                ['@name'] = DataName,
            }, function(result)
                local Data = result[1]
                local DataRequest = json.decode(Data.request)
                for i=1, #DataRequest, 1 do
                    local Identifier = DataRequest[i].Identifier
                    if Identifier == xPlayer.identifier then
                        IsRequest = true
                        break
                    end
                end
                if IsRequest then
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "ขอเข้าร่วมไปแล้ว",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "ขอเข้าร่วมสำเร็จ",
                        type = "success",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                    table.insert(DataRequest, {
                        Name = xPlayer.name,
                        Identifier = xPlayer.identifier
                    })
                    MySQL.Async.execute('UPDATE xns_family SET request = @request WHERE name = @name', {
                        ['@name'] = DataName,
                        ['@request'] = json.encode(DataRequest)
                    })
                end
            end)
        end
    end)
end)

RegisterServerEvent(script_name..":SV:AccpetRequest")
AddEventHandler(script_name..":SV:AccpetRequest",function(Identifier, FamilyName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local MaxMember = false
    -- 
    local CheckMember = MySQL.Sync.fetchAll('SELECT * FROM xns_family')
    local Familys = MySQL.Sync.fetchAll('SELECT * FROM xns_family')
    for i=1, #CheckMember, 1 do
        local MemberCount = CheckMember[i].membercount
        local MaxMemberCount = CheckMember[i].maxmembercount
        local DataName = CheckMember[i].name
        if DataName == FamilyName then
            if MemberCount >= MaxMemberCount then
                MaxMember = true
                break
            end
        end
    end
    -- 
    if not MaxMember then
        local HaveFamily = false
        local IdentifierName = MySQL.Sync.fetchAll('SELECT * FROM xns_family_members')
        for i=1, #IdentifierName, 1 do
            local TargetName = IdentifierName[i].identifier
            if TargetName == Identifier then
                HaveFamily = true
                break
            end
        end
        if HaveFamily then
            MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
                ['@name'] = FamilyName,
            }, function(result)
                local HaveIdentifier = false
                local Data = result[1]
                local DataRequest = json.decode(Data.request)
                for i=1, #DataRequest, 1 do
                    local TargetIdentifier = DataRequest[i].Identifier
                    if TargetIdentifier == Identifier then
                        HaveIdentifier = DataRequest[i].Name
                        table.remove(DataRequest, i)
                        break
                    end
                end
                if HaveIdentifier then
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = HaveIdentifier.." มีครอบครัวอยู่แล้วไม่สามารถเข้าร่วมได้",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                    MySQL.Async.execute('UPDATE xns_family SET request = @request WHERE name = @name', {
                        ['@name'] = FamilyName,
                        ['@request'] = json.encode(DataRequest)
                    })
                    TriggerClientEvent(script_name..":CL:RefreshRequest", xPlayer.source)
                end
            end)
        else
            MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
                ['@name'] = FamilyName,
            }, function(result)
                local Data = result[1]
                local DataRequest = json.decode(Data.request)
                local DataMember = json.decode(Data.member)
                local DataMemberCount = Data.membercount
                for i=1, #DataRequest, 1 do
                    local TargetIdentifier = DataRequest[i].Identifier
                    if TargetIdentifier == Identifier then
                        HaveIdentifier = DataRequest[i].Name
                        table.remove(DataRequest, i)
                        break
                    end
                end
                if HaveIdentifier then
                    MySQL.Async.fetchAll('SELECT * FROM xns_family_cooldown WHERE identifier = @identifier', {
                        ['@identifier'] = Identifier,
                    }, function(result)
                        if (result[1] ~= nil) then
                            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                                text = HaveIdentifier.." ติดคูลดาวน์ "..result[1].date,
                                type = "error",
                                timeout = 5000,
                                layout = "top-right",
                                queue = "global"
                            })
                        else
                            local sendToDiscord = string.format("คุณ: %s\nได้รับเข้าครอบครัว %s %s",xPlayer.name, HaveIdentifier, FamilyName)
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'acceptfamily', sendToDiscord, xPlayer.source, '^1')
                            table.insert(DataMember, {
                                Name = HaveIdentifier,
                                Identifier = Identifier,
                                Grage = "Member",
                                Label = "สมาชิก",
                                Permission = 3
                            })
                            MySQL.Async.execute('UPDATE xns_family SET request = @request, member = @member, membercount = @membercount WHERE name = @name', {
                                ['@name'] = FamilyName,
                                ['@member'] = json.encode(DataMember),
                                ['@request'] = json.encode(DataRequest),
                                ['@membercount'] = DataMemberCount + 1
                            })
                            TriggerClientEvent(script_name..":CL:RefreshPlayerInFamily", xPlayer.source)
                            TriggerClientEvent(script_name..":CL:RefreshRequest", xPlayer.source)
                            MySQL.Async.execute('INSERT INTO xns_family_members(identifier, grage, name) VALUES (@identifier, @grage, @name)', {
                                ['@identifier'] = Identifier,
                                ['@grage'] = "Member",
                                ['@name'] = FamilyName,
                            })
                            local xTarget = ESX.GetPlayerFromIdentifier(Identifier)
                            if xTarget then
                                TriggerClientEvent(script_name..":CL:TriggerGetFamilyName", xTarget.source)
                                TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                                    text = FamilyName.." ได้รับคุณเข้าครอบครัวแล้ว",
                                    type = "success",
                                    timeout = 5000,
                                    layout = "top-right",
                                    queue = "global"
                                })
                            end
                        end
                    end)
                end
            end)
        end
    else
        TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "จำนวนสมาชิกเกินกำหนด",
            type = "error",
            timeout = 5000,
            layout = "top-right",
            queue = "global"
        })
    end
end)
RegisterServerEvent(script_name..":SV:DenyRequest")
AddEventHandler(script_name..":SV:DenyRequest",function(Identifier, FamilyName)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
        ['@name'] = FamilyName,
    }, function(result)
        local HaveIdentifier = false
        local Data = result[1]
        local DataRequest = json.decode(Data.request)
        for i=1, #DataRequest, 1 do
            local TargetIdentifier = DataRequest[i].Identifier
            if TargetIdentifier == Identifier then
                HaveIdentifier = DataRequest[i].Name
                table.remove(DataRequest, i)
                break
            end
        end
        if HaveIdentifier then
            local xTarget = ESX.GetPlayerFromIdentifier(Identifier)
            if xTarget then
                TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                    text = FamilyName.." ได้ปฏิเสธคำขอเข้าครอบครัวของคุณ",
                    type = "error",
                    timeout = 5000,
                    layout = "top-right",
                    queue = "global"
                })
            end
            MySQL.Async.execute('UPDATE xns_family SET request = @request WHERE name = @name', {
                ['@name'] = FamilyName,
                ['@request'] = json.encode(DataRequest)
            })
            TriggerClientEvent(script_name..":CL:RefreshRequest", xPlayer.source)
        end
    end)
end)

RegisterServerEvent(script_name..":SV:SubmitDeleteFamily")
AddEventHandler(script_name..":SV:SubmitDeleteFamily",function(FamilyName)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE FROM xns_family WHERE name = @name',{
        ['@name'] = FamilyName
    })
    local sendToDiscord = string.format("คุณ: %s\nได้ลบครอบครัว %s",xPlayer.name, FamilyName)
    TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'deletefamily', sendToDiscord, xPlayer.source, '^1')
    MySQL.Async.fetchAll('SELECT * FROM xns_family_members WHERE name = @name', {
        ['@name'] = FamilyName,
    }, function(result)
        for i=1, #result, 1 do
            local TargetIdentifier = result[i].identifier
            local xPlayer = ESX.GetPlayerFromIdentifier(TargetIdentifier)
            if xPlayer then
                TriggerClientEvent(script_name..":CL:TriggerGetFamilyName", xPlayer.source)
                TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                    text = "ครอบครัว "..FamilyName.." ได้ถูกยุบแล้ว",
                    type = "error",
                    timeout = 5000,
                    layout = "top-right",
                    queue = "global"
                })
            end
        end
        MySQL.Async.fetchAll('SELECT * FROM xns_family_members WHERE name = @name', {
            ['@name'] = FamilyName,
        }, function(result)
            for i=1, #result, 1 do
                local TargetIdentifier = result[i].identifier
                CooldownFamily(TargetIdentifier)
            end
        end)
        MySQL.Async.execute('DELETE FROM xns_family_members WHERE name = @name',{
            ['@name'] = FamilyName
        })
    end)
end)

RegisterServerEvent(script_name..":SV:SubmitUpGrageSloty")
AddEventHandler(script_name..":SV:SubmitUpGrageSloty",function(FamilyName)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
        ['@name'] = FamilyName,
    }, function(result)
        local Data = result[1]
        local DataMaxMemberCount = Data.maxmembercount
        xPlayer.removeInventoryItem(Config["ItemUpSlot"], 1)
        TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "เพิ่มสล็อต 5 สล็อต สำเร็จ",
            type = "suscess",
            timeout = 5000,
            layout = "top-right",
            queue = "global"
        })
        MySQL.Async.execute('UPDATE xns_family SET maxmembercount = @maxmembercount WHERE name = @name', {
            ['@name'] = FamilyName,
            ['@maxmembercount'] = DataMaxMemberCount + 5
        })
    end)
end)

RegisterServerEvent(script_name..":SV:SubmitQuitFamily")
AddEventHandler(script_name..":SV:SubmitQuitFamily",function(FamilyName)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
        ['@name'] = FamilyName,
    }, function(result)
        local HaveIdentifier = false
        local Data = result[1]
        local DataMember = json.decode(Data.member)
        local DataMemberCount = Data.membercount
        for i=1, #DataMember, 1 do
            local TargetIdentifier = DataMember[i].Identifier
            if TargetIdentifier == xPlayer.identifier then
                HaveIdentifier = DataMember[i].Name
                table.remove(DataMember, i)
                break
            end
        end
        if HaveIdentifier then
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "ออกจากครอบครัวเรียบร้อย",
                type = "suscess",
                timeout = 5000,
                layout = "top-right",
                queue = "global"
            })
            MySQL.Async.execute('UPDATE xns_family SET member = @member, membercount = @membercount WHERE name = @name', {
                ['@name'] = FamilyName,
                ['@member'] = json.encode(DataMember),
                ['@membercount'] = DataMemberCount - 1
            })
            MySQL.Async.execute('DELETE FROM xns_family_members WHERE identifier = @identifier',{
                ['@identifier'] = xPlayer.identifier
            })
            CooldownFamily(xPlayer.identifier)
            TriggerClientEvent(script_name..":CL:TriggerGetFamilyName", xPlayer.source)
        end
    end)
end)
RegisterServerEvent(script_name..":SV:KickPlayer")
AddEventHandler(script_name..":SV:KickPlayer",function(Identifier, FamilyName, Permission)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
        ['@name'] = FamilyName,
    }, function(result)
        local HaveIdentifier = false
        local Data = result[1]
        local DataMember = json.decode(Data.member)
        local DataMemberCount = Data.membercount

        for i=1, #DataMember, 1 do
            local TargetIdentifier = DataMember[i].Identifier
            if TargetIdentifier == Identifier then
                if Permission < DataMember[i].Permission then
                    HaveIdentifier = DataMember[i].Name
                    table.remove(DataMember, i)
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "คุณไม่สามารถเตะคนยศสูงกว่าหรือเท่ากันได้",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
                break
            end
        end
        if HaveIdentifier then
            local sendToDiscord = string.format("คุณ: %s\nได้เตะออกครอบครัว %s %s",xPlayer.name, HaveIdentifier, FamilyName)
            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'kickfamily', sendToDiscord, xPlayer.source, '^1')
            MySQL.Async.execute('UPDATE xns_family SET member = @member, membercount = @membercount WHERE name = @name', {
                ['@name'] = FamilyName,
                ['@member'] = json.encode(DataMember),
                ['@membercount'] = DataMemberCount - 1
            })
            MySQL.Async.execute('DELETE FROM xns_family_members WHERE identifier = @identifier',{
                ['@identifier'] = Identifier
            })
            CooldownFamily(Identifier)
            TriggerClientEvent(script_name..":CL:RefreshPlayerInFamily", xPlayer.source)
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "คุณได้นำ "..HaveIdentifier.." ออกจากครอบครัวแล้ว",
                type = "error",
                timeout = 5000,
                layout = "top-right",
                queue = "global"
            })
            local xTarget = ESX.GetPlayerFromIdentifier(Identifier)
            if xTarget then
                TriggerClientEvent(script_name..":CL:TriggerGetFamilyName", xTarget.source)
                TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                    text = FamilyName.." ได้นำคุณออกจากครอบครัว",
                    type = "error",
                    timeout = 5000,
                    layout = "top-right",
                    queue = "global"
                })
            end
        end
    end)
end)

RegisterServerEvent(script_name..":SV:UpRank")
AddEventHandler(script_name..":SV:UpRank",function(Rankdata, FamilyName, Permission)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerData = Rankdata
    MySQL.Async.fetchAll('SELECT * FROM xns_family WHERE name = @name', {
        ['@name'] = FamilyName,
    }, function(result)
        local Data = result[1]
        local DataMember = json.decode(Data.member)
        local DataMemberCount = Data.membercount

        for i=1, #DataMember, 1 do
            local TargetIdentifier = DataMember[i].Identifier
            if TargetIdentifier == xPlayerData.Name then
                if Permission < DataMember[i].Permission then
                    for k, v in pairs(Config["FamilyPermission"]) do
                        if v.Grage == xPlayerData.Rank then
                            DataMember[i].Grage = v.Grage
                            DataMember[i].Label = v.label
                            MySQL.Async.execute('UPDATE xns_family_members SET grage = @grage WHERE identifier = @identifier', {
                                ['@identifier'] = TargetIdentifier,
                                ['@grage'] = v.Grage
                            })
                            break
                        end
                    end
                else
                    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                        text = "คุณไม่จัดการคนยศสูงกว่าได้",
                        type = "error",
                        timeout = 5000,
                        layout = "top-right",
                        queue = "global"
                    })
                end
                break
            end
        end
        MySQL.Async.execute('UPDATE xns_family SET member = @member WHERE name = @name', {
            ['@name'] = FamilyName,
            ['@member'] = json.encode(DataMember)
        })
        local xTarget = ESX.GetPlayerFromIdentifier(xPlayerData.Name)
        if xTarget then
            TriggerClientEvent(script_name..":CL:TriggerGetFamilyName", xTarget.source)
        end
    end)
end)

ESX.RegisterServerCallback(script_name..':avatars', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = GetPlayerIdentifiers(source)[1]

    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier ',{['identifier'] = xPlayer.identifier}, function(result)
        local avatar = {}
        if (result[1] ~= nil) then
            for i = 1, #result, 1 do
                table.insert(avatar, {
                    steamid = tonumber(identifier:gsub("steam:", ""), 16),
                    Name = xPlayer.name,
                    Hex = xPlayer.identifier
                })
            end
            cb(avatar)
        end
    end)
end)

CooldownFamily = function(identifier)
    local ThisTime = os.date('%Y-%m-%d %H:%M:%S', os.time())
    MySQL.Async.execute('INSERT INTO xns_family_cooldown (identifier, date) VALUES (@identifier, DATE_ADD(@day, INTERVAL @add Day))',{
        ['@identifier'] = identifier,
        ['@day'] = ThisTime,
        ['@add'] = Config["CooldownDay"],
    },function(rChange)
    end)
end

Citizen.CreateThread(function ()
    local delay = 1 * 60 * 1000; 
    while true do
        DeleteCoolDown()
        Citizen.Wait(delay)
    end
end)

DeleteCoolDown = function()
    local thistime = os.date('%Y-%m-%d %H:%M:%S', os.time())
    MySQL.Async.fetchAll('SELECT * FROM xns_family_cooldown WHERE date < @time',{
        ['@time'] = thistime
    }, function(result)
        -- print(ESX.DumpTable(result))
        if(result[1])then
            MySQL.Async.execute('DELETE FROM xns_family_cooldown WHERE identifier = @identifier',{
                ['@identifier'] = result[1].identifier
            })
        end
    end)  
end