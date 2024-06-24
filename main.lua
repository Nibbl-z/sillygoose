local virtualWidth = 64
local virtualHeight = 64
local windowScale = 10

local player = require("player")
local collision = require("collision")
local numberRenderer = require("numberrenderer")

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
    plrHurtSprite = love.graphics.newImage("/img/plr_hurt.png")

    gameOverSprite = love.graphics.newImage("/img/game_over.png")
    
    bgSprite:setWrap("repeat", "repeat", "repeat")
    
    player:Init(world)
    
    for i = 1, enemies do
        local greygoose = setmetatable({}, require("enemy"))
        table.insert(greygeese, greygoose)
        
        local function distance(x1, y1, x2, y2)
            local dx = x1 - x2
            local dy = y1 - y2
            return math.sqrt(dx * dx + dy * dy)
        end
        
        repeat
            local side = math.random(1,4)
            if side == 1 then
                greygoose.x = -20
                greygoose.y = math.random(4,60)
            elseif side == 2 then
                greygoose.x = virtualWidth + 20
                greygoose.y = math.random(4,60)
            elseif side == 3 then
                greygoose.x = math.random(4,60)
                greygoose.y = -20
            elseif side == 4 then
                greygoose.x = math.random(4,60)
                greygoose.y = virtualHeight + 20
            end 
            
    
        until distance(player.body:getX(), player.body:getY(), greygoose.x, greygoose.y) > 30
         
        
        greygoose.speed = math.random(1000, 1600) / 100
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
        Border.fixture:setCategory(5, 5)
        Border.fixture:setMask(5, 6)
        Border.fixture:setUserData("border"..tostring(index))
    end

    bgMusic = love.audio.newSource("/audio/bg_music.mp3", "stream")
    hurtSfx = love.audio.newSource("/audio/hitHurt.wav", "static")
    breadSfx = love.audio.newSource("/audio/pickupBread.wav", "static")
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
        local function distance(x1, y1, x2, y2)
            local dx = x1 - x2
            local dy = y1 - y2
            return math.sqrt(dx * dx + dy * dy)
        end

        bread = require("bread")

        repeat
            bread.x = math.random(4, 60)
            bread.y = math.random(4, 60)
        until distance(player.body:getX(), player.body:getY(), bread.x, bread.y) > 20
       
    end

    if collision:CheckCollision(
            math.floor(player.body:getX()), math.floor(player.body:getY()), 8, 8,
            math.floor(bread.x), math.floor(bread.y), 12, 12
        ) then
            player.bread = player.bread + 1
            bread = nil
            breadSfx:play()
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
    
    if player.damageEffectTimer > love.timer.getTime() then
        love.graphics.setColor(1,0,0,1)
        love.graphics.draw(plrHurtSprite, math.floor(player.body:getX()), math.floor(player.body:getY()), 0, player.direction, 1, 4, 4)
    else
        love.graphics.draw(plrSprite, math.floor(player.body:getX()), math.floor(player.body:getY()), 0, player.direction, 1, 4, 4)
    end
    
    love.graphics.setColor(1,1,1,1)
    for _, goose in ipairs(greygeese) do
        love.graphics.draw(enemySprite, math.floor(goose.body:getX()), math.floor(goose.body:getY()), 0, goose.direction, 1, 4, 4)
    end
    
    love.graphics.draw(healthbarBaseSprite, 2, 2)
    love.graphics.draw(healthbarSprite, 2, 2, 0, player.health / 100, 1)
    
    love.graphics.draw(breadSprite, virtualWidth - 10, 2)
    numberRenderer:RenderNumber(player.bread, virtualWidth - 20, 2, virtualWidth, virtualHeight, "righttoleft")

    if player.health <= 0 then
        player.disableMovement = true
        love.graphics.setColor(1,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, virtualWidth, virtualHeight)
        love.graphics.setColor(1,1,1,1)

        love.graphics.draw(gameOverSprite, 0,0)
    end
    
    -- Rendering virtual resolution
    love.graphics.pop()
end