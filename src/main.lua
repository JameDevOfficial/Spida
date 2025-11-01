Settings = require("game.settings")
Spider = require("sprites.spider")
UI = require("game.ui")
Shader = require("game.shader")

IsPaused = false
Screen = {}
Spiders = {}
Player = {
    spiderIndex = 1
}

function love.load()
    Screen = UI.windowResized()
    math.randomseed(os.time());
    Shader.loadShader()
    -- sprites
    Spider.initSpriteAsset()
    local spriteW, spriteH = Spider._sharedSprite:getDimensions()
    table.insert(Spiders, Spider:new({ isPlayer = true, offset = { X = spriteW / 2, Y = spriteH / 2}}))
    Player.spiderIndex = #Spiders
end

function love.update(dt)
    if IsPaused then return end
    for i, v in ipairs(Spiders) do
        v:update(dt)
    end
end

function love.draw()
    UI.renderFrame()
    Shader.drawShader()
    for i, v in ipairs(Spiders) do
        v:renderNet()
        v:render()
    end
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
end
