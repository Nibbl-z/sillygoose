local enemy = {}

enemy.enemyX = 0
enemy.enemyY = 0
enemy.speed = 20
enemy.direction = 1

function enemy:Follow(playerX, playerY, dt)
    if self.enemyX < playerX then
        self.enemyX = self.enemyX + (self.speed * dt)

        self.direction = -1
    end
    
    if self.enemyX > playerX then
        self.enemyX = self.enemyX - (self.speed * dt)
        
        self.direction = 1
    end

    if self.enemyY < playerY then
        self.enemyY = self.enemyY + (self.speed * dt)
    end
    
    if self.enemyY > playerY then
        self.enemyY = self.enemyY - (self.speed * dt)
    end
end

return enemy