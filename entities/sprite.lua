local Sprite = Class("Sprite")

function Sprite:initialize(image)
    self.image = love.graphics.newImage(image)
    self.position = Vector(0, 0)
    self.color = {255, 255, 255, 255}
    self.rotation = 0
    self.scale = Vector(1, 1)
    self.offset = Vector(0, 0)
    self.centered = true

    self.width, self.height = self:calculateSize()
    self.actualWidth, self.actualHeight = self.image:getDimensions()
end

function Sprite:update(dt)
    self.width, self.height = self:calculateSize()
end

function Sprite:draw()
    local x, y = self.position:unpack()

    if self.centered then
        x = x - self.width/2
        y = y - self.height/2
    end

    x = math.floor(x + 0.5)
    y = math.floor(y + 0.5)

    love.graphics.setColor(self.color)
    love.graphics.draw(self.image, x, y, self.rotation, self.scale.x, self.scale.y, self.offset.x, self.offset.y)
end

function Sprite:calculateSize()
    local width = self.image:getWidth() * math.abs(self.scale.x)
    local height = self.image:getHeight() * math.abs(self.scale.y)

    return width, height
end

function Sprite:setPosition(x, y)
    self.position.x = x  
    self.position.y = y  
end

function Sprite:setScale(x, y)
    self.scale.x = x  
    self.scale.y = y  
end

function Sprite:setCentered(value)
    self.centered = value
end

return Sprite
