ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('addpoint', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'staff' then
        local _source = args[1]
        local xTarget = ESX.GetPlayerFromId(_source)
        if xTarget then
            local sendToDiscord = string.format("คุณ: %s\nได้รับพ้อยจากแอดมิน %s จำนวน: %s",xTarget.name, xPlayer.name, args[2])
            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'termgc', sendToDiscord, xPlayer.source, '^1')
            MySQL.Async.execute("UPDATE users SET point = point + @point WHERE identifier = @identifier", {['@identifier'] = xTarget.identifier,['@point'] = args[2]}, function()end)
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "แอดพ้อยสำเร็จ",
                type = "suscess",
                timeout = 3000,
                layout = "topRight",
                queue = "global"
            })
            TriggerClientEvent("pNotify:SendNotification", xTarget.source, {
                text = "แอดพ้อยสำเร็จ",
                type = "suscess",
                timeout = 3000,
                layout = "topRight",
                queue = "global"
            })
        else
            TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
                text = "ไม่พบผู้เล่น",
                type = "error",
                timeout = 3000,
                layout = "topRight",
                queue = "global"
            })
        end
    end
end)

RegisterServerEvent(script_name..":SV:BUYITEM")
AddEventHandler(script_name..":SV:BUYITEM",function(item, count)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    -- print(count)
    local count = ESX.Math.Round(count, 0)
    -- print(count)
	local countx = tonumber(count)
    for k,v in pairs(Config["ItemShop"]) do
        if v.item == item then
            MySQL.Async.fetchAll('SELECT point FROM users WHERE identifier = @identifier', {
                ['@identifier']  = xPlayer.identifier
                }, function(result)
                if result then
                    if result[1].point > v.price * count - 1  then
                        if countx < 1 then
                            TriggerClientEvent("pNotify:SendNotification", _source, {
                                text = "จำนวนไม่ถูกต้อง",
                                type = "error",
                                timeout = 3000,
                                layout = "topRight",
                                queue = "global"
                            })
                        else
                            TriggerClientEvent("pNotify:SendNotification", _source, {
                                text = "พ้อยคงเหลือ " ..result[1].point - (v.price * count),
                                type = "error",
                                timeout = 3000,
                                layout = "topRight",
                                queue = "global"
                            })
                            xPlayer.addInventoryItem(v.item, count)
                            local sendToDiscord = string.format("คุณ:%s\nชื้อไอเทมในสินค้าชื่อ:%s | จำนวน:%s", xPlayer.name, item, count)
                            TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'gc', sendToDiscord, xPlayer.source, '^1')
                            MySQL.Async.execute("UPDATE users SET point = point - @point WHERE identifier = @identifier", { ['@identifier'] = xPlayer.identifier, ['@point'] = v.price * count  }, function()end)
                        end
                    else
                        TriggerClientEvent("pNotify:SendNotification", _source, {
                            text = "พ้อยไม่พอในการชื้อ",
                            type = "error",
                            timeout = 3000,
                            layout = "topRight",
                            queue = "global"
                        })
                    end
                end
            end)
        end
	end
end)

ESX.RegisterServerCallback('XNS:CheckPoint', function(source, cb)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.fetchAll('SELECT point FROM users WHERE identifier = @identifier', {
        ['@identifier']  = xPlayer.identifier
		}, function(result)
        if result ~= nil then
			cb(result[1].point)
		else
			cb(nil)
		end
	end)
end)