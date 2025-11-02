local M = {}

M.backgroundImage = love.graphics.newImage(Settings.backgroundImage)
M.backgroundImage:setFilter("nearest", "nearest") -- for sharp rendering and not blurry

local RGB = function(r, g, b)
    return r / 255, g / 255, b / 255
end

local fontDefault = love.graphics.newFont(20)
local font30 = love.graphics.newFont(30)
local font50 = love.graphics.newFont(50)

fontDefault:setFilter("nearest", "nearest")
font30:setFilter("nearest", "nearest")
font50:setFilter("nearest", "nearest")


local drawBackground = function()
    local bgW, bgH = M.backgroundImage:getDimensions()
    local screenW, screenH = love.graphics.getDimensions()
    local scale = math.max(screenW / bgW, screenH / bgH)
    local offsetX = math.floor((screenW - bgW * scale) * 0.5 + 0.5)
    local offsetY = math.floor((screenH - bgH * scale) * 0.5 + 0.5)

    love.graphics.draw(M.backgroundImage, offsetX, offsetY, 0, scale, scale)
end

M.drawInfo = function()
    local prevShader = love.graphics.getShader()
    love.graphics.setShader()
    love.graphics.setFont(fontDefault)
    love.graphics.setColor(1, 1, 1, 1)

    local text = string.format("Flies killed: %d", Player.killedFlies)
    local width = fontDefault:getWidth(text)
    love.graphics.print(text, Screen.X - width - 10, 10)


    local w, h = Screen.X / 3, Screen.Y / 25
    local x, y = Screen.X / 2 - w / 2, 10
    love.graphics.setColor(RGB(33, 33, 33))
    love.graphics.rectangle("fill", x, y, w, h)

    local w, h = Screen.X / 3, Screen.Y / 25
    local x, y = Screen.X / 2 - w / 2, 10
    love.graphics.setColor(RGB(198, 40, 40))
    w = w * (Player.health / Settings.player.health)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(1, 1, 1, 1)
    text = string.format("%d / %d", Player.health, Settings.player.health)
    y = y + (h - fontDefault:getHeight()) / 2
    love.graphics.print(text, x, y)

    love.graphics.setShader(prevShader)
end

function M.drawCenteredText(centerX, centerY, text, font)
    love.graphics.setFont(font)
    local textWidth  = font:getWidth(text)
    local textHeight = font:getHeight()

    local drawX      = centerX - textWidth / 2
    local drawY      = centerY - textHeight / 2
    love.graphics.print(text, math.floor(drawX), math.floor(drawY))
end

M.drawMenu = function()
    local prevShader = love.graphics.getShader()
    love.graphics.setShader()
    love.graphics.setBackgroundColor(RGB(154, 220, 243))
    love.graphics.setFont(fontDefault)
    love.graphics.setColor(1, 1, 1, 1)

    M.drawCenteredText(math.floor(Screen.centerX),
        math.floor(Screen.centerY - 30), "Spida!", font50)
    M.drawCenteredText(math.floor(Screen.centerX),
        math.floor(Screen.centerY + 10), "Press enter to start", font30)

    local text = "Use W/A/S/D or arrow keys to move and space to draw the net."
    love.graphics.setFont(fontDefault)
    local textWidth  = fontDefault:getWidth(text)
    local textHeight = fontDefault:getHeight()
    local drawX      = Screen.centerX - textWidth / 2
    local drawY      = Screen.Y - textHeight - 10
    love.graphics.print(text, math.floor(drawX), math.floor(drawY))
    love.graphics.setShader(prevShader)
end

M.lostScreen = function()
    local prevShader = love.graphics.getShader()
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
    M.drawCenteredText(math.floor(Screen.centerX),
        math.floor(Screen.centerY + 50), "Flies Killed: " .. Player.killedFlies, font30)
    M.drawCenteredText(math.floor(Screen.centerX),
        math.floor(Screen.centerY - 40), "You lost!", font50)
    M.drawCenteredText(math.floor(Screen.centerX),
        math.floor(Screen.centerY + 10), "Press enter to try again", font30)
    love.graphics.setShader(prevShader)
end

M.renderFrame = function()
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
            "Spiders: %d\n" ..
            "Flies: %d",
            usedMem / 1024,
            collectgarbage("count") > 0 and collectgarbage("count") / 10 or 0,
            stats.drawcalls,
            stats.canvasswitches,
            stats.texturememory / 1024 / 1024,
            stats.images,
            stats.fonts,
            #playerSpider.netPoints,
            #Spiders,
            #Flies
        )
        love.graphics.print(perfText, 10, y)
        y = y + fontDefault:getHeight() * 11

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
        y = y + fontDefault:getHeight() * 8

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
