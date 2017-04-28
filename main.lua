local loadTimeStart = love.timer.getTime()
require 'globals'

Lume    = require 'libs.lume'
Husl    = require 'libs.husl'
Class   = require 'libs.class'
Vector  = require 'libs.vector'
State   = require 'libs.state'
Signal  = require 'libs.signal'
Inspect = require 'libs.inspect'
Camera  = require 'libs.camera'
Timer   = require 'libs.timer'

if DEBUG then
    Lovebird = require 'libs.lovebird'
    Lovebird.port = CONFIG.debug.lovebird.port
    Lovebird.wrapprint = CONFIG.debug.lovebird.wrapPrint
    Lovebird.echoinput = CONFIG.debug.lovebird.echoInput
    Lovebird.updateinterval = CONFIG.debug.lovebird.updateInterval
    Lovebird.maxlines = CONFIG.debug.lovebird.maxLines
    print('Running lovebird on localhost:' .. Lovebird.port)
    if CONFIG.debug.lovebird.openInBrowser then
        love.system.openURL("http://localhost:" .. Lovebird.port)
    end
end

States = {
    menu = require 'states.menu',
    game = require 'states.game',
}

function love.load()
    love.window.setIcon(love.image.newImageData(CONFIG.window.icon))
    love.graphics.setDefaultFilter(CONFIG.graphics.filter.down, 
                                   CONFIG.graphics.filter.up, 
                                   CONFIG.graphics.filter.anisotropy)

    -- Draw is left out so we can override it ourselves
    local callbacks = {'errhand', 'update'}
    for k in pairs(love.handlers) do
        callbacks[#callbacks+1] = k
    end

    State.registerEvents(callbacks)
    State.switch(States.menu)

    if DEBUG then
        local loadTimeEnd = love.timer.getTime()
        local loadTime = (loadTimeEnd - loadTimeStart)
        print(("Loaded game in %.3f seconds."):format(loadTime))
        Lovebird.print(("Loaded game in %.3f seconds."):format(loadTime))
    end
end

function love.update(dt)
    if DEBUG and Lovebird then
        Lovebird.update(dt)
    end
end

function love.draw()
    local drawTimeStart = love.timer.getTime()
    State.current():draw()
    local drawTimeEnd = love.timer.getTime()
    local drawTime = drawTimeEnd - drawTimeStart

    if DEBUG then
        love.graphics.push()
        local x, y = CONFIG.debug.stats.position.x, CONFIG.debug.stats.position.y
        local dy = CONFIG.debug.stats.lineHeight
        local stats = love.graphics.getStats()
        local memoryUnit = "KB"
        local ram = collectgarbage("count")
        local vram = stats.texturememory / 1024
        if not CONFIG.debug.stats.kilobytes then
            ram = ram / 1024
            vram = vram / 1024
            memoryUnit = "MB"
        end
        local info = {
            "FPS: " .. ("%3d"):format(love.timer.getFPS()),
            "DRAW: " .. ("%7.3fms"):format(Lume.round(drawTime * 1000, .001)),
            "RAM: " .. string.format("%7.2f", Lume.round(ram, .01)) .. memoryUnit,
            "VRAM: " .. string.format("%6.2f", Lume.round(vram, .01)) .. memoryUnit,
            "Draw calls: " .. stats.drawcalls,
            "Images: " .. stats.images,
            "Canvases: " .. stats.canvases,
            "\tSwitches: " .. stats.canvasswitches,
            "Shader switches: " .. stats.shaderswitches,
            "Fonts: " .. stats.fonts,
        }
        love.graphics.setFont(CONFIG.debug.stats.font[CONFIG.debug.stats.fontSize])
        for i, text in ipairs(info) do
            local sx, sy = CONFIG.debug.stats.shadowOffset.x, CONFIG.debug.stats.shadowOffset.y
            love.graphics.setColor(CONFIG.debug.stats.shadow)
            love.graphics.print(text, x + sx, y + sy + (i-1)*dy)
            love.graphics.setColor(CONFIG.debug.stats.foreground)
            love.graphics.print(text, x, y + (i-1)*dy)
        end
        love.graphics.pop()
    end
end

function love.keypressed(key, code, isRepeat)
    if not RELEASE and code == CONFIG.debug.key then
        DEBUG = not DEBUG
    end
end

function love.threaderror(thread, errorMessage)
    print("Thread error!\n" .. errorMessage)
end

-----------------------------------------------------------
-- Error screen.
-----------------------------------------------------------

local debug, print = debug, print

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.hasCursor() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
    local size = math.floor(love.window.toPixels(CONFIG.debug.error.fontSize))
    love.graphics.setFont(CONFIG.debug.error.font[size])

	love.graphics.setBackgroundColor(CONFIG.debug.error.background)
	love.graphics.setColor(CONFIG.debug.error.foreground)

	local trace = debug.traceback()

	love.graphics.clear(love.graphics.getBackgroundColor())
	love.graphics.origin()

	local err = {}

	table.insert(err, "Error")
	table.insert(err, "-------\n")
	table.insert(err, msg.."\n\n")

    local i = 0
	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
            local firstLine = string.match(l, "stack traceback:")
			l = string.gsub(l, "stack traceback:", "Traceback")

            if not firstLine then
                l = ">  " .. l
            end

			table.insert(err, l)

            if firstLine then
                table.insert(err, "-----------\n")
            end
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
        local x, y = love.window.toPixels(CONFIG.debug.error.position.x), love.window.toPixels(CONFIG.debug.error.position.y)
		love.graphics.clear(love.graphics.getBackgroundColor())
        local sx, sy = CONFIG.debug.error.shadowOffset.x, CONFIG.debug.error.shadowOffset.y
        love.graphics.setColor(CONFIG.debug.error.shadow)
		love.graphics.printf(p, x + sx, y + sy, love.graphics.getWidth() - x)
        love.graphics.setColor(CONFIG.debug.error.foreground)
		love.graphics.printf(p, x, y, love.graphics.getWidth() - x)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
		draw()
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end
