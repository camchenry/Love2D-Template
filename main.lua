require 'globals'

lume    = require 'libs.lume'
husl    = require 'libs.husl'
Class   = require 'libs.middleclass'
Vector  = require 'libs.vector'
State   = require 'libs.state'
Signal  = require 'libs.signal'
Flux    = require 'libs.flux'
Cron    = require 'libs.cron'
Inspect = require 'libs.inspect'

require 'states'
require 'entities'

function love.load()
    local function makeFont(path)
        return setmetatable({}, {
            __index = function(t, size)
                local f = love.graphics.newFont(path, size)
                rawset(t, size, f)
                return f
            end 
        })
    end

    Fonts = {
        default = nil,
        monoDefault = nil,

        regular = makeFont 'assets/fonts/OpenSans-Regular.ttf',
        bold    = makeFont 'assets/fonts/OpenSans-Bold.ttf',
        light   = makeFont 'assets/fonts/OpenSans-Light.ttf',
        mono    = makeFont 'assets/fonts/SourceCodePro-Regular.ttf',
    }
    Fonts.default = Fonts.regular
    Fonts.monoDefault = Fonts.mono

    love.window.setIcon(love.image.newImageData('assets/images/icon.png'))
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(Fonts.default[14])

    -- Draw is left out so we can override it ourselves
    local callbacks = {'errhand', 'update'}
    for k in pairs(love.handlers) do
        callbacks[#callbacks+1] = k
    end
    State.registerEvents(callbacks)
    State.switch(menu)
end

function love.update(dt)
    Flux.update(dt)
end

function love.draw()
    State.current():draw()

    if DEBUG then
        love.graphics.push()
        love.graphics.setFont(Fonts.mono[14])
        local stats = love.graphics.getStats()
        local info = {
            "FPS: " .. love.timer.getFPS(),
            "RAM: " .. lume.round(collectgarbage("count")/1024, .1) .. "MB",
        }
        if DETAILED_DEBUG then
            lume.push(info,
                "DRW: " .. stats.drawcalls,
                "TEX: " .. lume.round(stats.texturememory / 1024 / 1024, .01) .. "MB",
                "IMG#: " .. stats.images,
                "FNT#: " .. stats.fonts,
                "CVS#: " .. stats.canvases
            )
        end
        for i, text in ipairs(info) do
            love.graphics.print(text, 5, 2 + (i-1)*15)
        end
        love.graphics.pop()
    end
end

function love.keyreleased(key, code, isRepeat)
    if key == "escape" and love.keyboard.isDown("lctrl", "rctrl") then
        love.event.quit()
    end

    if key == "`" then
        if love.keyboard.isDown("lshift", "rshift") then
            DETAILED_DEBUG = not DETAILED_DEBUG
        else
            DEBUG = not DEBUG
        end
    end
end

function love.keypressed(key, code, isRepeat)

end

function love.mousepressed(x, y, button, isTouch)

end

function love.mousereleased(x, y, button, isTouch)

end

function love.mousefocus(hasFocus)

end

function love.mousemoved(x, y, dx, dy, isTouch)

end

function love.wheelmoved(x, y)

end

function love.textinput(text)

end

function love.threaderror(thread, errorMessage)
    print("Thread error!\n" .. errorMessage)
end

function love.touchmoved(id, x, y, dx, dy, pressure)

end

function love.touchpressed(id, x, y, dx, dy, pressure)

end

function love.touchreleased(id, x, y, dx, dy, pressure)

end

function love.resize(width, height)

end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

-- The default error handler with some minor changes
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
    end
    if love.joystick then
        -- Stop all joystick vibrations.
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    -- MODIFIED: Changed to use a nice monospaced font
    local size = math.floor(love.window.toPixels(14))
    if Fonts and Fonts.monoDefault then
        love.graphics.setFont(Fonts.monoDefault[size])
    else
        love.graphics.setNewFont(size)
    end

    love.graphics.setBackgroundColor(17, 59, 84)
    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, msg.."\n\n")

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    local function draw()
        local pos = love.window.toPixels(70)
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
        love.graphics.present()
    end

    while true do
        love.event.pump()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return
            elseif e == "keypressed" and a == "escape" then
                return
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttons = {"OK", "Cancel"}
                local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
                if pressed == 1 then
                    return
                end
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end

end
