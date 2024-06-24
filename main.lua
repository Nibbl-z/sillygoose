local virtualWidth = 64
local virtualHeight = 64
local windowScale = 10

local player = require("player")
local collision = require("collision")

local greygeese = {}
local enemies = 5

local bread

local world = love.physics.newWorld(0, 0, true)

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(virtualWidth * windowScale, virtualHeight * windowScale)
    
    plrSprite = love.graphics.newImage("/img/plr.png")
    enemySprite = love.graphics.newImage("/img/greygoose.png")
    bgSprite = love.graphics.newImage("/img/bg.png")
    
    healthbarBaseSprite = love.graphics.newImage("/img/healthbar_background.png")
    healthbarSprite = love.graphics.newImage("/img/healthbar_bar.png")

    breadSprite = love.graphics.newImage("/img/bread.png")
    
    bgSprite:setWrap("repeat", "repeat", "repeat")
    
    player:Init(world)
    
    for i = 1, enemies do
        local greygoose = setmetatable({}, require("enemy"))
        table.insert(greygeese, greygoose)
        
        greygoose.x = math.random(0, 64)
        greygoose.y = math.random(0, 64)

        greygoose:Init(world, i)
    end

    local borders = {
        {0,0,virtualWidth * 2,1},--top
        {0,virtualHeight,virtualWidth * 2,1},--bottom
        {0,0,1,virtualHeight * 2},--left
        {virtualWidth,0,1,virtualHeight * 2}--right
    }
    
    for index, border in ipairs(borders) do
        local Border = {}

        Border.body = love.physics.newBody(world, border[1], border[2], "static")
        Border.shape = love.physics.newRectangleShape(border[3], border[4])
        Border.fixture = love.physics.newFixture(Border.body, Border.shape)
        Border.fixture:setRestitution(0)
        Border.fixture:setUserData("border"..tostring(index))
    end

    bgMusic = love.audio.newSource("/audio/bg_music.mp3", "stream")
    hurtSfx = love.audio.newSource("/audio/hitHurt.wav", "static")
end

function love.update(dt)
    player:Movement(dt)

    for _, goose in ipairs(greygeese) do
        goose:Follow(player.body:getX(), player.body:getY(), dt)
    
        if collision:CheckCollision(
            math.floor(player.body:getX()), math.floor(player.body:getY()), 8, 8,
            math.floor(goose.body:getX()), math.floor(goose.body:getY()), 8, 8
        ) then
            goose:Damage(player, hurtSfx)
        end
    end
    
    if bread == nil then
        bread = require("bread")
        bread.x = math.random(4, 60)
        bread.y = math.random(4, 60)
    end

    if collision:CheckCollision(
            math.floor(player.body:getX()), math.floor(player.body:getY()), 8, 8,
            math.floor(bread.x), math.floor(bread.y), 12, 12
        ) then
            player.bread = player.bread + 1
            bread = nil
        end

    world:update(dt)

    

    if not bgMusic:isPlaying() then
        bgMusic:play()
    end
end

function love.draw()
    -- Virtual resolution
    love.graphics.push()
    love.graphics.scale(love.graphics.getHeight() / virtualWidth, love.graphics.getHeight() / virtualHeight)
    
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.draw(bgSprite, 0,0,0,1,1)
    
    if bread ~= nil then
        love.graphics.draw(breadSprite, bread.x, bread.y)
    end
    love.graphics.draw(plrSprite, math.floor(player.body:getX()), math.floor(player.body:getY()), 0, player.direction, 1, 4, 4)
    
    for _, goose in ipairs(greygeese) do
        love.graphics.draw(enemySprite, math.floor(goose.body:getX()), math.floor(goose.body:getY()), 0, goose.direction, 1, 4, 4)
    end
    
    love.graphics.draw(healthbarBaseSprite, 2, 2)
    love.graphics.draw(healthbarSprite, 2, 2, 0, player.health / 100, 1)
    
    -- Rendering virtual resolution
    love.graphics.pop()
end