local shop = {}

shop.shopItems = {
    {
        ID = "health",
        Price = 10,
        Callback = function(player)
            player:Heal(25)
        end
    }
}

shop.spawnTimer = love.timer.getTime() + 5
shop.spawned = false
shop.x = 0
shop.y = 0


function shop:GetShopItem(id)
    for _, shopItem in ipairs(self.shopItems) do
        if shopItem.ID == id then
            return shopItem
        end
    end
    
    return nil
end

function shop:Purchase(id, player)
    local shopItem = self:GetShopItem(id)
    if shopItem == nil then return end

    if player.bread >= shopItem.Price then
        player.bread = player.bread - shopItem.Price
        shopItem.Callback(player)
    end
end

function shop:SpawnStand(player)
    self.spawned = true

    local function distance(x1, y1, x2, y2)
        local dx = x1 - x2
        local dy = y1 - y2
        return math.sqrt(dx * dx + dy * dy)
    end
    
    repeat
        self.x = math.random(4, 60)
        self.y = math.random(4, 60)
    until distance(player.body:getX(), player.body:getY(), self.x, self.y) > 20
end

return shop