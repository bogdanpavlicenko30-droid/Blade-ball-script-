-- Blade Ball Auto Parry (Fixed + Anti-Kick)
-- made by @quakks

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Settings = {
    AutoParry = false,
    ParryDistance = 22,
    ParryDelay = 0.08,
    FOVCheck = true,
    FOVSize = 110,
    RandomDelay = true
}

local Ball = nil
local LastParry = 0
local Started = false
local Minimized = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuakksBB"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 300, 0, 360)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(60, 120, 255)
stroke.Thickness = 1.3
stroke.Transparency = 0.3

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 36)
Title.Position = UDim2.new(0, 12, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "made by @quakks"
Title.TextColor3 = Color3.fromRGB(160, 190, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -70, 0, 16)
SubTitle.Position = UDim2.new(0, 12, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Blade Ball"
SubTitle.TextColor3 = Color3.fromRGB(100, 110, 140)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = MainFrame

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -68, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -70)
Content.Position = UDim2.new(0, 12, 0, 58)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local layout = Instance.new("UIListLayout", Content)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -52, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(210, 215, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 22)
    btn.Position = UDim2.new(1, -44, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(45, 120, 255) or Color3.fromRGB(38, 38, 48)
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(45, 120, 255) or Color3.fromRGB(38, 38, 48)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        callback(state)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(210, 215, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

CreateToggle("Auto Parry", false, function(v) Settings.AutoParry = v end)
CreateSlider("Parry Distance", 12, 40, 22, function(v) Settings.ParryDistance = v end)
CreateSlider("Parry Delay (ms)", 40, 150, 80, function(v) Settings.ParryDelay = v / 1000 end)
CreateToggle("FOV Check", true, function(v) Settings.FOVCheck = v end)
CreateSlider("FOV Size", 60, 180, 110, function(v) Settings.FOVSize = v end)
CreateToggle("Random Delay", true, function(v) Settings.RandomDelay = v end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.BackgroundTransparency = 1
Status.Text = "Status: Idle"
Status.TextColor3 = Color3.fromRGB(80, 180, 110)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Content

-- Minimize logic
local FullSize = MainFrame.Size
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        Content.Visible = false
        MainFrame.Size = UDim2.new(0, 300, 0, 42)
        MinBtn.Text = "+"
    else
        Content.Visible = true
        MainFrame.Size = FullSize
        MinBtn.Text = "–"
    end
end)

-- Ball finder (improved)
local function GetBall()
    local closest = nil
    local closestDist = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if (name:find("ball") or name:find("sphere") or name == "ball") and obj.Size.Magnitude > 1.8 and obj.Size.Magnitude < 18 then
                local dist = (obj.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end
    end
    return closest
end

-- Safer Parry
local function PerformParry()
    local now = tick()
    local delay = Settings.ParryDelay
    if Settings.RandomDelay then
        delay = delay + math.random(10, 35) / 1000
    end
    if now - LastParry < delay then return end
    LastParry = now

    -- Method 1 (safer)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.012)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)

    -- Method 2 (fallback)
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        for _, r in ipairs(remotes:GetDescendants()) do
            if r:IsA("RemoteEvent") then
                local n = r.Name:lower()
                if n:find("parry") or n:find("block") or n:find("ability") then
                    r:FireServer()
                    break
                end
            end
        end
    end)

    Status.Text = "Status: Parried"
    task.delay(0.4, function()
        if Settings.AutoParry then
            Status.Text = "Status: Active"
        end
    end)
end

-- Main loop (slower & safer)
local lastCheck = 0
RunService.Heartbeat:Connect(function()
    if not Settings.AutoParry then
        Status.Text = "Status: Idle"
        return
    end

    if tick() - lastCheck < 0.03 then return end
    lastCheck = tick()

    Status.Text = "Status: Active"

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    Ball = GetBall()
    if not Ball or not Ball.Parent then return end

    local dist = (Ball.Position - root.Position).Magnitude
    if dist > Settings.ParryDistance then return end

    local vel = Ball.AssemblyLinearVelocity or Ball.Velocity
    if not vel or vel.Magnitude < 12 then return end

    local toPlayer = (root.Position - Ball.Position).Unit
    local incoming = vel.Unit:Dot(toPlayer)
    if incoming < 0.35 then return end

    if Settings.FOVCheck then
        local screenPos, onScreen = Camera:WorldToViewportPoint(Ball.Position)
        if not onScreen then return end
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude > Settings.FOVSize then return end
    end

    PerformParry()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P then
        Settings.AutoParry = not Settings.AutoParry
    end
end)

print("[@quakks] Fixed version loaded")
