SB.Include(Path.Join(SB_VIEW_DIR, "editor_view.lua"))

FilePickerWindow = EditorView:extends{}

function FilePickerWindow:init(path)
    self:super("init")

    self.path = path or "/"
    self.selectedFile = {}

    self.fileBrowser = TextureBrowser({
        ctrl = {
            width = "100%",
            height = "100%",
        },
        rootDir = self.path,
        OnSelectItem = {
            function(item, selected)
                if not item.texture then
                    return
                end

                local path = item.texture.diffuse
                if selected then
                    self.selectedFile[path] = true
                else
                    self.selectedFile[path] = false
                end
                if self.field then
                    self.field:Set(path)
                end
            end
        },
    })
    local children = {
        ScrollPanel:New {
            x = 0,
            right = 0,
            y = 0,
            height = "80%",
            padding = {0, 0, 0, 0},
            children = {
                self.fileBrowser.control,
            }
        },
    }

    table.insert(children,
        ScrollPanel:New {
            x = 0,
            y = 0,
            bottom = 0,
            right = 0,
            borderColor = {0,0,0,0},
            horizontalScrollbar = false,
            children = { self.stackPanel },
        }
    )
    self:Finalize(children, {notMainWindow = true})
end