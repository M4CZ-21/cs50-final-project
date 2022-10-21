function spend(player, resource, amount)
    global[player][resource] = global[player][resource] - amount
end

function damage(player, damage)
    if global[turn.player.all[turn.player.current]].conditions.freezing and global[turn.player.all[turn.player.current]].conditions.freezing >= 1 then
        global[turn.player.all[turn.player.current]].conditions.freezing = global[turn.player.all[turn.player.current]].conditions.freezing - 1
    else
        global[player]["hp"] = global[player]["hp"] - damage
    end
end

function recover(player, resource, amount)
    if global[player][resource] + amount > global[player]["max_" .. resource] then
        global[player][resource] = global[player]["max_" .. resource]
    else 
        global[player][resource] = global[player][resource] + amount
    end
end

function draw(player, amount)
    table.insert(elements[player].hand, elements[player].deck[1])
    table.remove(elements[player].deck, 1)
end

function apply(player, condition, amount)
    local initial = global[player].conditions[condition] or 0
    global[player].conditions[condition] = initial + amount
end