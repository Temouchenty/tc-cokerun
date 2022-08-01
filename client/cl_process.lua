local QBCore = exports['qb-core']:GetCoreObject()


local itemsTable = {
	'coke_brick',
	'cokeblueprint',
}

local isProcessing = false

Citizen.CreateThread(function()
	
    local sleep
	Citizen.Wait(5)
    while true do
        sleep = 5
        local player = PlayerPedId()
        local playercoords = GetEntityCoords(player)
        local tablecoordsx = Config.TableProcessLocation['x']
        local tablecoordsy = Config.TableProcessLocation['y']
        local tablecoordsz = Config.TableProcessLocation['z']
		local table = CreateObject(-2002254222, tablecoordsx, tablecoordsy, tablecoordsz, true, true, true)
		SetEntityHeading(table, Config.TableProcessLocation['heading'])
		FreezeEntityPosition(table, true)
        local dist = #(vector3(playercoords.x,playercoords.y,playercoords.z)-vector3(tablecoordsx,tablecoordsy,tablecoordsz))
        if dist <= 3 and not isProcessing then
            sleep = 5
			exports['qb-core']:DrawText('[E] To Break Down Brick')
            if IsControlJustPressed(1, 51) then        
                isProcessing = true
                QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                    if result then
                        processing()
                    else
                        QBCore.Functions.Notify("You are missing something", "error")
                        isProcessing = false
                    end
                end, itemsTable)
            end
        else
            sleep = 1500
			exports['qb-core']:HideText()
        end
        Citizen.Wait(sleep)
    end
end)





function processing()
	local player = PlayerPedId()
	FreezeEntityPosition(player, true)
	QBCore.Functions.Progressbar('process_coke', 'Processing Brick Into Bags', Config.ProcessTime, false, true, { 
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
		anim = 'machinic_loop_mechandplayer',
		flags = 49,
	}, {}, {}, function() 
		FreezeEntityPosition(player, false)
		TriggerServerEvent('tc-cokerun-processed')
		isProcessing = false
	end, function() 
		isProcessing = false
		ClearPedTasksImmediately(player)
		FreezeEntityPosition(player, false)
	end)
end
