local Server = lib.require('sv_config')

local function busyTimer(num)
    local index = num
    Server.Locations[index].busy = true
    SetTimeout(Server.Timeout * 60000, function()
        Server.Locations[index].busy = false
    end)
end

lib.callback.register('randol_skydiving:server:viewLocs', function(source)
    return Server.Locations
end)

lib.callback.register('randol_skydiving:server:attemptStart', function(source, index)
    if Server.Locations[index].busy then
        DoNotification(source, 'Someone has taken this route recently.', 'error')
        return false 
    end

    local src = source
    local player = GetPlayer(src)
    local price = Server.Locations[index].price

    if not RemovePlayerMoney(player, price, 'bank') then
        DoNotification(src, ('You need $%s in the bank to pay for this.'):format(price), 'error')
        return false 
    end

    DoNotification(src, ('You paid $%s for the skydive.'):format(price), 'success')
    busyTimer(index)
    return true
end)