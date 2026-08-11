--[[
   Blade Ball Ultimate — Auto Parry
   made by @quakks
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TextChatService = game:GetService("TextChatService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage

local ParryRemote = remotes:FindFirstChild("ParryButtonPress") or remotes:FindFirstChild("ParryPress") or remotes:FindFirstChild("Parry")
local AbilityRemote = remotes:FindFirstChild("AbilityButtonPress") or remotes:FindFirstChild("AbilityPress") or remotes:FindFirstChild("Ability")

local Config = {
    AutoParry = false,
    AutoAbility = false,
    UseRageDeflection = true,
    ParryDistance = 14,
    PredictionThreshold = 0.12,
    Visualizer = true,
    BallTrails = true,
}

local BallsFolder = workspace:FindFirstChild("Balls") or workspace:FindFirstChild("Ball") or workspace
local Started = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuakksBladeBall"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
MainFrame.BackgroundTransparency = 0.08
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 120, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Header
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 48)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
HeaderFrame.BackgroundTransparency = 0.2
HeaderFrame.Parent = MainFrame

local UICornerHeader = Instance.new("UICorner")
UICornerHeader.CornerRadius = UDim.new(0, 12)
UICornerHeader.Parent = HeaderFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "made by @quakks"
Title.TextColor3 = Color3.fromRGB(180, 200, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -70, 0, 16)
Subtitle.Position = UDim2.new(0, 16, 0, 26)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Blade Ball • Auto Parry"
Subtitle.TextColor3 = Color3.fromRGB(45, 120, 255)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = HeaderFrame

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = HeaderFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(180, 190, 210)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = HeaderFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Start Button (first screen)
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 180, 0, 42)
StartBtn.Position = UDim2.new(0.5, -90, 0.5, -21)
StartBtn.BackgroundColor3 = Color3.fromRGB(45, 110, 255)
StartBtn.Text = "НАЧАТЬ"
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 16
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 8)

-- Content
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -58)
ContentFrame.Position = UDim2.new(0, 10, 0, 53)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 120, 255)
ContentFrame.BorderSizePixel = 0
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ContentFrame.Visible = false
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.Parent = ContentFrame

local function CreateSection(text, order)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 28)
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = order
    Section.Parent = ContentFrame

    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, -10, 1, 0)
    SectionLabel.Position = UDim2.new(0, 8, 0, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = text
    SectionLabel.TextColor3 = Color3.fromRGB(45, 120, 255)
    SectionLabel.TextSize = 12
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = Section
end

local function CreateToggle(text, desc, default, order, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    ToggleFrame.BackgroundTransparency = 0.25
    ToggleFrame.LayoutOrder = order
    ToggleFrame.Parent = ContentFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -55, 0, 16)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 5)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 210, 235)
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -55, 0, 13)
    DescLabel.Position = UDim2.new(0, 12, 0, 22)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc
    DescLabel.TextColor3 = Color3.fromRGB(120, 130, 160)
    DescLabel.TextSize = 10
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 38, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -48, 0, 11)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(45, 120, 255) or Color3.fromRGB(40, 40, 55)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleFrame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 14, 0, 14)
    ToggleIndicator.Position = default and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
    ToggleIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleIndicator.Parent = ToggleBtn
    Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(1, 0)

    local toggled = default
    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        callback(toggled)
        local targetPos = toggled and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
        local targetColor = toggled and Color3.fromRGB(45, 120, 255) or Color3.fromRGB(40, 40, 55)
        TweenService:Create(ToggleIndicator, TweenInfo.new(0.18), {Position = targetPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
    end)
end

local function CreateSlider(text, desc, min, max, default, suffix, order, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 52)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    SliderFrame.BackgroundTransparency = 0.25
    SliderFrame.LayoutOrder = order
    SliderFrame.Parent = ContentFrame
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -60, 0, 15)
    SliderLabel.Position = UDim2.new(0, 12, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text
    SliderLabel.TextColor3 = Color3.fromRGB(200, 210, 235)
    SliderLabel.TextSize = 13
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 15)
    ValueLabel.Position = UDim2.new(1, -55, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. suffix
    ValueLabel.TextColor3 = Color3.fromRGB(45, 120, 255)
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -20, 0, 12)
    DescLabel.Position = UDim2.new(0, 12, 0, 21)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc
    DescLabel.TextColor3 = Color3.fromRGB(120, 130, 160)
    DescLabel.TextSize = 10
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = SliderFrame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -24, 0, 4)
    SliderBg.Position = UDim2.new(0, 12, 1, -12)
    SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    SliderBg.Parent = SliderFrame
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
    SliderFill.Parent = SliderBg
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * rel) * 100) / 100
            SliderFill.Size = UDim2.new(rel, 0, 1, 0)
            ValueLabel.Text = tostring(val) .. suffix
            callback(val)
        end
    end)
end

-- Build UI
local order = 0
CreateSection("PARRY SETTINGS", order); order = order + 1

CreateToggle("Auto Parry", "Автоматически отбивать мяч", false, order, function(v)
    Config.AutoParry = v
end); order = order + 1

CreateToggle("Auto Ability", "Авто-использование способностей", false, order, function(v)
    Config.AutoAbility = v
end); order = order + 1

CreateToggle("Rage Deflection", "Использовать Raging Deflection", true, order, function(v)
    Config.UseRageDeflection = v
end); order = order + 1

CreateSlider("Parry Distance", "Дистанция срабатывания", 5, 25, 14, " studs", order, function(v)
    Config.ParryDistance = v
end); order = order + 1

CreateSlider("Prediction", "Насколько заранее отбивать", 0.02, 0.35, 0.12, "s", order, function(v)
    Config.PredictionThreshold = v
end); order = order + 1

CreateSection("VISUALS", order); order = order + 1

CreateToggle("Ball Visualizer", "Показывать траекторию", true, order, function(v)
    Config.Visualizer = v
end); order = order + 1

CreateToggle("Trail Effects", "Подсветка мяча", true, order, function(v)
    Config.BallTrails = v
end); order = order + 1

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end)

-- Drag
local dragging, dragStart, startPos
HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize / Close
local minimized = false
local openSize = UDim2.new(0, 320, 0, 450)
local minSize = UDim2.new(0, 320, 0, 48)

MinBtn.MouseButton1Click:Connect(function()
    if not Started then return end
    minimized = not minimized
    local targetSize = minimized and minSize or openSize
    TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = targetSize}):Play()
    ContentFrame.Visible = not minimized
    MinBtn.Text = minimized and "+" or "–"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Start button
StartBtn.MouseButton1Click:Connect(function()
    Started = true
    StartBtn.Visible = false
    ContentFrame.Visible = true
    Title.Text = "Blade Ball"
    Subtitle.Text = "made by @quakks"
end)

-- ====================== CORE ======================

local focusedBall = nil
local parryCooldown = false
local lastParryTick = 0
local connectionManager = {}

local function isValidBall(ball)
    if not ball or not ball.Parent then return false end
    if not ball:IsA("BasePart") then return false end
    if ball:GetAttribute("realBall") == true then return true end
    if ball:GetAttribute("target") ~= nil then return true end
    local n = ball.Name:lower()
    if n:find("ball") then return true end
    return false
end

local function findBestBall()
    local bestBall, bestDist = nil, math.huge
    local char = Player.Character
    if not char or not char.PrimaryPart then return nil end

    for _, ball in ipairs(BallsFolder:GetChildren()) do
        if isValidBall(ball) then
            local dist = (ball.Position - char.PrimaryPart.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestBall = ball
            end
        end
    end
    return bestBall
end

local function fireParry()
    if not Config.AutoParry or not Started then return end
    if parryCooldown then return end

    local now = tick()
    if now - lastParryTick < 0.04 then return end

    parryCooldown = true
    lastParryTick = now

    if ParryRemote then
        pcall(function()
            ParryRemote:FireServer()
        end)
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.012)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)

    task.delay(0.03, function()
        parryCooldown = false
    end)
end

local function fireAbility()
    if not Config.AutoAbility then return end

    if AbilityRemote then
        pcall(function()
            AbilityRemote:FireServer()
        end)
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.012)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end)
end

local function predictImpact(ball, charPos, charVel)
    if not ball then return math.huge end

    local ballPos = ball.Position
    local ballVel = ball.AssemblyLinearVelocity or ball.Velocity
    local dist = (ballPos - charPos).Magnitude

    if dist < Config.ParryDistance then
        return 0
    end

    local dirToPlayer = (charPos - ballPos).Unit
    local speedTowardPlayer = ballVel:Dot(dirToPlayer) - (charVel and charVel:Dot(dirToPlayer) or 0)

    if speedTowardPlayer <= 0 then
        return math.huge
    end

    return (dist - Config.ParryDistance) / speedTowardPlayer
end

local function onHeartbeat()
    if not Started or not Config.AutoParry then return end

    local char = Player.Character
    if not char then return end

    local primaryPart = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
    if not primaryPart then return end

    local charPos = primaryPart.Position
    local charVel = primaryPart.AssemblyLinearVelocity or primaryPart.Velocity

    if not focusedBall or not focusedBall.Parent or not isValidBall(focusedBall) then
        focusedBall = findBestBall()
    end

    if not focusedBall then return end

    local timeToImpact = predictImpact(focusedBall, charPos, charVel)

    if timeToImpact < Config.PredictionThreshold then
        fireParry()

        if Config.UseRageDeflection and Config.AutoAbility then
            local abilities = char:FindFirstChild("Abilities")
            if abilities then
                local rage = abilities:FindFirstChild("Raging Deflection")
                if rage then
                    fireAbility()
                end
            end
        end
    end

    local dist = (focusedBall.Position - charPos).Magnitude
    if dist < Config.ParryDistance then
        fireParry()
    end
end

local function onBallAdded(ball)
    if not isValidBall(ball) then return end
    task.wait(0.04)

    local conn = ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not ball.Parent then
            if conn then conn:Disconnect() end
            return
        end
        if not Started or not Config.AutoParry then return end

        local char = Player.Character
        if not char or not char.PrimaryPart then return end

        local dist = (ball.Position - char.PrimaryPart.Position).Magnitude
        if dist < Config.ParryDistance then
            fireParry()
        end
    end)

    connectionManager[ball] = conn
end

local function onBallRemoved(ball)
    if connectionManager[ball] then
        connectionManager[ball]:Disconnect()
        connectionManager[ball] = nil
    end
    if focusedBall == ball then
        focusedBall = nil
    end
end

BallsFolder.ChildAdded:Connect(onBallAdded)
BallsFolder.ChildRemoved:Connect(onBallRemoved)

for _, ball in ipairs(BallsFolder:GetChildren()) do
    if isValidBall(ball) then
        onBallAdded(ball)
    end
end

RunService.Heartbeat:Connect(function()
    pcall(onHeartbeat)
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.8)
    focusedBall = nil
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[@quakks] Blade Ball loaded")
