menu = {}

function menu:init()
    self.titleText = "LÖVE Game"
    self.titleFont = Fonts.bold[60]
    self.titleColor = {233, 73, 154}

    self.startKey = "space"
    self.startText = "Press " .. string.upper(self.startKey) .. " to start"
    self.startFont = Fonts.regular[24]
    self.startColor = {255, 255, 255}

    love.graphics.setBackgroundColor(37, 170, 225)
end

function menu:enter()

end

function menu:update(dt)

end

function menu:keyreleased(key, code)
    if key == self.startKey then
        State.switch(game)
    end
end

function menu:mousepressed(x, y, mbutton)

end

function menu:draw()
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(self.titleColor[1]*0.5, self.titleColor[2]*0.5, self.titleColor[3]*0.5, 200)
    love.graphics.printf(self.titleText, 3, 103, love.graphics.getWidth(), "center")
    love.graphics.setColor(self.titleColor)
    love.graphics.printf(self.titleText, 0, 100, love.graphics.getWidth(), "center")
    love.graphics.setFont(self.startFont)
    
    -- Start text fades in and out
    local r, g, b = self.startColor[1], self.startColor[2], self.startColor[3]
    love.graphics.setColor(r, g, b, 255 * math.abs(math.sin(love.timer.getTime()*2)))
    love.graphics.printf(self.startText, 0, love.graphics.getHeight()/2 - self.startFont:getHeight(self.startText)/2, love.graphics.getWidth(), "center")
end
