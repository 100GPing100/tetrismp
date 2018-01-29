local STEP_INTERVAL = 0.25
local FIELD_X = 10
local FIELD_Y = 22

local function Field(margin)
    local self = {
        offset = {x = 0, y = 0},
        blocks = {},
        size = 0,
        nextstep = STEP_INTERVAL,
        falling = nil,
        falling_id = 0,
        ghost = nil,
        hold = nil
    }

    -- create grid
    for i = 0, FIELD_Y * FIELD_X - 1 do
        self.blocks[i] = 0
    end

    -- setup sizes and field position
    local w = love.graphics.getWidth() - margin.left - margin.right
    local h = love.graphics.getHeight() - margin.top - margin.bottom

    local wsize = w / FIELD_X
    local hsize = h / FIELD_Y

    self.size = math.min(wsize, hsize)
    if self.size == wsize then
        self.offset.y = (h - self.size * FIELD_Y) / 2
    else
        self.offset.x = (w - self.size * FIELD_X) / 2
    end

    self.offset.y = self.offset.y + margin.top
    self.offset.x = self.offset.x + margin.left

    function self.setcolor(self, i, forghost)
        local alpha = forghost and 64 or 255
        
        if i == 1 then -- I
            love.graphics.setColor(255, 220, 0, alpha)
        elseif i == 2 then -- O
            love.graphics.setColor(57, 204, 204, alpha)
        elseif i == 3 then -- T
            love.graphics.setColor(177, 13, 201, alpha)
        elseif i == 4 then -- S
            love.graphics.setColor(46, 204, 64, alpha)
        elseif i == 5 then -- Z
            love.graphics.setColor(255, 65, 54, alpha)
        elseif i == 6 then -- J
            love.graphics.setColor(255, 133, 27, alpha)
        elseif i == 7 then -- L
            love.graphics.setColor(0, 116, 217, alpha)
        else
            -- empty field block
            love.graphics.setColor(255, 255, 255, alpha)
        end
    end

    function self.draw(self)
        love.graphics.push()
        love.graphics.translate(self.offset.x, self.offset.y)

        for y = 0, FIELD_Y - 1 do
            for x = 0, FIELD_X - 1 do
                local i = self.blocks[y * FIELD_X + x]

                self:setcolor(i, false)
                if i ~= 0 then
                    love.graphics.rectangle('fill', x * self.size, y * self.size, self.size, self.size)

                    self:setcolor(0, false)
                else
                    love.graphics.setColor(128, 128, 128, 255)
                end

                love.graphics.rectangle('line', x * self.size, y * self.size, self.size, self.size)
            end
        end

        if self.falling then
            for c, pos in ipairs(self.falling) do
                self:setcolor(self.falling_id, false)
                love.graphics.rectangle('fill', pos.x * self.size, pos.y * self.size, self.size, self.size)

                self:setcolor(0, false)
                love.graphics.rectangle('line', pos.x * self.size, pos.y * self.size, self.size, self.size)
            end
        end

        if self.ghost then
            for c, pos in ipairs(self.ghost) do
                self:setcolor(self.falling_id, true)
                love.graphics.rectangle('fill', pos.x * self.size, pos.y * self.size, self.size, self.size)

                self:setcolor(0, true)
                love.graphics.rectangle('line', pos.x * self.size, pos.y * self.size, self.size, self.size)
            end
        end

        love.graphics.pop()
    end

    function self.createpiece(self, i)
        if i == 1 then
            return { -- I
                { x = 3, y = 1 },
                { x = 4, y = 1 },
                { x = 5, y = 1 },
                { x = 6, y = 1 }
            }
        elseif i == 2 then
            return { -- O
                { x = 4, y = 0 },
                { x = 5, y = 0 },
                { x = 4, y = 1 },
                { x = 5, y = 1 }
            }
        elseif i == 3 then
            return { -- T
                { x = 4, y = 0 },
                { x = 3, y = 1 },
                { x = 4, y = 1 },
                { x = 5, y = 1 }
            }
        elseif i == 4 then
            return { -- S
                { x = 4, y = 0 },
                { x = 5, y = 0 },
                { x = 3, y = 1 },
                { x = 4, y = 1 }
            }
        elseif i == 5 then
            return { -- Z
                { x = 3, y = 0 },
                { x = 4, y = 0 },
                { x = 4, y = 1 },
                { x = 5, y = 1 }
            }
        elseif i == 6 then
            return { -- J
                { x = 3, y = 0 },
                { x = 3, y = 1 },
                { x = 4, y = 1 },
                { x = 5, y = 1 }
            }
        elseif i == 7 then
            return { -- L
                { x = 5, y = 0 },
                { x = 3, y = 1 },
                { x = 4, y = 1 },
                { x = 5, y = 1 }
            }
        else
            error("Unknown piece id")
        end
    end

    function self.spawn(self, i)
        self.falling_id = i
        self.falling = self:createpiece(i)
        self.ghost = self:getghost()
    end

    function self.update(self, dt)
        self.nextstep = self.nextstep - dt

        if self.nextstep <= 0 then
            self.nextstep = STEP_INTERVAL

            if self.falling == nil then
                self:spawn(math.random(1, 7))
            else
                local stop_fall = false

                for c, pos in ipairs(self.falling) do
                    if pos.y == FIELD_Y - 1 then
                        -- at bottom stay
                        stop_fall = true
                        break
                    elseif self.blocks[(pos.y + 1) * FIELD_X + pos.x] ~= 0 then
                        -- check next block: not empty, stay
                        stop_fall = true
                        break
                    end

                    -- it's empty, might fall, check next block
                end

                if stop_fall then
                    self:stay()
                else
                    for c, pos in ipairs(self.falling) do
                        pos.y = pos.y + 1
                    end
                end
            end -- </if has falling>
        end -- </if next step>
    end -- </self.update>

    function self.stay(self)
        if not self.falling then
            return
        end

        for c, pos in ipairs(self.falling) do
            self.blocks[pos.y * FIELD_X + pos.x] = self.falling_id
        end

        self.falling_id = nil
        self.falling = nil
    end

    function self.move(self, x)
        if not self.falling then
            return
        end

        local can_move = true

        for c, pos in ipairs(self.falling) do
            -- check boundaries for move left (0) or right(FIELD_X - 1)
            if pos.x == (x < 0 and 0 or FIELD_X - 1) then
                can_move = false
                break
            elseif self.blocks[pos.y * FIELD_X + pos.x + x] ~= 0 then
                -- check side block: not empty, stay
                can_move = false
                break
            end

            -- it's empty, might move, check next block
        end

        if can_move then
            for c, pos in ipairs(self.falling) do
                pos.x = pos.x + x
            end

            self.ghost = self:getghost()
        end
    end

    function self.getghost(self)
        if not self.falling then
            return nil
        end

        local falling = {}
        for c, pos in ipairs(self.falling) do
            falling[c] = { x = pos.x, y = pos.y }
        end

        local stop_fall = false
        while not stop_fall do
            for c, pos in ipairs(falling) do
                -- check bottom
                if pos.y == FIELD_Y - 1 then
                    stop_fall = true
                    break
                elseif self.blocks[(pos.y + 1) * FIELD_X + pos.x] ~= 0 then
                    -- check bottom block: not empty, stay
                    stop_fall = true
                    break
                end

                -- it's empty, might move, check next block
            end

            if not stop_fall then
                for c, pos in ipairs(falling) do
                    pos.y = pos.y + 1
                end
            end
        end

        return falling
    end

    function self.harddrop(self)
        if not self.falling then
            return
        end

        self.falling = self:getghost()
        self:stay()
    end

    function self.drop(self)
        if not self.falling then
            return
        end

        -- sanity check
        if not self.ghost then
            self.ghost = self:getghost()
        end

        if self.falling[1].y == self.ghost[1].y then
            self:stay()
        else
            for c, pos in ipairs(self.falling) do
                pos.y = pos.y + 1
            end
        end

        --[[local stop_fall = false

        for c, pos in ipairs(self.falling) do
            -- check bottom
            if pos.y == FIELD_Y - 1 then
                stop_fall = true
                break
            elseif self.blocks[(pos.y + 1) * FIELD_X + pos.x] ~= 0 then
                -- check bottom block: not empty, stay
                stop_fall = true
                break
            end

            -- it's empty, might move, check next block
        end

        if stop_fall then
            self:stay()
        else
            for c, pos in ipairs(self.falling) do
                pos.y = pos.y + 1
            end
        end--]]
    end

    return self
end

return Field
