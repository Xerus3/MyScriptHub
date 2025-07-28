local P=game.Players.LocalPlayer
local RS=game:GetService("ReplicatedStorage")
local WS=workspace
local UIS=game:GetService("UserInputService")
local RunS=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local StarterGui=game:GetService("StarterGui")

local OFFSET,FARM_DELAY=3,0.5
local running=false
local farmThread
local currentOption=1 --1=KeepBoth,2=Replace
local notified={}

local trackedItems={"RequiemArrow","Frog","Cmoonbaby","DioDiary","devildiary"}

local statInputs={
	{label="Power (1-999999)",name="Power",min=1,max=999999,default=1},
	{label="Endurance (1-999999)",name="Endurance",min=1,max=999999,default=1},
	{label="Special (1-999999)",name="Special",min=1,max=999999,default=1},
	{label="Speed (1-20)",name="Speed",min=1,max=20,default=1},
	{label="ChanceMultiplier (1-999999)",name="ChanceMultiplier",min=1,max=999999,default=1},
}

local function setStat(n,v,minv,maxv)
	v=math.clamp(tonumber(v) or minv,minv,maxv)
	local stat=P:FindFirstChild(n)
	if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then stat.Value=v
	else warn("Stat "..n.." not found or invalid") end
end

local function cloneHTW()
	local b=P:WaitForChild("Backpack")
	local htw=RS:WaitForChild("Stands"):FindFirstChild("Halloween World")
	if htw then htw:Clone().Parent=b end
end

local function removeOldStands()
	local b=P:WaitForChild("Backpack")
	for _,v in pairs(b:GetChildren()) do
		if v:IsA("LocalScript") and v.Name~="ClientHandler" then v:Destroy() end
	end
end

local function removeOilTanker()
	local st=WS:FindFirstChild(P.Name)
	if st then
		local h=st:FindFirstChild("Head")
		local cont=h and h:FindFirstChild("Container")
		local stand=cont and cont:FindFirstChild("Stand")
		if stand then
			local ot=stand:FindFirstChild("oiltankerda")
			if ot then ot:Destroy() end
		end
	end
end

local function teleportInFront(torso)
	local lv,pos=torso.CFrame.LookVector,torso.Position
	local hrp=P.Character and P.Character:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.CFrame=CFrame.new(pos+lv*OFFSET,pos) end
end

local function collectCoPart()
	for _,p in pairs(WS:GetDescendants()) do
		if p:IsA("BasePart") and p.Name=="CoPart2" then
			local hrp=P.Character and P.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame=p.CFrame+Vector3.new(0,3,0)
				firetouchinterest(hrp,p,0)
				firetouchinterest(hrp,p,1)
			end
			return true
		end
	end
	return false
end

local function findNearestDummy()
	local closest,dist=nil,math.huge
	for _,m in pairs(WS:GetDescendants()) do
		if m:IsA("Model") and m:FindFirstChild("Torso") and string.match(m.Name,"^Hyperspace Dummy %[.-%]$") then
			local t=m.Torso
			local mag=P.Character and P.Character:FindFirstChild("HumanoidRootPart") and (t.Position-P.Character.HumanoidRootPart.Position).Magnitude or math.huge
			if mag<dist then dist=mag closest=m end
		end
	end
	return closest
end

local gui=Instance.new("ScreenGui",P:WaitForChild("PlayerGui"))
gui.Name="AutoFarmGui"
gui.ResetOnSpawn=false

local frame=Instance.new("Frame",gui)
frame.Size=UDim2.new(0,260,0,430)
frame.Position=UDim2.new(0.7,0,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(30,30,30)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true

local function mkBtn(txt,y,col)
	local b=Instance.new("TextButton",frame)
	b.Size=UDim2.new(1,-10,0,25)
	b.Position=UDim2.new(0,5,0,y)
	b.Text=txt
	b.BackgroundColor3=col or Color3.fromRGB(50,50,50)
	b.TextColor3=Color3.new(1,1,1)
	return b
end

local toggle=mkBtn("AutoFarm: OFF",5)
local optionLbl=Instance.new("TextLabel",frame)
optionLbl.Size=UDim2.new(1,-10,0,20)
optionLbl.Position=UDim2.new(0,5,0,40)
optionLbl.BackgroundTransparency=1
optionLbl.TextColor3=Color3.new(1,1,1)
optionLbl.Text="Stand Option (Click to toggle):"
optionLbl.TextXAlignment=Enum.TextXAlignment.Left

local optionBtn=mkBtn("Keep Both",65)
local resetBtn=mkBtn("Reset Player",95,Color3.fromRGB(150,40,40))

local labelY=130
local inputs={}
for i,v in ipairs(statInputs) do
	local l=Instance.new("TextLabel",frame)
	l.Position=UDim2.new(0,5,0,labelY)
	l.Size=UDim2.new(1,-10,0,20)
	l.BackgroundTransparency=1
	l.Text=v.label..":"
	l.TextColor3=Color3.new(1,1,1)
	l.TextSize=14
	local tb=Instance.new("TextBox",frame)
	tb.Position=UDim2.new(0,5,0,labelY+20)
	tb.Size=UDim2.new(1,-10,0,25)
	tb.PlaceholderText=tostring(v.default)
	tb.BackgroundColor3=Color3.fromRGB(40,40,40)
	tb.TextColor3=Color3.new(1,1,1)
	inputs[v.name]=tb
	labelY=labelY+50
end

local webhookLabel=Instance.new("TextLabel",frame)
webhookLabel.Position=UDim2.new(0,5,0,labelY)
webhookLabel.Size=UDim2.new(1,-10,0,20)
webhookLabel.BackgroundTransparency=1
webhookLabel.Text="Webhook URL (optional):"
webhookLabel.TextColor3=Color3.new(1,1,1)
webhookLabel.TextSize=14

local webhookBox=Instance.new("TextBox",frame)
webhookBox.Position=UDim2.new(0,5,0,labelY+20)
webhookBox.Size=UDim2.new(1,-10,0,25)
webhookBox.PlaceholderText="Webhook Here"
webhookBox.BackgroundColor3=Color3.fromRGB(40,40,40)
webhookBox.TextColor3=Color3.new(1,1,1)

labelY=labelY+50
local applyStatsBtn=mkBtn("Apply Stats",labelY)
local destroyBtn=mkBtn("Destroy GUI",labelY+30,Color3.fromRGB(100,30,30))

local resizing=false
local resizeBtn=Instance.new("TextButton",frame)
resizeBtn.Size=UDim2.new(0,15,0,15)
resizeBtn.Position=UDim2.new(1,-15,1,-15)
resizeBtn.Text="⇲"
resizeBtn.BackgroundColor3=Color3.fromRGB(60,60,60)
resizeBtn.TextColor3=Color3.fromRGB(200,200,200)
resizeBtn.MouseButton1Down:Connect(function() resizing=true end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end
end)
RunS.RenderStepped:Connect(function()
	if resizing then
		local mouse=UIS:GetMouseLocation()
		local minW, minH = 260, labelY + 70
		local newW = math.max(minW, mouse.X-frame.AbsolutePosition.X)
		local newH = math.max(minH, mouse.Y-frame.AbsolutePosition.Y)
		frame.Size=UDim2.new(0,newW,0,newH)
	end
end)

local function applyStats()
	for _,v in ipairs(statInputs) do
		setStat(v.name,inputs[v.name].Text,v.min,v.max)
	end
end

local function autofarm()
	farmThread=task.spawn(function()
		while running do
			if not collectCoPart() then
				local dummy=findNearestDummy()
				if dummy and dummy:FindFirstChild("Torso") then
					teleportInFront(dummy.Torso)
				end
			end
			task.wait(FARM_DELAY)
		end
	end)
end

local function sendNotification(text)
	StarterGui:SetCore("SendNotification",{
		Title="Item Spawned";
		Text=text;
		Duration=4;
	})
end

local function sendWebhook(msg)
	local url=webhookBox.Text
	if url~="" then
		local data={content=msg}
		local json=HttpService:JSONEncode(data)
		local success,err=pcall(function()
			HttpService:PostAsync(url,json,Enum.HttpContentType.ApplicationJson)
		end)
		if not success then warn("Webhook error:",err) end
	end
end

toggle.MouseButton1Click:Connect(function()
	running=not running
	toggle.Text="AutoFarm: "..(running and "ON" or "OFF")
	if running then
		if currentOption==2 then
			removeOldStands()
			removeOilTanker()
		end
		cloneHTW()
		task.wait(1)
		applyStats()
		autofarm()
	else
		if farmThread then
			task.cancel(farmThread)
			farmThread=nil
		end
	end
end)

applyStatsBtn.MouseButton1Click:Connect(applyStats)

optionBtn.MouseButton1Click:Connect(function()
	if currentOption==1 then currentOption=2 optionBtn.Text="Replace"
	else currentOption=1 optionBtn.Text="Keep Both" end
end)

resetBtn.MouseButton1Click:Connect(function()
	if P.Character and P.Character:FindFirstChild("Humanoid") then
		P.Character.Humanoid.Health=0
	end
end)

destroyBtn.MouseButton1Click:Connect(function()
	running=false
	if farmThread then
		task.cancel(farmThread)
	end
	gui:Destroy()
end)

StarterGui:SetCore("SendNotification",{Title="AutoFarm Script";Text="Script Loaded!";Duration=4})

task.spawn(function()
	while true do
		for _,itemName in ipairs(trackedItems) do
			if not notified[itemName] then
				if WS:FindFirstChild(itemName) then
					local text=itemName.." has spawned!"
					sendNotification(text)
					sendWebhook(text)
					notified[itemName]=true
				end
			end
		end
		task.wait(1)
	end
end)
