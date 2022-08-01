local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function() 
    while true do
		Citizen.Wait(Config.Cooldown * 1000)
		TriggerServerEvent('tc-cokerun-updateTable', false)
	end
end)


CreateThread(function()
	RequestModel(`cs_nervousron`)
	  while not HasModelLoaded(`cs_nervousron`) do
	  Wait(1)
	end
	  methboss = CreatePed(2, `cs_nervousron`, Config.PedLocation['x'], Config.PedLocation['y'], Config.PedLocation['z'], Config.PedLocation['h'], false, false) 
	  SetPedFleeAttributes(methboss, 0, 0)
	  SetPedDiesWhenInjured(methboss, false)
	  TaskStartScenarioInPlace(methboss, "WORLD_HUMAN_CLIPBOARD", 0, true)
	  SetPedKeepTask(methboss, true)
	  SetBlockingOfNonTemporaryEvents(methboss, true)
	  SetEntityInvincible(methboss, true)
	  FreezeEntityPosition(methboss, true)
  end)


CreateThread(function()
    exports['qb-target']:AddTargetModel('cs_nervousron', {
        options = {
            { 
                type = "client",
                event = "tc-cokerun-buyPlane",
                icon = "fas fa-plane",
                label = "Rent A Plane",
            },
        },
        distance = 3.0 
    })
end)

local inUse = false

RegisterNetEvent('tc-cokerun-syncTable')
AddEventHandler('tc-cokerun-syncTable', function(bool)
    inUse = bool
end)


RegisterNetEvent('tc-cokerun-buyPlane', function()
	if not inUse then
		TriggerServerEvent('tc-cokerun-payPlane')
	else
		QBCore.Functions.Notify('Someone Already Rented A Plane', 'error', 7500)
	end
	Citizen.Wait(Config.Cooldown * 1000)
	inUse = false
end)


local location = nil

local delivering

local hangar

local airplane

local blip

local checkPlane


RegisterNetEvent('tc-cokerun-boughtPlane', function()
	local player = PlayerPedId()
	QBCore.Functions.Notify('Payed $' ..Config.Amount.. ' for plane rental', 'success', 7500)
	Citizen.Wait(2000)
	TriggerServerEvent('tc-cokerun-updateTable', true)
	QBCore.Functions.Notify("Go to the airfield.", "success")
	rand = math.random(1,#Config.locations)
	location = Config.locations[rand]
	blip1 = AddBlipForCoord(location.fuel.x,location.fuel.y,location.fuel.z)
	SetBlipRoute(blip1, true)
	enroute = true
	Citizen.CreateThread(function()
		while enroute do
			sleep = 5	
			local player = PlayerPedId()
			playerpos = GetEntityCoords(player)
			local disttocoord = #(vector3(location.fuel.x,location.fuel.y,location.fuel.z)-vector3(playerpos.x,playerpos.y,playerpos.z))
			if disttocoord <= 20 then
				PlaneSpawn()
				enroute = false
			else
				sleep = 1500
			end
			Citizen.Wait(sleep)
		end
	end)
end)



function PlaneSpawn()

	if DoesEntityExist(airplane) then
	    SetVehicleHasBeenOwnedByPlayer(airplane,false)
		SetEntityAsNoLongerNeeded(airplane)
		DeleteEntity(airplane)
	end

	local planehash = GetHashKey("dodo")
	
    RequestModel(planehash)
    while not HasModelLoaded(planehash) do
        Citizen.Wait(0)
    end

    airplane = CreateVehicle(planehash, location.parking.x, location.parking.y, location.parking.z, 100, true, false)
    local plt = GetVehicleNumberPlateText(airplane)
	SetVehicleHasBeenOwnedByPlayer(airplane,true)
	
	local plate = GetVehicleNumberPlateText(airplane)
	TriggerEvent("vehiclekeys:client:SetOwner", plate)

	RemoveBlip(blip1)
	SetBlipRoute(blip1, false)
	
	dodo = false
	delivering = true
	delivery()

	
    while true do
    	Citizen.Wait(5)
    	 DrawText3D(location.parking.x, location.parking.y, location.parking.z, "Cocaine Plane.")
		 if #(GetEntityCoords(PlayerPedId()) - vector3(location.parking.x, location.parking.y, location.parking.z)) < 8.0 then
    	 	return
    	 end
	end
end


function delivery()
	QBCore.Functions.Notify("There's a package for you, check your GPS and fly to get it", "success")
	local pickup = GetHashKey("prop_barrel_float_1")
	blip = AddBlipForCoord(location.delivery.x,location.delivery.y,location.delivery.z)
	SetBlipRoute(blip, true)
	RequestModel(pickup)
	while not HasModelLoaded(pickup) do
		Citizen.Wait(5)
	end
	local pickupSpawn = CreateObject(pickup, location.delivery.x,location.delivery.y,location.delivery.z, true, true, true)
	local player = PlayerPedId()
	Citizen.CreateThread(function()
		while delivering do
			sleep = 5	
			local playerpos = GetEntityCoords(player)
			local disttocoord = #(vector3(location.delivery.x,location.delivery.y,location.delivery.z)-vector3(playerpos.x,playerpos.y,playerpos.z))
			if disttocoord <= 30 then
				RemoveBlip(blip)
				SetBlipRoute(blip, false)
				exports['qb-core']:DrawText('[E] To Pick Up Package')
				if IsControlJustPressed(1, 51) then
					exports['qb-core']:KeyPressed()
					delivering = false

					QBCore.Functions.Progressbar("picking_", "Picking up the package..", lockpickTime, false, true, {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					}, {}, {}, {}, function() 
						DeleteEntity(pickupSpawn)
					end, function() 
						QBCore.Functions.Notify("Canceled!", "error")
					end)

					Citizen.Wait(2000)
					QBCore.Functions.Notify("Return back to the airfield marked on your GPS.", "success")
					Citizen.Wait(2000)
					final()
				end
			else
				sleep = 1500
				exports['qb-core']:HideText()
			end
			Citizen.Wait(sleep)
		end
	end)
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end

function final()
	QBCore.Functions.Notify("Deliver the plane back to a hangar", "success")
	blip = AddBlipForCoord(location.hangar.x,location.hangar.y,location.hangar.z)
	SetBlipRoute(blip, true)
	hangar = true
	local player = PlayerPedId()
	Citizen.CreateThread(function()
		while hangar do
			sleep = 5	
			local playerpos = GetEntityCoords(player)
			local disttocoord = #(vector3(location.hangar.x,location.hangar.y,location.hangar.z)-vector3(playerpos.x,playerpos.y,playerpos.z))
			if IsPedInAnyPlane(PlayerPedId()) and disttocoord <= 10 then
				RemoveBlip(blip)
				SetBlipRoute(blip, false)
				exports['qb-core']:DrawText('[E] To Park Plane')
				DrawMarker(27, location.hangar.x,location.hangar.y,location.hangar.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 3, 252, 152, 100, false, true, 2, false, false, false, false)
				if IsControlJustPressed(1, 51) then
					exports['qb-core']:KeyPressed()
					hangar = false
					FreezeEntityPosition(airplane, true)
					QBCore.Functions.Progressbar("park_plane", "Parking Plane", 1000, false, true, {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					}, {}, {}, {}, function() 
						DeleteEntity(airplane)
					end, function() 
						DeleteEntity(airplane)
					end)

					Citizen.Wait(2000)
					TriggerServerEvent('tc-cokerun-GiveItem')
					TaskLeaveVehicle(player, airplane, 0)
					SetVehicleDoorsLocked(airplane, 2)
					Citizen.Wait(1000)
					TriggerServerEvent('tc-cokerun-updateTable', false)
				end
			else
				exports['qb-core']:HideText()
				sleep = 1500
			end
			Citizen.Wait(sleep)
		end
	end)
end

Citizen.CreateThread(function()
	checkPlane = true
	while checkPlane do
		sleep = 100 
		if DoesEntityExist(airplane) then
			if GetVehicleEngineHealth(airplane) < 0 then
				QBCore.Functions.Notify("Failed, your plane was Destroyed", "error")
				TriggerServerEvent('tc-cokerun-updateTable', false)
				RemoveBlip(blip)
				SetBlipRoute(blip, false)
				DeleteEntity(pickupSpawn)
				delivering = false
				checkPlane = false
			end
		else
			sleep = 3000
		end
		Citizen.Wait(sleep)
	end
end)