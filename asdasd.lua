local Key = ...
local HWID = (gethwid and gethwid()) or "unknown_hwid"

-- If HWID is "unknown_hwid", set it to nil
if HWID == "unknown_hwid" then
    HWID = nil  -- Set HWID to nil so that the GitHub script can handle it
end

-- Debugging the HWID before sending to validation
print("Local HWID:", HWID)

-- Load the validation function from GitHub
local source = game:HttpGet("https://raw.githubusercontent.com/jazminelove/robloxauth/refs/heads/main/keyauth.lua")

local validateKeyFunc, err = loadstring(source)
if not validateKeyFunc then
    warn("Failed to load validateKey function:", err)
    return
end

-- Get the validateKey function
local validateKey = validateKeyFunc()
if type(validateKey) ~= "function" then
    warn("Returned value is not a function")
    return
end

-- Validate the key and HWID (Pass nil if HWID is not available)
local accessGranted = validateKey(Key, HWID)

if not accessGranted then
    warn("Invalid key or HWID")
    return
end

print("Access granted for key:", Key)

local http_request = http_request or request or httprequest
local webhookUrl = "https://discord.com/api/webhooks/1368743735516725288/d18GNgne8OQ9lFSDjbGbegUyehFKOtAUw4LZdn09Y7At2SbbkiVeCM3QAnKt0OKYGwFK"

-- Function to get the HWID (Client ID)
local function getHWID()
    local success, clientId = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if success and clientId then
        return clientId
    end
    return "unknown_hwid"
end

-- Function to send the data to Discord (with a mention)
local function sendToDiscord(username, hwid, key)
    local data = {
        -- Adjusted content for new line before the username
        content = "<@1370091542882287707>\nUsername: **" .. username .. "**\nHWID (Client ID): **" .. hwid .. "**\nKey: **" .. key .. "**"
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(data)

    -- Debugging: Print the final message content before sending
    print("Sending to Discord:", data.content)

    pcall(function()
        http_request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end)
end

-- Collect the username, HWID, and Key
local username = game.Players.LocalPlayer.Name
local hwid = getHWID()
local Key = Key or "unknown_key" -- Ensure Key is not nil

-- Send the data to Discord
sendToDiscord(username, hwid, Key)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerCashDisplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local espEnabled = false
local previousTargetPlayer = nil  -- Keeps track of the previous target player
local highlightColor = Color3.new(255, 255, 255)  -- Default highlight color
local textSize = 14  -- Default text size

local isSpectating = false
local lastSpectatedPlayer = nil  -- Track the player we are currently spectating
local currentSpectatedPlayer = nil  -- Track the player we are trying to spectate with the button
local originalCameraType = game.Workspace.CurrentCamera.CameraType
local originalCameraSubject = game.Workspace.CurrentCamera.CameraSubject

local noclipEnabled = false
local noclipConnection

local dropFolder = workspace:WaitForChild("Ignored"):WaitForChild("Drop")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)  -- Very dark color
frame.BorderSizePixel = 0  -- No border
frame.Active = true
frame.Draggable = false
frame.Parent = screenGui

local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    if dragging then
        local delta = input.Position - dragStart
        local targetPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

        local tweenInfo = TweenInfo.new(
            0.2,  -- Duration of the smooth animation
            Enum.EasingStyle.Quad,  -- Easing style for smooth movement
            Enum.EasingDirection.Out  -- Easing direction for a smooth start and stop
        )
        
        local tween = TweenService:Create(frame, tweenInfo, {Position = targetPosition})
        tween:Play()
    end
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput then
        update(input)
    end
end)

local function smoothBackgroundHover(button, hoverColor)
	local originalColor = button.BackgroundColor3
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverColor}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, tweenInfo, {BackgroundColor3 = originalColor}):Play()
	end)
end

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0.05, 0)  -- Less round edges
frameCorner.Parent = frame

local welcomeMessage = Instance.new("TextLabel")
welcomeMessage.Size = UDim2.new(1, 0, 0, 85)
welcomeMessage.Position = UDim2.new(0, 0, 0.25, 0)
welcomeMessage.BackgroundTransparency = 1
welcomeMessage.TextColor3 = Color3.fromRGB(255, 105, 180)  -- Pink color
welcomeMessage.Font = Enum.Font.SourceSansBold  -- Bold font
welcomeMessage.TextScaled = true
welcomeMessage.Text = "WELCOME\n " .. player.Name
welcomeMessage.Parent = frame
welcomeMessage.TextTransparency = 1 -- Start fully transparent

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 125, 0, 125)  -- Set size to 80x80 (equal width and height for circle)
avatarImage.Position = UDim2.new(0.5, -63, 0.55, 0)
avatarImage.BackgroundTransparency = 1
avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
avatarImage.ScaleType = Enum.ScaleType.Fit
avatarImage.Parent = frame
avatarImage.ImageTransparency = 1 -- Start fully transparent

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)  -- 0.5 will make the ImageLabel circular
corner.Parent = avatarImage  -- Parent the UICorner to the ImageLabelcaleType.Fit
avatarImage.Parent = frame

local tweenInfoWelcome = TweenInfo.new(
    2.5,  -- Duration of 1.5 seconds for smoother transition
    Enum.EasingStyle.Quad,  -- Easing style for a smooth easing effect
    Enum.EasingDirection.Out,  -- Easing direction for smooth out movement
    0,  -- No repeats
    false,  -- No reversal
    0  -- No delay
)
local goalWelcome = {
    Position = UDim2.new(0, 0, 0.2, 0),  -- Move up to new position
    TextTransparency = 0  -- Fade in text (make it fully visible)
}

local tweenWelcome = TweenService:Create(welcomeMessage, tweenInfoWelcome, goalWelcome)
tweenWelcome:Play()

task.wait(0.5)

local tweenInfoAvatar = TweenInfo.new(
    2.5,  -- Duration of 1.5 seconds for smoother transition
    Enum.EasingStyle.Quad,  -- Easing style for smooth transition
    Enum.EasingDirection.Out,  -- Easing direction for smooth out movement
    0,  -- No repeats
    false,  -- No reversal
    0  -- No delay
)
local goalAvatar = {
    Position = UDim2.new(0.5, -63, 0.5, 0),  -- Move avatar into place
    ImageTransparency = 0  -- Fade in the avatar image (make it visible)
}

local tweenAvatar = TweenService:Create(avatarImage, tweenInfoAvatar, goalAvatar)
tweenAvatar:Play()

task.wait(4)  -- Delay before fading out the welcome message

TweenService:Create(welcomeMessage, TweenInfo.new(1), {TextTransparency = 1}):Play()
TweenService:Create(avatarImage, TweenInfo.new(1), {ImageTransparency = 1}):Play()

task.wait(1)  -- Wait for 1 second after fading out the welcome message

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.AnchorPoint = Vector2.new(1, 0)  -- Aligns to the top-right
titleLabel.Position = UDim2.new(1, -115, 0, -2)  -- Position it 10px from the right and top
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.Text = "愛い"
titleLabel.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 15)
titleLabel.AnchorPoint = Vector2.new(1, 0)  -- Aligns to the top-right
titleLabel.Position = UDim2.new(1, -15, 0, 13)  -- Position it 10px from the right and top
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.Text = "love rawri, and RAMUNE!"
titleLabel.Parent = frame

local circleFrame = Instance.new("Frame")
circleFrame.Size = UDim2.new(0, 300, 0, 60) -- expanded width
circleFrame.Position = UDim2.new(0, 0, 1, 32)
circleFrame.AnchorPoint = Vector2.new(0, 0.5)
circleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
circleFrame.BackgroundTransparency = 0
circleFrame.ClipsDescendants = false
circleFrame.Parent = frame

local circleFrameCorner = Instance.new("UICorner")
circleFrameCorner.CornerRadius = UDim.new(0.2, 0)
circleFrameCorner.Parent = circleFrame

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 60, 0, 60)
avatarImage.Position = UDim2.new(0, 0, 0, 0)
avatarImage.BackgroundTransparency = 1
avatarImage.Image = Players:GetUserThumbnailAsync(
	player.UserId,
	Enum.ThumbnailType.HeadShot,
	Enum.ThumbnailSize.Size420x420
)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.2, 0)
corner.Parent = avatarImage
avatarImage.Parent = circleFrame

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(0, 100, 0, 22)
usernameLabel.Position = UDim2.new(0, 70, 0, 5)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = string.upper(player.Name)
usernameLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
usernameLabel.TextSize = 16
usernameLabel.Font = Enum.Font.SourceSansBold
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.Parent = circleFrame

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(0, 100, 0, 20)
cashLabel.Position = UDim2.new(0, 70, 0, 20)
cashLabel.BackgroundTransparency = 1
cashLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cashLabel.TextSize = 14
cashLabel.Font = Enum.Font.SourceSansBold
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Parent = circleFrame

local function updateCashLabel()
	local cashAmount = player:WaitForChild("DataFolder"):WaitForChild("Currency").Value
	cashLabel.Text = "$" .. cashAmount
end
player:WaitForChild("DataFolder"):WaitForChild("Currency").Changed:Connect(updateCashLabel)
updateCashLabel()

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 100, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 7
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "IDLE"
statusLabel.Parent = circleFrame

local function updateStatus()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local bodyEffects = character and character:FindFirstChild("BodyEffects")
	local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")

	if humanoid then
		if ko and ko.Value == true then
			statusLabel.Text = "(KNOCKED)"
		elseif humanoid.MoveDirection.Magnitude > 0 then
			statusLabel.Text = "(WALKING)"
		else
			statusLabel.Text = "(IDLE)"
		end
	end
end

local function updateStatusPosition()
	-- Wait one frame to make sure TextBounds is updated
	task.wait()
	local textWidth = usernameLabel.TextBounds.X
	statusLabel.Position = UDim2.new(0, usernameLabel.Position.X.Offset + textWidth + 5, 0, 5)
end

usernameLabel:GetPropertyChangedSignal("Text"):Connect(updateStatusPosition)

updateStatusPosition()

game:GetService("RunService").Heartbeat:Connect(function()
    updateStatus()  -- Run the status update function
    task.wait(5)  -- Wait for 0.2 seconds before running again (adjust as needed)
end)

local runtimeLabel = Instance.new("TextLabel")
runtimeLabel.Size = UDim2.new(0, 100, 0, 22)
runtimeLabel.BackgroundTransparency = 1
runtimeLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
runtimeLabel.TextSize = 9
runtimeLabel.Font = Enum.Font.SourceSansBold
runtimeLabel.TextXAlignment = Enum.TextXAlignment.Left
runtimeLabel.Text = "00:00:00"
runtimeLabel.Parent = circleFrame

local function updateRuntimePosition()
	task.wait()
	local xOffset = cashLabel.Position.X.Offset + cashLabel.TextBounds.X + 4
	runtimeLabel.Position = UDim2.new(0, xOffset, 0, cashLabel.Position.Y.Offset)
end

cashLabel:GetPropertyChangedSignal("Text"):Connect(updateRuntimePosition)
updateRuntimePosition()

local startTime = tick()
task.spawn(function()
	while true do
		local elapsed = math.floor(tick() - startTime)
		local hours = math.floor(elapsed / 3600)
		local minutes = math.floor((elapsed % 3600) / 60)
		local seconds = elapsed % 60
		runtimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
		task.wait(1)
	end
end)

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 30, 0, 15)
resetButton.Position = UDim2.new(0, 245, 0, 10)
resetButton.BackgroundTransparency = 0.5
resetButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
resetButton.TextColor3 = Color3.fromRGB(255, 105, 180)
resetButton.TextSize = 12
resetButton.Font = Enum.Font.SourceSansBold
resetButton.Text = "RESET"
resetButton.BorderSizePixel = 0
resetButton.AutoButtonColor = false -- disables hover effect
resetButton.Parent = circleFrame

resetButton.MouseButton1Click:Connect(function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0
	end
end)

local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0, 45, 0, 15)
noclipButton.Position = UDim2.new(0, 240, 0, 30)
noclipButton.BackgroundTransparency = 0.5
noclipButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
noclipButton.TextColor3 = Color3.fromRGB(255, 105, 180)
noclipButton.TextSize = 12
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.Text = "NOCLIP"
noclipButton.BorderSizePixel = 0
noclipButton.AutoButtonColor = false
noclipButton.Parent = circleFrame

noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled

	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			local character = player.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end

		local character = player.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end)

local prefixLabel = Instance.new("TextLabel")
prefixLabel.Size = UDim2.new(0.5, 100, 0, 0)
prefixLabel.Position = UDim2.new(0.5, -80, 0, 42)
prefixLabel.BackgroundTransparency = 1
prefixLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
prefixLabel.Font = Enum.Font.GothamBold
prefixLabel.TextSize = 9
prefixLabel.Text = "CASH DROPS :"
prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
prefixLabel.ZIndex = 10
prefixLabel.Parent = circleFrame

local amountLabel = Instance.new("TextLabel")
amountLabel.Size = UDim2.new(0, 160, 0, 50)
amountLabel.Position = UDim2.new(0.2, 26, -0.2, -25)
amountLabel.BackgroundTransparency = 1
amountLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
amountLabel.Font = Enum.Font.GothamBold
amountLabel.TextSize = 9
amountLabel.Text = "0"
amountLabel.TextXAlignment = Enum.TextXAlignment.Left
amountLabel.ZIndex = 10
amountLabel.Parent = prefixLabel

local function formatNumber(n)
	local formatted = tostring(n)
	while true do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

-- Recalculate the total cash from all money drops
local function recalculateTotalCash()
	local total = 0
	for _, drop in ipairs(dropFolder:GetChildren()) do
		if drop:IsA("Part") then
			local gui = drop:FindFirstChild("BillboardGui")
			if gui then
				local label = gui:FindFirstChild("TextLabel")
				if label then
					local text = label.Text
					local numberStr = text:gsub("[$,]", "")
					local value = tonumber(numberStr)
					if value then
						total += value
					end
				end
			end
		end
	end
	return total
end

-- Immediately set the label once on script start
amountLabel.Text = formatNumber(recalculateTotalCash())

-- Then continue updating every second
task.spawn(function()
	while true do
		local total = recalculateTotalCash()
		amountLabel.Text = formatNumber(total)
		task.wait(6)
	end
end)

local followerFrame = Instance.new("Frame")
followerFrame.Size = UDim2.new(0, 55, 0, 464)
followerFrame.Position = UDim2.new(0, -58, 0, 0)
followerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
followerFrame.BorderSizePixel = 0
followerFrame.ZIndex = 0
followerFrame.Parent = frame

local followerCorner = Instance.new("UICorner")
followerCorner.CornerRadius = UDim.new(0, 12)  -- Adjust for rounded corners
followerCorner.Parent = followerFrame

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 45, 0, 20)  -- Set the size of the button
teleportButton.Position = UDim2.new(0, -53, 0, 10)  -- Set the position where the button will appear
teleportButton.Text = "BANK"
teleportButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)  -- Green background for the button
teleportButton.TextColor3 = Color3.fromRGB(255, 105, 180)  -- White text color
teleportButton.Font = Enum.Font.SourceSansBold
teleportButton.TextScaled = true
teleportButton.ZIndex = 10
teleportButton.Parent = frame  -- Add the button to the frame

teleportButton.BorderSizePixel = 0  -- Removes the border
teleportButton.Selectable = false   -- Disables the focus ring

local function teleportToLocation()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-374.98095703125, 21.248018264770508, -343.658203125)
    end
end

teleportButton.MouseButton1Click:Connect(teleportToLocation)

local clubButton = Instance.new("TextButton")
clubButton.Size = UDim2.new(0, 45, 0, 20)
clubButton.Position = UDim2.new(0, -53, 0, 35) -- Static position, no tween
clubButton.Text = "CLUB"
clubButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
clubButton.TextColor3 = Color3.fromRGB(255, 105, 180)
clubButton.Font = Enum.Font.SourceSansBold
clubButton.TextScaled = true
clubButton.ZIndex = 10
clubButton.Parent = frame

clubButton.BorderSizePixel = 0  -- Removes the border
clubButton.Selectable = false   -- Disables the focus ring

clubButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-264.6902160644531, 0.02608632668852806, -421.73016357421875)
    end
end)

local milButton = Instance.new("TextButton")
milButton.Size = UDim2.new(0, 45, 0, 20)
milButton.Position = UDim2.new(0, -53, 0, 60) -- Static position, no tween
milButton.Text = "MILL"
milButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
milButton.TextColor3 = Color3.fromRGB(255, 105, 180)
milButton.Font = Enum.Font.SourceSansBold
milButton.TextScaled = true
milButton.ZIndex = 10
milButton.Parent = frame

milButton.BorderSizePixel = 0  -- Removes the border
milButton.Selectable = false   -- Disables the focus ring

milButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(26.793386459350586, 25.253023147583008, -882.3036499023438)
    end
end)

local revlButton = Instance.new("TextButton")
revlButton.Size = UDim2.new(0, 45, 0, 20)
revlButton.Position = UDim2.new(0, -53, 0, 85) -- Static position, no tween
revlButton.Text = "REVE"
revlButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
revlButton.TextColor3 = Color3.fromRGB(255, 105, 180)
revlButton.Font = Enum.Font.SourceSansBold
revlButton.TextScaled = true
revlButton.ZIndex = 10
revlButton.Parent = frame

revlButton.BorderSizePixel = 0  -- Removes the border
revlButton.Selectable = false   -- Disables the focus ring

revlButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-634.6885986328125, 21.74802589416504, -133.24075317382812)
    end
end)

local rpgButton = Instance.new("TextButton")
rpgButton.Size = UDim2.new(0, 45, 0, 20)
rpgButton.Position = UDim2.new(0, -53, 0, 110) -- Static position, no tween
rpgButton.Text = "RPG"
rpgButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
rpgButton.TextColor3 = Color3.fromRGB(255, 105, 180)
rpgButton.Font = Enum.Font.SourceSansBold
rpgButton.TextScaled = true
rpgButton.ZIndex = 10
rpgButton.Parent = frame

rpgButton.BorderSizePixel = 0  -- Removes the border
rpgButton.Selectable = false   -- Disables the focus ring

rpgButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(111.84397888183594, -26.75200653076172, -275.4105529785156)
    end
end)

local uphillButton = Instance.new("TextButton")
uphillButton.Size = UDim2.new(0, 45, 0, 20)
uphillButton.Position = UDim2.new(0, -53, 0, 135) -- Static position, no tween
uphillButton.Text = "UHILL"
uphillButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
uphillButton.TextColor3 = Color3.fromRGB(255, 105, 180)
uphillButton.Font = Enum.Font.SourceSansBold
uphillButton.TextScaled = true
uphillButton.ZIndex = 10
uphillButton.Parent = frame

uphillButton.BorderSizePixel = 0  -- Removes the border
uphillButton.Selectable = false   -- Disables the focus ring

uphillButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(481.19281005859375, 48.003013610839844, -589.7630615234375)
    end
end)

local downhillButton = Instance.new("TextButton")
downhillButton.Size = UDim2.new(0, 45, 0, 20)
downhillButton.Position = UDim2.new(0, -53, 0, 160) -- Static position, no tween
downhillButton.Text = "DHILL"
downhillButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
downhillButton.TextColor3 = Color3.fromRGB(255, 105, 180)
downhillButton.Font = Enum.Font.SourceSansBold
downhillButton.TextScaled = true
downhillButton.ZIndex = 10
downhillButton.Parent = frame

downhillButton.BorderSizePixel = 0  -- Removes the border
downhillButton.Selectable = false   -- Disables the focus ring

downhillButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-549.11767578125, 7.997873306274414, -742.3152465820312)
    end
end)

local highschoolButton = Instance.new("TextButton")
highschoolButton.Size = UDim2.new(0, 45, 0, 20)
highschoolButton.Position = UDim2.new(0, -53, 0, 185) -- Static position, no tween
highschoolButton.Text = "HIGHS"
highschoolButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
highschoolButton.TextColor3 = Color3.fromRGB(255, 105, 180)
highschoolButton.Font = Enum.Font.SourceSansBold
highschoolButton.TextScaled = true
highschoolButton.ZIndex = 10
highschoolButton.Parent = frame

highschoolButton.BorderSizePixel = 0  -- Removes the border
highschoolButton.Selectable = false   -- Disables the focus ring

highschoolButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-603.8748168945312, 21.74802017211914, 138.74754333496094)
    end
end)

local trainButton = Instance.new("TextButton")
trainButton.Size = UDim2.new(0, 45, 0, 20)
trainButton.Position = UDim2.new(0, -53, 0, 210) -- Static position, no tween
trainButton.Text = "TRAIN"
trainButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
trainButton.TextColor3 = Color3.fromRGB(255, 105, 180)
trainButton.Font = Enum.Font.SourceSansBold
trainButton.TextScaled = true
trainButton.ZIndex = 10
trainButton.Parent = frame

trainButton.BorderSizePixel = 0  -- Removes the border
trainButton.Selectable = false   -- Disables the focus ring

trainButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(611.118408203125, 47.99801254272461, -105.4192123413086)
    end
end)

local armorButton = Instance.new("TextButton")
armorButton.Size = UDim2.new(0, 45, 0, 20)
armorButton.Position = UDim2.new(0, -53, 0, 235) -- Static position, no tween
armorButton.Text = "ARMR"
armorButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
armorButton.TextColor3 = Color3.fromRGB(255, 105, 180)
armorButton.Font = Enum.Font.SourceSansBold
armorButton.TextScaled = true
armorButton.ZIndex = 10
armorButton.Parent = frame

armorButton.BorderSizePixel = 0  -- Removes the border
armorButton.Selectable = false   -- Disables the focus ring

armorButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(418.6942443847656, 39.27721405029297, -5.0978240966796875)
    end
end)

local churchButton = Instance.new("TextButton")
churchButton.Size = UDim2.new(0, 45, 0, 20)
churchButton.Position = UDim2.new(0, -53, 0, 260) -- Static position, no tween
churchButton.Text = "CHRCH"
churchButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
churchButton.TextColor3 = Color3.fromRGB(255, 105, 180)
churchButton.Font = Enum.Font.SourceSansBold
churchButton.TextScaled = true
churchButton.ZIndex = 10
churchButton.Parent = frame

churchButton.BorderSizePixel = 0  -- Removes the border
churchButton.Selectable = false   -- Disables the focus ring

churchButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(205.62921142578125, 21.74802017211914, -80.03306579589844)
    end
end)

local treehouseButton = Instance.new("TextButton")
treehouseButton.Size = UDim2.new(0, 45, 0, 20)
treehouseButton.Position = UDim2.new(0, -53, 0, 285) -- Static position, no tween
treehouseButton.Text = "TREE"
treehouseButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
treehouseButton.TextColor3 = Color3.fromRGB(255, 105, 180)
treehouseButton.Font = Enum.Font.SourceSansBold
treehouseButton.TextScaled = true
treehouseButton.ZIndex = 10
treehouseButton.Parent = frame

treehouseButton.BorderSizePixel = 0  -- Removes the border
treehouseButton.Selectable = false   -- Disables the focus ring

treehouseButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-72.68193054199219, 55.37301254272461, -256.1567687988281)
    end
end)

local augButton = Instance.new("TextButton")
augButton.Size = UDim2.new(0, 45, 0, 20)
augButton.Position = UDim2.new(0, -53, 0, 310) -- Static position, no tween
augButton.Text = "AUG"
augButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
augButton.TextColor3 = Color3.fromRGB(255, 105, 180)
augButton.Font = Enum.Font.SourceSansBold
augButton.TextScaled = true
augButton.ZIndex = 10
augButton.Parent = frame

augButton.BorderSizePixel = 0  -- Removes the border
augButton.Selectable = false   -- Disables the focus ring

augButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-268.8354797363281, 52.261661529541016, -227.72640991210938)
    end
end)

local flameButton = Instance.new("TextButton")
flameButton.Size = UDim2.new(0, 45, 0, 20)
flameButton.Position = UDim2.new(0, -53, 0, 335) -- Static position, no tween
flameButton.Text = "FLAME"
flameButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
flameButton.TextColor3 = Color3.fromRGB(255, 105, 180)
flameButton.Font = Enum.Font.SourceSansBold
flameButton.TextScaled = true
flameButton.ZIndex = 10
flameButton.Parent = frame

flameButton.BorderSizePixel = 0  -- Removes the border
flameButton.Selectable = false   -- Disables the focus ring

flameButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-149.6748504638672, 53.80862808227539, -95.47990417480469)
    end
end)

local trailerButton = Instance.new("TextButton")
trailerButton.Size = UDim2.new(0, 45, 0, 20)
trailerButton.Position = UDim2.new(0, -53, 0, 360) -- Static position, no tween
trailerButton.Text = "HOUSE"
trailerButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
trailerButton.TextColor3 = Color3.fromRGB(255, 105, 180)
trailerButton.Font = Enum.Font.SourceSansBold
trailerButton.TextScaled = true
trailerButton.ZIndex = 10
trailerButton.Parent = frame

trailerButton.BorderSizePixel = 0  -- Removes the border
trailerButton.Selectable = false   -- Disables the focus ring

trailerButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-929.3622436523438, -4.876976013183594, 443.10418701171875)
    end
end)

local courtButton = Instance.new("TextButton")
courtButton.Size = UDim2.new(0, 45, 0, 20)
courtButton.Position = UDim2.new(0, -53, 0, 385) -- Static position, no tween
courtButton.Text = "COURT"
courtButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
courtButton.TextColor3 = Color3.fromRGB(255, 105, 180)
courtButton.Font = Enum.Font.SourceSansBold
courtButton.TextScaled = true
courtButton.ZIndex = 10
courtButton.Parent = frame

courtButton.BorderSizePixel = 0  -- Removes the border
courtButton.Selectable = false   -- Disables the focus ring

courtButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-837.3561401367188, 21.25301742553711, -570.8378295898438)
    end
end)

local hospitalButton = Instance.new("TextButton")
hospitalButton.Size = UDim2.new(0, 45, 0, 20)
hospitalButton.Position = UDim2.new(0, -53, 0, 410) -- Static position, no tween
hospitalButton.Text = "HOSPT"
hospitalButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
hospitalButton.TextColor3 = Color3.fromRGB(255, 105, 180)
hospitalButton.Font = Enum.Font.SourceSansBold
hospitalButton.TextScaled = true
hospitalButton.ZIndex = 10
hospitalButton.Parent = frame

hospitalButton.BorderSizePixel = 0  -- Removes the border
hospitalButton.Selectable = false   -- Disables the focus ring

hospitalButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(103.13690948486328, 22.798015594482422, -483.2322082519531)
    end
end)

local undergroundButton = Instance.new("TextButton")
undergroundButton.Size = UDim2.new(0, 45, 0, 20)
undergroundButton.Position = UDim2.new(0, -53, 0, 435) -- Static position, no tween
undergroundButton.Text = "SEWER"
undergroundButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
undergroundButton.TextColor3 = Color3.fromRGB(255, 105, 180)
undergroundButton.Font = Enum.Font.SourceSansBold
undergroundButton.TextScaled = true
undergroundButton.ZIndex = 10
undergroundButton.Parent = frame

undergroundButton.BorderSizePixel = 0  -- Removes the border
undergroundButton.Selectable = false   -- Disables the focus ring

undergroundButton.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-422.08013916015625, -21.25197982788086, 48.99519348144531)
    end
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0.87, 0) -- 100% width, 80% height
scrollFrame.Position = UDim2.new(0, 0, 0, 40) -- anchored at top
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
scrollFrame.ScrollBarThickness = 0
scrollFrame.Parent = frame

local cashHistory = {}
local openPopups = {}

local function formatCashAmount(amount)
    return tostring(amount)  -- Simply return the amount as a string without any formatting
end

local function toggleCashPopup(playerName)
    local popupName = "CashHistoryPopup_" .. playerName
    local existing = frame:FindFirstChild(popupName)

    if existing then
        existing:Destroy()
        openPopups[playerName] = nil
        return
    end

    -- If there is any other open popup, close it
    for otherPlayerName, openPopup in pairs(openPopups) do
        if openPopup then
            openPopup:Destroy()  -- Destroy any currently open popup
            openPopups[otherPlayerName] = nil  -- Remove it from the openPopups table
        end
    end

    local popup = Instance.new("Frame")
    popup.Name = popupName
    popup.Size = UDim2.new(0, 250, 0, 300)
    popup.Position = UDim2.new(0, frame.AbsoluteSize.X + 10, 0, 0)
    popup.BackgroundColor3 = Color3.fromRGB(15, 15, 15)  -- Very dark color for the popup
    popup.BorderSizePixel = 0
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)  -- Less round edges
    popupCorner.Parent = popup
    popup.BackgroundTransparency = 1
    popup.BackgroundTransparency = 1
    popup.Position = UDim2.new(0, frame.AbsoluteSize.X + 10, 0, 25) -- starts below
    popup.Parent = frame
	
	local tweenInfo = TweenInfo.new(
		0.5,                              -- Duration
		Enum.EasingStyle.Quad,           -- Smoother acceleration
		Enum.EasingDirection.Out         -- Starts fast, slows down
	)

    TweenService:Create(popup, tweenInfo, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, frame.AbsoluteSize.X + 10, 0, 0) -- Slide into final Y position
    }):Play()

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "CASH INFO"
    title.TextColor3 = Color3.fromRGB(255, 105, 180)
    title.Font = Enum.Font.SourceSansBold
    title.TextScaled = true
    title.Parent = popup

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, -55)
    list.Position = UDim2.new(0, 0, 0, 55)
    list.CanvasSize = UDim2.new(0, 0, 0, 1000)
    list.ScrollBarThickness = 4
    list.BackgroundTransparency = 1
    list.Parent = popup

	local espButton = Instance.new("TextButton")
	espButton.Size = UDim2.new(0, 75, 0, 35)
	espButton.Position = UDim2.new(1.1, -105, 0.85, 0)  -- Positioned below teleport button
	espButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	espButton.Text = "CHAMS/ESP"
	espButton.Font = Enum.Font.SourceSansBold
	espButton.TextSize = 15
	espButton.TextColor3 = Color3.fromRGB(255, 108, 155)
	espButton.BackgroundTransparency = 1
	espButton.TextTransparency = 1
	espButton.Parent = popup  -- Parent the button to the popup GUI

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)  -- Adjust this value to change the roundness
	buttonCorner.Parent = espButton

	espButton.BorderSizePixel = 0  -- Removes the border
	espButton.Selectable = false   -- Disables the focus ring

	local function addESP(targetPlayer)
		if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			-- Create highlight effect
			local highlight = Instance.new("Highlight")
			highlight.Name = "ESP_Highlight"
			highlight.FillColor = highlightColor
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.OutlineTransparency = 0
			highlight.Parent = targetPlayer.Character

			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Name = "ESP_Billboard"
			billboardGui.Adornee = targetPlayer.Character.HumanoidRootPart
			billboardGui.Size = UDim2.new(0, 100, 0, 50)
			billboardGui.StudsOffset = Vector3.new(0, 3, 0)
			billboardGui.AlwaysOnTop = true

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.fromRGB(255, 105, 180)  -- Pink color
			textLabel.TextStrokeTransparency = 0.5
			textLabel.TextSize = textSize
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.Text = string.upper(targetPlayer.Name) .. " (" ..
				math.floor((targetPlayer.Character.HumanoidRootPart.Position - 
				game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m)"
			textLabel.Parent = billboardGui

			game:GetService("RunService").Heartbeat:Connect(function()
				if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local distance = math.floor((targetPlayer.Character.HumanoidRootPart.Position - 
						game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
					textLabel.Text = string.upper(targetPlayer.Name) .. " (" .. distance .. "m)"
				else
					-- If the target player or their character is no longer available, stop updating
					textLabel.Text = ""
				end
			end)

			billboardGui.Parent = targetPlayer.Character
		end
	end

	local function removeESP(targetPlayer)
		if targetPlayer.Character then
			if targetPlayer.Character:FindFirstChild("ESP_Highlight") then
				targetPlayer.Character.ESP_Highlight:Destroy()
			end
			if targetPlayer.Character:FindFirstChild("ESP_Billboard") then
				targetPlayer.Character.ESP_Billboard:Destroy()
			end
		end
	end

	espButton.MouseButton1Click:Connect(function()
		local targetPlayer = game.Players:FindFirstChild(playerName)  -- Ensure playerName is valid

		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			if previousTargetPlayer then
				removeESP(previousTargetPlayer)
			end

			if espEnabled and previousTargetPlayer == targetPlayer then
				removeESP(targetPlayer)  -- Remove ESP if it was already enabled
				espEnabled = false
				previousTargetPlayer = nil
			else
				addESP(targetPlayer)  -- Add ESP to the new target player
				espEnabled = true
				previousTargetPlayer = targetPlayer  -- Set the current player as the previous target
			end
		end
	end)

	smoothBackgroundHover(espButton, Color3.fromRGB(10, 10, 10))

	local teleportButton = Instance.new("TextButton")
	teleportButton.Size = UDim2.new(0, 75, 0, 35)
	teleportButton.Position = UDim2.new(0.8, -109, 0.85, 0)
	teleportButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	teleportButton.Text = "TELEPORT"
	teleportButton.Font = Enum.Font.SourceSansBold
	teleportButton.TextSize = 15
	teleportButton.TextColor3 = Color3.fromRGB(255, 108, 155)
	teleportButton.BackgroundTransparency = 1
	teleportButton.TextTransparency = 1
	teleportButton.Parent = popup

	local teleportCorner = Instance.new("UICorner")
	teleportCorner.CornerRadius = UDim.new(0, 7) -- Less round
	teleportCorner.Parent = teleportButton

	smoothBackgroundHover(teleportButton, Color3.fromRGB(10, 10, 10))

	teleportButton.MouseButton1Click:Connect(function()
		local targetPlayer = game.Players:FindFirstChild(playerName)
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
			game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
			print("Teleported to " .. playerName)
		end
	end)

		local spectateButton = Instance.new("TextButton")
		spectateButton.Size = UDim2.new(0, 75, 0, 35)
		spectateButton.Position = UDim2.new(0.45, -103, 0.85, 0)
		spectateButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		spectateButton.Text = "SPECTATE"
		spectateButton.Font = Enum.Font.SourceSansBold
		spectateButton.TextSize = 15
		spectateButton.TextColor3 = Color3.fromRGB(255, 105, 180)
		spectateButton.BackgroundTransparency = 1
		spectateButton.TextTransparency = 1
		spectateButton.Parent = popup

		local spectateCorner = Instance.new("UICorner")
		spectateCorner.CornerRadius = UDim.new(0, 7) -- Less round
		spectateCorner.Parent = spectateButton

		smoothBackgroundHover(spectateButton, Color3.fromRGB(10, 10, 10))

		local function startSpectating(player)
			if player and player.Character then
				local camera = game.Workspace.CurrentCamera
				camera.CameraSubject = player.Character.Humanoid
				camera.CameraType = Enum.CameraType.Custom
				lastSpectatedPlayer = player
				print("Now spectating " .. player.Name)
				isSpectating = true
			end
		end

		local function stopSpectating()
			local camera = game.Workspace.CurrentCamera
			camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
			camera.CameraType = Enum.CameraType.Custom
			print("Returned to original view.")
			isSpectating = false
			lastSpectatedPlayer = nil
		end

		spectateButton.MouseButton1Click:Connect(function()
			if currentSpectatedPlayer == lastSpectatedPlayer then
				stopSpectating()
			else
				startSpectating(currentSpectatedPlayer)
			end
		end)

		currentSpectatedPlayer = game.Players:FindFirstChild(playerName)

		local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		task.delay(0.12, function()
			-- Fade in SPECTATE button after 0.5s
			TweenService:Create(spectateButton, tweenInfo, {
				BackgroundTransparency = 0,
				TextTransparency = 0
			}):Play()

			task.delay(0.25, function()
				TweenService:Create(teleportButton, tweenInfo, {
					BackgroundTransparency = 0,
					TextTransparency = 0
				}):Play()
			end)

			-- Fade in ESP button after another 0.25s
			task.delay(0.40, function()
				TweenService:Create(espButton, tweenInfo, {
					BackgroundTransparency = 0,
					TextTransparency = 0
				}):Play()
			end)
		end)

	teleportButton.MouseButton1Click:Connect(function()
		local targetPlayer = game.Players:FindFirstChild(playerName)  -- Replace with the player name you're targeting
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			-- Teleport the local player to the target player's HumanoidRootPart
			local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
			game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
			print("Teleported to " .. playerName)  -- Optional: Print confirmation
		else
			print("Target player or their character is not available.")
		end
	end)

	spectateButton.MouseButton1Click:Connect(function()
	end)

    local cashMadeText = Instance.new("TextLabel")
    cashMadeText.Size = UDim2.new(1, 0, 0, 25)
    cashMadeText.Position = UDim2.new(0, 0, 0, 30)
    cashMadeText.BackgroundTransparency = 1
    cashMadeText.Font = Enum.Font.SourceSansBold
    cashMadeText.TextSize = 14
    cashMadeText.TextScaled = false
    cashMadeText.Text = "CASH MADE 0"
    cashMadeText.TextColor3 = Color3.fromRGB(255, 105, 180)  -- Set to white
    cashMadeText.Parent = popup

    cashMadeText.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Keep it white

local function updatePopup()
    local totalMade = 0
    for _, record in ipairs(cashHistory[playerName] or {}) do
        if record.delta > 0 then
            totalMade += record.delta
        end
    end

    cashMadeText.Text = "Cash Made This Session: " .. formatCashAmount(totalMade)
    list:ClearAllChildren()

    local yOffset = 0
    local itemHeight = 25  -- The height of each entry label

    for _, record in ipairs(cashHistory[playerName] or {}) do
        if record.delta < 0 and record.delta < -3000 then  -- For negative entries and only less than -1000
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, itemHeight)
            label.Position = UDim2.new(0, 10, 0, yOffset)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Default white before applying chroma
            label.Font = Enum.Font.SourceSansBold
			label.TextSize = 15  -- Change this number to adjust the text size (e.g., 24)
            label.Text = "- " .. formatCashAmount(math.abs(record.delta)) .. " deducted ⚠️"
            label.Parent = list
            label.TextColor3 = Color3.fromRGB(255, 255, 255)

            yOffset += itemHeight
        end
    end

    local availableHeight = scrollFrame.AbsoluteSize.Y - 100  -- Adjust 40 based on the bottom margin (space for buttons)
    yOffset = math.min(yOffset, availableHeight)

    list.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

if popup and popup.Parent then
    updatePopup()
end

local lastUpdate = 0
local updateInterval = 4

RunService.Heartbeat:Connect(function(deltaTime)
    lastUpdate += deltaTime
    if lastUpdate >= updateInterval then
        if popup and popup.Parent then
            updatePopup()
        end
        lastUpdate = 0
    end
end)

openPopups[playerName] = popup
end

local function updateDisplay()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local yOffset = 0
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local dataFolder = otherPlayer:FindFirstChild("DataFolder")
            local currency = dataFolder and dataFolder:FindFirstChild("Currency")
            if currency then
                local previous = cashHistory[otherPlayer.Name] and cashHistory[otherPlayer.Name][#cashHistory[otherPlayer.Name]]
                if not cashHistory[otherPlayer.Name] then cashHistory[otherPlayer.Name] = {} end
                if not previous or previous.amount ~= currency.Value then
                    table.insert(cashHistory[otherPlayer.Name], {
                        amount = currency.Value,
                        delta = previous and (currency.Value - previous.amount) or 0
                    })
                end

                local entry = Instance.new("Frame")
                entry.Size = UDim2.new(1, 0, 0, 60)
                entry.Position = UDim2.new(0, 0, 0, yOffset)
                entry.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                entry.BackgroundTransparency = 0.3
                entry.BorderSizePixel = 0
                entry.Parent = scrollFrame
                
                local hover = TweenService:Create(entry, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
                local unhover = TweenService:Create(entry, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)})
                
				entry.MouseEnter:Connect(function()
					-- Cancel the current tween if there is one
					if hover.PlaybackState == Enum.PlaybackState.Playing then
						hover:Cancel()
					end
					hover:Play()  -- Smooth transition to darker color
				end)

				entry.MouseLeave:Connect(function()
					-- Cancel the current tween if there is one
					if unhover.PlaybackState == Enum.PlaybackState.Playing then
						unhover:Cancel()
					end
					unhover:Play()  -- Smooth transition back to original color
				end)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
                nameLabel.Position = UDim2.new(0, 10, 0, 5)
                nameLabel.Text = otherPlayer.Name
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.TextScaled = true
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Parent = entry

				local locations = {
					BANK = Vector3.new(-380.15771484375, 21.248018264770508, -284.81219482421875),
					HOUSES = Vector3.new(-479.7799072265625, 21.248018264770508, -453.5369567871094),
					HOOD_FITNESS = Vector3.new(-74.5443344116211, 21.25301742553711, -568.432373046875),
					HOSPITAL = Vector3.new(46.349449157714844, 21.253023147583008, -484.109375),
					HOOD_KICKS = Vector3.new(-165.17092895507812, 21.25301742553711, -410.7854309082031),
					ARCADE = Vector3.new(-217.1468505859375, 21.25301742553711, -357.8340148925781),
					FIRE_DEPARTMENT = Vector3.new(-139.96763610839844, 21.27802085876465, -148.87583923339844),
					POLICE = Vector3.new(-255.05064392089844, 21.25301742553711, -150.84487915039062),
					HIGHSCHOOL = Vector3.new(-584.51025390625, 21.74802017211914, 143.91989135742188),
					FURNITURE_STORE = Vector3.new(-490.54302978515625, 21.25301742553711, -149.42538452148438),
					REV = Vector3.new(-615.6591186523438, 21.748023986816406, -135.1639404296875),
					THEATRE = Vector3.new(-1007.2385864257812, 21.25301742553711, -181.36109924316406),
					CASINO = Vector3.new(-863.6213989257812, 21.25301742553711, -188.6395263671875),
					FOOTBALL = Vector3.new(-748.83740234375, 22.278295516967773, -484.3514099121094),
					BASKETBALL = Vector3.new(-932.3101806640625, 21.997844696044922, -482.7280578613281),
					DOWNHILL = Vector3.new(-533.669921875, 7.552864074707031, -736.772216796875),
					PLAYGROUND = Vector3.new(-166.7949981689453, 21.25301742553711, -755.4473266601562),
					BOXING_CLUB = Vector3.new(-165.50279235839844, 21.25301742553711, -1119.03125),
					MILITARY = Vector3.new(42.86072540283203, 25.253023147583008, -875.8866577148438),
					RESTROOM = Vector3.new(220.64089965820312, 25.253023147583008, -916.6513671875),
					UPHILL = Vector3.new(481.9474792480469, 47.753013610839844, -568.9171752929688),
					GAS_STATION = Vector3.new(493.7346496582031, 47.753013610839844, -251.73886108398438),
					TRAIN = Vector3.new(493.7346496582031, 47.753013610839844, -251.73886108398438),
					CHURCH = Vector3.new(205.3927459716797, 21.27802085876465, -141.2115020751953),
					GRAVEYARD = Vector3.new(196.1808319091797, 21.748018264770508, 63.31427764892578),
					BARBA = Vector3.new(13.994160652160645, 21.27802276611328, -148.23802185058594),
					HOUSES = Vector3.new(-61.4205207824707, 37.00371551513672, -445.5301513671875),
					-- Add other locations here...
				}

				local locations = {
					BANK = Vector3.new(-380.15, 21.24, -284.81),
					HOUSES = Vector3.new(-61.42, 37.00, -445.53),
					["HOOD FITNESS"] = Vector3.new(-74.54, 21.25, -568.43),
					HOSPITAL = Vector3.new(46.34, 21.25, -484.10),
					["HOOD KICKS"] = Vector3.new(-165.17, 21.25, -410.78),
					ARCADE = Vector3.new(-217.14, 21.25, -357.83),
					["FIRE DEPARTMENT"] = Vector3.new(-139.96, 21.27, -148.87),
					POLICE = Vector3.new(-255.05, 21.25, -150.84),
					HIGHSCHOOL = Vector3.new(-584.51, 21.75, 143.91),
					["FURNITURE STORE"] = Vector3.new(-490.54, 21.25, -149.42),
					REV = Vector3.new(-615.65, 21.75, -135.16),
					THEATRE = Vector3.new(-1007.23, 21.25, -181.36),
					CASINO = Vector3.new(-863.62, 21.25, -188.63),
					FOOTBALL = Vector3.new(-748.83, 22.27, -484.35),
					BASKETBALL = Vector3.new(-932.31, 21.99, -482.72),
					DOWNHILL = Vector3.new(-533.67, 7.55, -736.77),
					PLAYGROUND = Vector3.new(-166.79, 21.25, -755.44),
					["BOXING CLUB"] = Vector3.new(-165.50, 21.25, -1119.03),
					MILITARY = Vector3.new(42.86, 25.25, -875.88),
					RESTROOM = Vector3.new(220.64, 25.25, -916.65),
					UPHILL = Vector3.new(481.94, 47.75, -568.91),
					["GAS STATION"] = Vector3.new(493.73, 47.75, -251.73),
					CHURCH = Vector3.new(205.39, 21.27, -141.21),
					GRAVEYARD = Vector3.new(196.18, 21.75, 63.31),
					BARBA = Vector3.new(13.99, 21.27, -148.23),
				}

				local locationLabel = Instance.new("TextLabel")
				locationLabel.Size = UDim2.new(0, 150, 0, 20)
				locationLabel.Position = UDim2.new(0, nameLabel.TextBounds.X + 20, 0, 5)
				locationLabel.BackgroundTransparency = 1
				locationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				locationLabel.Font = Enum.Font.SourceSansBold
				locationLabel.TextSize = 10
				locationLabel.TextScaled = false
				locationLabel.TextXAlignment = Enum.TextXAlignment.Left
				locationLabel.Parent = entry

				local function getClosestLocation(pos)
					local closestName = nil
					local closestDist = math.huge
					for name, locPos in pairs(locations) do
						local dist = (pos - locPos).Magnitude
						if dist < closestDist then
							closestName = name
							closestDist = dist
						end
					end
					return closestName
				end

				local lastLocation = nil

				task.spawn(function()
					while otherPlayer and otherPlayer.Parent do
						local char = otherPlayer.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						if hrp then
							local newLocation = getClosestLocation(hrp.Position)
							if newLocation and newLocation ~= lastLocation then
								locationLabel.Text = "AT " .. newLocation
								lastLocation = newLocation
							end
						end
						task.wait(2)
					end
				end)

				local itemsLabel = Instance.new("TextLabel")
				itemsLabel.Size = UDim2.new(0, 200, 0, 20)
				itemsLabel.Position = UDim2.new(0, nameLabel.TextBounds.X + 20, 0, 15) -- Below name/location
				itemsLabel.BackgroundTransparency = 1
				itemsLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
				itemsLabel.Font = Enum.Font.SourceSansBold
				itemsLabel.TextSize = 10
				itemsLabel.TextScaled = false
				itemsLabel.TextXAlignment = Enum.TextXAlignment.Left
				itemsLabel.Parent = entry

				local function abbreviateItemName(name)
					local map = {
						["TacticalShotgun"] = "Shotgun",
						["SilencedPistol"] = "Pistol",
						["AK47"] = "AK47",
						["Shotgun"] = "Shotgun",
						["Glock"] = "Glock",
						["Double-Barrel SG"] = "DB",
						-- Add more as needed
					}
					return map[name] or name
				end

				local function getHeldItems(player)
					local items = {}
					if player.Character then
						for _, tool in ipairs(player.Character:GetChildren()) do
							if tool:IsA("Tool") then
								local cleaned = tool.Name:gsub("%[", ""):gsub("%]", "")  -- Remove brackets
								local shortName = abbreviateItemName(cleaned)  -- Apply abbreviation if it exists
								table.insert(items, shortName)
							end
						end
					end
					return items
				end

				local function getPlayerMovementStatus(player)
					local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
					if humanoid and humanoid.MoveDirection.Magnitude > 0 then
						return "Walking"
					else
						return "Idle"
					end
				end

				task.spawn(function()
					local lastItems = ""
					while otherPlayer and otherPlayer.Parent do
						local heldItems = getHeldItems(otherPlayer)
						local itemStr = ""

						-- Check if player is holding any items
						if #heldItems > 0 then
							-- If holding items, display them
							itemStr = table.concat(heldItems, ", ")
						else
							-- If not holding items, show walking or idle status
							itemStr = getPlayerMovementStatus(otherPlayer)
						end
						
						-- Update the displayed item status
						if itemStr ~= lastItems then
							-- Only show the item text when there are items, else just show movement status
							if #heldItems > 0 then
								itemsLabel.Text = "Carrying " .. itemStr
							else
								itemsLabel.Text = itemStr
							end
							lastItems = itemStr
						end
						task.wait(1.5)
					end
				end)

				local cashLabel = Instance.new("TextLabel")
				cashLabel.Size = UDim2.new(0.6, 0, 0, 25)
				cashLabel.Position = UDim2.new(0, 10, 0, 30)
				cashLabel.BackgroundTransparency = 1
				cashLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
				cashLabel.Font = Enum.Font.SourceSansBold
				cashLabel.TextScaled = true
				cashLabel.Text = formatCashAmount(currency.Value)
				cashLabel.TextXAlignment = Enum.TextXAlignment.Left
				cashLabel.Parent = entry

				local image = Instance.new("ImageLabel")
				image.Size = UDim2.new(0, 50, 0, 50)  -- Set size to 35x35 (equal width and height for circle)
				image.Position = UDim2.new(0.9, -35, 0, 7)
				image.BackgroundTransparency = 1
				image.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. otherPlayer.UserId .. "&width=420&height=420&format=png"
				image.ScaleType = Enum.ScaleType.Fit
				image.Parent = entry

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0.5, 0)  -- 0.5 will make the ImageLabel circular
				corner.Parent = image  -- Parent the UICorner to the ImageLabel

				local clickHandler = Instance.new("TextButton")
				clickHandler.Size = UDim2.new(1, 0, 1, 0)
				clickHandler.Position = UDim2.new(0, 0, 0, 0)
				clickHandler.BackgroundTransparency = 1
				clickHandler.Text = ""
				clickHandler.MouseButton1Click:Connect(function() toggleCashPopup(otherPlayer.Name) end)
				clickHandler.Parent = entry

                yOffset += 60
            end
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

while true do
    updateDisplay()
    task.wait(5)
end
