List = class('List')

function List:initialize(label, options, initial, x, y, w, h)
	self.x = x
	self.y = y
	self.font = font[22]
	self.margin = 5
	
	self.label = label
	self.text = ''
	self.options = options
	self.selected = 1

	if type(initial) == "table" then
		self:selectTable(initial)
	else
		self:selectValue(initial)
	end
	
	self.longestIndex = self:setLongestIndex() -- arrows 
	
	self.width = w 
	self.height = h or self.font:getHeight()
	self.optionWidth = 120
	self.y = self.y - self.height/2
	
	self.leftButton = Button:new("<", self.x, self.y, nil, nil, fontBold[22])
	self.leftButton.activated = function()
		self:prev()
	end
	self.rightButton = Button:new(">", self.x+self.width, self.y, nil, nil, fontBold[22])
	self.rightButton.activated = function()
		self:next()
	end
	
	self.textSpacing = 0
	self:setTextSpacing()
end

function List:update(dt)
	self.leftButton:update(dt)
	self.rightButton:update(dt)
end

function List:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(self.text, self.textSpacing, self.y) -- formatted to be centered between arrows
	love.graphics.print(self.label, math.floor(self.x), math.floor(self.y))

	self.leftButton:draw()
	self.rightButton:draw()
end

function List:setOptionWidth(optionWidth)
	self.rightButton.x = self.x + self.width
	self.leftButton.x = self.rightButton.x - optionWidth - self.leftButton.font:getWidth(self.leftButton.text) - self.margin*2 -- formatted to be lined up with other list arrows
	
	self.optionWidth = optionWidth
	self:setTextSpacing()
end

function List:setTextSpacing() -- used internally
	love.graphics.setFont(self.font)
	self.textSpacing = self.rightButton.x - love.graphics.getFont():getWidth(self.text)/2 - self.margin - self.optionWidth/2
end

function List:next()
	self.selected = self.selected < #self.options and self.selected + 1 or 1
	self:setText()
	self:setTextSpacing()
end

function List:prev()
	self.selected = self.selected > 1 and self.selected - 1 or #self.options
	self:setText()
	self:setTextSpacing()
end

function List:mousepressed(x, y, button)
	self.leftButton:mousepressed(x, y, button)
	self.rightButton:mousepressed(x, y, button)
end


-- Takes a value, serches for an identical value's index, and selects it
function List:selectValue(value)
	for i = 1, #self.options do
		if value == self.options[i] then
			self.selected = i
		end
	end
end


-- Takes a table and searches through all options. Selects index if a match is found
function List:selectTable(tbl1)
	for i = 1, #self.options do
		local tbl2 = self.options[i]
		
		local clear = true
		for j = 1, #tbl2 do
			if tbl1[j] ~= tbl2[j] then
				clear = false
			end
		end
		
		if clear then
			self.selected = i
			break
		end
	end
end


-- Sets how options are displayed. ex: for resolution, 'val1 x val2', or for antialiasing, 'valx'
function List:setText(text)
	-- if no text given then use the stored value
	if not text then text = self.originalText end

	self.originalText = text
	local longestText = self.originalText

	-- Use val for simple numbered options
	if text:find('{}') then
		text = text:gsub('{}', self.options[self.selected]) 
		longestText = longestText:gsub('{}', self.options[self.longestIndex])
	end

	-- Use val1, 2 etc for table options
	if text:find('{1}') then
		text = text:gsub('{1}', self.options[self.selected][1])
		longestText = longestText:gsub('{1}', self.options[self.longestIndex][1])
	end
	
	if text:find('{2}') then
		text = text:gsub('{2}', self.options[self.selected][2])
		longestText = longestText:gsub('{2}', self.options[self.longestIndex][2])
	end
	
	self.text = text
	--self.width = w or self.longestIndex and self.font:getWidth(longestText)  -- sets width to that of the longest possible width of all options in list
		--or self.font:getWidth(self.text)
end


-- Finds index of the longest possible width
function List:setLongestIndex()
	local longestIndex = nil
	local longest = nil
	for i, option in ipairs(self.options) do
		local len = 0
		
		if type(option) == 'number' then
			len = string.len(tostring(option))
		elseif type(option) == 'table' then
			for j, value in pairs(option) do
				len = len + string.len(tostring(value))
			end
		elseif type(option) == 'string' then
			len = string.len(option)
		end
		
		if not longest then
			longestIndex = i
			longest = len
		elseif len > longest then
			longestIndex = i
			longest = len
		end
	end
	
	if longestIndex and longest then
		return longestIndex
	end
end