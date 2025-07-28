local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")
local lp=Players.LocalPlayer
local playerGui=lp:WaitForChild("PlayerGui")
local oldGui=playerGui:FindFirstChild("TeleportButtons")
if oldGui then oldGui:Destroy() end
local cooldown=false
local container=Instance.new("ScreenGui")
container.Name="TeleportButtons"
container.ResetOnSpawn=false
container.Parent=playerGui
local frame=Instance.new("Frame",container)
frame.Size=UDim2.new(0,180,0,320)
frame.Position=UDim2.new(0,20,0.5,-160)
frame.BackgroundTransparency=0
frame.BackgroundColor3=Color3.fromRGB(30,30,30)
frame.Active=true
frame.Draggable=true
local padding=Instance.new("UIPadding",frame)
padding.PaddingTop=UDim.new(0,20)
local layout=Instance.new("UIListLayout",frame)
layout.Padding=UDim.new(0,6)
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local toggleButton=Instance.new("TextButton",container)
toggleButton.Size=UDim2.new(0,150,0,30)
toggleButton.Position=UDim2.new(0,20,0,20)
toggleButton.BackgroundColor3=Color3.fromRGB(50,50,50)
toggleButton.TextColor3=Color3.fromRGB(255,255,255)
toggleButton.Font=Enum.Font.Gotham
toggleButton.TextSize=14
toggleButton.Text="Toggle Teleport GUI"
local function addUICorner(inst,radius)
	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,radius or 6)
	corner.Parent=inst
end
addUICorner(frame,10)
addUICorner(toggleButton,8)
local function notify(text)
	StarterGui:SetCore("SendNotification",{
		Title="Teleported!",
		Text=text,
		Duration=2
	})
end
local function styleButton(btn)
	btn.Size=UDim2.new(0,160,0,30)
	btn.BackgroundColor3=Color3.fromRGB(50,50,50)
	btn.TextColor3=Color3.fromRGB(255,255,255)
	btn.Font=Enum.Font.Gotham
	btn.TextSize=14
	addUICorner(btn,4)
end
local function createButton(name,teleportFunc)
	local btn=Instance.new("TextButton",frame)
	btn.Text=name
	styleButton(btn)
	btn.MouseButton1Click:Connect(function()
		if cooldown then return end
		cooldown=true
		local char=lp.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			teleportFunc(char.HumanoidRootPart)
			notify("You teleported to "..name)
		end
		task.wait(0.5)
		cooldown=false
	end)
end
local npcFolder=workspace:WaitForChild("Qu2")
createButton("Koichi",function(hrp)
	local target=npcFolder:FindFirstChild("NPC")
	if target then hrp.CFrame=target:GetPivot()+Vector3.new(4,5,0) end
end)
createButton("Jotaro",function(hrp)
	local target=npcFolder:FindFirstChild("NPC3")
	if target then hrp.CFrame=target:GetPivot()+Vector3.new(4,5,0) end
end)
createButton("Pucci",function(hrp)
	local target=npcFolder:FindFirstChild("NPC2")
	if target then hrp.CFrame=target:GetPivot()+Vector3.new(4,5,0) end
end)
createButton("DIO",function(hrp)
	local target=npcFolder:FindFirstChild("NPC4")
	if target then hrp.CFrame=target:GetPivot()+Vector3.new(4,5,0) end
end)
createButton("Giorno (Requiem Bags)",function(hrp)
	local target=npcFolder:FindFirstChild("NPC6")
	if target then hrp.CFrame=target:GetPivot()+Vector3.new(4,5,0) end
end)
createButton("Giorno (Grass Dummy)",function(hrp)
	local target=npcFolder:FindFirstChild("NPC7")
	if target then hrp.CFrame=target:GetPivot()+Vector3.new(4,5,0) end
end)
createButton("Stand Storage",function(hrp)
	local position=Vector3.new(-303.451843,213.252747,109.062027)
	hrp.CFrame=CFrame.new(position+Vector3.new(4,5,0))
end)
createButton("❌ Destroy GUI",function()
	container:Destroy()
end)
toggleButton.MouseButton1Click:Connect(function()
	frame.Visible=not frame.Visible
end)
StarterGui:SetCore("SendNotification",{
	Title="Teleportation",
	Text="Teleportation Loaded Successfully ✅",
	Duration=4
})