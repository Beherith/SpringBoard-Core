SaveProjectInfoCommand = Command:extends{}
SaveProjectInfoCommand.className = "SaveProjectInfoCommand"

function SaveProjectInfoCommand:init(name, path, isNewProject)
    self.name = name
    self.path = path
    self.isNewProject = isNewProject
end

local function GenerateModInfo()
    local modInfoTxt =
[[
local modinfo = {
    name = "__NAME__",
    shortName = "__SHORTNAME__",
    version    = "__VERSION__",
    game = "__GAME__", --what is this?
    shortGame = "__SHORTGAME__", --what is this?
    mutator = "Official", --what is this?
    description = "__DESCRIPTION__",
    modtype = "1",
    depend = {
        "__GAME_NAME__ __GAME_VERSION__",
    }
}
return modinfo]]
    local scenarioInfo = SB.model.scenarioInfo
    modInfoTxt = modInfoTxt:gsub("__NAME__", scenarioInfo.name)
                           :gsub("__SHORTNAME__", scenarioInfo.name)
                           :gsub("__VERSION__", scenarioInfo.version)
                           :gsub("__GAME__", scenarioInfo.name)
                           :gsub("__SHORTGAME__", scenarioInfo.name)
                           :gsub("__DESCRIPTION__", scenarioInfo.description)
                           :gsub("__GAME_NAME__", Game.gameName)
                           :gsub("__GAME_VERSION__", Game.gameVersion)

    return modInfoTxt
end

function SaveCommand.GenerateScript()
    -- TODO: Use SB.GetPersistantModOptions
    local project = SB.project

    local game = {
        name = project.game.name,
        version = project.game.version
    }

    local modOptions = {
        deathmode = "neverend",
        _sb_game_name = Game.gameName,
        _sb_game_version = Game.gameVersion,
        sb_game_mode = "dev",
        project_path = SB.project.path
    }

    local teams = {}
    local ais = {}
    local players = {}

    -- we ignore SB's teamIDs and make sure they make a no-gap array
    local teamIDCount = 1
    for _, team in pairs(SB.model.teamManager:getAllTeams()) do
        if not team.gaia and #players + #ais < 2 then
            local t = {
                -- TeamID = team.id, ID is implicit as index-1
                teamLeader = 0,
                allyTeam = team.allyTeam,
                RGBColor = team.color.r .. " " .. team.color.g .. " " .. team.color.b,
                side = team.side,
            }
            teams[teamIDCount] = t
            if team.side ~= nil and String.Trim(team.side) == "" then
                t.side = nil
            end
            if team.ai then
                local aiShortName = "NullAI"
                local aiVersion = ""

                table.insert(ais, {
                    name = team.name,
                    team = teamIDCount,
                    shortName = aiShortName,
                    version = aiVersion,

                    isFromDemo = false,
                    host = 0,
                })
            else
                table.insert(players, {
                    name = team.name,
                    team = teamIDCount,
                    spectator = true,
                    isFromDemo = true,
                })
            end

            teamIDCount = teamIDCount + 1
        end
    end

    local allyTeams = {}
    for i = 1, #teams do
        table.insert(allyTeams, {
            numAllies = 1,
        })
    end

    local script = {
        game = game,
        mapName = project.mapName,
        mapSeed = project.randomMapOptions.mapSeed,
        mapOptions = {
            new_map_x = project.randomMapOptions.new_map_x,
            new_map_y = project.randomMapOptions.new_map_y
        },
        startDelay = 0,
        mutators = project.mutators,
        modOptions = modOptions,
        players = players,
        ais = ais,
        teams = teams,
        allyTeams = allyTeams,
    }
    return StartScript.GenerateScriptTxt(script)
end

local function ScriptTxtSave(path)
    local scriptTxt = SaveCommand.GenerateScript()
    local file = assert(io.open(path, "w"))
    file:write(scriptTxt)
    file:close()
end

local function ModInfoSave(path)
    local modInfoTxt = GenerateModInfo()
    local file = assert(io.open(path, "w"))
    file:write(modInfoTxt)
    file:close()
end

local function MapInfoSave(name, path)
    local mapInfo = {
        name = name,
        version = "1.0",
        description = "",
        modtype = 3,
        teams = ExportMapInfoCommand.GetTeams(),
        depend = {
            "cursors.sdz",
        }
    }
    local file = assert(io.open(path, "w"))
    file:write(table.show(mapInfo))
    file:close()
end

function SaveProjectInfoCommand:execute()
    local projectDir = self.path
    local projectName = self.name

    Time.MeasureTime(function()
        MapInfoSave(projectName, Path.Join(projectDir, "mapinfo.lua"))
    end, function(elapsed)
        Log.Notice(("[%.4fs] Saved mapinfo"):format(elapsed))
    end)

    Time.MeasureTime(function()
        ScriptTxtSave(Path.Join(projectDir, Project.SCRIPT_FILE))
    end, function(elapsed)
        Log.Notice(("[%.4fs] Saved start scripts"):format(elapsed))
    end)

    Time.MeasureTime(function()
        table.save(SB.project:GetData(), Path.Join(projectDir, Project.PROJECT_FILE))
    end, function(elapsed)
        Log.Notice(("[%.4fs] Saved SpringBoard info"):format(elapsed))
    end)
end
