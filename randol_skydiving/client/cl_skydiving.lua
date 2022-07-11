local QBCore = exports['qb-core']:GetCoreObject()
local waitingTakeOff = 0 -- Don't touch.

CreateThread(function()
    local blip = AddBlipForCoord(1742.21, 3295.82, 41.11)
    SetBlipSprite(blip, 94)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.65)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Skydiving")
    EndTextCommandSetBlipName(blip)
end)

local function drawTxt(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function startTimer(Time) -- Shoutout to qb-vehicleshop for having this countdown timer function I could yoink.
    local gameTimer = GetGameTimer()
    CreateThread(function()
        while waitingTakeOff do
            if GetGameTimer() < gameTimer + tonumber(1000 * Time) then
                local secondsLeft = GetGameTimer() - gameTimer
                drawTxt("TIME UNTIL TAKE OFF: " .. math.ceil(Time - secondsLeft / 1000), 4, 0.5, 0.93, 0.50, 255, 255, 255, 180)
            end
            Wait(0)
        end
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        AirfieldPilot()
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    AirfieldPilot()
end)

function AirfieldPilot()
	if not DoesEntityExist(igpilot) then

	RequestModel("ig_pilot")
	while not HasModelLoaded("ig_pilot") do
		Wait(0)
	end

                
		igpilot = CreatePed(4, "ig_pilot" , 1742.58, 3296.68, 40.14, 196.03, false, false)

		SetEntityAsMissionEntity(igpilot)
		SetBlockingOfNonTemporaryEvents(igpilot, true)
		SetEntityInvincible(igpilot, true)
		FreezeEntityPosition(igpilot, true)
		TaskStartScenarioInPlace(igpilot, "WORLD_HUMAN_CLIPBOARD", 0, true)

		exports['qb-target']:AddTargetEntity(igpilot, {
			options = {
				{
					type = "server",
					event = "randol_skydive:server:payforgroup",
					icon = "fa-solid fa-user-group",
					label = "Group Skydive ($750)",
				},
				{
					type = "client",
					event = "randol_skydive:client:ridewithbuddy",
					icon = "fa-solid fa-user-group",
					label = "Join Friends",
				},
				{
					type = "server",
					event = "randol_skydive:server:solojump",
					icon = "fa-solid fa-parachute-box",
					label = "Solo Jump",
				}
			},
			distance = 2.5,
		})
	end
end

--- GROUP FLIGHT

RegisterNetEvent('randol_skydive:client:skydivetime')
AddEventHandler('randol_skydive:client:skydivetime', function()
	local Ped = PlayerPedId()
	DoScreenFadeOut(2000)
	Wait(4000)

	planeHK = GetHashKey("mammatus")
	pilotHK = GetHashKey("s_m_m_pilot_01")
	
	RequestModel(planeHK)
	while not HasModelLoaded(planeHK) do
	Wait(0)
	end
	
	RequestModel(pilotHK)
	while not HasModelLoaded(pilotHK) do
	Wait(0)
	end
	
	if HasModelLoaded(planeHK) and HasModelLoaded(pilotHK) then
		local Skydive = CreateVehicle(planeHK, 1738.58, 3283.2, 41.11, 191.1, true, false)
		exports[Config.FuelExport]:SetFuel(Skydive, 100.0)
		SetEntityAsMissionEntity(Skydive, true, true)
		SetModelAsNoLongerNeeded(Skydive)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
		SetVehicleEngineOn(SkyDive, true, true)
		local pilot = CreatePedInsideVehicle(Skydive, 6, pilotHK, -1, true, false)
		Wait(500)
		SetPedIntoVehicle(Ped, Skydive, 2)
		TriggerServerEvent('randol_skydive:flightcooldown') -- Triggers global cooldown
		GiveWeaponToPed(Ped, GetHashKey("GADGET_PARACHUTE"), true)
		SetBlockingOfNonTemporaryEvents(pilot, true)
		SetPedCanBeDraggedOut(pilot, false)
		SetDriverAbility(pilot, 1.0)
		SetDriverAggressiveness(pilot, 0.0)
		DoScreenFadeIn(2000)
		
		startTimer(0.5 * 60) -- 30 seconds - Don't touch.
		Wait(30000) -- Time until it takes off. (Gives friends time to join) - Don't touch.
		TaskVehicleDriveToCoord(pilot, Skydive, 1122.66, 3094.08, 40.41, 30.0, 0, 1341619767, 786603, 1, true)
		Wait(28000) -- Give pilot time to go down the runway before switching route.
		TaskVehicleDriveToCoord(pilot, Skydive, -817.27, 4563.03, 1431.49, 253.07, 0, 1341619767, 4457279, 1, true)
		Wait(90000) -- Time spent in the air getting to destination before parachuting.
		SetAmbientVoiceName(pilot, "BRAD")
		PlayAmbientSpeech1(pilot, "GET_OUT_OF_HERE", "SPEECH_PARAMS_FORCE_NORMAL")
		Wait(3000)
		DeletePed(pilot)
		QBCore.Functions.DeleteVehicle(Skydive)
	end	
end)

----------- SOLO JUMP -------------

RegisterNetEvent('randol_skydive:client:skydivesolo')
AddEventHandler('randol_skydive:client:skydivesolo', function()
	local Ped = PlayerPedId()
	DoScreenFadeOut(2000)
	Wait(4000)

	planeHK = GetHashKey("dodo")
	pilotHK = GetHashKey("s_m_m_pilot_01")
	
	RequestModel(planeHK)
	while not HasModelLoaded(planeHK) do
	Wait(0)
	end
	
	RequestModel(pilotHK)
	while not HasModelLoaded(pilotHK) do
	Wait(0)
	end
	
	if HasModelLoaded(planeHK) and HasModelLoaded(pilotHK) then
		Skydive = CreateVehicle(planeHK, -2024.23, 4983.37, 968.92, 246.51, true, false)
		SetPedIntoVehicle(Ped, Skydive, 2)
		GiveWeaponToPed(Ped, GetHashKey("GADGET_PARACHUTE"), true)
		
		exports[Config.FuelExport]:SetFuel(Skydive, 100.0)
		SetEntityAsMissionEntity(Skydive, true, true)
		SetModelAsNoLongerNeeded(Skydive)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
		SetVehicleEngineOn(SkyDive, true, true)
		pilot = CreatePedInsideVehicle(Skydive, 6, pilotHK, -1, true, false)
		Wait(500)
		TriggerServerEvent('randol_skydive:flightcooldown')
		SetBlockingOfNonTemporaryEvents(pilot, true)
		SetPedCanBeDraggedOut(pilot, false)
		SetDriverAbility(pilot, 1.0)
		SetDriverAggressiveness(pilot, 0.0)
		TaskVehicleDriveToCoord(pilot, Skydive, 1201.69, 2700.12, 1450.0, 230.0, 0, 1341619767, 4457279, 1, true)
		DoScreenFadeIn(2000)
		Wait(30000)
		SetAmbientVoiceName(pilot, "BRAD")
		PlayAmbientSpeech1(pilot, "GET_OUT_OF_HERE", "SPEECH_PARAMS_FORCE_NORMAL")
		Wait(3000)
		TaskLeaveVehicle(Ped, Skydive, 64)
		Wait(10000)
		DeletePed(pilot)
		QBCore.Functions.DeleteVehicle(Skydive)
	end
end)


-- Event to ride with buddies.

RegisterNetEvent('randol_skydive:client:ridewithbuddy')
AddEventHandler('randol_skydive:client:ridewithbuddy', function()
	local friends = PlayerPedId()
	local friendsCoords = GetEntityCoords(friends)
	local vehicles = GetGamePool("CVehicle")

	local foundVehicle = nil

	for k, v in pairs(vehicles) do
		if v ~= 0 then
			local vehPos = GetEntityCoords(v)
			local dist = #(friendsCoords - vehPos)

			if GetEntityModel(v) == `mammatus` and dist < 20.0 then
				foundVehicle = v
				break
			end
		end
	end

	if foundVehicle == nil then QBCore.Functions.Notify("Nobody has paid for the Group flight yet!", 'error') return end
	local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(foundVehicle)

	for i=maxSeats - 1, 0, -1 do
		if IsVehicleSeatFree(foundVehicle, i) then
			freeSeat = i
			break
		end
	end
	SetPedIntoVehicle(friends, foundVehicle, freeSeat)
	GiveWeaponToPed(friends, GetHashKey("GADGET_PARACHUTE"), true)
end)

function DeletePilot()
    if DoesEntityExist(igpilot) then
        DeletePed(igpilot)
    end
end

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        DeletePilot()
	end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    DeletePilot()
end)