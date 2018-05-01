local loadTimeStart = love.timer.getTime()

require 'globals'

function love.load()
    love.window.setIcon(love.image.newImageData(CONFIG.window.icon))
    love.graphics.setDefaultFilter(CONFIG.graphics.filter.down,
                                   CONFIG.graphics.filter.up,
                                   CONFIG.graphics.filter.anisotropy)

    -- Draw is left out so we can override it ourselves
    local callbacks = {'update'}
    for k in pairs(love.handlers) do
        callbacks[#callbacks+1] = k
    end

    State.registerEvents(callbacks)
    State.switch(States.game)

    if DEBUG then
        local loadTimeEnd = love.timer.getTime()
        local loadTime = (loadTimeEnd - loadTimeStart)
        print(("Loaded game in %.3f seconds."):format(loadTime))
    end
end

function love.update(dt)

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

local utf8 = require("utf8")

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
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
        if love.mouse.isCursorSupported() then
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
    local font = CONFIG.debug.error.font[size]
    love.graphics.setFont(font)

    love.graphics.setColor(CONFIG.debug.error.foreground)

    local trace = debug.traceback()

    love.graphics.origin()

    local sanitizedmsg = {}
    for char in msg:gmatch(utf8.charpattern) do
        table.insert(sanitizedmsg, char)
    end
    sanitizedmsg = table.concat(sanitizedmsg)

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, sanitizedmsg)

    if #sanitizedmsg ~= #msg then
        table.insert(err, "Invalid UTF-8 string in error message.")
    end

    table.insert(err, "\n")

    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = p:gsub("\t", "")
    p = p:gsub("%[string \"(.-)\"%]", "%1")

    local max_text_width = love.graphics.getWidth() - love.window.toPixels(CONFIG.debug.error.position.x)
    local _, lines = font:getWrap(p, max_text_width)
    local max_translate_y = (#lines + 8) * font:getHeight()
    local translate_y = 0
    local translate_vy = 0
    local translate_ay = 0

    local function draw()
        local x, y = love.window.toPixels(CONFIG.debug.error.position.x), love.window.toPixels(CONFIG.debug.error.position.y)
        love.graphics.clear(CONFIG.debug.error.background)
        local sx, sy = CONFIG.debug.error.shadowOffset.x, CONFIG.debug.error.shadowOffset.y
        love.graphics.setColor(CONFIG.debug.error.shadow)
        love.graphics.printf(p, x + sx, y + sy, love.graphics.getWidth() - x)
        love.graphics.setColor(CONFIG.debug.error.foreground)
        love.graphics.printf(p, x, y, love.graphics.getWidth() - x)

        if math.abs(translate_vy) > 4 then
            love.graphics.push()
            love.graphics.translate(0, -translate_y)
            local bar_width = 8
            local bar_height = love.graphics.getHeight()^2 / max_translate_y
            local bar_y = -translate_y / max_translate_y * love.graphics.getHeight()
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.rectangle('fill', love.graphics.getWidth() - bar_width - 1, bar_y, bar_width, bar_height, 2, 2)
            love.graphics.pop()
        else
            love.graphics.push()
            love.graphics.translate(0, -translate_y)
            local bar_width = 8
            local bar_height = love.graphics.getHeight()^2 / max_translate_y
            local bar_y = -translate_y / max_translate_y * love.graphics.getHeight()
            love.graphics.setColor(1, 1, 1, Lume.clamp(math.abs(translate_vy)/4, 0, 0.5))
            love.graphics.rectangle('fill', love.graphics.getWidth() - bar_width - 1, bar_y, bar_width, bar_height, 2, 2)
            love.graphics.pop()
        end

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

    local is_clicked = false

    return function()
        love.event.pump()

        for e, a, b, c, d in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" and a == "escape" then
                return 1
            elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
                copyToClipboard()
            elseif e == "mousepressed" and c == 1 then
                is_clicked = true
            elseif e == "mousereleased" and c == 1 then
                is_clicked = false
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttons = {"OK", "Cancel"}
                if love.system then
                    buttons[3] = "Copy to clipboard"
                end
                local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
                if pressed == 1 then
                    return 1
                elseif pressed == 3 then
                    copyToClipboard()
                end
            elseif e == "mousemoved" and is_clicked then
                translate_ay = d * 100 * math.sqrt((1+ math.abs(translate_vy)))
            elseif e == "wheelmoved" then
                translate_ay = b * 2000 * math.sqrt((1+ math.abs(translate_vy)))
            end
        end

        if max_translate_y > love.graphics.getHeight() then
            local dt = 0.016
            translate_vy = translate_vy + translate_ay * dt
            translate_vy = translate_vy * 0.9
            translate_y = translate_y + translate_vy * dt
            if translate_y > 0 then
                translate_y = 0
            end
            local max_scroll_y = -max_translate_y + love.graphics.getHeight()
            if translate_y < max_scroll_y then
                translate_y = max_scroll_y
            end
            translate_ay = 0
        end

        love.graphics.translate(0, translate_y)
        draw()
        love.graphics.origin()

        if love.timer then
            love.timer.sleep(0.016)
        end
    end
end
