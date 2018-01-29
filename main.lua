local Field = require'field'

local field = nil
local aa = nil

function love.load()
    field = Field({
        top = 32,
        left = -400,
        bottom = 32,
        right = 0
    })

    aa = Field({
        top = 32,
        left = 400,
        bottom = 32,
        right = 0
    })
end

function love.update(dt)
    --player.update(dt)
    field:update(dt)
    aa:update(dt)
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)
    
    field:draw()
    aa:draw()
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
        return
    end

    if k == 'left' then
        field:move(-1)
    elseif k == 'right' then
        field:move(1)
    elseif k == 'down' then
        field:drop()
    elseif k == 'up' then
        field:harddrop()
    end

    --player.key(true, k)
end

function love.joystickpressed(joystick,button)
    print(joystick, button)
    if button == 5 then
        field:harddrop()
    elseif button == 6 then
        field:move(1)
    elseif button == 7 then
        field:drop()
    elseif button == 8 then
        field:move(-1)
    end
 end

function love.keyreleased(k)
    --player.key(false, k)
end