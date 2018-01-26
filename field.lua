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
        falling_id = 0
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

    function self.draw(self)
        love.graphics.push()
        love.graphics.translate(self.offset.x, self.offset.y)

        for y = 0, FIELD_Y - 1 do
            for x = 0, FIELD_X - 1 do
                local i = self.blocks[y * FIELD_X + x]

                if i < 0 then
                    love.graphics.setColor(255, 0, 0, 255)
                elseif i == 0 then
                    love.graphics.setColor(255, 255, 255, 255)
                else
                    love.graphics.setColor(0, 255, 0, 255)
                end

                love.graphics.rectangle(i == 0 and 'line' or 'fill', x * self.size, y * self.size, self.size, self.size)
            end
        end

        if self.falling then
            love.graphics.setColor(255, 255, 255, 255)
            for c, pos in ipairs(self.falling) do
                love.graphics.rectangle('fill', pos.x * self.size, pos.y * self.size, self.size, self.size)
            end
        end

        love.graphics.pop()
    end

    function self.createpiece(self, i)
        self.falling_id = i

        if i == 1 then
            return {
                { x = 3, y = 0 }
            }
        end
    end

    function self.spawn(self, i)
        self.falling_id = i
        self.falling = {
            {x = 5, y = 0},
            {x = 6, y = 0},
            {x = 5, y = 1},
            {x = 6, y = 1}
        }
    end

    function self.update(self, dt)
        self.nextstep = self.nextstep - dt

        if self.nextstep <= 0 then
            self.nextstep = STEP_INTERVAL

            if self.falling == nil then
                self:spawn(1)
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
        end
    end

    function self.drop(self, alltheway)
        if not self.falling then
            return
        end

        if alltheway then
            while self.falling do
                self:drop(false)
            end
        else
            local stop_fall = false

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
            end
        end
    end

    return self
end

return Field
