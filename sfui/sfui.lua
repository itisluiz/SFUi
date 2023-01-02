SFUi = class("SFUi")

SFUi.static.palette = {
    foreground = Color(255, 255, 255),
    background = Color(30, 30, 30),
    hover = Color(75, 75, 75),
    component = Color(45, 45, 45),
    contrast = Color(60, 60, 60),
    highlight = Color(150, 255, 0)
}

function SFUi:initialize(height, fontsize, font)
    self.scaling = {
        height = height,
        fontsize = fontsize,
        lastScale = 1,
        lastHeight = nil
    }
    self.components = {}
    self.font = font or "Default"
    self.fonts = {}
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
    local curHeight = select(2, render.getResolution())
    local scale = nil

    if self.scaling.height and self.scaling.lastHeight ~= curHeight then
        local rawScale = (curHeight / self.scaling.height)
        scale = rawScale / self.scaling.lastScale
        
        if self.scaling.fontsize then
            local scaledFontSize = math.round(self.scaling.fontsize * rawScale)
            if not self.fonts[scaledFontSize] then
                self.fonts[scaledFontSize] = render.createFont(self.font, scaledFontSize, 400)
            end
            render.setFont(self.fonts[scaledFontSize])
        end
        
        self.scaling.lastScale = self.scaling.lastScale * scale
        self.scaling.lastHeight = curHeight
    end

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

    self:orderTopmost()
    local hovered = self:hoveredComponent(cursor)
    for index, component in ipairs(table.reverse(self.components)) do
        if scale then
            component:scale(scale, true)
        end
        if component.visible then
            component.focus.allowed = component == hovered
            component:render(cursor, action)
        end
    end
end