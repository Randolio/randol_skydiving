if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function RemovePlayerMoney(xPlayer, amount, moneyType)
    local account = (moneyType == 'cash' and 'money') or moneyType

    if xPlayer.getAccount(account).money >= amount then
        xPlayer.removeAccountMoney(account, amount, "skydive")
        return true
    end

    return false
end
