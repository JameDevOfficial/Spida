local M = {}

M.DEBUG = false
M.EPSILON = 10
M.backgroundImage = "assets/forest.png"
M.backgroundMusic = "assets/Spooky_Forest.mp3"
M.Shader = true

M.spider = {}
M.spider.speed = 200
M.spider.image = "assets/spider_small.png"
M.spider.maxNetPoints = 20
M.spider.maxTTL = 10 -- seconds
M.spider.tolerance = 15

M.fly = {}
M.fly.speed = 100
M.fly.image = "assets/evil_fly_small.png"
M.fly.spawnChance = 30 -- in %; per second
M.fly.timeToDie = 2    -- seconds
M.fly.damage = 10

M.player = {}
M.player.health = 100
M.player.hitCooldown = 0.5

return M
