local enemy = {}

enemy.x = 0
enemy.y = 0
enemy.speed = 13
enemy.direction = 1
enemy.damage = 5

local disableFollowTimer = love.timer.getTime() + 2
local damageTimer = love.timer.getTime()

enemy.__index = enemy

function enemy:Init(world, index)
    self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newRectangleShape(6,6)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setRestitution(0.1)
    self.fixture:setDensity(0)
    self.fixture:setUserData("enemy"..tostring(index))
end

function enemy:Follow(playerX, playerY, dt)
    if disableFollowTimer > love.timer.getTime() then return end

    local forceX = 0
    local forceY = 0

    if self.body:getX() < playerX then
        forceX = self.speed

        self.direction = -1
    end
    
    if self.body:getX() > playerX then
        forceX = -self.speed
        
        self.direction = 1
    end
    
    if self.body:getY() < playerY then
        forceY = self.speed
    end
    
    if self.body:getY() > playerY then
        forceY = -self.speed
    end

    self.body:setLinearVelocity(forceX, forceY)
end

function enemy:Damage(player, hurtSfx)
    print(damageTimer)
    
    if damageTimer > love.timer.getTime() then return end
    
    damageTimer = love.timer.getTime() + 0.5
    disableFollowTimer = love.timer.getTime() + 0.8
    
    player:TakeDamage(self.damage)
    hurtSfx:play()

    local forceX = 0
    local forceY = 0
    local flingForce = 3

    if self.body:getX() < player.body:getX() then
        forceX = -flingForce

        self.direction = -1
    end
    
    if self.body:getX() > player.body:getX() then
        forceX = flingForce
        
        self.direction = 1
    end
    
    if self.body:getY() < player.body:getY() then
        forceY = -flingForce
    end
    
    if self.body:getY() > player.body:getY()  then
        forceY = flingForce
    end
    
    self.body:applyForce(forceX, forceY)
end

return enemy