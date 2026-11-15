end)
minimize.Activated:Connect(function() setMenuVisible(false) end)

local dragging, dragStart, startPosition = false, nil, nil
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)
connect(UIS.InputChanged, function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
			startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end
end)
connect(UIS.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local function hookPlayer(plr)
	if plr == player then return end
	connect(plr.CharacterAdded, function(char)
		if S.playerESP then
			setHighlight(char, "player", true)
			attachESPTag(char, plr.Name, Color3.fromRGB(80, 190, 255))
		end
	end)
end
for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end

connect(Players.PlayerAdded, function(plr)
	hookPlayer(plr)
	if S.currentPage == "Players" then refreshPage() end
end)
connect(Players.PlayerRemoving, function(plr)
	if S.selectedPlayer == plr then S.selectedPlayer = nil end
	task.delay(0.2, function()
		if S.currentPage == "Players" and gui.Parent then refreshPage() end
	end)
end)
connect(workspace.DescendantAdded, function(obj)
	if S.monsterESP and isMonster(obj) then setHighlight(obj, "monster", true) end
	local kind = classifyObject(obj)
	if kind and S[kind .. "ESP"] then
		task.defer(function() if obj.Parent then setObjectHighlight(obj, kind, true) end end)
	end
	if S.routeESP and isMonster(obj) then setRouteESP(true) end
end)

local function onCharacter(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	S.original.WalkSpeed = hum.WalkSpeed
	S.original.JumpPower = hum.JumpPower
	S.original.JumpHeight = hum.JumpHeight
	S.original.UseJumpPower = hum.UseJumpPower
	applyMovement()
	if S.godmode then
		local ff = char:FindFirstChild("DogV10_LocalForceField")
		if not ff then ff = Instance.new("ForceField"); ff.Name = "DogV10_LocalForceField"; ff.Visible = false; ff.Parent = char end
	end
	if hideChar then
		task.wait(0.5)
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end
		end
	end
end
connect(player.CharacterAdded, onCharacter)
if player.Character then task.spawn(onCharacter, player.Character) end

gui.Destroying:Connect(function()
	for _, c in ipairs(S.connections) do c:Disconnect() end
	if movementGuard then movementGuard:Disconnect() end
	if rainbowConn then rainbowConn:Disconnect() end
	if rainbowIconConn then rainbowIconConn:Disconnect() end
	if asmrSound then asmrSound:Stop(); asmrSound:Destroy(); asmrSound = nil end
	if S.godmodeConn then S.godmodeConn:Disconnect(); S.godmodeConn = nil end
	for _, line in pairs(routeParts) do if line and line.Parent then line:Destroy() end end
	for _, tag in pairs(espTags) do if tag and tag.Parent then tag:Destroy() end end
end)

local defaultId = CONFIG.DEFAULT_IMAGE_ID:match("%d+")
if defaultId then S.lastImageId = defaultId end
if S.lastImageId and S.lastImageId ~= "" then setMenuImage(S.lastImageId) end

task.spawn(function()
	local steps = {"Initializing", "Loading modules", "Building interface", "Almost ready"}
	for i = 1, 100 do
		if not gui.Parent then return end
		loadRingGradient.Rotation = (loadRingGradient.Rotation + 5) % 360
		loadRing.Color = Color3.fromHSV((i / 100) % 1, 0.9, 1)
		loadFill.Size = UDim2.new(i / 100, 0, 1, 0)
		percent.Text = i .. "%"
		loadStatus.Text = steps[math.min(#steps, math.ceil(i / 25))] .. "..."
		task.wait(0.02)
	end
	showPage("Visuals")
	main.Visible = true
	S.ready = true
	local fade = TweenService:Create(loading, TweenInfo.new(0.5), {GroupTransparency = 1})
	fade:Play()
	fade.Completed:Wait()
	loading:Destroy()
	notify("LOCKEDTOWER CHEAT PANEL loaded!", THEME.success)
end)
