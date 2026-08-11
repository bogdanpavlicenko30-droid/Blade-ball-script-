-- Blade Ball Auto Parry (Delta Optimized)
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
    ParryDistance = 28,
    ParryDelay = 0.03,
    FOVCheck = true,
    FOVSize = 130,
    Notify = true
}

local Ball = nil
local LastParry = 0
local Started = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuakksBladeBall"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 320, 0, 390)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(70, 130, 255)
stroke.Thickness = 1.4
stroke.Transparency = 0.25

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundTransparency = 1
Title.Text = "made by @quakks"
Title.TextColor3 = Color3.fromRGB(170, 195, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 18)
SubTitle.Position = UDim2.new(0, 0, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Blade Ball • Auto Parry"
SubTitle.TextColor3 = Color3.fromRGB(110, 120, 150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 200, 0, 44)
StartBtn.Position = UDim2.new(0.5, -100, 0.5, -22)
StartBtn.BackgroundColor3 = Color3.fromRGB(45, 105, 255)
StartBtn.Text = "НАЧАТЬ"
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 16
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 8)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -28, 1, -95)
Content.Position = UDim2.new(0, 14, 0, 72)
Content.BackgroundTransparency = 1
Content.Visible = false
Content.Parent = MainFrame

local layout = Instance.new("UIListLayout", Content)
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -58, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(215, 220, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 22)
    btn.Position = UDim2.new(1, -46, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 130, 255) or Color3.fromRGB(40, 40, 50)
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
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundColor3 = state and Color3.fromRGB(50, 130, 255) or Color3.fromRGB(40, 40, 50)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.18), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        callback(state)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(215, 220, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.Position = UDim2.new(0, 0, 0, 26)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
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
CreateSlider("Parry Distance", 12, 55, 28, function(v) Settings.ParryDistance = v end)
CreateSlider("Parry Delay (ms)", 0, 80, 30, function(v) Settings.ParryDelay = v / 1000 end)
CreateToggle("FOV Check", true, function(v) Settings.FOVCheck = v end)
CreateSlider("FOV Size", 50, 200, 130, function(v) Settings.FOVSize = v end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 22)
Status.BackgroundTransparency = 1
Status.Text = "Status: Waiting"
Status.TextColor3 = Color3.fromRGB(90, 190, 120)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Content

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 26, 0, 26)
Close.Position = UDim2.new(1, -34, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(190, 190, 200)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.Parent = MainFrame
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

StartBtn.MouseButton1Click:Connect(function()
    Started = true
    StartBtn.Visible = false
    Content.Visible = true
    Title.Text = "Blade Ball"
    SubTitle.Text = "made by @quakks"
end)

-- Ball finder
local function GetBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n == "ball" or n:find("ball") or n:find("sphere") then
                if obj.Size.Magnitude > 1.5 and obj.Size.Magnitude < 20 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Parry (Delta friendly)
local function PerformParry()
    if tick() - LastParry < Settings.ParryDelay then return end
    LastParry = tick()

    -- Method 1: VirtualInputManager (лучше всего на Delta)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)

    -- Method 2: Remote fallback
    pcall(function()
        for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") then
                local name = r.Name:lower()
                if name:find("parry") or name:find("block") or name:find("ability") or name:find("click") then
                    r:FireServer()
                    break
                end
            end
        end
    end)

    if Settings.Notify then
        Status.Text = "Status: Parried"
        task.delay(0.35, function()
            if Settings.AutoParry then Status.Text = "Status: Active" end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not Started or not Settings.AutoParry then
        Status.Text = Started and "Status: Idle" or "Status: Waiting"
        return
    end

    Status.Text = "Status: Active"
    Ball = GetBall()
    if not Ball or not Ball.Parent then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local dist = (Ball.Position - root.Position).Magnitude
    if dist > Settings.ParryDistance then return end

    local vel = Ball.AssemblyLinearVelocity or Ball.Velocity
    if vel.Magnitude < 8 then return end

    local toPlayer = (root.Position - Ball.Position).Unit
    if vel.Unit:Dot(toPlayer) < 0.25 then return end

    if Settings.FOVCheck then
        local sp, onScreen = Camera:WorldToViewportPoint(Ball.Position)
        if not onScreen then return end
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if (Vector2.new(sp.X, sp.Y) - center).Magnitude > Settings.FOVSize then return end
    end

    PerformParry()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P then
        Settings.AutoParry = not Settings.AutoParry
    end
end)

print("[@quakks] Delta version loaded")
