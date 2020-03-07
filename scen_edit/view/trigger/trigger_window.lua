SB.Include(Path.Join(SB.DIRS.SRC, 'view/editor.lua'))
SB.IncludeDir(Path.Join(SB.DIRS.SRC, 'view/trigger/fields'))

TriggerWindow = Editor:extends{}

function TriggerWindow:init(trigger)
    Editor.init(self)

    self.trigger = trigger
    self.openedConditionNodes = {}
    self.openedActionNodes = {}


    self.showEvents = true
    self.showConditions = true
    self.showActions = true

    self:AddField(StringField({
        name = "name",
        title = "Name:",
        tooltip = "Trigger name",
        value = self.trigger.name,
    }))

    self._triggerPanel = StackPanel:New {
        itemMargin = {0, 0, 0, 0},
        x = 0,
        y = 0,
        right = 0,
        autosize = true,
        resizeItems = false,
        padding = {0, 0, 0, 0}
    }

    local children = {}

    table.insert(children,
        ScrollPanel:New {
            x = 0,
            y = 0,
            bottom = 30,
            right = 0,
            borderColor = {0,0,0,0},
            horizontalScrollbar = false,
            children = { self.stackPanel },
        }
    )
    table.insert(children,
        ScrollPanel:New {
            x = 0,
            y = 50,
            bottom = 30,
            right = 0,
            borderColor = {0,0,0,0},
            horizontalScrollbar = false,
            children = { self._triggerPanel },
        }
    )
    self:Finalize(children, {
        notMainWindow = true,
        buttons = { "ok", "cancel" },
        width = 610,
        height = 550,
        x = tostring(math.random(25, 35)) .. "%",
        y = tostring(math.random(15, 25)) .. "%",
        classname = "sb_window",
    })

    self:Populate()
end

function TriggerWindow:ConfirmDialog()
    self.trigger.name = self.fields["name"].value
    self.save = true
    self.window:Dispose()
end

function TriggerWindow:_AddSection(opts)
    local title = opts.title
    local AddFunction = opts.AddFunction
    local ToggleShowFunction = opts.ToggleShowFunction
    local isCollapsed = opts.isCollapsed
    local hasElements = opts.hasElements

    local headerHeight
    local minElementPanelHeight
    if isCollapsed or hasElements then
        headerHeight = 32
        minElementPanelHeight = 0
    else
        headerHeight = 30
        minElementPanelHeight = 20
    end
    local headerPanel = Control:New {
        width = "100%",
        height = headerHeight,
        parent = self._triggerPanel,
        padding = {0, 0, 0, 0},
    }
    -- local captionWidth = headerPanel.font:GetTextWidth(title)
    local btnAdd = Button:New {
        parent = headerPanel,
        -- x = captionWidth + 20,
        x = 100,
        y = 0,
        height = 30,
        width = 80,
        caption = "Add",
        OnClick = {AddFunction},
        classname = "positive_button",
    }

    local imgFile
    if isCollapsed then
        imgFile = Path.Join(SB.DIRS.IMG, 'expand.png')
    else
        imgFile = Path.Join(SB.DIRS.IMG, 'collapse.png')
    end
    local imgCollapsedState = Image:New {
        parent = headerPanel,
        right = 10,
        width = 15,
        height = 15,
        y = 7,
        file = imgFile,
    }

    local btnToggleDisplay = Button:New {
        parent = headerPanel,
        width = "100%",
        height = 30,
        caption = title,
        align = "left",
        valign = "center",
        OnClick = {ToggleShowFunction},
        classname = "collapse_panel_header",
    }

    local elementPanel = StackPanel:New {
        parent = self._triggerPanel,
        itemMargin = {0, 0, 0, 0},
        x = 0,
        y = 0,
        right = 0,
        autosize = true,
        resizeItems = false,
        padding = {0, 5, 0, 0},
        classname = "panel",
        minHeight = minElementPanelHeight,
    }

    return elementPanel
end

function TriggerWindow:Populate()
    self._triggerPanel:ClearChildren()
    local ELEMENT_INDENT = 10
    do -- Events
        local elementPanel = self:_AddSection({
            title = "Events",
            AddFunction = function() self:MakeAddEventWindow() end,
            ToggleShowFunction = function()
                self.showEvents = not self.showEvents
                self:Populate()
            end,
            isCollapsed = not self.showEvents,
            hasElements = #self.trigger.events > 0,
        })
        if self.showEvents then
            for i = 1, #self.trigger.events do
                local event = self.trigger.events[i]
                local stackEventPanel = MakeComponentPanel(elementPanel)
                local btnEditEvent = Button:New {
                    caption = SB.model.triggerManager:GetSafeEventHumanName(self.trigger, event),
                    right = SB.conf.B_HEIGHT + 10,
                    x = ELEMENT_INDENT,
                    height = SB.conf.B_HEIGHT,
                    parent = stackEventPanel,
                    tooltip = "Edit event",
                    OnClick = {function() self:MakeEditEventWindow(event) end},
                }
                local btnRemoveEvent = Button:New {
                    caption = "",
                    right = 0,
                    width = SB.conf.B_HEIGHT,
                    height = SB.conf.B_HEIGHT,
                    parent = stackEventPanel,
                    padding = {2, 2, 2, 2},
                    tooltip = "Remove event",
                    classname = "negative_button",
                    children = {
                        Image:New {
                            file = Path.Join(SB.DIRS.IMG, 'cancel.png'),
                            height = "100%",
                            width = "100%",
                        },
                    },
                    OnClick = {function() self:MakeRemoveEventWindow(event, i) end}
                }
            end
        end
    end
    do -- Conditions
        local elementPanel = self:_AddSection({
            title = "Conditions",
            AddFunction = function() self:MakeAddConditionWindow() end,
            ToggleShowFunction = function()
                self.showConditions = not self.showConditions
                self:Populate()
            end,
            isCollapsed = not self.showConditions,
            hasElements = #self.trigger.conditions > 0,
        })
        if self.showConditions then
            for i = 1, #self.trigger.conditions do
                local condition = self.trigger.conditions[i]
                local stackPanel = MakeComponentPanel(elementPanel)
                local conditionHumanName = SB.humanExpression(condition, "condition")

                local imgFile
                if self.openedConditionNodes[i] then
                    imgFile = Path.Join(SB.DIRS.IMG, 'collapse.png')
                else
                    imgFile = Path.Join(SB.DIRS.IMG, 'expand.png')
                end
                local btnOpenSubNodes = Button:New {
                    caption = '',
                    x = ELEMENT_INDENT,
                    width = SB.conf.B_HEIGHT - 4,
                    height = SB.conf.B_HEIGHT - 4,
                    padding = {2, 2, 2, 2},
                    parent = stackPanel,
                    OnClick = {
                        function()
                            self.openedConditionNodes[i] = not self.openedConditionNodes[i]
                            self:Populate()
                        end
                    },
                    children = {
                        Image:New {
                            height = "100%",
                            width = "100%",
                            file = imgFile,
                        }
                    }
                }
                local btnEditCondition = Button:New {
                    caption = conditionHumanName,
                    right = SB.conf.B_HEIGHT + 10,
                    x = ELEMENT_INDENT + SB.conf.B_HEIGHT + 5,
                    height = SB.conf.B_HEIGHT,
                    parent = stackPanel,
                    tooltip = "Edit condition",
                    OnClick = {function() self:MakeEditConditionWindow(condition) end}
                }
                local btnRemoveCondition = Button:New {
                    caption = "",
                    right = 0,
                    width = SB.conf.B_HEIGHT,
                    height = SB.conf.B_HEIGHT,
                    parent = stackPanel,
                    padding = {2, 2, 2, 2},
                    tooltip = "Remove condition",
                    classname = "negative_button",
                    children = {
                        Image:New {
                            file = Path.Join(SB.DIRS.IMG, 'cancel.png'),
                            height = "100%",
                            width = "100%",
                        },
                    },
                    OnClick = {function() self:MakeRemoveConditionWindow(condition, i) end}
                }
                local openedNodes = self.openedConditionNodes[i]
                if openedNodes then
                    self:PopulateExpressions(condition, SB.metaModel.functionTypes[condition.typeName], 2, condition.typeName, elementPanel)
                end
            end
        end
    end
    do -- Actions
        local elementPanel = self:_AddSection({
            title = "Actions",
            AddFunction = function() self:MakeAddActionWindow() end,
            ToggleShowFunction = function()
                self.showActions = not self.showActions
                self:Populate()
            end,
            isCollapsed = not self.showActions,
            hasElements = #self.trigger.actions > 0,
        })
        if self.showActions then
            for i = 1, #self.trigger.actions do
                local action = self.trigger.actions[i]
                local stackActionPanel = MakeComponentPanel(elementPanel)
                local actionHumanName = SB.humanExpression(action, "action")

                local imgFile
                if self.openedActionNodes[i] then
                    imgFile = Path.Join(SB.DIRS.IMG, 'collapse.png')
                else
                    imgFile = Path.Join(SB.DIRS.IMG, 'expand.png')
                end
                local btnOpenSubNodes = Button:New {
                    caption = '',
                    x = ELEMENT_INDENT,
                    width = SB.conf.B_HEIGHT - 4,
                    height = SB.conf.B_HEIGHT - 4,
                    padding = {2, 2, 2, 2},
                    parent = stackActionPanel,
                    OnClick = {
                        function()
                            self.openedActionNodes[i] = not self.openedActionNodes[i]
                            self:Populate()
                        end
                    },
                    children = {
                        Image:New {
                            height = "100%",
                            width = "100%",
                            file = imgFile,
                        }
                    }
                }
                local btnEditAction = Button:New {
                    caption = actionHumanName,
                    right = SB.conf.B_HEIGHT + 10,
                    x = ELEMENT_INDENT + SB.conf.B_HEIGHT + 5,
                    height = SB.conf.B_HEIGHT,
                    parent = stackActionPanel,
                    tooltip = "Edit action",
                    OnClick = {function() self:MakeEditActionWindow(action) end}
                }
                local btnRemoveAction = Button:New {
                    caption = "",
                    right = 0,
                    width = SB.conf.B_HEIGHT,
                    height = SB.conf.B_HEIGHT,
                    parent = stackActionPanel,
                    padding = {2, 2, 2, 2},
                    tooltip = "Remove action",
                    classname = "negative_button",
                    children = {
                        Image:New {
                            file = Path.Join(SB.DIRS.IMG, 'cancel.png'),
                            height = "100%",
                            width = "100%",
                        },
                    },
                    OnClick = {function() self:MakeRemoveActionWindow(action, i) end},
                }
                local openedNodes = self.openedActionNodes[i]
                if openedNodes then
                    self:PopulateExpressions(action, SB.metaModel.actionTypes[action.typeName], 2, action.typeName, elementPanel)
                end
            end
        end
    end
end

function TriggerWindow:PopulateExpressions(root, rootType, level, typeName, panel)
    if rootType == nil then
        local stackPanel = MakeComponentPanel(panel)
        local lblParam = Label:New {
            caption = "Error: Cannot find declaration for type: " ..typeName,
            x = (level - 1) * 50,
            right = 1,
            parent = stackPanel,
        }
        return
    end
    for i, input in pairs(rootType.input) do
        local stackPanel = MakeComponentPanel(panel)

        local param = root[input.name] or {}
        local paramName = param.value
        if param.type == 'var' then
            paramName = SB.model.variableManager:getVariable(param.value).name
        elseif param.type == "expr" then
            local expr = param.value
            paramName = SB.metaModel.functionTypes[expr.typeName].humanName
        elseif type(paramName) == 'table' then
            paramName = SB.humanExpression(param, "value", input.type)
        end
        if input.name == "relation" then
            if root.typeName == "compare_number" then
                paramName = SB.metaModel.numericComparisonTypes[root.relation.value]
            else
                paramName = SB.metaModel.identityComparisonTypes[root.relation.value]
            end
        end
        local lblParam = Label:New {
            caption = input.name .. ": " .. (tostring(paramName) or "nil"),
            x = (level - 1) * 50,
            right = 1,
            parent = stackPanel,
        }

        if param.type == "expr" then
            local expr = param.value
            local exprType = SB.metaModel.functionTypes[expr.typeName]

            self:PopulateExpressions(expr, exprType, level + 1, expr.typeName, panel)
        end
    end
end

function TriggerWindow:_GetTriggerElementWindowParams()
    return {
        trigger = self.trigger,
        params = SB.model.triggerManager:GetTriggerScopeParams(self.trigger),
    }
end

function TriggerWindow:_PostElementWindowCreate(elementWindow)
    SB.MakeWindowModal(elementWindow.window, self.window)
    return elementWindow
end

function TriggerWindow:MakeAddConditionWindow()
    local opts = self:_GetTriggerElementWindowParams()
    opts.mode = 'add'
    opts.OnConfirm = {
        function(element)
            table.insert(self.trigger.conditions, element)
            self.showConditions = true
            self:Populate()
        end
    }
    return self:_PostElementWindowCreate(ConditionWindow(opts))
end

function TriggerWindow:MakeEditConditionWindow(condition)
    local opts = self:_GetTriggerElementWindowParams()
    opts.mode = 'edit'
    opts.condition = condition
    opts.OnConfirm = {
        function(element)
            self:Populate()
        end
    }
    return self:_PostElementWindowCreate(ConditionWindow(opts))
end

function TriggerWindow:MakeRemoveConditionWindow(condition, idx)
    table.remove(self.trigger.conditions, idx)
    self.openedConditionNodes = {}
    self:Populate()
end

function TriggerWindow:MakeAddEventWindow()
    local opts = self:_GetTriggerElementWindowParams()
    opts.mode = 'add'
    opts.OnConfirm = {
        function(element)
            table.insert(self.trigger.events, element)
            self.showEvents = true
            self:Populate()
        end
    }
    return self:_PostElementWindowCreate(EventWindow(opts))
end

function TriggerWindow:MakeEditEventWindow(event)
    local opts = self:_GetTriggerElementWindowParams()
    opts.mode = 'edit'
    opts.event = event
    opts.OnConfirm = {
        function(element)
            self:Populate()
        end
    }
    return self:_PostElementWindowCreate(EventWindow(opts))
end

function TriggerWindow:MakeRemoveEventWindow(event, idx)
    table.remove(self.trigger.events, idx)
    self:Populate()
end

-- Merge additional params from other, previous actions
-- FIXME: Maybe this should be moved to the triggerManager
function TriggerWindow:_MergeExtraActionParams(opts, action)
    for _, a in ipairs(self.trigger.actions) do
        -- Do not include actions *after* this action
        if a == action then
            break
        end

        local aType = SB.metaModel.actionTypes[a.typeName]
        for _, param in pairs(aType.param) do
            table.insert(opts.params, {
                name = param.name,
                type = param.type,
                humanName = "Action(" .. aType.humanName .. "): " .. param.name,
            })
        end
    end
end

function TriggerWindow:MakeAddActionWindow()
    local opts = self:_GetTriggerElementWindowParams()
    self:_MergeExtraActionParams(opts)
    opts.mode = 'add'
    opts.OnConfirm = {
        function(element)
            table.insert(self.trigger.actions, element)
            self.showActions = true
            self:Populate()
        end
    }
    return self:_PostElementWindowCreate(ActionWindow(opts))
end

function TriggerWindow:MakeEditActionWindow(action)
    local opts = self:_GetTriggerElementWindowParams()
    self:_MergeExtraActionParams(opts, action)
    opts.mode = 'edit'
    opts.action = action
    opts.OnConfirm = {
        function(element)
            self:Populate()
        end
    }
    return self:_PostElementWindowCreate(ActionWindow(opts))
end

function TriggerWindow:MakeRemoveActionWindow(action, idx)
    table.remove(self.trigger.actions, idx)
    self.openedActionNodes = {}
    self:Populate()
end
