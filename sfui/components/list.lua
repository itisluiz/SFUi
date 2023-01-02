local List = class("List", SFUi.component)

function List:initialize(parent, pos, size, label, options, callback)
    SFUi.component.initialize(self, parent, pos, size)
    self.label = label
    self.options = options
    self.callback = callback
    self.labelheight = 0
    self.scrollwidth = 7
    self.value = nil
    self.list = {
        length = 0,
        scroll = 0,
        items = {},
        action = {
            option = nil,
            scrolldist = 0,
            scrollhover = false,
            scrollheld = false
        }
    }
end

function List:updateList(cursor)
    for option, item in pairs(self.list.items) do
        if not self.options[option] then
            self.list.items[option] = nil 
        end
    end

    self.list.length = 0
    for option, label in pairs(self.options) do        
        local item = self.list.items[option]
        if not item or item.oglabel ~= label then
            local trimmedLabel, label_x, label_y = self:trimText(label)
            self.list.items[option] = {label = trimmedLabel, oglabel = label, size = label_y}
            item = self.list.items[option]
        end

        item.min = self.mins.y + self.list.length - self.list.scroll
        item.max = item.min + item.size
        item.hover = self.hover and cursor and cursor.x < self.maxs.x - self.scrollwidth and cursor.y > math.max(item.min, self.mins.y) and cursor.y < math.min(item.max, self.maxs.y)

        self.list.length = self.list.length + item.size
    end
end

function List:updateScroll(cursor)
    if self.list.length > self.size.y then
        self.list.action.scrollhover = cursor and self.hover and cursor.x > self.maxs.x - self.scrollwidth  
        if self.list.action.scrollhover and self.action.click then
            self.list.action.scrollheld = true
        elseif not self.action.held then
            self.list.action.scrollheld = false
        end

        if cursor and self.list.action.scrollheld then
            self.list.scroll = math.clamp(math.remap(cursor.y, self.mins.y, self.maxs.y, 0, self.list.length - self.size.y), 0, self.list.length - self.size.y)
        elseif self.drag.delta and not self.list.action.scrollheld then
            self.list.scroll = math.clamp(self.list.scroll - self.drag.delta.y, 0, self.list.length - self.size.y)
            self.list.action.scrolldist = self.list.action.scrolldist + self.drag.delta:getLength2DSqr()
        end
    end
end

function List:render(cursor, action)
    self:updateScroll(cursor)
    self:updateList(cursor)
    self.labelheight = select(2, render.getTextSize(self.label))

    render.setColor(self.palette.background)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    for option, item in pairs(self.list.items) do
        if item.max > self.mins.y and item.min < self.maxs.y then
            if self.list.action.option == option then
                render.setColor(self.palette.hover)
                render.drawRect(self.mins.x, item.min, self.size.x, item.size)
            elseif item.hover then
                if self.action.click then
                    self.list.action.option = option
                elseif not self.action.held then
                    render.setColor(self.palette.contrast)
                    render.drawRect(self.mins.x, item.min, self.size.x, item.size)
                end
            end

            render.setColor(self.value == option and self.palette.highlight or self.palette.foreground)
            render.drawSimpleText(self.mins.x + 5, item.min, item.label, item.size)
        end
    end

    if self.action.release and self.list.action.option and self.list.action.scrolldist < 0.2 then
        self.value = self.list.action.option
        if self.callback then
            self.callback(self.value)
        end
    end

    if not self.action.held then
        self.list.action.option = nil
        self.list.action.scrolldist = 0
    end

    render.setColor(self.palette.background)
    render.drawRect(self.mins.x, self.mins.y - self.labelheight, self.size.x, self.labelheight)
    render.drawRect(self.mins.x, self.maxs.y, self.size.x, self.labelheight)

    local scrollheight = (self.size.y / self.list.length) * self.size.y
    if scrollheight < self.size.y then
        render.setColor(self.palette.component)
        render.drawRect(self.maxs.x - self.scrollwidth, self.mins.y, self.scrollwidth, self.size.y)

        render.setColor((self.list.action.scrollheld or self.list.action.scrolldist >= 0.2) and self.palette.highlight or (self.list.action.scrollhover and self.palette.hover or self.palette.contrast))
        render.drawRect(self.maxs.x - self.scrollwidth, math.remap(self.list.scroll, 0, self.list.length - self.size.y, self.mins.y, self.maxs.y - scrollheight), self.scrollwidth, scrollheight)
    end
    
    render.setColor(self.palette.foreground)
    render.drawSimpleText(self.mins.x + 2, self.mins.y - self.labelheight, self.label)

    render.setColor(self.hover and self.palette.hover or self.palette.contrast)
    render.drawRectOutline(self.mins.x - 1, self.mins.y - 1, self.size.x + 2, self.size.y + 2)

    SFUi.component.render(self, cursor, action)
end

SFUi.static.list = List