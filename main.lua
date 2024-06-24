local virtualWidth = 64
local virtualHeight = 64
local windowScale = 10

local direction = {w = {0,-1}, a = {-1,0}, s = {0,1}, d = {1,0}}
local speed = 50

local playerX = 32
local playerY = 32

local facing = 1

local enemy = require("enemy")

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(virtualWidth * windowScale, virtualHeight * windowScale)

    plrSprite = love.graphics.newImage("plr.png")
    enemySprite = love.graphics.newImage("greygoose.png")
    bgSprite = love.graphics.newImage("bg.png")

    bgSprite:setWrap("repeat", "repeat", "repeat")
end

function love.update(dt)
    for key, mult in pairs(direction) do
        if love.keyboard.isDown(key) then
            playerX = playerX + (speed * dt * mult[1])
            playerY = playerY + (speed * dt * mult[2])

            if key == "a" then
                facing = 1
            elseif key == "d" then
                facing = -1
            end
        end
    end

    enemy:Follow(playerX, playerY, dt)
end

function love.draw()
    -- Virtual resolution
    love.graphics.push()
    love.graphics.scale(love.graphics.getHeight() / virtualWidth, love.graphics.getHeight() / virtualHeight)

    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.draw(bgSprite, 0,0,0,1,1)
    love.graphics.draw(plrSprite, math.floor(playerX), math.floor(playerY), 0, facing, 1, 4, 4)

    love.graphics.draw(enemySprite, math.floor(enemy.enemyX), math.floor(enemy.enemyY), 0, enemy.direction, 1, 4, 4)
    
    -- Rendering virtual resolution
    love.graphics.pop()
end