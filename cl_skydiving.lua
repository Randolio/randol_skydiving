local Config = lib.require('config')
local START_PED, HELI_CAM, START_ZONE, HELI, PILOT
local isWaiting = false

local function targetLocalEntity(entity, options, distance)
    if GetResourceState('ox_target') == 'started' then
        for _, option in ipairs(options) do
            option.distance = distance
            option.onSelect = option.action
            option.action = nil
        end
        exports.ox_target:addLocalEntity(entity, options)
    else
        exports['qb-target']:AddTargetEntity(entity, { options = options, distance = distance })
    end
end

local blip = AddBlipForCoord(Config.Ped.coords.xyz)
SetBlipSprite(blip, 94)
SetBlipColour(blip, 2)
SetBlipScale(blip, 0.65)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName('STRING')
AddTextComponentString('Skydiving')
EndTextCommandSetBlipName(blip)

local function deleteChute(chute)
    if DoesEntityExist(chute) then
        SetEntityAsMissionEntity(chute, false, true)
        DeleteEntity(chute)
    end
end

local function convertHex(hex)
    local hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0

    return r, g, b
end

local function getChuteColors()
    local opts = {}
    for i = 1, #Config.ParachuteColors do
        opts[#opts + 1] = {
            value = Config.ParachuteColors[i].value,
            label = Config.ParachuteColors[i].label
        }
    end
    return opts
end

local function startJump(coords, style, trail)
    DoScreenFadeOut(100)
    lib.requestModel(Config.HeliModel)
    lib.requestModel(Config.PilotModel)
    Wait(500)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z+10.0)
    FreezeEntityPosition(cache.ped, true)
    HELI = CreateVehicle(Config.HeliModel, coords, false, false)
    PILOT = CreatePedInsideVehicle(HELI, 6, Config.PilotModel, -1, false, false)
    SetVehicleEngineOn(HELI, true, true)
    Wait(100)
    TaskHeliMission(PILOT, HELI, 0, 0, coords.xyz, 4, 0.0, -1.0, -1.0, -1, -1, -1.0, 0)
    SetVehicleEngineOn(HELI, true, true)
    SetHeliBladesFullSpeed(HELI)
    SetVehicleEngineOn(HELI, true, true, false)
    ActivatePhysics(HELI)
    Wait(500)
    FreezeEntityPosition(cache.ped, false)
    DoScreenFadeIn(100)

    HELI_CAM = CreateCamera('DEFAULT_SCRIPTED_CAMERA', false)
    AttachCamToEntity(HELI_CAM, cache.ped, 0.45, -1.15, 0.95, true)
    PointCamAtEntity(HELI_CAM, cache.ped, -0.6, 1.9, -0.6, true)
    SetCamFov(HELI_CAM, 29.0)
    SetGameplayCamRelativeHeading(0.0)
    SetGameplayCamRelativePitch(0.0, 1.0)
    SetCamActive(HELI_CAM, true)
    RenderScriptCams(true, false, 1000, true, false, 0)
    ShakeCam(HELI_CAM, 'HAND_SHAKE', 1.0)

    lib.requestAnimDict('oddjobs@basejump@')
    lib.requestModel(`p_parachute_s`)

    local chute = CreateParachuteBagObject(cache.ped, true, true)
    local r, g, b = convertHex(trail)

    SetPlayerParachuteTintIndex(cache.playerId, 0)
    SetPlayerParachutePackTintIndex(cache.playerId, 0)
    ClearPlayerParachutePackModelOverride(cache.playerId)
    
    SetPlayerParachuteTintIndex(cache.playerId, style)
    SetPlayerParachuteModelOverride(cache.playerId, `lts_p_para_pilot2_sp_s`)
    SetPlayerCanLeaveParachuteSmokeTrail(cache.playerId, true)
    SetPlayerParachuteSmokeTrailColor(cache.playerId, r, g, b)

    local scene = CreateSynchronizedScene(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2)
    AttachSynchronizedSceneToEntity(scene, HELI, GetEntityBoneIndexByName(HELI, 'Chassis'))
    TaskSynchronizedScene(cache.ped, scene, 'oddjobs@basejump@', 'Heli_door_loop', 4.0, -4.0, 65, 0, 1000.0, 0)
    SetSynchronizedSceneLooped(scene, true)

    isWaiting = true
    while not RequestScriptAudioBank('DLC_MPSUM2/Junk_Energy_Skydive', false, -1) do Wait(100) end

    lib.showTextUI('PRESS **SPACEBAR** TO JUMP', {position = 'left-center', icon = 'hand'})

    local startTime = GetGameTimer()
    while isWaiting do
        if IsControlJustPressed(0, 22) then
            PlaySoundFrontend(-1, 'Countdown_Go', 'Junk_Energy_Skydive_Soundset', true)
            isWaiting = false
        end

        if GetGameTimer() - startTime >= 30000 then
            PlaySoundFrontend(-1, 'Countdown_Go', 'Junk_Energy_Skydive_Soundset', true)
            isWaiting = false
        end
        Wait(0)
    end

    ReleaseScriptAudioBank()
    lib.hideTextUI()
    DetachSynchronizedScene(scene)
    
    local scene2 = CreateSynchronizedScene(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2)
    AttachSynchronizedSceneToEntity(scene2, HELI, GetEntityBoneIndexByName(HELI, 'Chassis'))
    TaskSynchronizedScene(cache.ped, scene2, 'oddjobs@basejump@', 'Heli_jump', 4.0, -4.0, 65, 0, 1000.0, 0)
    SetSynchronizedScenePhase(scene2, 0.6)
    while GetSynchronizedScenePhase(scene2) < 0.92 do Wait(0) end

    SetCamActive(HELI_CAM, false)
    DestroyCam(HELI_CAM, true)
    RenderScriptCams(false, false, 1000, true, true)
    TaskForceMotionState(cache.ped, `MotionState_Parachuting`, false)
    TaskParachute(cache.ped, true, false)
    deleteChute(chute)

    Wait(3000)
    DetachSynchronizedScene(scene2)
    DeleteEntity(HELI)
    DeleteEntity(PILOT)
    HELI, PILOT = nil
    
    SetModelAsNoLongerNeeded(Config.HeliModel)
    SetModelAsNoLongerNeeded(Config.PilotModel)
    SetModelAsNoLongerNeeded(`p_parachute_s`)
    RemoveAnimDict('oddjobs@basejump@')
end

local function getStreetandZone(coords)
    local currentStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    return currentStreetName
end

local function viewJumps()
    local locations = lib.callback.await('randol_skydiving:server:viewLocs', false)
    local opts = {}

    for index, data in pairs(locations) do
        opts[#opts + 1] = {
            title = getStreetandZone(data.coords.xyz),
            disabled = data.busy,
            description = data.busy and 'Unavailable right now' or ('Available: $%s'):format(data.price),
            icon = 'fa-solid fa-location-dot',
            onSelect = function()
                local opts = getChuteColors()
                local response = lib.inputDialog('Select Parachute', {
                    { type = 'select', label = 'Parachute Styles', required = true, icon = 'fa-solid fa-fill', options = opts},
                    { type = 'color', label = 'Smoke Trail', required = true, default = '#eb4034'},
                })
                if not response then return end
                local success = lib.callback.await('randol_skydiving:server:attemptStart', false, index)
                if success then
                    startJump(data.coords, response[1], response[2])
                end
            end,
        }
    end

    lib.registerContext({ id = 'jump_locs', title = 'Sky Diving Locations', options = opts })
    lib.showContext('jump_locs')
end

local function removePed()
    if not DoesEntityExist(START_PED) then return end

    if Config.UseTarget then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:removeLocalEntity(START_PED, 'View Locations')
        else
            exports['qb-target']:RemoveTargetEntity(START_PED, 'View Locations')
        end
    else
        exports.interact:RemoveLocalEntityInteraction(START_PED, 'skydive_guy')
    end

    DeleteEntity(START_PED)
    START_PED = nil
end

local function initPed()
    local model = Config.Ped.model
    lib.requestModel(model)

    START_PED = CreatePed(4, model, Config.Ped.coords, false, false)
    SetEntityAsMissionEntity(START_PED, true, true)
    SetBlockingOfNonTemporaryEvents(START_PED, true)
    SetEntityInvincible(START_PED, true)
    FreezeEntityPosition(START_PED, true)
    TaskStartScenarioInPlace(START_PED, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    SetModelAsNoLongerNeeded(model)

    if Config.UseTarget then
        targetLocalEntity(START_PED, {
            {
                icon = 'fa-solid fa-parachute-box',
                label = 'View Locations',
                action = viewJumps,
            },
        }, 1.5)
    else
        exports.interact:AddLocalEntityInteraction({
            entity = START_PED,
            name = 'skydive_guy',
            id = 'skydive_guy',
            distance = 5.0,
            interactDst = 1.5,
            ignoreLos = true,
            offset = vec3(0.0, 0.0, 0.0),
            options = {
                {
                    label = 'View Locations',
                    action = function()
                        viewJumps()
                    end,
                },
            }
        })
    end
end

function removePedSpawn()
    removePed()
    if START_ZONE then START_ZONE:remove() START_ZONE = nil end
end

function createPedSpawn()
    START_ZONE = lib.points.new({
        coords = Config.Ped.coords.xyz,
        distance = 50,
        pedData = data,
        onEnter = initPed,
        onExit = removePed,
    })
end

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or not hasPlyLoaded() then return end
    createPedSpawn()
end)

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() ~= resourceName then return end
    removePedSpawn()
end)
