local Radio = class("Radio", SFUi.component)

function Radio:initialize(parent, pos, size, text, group, value, checked, callback)
    SFUi.component.initialize(self, parent, pos, size)
    self.text = text
    self.group = group
    self.value = value
    self.checked = checked ~= nil and checked or false
    self.callback = callback
    self.radius = self.size.x
end

function Radio:updateHover(cursor)
    if cursor and self.focus.allowed then
        self.hover = cursor:getDistanceSqr(self.center) < self.radius * self.radius
    else
        self.hover = false
    end
end

function Radio:getSiblings()
    local siblings = {}
    for _, component in ipairs(self.parent.children) do
        if component.group and component.group == self.group then
            table.insert(siblings, component)
        end
    end

    return siblings
end

function Radio:groupValue()
    local siblings = self:getSiblings()
    for _, sibling in ipairs(siblings) do
        if sibling.checked then
            return sibling.value
        end
    end

    return nil
end

function Radio:uncheckGroup()
    local siblings = self:getSiblings()
    for _, sibling in ipairs(siblings) do
        sibling.checked = false
    end
end

function Radio:render(cursor, action)
    self.radius = self.size.x
    
    render.setColor(self.action.held and self.palette.highlight or self.palette.contrast)
    render.drawFilledCircle(self.center.x, self.center.y, self.radius + 1)

    render.setColor(self.hover and self.palette.contrast or self.palette.component)
    render.drawFilledCircle(self.center.x, self.center.y, self.radius)

    if self.checked then
        render.setColor(self.palette.highlight)
        render.drawFilledCircle(self.center.x, self.center.y, self.radius * 0.6)
    end

    render.setColor(self.action.held and self.palette.highlight or self.palette.foreground)
    render.drawSimpleText(self.maxs.x + self.radius * 1.5, self.center.y, self.text, nil, TEXT_ALIGN.CENTER)

    if self.action.click and not self.checked then
        self:uncheckGroup()
        self.checked = true
        if self.callback then
            self.callback()
        end
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.radio = Radio