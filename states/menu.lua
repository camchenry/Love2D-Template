local menu = {}

function menu:init()
    self.titleText = "LÖVE Game"
    self.titleFont = Fonts.bold[60]
    self.titleColor = {1, 1, 1}

    self.startText = "Press any key or touch to start"
    self.startFont = Fonts.regular[24]
    self.startColor = {1, 1, 1}
end

function menu:enter()

end

function menu:update(dt)

end

function menu:keyreleased(key, code)
    State.switch(States.game)
end

function menu:touchreleased(id, x, y, dx, dy, pressure)
    State.switch(States.game)
end

function menu:mousepressed(x, y, mbutton)

end

function menu:draw()
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.titleColor[1]*0.5, self.titleColor[2]*0.5, self.titleColor[3]*0.5, 0.8)
    love.graphics.printf(self.titleText, 3, 103, love.graphics.getWidth(), "center")
    love.graphics.setColor(self.titleColor)
    love.graphics.printf(self.titleText, 0, 100, love.graphics.getWidth(), "center")
    love.graphics.setFont(self.startFont)

    -- Start text fades in and out
    local r, g, b = self.startColor[1], self.startColor[2], self.startColor[3]
    love.graphics.setColor(r, g, b, math.abs(math.sin(love.timer.getTime()*2)))
    love.graphics.printf(self.startText, 0, love.graphics.getHeight()/2 - self.startFont:getHeight(self.startText)/2, love.graphics.getWidth(), "center")
end

return menu
