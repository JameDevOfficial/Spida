local M = {}

M.DEBUG = false
M.EPSILON = 10
M.backgroundImage = "assets/forest.png"
M.backgroundMusic = "assets/Spooky_Forest.mp3"
M.Shader = true

M.spider = {}
M.spider.speed = 200
M.spider.image = "assets/spider_small.png"
M.spider.maxNetPoints = 25
M.spider.maxTTL = 20 -- seconds

M.fly = {}
M.fly.speed = 200
M.fly.image = "assets/evil_fly_small.png"

return M
