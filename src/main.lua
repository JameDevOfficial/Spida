Settings = require("game.settings")
Spider = require("sprites.spider")
UI = require("game.ui")

IsPaused = false
Screen = {}
Spiders = {}

function love.load()
    UI.windowResized()
    math.randomseed(os.time());

    -- sprites
    Spider.initSpriteAsset()
    table.insert(Spiders, Spider:new())
end

function love.update(dt)
    if IsPaused then return end
end

function love.draw()
    UI.renderFrame()
    for i, v in ipairs(Spiders) do
        v:render()
    end
end

function love.resize()
    UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)

end
