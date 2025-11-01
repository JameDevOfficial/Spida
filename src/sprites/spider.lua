local spider = {}
spider.__index = spider

function spider.initSpriteAsset()
    spider._sharedSprite = love.graphics.newImage(Settings.spider.image)
end

function spider:render()
    if not self.sprite then return end
    love.graphics.setColor(self.color)
    local w, h = self.sprite:getDimensions()
    local xScale = (self.size.W / w) * self.scale.X
    local yScale = (self.size.H / h) * self.scale.Y
    love.graphics.draw(self.sprite, self.position.X, self.position.Y, 0, xScale, yScale, self.offset.X, self.offset.Y)
end

function spider:update(dt)
    self.position.X = self.position.X + self.velocity.X * dt
    self.position.Y = self.position.Y + self.velocity.Y * dt

    self.velocity.X = self.velocity.X * (self.damping ^ dt)
    self.velocity.Y = self.velocity.Y * (self.damping ^ dt)
    self.rotation = math.floor(self.rotation * (self.damping ^ dt) * 100 + 0.5) / 100

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

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.velocity.X = self.velocity.X - Settings.spider.speed * dt
        print("Moving left")
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.velocity.X = self.velocity.X + Settings.spider.speed * dt
        print("Moving right")
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        self.velocity.Y = self.velocity.Y + Settings.spider.speed * dt
        print("Moving down")
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        self.velocity.Y = self.velocity.Y - Settings.spider.speed * dt
        print("Moving up")
    end
    if love.keyboard.isDown("space") then
        self:saveLastLinePoint()
    end
end

function spider:new(opts)
    opts              = opts or {}
    local o           = setmetatable({}, self)
    o.scale           = opts.scale or { X = 1, Y = 1 }
    o.size            = opts.size or { W = 100, H = 100 }
    o.color           = opts.color or { 1, 1, 1, 1 }
    o.position        = opts.position or { X = 100, Y = 100 }
    o.velocity        = opts.velocity or { X = 0, Y = 0 }
    o.speed           = opts.speed or Settings.spider.speed
    o.damping         = opts.damping or 0.5
    o.rotation        = opts.rotation or 0
    o.sprite          = spider._sharedSprite
    o.offset          = opts.offset or { X = 0, Y = 0 }
    o.netPoints       = {}
    o.lastPoint       = { X = 0, Y = 0 }
    o.lastPointInLine = { X = 0, Y = 0 }
    return o
end

function spider:saveLastLinePoint()
    local n = #self.netPoints
    local p = { X = self.position.X, Y = self.position.Y }

    if n < 2 then
        table.insert(self.netPoints, p)
        return
    end

    local a = self.netPoints[n - 1]
    local b = self.netPoints[n]

    local cross = (b.X - a.X) * (p.Y - a.Y) - (b.Y - a.Y) * (p.X - a.X)
    local eps = 1e-3

    if math.abs(cross) <= eps then
        print("Replaced")
        self.netPoints[n] = p
    else
        table.insert(self.netPoints, p)
        print("New")
    end
end

function spider:renderNet()
    if #self.netPoints < 2 then
        return
    end
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(2)
    for i = 1, #self.netPoints - 1 do
        local p1, p2 = self.netPoints[i], self.netPoints[i+1]
        love.graphics.line(p1.X, p1.Y, p2.X, p2.Y)
    end
end

function spider:getActualPostion()
    return
        self.position.X - (self.offset.X * self.scale.X),
        self.position.Y - (self.offset.Y * self.scale.Y)
end

function spider:getScaledDimensions()
    return self.size.W * self.scale.X, self.size.H * self.scale.Y
end

return spider
