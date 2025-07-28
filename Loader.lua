local urls={
"https://raw.githubusercontent.com/Xerus3/MyScriptHub/refs/heads/main/Teleportation.lua",
"https://raw.githubusercontent.com/Xerus3/MyScriptHub/refs/heads/main/Autofarm.lua"
}
local function g(u)local fcs={function(u)return _G.HttpGet and _G.HttpGet(u)end,function(u)local s,r=pcall(function()return http and http.get and http.get(u)end)if s and r then return r.Body or r.body or r end end,function(u)local s,r=pcall(function()return http_request({Url=u,Method="GET"})end)if s and r and r.Success then return r.Body end end,function(u)local s,r=pcall(function()return syn and syn.request and syn.request({Url=u,Method="GET"})end)if s and r and r.StatusCode==200 then return r.Body end end,function(u)local s,r=pcall(function()return http_get and http_get(u)end)if s then return r end end}for _,fn in ipairs(fcs)do local s,r=pcall(fn,u)if s and r and type(r)=="string" and#r>0 then return r end end error("Failed to fetch "..u)end
for _,u in ipairs(urls)do
	local t=g(u)
	local f,e=loadstring(t)
	if f then f()else error("Loadstring error: "..tostring(e))end
end
