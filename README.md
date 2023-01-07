
# SFUi - StarfallEX GUI

## Showcase
https://user-images.githubusercontent.com/46863600/210156461-7b12105b-3d6a-48de-86f2-b5c1dbe828fc.mp4

## Source
```lua
--@name SFUi Example
--@author itisluiz
--@client

--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/sfui.lua as sfui.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/component.lua as components/component.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/window.lua as components/window.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/checkbox.lua as components/checkbox.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/button.lua as components/button.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/progress.lua as components/progress.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/slider.lua as components/slider.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/label.lua as components/label.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/list.lua as components/list.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/radio.lua as components/radio.lua
--@include https://raw.githubusercontent.com/itisluiz/SFUi/main/sfui/components/textbox.lua as components/textbox.lua

-- Always Required
require("sfui.lua")
require("components/component.lua")
-- Required only if used
require("components/window.lua")
require("components/button.lua")
require("components/checkbox.lua")
require("components/progress.lua")
require("components/slider.lua")
require("components/label.lua")
require("components/list.lua")
require("components/radio.lua")
require("components/textbox.lua")

local counter = 0
local props = {}

local function filterProps(partialModel)
    local allprops = find.byClass("prop_physics")
    
    table.empty(props)
    for k, v in ipairs(allprops) do  
        local model = v:getModel()
        if partialModel:len() == 0 or (model and model:find(partialModel) ~= nil) then
            props[k] = model
        end
    end
end
filterProps("")

local hiddenWindow = SFUi.window(Vector(100, 100), Vector(400, 300), "I was hidden!")
local textbox = SFUi.textbox(hiddenWindow, Vector(50, 40), Vector(250, 30), "Filter by model...", nil, filterProps)
local list = SFUi.list(hiddenWindow, Vector(50, 110), Vector(250, 150), "All props", props)
hiddenWindow.visible = false

local window = SFUi.window(Vector(10, 10), Vector(300, 200), "My Window")
local label = SFUi.label(window, Vector(10, 30), "Press the button to start adding!")
local slider = SFUi.slider(window, Vector(10, 90), Vector(120, 8), 1, 1, 10, 1)
local progress = SFUi.progress(window, Vector(10, 120), Vector(120, 12), nil)
local radioA = SFUi.radio(window, Vector(150, 90), Vector(5, 5), "Increment", "mygroup1", 1, true)
local radioB = SFUi.radio(window, Vector(150, 110), Vector(5, 5), "Decrement", "mygroup1", -1, false)

SFUi.checkbox(window, Vector(120, 60), Vector(10, 10), "Show hidden window", false, function(checked)
    hiddenWindow.visible = checked
end)

SFUi.button(window, Vector(10, 60), Vector(80, 20), "Add", function() 
    counter = counter + slider.value * radioA:groupValue()
    label.content = {"The total is [", Color(0, 255, 0), counter, Color(255, 255, 255), "]"}
    
    if counter < 0 then
        progress.palette.highlight = Color(255, 0, 0)
    else
        progress.palette.highlight = window.palette.highlight
    end
    progress.value = math.abs(counter) / 100
end)

-- Only add root components to your gui
local gui = SFUi:new()
gui:addComponent(hiddenWindow)
gui:addComponent(window)

hook.add("render", "sfui_gui_render", function()
    if not render.isHUDActive() then
        gui:render()
    end
end)


hook.add("drawhud", "sfui_gui_render", function()
    gui:render()
end)
```
# Quick and dirty documentation
### Library
- [SFUi Instance](#sfui)
### Components
- [Base](#component)
- [Window](#window)
- [Button](#button)
- [Checkbox](#checkbox)
- [Label](#label)
- [Listbox](#listbox)
- [Radio](#radio)
- [Slider](#slider)
- [Textbox](#textbox)
---
## SFUi
SFUi(scaling or nil)
#### Parameters
>- **scaling**: table, contains information regarding how the components should be auto-scaled for different resolutions. Contains the following keys: *designHeight* (The height for which the current sizes were designed or nil to disable auto scaling), *designFontSize* (The designed font size for the design height or nil to disable font auto scaling), *componentAttenuation* (For making components scale less [0 - 1] default 0), *fontAttenuation* (For making fonts scale less [0 - 1] default 0.6) and *fontName* (Font name to be used for auto-scaling on fonts, default is "Default")
---
## Component
Other components inherit these attributes
>- component.**pos**
>- component.**size**
>- component.**visible** - Whether a component and it's children should be rendered
>- component.**palette** - A table of colors with the following keys: *foreground*, *background*, *hover*, *component*, *contrast* and *highlight*
>- component:**scale(factor, recursive or nil)** - Scales the component's size and position by factor (number), and recurses if recursive (boolean), defaults to true
---
## Window
SFUi.window(pos, size, title or nil, draggable or nil, closehides or nil, callback or nil)
#### Parameters
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **title**: string, defaults to "Window"
>- **draggable**: boolean, defaults to true
>- **closehides**: boolean, if true or false then the close button will be visible, the truthiness determines if the close button should make the window not visible when clicked. If nil then the close button isn't visible.
>- **callback**: function(), called when the close button is visible and clicked
#### Useful Members
>- component.**title**
>- component.**draggable**
>- component.**closehides**
>- component.**callback**
---
## Button
SFUi.button(parent or nil, pos, size, text, callback or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **text**: string
>- **callback**: function(), called when button is clicked
#### Useful Members
>- component.**text**
>- component.**callback**
--- 
## Checkbox
SFUi.checkbox(parent or nil, pos, size, text, checked or nil, callback or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **text**: string
>- **checked**: boolean, defaults to false
>- **callback**: function(checked), called when checkbox state changes
#### Useful Members
>- component.**text**
>- component.**checked**
>- component.**callback**
---
## Label
SFUi.label(parent or nil, pos, content)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **content**: string or table containing strings and colors ("Hello World!" or {"Hello ", Color(255, 0, 0), "World!"})
#### Useful Members
>- component.**content**
>- component:**getText()** - Returns the condensed content text
---
## Listbox
SFUi.list(parent or nil, pos, size, label, options, callback or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **label**: string
>- **options**: table containing list items
>- **callback**: function(key), called when an item is clicked with the key of the item passed
#### Useful Members
>- component.**label**
>- component:**options**
>- component:**callback**
>- component:**value** - Current selected key in options
---
## Progress Bar
SFUi.progress(parent or nil, pos, size, value or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **value**: number (0 >- 1), progress of the bar, defaults to an animated loop if nil
#### Useful Members
>- component.**value**
---
## Radio Button
SFUi.radio(parent or nil, pos, size, text, group, value, checked or nil, callback or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector, only the x component matters as the radius
>- **text**: string
>- **group**: any, when this component is clicked, all siblings with same group will be unchecked
>- **value**: any, the value of the groupbox when it is selected
>- **checked**: boolean, defaults to false
>- **callback**: function(), called when this component is clicked
#### Useful Members
>- component.**text**
>- component.**group**
>- component.**checked**
>- component.**callback**
>- component:**groupValue()** - Returns the current value active in the group
>- component:**uncheckGroup()** - Unchecks all radios in the same group, including self
---
## Slider
SFUi.slider(parent or nil, pos, size, value, min, max, snap or nil, callback or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **value**: number, current value
>- **min**: number, minimum value
>- **max**: number, maximum value
>- **snap**: number, the increment / decrement multiple of the slider
>- **callback**: function(value), called when the value changes
#### Useful Members
>- component.**value**
>- component.**min**
>- component.**max**
>- component.**snap**
>- component.**callback**
---
## Textbox
SFUi.textbox(parent or nil, pos, size, hint or nil, text or nil, callback or nil)
#### Parameters
>- **parent**: parent element
>- **pos**: 2D Vector
>- **size**: 2D Vector
>- **hint**: string, place holder text, defaults to "Hover and chat"
>- **text**: string, default text, defaults to ""
>- **callback**: function(text), called when new text has been input
#### Useful Members
>- component.**hint**
>- component.**text**
>- component.**callback**
>- component.**active**
