local spider = {}

function spider.initSpriteAsset()
    spider._sharedSprite = love.graphics.newImage(Settings.spider.image)
end

function spider:render()
    love.graphics.setColor(1, 1, 1)
    local w, h = self.sprite:getDimensions()
    local xScale = (self.size.W / w) * self.scale.X
    local yScale = (self.size.H / h) * self.scale.Y
    love.graphics.draw(self.sprite, self.position.X, self.position.Y, 0, xScale, yScale, self.offset.X, self.offset.Y)
end

spider.update = function(dt)
    spider.position.X = spider.position.X + spider.velocity.X * dt
    spider.position.Y = spider.position.Y + spider.velocity.Y * dt

    spider.velocity.X = spider.velocity.X * spider.damping ^ dt
    spider.velocity.Y = spider.velocity.Y * spider.damping ^ dt
    spider.rotation = round(spider.rotation * spider.damping ^ dt, 2)

    local w, h = spider.getScaledDimensions()

    if spider.position.X < 0 then
        spider.position.X = 0
        spider.velocity.X = -spider.velocity.X
    end
    if spider.position.Y < 0 then
        spider.position.Y = 0
        spider.velocity.Y = -spider.velocity.Y
    end
    if spider.position.X + w > Screen.X then
        spider.position.X = Screen.X - w
        spider.velocity.X = -spider.velocity.X
    end
    if spider.position.Y + h > Screen.Y then
        spider.position.Y = Screen.Y - h
        spider.velocity.Y = -spider.velocity.Y
    end

    if Settings.verticalMovement then
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            spider.velocity.Y = spider.velocity.Y + Settings.spider.speed * dt
        end
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            spider.velocity.Y = spider.velocity.Y - Settings.spider.speed * dt
        end
    end
end

function spider:new(opts)
    opts       = opts or {}
    local o    = setmetatable({}, self)
    o.scale    = opts.scale or { X = 1, Y = 1 }
    o.size     = opts.size or { W = 0, H = 0 }
    o.color    = opts.color or { 0.2, 1, 0.2, 1 }
    o.position = opts.position or { X = 100, Y = 100 }
    o.velocity = opts.velocity or { X = 0, Y = 0}
    o.speed    = opts.speed or Settings.obstacles.speed
    o.offset = opts.offset or { X = 0, Y = 0 }
end

function spider:getActualPostion()
    return
        self.position.X - (self.offset.X * self.scale.X),
        self.position.Y - (self.offset.Y * self.scale.Y)
end

function spider:getScaledDimensions()
    local w, h = self.sprite:getDimensions()
    return w * self.scale.X, h * self.scale.Y
end
return spider