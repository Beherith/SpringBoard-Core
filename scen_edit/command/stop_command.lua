StopCommand = Command:extends{}

function StopCommand:init()
    self.className = "StopCommand"
end

function StopCommand:execute()
    if SB.rtModel.hasStarted then
        Log.Notice("Stopping game...")
        Spring.StopSoundStream()
        Spring.SetGameRulesParam("sb_gameMode", "dev")
        SB.rtModel:GameStop()
        -- use meta data (except variables) from the new (runtime) model
        -- enable all triggers
        local meta = SB.model:GetMetaData()
        for _, trigger in pairs(meta.triggers) do
            trigger.enabled = true
        end
        meta.variables = SB.model.oldModel.meta.variables

        SB.model.oldModel.meta = meta

        SB.model:Load(SB.model.oldModel)
        SB.model.oldHeightMap:Load()
    end
end
