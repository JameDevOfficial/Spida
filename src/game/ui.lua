local M = {}

M.backgroundImage = love.graphics.newImage(Settings.backgroundImage)
M.backgroundImage:setFilter("nearest", "nearest") -- for sharp rendering and not blurry

local drawBackground = function ()
    local bgW, bgH = M.backgroundImage:getDimensions()
    local screenW, screenH = love.graphics.getDimensions()
    local scale = math.max(screenW / bgW, screenH / bgH)
    local offsetX = math.floor((screenW - bgW * scale) * 0.5 + 0.5)
    local offsetY = math.floor((screenH - bgH * scale) * 0.5 + 0.5)

    love.graphics.draw(M.backgroundImage, offsetX, offsetY, 0, scale, scale)
end

M.renderFrame = function ()
    love.graphics.setBackgroundColor(1,1,1)
    drawBackground()
end

M.windowResized = function()
    local screen = {
        X = 0,
        Y = 0,
        centerX = 0,
        centerY = 0,
        minSize = 0,
        topLeft = { X = 0, Y = 0 },
        topRight = { X = 0, Y = 0 },
        bottomLeft = { X = 0, Y = 0 },
        bottomRight = { X = 0, Y = 0 }
    }
    screen.X, screen.Y = love.graphics.getDimensions()
    screen.minSize = (screen.Y < screen.X) and screen.Y or screen.X
    screen.centerX = screen.X / 2
    screen.centerY = screen.Y / 2

    local half = screen.minSize / 2
    screen.topLeft.X = screen.centerX - half
    screen.topLeft.Y = screen.centerY - half
    screen.topRight.X = screen.centerX + half
    screen.topRight.Y = screen.centerY - half
    screen.bottomRight.X = screen.centerX + half
    screen.bottomRight.Y = screen.centerY + half
    screen.bottomLeft.X = screen.centerX - half
    screen.bottomLeft.Y = screen.centerY + half

    return screen
end

return M