local spider = {}
spider.__index = spider

function spider._atan2(y, x)
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 then
        local angle = math.atan(y / x)
        return y >= 0 and angle + math.pi or angle - math.pi
    elseif y > 0 then
        return math.pi / 2
    elseif y < 0 then
        return -math.pi / 2
    else
        return 0
    end
end

function spider.aabbIntersect(x1, y1, w1, h1, x2, y2, w2, h2, tolerance)
    tolerance = tolerance or 0

    local x1T = x1 + tolerance
    local y1T = y1 + tolerance
    local w1T = w1 - (2 * tolerance)
    local h1T = h1 - (2 * tolerance)

    return x1T < x2 + w2 and
        x2 < x1T + w1T and
        y1T < y2 + h2 and
        y2 < y1T + h1T
end

function spider:checkCollisons(dt, o)
    if not o or not o.position then
        return false
    end
    local bx, by, bw, bh = self:getAABB()
    local ox, oy, ow, oh = o:getAABB()
    if spider.aabbIntersect(bx, by, bw, bh, ox, oy, ow, oh, Settings.spider.tolerance) then
        print("collision with fly", o)
        return true
    end
    return false
end

function spider.initSpriteAsset()
    spider._sharedSprite = love.graphics.newImage(Settings.spider.image)
end

function spider:render()
    if not self.sprite then return end
    love.graphics.setColor(self.color)
    local w, h = self.sprite:getDimensions()
    local xScale = (self.size.W / w) * self.scale.X
    local yScale = (self.size.H / h) * self.scale.Y
    love.graphics.draw(self.sprite, self.position.X, self.position.Y, self.rotation, xScale, yScale, self.offset.X,
        self.offset.Y)
end

function spider:update(dt)
    self.position.X = self.position.X + self.velocity.X * dt
    self.position.Y = self.position.Y + self.velocity.Y * dt

    self.velocity.X = self.velocity.X * (self.damping ^ dt)
    self.velocity.Y = self.velocity.Y * (self.damping ^ dt)

    if self.hitCooldown <= 0 then
        for i = #Flies, 1, -1 do
            if Flies[i] then
                if self:checkCollisons(dt, Flies[i]) == true and Flies[i].isCaught == false then
                    Player.health = Player.health - Settings.fly.damage
                    self.hitCooldown = Settings.player.hitCooldown
                end
            end
        end
    else
        self.hitCooldown = self.hitCooldown - dt
    end

    local speed = math.sqrt(self.velocity.X * self.velocity.X + self.velocity.Y * self.velocity.Y)
    if speed > 10 then
        self.rotation = spider._atan2(self.velocity.Y, self.velocity.X) - math.pi / 2
    end

    local w, h = self:getScaledDimensions()
    local ax, ay = self:getActualPostion()

    if ax < 0 then
        self.position.X = self.offset.X * self.scale.X
        self.velocity.X = -self.velocity.X
    end
    if ay < 0 then
        self.position.Y = self.offset.Y * self.scale.Y
        self.velocity.Y = -self.velocity.Y
    end
    if ax + w > Screen.X then
        self.position.X = Screen.X - w + (self.offset.X * self.scale.X)
        self.velocity.X = -self.velocity.X
    end
    if ay + h > Screen.Y then
        self.position.Y = Screen.Y - h + (self.offset.Y * self.scale.Y)
        self.velocity.Y = -self.velocity.Y
    end

    if not self.isPlayer then return end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.velocity.X = self.velocity.X - Settings.spider.speed * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.velocity.X = self.velocity.X + Settings.spider.speed * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        self.velocity.Y = self.velocity.Y + Settings.spider.speed * dt
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        self.velocity.Y = self.velocity.Y - Settings.spider.speed * dt
    end
    if love.keyboard.isDown("space") then
        self:saveLastLinePoint()
    end

    local cTime = love.timer.getTime()
    if #self.netPoints < 2 then return end
    if -(self.netPoints[1].sTime - cTime) > Settings.spider.maxTTL then
        table.remove(self.netPoints, 1)
    end
end

function spider:new(opts)
    opts              = opts or {}
    local o           = setmetatable({}, self)
    o.isPlayer        = opts.isPlayer or false
    o.size            = opts.size or { W = spider._sharedSprite:getWidth(), H = spider._sharedSprite:getHeight() }
    o.color           = opts.color or { 1, 1, 1, 1 }
    o.position        = opts.position or
        { X = Screen.centerX, Y = Screen.centerY }
    o.velocity        = opts.velocity or { X = 0, Y = 0 }
    o.speed           = opts.speed or Settings.spider.speed
    o.damping         = opts.damping or 0.5
    o.rotation        = opts.rotation or 0
    o.sprite          = spider._sharedSprite
    o.offset          = opts.offset or { X = 0, Y = 0 }
    o.netPoints       = {}
    o.lastPoint       = { X = 0, Y = 0 }
    o.lastPointInLine = { X = 0, Y = 0 }
    o.scale           = { X = 1, Y = 1 }
    o.hitCooldown     = 0
    return o
end

function spider:saveLastLinePoint(newLine)
    if newLine == nil then newLine = false end
    local n = #self.netPoints
    local x, y = self:getActualPostion()
    local p = { X = x + self.size.W / 2, Y = y + self.size.H / 2, newNet = newLine, sTime = love.timer.getTime() }

    if n < 2 then
        table.insert(self.netPoints, p)
        return
    end

    local a = self.netPoints[n - 1]
    local b = self.netPoints[n]

    local cross = (b.X - a.X) * (p.Y - a.Y) - (b.Y - a.Y) * (p.X - a.X)

    if math.abs(cross) <= Settings.EPSILON then
        self.netPoints[n] = p
    else
        table.insert(self.netPoints, p)
        if #self.netPoints > Settings.spider.maxNetPoints then
            table.remove(self.netPoints, 1)
        end
    end
end

function spider:renderNet()
    if #self.netPoints < 2 then
        return
    end
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(2)
    for i = 1, #self.netPoints - 1 do
        local p1, p2 = self.netPoints[i], self.netPoints[i + 1]
        if p1.newNet == false then
            love.graphics.line(p1.X, p1.Y, p2.X, p2.Y)
        end
    end
end

function spider:getActualPostion()
    return
        self.position.X - (self.offset.X * self.scale.X),
        self.position.Y - (self.offset.Y * self.scale.Y)
end

function spider:getScaledDimensions()
    local spriteW, spriteH = Spider._sharedSprite:getDimensions()
    return spriteW, spriteH
end

function spider:getAABB()
    local w, h = self:getScaledDimensions()
    return self.position.X - w / 2, self.position.Y - h / 2, w, h
end

return spider
