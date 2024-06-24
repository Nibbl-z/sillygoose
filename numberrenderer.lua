local module = {}

local sprites = {
    ["0"] = love.graphics.newImage("/img/numbers/0.png"),
    ["1"] = love.graphics.newImage("/img/numbers/1.png"),
    ["2"] = love.graphics.newImage("/img/numbers/2.png"),
    ["3"] = love.graphics.newImage("/img/numbers/3.png"),
    ["4"] = love.graphics.newImage("/img/numbers/4.png"),
    ["5"] = love.graphics.newImage("/img/numbers/5.png"),
    ["6"] = love.graphics.newImage("/img/numbers/6.png"),
    ["7"] = love.graphics.newImage("/img/numbers/7.png"),
    ["8"] = love.graphics.newImage("/img/numbers/8.png"),
    ["9"] = love.graphics.newImage("/img/numbers/9.png")
}

function module:RenderNumber(number, x, y, virtualWidth, virtualHeight)
    number = tostring(number)
    
    for i = 1, string.len(number) do
        local digit = string.sub(number, i, i)
        sprites[digit]:setFilter("nearest", "nearest")
        love.graphics.draw(sprites[digit], x + ((i - 1) * 9), y)
    end
end

return module