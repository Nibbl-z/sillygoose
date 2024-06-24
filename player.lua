local player = {}

local movementDirections = {w = {0,-1}, a = {-1,0}, s = {0,1}, d = {1,0}}
player.x = 32
player.y = 32
player.speed = 2

player.health = 100
player.direction = 1
player.bread = 0

player.damageEffectTimer = love.timer.getTime()
player.disableMovement = false

player.__index = player

function player:ResetValues()
    self.speed = 2
    self.health = 100
    self.direction = 1
    self.bread = 0
    self.disableMovement = false

    self.body:setX(32)
    self.body:setY(32)
end

function player:Init(world)
    if self.body ~= nil then
        self.body:destroy()
    end

    self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newRectangleShape(4, 4)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setRestitution(0.1)
    self.fixture:setDensity(10000000)
    self.fixture:setUserData("player")
end

function player:Movement(dt)
    if self.disableMovement then return end

    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            self.body:applyForce(self.speed * mult[1], self.speed * mult[2])

            if key == "a" then
                self.direction = 1
            elseif key == "d" then
                self.direction = -1
            end
        end
    end
end

function player:TakeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then self.health = 0 end

    self.damageEffectTimer = love.timer.getTime() + 0.1
end

function player:Heal(heal)
    self.health = self.health + heal
    if self.health > 100 then self.health = 100 end
end

return player