-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !! This flag controls the ability to toggle the debug view.         !!
-- !! You will want to turn this to 'true' when you publish your game. !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
RELEASE = false

-- Enables the debug stats
DEBUG = not RELEASE

CONFIG = {
    graphics = {
        filter = {
            -- FilterModes: linear (blurry) / nearest (blocky)
            -- Default filter used when scaling down
            down = "nearest",

            -- Default filter used when scaling up
            up = "nearest",

            -- Amount of anisotropic filter performed
            anisotropy = 1,
        }
    },

    window = {
        icon = 'assets/images/icon.png'
    },

    debug = {
        -- The key (scancode) that will toggle the debug state.
        -- Scancodes are independent of keyboard layout so it will always be in the same
        -- position on the keyboard. The positions are based on an American layout.
        key = '`',

        stats = {
            font            = nil, -- set after fonts are created
            fontSize        = 16,
            lineHeight      = 18,
            foreground      = {255, 255, 255, 225},
            shadow          = {0, 0, 0, 225}, 
            shadowOffset    = {x = 1, y = 1},
            position        = {x = 8, y = 6},

            kilobytes = false,
        },

        -- Error screen config
        error = {
            font            = nil, -- set after fonts are created
            fontSize        = 16,
            background      = {26, 79, 126},
            foreground      = {255, 255, 255},
            shadow          = {0, 0, 0, 225}, 
            shadowOffset    = {x = 1, y = 1},
            position        = {x = 70, y = 70},
        },

        lovebird = {
            port = 8000,
            wrapPrint = true,
            echoInput = true,
            updateInterval = 0.2,
            maxLines = 200,
            openInBrowser = false,
        }
    }
}

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

    regular         = makeFont 'assets/fonts/Roboto-Regular.ttf',
    bold            = makeFont 'assets/fonts/Roboto-Bold.ttf',
    light           = makeFont 'assets/fonts/Roboto-Light.ttf',
    thin            = makeFont 'assets/fonts/Roboto-Thin.ttf',
    regularItalic   = makeFont 'assets/fonts/Roboto-Italic.ttf',
    boldItalic      = makeFont 'assets/fonts/Roboto-BoldItalic.ttf',
    lightItalic     = makeFont 'assets/fonts/Roboto-LightItalic.ttf',
    thinItalic      = makeFont 'assets/fonts/Roboto-Italic.ttf',

    monospace       = makeFont 'assets/fonts/RobotoMono-Regular.ttf',
}
Fonts.default = Fonts.regular

CONFIG.debug.stats.font = Fonts.monospace
CONFIG.debug.error.font = Fonts.monospace
