SFUi = class("SFUi")

SFUi.static.palette = {
    foreground = Color(255, 255, 255),
    background = Color(30, 30, 30),
    hover = Color(75, 75, 75),
    component = Color(45, 45, 45),
    contrast = Color(60, 60, 60),
    highlight = Color(150, 255, 0)
}

function SFUi:initialize()
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

    -- Get appropriate cursor position
    do
        local cursorSource = isHUD and {input.getCursorPos()} or {render.cursorPos()}
        if cursorSource[1] and cursorSource[2] then
            cursor = Vector(cursorSource[1], cursorSource[2])
        end

    end

    -- Get action values for held and clicked
    do
        action.held = input.isKeyDown(KEY.E) or input.isMouseDown(MOUSE.LEFT)
        if action.held and not self.preventClick then
            action.click = true
            self.preventClick = true
        elseif not action.held then
            self.preventClick = false
        end

    end

    -- Prevent clicking on obsucured components
    self:orderTopmost()
    local hovered = self:hoveredComponent(cursor)

    -- Render components
    for index, component in ipairs(table.reverse(self.components)) do
        if component.visible then
            component.focus.allowed = component == hovered
            component:render(cursor, action)
        end
    end
end