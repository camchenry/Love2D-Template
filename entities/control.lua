local baton = {
    _VERSION = 'baton',
    _DESCRIPTION = 'Input library for LÖVE.',
    _URL = 'https://github.com/tesselode/baton',
    _LICENSE = [[
    MIT License

    Copyright (c) 2016 Andrew Minnich

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}

local sourceFunction = {}

function sourceFunction.key(k)
    return function()
        return love.keyboard.isDown(k) and 1 or 0, 'keyboard'
    end
end

function sourceFunction.sc(sc)
    return function()
        return love.keyboard.isScancodeDown(sc) and 1 or 0, 'keyboard'
    end
end

function sourceFunction.axis(value)
    local axis, direction = value:match '(.+)%s*([%+%-])'
    if direction == '+' then direction = 1 end
    if direction == '-' then direction = -1 end
    return function(self)
        if self.joystick then
            local v = tonumber(axis) and self.joystick:getAxis(tonumber(axis))
            or self.joystick:getGamepadAxis(axis)
            v = v * direction
            return v > self.deadzone and (v - self.deadzone)/(1 - self.deadzone) or 0, 'joystick'
        end
        return 0, 'joystick'
    end
end

function sourceFunction.button(button)
    return function(self)
        if self.joystick then
            if tonumber(button) then
                return self.joystick:isDown(tonumber(button)) and 1 or 0, 'joystick'
            else
                return self.joystick:isGamepadDown(button) and 1 or 0, 'joystick'
            end
        end
        return 0, 'joystick'
    end
end

local Control = Class("Control")

function Control:initialize(controls, joystick)
    self._controls = {}
    self.joystick = joystick
    self.deadzone = 0.3
    self:setControls(controls)
end

function Control:_addControl(name, sources)
    self._controls[name] = {
        value = 0,
        downCurrent = false,
        downPrevious = false,
    }
    self:_setSources(name, sources)
end

function Control:_setSources(controlName, sources)
    self._controls[controlName].sources = {}
    for i = 1, #sources do
        local type, value = sources[i]:match '(.+)%s*:%s*(.+)'
        table.insert(self._controls[controlName].sources,
                     sourceFunction[type](value))
    end
end

function Control:setControls(controls)
    for name, sources in pairs(controls) do
        if self._controls[name] then
            self:_setSources(name, sources)
        else
            self:_addControl(name, sources)
        end
    end
end

function Control:update()
    for _, control in pairs(self._controls) do
        control.value = 0
        for i = 1, #control.sources do
            local v, type = control.sources[i](self)
            if v ~= 0 then
                control.value = control.value + v
                self.lastUsed = type
            end
        end
        if control.value > 1 then control.value = 1 end

        control.downPrevious = control.downCurrent
        control.downCurrent = control.value > 0
    end
end

function Control:get(control)
    return self._controls[control].value
end
function Control:down(control)
    return self._controls[control].downCurrent
end
function Control:pressed(control)
    local c = self._controls[control]
    return c.downCurrent and not c.downPrevious
end
function Control:released(control)
    local c = self._controls[control]
    return c.downPrevious and not c.downCurrent
end

return Control
