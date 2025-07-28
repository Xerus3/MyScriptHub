local g=game:HttpGet
local scripts={
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/refs/heads/main/Autofarm.lua",
    "https://raw.githubusercontent.com/Xerus3/MyScriptHub/refs/heads/main/Teleportation.lua"
}
for _,url in ipairs(scripts) do
    local s,err = loadstring(g(url))
    if s then coroutine.wrap(s)() task.wait(0.2) end
end
