local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Config = {
    AimBot = {
        Enabled = false,
        FOV = 35,
        Smooth = 0.45,
        VisibleCheck = false,
        Range = 15,
        OnKey = "",
        AimPart = "Head",
        Prediction = 0,
        WallPenetration = false
    },
    Silent = {
        Enabled = false,
        Range = 15.0,
        FOV = 35,
        Smooth = 0.45,
        VisibleCheck = false,
        OnKey = "",
        AimPart = "Head"
    },
    Trigger = {
        Enabled = false,
        Range = 20.0,
        FOV = 10,
        Delay = 50,
        VisibleCheck = false,
        OnKey = "",
        HitChance = 100
    },
    Chams = {
        Enabled = false,
        Mode = "Always",
        VisibleColor = Color3.fromRGB(0, 255, 0),
        HiddenColor = Color3.fromRGB(255, 0, 0),
        GlowIntensity = 0.5,
        Transparency = 0.3,
        OutlineTransparency = 0.5,
        Visible = true
    },
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Skeleton = false,
        Tracer = false,
        HeadDot = false,
        TeamCheck = false,
        MaxDistance = 100
    },
    AntiAim = {
        Enabled = false,
        Mode = "Jitter",
        Angle = 90,
        Pitch = 0,
        Yaw = 0,
        FakeLag = false,
        JitterAmount = 10
    },
    BunnyHop = {
        Enabled = false,
        HoldKey = "Spacebar",
        AutoJump = true
    },
    Speed = {
        Enabled = false,
        Speed = 50,
        Mode = "Walk",
        OnKey = ""
    },
    Fly = {
        Enabled = false,
        Speed = 50,
        OnKey = "",
        Toggle = false
    },
    NoClip = {
        Enabled = false,
        OnKey = ""
    },
    Watermark = {
        Enabled = true,
        Position = "TopLeft",
        FPS = true,
        Time = true,
        PlayerCount = true
    },
    Customization = {
        MenuColor = Color3.fromRGB(150, 200, 255),
        MenuTransparency = 0.95,
        AccentColor = Color3.fromRGB(100, 150, 255),
        Font = "Gotham"
    }
}

local MenuOpen = false
local SelectedTab = "Combat"
local ESPObjects = {}
local ChamsObjects = {}
local ESPActive = false
local ChamsActive = false
local WatermarkActive = false
local FlyActive = false
local NoClipActive = false
local SpeedActive = false
local AntiAimActive = false
local CurrentFPS = 0
local LastFrameTime = tick()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function MakeCircular(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
end

local function MakeShadow(frame)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045335"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.Parent = frame
    return shadow
end

local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 60, 0, 60)
CircleButton.Position = UDim2.new(0.02, 0, 0.5, -30)
CircleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
CircleButton.BackgroundTransparency = 0
CircleButton.BorderSizePixel = 2
CircleButton.BorderColor3 = Config.Customization.AccentColor
CircleButton.Image = "rbxassetid://0"
CircleButton.AutoButtonColor = false
CircleButton.Parent = ScreenGui
MakeCircular(CircleButton)

local ButtonGlow = Instance.new("ImageLabel")
ButtonGlow.Size = UDim2.new(1.3, 0, 1.3, 0)
ButtonGlow.Position = UDim2.new(-0.15, 0, -0.15, 0)
ButtonGlow.BackgroundTransparency = 1
ButtonGlow.Image = "rbxassetid://1316045335"
ButtonGlow.ImageColor3 = Config.Customization.AccentColor
ButtonGlow.ImageTransparency = 0.8
ButtonGlow.Parent = CircleButton

local CircleInner = Instance.new("ImageLabel")
CircleInner.Size = UDim2.new(1, -10, 1, -10)
CircleInner.Position = UDim2.new(0, 5, 0, 5)
CircleInner.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
CircleInner.BackgroundTransparency = 0
CircleInner.BorderSizePixel = 0
CircleInner.Image = "rbxassetid://0"
CircleInner.Parent = CircleButton
MakeCircular(CircleInner)

local HirukuText = Instance.new("TextLabel")
HirukuText.Size = UDim2.new(1, 0, 1, 0)
HirukuText.Position = UDim2.new(0, 0, 0, 0)
HirukuText.BackgroundTransparency = 1
HirukuText.Text = "H"
HirukuText.TextColor3 = Config.Customization.AccentColor
HirukuText.TextScaled = true
HirukuText.Font = Enum.Font.GothamBold
HirukuText.Parent = CircleInner

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
MainFrame.BackgroundTransparency = 1 - Config.Customization.MenuTransparency
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Config.Customization.AccentColor
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

MakeShadow(MainFrame)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BackgroundTransparency = 1 - Config.Customization.MenuTransparency
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hiruku Internal v2.0"
TitleText.TextColor3 = Config.Customization.AccentColor
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1, -70, 0.5, 0)
VersionText.Position = UDim2.new(0, 15, 0.5, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "Expires 19 days | NONE"
VersionText.TextColor3 = Color3.fromRGB(100, 100, 130)
VersionText.TextXAlignment = Enum.TextXAlignment.Right
VersionText.TextScaled = true
VersionText.Font = Enum.Font.Gotham
VersionText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 6.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TabBar.BackgroundTransparency = 1 - Config.Customization.MenuTransparency
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabNames = {"Combat", "Visuals", "Movement", "Misc", "Settings"}
local TabButtons = {}
local TabContents = {}

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 180)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 0)
    btnCorner.Parent = btn
    
    TabButtons[name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -85)
    content.Position = UDim2.new(0, 0, 0, 85)
    content.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Config.Customization.AccentColor
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = MainFrame
    TabContents[name] = content
end

local function CreateSlider(parent, title, configPath, min, max, decimal, description)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 45)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 48)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.5, 0, 0.4, 0)
        desc.Position = UDim2.new(0, 0, 0.6, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(100, 100, 130)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextScaled = true
        desc.Font = Enum.Font.Gotham
        desc.Parent = holder
    end
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.12, 0, 0.6, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.TextColor3 = Config.Customization.AccentColor
    val.TextScaled = true
    val.Font = Enum.Font.GothamBold
    val.Parent = holder
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.35, 0, 0.3, 0)
    slider.Position = UDim2.new(0.63, 0, 0.15, 0)
    slider.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    slider.BorderSizePixel = 0
    slider.Parent = holder
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Config.Customization.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local function updateSlider()
        local current = Config
        for _, v in ipairs(configPath) do current = current[v] end
        local percent = (current - min) / (max - min)
        fill.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
        if decimal then
            val.Text = string.format("%.2f", current)
        else
            val.Text = tostring(math.round(current))
        end
    end
    updateSlider()
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            if decimal then
                value = math.round(value / 0.01) * 0.01
            else
                value = math.round(value)
            end
            local current = Config
            for i = 1, #configPath - 1 do current = current[configPath[i]] end
            current[configPath[#configPath]] = value
            updateSlider()
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 48 + 20)
end

local function CreateToggle(parent, title, configPath, description)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 45)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 48)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.5, 0, 0.4, 0)
        desc.Position = UDim2.new(0, 0, 0.6, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(100, 100, 130)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextScaled = true
        desc.Font = Enum.Font.Gotham
        desc.Parent = holder
    end
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 22)
    toggle.Position = UDim2.new(0.82, 0, 0.25, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    toggle.BorderSizePixel = 0
    toggle.Parent = holder
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 18, 0, 18)
    check.Position = UDim2.new(0, 2, 0, 2)
    check.BackgroundColor3 = Config.Customization.AccentColor
    check.BorderSizePixel = 0
    check.Parent = toggle
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(1, 0)
    checkCorner.Parent = check
    
    local function updateToggle()
        local current = Config
        for _, v in ipairs(configPath) do current = current[v] end
        check.Visible = current
        if current then
            check.Position = UDim2.new(0, 20, 0, 2)
            toggle.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
            TweenService:Create(check, TweenInfo.new(0.2), {Position = UDim2.new(0, 20, 0, 2)}):Play()
        else
            check.Position = UDim2.new(0, 2, 0, 2)
            toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TweenService:Create(check, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
    end
    updateToggle()
    
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local current = Config
            for i = 1, #configPath - 1 do current = current[configPath[i]] end
            current[configPath[#configPath]] = not current[configPath[#configPath]]
            updateToggle()
            if configPath[1] == "ESP" and configPath[2] == "Enabled" then
                if Config.ESP.Enabled then EnableESP() else DisableESP() end
            end
            if configPath[1] == "Chams" and configPath[2] == "Enabled" then
                if Config.Chams.Enabled then EnableChams() else DisableChams() end
            end
            if configPath[1] == "Fly" and configPath[2] == "Enabled" then
                if Config.Fly.Enabled then EnableFly() else DisableFly() end
            end
            if configPath[1] == "NoClip" and configPath[2] == "Enabled" then
                if Config.NoClip.Enabled then EnableNoClip() else DisableNoClip() end
            end
            if configPath[1] == "Speed" and configPath[2] == "Enabled" then
                if Config.Speed.Enabled then EnableSpeed() else DisableSpeed() end
            end
            if configPath[1] == "AntiAim" and configPath[2] == "Enabled" then
                if Config.AntiAim.Enabled then EnableAntiAim() else DisableAntiAim() end
            end
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 48 + 20)
end

local function CreateDropdown(parent, title, configPath, options, description)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 45)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 48)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.5, 0, 0.4, 0)
        desc.Position = UDim2.new(0, 0, 0.6, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(100, 100, 130)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextScaled = true
        desc.Font = Enum.Font.Gotham
        desc.Parent = holder
    end
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.35, 0, 0.6, 0)
    dropdown.Position = UDim2.new(0.63, 0, 0.2, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    dropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdown.TextScaled = true
    dropdown.Font = Enum.Font.Gotham
    dropdown.BorderSizePixel = 0
    dropdown.Parent = holder
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 4)
    dropCorner.Parent = dropdown
    
    local current = Config
    for _, v in ipairs(configPath) do current = current[v] end
    dropdown.Text = current
    
    local expanded = false
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(0.35, 0, 0, 0)
    optionFrame.Position = UDim2.new(0.63, 0, 0.8, 0)
    optionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    optionFrame.BorderSizePixel = 1
    optionFrame.BorderColor3 = Color3.fromRGB(40, 40, 50)
    optionFrame.Visible = false
    optionFrame.ClipsDescendants = true
    optionFrame.Parent = holder
    
    local optCorner = Instance.new("UICorner")
    optCorner.CornerRadius = UDim.new(0, 4)
    optCorner.Parent = optionFrame
    
    local function updateOptions()
        for _, child in pairs(optionFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.Position = UDim2.new(0, 0, 0, (i-1) * 28)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = opt
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = optionFrame
            
            btn.MouseButton1Click:Connect(function()
                local current = Config
                for i = 1, #configPath - 1 do current = current[configPath[i]] end
                current[configPath[#configPath]] = opt
                dropdown.Text = opt
                expanded = false
                optionFrame.Visible = false
                optionFrame.Size = UDim2.new(0.35, 0, 0, 0)
                if configPath[1] == "Chams" and configPath[2] == "Mode" and Config.Chams.Enabled then
                    DisableChams()
                    EnableChams()
                end
                if configPath[1] == "AntiAim" and configPath[2] == "Mode" and Config.AntiAim.Enabled then
                    DisableAntiAim()
                    EnableAntiAim()
                end
            end)
        end
        optionFrame.Size = UDim2.new(0.35, 0, 0, #options * 28)
    end
    updateOptions()
    
    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionFrame.Visible = expanded
        if expanded then
            optionFrame.Size = UDim2.new(0.35, 0, 0, #options * 28)
        else
            optionFrame.Size = UDim2.new(0.35, 0, 0, 0)
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 48 + 20)
end

local function CreateKeybind(parent, title, configPath, description)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 45)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 48)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.5, 0, 0.4, 0)
        desc.Position = UDim2.new(0, 0, 0.6, 0)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(100, 100, 130)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextScaled = true
        desc.Font = Enum.Font.Gotham
        desc.Parent = holder
    end
    
    local keybind = Instance.new("TextButton")
    keybind.Size = UDim2.new(0.25, 0, 0.6, 0)
    keybind.Position = UDim2.new(0.73, 0, 0.2, 0)
    keybind.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    keybind.TextColor3 = Color3.fromRGB(200, 200, 200)
    keybind.TextScaled = true
    keybind.Font = Enum.Font.Gotham
    keybind.BorderSizePixel = 0
    keybind.Parent = holder
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keybind
    
    local current = Config
    for _, v in ipairs(configPath) do current = current[v] end
    if current == "" then
        keybind.Text = "None"
    else
        keybind.Text = current
    end
    
    local waiting = false
    keybind.MouseButton1Click:Connect(function()
        if not waiting then
            waiting = true
            keybind.Text = "Press key..."
            keybind.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            local current = Config
            for i = 1, #configPath - 1 do current = current[configPath[i]] end
            current[configPath[#configPath]] = key
            keybind.Text = key
            keybind.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            waiting = false
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 48 + 20)
end

local function CreateColorPicker(parent, title, configPath)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 45)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 48)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    local colorBtn = Instance.new("ImageButton")
    colorBtn.Size = UDim2.new(0, 40, 0, 30)
    colorBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
    colorBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    colorBtn.BorderSizePixel = 1
    colorBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
    colorBtn.Parent = holder
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorBtn
    
    local current = Config
    for _, v in ipairs(configPath) do current = current[v] end
    colorBtn.BackgroundColor3 = current
    
    colorBtn.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("Frame")
        colorPicker.Size = UDim2.new(0, 200, 0, 150)
        colorPicker.Position = UDim2.new(0.5, -100, 0.5, -75)
        colorPicker.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        colorPicker.BorderSizePixel = 1
        colorPicker.BorderColor3 = Color3.fromRGB(40, 40, 50)
        colorPicker.Parent = ScreenGui
        
        local pickerCorner = Instance.new("UICorner")
        pickerCorner.CornerRadius = UDim.new(0, 8)
        pickerCorner.Parent = colorPicker
        
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(0.8, 0, 0, 15)
        hueSlider.Position = UDim2.new(0.1, 0, 0.4, 0)
        hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        hueSlider.BorderSizePixel = 0
        hueSlider.Parent = colorPicker
        
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(1, 0)
        hueCorner.Parent = hueSlider
        
        local satSlider = Instance.new("Frame")
        satSlider.Size = UDim2.new(0.8, 0, 0, 15)
        satSlider.Position = UDim2.new(0.1, 0, 0.6, 0)
        satSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        satSlider.BorderSizePixel = 0
        satSlider.Parent = colorPicker
        
        local satCorner = Instance.new("UICorner")
        satCorner.CornerRadius = UDim.new(1, 0)
        satCorner.Parent = satSlider
        
        local colorPreview = Instance.new("ImageLabel")
        colorPreview.Size = UDim2.new(0, 40, 0, 30)
        colorPreview.Position = UDim2.new(0.1, 0, 0.15, 0)
        colorPreview.BackgroundColor3 = colorBtn.BackgroundColor3
        colorPreview.BorderSizePixel = 1
        colorPreview.BorderColor3 = Color3.fromRGB(200, 200, 200)
        colorPreview.Parent = colorPicker
        
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 4)
        previewCorner.Parent = colorPreview
        
        local hueVal = 0
        local satVal = 1
        
        local function updateColor()
            local color = Color3.fromHSV(hueVal, satVal, 1)
            colorPreview.BackgroundColor3 = color
            local current = Config
            for i = 1, #configPath - 1 do current = current[configPath[i]] end
            current[configPath[#configPath]] = color
            colorBtn.BackgroundColor3 = color
        end
        
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position.X - hueSlider.AbsolutePosition.X
                hueVal = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
                updateColor()
            end
        end)
        hueSlider.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Changed then
                local pos = input.Position.X - hueSlider.AbsolutePosition.X
                hueVal = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
                updateColor()
            end
        end)
        
        satSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position.X - satSlider.AbsolutePosition.X
                satVal = math.clamp(pos / satSlider.AbsoluteSize.X, 0, 1)
                updateColor()
            end
        end)
        satSlider.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Changed then
                local pos = input.Position.X - satSlider.AbsolutePosition.X
                satVal = math.clamp(pos / satSlider.AbsoluteSize.X, 0, 1)
                updateColor()
            end
        end)
        
        local closePicker = Instance.new("TextButton")
        closePicker.Size = UDim2.new(0.2, 0, 0.15, 0)
        closePicker.Position = UDim2.new(0.65, 0, 0.75, 0)
        closePicker.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        closePicker.Text = "Apply"
        closePicker.TextColor3 = Color3.fromRGB(200, 200, 200)
        closePicker.TextScaled = true
        closePicker.Font = Enum.Font.Gotham
        closePicker.BorderSizePixel = 0
        closePicker.Parent = colorPicker
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closePicker
        
        closePicker.MouseButton1Click:Connect(function()
            colorPicker:Destroy()
        end)
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 48 + 20)
end

local CombatTab = TabContents["Combat"]
CreateToggle(CombatTab, "AimBot", {"AimBot", "Enabled"}, "Auto aim at enemies")
CreateSlider(CombatTab, "Aim FOV", {"AimBot", "FOV"}, 1, 180, false, "Field of view for aimbot")
CreateSlider(CombatTab, "Aim Smooth", {"AimBot", "Smooth"}, 0, 1, true, "Smoothness of aiming")
CreateToggle(CombatTab, "Visible Check", {"AimBot", "VisibleCheck"}, "Only aim at visible enemies")
CreateSlider(CombatTab, "Range", {"AimBot", "Range"}, 1, 50, false, "Maximum range for aimbot")
CreateDropdown(CombatTab, "Aim Part", {"AimBot", "AimPart"}, {"Head", "Torso", "HumanoidRootPart"}, "Body part to aim at")
CreateToggle(CombatTab, "Wall Penetration", {"AimBot", "WallPenetration"}, "Aim through walls")
CreateToggle(CombatTab, "Silent Aim", {"Silent", "Enabled"}, "Invisible aimbot")
CreateSlider(CombatTab, "Silent Range", {"Silent", "Range"}, 1, 50, false, "Range for silent aim")
CreateSlider(CombatTab, "Silent FOV", {"Silent", "FOV"}, 1, 180, false, "FOV for silent aim")
CreateSlider(CombatTab, "Silent Smooth", {"Silent", "Smooth"}, 0, 1, true, "Smoothness for silent aim")
CreateToggle(CombatTab, "TriggerBot", {"Trigger", "Enabled"}, "Auto shoot when aiming at enemy")
CreateSlider(CombatTab, "Trigger Range", {"Trigger", "Range"}, 1, 50, false, "Range for triggerbot")
CreateSlider(CombatTab, "Trigger FOV", {"Trigger", "FOV"}, 1, 180, false, "FOV for triggerbot")
CreateSlider(CombatTab, "Trigger Delay", {"Trigger", "Delay"}, 10, 500, false, "Delay between shots")
CreateToggle(CombatTab, "Trigger Visible", {"Trigger", "VisibleCheck"}, "Only shoot visible enemies")

local VisualsTab = TabContents["Visuals"]
CreateToggle(VisualsTab, "ESP", {"ESP", "Enabled"}, "Show enemy information")
CreateToggle(VisualsTab, "ESP Box", {"ESP", "Box"}, "Draw box around enemies")
CreateToggle(VisualsTab, "ESP Name", {"ESP", "Name"}, "Show player names")
CreateToggle(VisualsTab, "ESP Health", {"ESP", "Health"}, "Show health bar")
CreateToggle(VisualsTab, "ESP Distance", {"ESP", "Distance"}, "Show distance to enemy")
CreateToggle(VisualsTab, "ESP Tracer", {"ESP", "Tracer"}, "Draw line to enemy")
CreateToggle(VisualsTab, "ESP Head Dot", {"ESP", "HeadDot"}, "Show dot on enemy head")
CreateToggle(VisualsTab, "Team Check", {"ESP", "TeamCheck"}, "Ignore teammates")
CreateSlider(VisualsTab, "ESP Max Distance", {"ESP", "MaxDistance"}, 1, 500, false, "Maximum distance for ESP")
CreateToggle(VisualsTab, "Chams", {"Chams", "Enabled"}, "Highlight enemies through walls")
CreateDropdown(VisualsTab, "Chams Mode", {"Chams", "Mode"}, {"Always", "Visible", "Glow", "Wireframe"}, "Chams display mode")
CreateSlider(VisualsTab, "Chams Transparency", {"Chams", "Transparency"}, 0, 1, true, "Transparency of chams")
CreateColorPicker(VisualsTab, "Visible Color", {"Chams", "VisibleColor"})
CreateColorPicker(VisualsTab, "Hidden Color", {"Chams", "HiddenColor"})

local MovementTab = TabContents["Movement"]
CreateToggle(MovementTab, "Bunny Hop", {"BunnyHop", "Enabled"}, "Auto jump when holding space")
CreateToggle(MovementTab, "Speed", {"Speed", "Enabled"}, "Increase movement speed")
CreateSlider(MovementTab, "Speed Value", {"Speed", "Speed"}, 10, 200, false, "Speed multiplier")
CreateDropdown(MovementTab, "Speed Mode", {"Speed", "Mode"}, {"Walk", "Sprint", "Crouch", "Swim"}, "Movement type to affect")
CreateKeybind(MovementTab, "Speed Key", {"Speed", "OnKey"}, "Key to toggle speed")
CreateToggle(MovementTab, "Fly", {"Fly", "Enabled"}, "Enable fly mode")
CreateSlider(MovementTab, "Fly Speed", {"Fly", "Speed"}, 10, 200, false, "Fly speed")
CreateKeybind(MovementTab, "Fly Key", {"Fly", "OnKey"}, "Key to toggle fly")
CreateToggle(MovementTab, "NoClip", {"NoClip", "Enabled"}, "Walk through walls")
CreateKeybind(MovementTab, "NoClip Key", {"NoClip", "OnKey"}, "Key to toggle noclip")

local MiscTab = TabContents["Misc"]
CreateToggle(MiscTab, "Anti-Aim", {"AntiAim", "Enabled"}, "Hide your real aim")
CreateDropdown(MiscTab, "Anti-Aim Mode", {"AntiAim", "Mode"}, {"Jitter", "Spin", "Fake", "Backwards"}, "Anti-aim mode")
CreateSlider(MiscTab, "Anti-Aim Angle", {"AntiAim", "Angle"}, 0, 180, false, "Angle to display")
CreateSlider(MiscTab, "Jitter Amount", {"AntiAim", "JitterAmount"}, 1, 30, false, "Jitter intensity")
CreateToggle(MiscTab, "Fake Lag", {"AntiAim", "FakeLag"}, "Add artificial lag")
CreateToggle(MiscTab, "Watermark", {"Watermark", "Enabled"}, "Show info on screen")

local SettingsTab = TabContents["Settings"]
CreateColorPicker(SettingsTab, "Menu Color", {"Customization", "MenuColor"})
CreateColorPicker(SettingsTab, "Accent Color", {"Customization", "AccentColor"})
CreateSlider(SettingsTab, "Menu Transparency", {"Customization", "MenuTransparency"}, 0.5, 1, true, "Menu opacity")
CreateDropdown(SettingsTab, "Font", {"Customization", "Font"}, {"Gotham", "Arial", "Comic Sans MS", "Times New Roman"}, "UI font")

function EnableESP()
    if ESPActive then return end
    ESPActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESPForPlayer(player)
        end
    end
end

function DisableESP()
    ESPActive = false
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    ESPObjects = {}
end

function CreateESPForPlayer(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    
    if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then return end
    
    local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if dist > Config.ESP.MaxDistance then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = char
    table.insert(ESPObjects, espFolder)
    
    if Config.ESP.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 5, 3)
        box.Adornee = root
        box.Color3 = Config.Customization.AccentColor
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.ZIndex = 0
        box.Parent = espFolder
        table.insert(ESPObjects, box)
    end
    
    if Config.ESP.Name then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 120, 0, 25)
        nameTag.Adornee = root
        nameTag.AlwaysOnTop = true
        nameTag.Parent = espFolder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = nameTag
        table.insert(ESPObjects, nameTag)
    end
    
    if Config.ESP.Health then
        local healthTag = Instance.new("BillboardGui")
        healthTag.Size = UDim2.new(0, 120, 0, 20)
        healthTag.Position = UDim2.new(0, 0, 0, 25)
        healthTag.Adornee = root
        healthTag.AlwaysOnTop = true
        healthTag.Parent = espFolder
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        healthBar.BackgroundTransparency = 0.5
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthTag
        
        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBar
        
        local healthCorner = Instance.new("UICorner")
        healthCorner.CornerRadius = UDim.new(0, 2)
        healthCorner.Parent = healthBar
        
        local healthFillCorner = Instance.new("UICorner")
        healthFillCorner.CornerRadius = UDim.new(0, 2)
        healthFillCorner.Parent = healthFill
        
        local healthText = Instance.new("TextLabel")
        healthText.Size = UDim2.new(1, 0, 1, 0)
        healthText.BackgroundTransparency = 1
        healthText.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
        healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthText.TextScaled = true
        healthText.Font = Enum.Font.Gotham
        healthText.Parent = healthBar
        
        table.insert(ESPObjects, healthTag)
    end
    
    if Config.ESP.Distance then
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0, 80, 0, 20)
        distTag.Position = UDim2.new(0, 0, 0, 45)
        distTag.Adornee = root
        distTag.AlwaysOnTop = true
        distTag.Parent = espFolder
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = math.floor(dist) .. "m"
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.TextScaled = true
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = distTag
        table.insert(ESPObjects, distTag)
    end
    
    if Config.ESP.HeadDot then
        local head = char:FindFirstChild("Head")
        if head then
            local dot = Instance.new("BillboardGui")
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Adornee = head
            dot.AlwaysOnTop = true
            dot.Parent = espFolder
            
            local dotImage = Instance.new("ImageLabel")
            dotImage.Size = UDim2.new(1, 0, 1, 0)
            dotImage.BackgroundTransparency = 1
            dotImage.Image = "rbxassetid://0"
            dotImage.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            dotImage.Parent = dot
            
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dotImage
            
            table.insert(ESPObjects, dot)
        end
    end
    
    if Config.ESP.Tracer then
        local tracer = Instance.new("LineHandleAdornment")
        tracer.Size = Vector3.new(1, 1, 1)
        tracer.Adornee = root
        tracer.Color3 = Config.Customization.AccentColor
        tracer.Transparency = 0.5
        tracer.AlwaysOnTop = true
        tracer.ZIndex = 0
        tracer.Parent = espFolder
        table.insert(ESPObjects, tracer)
    end
end

function EnableChams()
    if ChamsActive then return end
    ChamsActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateChamsForPlayer(player)
        end
    end
end

function DisableChams()
    ChamsActive = false
    for _, obj in pairs(ChamsObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    ChamsObjects = {}
end

function CreateChamsForPlayer(player)
    local char = player.Character
    if not char then return end
    if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = Config.Chams.VisibleColor
            highlight.FillTransparency = Config.Chams.Transparency
            highlight.OutlineColor = Config.Chams.HiddenColor
            highlight.OutlineTransparency = Config.Chams.OutlineTransparency
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = part
            table.insert(ChamsObjects, highlight)
        end
    end
end

function EnableFly()
    if FlyActive then return end
    FlyActive = true
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
    end
end

function DisableFly()
    FlyActive = false
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

function EnableNoClip()
    NoClipActive = true
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

function DisableNoClip()
    NoClipActive = false
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function EnableSpeed()
    SpeedActive = true
end

function DisableSpeed()
    SpeedActive = false
end

function EnableAntiAim()
    AntiAimActive = true
end

function DisableAntiAim()
    AntiAimActive = false
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, content in pairs(TabContents) do
            content.Visible = false
        end
        TabContents[name].Visible = true
        SelectedTab = name
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
            b.TextColor3 = Color3.fromRGB(150, 150, 180)
        end
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        btn.TextColor3 = Config.Customization.AccentColor
    end)
end

TabButtons["Combat"].BackgroundColor3 = Color3.fromRGB(30, 30, 50)
TabButtons["Combat"].TextColor3 = Config.Customization.AccentColor

local circleDragging = false
local circleDragOffset = nil

CircleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        circleDragging = true
        circleDragOffset = Vector2.new(
            input.Position.X - CircleButton.AbsolutePosition.X,
            input.Position.Y - CircleButton.AbsolutePosition.Y
        )
    end
end)

CircleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        circleDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if circleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPos = UDim2.new(
            0, input.Position.X - circleDragOffset.X,
            0, input.Position.Y - circleDragOffset.Y
        )
        CircleButton.Position = newPos
    end
end)

CircleButton.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    if MenuOpen then
        MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    end
end)

local titleDragging = false
local titleDragOffset = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        titleDragging = true
        titleDragOffset = Vector2.new(
            input.Position.X - MainFrame.AbsolutePosition.X,
            input.Position.Y - MainFrame.AbsolutePosition.Y
        )
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        titleDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if titleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPos = UDim2.new(
            0, input.Position.X - titleDragOffset.X,
            0, input.Position.Y - titleDragOffset.Y
        )
        MainFrame.Position = newPos
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if ESPActive then CreateESPForPlayer(player) end
        if ChamsActive then CreateChamsForPlayer(player) end
        if FlyActive then EnableFly() end
        if NoClipActive then EnableNoClip() end
    end)
end)

local function GetClosestPlayer()
    local closest = nil
    local shortest = Config.AimBot.Range
    local aimPart = Config.AimBot.AimPart
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(aimPart) or player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (pos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < Config.AimBot.FOV and dist < shortest then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 999)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        if Config.AimBot.WallPenetration or not hit or hit:IsDescendantOf(player.Character) then
                            if not Config.AimBot.VisibleCheck or not hit or hit:IsDescendantOf(player.Character) then
                                closest = player
                                shortest = dist
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosestPlayerForTrigger()
    local closest = nil
    local shortest = Config.Trigger.FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (pos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < Config.Trigger.FOV and dist < shortest then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 999)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        if not Config.Trigger.VisibleCheck or not hit or hit:IsDescendantOf(player.Character) then
                            closest = player
                            shortest = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

local triggerDelay = 0

RunService.RenderStepped:Connect(function()
    if Config.AimBot.Enabled and not MenuOpen then
        local target = GetClosestPlayer()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Config.AimBot.AimPart) or target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart then
                local pos = Camera:WorldToViewportPoint(aimPart.Position)
                local current = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local targetPos = Vector2.new(pos.X, pos.Y)
                local diff = targetPos - current
                if diff.Magnitude > 5 then
                    local smooth = Config.AimBot.Smooth
                    local newPos = current + diff * (1 - smooth)
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera:ScreenToWorldPoint(Vector3.new(newPos.X, newPos.Y, pos.Z)))
                end
            end
        end
    end
    
    if Config.Trigger.Enabled and not MenuOpen then
        triggerDelay = triggerDelay + 1
        if triggerDelay >= Config.Trigger.Delay then
            local target = GetClosestPlayerForTrigger()
            if target then
                Mouse1Click()
                triggerDelay = 0
            end
        end
    end
    
    if Config.BunnyHop.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid.Jump = true
            end
        end
    end
    
    if FlyActive and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local humanoid = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if humanoid and root then
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            if moveDirection.Magnitude > 0 then
                root.Velocity = moveDirection.Unit * Config.Fly.Speed
            else
                root.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
    
    if SpeedActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.Speed.Speed
        end
    end
    
    if AntiAimActive and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if Config.AntiAim.Mode == "Jitter" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.AntiAim.JitterAmount * math.sin(tick())), 0)
            elseif Config.AntiAim.Mode == "Spin" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(tick() * 360), 0)
            elseif Config.AntiAim.Mode == "Backwards" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
            elseif Config.AntiAim.Mode == "Fake" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.AntiAim.Angle), 0)
            end
        end
    end
    
    if Config.Watermark.Enabled then
        local frameTime = tick() - LastFrameTime
        LastFrameTime = tick()
        CurrentFPS = math.floor(1 / frameTime)
    end
end)

local speedKeyPressed = false
local flyKeyPressed = false
local noclipKeyPressed = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        
        if Config.Speed.OnKey ~= "" and key == Config.Speed.OnKey then
            if not speedKeyPressed then
                Config.Speed.Enabled = not Config.Speed.Enabled
                if Config.Speed.Enabled then EnableSpeed() else DisableSpeed() end
                speedKeyPressed = true
            end
        end
        
        if Config.Fly.OnKey ~= "" and key == Config.Fly.OnKey then
            if not flyKeyPressed then
                Config.Fly.Enabled = not Config.Fly.Enabled
                if Config.Fly.Enabled then EnableFly() else DisableFly() end
                flyKeyPressed = true
            end
        end
        
        if Config.NoClip.OnKey ~= "" and key == Config.NoClip.OnKey then
            if not noclipKeyPressed then
                Config.NoClip.Enabled = not Config.NoClip.Enabled
                if Config.NoClip.Enabled then EnableNoClip() else DisableNoClip() end
                noclipKeyPressed = true
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        if key == Config.Speed.OnKey then speedKeyPressed = false end
        if key == Config.Fly.OnKey then flyKeyPressed = false end
        if key == Config.NoClip.OnKey then noclipKeyPressed = false end
    end
end)

local function CreateWatermark()
    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(0, 300, 0, 30)
    watermark.Position = UDim2.new(0, 10, 0, 10)
    watermark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    watermark.BackgroundTransparency = 0.5
    watermark.TextColor3 = Config.Customization.AccentColor
    watermark.TextScaled = true
    watermark.Font = Enum.Font.GothamBold
    watermark.Text = "Hiruku Internal | FPS: 0 | Players: 0"
    watermark.Parent = ScreenGui
    
    local watermarkCorner = Instance.new("UICorner")
    watermarkCorner.CornerRadius = UDim.new(0, 4)
    watermarkCorner.Parent = watermark
    
    return watermark
end

local Watermark = CreateWatermark()

RunService.Heartbeat:Connect(function()
    if Config.Watermark.Enabled then
        Watermark.Visible = true
        local playerCount = #Players:GetPlayers()
        Watermark.Text = "Hiruku Internal | FPS: " .. CurrentFPS .. " | Players: " .. playerCount
    else
        Watermark.Visible = false
    end
end)

function Mouse1Click()
    local args = {
        [1] = "MouseButton1Down"
    }
    game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent"):FireServer(unpack(args))
    wait(0.05)
    local args2 = {
        [1] = "MouseButton1Up"
    }
    game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent"):FireServer(unpack(args2))
end

print("Hiruku Internal v2.0 Loaded Successfully!")
print("Press H to open menu")