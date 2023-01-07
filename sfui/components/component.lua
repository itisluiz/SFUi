local Component = class("Component")

function Component:initialize(parent, pos, size)
    self.pos = pos
    self.size = size or Vector()
    self.parent = parent
    self.palette = table.copy(self.parent and self.parent.palette or SFUi.palette)
    self.root = nil
    self.mins = nil
    self.center = nil
    self.maxs = nil
    self.hover = false
    self.visible = true
    self.lastclicked = 0
    self.children = {}
    self.focus = {
        component = nil,
        allowed = true
    }
    self.action = {
        click = nil,
        held = nil,
        release = nil
    }
    self.drag = {
        from = nil,
        delta = nil
    }

    if parent then
        table.insert(parent.children, self)
    end

    self:updateRoot()
    self:updatePos()
end

function Component:updateRoot()
    self.root = self.parent and self.parent.root or self
end

function Component:updateFocus()
    if self.parent then
        self.focus.allowed = self.parent.focus.allowed and (not self.parent.focus.component or self.parent.focus.component == self)
    end
end

function Component:updatePos()
    self.mins = self.pos
    if self.parent then
        self.mins = self.parent.mins + self.mins
    end
    self.center = self.mins + self.size / 2
    self.maxs = self.mins + self.size
end

function Component:updateHover(cursor)
    if cursor and self.focus.allowed then
        self.hover = cursor:withinAABox(self.mins, self.maxs)
    else
        self.hover = false
    end
end

function Component:updateActions(cursor, action)
    self.action.click = nil
    self.action.release = nil

    if self.hover and action.click then
        self.action.click = cursor
        self.action.held = cursor
        self.lastclicked = timer.realtime()
    elseif self.action.held and not action.held then
        self.action.held = nil
        self.action.release = cursor
    end
end

function Component:updateDrag(cursor)
    if self.action.held and not self.drag.from then
        self.drag.from = self.action.held
    elseif not self.action.held then
        self.drag.from = nil
    end

    if self.drag.from and cursor then
        self.drag.delta = cursor - self.drag.from
        self.drag.from = cursor
    else
        self.drag.delta = nil
    end
end

function Component:scale(factor, recursive)
    recursive = recursive or true
    self.size = self.size * factor
    self.pos = self.pos * factor
    
    if recursive then
        for _, child in ipairs(self.children) do
            child:scale(factor, recursive)
        end
    end
end

function Component:trimText(text, width, margin)
    width = width or self.size.x
    margin = margin or width * 0.05

    text = tostring(text)
    for i = -1, -text:len(), -1 do
        local subtext = text:sub(1, i)
        local sub_x, sub_y = render.getTextSize(subtext)

        if sub_x < width - margin then
            return subtext, sub_x, sub_y
        end
    end
end

function Component:render(cursor, action)
    self:updateRoot()
    self:updateFocus()
    self:updatePos()
    self:updateHover(cursor)
    self:updateActions(cursor, action)
    self:updateDrag(cursor)

    for _, child in ipairs(self.children) do
        if child.visible then
            child:render(cursor, action)
        end
    end
end

SFUi.static.component = Component