

LÖVE Template
=============

This is a simple template for making games with LÖVE. It tries to do as little as possible while still being useful for most types of games (or tools).

## Should you use this template?

This template is primarily for my own personal use and the way that things are setup matches how I tend to write projects.

If you are an absolute novice to LÖVE, it would be in your best interest to become familiar with the basics first before using any templates.

If you are a beginner/intermediate user of LÖVE and you are not sure what libraries to use or how to layout a project, then this may be what you need.

If you are experienced with LÖVE, you probably know enough to make your own template, and you don't need this anyway. On the other hand, it should also be trivial to modify the code to suit your own needs. It is your choice.

## General project guidelines

There are a few guidelines that I follow to keep projects consistent and maintainable.

1. **Modules should be local by default.** 

    This makes it easy to alias the module name. It also keeps the global namespace clean. For further reading: http://kiki.to/blog/2014/03/31/rule-2-return-a-local-table/

    ```lua
    -- theModule.lua
    local theModule = {}
    ...
    return theModule
    ```

    ```lua
    -- Other lua file
    local theModule = require 'theModule'
    ```

2. **Common libraries should be global.**

    If a library is used everywhere, then it might be a good idea to require it globally.

    ```lua
    Class = require 'libs.class'
    ```

3. **Global variables should be put into a file called globals.lua.** 

    Ideally, you do not want many global variables in the global namespace, because it makes it hard to keep track of state. To make things even easier, putting global variables in a single file makes it easier to find where they are defined.

4. **Directories should be plural, where applicable.**

5. **Directories should not be abbreviated.**

    There is no technical justification for these two guidelines, but it makes names easier to remember.
    
## Included libraries

* [inspect.lua](https://github.com/kikito/inspect.lua) (Used as `Inspect`) - A useful debug utility for printing out the contents of tables.
* [HUSL 1.0 (now called HSLuv)](https://github.com/hsluv/hsluv-lua) - Provides an easier and more aesthetically pleasing alternative to RGB for specifying colors.
* [HUMP](https://github.com/vrld/hump)
    * [Camera](http://hump.readthedocs.io/en/latest/camera.html) -  Handles translations, rotation, and scaling.
    * [Class](http://hump.readthedocs.io/en/latest/class.html) - Allows lightweight classes, not a full OOP implementation.
    * [Gamestate](http://hump.readthedocs.io/en/latest/gamestate.html) (Used as `State`) - Creates different states in your game that you can switch between, e.g. menu, game, pause screen, etc.
    * [Signal](http://hump.readthedocs.io/en/latest/signal.html) - Used for broadcasting events, "player killed an enemy," "an item was dropped," "the game has started," which is useful for triggering sounds and effects without tying it to your gameplay code.
    * [Timer](http://hump.readthedocs.io/en/latest/timer.html) - Allows you to create code that will run after N seconds, every N seconds, and during N seconds, and other useful timing utilities.
    * [Vector](http://hump.readthedocs.io/en/latest/vector.html) - Represents a 2D vector with a full set of the needed functions (normalization, dot product, cross product, etc.).
* [Lume](https://github.com/rxi/lume) - A set of utility functions that are incredibly useful for gamedev.
