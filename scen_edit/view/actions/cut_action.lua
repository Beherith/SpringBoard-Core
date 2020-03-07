SB.Include(Path.Join(SB.DIRS.SRC, 'view/actions/action.lua'))

CutAction = Action:extends{}

CutAction:Register({
    name = "sb_cut",
    tooltip = "Cut",
    image = Path.Join(SB.DIRS.IMG, 'scissors-rotated.png'),
    toolbar_order = 103,
    hotkey = {
        key = KEYSYMS.X,
        ctrl = true,
    },
    limit_state = true,
})

function CutAction:canExecute()
    return SB.view.selectionManager:GetSelectionCount() > 0
end

function CutAction:execute()
    SB.clipboard:Cut(SB.view.selectionManager:GetSelection())
end