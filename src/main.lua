Settings = require("settings")
Spider = require("sprites.spider")
UI = require("ui")

IsPaused = false
Screen = {}

function love.load()
    UI.windowResized()
    math.randomseed(os.time());
end

function love.update(dt)

end

function love.draw()

end

function love.resize()
    UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)

end