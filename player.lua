local player = {}

local movementDirections = {w = {0,-1}, a = {-1,0}, s = {0,1}, d = {1,0}}
player.x = 32
player.y = 32
player.speed = 2

player.health = 100
player.direction = 1
player.bread = 0

function player:Init(world)
    player.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    player.shape = love.physics.newRectangleShape(4, 4)
    player.fixture = love.physics.newFixture(self.body, self.shape)
    player.fixture:setRestitution(0.1)
    player.fixture:setDensity(10000000)
    player.fixture:setUserData("player")
end

function player:Movement(dt)
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
end

return player