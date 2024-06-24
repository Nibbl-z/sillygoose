local player = {}

local movementDirections = {w = {0,-1}, a = {-1,0}, s = {0,1}, d = {1,0}}
player.speed = 50

player.x = 32
player.y = 32

player.health = 100
player.direction = 1

function player:Movement(dt)
    for key, mult in pairs(movementDirections) do
        if love.keyboard.isDown(key) then
            self.x = self.x + (self.speed * dt * mult[1])
            self.y = self.y + (self.speed * dt * mult[2])

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