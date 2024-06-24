local enemy = {}

enemy.x = 0
enemy.y = 0
enemy.speed = 20
enemy.direction = 1
enemy.damage = 5

local damageTimer = love.timer.getTime()

function enemy:Follow(playerX, playerY, dt)
    if self.x < playerX then
        self.x = self.x + (self.speed * dt)

        self.direction = -1
    end
    
    if self.x > playerX then
        self.x = self.x - (self.speed * dt)
        
        self.direction = 1
    end

    if self.y < playerY then
        self.y = self.y + (self.speed * dt)
    end
    
    if self.y > playerY then
        self.y = self.y - (self.speed * dt)
    end
end

function enemy:Damage(player)
    print(damageTimer)

    if damageTimer > love.timer.getTime() then return end

    damageTimer = love.timer.getTime() + 0.5
    player:TakeDamage(self.damage)
end

return enemy