Settings = require("game.settings")
Spider = require("sprites.spider")
Fly = require("sprites.fly")
UI = require("game.ui")
Shader = require("game.shader")

IsPaused = false
Screen = {}
Spiders = {}
Flies = {}
Player = {
    spiderIndex = 1,
    killedFlies = 0,
    health = Settings.player.health,
    hasLost = false
}

function love.load()
    Screen = UI.windowResized()
    math.randomseed(os.time());
    Shader.loadShader()
    BackgroundMusic = love.audio.newSource(Settings.backgroundMusic, 'stream')
    BackgroundMusic:setLooping(true)
    BackgroundMusic:play()
    BackgroundMusic:setVolume(0.25)
    -- spider
    Spider.initSpriteAsset()
    local spriteW, spriteH = Spider._sharedSprite:getDimensions()
    table.insert(Spiders, Spider:new({ isPlayer = true, offset = { X = spriteW / 2, Y = spriteH / 2 } }))
    Player.spiderIndex = #Spiders
    --Fly
    Fly.initSpriteAsset()
    spriteW, spriteH = Fly._sharedSprite:getDimensions()
    table.insert(Flies, Fly:new({ offset = { X = spriteW / 2, Y = spriteH / 2 } }))
end

function love.update(dt)
    if Player.health <= 0 then
        IsPaused = true
        Player.hasLost = true
    end
    if IsPaused then return end
    for i, v in ipairs(Spiders) do
        v:update(dt)
    end
    for i = #Flies, 1, -1 do
        Flies[i]:update(dt)
    end
    Fly.spawnRandom(dt)
end

function love.draw()
    UI.renderFrame()
    Shader.drawShader()
    for i, v in ipairs(Flies) do
        v:render()
    end
    for i, v in ipairs(Spiders) do
        v:renderNet()
        v:render()
    end
    if Settings.DEBUG == true then
        local prevShader = love.graphics.getShader()
        love.graphics.setShader()
        UI.drawDebug()
        love.graphics.setShader(prevShader)
    end
    UI.drawInfo()
end

function love.resize()
    Screen = UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)
    -- if key == "space" then
    --     Spiders[Player.spiderIndex]:saveLastLinePoint()
    --     print("space")
    -- else
    --     print(key..", " .. scancode)
    -- end

    if key == "f5" then
        Settings.DEBUG = not Settings.DEBUG
    end
    if key == "enter" and Player.hasLost == true then
        Player.hasLost = false
    end
end

function love.keyreleased(key, scancode)
    if key == "space" then
        Spiders[Player.spiderIndex]:saveLastLinePoint(true)
    end
end
