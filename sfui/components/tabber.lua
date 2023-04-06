-- Tab, not exported
local Tab = class("Tab", SFUi.component)

function Tab:initialize(parent, tabLabel, callback)
    SFUi.component.initialize(self, parent, Vector(0, 0), parent.size)
    self.tabLabel = tabLabel
    self.callback = callback
end

function Tab:render(cursor, action)
    if self.parent.activeTab ~= self then
        return
    end

    SFUi.component.render(self, cursor, action)
end

-- Tab container, exported
local Tabber = class("Tabber", SFUi.component)

function Tabber:initialize(parent, pos, size)
    SFUi.component.initialize(self, parent, pos, size)
    self.activeTab = nil
end

function Tabber:addTab(tabLabel, callback)
    local tab = Tab(self, tabLabel, callback)
    if not self.activeTab then
        self.activeTab = tab
    end

    return tab
end

function Tabber:removeTab(tab)
    for index, child in ipairs(self.children) do
        if tab == child then
            table.remove(self.children, index)
            break
        end
    end

    if self.activeTab == tab then
        self.activeTab = nil
        for index, child in ipairs(self.children) do
            if child.tabLabel then
                self.activeTab = child
            end
        end
    end
end

function Tabber:render(cursor, action)
    local tabSwitchWidth = 0
    for _, tab in ipairs(self.children) do
        if not tab.tabLabel then
            continue
        end

        local labelX, labelY = render.getTextSize(tab.tabLabel)
        labelX = labelX + self.size.x * 0.05
        labelY = labelY + self.size.y * 0.025

        local size = Vector(labelX, labelY)
        local mins = Vector(self.mins.x + tabSwitchWidth, self.mins.y)
        local maxs = Vector(self.mins.x + tabSwitchWidth + labelX, self.mins.y + labelY)
        local hover = cursor and self.hover and cursor:withinAABox(mins, maxs)

        render.setColor(hover and self.palette.contrast or (self.activeTab == tab and self.palette.component or self.palette.background))
        render.drawRectFast(mins.x, mins.y, size.x, size.y)

        render.setColor(self.activeTab == tab and self.palette.highlight or self.palette.foreground)
        render.drawSimpleText(mins.x + self.size.x * 0.025, mins.y + self.size.y * 0.0125, tab.tabLabel, TEXT_ALIGN.LEFT, TEXT_ALIGN.TOP)

        if hover and action.click then
            self.activeTab = tab
            
            if tab.callback then
                tab.callback()
            end
        end

        tabSwitchWidth = tabSwitchWidth + labelX
    end

    render.setColor(self.palette.contrast)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    SFUi.component.render(self, cursor, action)
end

SFUi.static.tabber = Tabber