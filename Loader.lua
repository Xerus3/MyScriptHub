local urls = {
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/main/Teleportation.lua",
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/main/Autofarm.lua"
}

for _, url in ipairs(urls) do
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not success then warn("Failed loading", url, err) end
    task.wait(0.3) -- small delay to prevent race
end
