local shop = {}

shop.shopItems = {
    {
        ID = "health",
        Price = 10,
        Callback = function(player)
            player:Heal(25)
        end,
        ButtonTransform = {9, 25, 22, 11}
    },
    {
        ID = "goldbreadchance",
        Price = 15,
        Callback = function(player)
            player:IncreaseGoldenChance()
        end,
        ButtonTransform = {33, 25, 22, 11}
    },
    {
        ID = "tornado",
        Price = 20,
        Callback = function(player)
            player:IncreasePowerupAmount("tornado")
        end,
        ButtonTransform = {9, 38, 22, 11}
    },
    {
        ID = "forcefield",
        Price = 20,
        Callback = function(player)
            player:IncreasePowerupAmount("forcefield")
        end,
        ButtonTransform = {33, 38, 22, 11}
    }
}

shop.spawnTimer = love.timer.getTime() + 10
shop.spawned = false
shop.x = 0
shop.y = 0
shop.menuOpen = false

local isMouseReleased = true

local collision = require("collision")

function shop:GetShopItem(id)
    for _, shopItem in ipairs(self.shopItems) do
        if shopItem.ID == id then
            return shopItem
        end
    end
    
    return nil
end

function shop:Purchase(id, player, bread)
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

function shop:HandleMenu(windowScale, player, clickSfx)
    local mouseX, mouseY = love.mouse.getPosition()

    for _, shopItem in ipairs(self.shopItems) do
        if collision:CheckCollision(mouseX / windowScale, mouseY / windowScale, 1, 1, shopItem.ButtonTransform[1], shopItem.ButtonTransform[2], shopItem.ButtonTransform[3], shopItem.ButtonTransform[4]) then
            if love.mouse.isDown(1) and isMouseReleased then
                clickSfx:play()
                isMouseReleased = false
                self:Purchase(shopItem.ID, player)
            end
        end
    end
    
    if collision:CheckCollision(mouseX / windowScale, mouseY / windowScale, 1, 1, 21, 50, 22, 6) then
        if love.mouse.isDown(1) then
            clickSfx:play()
            self.menuOpen = false
            self.spawnTimer = love.timer.getTime() + 20
            self.spawned = false
            return "closed"
        end
    end

    if not love.mouse.isDown(1) then
        isMouseReleased = true
    end
end

function shop:OpenMenu()
    self.menuOpen = true
end

return shop