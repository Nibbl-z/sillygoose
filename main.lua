local virtualWidth = 64
local virtualHeight = 64
local windowScale = 10

local player = require("player")
local enemy = require("enemy")
local collision = require("collision")

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(virtualWidth * windowScale, virtualHeight * windowScale)

    plrSprite = love.graphics.newImage("plr.png")
    enemySprite = love.graphics.newImage("greygoose.png")
    bgSprite = love.graphics.newImage("bg.png")

    bgSprite:setWrap("repeat", "repeat", "repeat")
end

function love.update(dt)
    player:Movement(dt)
    enemy:Follow(player.x, player.y, dt)
    
    if collision:CheckCollision(
        math.floor(player.x), math.floor(player.y), 8, 8,
        math.floor(enemy.x), math.floor(enemy.y), 8, 8
    ) then
        enemy:Damage(player)
    end
end

function love.draw()
    -- Virtual resolution
    love.graphics.push()
    love.graphics.scale(love.graphics.getHeight() / virtualWidth, love.graphics.getHeight() / virtualHeight)

    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.draw(bgSprite, 0,0,0,1,1)
    love.graphics.draw(plrSprite, math.floor(player.x), math.floor(player.y), 0, player.direction, 1, 4, 4)

    love.graphics.draw(enemySprite, math.floor(enemy.x), math.floor(enemy.y), 0, enemy.direction, 1, 4, 4)
    love.graphics.print(tostring(player.health), 0, 0)
    -- Rendering virtual resolution
    love.graphics.pop()
end