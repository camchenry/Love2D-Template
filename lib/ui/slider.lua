Slider = class("Slider")

function Slider:initialize(text, min, max, value, x, y, w, h, fontSize)
    self.text = text
    self.originalText = text
    self.font = fontSize or font[32]
    self.x = x
    self.y = y
    self.width = w
    self.height = h or 75

    self.value = value or max
    self.min = min
    self.max = max
    self.ratio = ((value - min) / ( max - min )) or 1 -- works for more values

    self.active = {127, 127, 127}
    self.bg = {255, 255, 255, 0}
    self.fg = {255, 255, 255, 255}
	
	self.sliderWidth = 8

    self.translateX = 0

    self.click = Slider.click
    self.selected = false
	self.roundTo = 1
	
	-- lines up the box based on the width of the slider
	self.x = self.x - self.sliderWidth/2+1
	self.width = self.width + self.sliderWidth-2

    self.activated = activated or function() end
end

function Slider:mousepressed(x, y, mbutton)
    if self:hover() and mbutton == 1 then
        self.ratio = (x-self.x)/(self.width)
		signal.emit('uiClick')

        if self.changed then
            self:changed()
        end
    end

    if love.mouse.isDown(1) and self:hover() then
        self.dragging = true
    end
end

function Slider:update(dt)
    if not love.mouse.isDown(1) then
        self.dragging = false
    end

    local x = love.mouse.getX()
    if self.dragging then
        self.ratio = (x-self.x)/(self.width)

        if self.changed then
            self:changed()
        end
    end

    local r = self.ratio*self.max
    if r > self.max then
        self.ratio = 1
    elseif r < self.min then
        self.ratio = 0
    end

	-- error here
    --self.value = math.ceil(self.ratio * (self.max - self.min) * 1/self.roundTo + self.min) * self.roundTo
	local value = self.ratio * (self.max - self.min) + self.min -- does not round
	--value = math.ceil(value / self.roundTo) * self.roundTo
	if self.roundTo == 1 then
		value = math.ceil(value)
	else
		value = tonumber(string.format("%.1f", value)) -- bug: only works for 1 decimal place
	end
	self.value = value

    self.text = self.originalText .. " (" .. tostring(value) .. ")"
end

function Slider:draw()
    local r, g, b, a = love.graphics.getColor()
    local oldColor = {r, g, b, a}

	local sliderWidth = self.sliderWidth
	
    love.graphics.setColor(self.bg)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    if self.dragging then
        love.graphics.setColor(self.active)
    else
        love.graphics.setColor(200, 200, 200)
    end

	-- negate earlier changes to width and height
	local x = self.x + self.sliderWidth/2-1
	local width = self.width - self.sliderWidth+2
	
    love.graphics.setLineWidth(sliderWidth)
    love.graphics.line(x+width*self.ratio, self.y+1, 
                       x+width*self.ratio, self.y+self.height-1)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(self.fg)
    love.graphics.setFont(self.font)
    local text = string.format(self.text, self.value)
    local x = self.x + self.width/2 - self.font:getWidth(text)/2
    local y = self.y + self.height/2 - self.font:getHeight(text)/2
	x, y = math.floor(x), math.floor(y)
    love.graphics.print(text, x, y)

    love.graphics.setColor(oldColor)
end

function Slider:setActive(r, g, b, a)
    self.active = {r, g, b, a or 255}
    return self
end

function Slider:setBG(r, g, b, a)
    self.bg = {r, g, b, a or 255}
    return self
end

function Slider:setFG(r, g, b, a)
    self.fg = {r, g, b, a or 255}
    return self
end

function Slider:centerAround(x, y)
    self.x = x - self.width/2
    self.y = y - self.height/2
    return self
end

-- returns whether or not the mouse is currently over the button
function Slider:hover()
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local inX = mx >= self.x and mx <= self.x + self.width
    local inY = my >= self.y and my <= self.y + self.height
    return inX and inY
end