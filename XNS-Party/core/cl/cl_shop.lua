ESX = nil


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(10)
        TriggerEvent("esx:getSharedObject", function(esx)
            ESX = esx
        end)
    end
end)

RegisterNUICallback("GetShop", function(data, cb)
    ESX.TriggerServerCallback('XNS:CheckPoint', function(data)
        SendNUIMessage({
            action = "GetShop",
            Shop = Config["ItemShop"],
            Gc = data
        })
    end)
end)

RegisterNUICallback("BuyItem", function(data, cb)
    Wait(math.random(1000))
	TriggerServerEvent(script_name..":SV:BUYITEM", data.Name, data.Count)
end)