local function run(url)
    local s, e = pcall(function()
        local code = game:HttpGet(url)
        local f = loadstring(code)
        if f then f() else warn("Failed to compile: "..url) end
    end)
    if not s then warn("Error loading: "..url.."\n"..e) end
end

run("https://raw.githubusercontent.com/Xerus3/MyScriptHub/main/Teleportation.lua")
run("https://raw.githubusercontent.com/Xerus3/MyScriptHub/main/Autofarm.lua")
