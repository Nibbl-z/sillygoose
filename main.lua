local virtualWidth = 64
local virtualHeight = 64
local windowScale = 10

local player = require("player")
local collision = require("collision")
local numberRenderer = require("numberrenderer")
local shop = require("shop")
local fade = require("fade")
local pause = require("pause")
local greygeese = {}
local enemies = 3

local bread

local world = love.physics.newWorld(0, 0, true)

local paused = false
local pauseMenu = false

local started = false
local startDelay = 0
local fadeStopTime = 0

local spawnGreyGooseTimer

local sprites = {
    Player = "plr.png",
    PlayerHurt = "plr_hurt.png",
    PlayerForcefield = "plr_forcefield.png",
    Enemy = "greygoose.png",
    Background = "bg.png",
    HealthbarBase = "healthbar_background.png",
    HealthbarBar = "healthbar_bar.png",
    Bread = "bread.png",
    GoldenBread = "golden_bread.png",
    GameOver = "game_over.png",
    RetryButton = "retry.png",
    
    ShopStand = "shop_stand.png",
    ShopMenu = "shop.png",
    ShopGoldBreadSold = "goldbread_soldout.png",
    ShopKeybind = "shop_keybind_hover.png",
    
    Tornado = "tornado.png",
    Forcefield = "forcefield.png",

    Menu = "menu.png",
    PressAnyKey = "pressanykey.png",

    Paused = "pause.png"
}

local sounds = {
    BGMusic = {"bg_music.mp3", "stream"},
    MenuMusic = {"menu_music.mp3", "stream"},
    Damage = {"hitHurt.wav", "static"},
    Bread = {"pickupBread.wav", "static"},
    Tornado = {"tornado.wav", "static"},
    Forcefield = {"forcefield.wav", "static"},
    Click = {"click.wav", "static"}
}

function SpawnGreyGoose()
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
    greygoose:Init(world, 1)
end

function Start()
    paused = false
    pauseMenu = false
    player:ResetValues()
    
    for _, v in ipairs(greygeese) do
        v:Destroy()
        v = nil
    end

    greygeese = {}
    
    for i = 1, enemies do
        SpawnGreyGoose()
    end
    
    shop.spawned = false
    shop.spawnTimer = love.timer.getTime() + 20
    spawnGreyGooseTimer = love.timer.getTime() + math.random(6,15)
    sounds.BGMusic:stop()
end

function love.load()
   

    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(virtualWidth * windowScale, virtualHeight * windowScale)
    
    love.window.setTitle("GOOSE SURVIVAL")
    love.window.setIcon(love.image.newImageData("/img/icon.png"))
    
    for name, sprite in pairs(sprites) do
        sprites[name] = love.graphics.newImage("/img/"..sprite)
    end
    for name, sound in pairs(sounds) do
        sounds[name] = love.audio.newSource("/audio/"..sound[1], sound[2])
    end
    
    love.audio.setEffect("gameover", {type = "equalizer", volume = 0.4, highgain = 0.126, highmidgain = 0.126, lowgain = 3})
    sounds.MenuMusic:play()
    sounds.MenuMusic:setVolume(0.5)
    sprites.Background:setWrap("repeat", "repeat", "repeat")

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

    player:Init(world)
    Start()
end

function love.update(dt)
    if started == false then return end
    if startDelay > love.timer.getTime() then return end
    
    player:Movement(dt)
    
    if love.timer.getTime() >= spawnGreyGooseTimer then
        SpawnGreyGoose()
        
        spawnGreyGooseTimer = love.timer.getTime() + math.random(6,15)
    end
    
    for _, goose in ipairs(greygeese) do
        goose:Follow(player.body:getX(), player.body:getY(), dt)
    
        if collision:CheckCollision(
            math.floor(player.body:getX()), math.floor(player.body:getY()), 8, 8,
            math.floor(goose.body:getX()), math.floor(goose.body:getY()), 8, 8
        ) then
            if not paused then
                goose:Damage(player, sounds.Damage)
            end
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
            bread.x = math.random(4, 46)
            bread.y = math.random(4, 46)
        until distance(player.body:getX(), player.body:getY(), bread.x, bread.y) > 20
        
        if math.random(1,10) >= player.goldenChance then
            bread.golden = true
        else
            bread.golden = false
        end
    end

    if collision:CheckCollision(
            math.floor(player.body:getX()), math.floor(player.body:getY()), 8, 8,
            math.floor(bread.x), math.floor(bread.y), 12, 12
        ) then
            if bread.golden == true then
                player.bread = player.bread + 5
            else
                player.bread = player.bread + 1
            end
            
            bread = nil
            sounds.Bread:play()
        end
    
    if not paused then world:update(dt) end
    if pauseMenu and not shop.menuOpen then
        local returnval = pause:HandlePause(windowScale)

        if returnval == "resume" then
            paused = false
            pauseMenu = false
        end
        if returnval == "retry" then
            Start()
        end
        if returnval == "quit" then
            love.event.quit()
        end
    end
    
    if not sounds.BGMusic:isPlaying() then
        sounds.BGMusic:setVolume(0.6)
        sounds.BGMusic:play()
    end
    
    if player.health <= 0 then
        local mouseX, mouseY = love.mouse.getPosition()
        
        if collision:CheckCollision(mouseX / windowScale, mouseY / windowScale, 1, 1, 16, 51, 31, 11) then
            if love.mouse.isDown(1) then
                print("retry")
                Start()
            end
        end
    end
    
    if love.keyboard.isDown("2") then
        player:UseAbility("tornado", greygeese, sounds.Tornado)
    end

    if love.keyboard.isDown("1") then
        player:UseAbility("forcefield", player, sounds.Forcefield)
    end

    if not shop.spawned then
        if shop.spawnTimer < love.timer.getTime() then
            shop:SpawnStand(player)
        end
    else
        if collision:CheckCollision(math.floor(player.body:getX()), math.floor(player.body:getY()), 8, 8,
        math.floor(shop.x), math.floor(shop.y), 12, 12) then
            shop.canOpen = true
            if love.keyboard.isDown("e") then
                if shop.menuOpen == false then
                    shop:OpenMenu()
                    paused = true
                end
            end
        else
            shop.canOpen = false
        end
    end
    
    if shop.menuOpen then
        local returnValue = shop:HandleMenu(windowScale, player, sounds.Click)
        if returnValue == "closed" then
            paused = false
        end
    end
end


function love.keypressed(key, scancode, isRepeat)
    if not isRepeat then
        if scancode == "escape" and not shop.menuOpen then
            paused = not paused
            pauseMenu = not pauseMenu
        end
    end
    
    if started == false then
        fade:SetTimes()
        startDelay = love.timer.getTime() + 1
        started = true
        fadeStopTime = love.timer.getTime() + 2
    end
end

function love.draw()
    -- Virtual resolution
    love.graphics.push()
    love.graphics.scale(love.graphics.getHeight() / virtualWidth, love.graphics.getHeight() / virtualHeight)
    
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.draw(sprites.Background, 0,0,0,1,1)
    
    if bread ~= nil then
        if bread.golden == true then
            love.graphics.draw(sprites.GoldenBread, bread.x, bread.y)
        else
            love.graphics.draw(sprites.Bread, bread.x, bread.y)
        end
    end
    
    if shop.spawned == true then
        love.graphics.draw(sprites.ShopStand, shop.x, shop.y)
        
        if shop.canOpen then
            love.graphics.draw(sprites.ShopKeybind, shop.x, shop.y)
        end
    end
    
    if player.damageEffectTimer > love.timer.getTime() then
        love.graphics.setColor(1,0,0,1)
        love.graphics.draw(sprites.PlayerHurt, math.floor(player.body:getX()), math.floor(player.body:getY()), 0, player.direction, 1, 4, 4)
    else
        if player.forcefielded then
            love.graphics.draw(sprites.PlayerForcefield, math.floor(player.body:getX()), math.floor(player.body:getY()), 0, player.direction, 1, 4, 4)
        else
            love.graphics.draw(sprites.Player, math.floor(player.body:getX()), math.floor(player.body:getY()), 0, player.direction, 1, 4, 4)
        end
        
    end
    
    love.graphics.setColor(1,1,1,1)
    for _, goose in ipairs(greygeese) do
        love.graphics.draw(sprites.Enemy, math.floor(goose.body:getX()), math.floor(goose.body:getY()), 0, goose.direction, 1, 4, 4)
    end
    
    love.graphics.draw(sprites.HealthbarBase, 2, 2)
    love.graphics.draw(sprites.HealthbarBar, 2, 2, 0, player.health / 100, 1)

    if shop.menuOpen == true then
        love.graphics.draw(sprites.ShopMenu, 0, 0)

        if player.goldenChance == 1 then
            love.graphics.draw(sprites.ShopGoldBreadSold, 0, 0)
        end
    end
    
    love.graphics.draw(sprites.Bread, virtualWidth - 10, 2)
    numberRenderer:RenderNumber(player.bread, virtualWidth - 20, 2, "righttoleft")
    
    if player:GetPowerup("tornado").Cooldown > love.timer.getTime() then
        love.graphics.setColor(0.5,0.5,0.5,1)
    end
    love.graphics.draw(sprites.Tornado, 2, virtualHeight - 10)
    love.graphics.setColor(1,1,1,1)
    numberRenderer:RenderNumber(player:GetPowerup("tornado").Amount, 12, virtualHeight - 10, "lefttoright")
    if player:GetPowerup("forcefield").Cooldown > love.timer.getTime() then
        love.graphics.setColor(0.5,0.5,0.5,1)
    end
    love.graphics.draw(sprites.Forcefield, 2, virtualHeight - 20)
    love.graphics.setColor(1,1,1,1)
    numberRenderer:RenderNumber(player:GetPowerup("forcefield").Amount, 12, virtualHeight - 20, "lefttoright")
    love.graphics.setColor(1,1,1,1)
    
    if player.health <= 0 then
        sounds.BGMusic:setVolume(0.2)
        sounds.BGMusic:setEffect("gameover", true)
        
        player.disableMovement = true
        love.graphics.setColor(1,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, virtualWidth, virtualHeight)
        love.graphics.setColor(1,1,1,1)
        
        love.graphics.draw(sprites.GameOver, 0,0)
        love.graphics.draw(sprites.RetryButton, 0, 0) -- 16, 51, 31, 11
    else
        sounds.BGMusic:setVolume(0.4)
        sounds.BGMusic:setEffect("gameover", false)
    end
    
    if started == false or startDelay > love.timer.getTime() then
        love.graphics.draw(sprites.Menu, 0, 0)
        love.graphics.draw(sprites.PressAnyKey, 0, 0)

        if sounds.MenuMusic:isPlaying() == false then
            sounds.MenuMusic:play()
        end
    else
        sounds.MenuMusic:stop()
    end

    if started == true and love.timer.getTime() <= fadeStopTime then
        fade:Fade()
    end

    if pauseMenu then
        sounds.BGMusic:setVolume(0.1)
        sounds.BGMusic:setEffect("gameover", true)
        love.graphics.draw(sprites.Paused, 0, 0)
    end
    
    -- Rendering virtual resolution
    love.graphics.pop()
end