local QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent('tc-cokerun-updateTable')
AddEventHandler('tc-cokerun-updateTable', function(bool)
    TriggerClientEvent('tc-cokerun-syncTable', -1, bool)
end)



RegisterNetEvent('tc-cokerun-payPlane', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local hasCash = Player.Functions.GetMoney('cash')
	local buyCash = Config.Amount

	if hasCash >= buyCash then
		Player.Functions.RemoveMoney('cash', buyCash)
		TriggerClientEvent('tc-cokerun-boughtPlane', -1)
	else
		TriggerClientEvent("QBCore:Notify", src, "You need $" ..buyCash.. " to rent", "error", 4000)
	end
end)

RegisterServerEvent("tc-cokerun-processed")
AddEventHandler("tc-cokerun-processed", function(x,y,z)
  	local src = source
  	local Player = QBCore.Functions.GetPlayer(src)
	local baggyamount = Config.BaggyAmount

		if 	TriggerClientEvent("QBCore:Notify", src, "Made Coke Bags", "Success", 8000) then
			Player.Functions.RemoveItem('coke_brick', 1) 
			Player.Functions.AddItem('cokebaggy', baggyamount)
			TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['coke_brick'], "remove")
			TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['cokebaggy'], "add")
		end
	end)




RegisterServerEvent("tc-cokerun-GiveItem")
AddEventHandler("tc-cokerun-GiveItem", function()
  	local src = source
	  local Player = QBCore.Functions.GetPlayer(src)
	  local price = Config.Price
	  local brick = Config.BrickAmount
	Player.Functions.AddMoney('cash', price)
	Player.Functions.AddItem('coke_brick', brick)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['coke_brick'], "add")
end)
