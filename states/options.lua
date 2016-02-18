options = {}
-- this is out here because it needs to be accessible before options:init() is called
options.file = 'config.txt'
options.version = 1

function options:init()
	self.alwaysUsableElements = {}
	self.elements = {}
	self.currentPanel = 1

	self.leftAlign = 75
	self.optionWidth = 130
	self.bottomMargin = 70
	self.listWidth = 400
	self.listOptionWidth = 130

	self.tabsY = 160
	self.tabSpacing = 35

	self.minWidth = 1279 -- any resolutions narrower than this are excluded
end

function options:add(obj, panel)
	panel = panel or 1
	if self.elements[panel] == nil then
		self.elements[panel] = {}
	end
	table.insert(self.elements[panel], obj)
	return obj
end

function options:alwaysUsableAdd(obj)
	table.insert(self.alwaysUsableElements, obj)
	return obj
end

function options:enter()
	self.currentPanel = 1

	local config = nil
	if not love.filesystem.exists(self.file) then
		config = self:getDefaultConfig()
	else
		config = self:getConfig()
	end

	self.tabs = {"GRAPHICS", "AUDIO", "CONTROLS", "ACCESSIBILITY"}

	local resolutions = self:getResolutions()
	local msaaOptions = {0, 2, 4, 8}

	self.elements = {}
	for i, tab in ipairs(self.tabs) do
		self.elements[i] = {}
	end
	self.alwaysUsableElements = {}
	-- data table for creating ui elements
	-- the indexes correspond with the tabs
	self.items = {
		{
			y = 250,
			dy = 45,

			-- the short name turns into the key for the list object that can be accessed through self
			-- e.g. "resolution" creates: self.resolution (instance of the object)
			outline = {
				{List, 		"RESOLUTION", 		"resolution", 	'{1}x{2}', 	resolutions, {config.display.width, config.display.height}},
				{List, 		"ANTIALIASING",		"msaa", 		'{}x', 		msaaOptions, config.display.flags.msaa},
				{Checkbox, 	"FULLSCREEN", 		"fullscreen", 	config.display.flags.fullscreen},
				{Checkbox, 	"VERTICAL SYNC", 	"vsync", 		config.display.flags.vsync},
				{Checkbox, 	"BORDERLESS", 		"borderless", 	config.display.flags.borderless},
			},
		},

		{
			y = 250,
			dy = 45,

			outline = {
				{Slider, 	"SOUND VOLUME", 	"soundVolume", 0, 100, config.audio.soundVolume},
			},
		},
	}

	-- how to handle adding a ui element to an options panel
	self.handling = {
		-- panel: index of the current panel
		-- y: y value of the ui element
		-- args: a table of all the data needed to make the ui element
		-- args[1] = the class (List, Checkbox, ...)

		[List] = function(panel, y, args)
			local title, name, display, list, initial = args[2], args[3], args[4], args[5], args[6]

			self[name] = self:add(List:new(title, list, initial, self.leftAlign, y, self.listWidth), panel)
			self[name]:setText(display)
			self[name]:setOptionWidth(self.listOptionWidth)
		end,

		[Checkbox] = function(panel, y, args)
			local title, name, flag = args[2], args[3], args[4]

			self[name] = self:add(Checkbox:new(title, self.leftAlign, y), panel)
			self[name].selected = flag
		end,

		[Slider] = function(panel, y, args)
			local title, name, min, max, value = args[2], args[3], args[4], args[5], args[6]

			self[name] = self:add(Slider:new(title, min, max, value, self.leftAlign, y, 400), panel)
			self[name].changed = function()
				signal.emit(name .. 'Changed', self[name].value)
			end
		end,
	}
	
	for panel, panelItems in ipairs(self.items) do
		local y = panelItems.y
		local dy = panelItems.dy

		for i, args in ipairs(panelItems.outline) do
			self.handling[args[1]](panel, y, args)

			y = y + dy
		end
	end

	-- Buttons to switch tabs
	local prevWidth = 0
	for i, tabName in ipairs(self.tabs) do
		local b = self:alwaysUsableAdd(Button:new(tabName, self.leftAlign + self.tabSpacing * (i-1) + prevWidth, self.tabsY, nil, nil, fontLight[24]))
		b.activated = function()
			self.currentPanel = i
		end
		prevWidth = b.width + prevWidth
	end
	
	local y = love.graphics.getHeight() - self.bottomMargin
	self.back = self:alwaysUsableAdd(Button:new("< BACK", self.leftAlign, y))
	self.back.activated = function()
		state.switch(menu)
	end

	self.apply = self:alwaysUsableAdd(Button:new('APPLY CHANGES', self.leftAlign+170, y))
	self.apply.activated = function ()
		self:applyChanges()
	end

	signal.register('resolutionChanged', function()
		y = love.graphics.getHeight() - self.bottomMargin
		self.back.y = y
		self.apply.y = y
	end)
end

function options:applyChanges()
    self:save()
    self:load()
end

function options:update(dt)
	for i, element in ipairs(self.elements[self.currentPanel]) do
		element:update(dt)
	end

	for i, element in ipairs(self.alwaysUsableElements) do
		element:update(dt)
	end
end

function options:mousepressed(x, y, button)
	for i, element in ipairs(self.elements[self.currentPanel]) do
		element:mousepressed(x, y, button)
	end

	for i, element in ipairs(self.alwaysUsableElements) do
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

    for i, element in ipairs(self.elements[self.currentPanel]) do
		element:draw()
	end

	for i, element in ipairs(self.alwaysUsableElements) do
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
		audio = {
			soundVolume = 100,
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
			audio = {
				soundVolume = self.soundVolume.value
			},
			graphics = {

			},
		}
	end
	love.filesystem.write(self.file, serialize(conf))
end

function options:load()
	local config = self:getConfig()

	-- old config file
	-- this could be  rewritten to be more clear
	if (config.version == nil) or (self.version > config.version) then
		local newConfig = self:getDefaultConfig()

		-- this will port over old config values to a new config file, based on the default
		-- if there are missing values, it replaces them with the default setting
		for i, category in pairs(newConfig) do
			if type(category) == 'table' then
				for j, value in pairs(category) do
					if config[i][j] == nil then
						config[i][j] = value

					-- table within a table (right now this should only be the window flags)
					elseif type(value) == 'table' then
						for k, flag in pairs(value) do
							if config[i][j][k] == nil then
								config[i][j][k] = flag
							end
						end
					end
				end
			end
		end
	end
	
	love.window.setMode(config.display.width, config.display.height, config.display.flags)
	signal.emit('resolutionChanged')

	return true
end

function options:getConfig()
	assert(love.filesystem.exists(self.file), 'Tried to load config file, but it does not exist.')
	return love.filesystem.load(self.file)()
end

function options:getResolutions()
	-- Takes all available resolutions
	local resTable = love.window.getFullscreenModes(1)
	local resolutions = {}
	for k, res in pairs(resTable) do
		-- cuts off resolutions based on width
		if res.width > self.minWidth then
			table.insert(resolutions, {res.width, res.height})
		end
	end

	-- sort resolutions from smallest to biggest
	table.sort(resolutions, function(a, b) return a[1]*a[2] < b[1]*b[2] end)

	return resolutions
end