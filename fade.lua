local fade = {}
local fadeEndTime
local fadeBackTime

function fade:SetTimes()
    fadeEndTime = love.timer.getTime() + 1
    fadeBackTime = love.timer.getTime() + 2
end

function fade:Fade()
    if love.timer.getTime() <= fadeEndTime then
        local progress = love.timer.getTime() - fadeEndTime
        print(progress)
        love.graphics.setColor(0,0,0, 1 + progress)
        love.graphics.rectangle("fill",0,0,64,64)
    else
        local progress = love.timer.getTime() - fadeBackTime
        print(progress)
        love.graphics.setColor(0,0,0, -progress)
        love.graphics.rectangle("fill",0,0,64,64)
    end

    love.graphics.setColor(1,1,1,1)
end

return fade