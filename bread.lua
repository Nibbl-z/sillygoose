local bread = {}

bread.x = 0
bread.y = 0
bread.golden = false

function bread:IncreaseGoldenChance(chance)
    self.goldenChance = self.goldenChance - 1
    if self.goldenChance <= 0 then
        self.goldenChance = 1
    end
end

return bread