for _, url in ipairs({
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/refs/heads/main/Teleportation.lua",
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/refs/heads/main/Autofarm.lua"
}) do
    local s, r = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not s then
        warn("Failed to load: "..url, r)
    end
end
