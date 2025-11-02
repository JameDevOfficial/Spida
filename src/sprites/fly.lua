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

function fly.initSpriteAsset()
    fly._sharedSprite = love.graphics.newImage(Settings.fly.image)
end

function fly:render()
    if not self.sprite then return end
    love.graphics.setColor(self.color)
    local w, h = self.sprite:getDimensions()
    local xScale = (self.size.W / w) * self.scale.X
    local yScale = (self.size.H / h) * self.scale.Y
    love.graphics.draw(self.sprite, self.position.X, self.position.Y, self.rotation, xScale, yScale, self.offset.X,
        self.offset.Y)
end

function fly:update(dt)
    self.position.X = self.position.X + self.velocity.X * dt
    self.position.Y = self.position.Y + self.velocity.Y * dt

    self.velocity.X = self.velocity.X * (self.damping ^ dt)
    self.velocity.Y = self.velocity.Y * (self.damping ^ dt)

    local speed = math.sqrt(self.velocity.X * self.velocity.X + self.velocity.Y * self.velocity.Y)
    if speed > 10 then
        self.rotation = fly._atan2(self.velocity.Y, self.velocity.X) - math.pi / 2
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
        { X = Screen.centerX, Y = Screen.centerY }
    o.velocity        = opts.velocity or { X = 0, Y = 0 }
    o.speed           = opts.speed or Settings.spider.speed
    o.damping         = opts.damping or 0.5
    o.rotation        = opts.rotation or 0
    o.sprite          = fly._sharedSprite
    o.offset          = opts.offset or { X = 0, Y = 0 }
    o.netPoints       = {}
    o.lastPoint       = { X = 0, Y = 0 }
    o.lastPointInLine = { X = 0, Y = 0 }
    o.scale           = { X = 1, Y = 1 }
    return o
end

function fly:getActualPostion()
    return
        self.position.X - (self.offset.X * self.scale.X),
        self.position.Y - (self.offset.Y * self.scale.Y)
end

function fly:getScaledDimensions()
    local spriteW, spriteH = Spider._sharedSprite:getDimensions()
    return spriteW * self.scale.X, spriteH * self.scale.Y
end

return fly
