-- SFUi by itisluiz
-- https://github.com/itisluiz/SFUi/
-- Version 0.2

SFUi = class("SFUi")

SFUi.static.palette = {
    foreground = Color(255, 255, 255),
    background = Color(30, 30, 30),
    hover = Color(75, 75, 75),
    component = Color(45, 45, 45),
    contrast = Color(60, 60, 60),
    highlight = Color(150, 255, 0)
}

function SFUi:initialize(scaling)
    scaling = scaling or {}
    
    self.scaling = {
        designHeight = scaling.designHeight,
        designFontSize = scaling.designFontSize,
        componentAttenuation = scaling.componentAttenuation or 0,
        fontAttenuation = scaling.fontAttenuation or 0.6,
        fontName = scaling.fontName or "Default",
        fonts = {},
        curScale = 1,
        lastHeight = nil
    }

    self.components = {}
    self.preventClick = false
end

function SFUi:addComponent(component)
    for i = 1, #self.components do
        if self.components[i] == component then
            return
        end
    end
    table.insert(self.components, component)
end

function SFUi:removeComponent(component)
    for i = 1, #self.components do
        if self.components[i] == component then
            table.remove(self.components, i)
            break
        end
    end
end

function SFUi:orderTopmost()
    table.sortByMember(self.components, "lastclicked")
end

function SFUi:hoveredComponent(cursor)
    if not cursor then
        return nil
    end

    for index, component in ipairs(self.components) do
        if component.visible and cursor:withinAABox(component.mins, component.maxs) then
            return component
        end
    end

    return nil
end

function SFUi:render()
    local isHUD = not render.getScreenEntity()
    local cursor = nil
    local action = {click = false, held = false}
    local height = select(2, render.getResolution())
    local scale_pending = nil

    local cursorSource = isHUD and {input.getCursorPos()} or {render.cursorPos()}
    if cursorSource[1] and cursorSource[2] then
        cursor = Vector(cursorSource[1], cursorSource[2])
    end

    action.held = input.isKeyDown(KEY.E) or input.isMouseDown(MOUSE.LEFT)
    if action.held and not self.preventClick then
        action.click = true
        self.preventClick = true
    elseif not action.held then
        self.preventClick = false
    end

    if self.scaling.lastHeight ~= height then
        local designHeight = self.scaling.designHeight or height
        local scale = height / designHeight
        local scale_components = (scale + (1 - scale) * self.scaling.componentAttenuation) / self.scaling.curScale

        if self.scaling.designFontSize then
            local scale_font = scale + (1 - scale) * self.scaling.fontAttenuation
            local fontSize = math.round(scale_font * self.scaling.designFontSize)

            if not self.scaling.fonts[fontSize] then
                self.scaling.fonts[fontSize] = render.createFont(self.scaling.fontName, fontSize)
            end
            
            render.setFont(self.scaling.fonts[fontSize])
        end 

        scale_pending = scale_components
        self.scaling.curScale = self.scaling.curScale * scale_components
        self.scaling.lastHeight = height
    end

    self:orderTopmost()
    local hovered = self:hoveredComponent(cursor)
    for index, component in ipairs(table.reverse(self.components)) do
        if scale_pending then
            component:scale(scale_pending)
        end
        if component.visible then
            component.focus.allowed = component == hovered
            component:render(cursor, action)
        end
    end
end