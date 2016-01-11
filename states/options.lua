options = {}
-- this is out here because it needs to be accessible before options:init() is called
options.file = 'config.txt'

function options:init()
	self.leftAlign = 75
	self.optionWidth = 130
	self.bottomMargin = 70
	self.listWidth = 400
	self.listOptionWidth = 130
	self.elements = {}
end

function options:add(obj)
	table.insert(self.elements, obj)
	return obj
end

function options:enter()
	local config = nil
	if not love.filesystem.exists(self.file) then
		config = self:getDefaultConfig()
	else
		config = self:getConfig()
	end

	self.elements = {}
	self.y = 225
	self.dy = 45

	-- Takes all available resolutions
	local resTable = love.window.getFullscreenModes(1)
	local resolutions = {}
	for k, res in pairs(resTable) do
		if res.width > 800 then -- cuts off any resolutions with a width under 800
			table.insert(resolutions, {res.width, res.height})
		end
	end

	-- sort resolutions from smallest to biggest
	table.sort(resolutions, function(a, b) return a[1]*a[2] < b[1]*b[2] end)

	local msaaOptions = {0, 2, 4, 8}
	-- data table for creating the lists
	-- the short name turns into the key for the list object that can be accessed through self
	-- e.g. "resolution" creates: self.resolution (instance of List)
	--  Title               Short name      Display     Options      Selected (current setting)
	local lists = {
		{"RESOLUTION", 		"resolution", 	'{1}x{2}', 	resolutions, {config.display.width, config.display.height}},
		{"ANTIALIASING",	"msaa", 		'{}x', 		msaaOptions, config.display.flags.msaa},
	}

	for k, val in pairs(lists) do
		local title, name, display, list, initial = val[1], val[2], val[3], val[4], val[5]

		self[name] = self:add(List:new(title, list, initial, self.leftAlign, self.y, self.listWidth))
		self[name]:setText(display)
		self[name]:setOptionWidth(self.listOptionWidth)

		self.y = self.y + self.dy
	end

	self.y = 335
	self.dy = 45

	-- data table for creating the checkboxes
	-- the short name turns into the key for the checkbox object that can be accessed through self
	-- e.g. "vsync" creates: self.vsync (instance of Checkbox)
	--  Title               Short name      Selected (current setting)
	local checkboxes = {
		{"FULLSCREEN", 		"fullscreen", 	config.display.flags.fullscreen},
		{"VERTICAL SYNC", 	"vsync", 		config.display.flags.vsync},
		{"BORDERLESS", 		"borderless", 	config.display.flags.borderless},
	}

	for k, val in pairs(checkboxes) do
		local title, name, flag = val[1], val[2], val[3]

		self[name] = self:add(Checkbox:new(title, self.leftAlign, self.y))
		self[name].selected = flag

		self.y = self.y + self.dy
	end
	
	local y = love.graphics.getHeight() - self.bottomMargin
	self.back = self:add(Button:new("< BACK", self.leftAlign, y))
	self.back.activated = function()
		state.switch(menu)
	end

	self.apply = self:add(Button:new('APPLY CHANGES', self.leftAlign+170, y))
	self.apply.activated = function ()
		self:applyChanges()
		self.back.y = love.graphics.getHeight()-self.bottomMargin
		self.apply.y = love.graphics.getHeight()-self.bottomMargin
	end
end

function options:applyChanges()
    self:save()
    self:load()
end

function options:update(dt)
	for i, element in ipairs(self.elements) do
		element:update(dt)
	end
end

function options:mousepressed(x, y, button)
	for i, element in ipairs(self.elements) do
		element:mousepressed(x, y, button)
	end
end

function options:keypressed(key)
	if key == "escape" then
		state.switch(menu)
	end
end

function options:draw()
    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(255, 255, 255)
    love.graphics.print('OPTIONS', 75, 70)

    for i, element in ipairs(self.elements) do
		element:draw()
	end
end

function options:getDefaultConfig()
	local o = {
		display = {
			width = 1280,
			height = 720,

			-- these are the standard flags for love.window.setMode
			flags = {
				vsync = false,
				fullscreen = false,
				borderless = false,
				msaa = 0,
			},
		},
		graphics = {

		},
	}
	return o
end

function options:save(conf)
	if conf == nil then
		 conf = {
			display = {
				width = self.resolution.options[self.resolution.selected][1],
				height = self.resolution.options[self.resolution.selected][2],

				-- these are the standard flags for love.window.setMode
				flags = {
					vsync = self.vsync.selected,
					fullscreen = self.fullscreen.selected,
					borderless = self.borderless.selected,
					msaa = self.msaa.options[self.msaa.selected],
				},
			},
			graphics = {

			},
		}
	end
	love.filesystem.write(self.file, serialize(conf))
end

function options:load()
	local config = self:getConfig()
	
	love.window.setMode(config.display.width, config.display.height, config.display.flags)

	return true
end

function options:getConfig()
	assert(love.filesystem.exists(self.file), 'Tried to load config file, but it does not exist.')
	return love.filesystem.load(self.file)()
end