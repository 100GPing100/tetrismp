player = {
    x = 400,
    y = 300,
    speed = 300
}
local dir = { x = 0, y = 0 }

function player.update(dt)
    player.x = player.x + dir.x * player.speed * dt
    player.y = player.y + dir.y * player.speed * dt
end

function player.draw()
    love.graphics.print("Hello World", player.x, player.y)
end

function player.key(state, k)
    state = (state == true and 1 or -1)

    if k == 'w' then
        dir.y = dir.y - state
    elseif k == 's' then
        dir.y = dir.y + state
    elseif k == 'a' then
        dir.x = dir.x - state
    elseif k == 'd' then
        dir.x = dir.x + state
    end

    --[[
    if k == 'w' then
        dir.y = dir.y + 1
    elseif k == 's' then
        dir.y = dir.y - 1
    elseif k == 'a' then
        dir.x = dir.x + 1
    elseif k == 'd' then
        dir.x = dir.x - 1
    end--]]
end