Settings = require("game.settings")
Spider = require("sprites.spider")
UI = require("game.ui")

IsPaused = false
Screen = {}
Spiders = {}

function love.load()
    Screen = UI.windowResized()
    math.randomseed(os.time());

    -- sprites
    Spider.initSpriteAsset()
    table.insert(Spiders, Spider:new())
end

function love.update(dt)
    if IsPaused then return end

    for i, v in ipairs(Spiders) do
        v:update(dt)
    end
end

function love.draw()
    UI.renderFrame()
    for i, v in ipairs(Spiders) do
        v:renderNet()
        v:render()
    end
end

function love.resize()
    Screen = UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)

end
