local M = {}

M.backgroundImage = love.graphics.newImage(Settings.backgroundImage)
M.backgroundImage:setFilter("nearest", "nearest") -- for sharp rendering and not blurry

local fontDefault = love.graphics.newFont(20)

local drawBackground = function ()
    local bgW, bgH = M.backgroundImage:getDimensions()
    local screenW, screenH = love.graphics.getDimensions()
    local scale = math.max(screenW / bgW, screenH / bgH)
    local offsetX = math.floor((screenW - bgW * scale) * 0.5 + 0.5)
    local offsetY = math.floor((screenH - bgH * scale) * 0.5 + 0.5)

    love.graphics.draw(M.backgroundImage, offsetX, offsetY, 0, scale, scale)
end

M.renderFrame = function ()
    love.graphics.setBackgroundColor(1, 1, 1)
    drawBackground()
end

M.drawDebug = function()
    local playerSpider = Spiders[Player.spiderIndex]
    if Settings.DEBUG == true then
        love.graphics.setFont(fontDefault)
        love.graphics.setColor(1, 1, 1, 1)

        local y = fontDefault:getHeight() + 10

        -- FPS
        local fps = love.timer.getFPS()
        local fpsText = string.format("FPS: %d", fps)
        love.graphics.print(fpsText, 10, y)
        y = y + fontDefault:getHeight()

        -- Performance
        local stats = love.graphics.getStats()
        local usedMem = collectgarbage("count")
        local perfText = string.format(
            "Memory: %.2f MB\n" ..
            "GC Pause: %d%%\n" ..
            "Draw Calls: %d\n" ..
            "Canvas Switches: %d\n" ..
            "Texture Memory: %.2f MB\n" ..
            "Images: %d\n" ..
            "Fonts: %d\n" ..
            "Player Net Points: %d\n" ..
            "Spiders: %d",
            usedMem / 1024,
            collectgarbage("count") > 0 and collectgarbage("count") / 10 or 0,
            stats.drawcalls,
            stats.canvasswitches,
            stats.texturememory / 1024 / 1024,
            stats.images,
            stats.fonts,
            #playerSpider.netPoints,
            #Spiders
        )
        love.graphics.print(perfText, 10, y)
        y = y + fontDefault:getHeight() * 9

        -- Game
        local dt = love.timer.getDelta()
        local avgDt = love.timer.getAverageDelta()
        local playerText = string.format(
            "Game Paused: %s\n" ..
            "Spider X: %.1f Y: %.1f\n" ..
            "Velocity X: %.1f Y: %.1f\n" ..
            "Rotation: %.1f°\n" ..
            "Delta Time: %.4fs (%.1f ms)\n" ..
            "Avg Delta: %.4fs (%.1f ms)\n" ..
            "Time: %.2fs",
            tostring(IsPaused),
            playerSpider.position.X, playerSpider.position.Y,
            playerSpider.velocity.X, playerSpider.velocity.Y,
            playerSpider.rotation,
            dt, dt * 1000,
            avgDt, avgDt * 1000,
            love.timer.getTime()
        )
        love.graphics.print(playerText, 10, y)
        y = y + fontDefault:getHeight() * 10

        -- System Info
        local renderer = love.graphics.getRendererInfo and love.graphics.getRendererInfo() or ""
        local systemText = string.format(
            "OS: %s\nGPU: %s",
            love.system.getOS(),
            select(4, love.graphics.getRendererInfo()) or 0
        )
        love.graphics.print(systemText, 10, y)
    end
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