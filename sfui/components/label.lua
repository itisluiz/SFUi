local Label = class("Label", SFUi.component)

function Label:initialize(parent, pos, content)
    SFUi.component.initialize(self, parent, pos, nil, content)
    self.content = content
end

function Label:getText()
    if type(self.content) == "table" then
        local text = ""
        for _, entry in ipairs(self.content) do
            if type(entry) ~= "Color" then
                text = text .. tostring(entry)
            end
        end
        return text
    else
        return tostring(self.content)
    end
end

function Label:updateSize()
    local lbl_x, lbl_y = render.getTextSize(self:getText())
    self.size = Vector(lbl_x, lbl_y)
end

function Label:render(cursor, action)
    self:updateSize()

    render.setColor(self.palette.foreground)
    if type(self.content) == "table" then
        local length_x = 0
        for _, entry in ipairs(self.content) do
            if type(entry) == "Color" then
                render.setColor(entry)
            else
                local entrystring = tostring(entry)
                render.drawSimpleText(self.mins.x + length_x, self.mins.y, entrystring)
                length_x = length_x + select(1, render.getTextSize(entrystring))
            end
        end
    else
        render.drawSimpleText(self.mins.x, self.mins.y, self:getText())
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.label = Label