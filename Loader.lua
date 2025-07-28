local scripts = {
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/main/Teleportation.lua",
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/main/Autofarm.lua"
}

for _, url in ipairs(scripts) do
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        assert(source and #source > 0, "Empty script")
        return loadstring(source)()
    end)
    
    if not success then
        warn("Failed to load script at:", url, "\nError:", result)
    end
end
