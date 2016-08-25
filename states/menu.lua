menu = {}

function menu:init()
    self.titleText = "Unfinished game"
    self.titleFont = Fonts.bold[48]

    self.startKey = "space"
    self.startText = "Press " .. self.startKey .. " to start"
    self.startFont = Fonts.regular[24]
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
    love.graphics.printf(self.titleText, 0, 100, love.graphics.getWidth(), "center")
    love.graphics.setFont(self.startFont)
    love.graphics.printf(self.startText, 0, love.graphics.getHeight()/2 - self.startFont:getHeight(self.startText)/2, love.graphics.getWidth(), "center")
end
