SB.Include(Path.Join(SB.DIRS.SRC, 'view/editor.lua'))

if ExampleEditor ~= nil then
    ExampleEditor:Deregister()
end

ExampleEditor = Editor:extends{}
ExampleEditor:Register({
    name = "exampleEditor",
    tab = "Example",
    caption = "Example",
    tooltip = "Example editor",
    -- TODO: Fix image/path for extensions
    image = Path.Join(SB.DIRS.IMG, 'globe.png'),
})

function ExampleEditor:init()
    self:super("init")

    self:AddField(NumericField({
        name = "example",
        title = "Example:",
        tooltip = "Example value tooltip.",
        width = 140,
        minValue = -10,
        maxValue = 5,
    }))

    -- Note: as we are setting the value in synced only, we won't see the effect of undo in the editor.
    -- Consider using game rules if you want to be able to read in the UI as well.
    self:AddField(NumericField({
        name = "undoable",
        title = "Undoable:",
        tooltip = "This value can be used with undo/redo.",
        width = 140,
        minValue = -3,
        maxValue = 12,
    }))

    local children = {
        ScrollPanel:New {
            x = 0,
            y = 0,
            bottom = 30,
            right = 0,
            borderColor = {0,0,0,0},
            horizontalScrollbar = false,
            children = { self.stackPanel },
        },
    }

    self:Finalize(children)
end

function ExampleEditor:OnStartChange(name)
    if name == "undoable" then
        SB.commandManager:execute(SetMultipleCommandModeCommand(true))
    end
end

function ExampleEditor:OnEndChange(name)
    if name == "undoable" then
        SB.commandManager:execute(SetMultipleCommandModeCommand(false))
    end
end


function ExampleEditor:OnFieldChange(name, value)
    if name == "example" then
        local cmd = HelloWorldCommand(value)
        SB.commandManager:execute(cmd)
    elseif name == "undoable" then
        local cmd = UndoableExampleCommand(value)
        SB.commandManager:execute(cmd)
    end
end
