CopyCustomProjectFilesCommand = Command:extends{}
CopyCustomProjectFilesCommand.className = "CopyCustomProjectFilesCommand"

local ignoredFiles = {
	["mapinfo.lua"] = true,
	[".git"] = true
}

function CopyCustomProjectFilesCommand:init(src, dest)
	self.src = src
	self.dest = dest
end

function CopyCustomProjectFilesCommand:execute()
	Path.Walk(self.src, function(srcPath)
		local pathBase = srcPath:sub(#self.src + 2, #srcPath)

		if String.Starts(pathBase, Project.FOLDER_PREFIX) or
			ignoredFiles[Path.ExtractFileName(pathBase)] then
			return
		end

		Log.Notice("Copying " .. pathBase .. "...")
		local destPath = Path.Join(self.dest, pathBase)
		local destDir = Path.GetParentDir(destPath)
		Spring.CreateDir(destDir)

		local srcFileContent = VFS.LoadFile(srcPath, VFS.RAW)

		-- TODO: Do this in JS where this isn't a problem and no crappy workaround is necessary.
		xpcall(function()
			local destFile = assert(io.open(destPath, "w"))
			destFile:write(srcFileContent)
			destFile:close()
		end, function(err)
			Log.Error(debug.traceback(err, 3))
			Log.Error("Error copying project file " .. destPath .. " . Consider including it manually")
		end)
	end)
end
