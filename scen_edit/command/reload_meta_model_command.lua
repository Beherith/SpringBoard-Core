ReloadMetaModelCommand = Command:extends{}

-- sends meta model files from widget to gadget
function ReloadMetaModelCommand:init(metaModelFiles)
    self.className = "ReloadMetaModelCommand"
    self.metaModelFiles = metaModelFiles
end

function ReloadMetaModelCommand:execute()
	Log.Notice("Reloading meta model...")
    SB.conf:SetMetaModelFiles(self.metaModelFiles)
    local metaModelLoader = MetaModelLoader()
    metaModelLoader:Load()
	Log.Notice("Reload completed successfully")
end
