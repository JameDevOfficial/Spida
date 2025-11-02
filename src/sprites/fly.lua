local fly = {}
fly.__index = fly

function fly._atan2(y, x)
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

function fly:checkNetCollision()
    local playerSpider = Spiders[Player.spiderIndex]
    if #playerSpider.netPoints < 2 then
        return false
    end
    local fX, fY = self:getActualPostion()
    local fW, fH = self:getScaledDimensions()
    local cx = fX + fW / 2
    local cy = fY + fH / 2
    local flyRadius = math.min(fW, fH) / 2.5 -- .5 for some tollerance

    for i = 1, #playerSpider.netPoints - 1 do
        local p1 = playerSpider.netPoints[i]
        local p2 = playerSpider.netPoints[i + 1]

        if p1.newNet == false then
            local distance = fly._pointToLineDistance(cx, cy, p1.X, p1.Y, p2.X, p2.Y)
            if distance < flyRadius then
                return true, i
            end
        end
    end

    return false
end

function fly._pointToLineDistance(px, py, x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local l2 = dx * dx + dy * dy

    if l2 == 0 then
        return math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1))
    end

    local t = ((px - x1) * dx + (py - y1) * dy) / l2
    t = math.max(0, math.min(1, t))
    local closestX = x1 + t * dx
    local closestY = y1 + t * dy

    return math.sqrt((px - closestX) * (px - closestX) + (py - closestY) * (py - closestY))
end

fly.spawnDelay = 0
function fly.spawnRandom(dt)
    fly.spawnDelay = fly.spawnDelay + dt
    if fly.spawnDelay < 1 then
        return
    end

    local rand = math.random(1, 100)
    fly.spawnDelay = 0
    if rand > Settings.fly.spawnChance then
        return
    end

    local spriteW, spriteH = Fly._sharedSprite:getDimensions()
    table.insert(Flies, Fly:new({ offset = { X = spriteW / 2, Y = spriteH / 2 } }))
end

function fly.initSpriteAsset()
    fly._sharedSprite = love.graphics.newImage(Settings.fly.image)
end

function fly:render()
    if not self.sprite then return end
    love.graphics.setColor(self.color)
    local w, h = self.sprite:getDimensions()
    local flipScale = self.velocity.X < 0 and -1 or 1

    local xScale = (self.size.W / w) * self.scale.X * flipScale
    local yScale = (self.size.H / h) * self.scale.Y
    love.graphics.draw(self.sprite, self.position.X, self.position.Y, self.rotation, xScale, yScale, self.offset.X,
        self.offset.Y)
end

function fly:crawl(dt)
    local playerSpider = Spiders[Player.spiderIndex]
    local sX, sY = playerSpider:getActualPostion()

    local fX, fY = self:getActualPostion()
    local dX = sX - fX
    local dY = sY - fY
    local dist = math.sqrt(dX * dX + dY * dY)

    if dist > 20 then
        local dirX = dX / dist
        local dirY = dY / dist
        self.velocity.X = self.velocity.X + dirX * Settings.fly.speed * dt
        self.velocity.Y = self.velocity.Y + dirY * Settings.fly.speed * dt
    end
end

function fly:update(dt)
    self.position.X = self.position.X + self.velocity.X * dt
    self.position.Y = self.position.Y + self.velocity.Y * dt

    self.velocity.X = self.velocity.X * (self.damping ^ dt)
    self.velocity.Y = self.velocity.Y * (self.damping ^ dt)
    self:crawl(dt)

    local caught, segmentIndex = self:checkNetCollision()
    if caught then
        self.isCaught = true
        self.velocity.X = 0
        self.velocity.Y = 0
        self.caughtTimer = self.caughtTimer + dt
        if self.caughtTimer > Settings.fly.timeToDie then
            Player.killedFlies = Player.killedFlies + 1
            for i, f in ipairs(Flies) do
                if f == self then
                    table.remove(Flies, i)
                    break
                end
            end
        end
    else
        self.caughtTimer = 0
    end

    local speed = math.sqrt(self.velocity.X * self.velocity.X + self.velocity.Y * self.velocity.Y)
    if speed > 10 then
        local angle = fly._atan2(self.velocity.Y, self.velocity.X) - math.pi / 2

        while angle > math.pi do angle = angle - 2 * math.pi end
        while angle < -math.pi do angle = angle + 2 * math.pi end

        if angle > math.pi / 2 then
            angle = math.pi - angle
        elseif angle < -math.pi / 2 then
            angle = -math.pi - angle
        end

        local maxTilt = math.pi / 18
        if angle > maxTilt then
            angle = maxTilt
        elseif angle < -maxTilt then
            angle = -maxTilt
        end

        self.rotation = angle
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
end

function fly:new(opts)
    opts              = opts or {}
    local o           = setmetatable({}, self)
    o.isPlayer        = opts.isPlayer or false
    o.size            = opts.size or { W = fly._sharedSprite:getWidth(), H = fly._sharedSprite:getHeight() }
    o.color           = opts.color or { 1, 1, 1, 1 }
    o.position        = opts.position or
        { X = 0, Y = 0 }
    o.velocity        = opts.velocity or { X = 0, Y = 0 }
    o.speed           = opts.speed or Settings.fly.speed
    o.damping         = opts.damping or 0.5
    o.rotation        = opts.rotation or 0
    o.sprite          = fly._sharedSprite
    o.offset          = opts.offset or { X = 0, Y = 0 }
    o.netPoints       = {}
    o.lastPoint       = { X = 0, Y = 0 }
    o.lastPointInLine = { X = 0, Y = 0 }
    o.scale           = { X = 1, Y = 1 }
    o.caughtTimer     = 0
    o.isCaught        = false
    return o
end

function fly:getActualPostion()
    return
        self.position.X - (self.offset.X * self.scale.X),
        self.position.Y - (self.offset.Y * self.scale.Y)
end

function fly:getScaledDimensions()
    local spriteW, spriteH = Fly._sharedSprite:getDimensions()
    return spriteW, spriteH
end

function fly:getAABB()
    local w, h = self:getScaledDimensions()
    return self.position.X - w / 2, self.position.Y - h / 2, w, h
end

return fly
