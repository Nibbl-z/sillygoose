local pause = {}

local buttons = {
    {
        Return = "resume",
        ButtonTransform = {15, 23, 31, 11}
    },
    {
        Return = "retry",
        ButtonTransform = {15, 36, 31, 11}
    }
    ,
    {
        Return = "quit",
        ButtonTransform = {15, 49, 31, 11}
    }
}
local collision = require("collision")

function pause:HandlePause(windowScale)
    local mouseX, mouseY = love.mouse.getPosition()

    for _, button in ipairs(buttons) do
        if collision:CheckCollision(mouseX / windowScale, mouseY / windowScale, 1, 1, button.ButtonTransform[1], button.ButtonTransform[2], button.ButtonTransform[3], button.ButtonTransform[4]) then
            if love.mouse.isDown(1) then
                return button.Return
            end
        end
    end

    return nil
end

return pause