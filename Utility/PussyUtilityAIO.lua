do
    
    local Version = 0.04
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyUtilityAIO.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/PussyUtilityAIO.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyUtilityAIO.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/PussyUtilityAIO.version"
        }
    }
    
    local function AutoUpdate()

        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New PussyUtility Version Press 2x F6")
        else
            print("PussyUtility loaded")
        end
    
    end
    
    AutoUpdate()

end


