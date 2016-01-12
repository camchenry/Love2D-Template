Checkbox = class('Checkbox')

function Checkbox:initialize(text, x, y, w, h, fontSize, activated, deactivated)
	self.text = text
	self.font = fontSize or font[22]
	self.x = x
	self.y = y -- This centers it on the line
	self.width = w or 32
	self.height = h or 32
	
	self.textHeight = self.font:getHeight(self.text)
	
	self.color = {255, 255, 255}
	self.active = {255, 255, 255}
	self.hoverColor = {127, 127, 127}
	self.textColor = {255, 255, 255}
	
	self.selected = false
	self.alreadyHovering = false
	
	self.activated = activated or function() end
	self.deactivated = deactivated or function() end
end

function Checkbox:update(dt)
	if self:hover() and not self.alreadyHovering then
        signal.emit('uiHover')
        self.alreadyHovering = true
    elseif not self:hover() then
        self.alreadyHovering = false
    end
end

function Checkbox:draw()
	local oldColor = {love.graphics.getColor()}
	local oldFont = love.graphics.getFont()
	love.graphics.setFont(self.font)
	
	if self.selected then
		love.graphics.setColor(self.active)
	else
		love.graphics.setColor(self.color)
	end
	
	local x = self.x
	local y = self.y - self.height/2
	
	love.graphics.rectangle("line", x, y, self.width, self.height)

	if self.selected then
		local margin = 5
		love.graphics.rectangle("fill", self.x+margin, y+margin, self.width-margin*2, self.height-margin*2)
	end

	if self:hover() then
        love.graphics.setColor(self.hoverColor)
	else
		love.graphics.setColor(self.textColor)
    end

	local textWidth = self.font:getWidth(self.text)
	local textX = math.floor(x + self.width + 10)
	local textY = math.floor(self.y - self.textHeight/2)
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, textX, textY)
	
	love.graphics.setColor(oldColor)
	love.graphics.setFont(oldFont)
end

function Checkbox:hover(x, y)
	if x == nil then x = love.mouse.getX() end
	if y == nil then y = love.mouse.getY() end
	local xBoundMax = self.x + self.width + 10 + self.font:getWidth(self.text)
	local xBoundMin = self.x
	local yBoundMax = self.y + self.height/2
	local yBoundMin = self.y - self.height/2

	return x >= xBoundMin and x <= xBoundMax  and y >= yBoundMin and y <= yBoundMax
end

function Checkbox:mousepressed(x, y, button)
	if self:hover(x, y) then
		-- toggle selected state
		self.selected = not self.selected

		if self.selected then
			self.activated()
		else
			self.deactivated()
		end

		signal.emit('uiClick')
	end
end