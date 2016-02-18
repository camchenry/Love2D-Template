menu = {}

menu.items = {
    {
        title = "PLAY",
        action = function()
            state.switch(game)
        end,
    },
    {
        title = "OPTIONS",
        action = function()
            state.switch(options)
        end,
    },
    {
        title = "QUIT",
        action = function()
            love.event.quit()
        end,
    },
}

menu.buttons = {}

function menu:init()
    for i, item in pairs(self.items) do
        table.insert(self.buttons, Button:new(item.title, 75, 50*(i-1) + 250, nil, nil, font[30], item.action))
    end
end

function menu:enter()

end

function menu:update(dt)
    for i, button in pairs(self.buttons) do
        button:update(dt)
    end
end

function menu:keyreleased(key, code)

end

function menu:mousepressed(x, y, mbutton)
    for i, button in pairs(self.buttons) do
        button:mousepressed(x, y, mbutton)
    end
end

function menu:draw()
    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Untitled", 75, 70)

    for i, button in pairs(self.buttons) do
        button:draw()
    end
end