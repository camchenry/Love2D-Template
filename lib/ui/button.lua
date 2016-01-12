Button = class("Button")

function Button:initialize(text, x, y, w, h, fontSize, activated)
    self.text = text
    self.font = fontSize or font[32]
    self.x = x
    self.y = y
    self.width = w or self.font:getWidth(text)
    self.height = h or self.font:getHeight(text)

    self.active = {127, 127, 127}
    self.bg = {255, 255, 255, 0}
    self.fg = {255, 255, 255, 255}

    self.translateX = 0

    self.click = Button.click
    self.selected = false
    self.alreadyHovering = false

    self.activated = activated or function() end
end

function Button:update(dt)
    if self:hover() and not self.alreadyHovering then
        signal.emit('uiHover')
        self.alreadyHovering = true
    elseif not self:hover() then
        self.alreadyHovering = false
    end
end

function Button:mousepressed(x, y, mbutton)
    if self:hover() and mbutton == 1 then
        signal.emit('uiClick')
        self.activated()
    end
end

function Button:draw()
    local r, g, b, a = love.graphics.getColor()
    local oldColor = {r, g, b, a}


    love.graphics.setColor(self.bg)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    if self:hover() then
        love.graphics.setColor(self.active)
    else
        love.graphics.setColor(self.fg)
    end

    local x = self.x + self.width/2 - self.font:getWidth(self.text)/2 + self.translateX
    local y = self.y + self.height/2 - self.font:getHeight(self.text)/2
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, x, y)

    love.graphics.setColor(oldColor)
end

function Button:setFont(font, update)
    update = update or true
    self.font = font
    if update then
        self.width =  self.font:getWidth(self.text)
        self.height = self.font:getHeight(self.text)
    end
    return self
end

function Button:setActive(r, g, b, a)
    self.active = {r, g, b, a or 255}
    return self
end

function Button:setBG(r, g, b, a)
    self.bg = {r, g, b, a or 255}
    return self
end

function Button:setFG(r, g, b, a)
    self.fg = {r, g, b, a or 255}
    return self
end

function Button:align(mode, margin)
    margin = margin or 0

    -- this will center align the button around the original coordinates
    if mode == 'both' then
        self.x = self.x - self.width/2
        self.y = self.y - self.height/2
    end

    -- this will only align the button around the original x coordinate
    if mode == 'x' then
        self.x = self.x - self.width/2
    end

    -- this will only align the button around the original y coordinate
    if mode == 'y' then
        self.y = self.y - self.height/2
    end

    -- shift text to left
    if mode == 'left' then
        self.translateX =  self.font:getWidth(self.text)/2 - self.width/2 + margin
    end

    -- shift text to center
    if mode == 'center' then
        self.translateX = 0
    end

    -- shift text to right
    if mode == 'right' then
        self.translateX = self.font:getWidth(self.text)/2 + self.width/2 + margin
    end
end

function Button:centerAround(x, y)
    self.x = x - self.width/2
    self.y = y - self.height/2
    return self
end

-- returns whether or not the mouse is currently over the button
function Button:hover()
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local inX = mx >= self.x and mx <= self.x + self.width
    local inY = my >= self.y and my <= self.y + self.height
    return inX and inY
end