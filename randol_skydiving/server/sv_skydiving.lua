local QBCore = exports['qb-core']:GetCoreObject()

local flightinprogress = false

function flightCooldown()
    SetTimeout(300000, function() -- 300000 = 5 minute cooldown. 
        flightinprogress = false
    end)
end


RegisterServerEvent('randol_skydive:flightcooldown', function()
    flightinprogress = true
    flightCooldown()
end)

RegisterServerEvent("randol_skydive:server:payforgroup")
AddEventHandler("randol_skydive:server:payforgroup", function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local groupfee = Config.GroupFee
    local balance = Player.Functions.GetMoney('bank')

    if not flightinprogress then
        if balance >= groupfee then
            Player.Functions.RemoveMoney("bank", groupfee, "skydive")
            TriggerClientEvent('QBCore:Notify', source, " You paid for a group sky dive!", 'success')
            TriggerClientEvent('randol_skydive:client:skydivetime', source)
        else
            TriggerClientEvent('QBCore:Notify', source, " You don't have enough money in the bank.", 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Flight already in progress.", 'error')
    end
end)

RegisterServerEvent("randol_skydive:server:solojump")
AddEventHandler("randol_skydive:server:solojump", function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local solofee = Config.SoloFee
    local balance = Player.Functions.GetMoney('bank')

    if not flightinprogress then

        if balance >= solofee then
            TriggerClientEvent('randol_skydive:client:skydivesolo', source)
            Player.Functions.RemoveMoney("bank", solofee, "skydive-solo")
            TriggerClientEvent('QBCore:Notify', source, " You paid for a solo sky dive!", 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, " You don't have enough money in the bank.", 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Flight already in progress.", 'error')
    end
end)