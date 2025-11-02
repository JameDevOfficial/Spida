local M = {}

M.DEBUG = false
M.EPSILON = 10
M.backgroundImage = "assets/forest.png"
M.Shader = true

M.spider = {}
M.spider.speed = 200
M.spider.image = "assets/spider_small.png"
M.spider.maxNetPoints = 25
M.spider.maxTTL = 20 -- seconds

return M
