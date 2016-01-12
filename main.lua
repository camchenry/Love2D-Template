-- libraries
class = require 'libs.middleclass'
vector = require 'libs.vector'
state = require 'libs.state'
tween = require 'libs.tween'
serialize = require 'libs.ser'
signal = require 'libs.signal'
require 'libs.util'

-- gamestates
require 'states.menu'
require 'states.game'
require 'states.options'

-- ui
require 'libs.ui.button'
require 'libs.ui.checkbox'
require 'libs.ui.input'
require 'libs.ui.list'
require 'libs.ui.slider'

function love.load()
	love.window.setTitle(config.windowTitle)
    love.window.setIcon(love.image.newImageData(config.windowIcon))
	love.graphics.setDefaultFilter(config.filterModeMin, config.filterModeMax)
    love.graphics.setFont(font[16])

    state.registerEvents()
    state.switch(menu)

    math.randomseed(os.time()/10)

    if not love.filesystem.exists("config.txt") then
        options:save(options:getDefaultConfig())
    end

    options:load()
end

function love.keypressed(key, code)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, mbutton)
    
end

function love.textinput(text)

end

function love.resize(w, h)

end

function love.update(dt)
    tween.update(dt)
end

function love.draw()

end