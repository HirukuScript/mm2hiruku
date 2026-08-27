local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Config = {
    AimBot = {Enabled = false, FOV = 35, Smooth = 0.45, Range = 15, AimPart = "Head"},
    Silent = {Enabled = false, Range = 15, FOV = 35, AimPart = "Head"},
    Trigger = {Enabled = false, Range = 20, FOV = 10, Delay = 50},
    Chams = {Enabled = false, Transparency = 0.3, Color = Color3.fromRGB(255,255,255)},
    ESP = {Enabled = false, Box = true, Name = true, Health = true, Distance = true, Skeleton = false, Trail = false, Highlight = false},
    BunnyHop = {Enabled = false},
    Speed = {Enabled = false, Speed = 50},
    Fly = {Enabled = false, Speed = 50},
    AntiAim = {Enabled = false, Mode = "Jitter", SpinSpeed = 90, HeadDown = false},
    Watermark = {Enabled = true},
    FOVCircle = {Enabled = true},
    SpeedIndicator = {Enabled = true},
    World = {
        Fog = {Enabled = false, Color = Color3.fromRGB(255,255,255), Density = 0.5},
        Sky = {Enabled = false, Color = Color3.fromRGB(135,206,235)},
        Ambient = {Enabled = false, Color = Color3.fromRGB(128,128,128)}
    }
}

local MenuOpen = false
local ESPActive = false
local ChamsActive = false
local FlyActive = false
local SpeedActive = false
local AntiAimActive = false
local CurrentFPS = 0
local LastFrameTime = tick()
local FOVCircle = nil
local ESPObjects = {}
local ChamsObjects = {}
local IndicatorObjects = {}
local DistanceLines = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Кнопка открытия меню
local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 70, 0, 70)
CircleButton.Position = UDim2.new(0.02, 0, 0.5, -35)
CircleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
CircleButton.Text = "H"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextScaled = true
CircleButton.Font = Enum.Font.Code
CircleButton.BorderSizePixel = 2
CircleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.AutoButtonColor = false
CircleButton.Parent = ScreenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = CircleButton

-- Главное окно (как на 2 фото)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hiruku"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextScaled = false
TitleText.Font = Enum.Font.Code
TitleText.TextSize = 20
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Code
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = CloseBtn

-- Левая панель с вкладками
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 160, 1, -40)
Tabs.Position = UDim2.new(0, 0, 0, 40)
Tabs.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Tabs.BorderSizePixel = 0
Tabs.Parent = MainFrame

-- Правая панель с настройками (скролл)
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -170, 1, -40)
ContentArea.Position = UDim2.new(0, 170, 0, 40)
ContentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ContentArea.Parent = MainFrame

local Sections = {"Combat", "Visuals", "Movement", "Misc"}
local SectionIcons = {
    Combat = "rbxassetid://6031094667",
    Visuals = "rbxassetid://6031094667",
    Movement = "rbxassetid://6031094667",
    Misc = "rbxassetid://6031094667"
}

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.Parent = Tabs

local TabButtons = {}
local AllTabs = {}

for i, name in ipairs(Sections) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 45)
    btn.Position = UDim2.new(0, 5, 0, (i-1) * 50)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = false
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(30, 30, 30)
    btn.Parent = Tabs
    TabButtons[name] = btn

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 5)
    tabCorner.Parent = btn

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 8, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = SectionIcons[name]
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = false
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ContentArea
    AllTabs[name] = content
end

local function CreateSettingPanel(parent, title)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, -10, 0, 30)
    panel.Position = UDim2.new(0, 5, 0, 0)
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    panel.BorderSizePixel = 1
    panel.BorderColor3 = Color3.fromRGB(30, 30, 30)
    panel.Parent = parent
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 5)
    panelCorner.Parent = panel
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 1, 0)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextScaled = false
    header.Font = Enum.Font.Code
    header.TextSize = 14
    header.BorderSizePixel = 0
    header.Parent = panel
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 5)
    headerCorner.Parent = header
    
    return panel
end

local function CreateToggle(parent, label, path, yPos)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 30)
    holder.Position = UDim2.new(0, 10, 0, yPos)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.6, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextScaled = false
    text.Font = Enum.Font.Code
    text.TextSize = 13
    text.Parent = holder
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(0.75, 0, 0.2, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 1
    toggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
    toggle.Parent = holder
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 16, 0, 16)
    check.Position = UDim2.new(0, 2, 0, 2)
    check.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    check.BorderSizePixel = 0
    check.Parent = toggle
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(1, 0)
    checkCorner.Parent = check
    
    local function UpdateToggle()
        local current = Config
        for _, v in ipairs(path) do current = current[v] end
        if current then
            check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TweenService:Create(check, TweenInfo.new(0.15), {Position = UDim2.new(0, 22, 0, 2)}):Play()
        else
            check.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            TweenService:Create(check, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
    end
    UpdateToggle()
    
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local current = Config
            for i = 1, #path - 1 do current = current[path[i]] end
            current[path[#path]] = not current[path[#path]]
            UpdateToggle()
            
            if path[1] == "ESP" and path[2] == "Enabled" then
                if Config.ESP.Enabled then EnableESP() else DisableESP() end
            elseif path[1] == "Chams" and path[2] == "Enabled" then
                if Config.Chams.Enabled then EnableChams() else DisableChams() end
            elseif path[1] == "Fly" and path[2] == "Enabled" then
                if Config.Fly.Enabled then EnableFly() else DisableFly() end
            elseif path[1] == "Speed" and path[2] == "Enabled" then
                if Config.Speed.Enabled then EnableSpeed() else DisableSpeed() end
            elseif path[1] == "AntiAim" and path[2] == "Enabled" then
                if Config.AntiAim.Enabled then EnableAntiAim() else DisableAntiAim() end
            end
        end
    end)
end

local function CreateSlider(parent, label, path, min, max, decimal, yPos)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 30)
    holder.Position = UDim2.new(0, 10, 0, yPos)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.4, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextScaled = false
    text.Font = Enum.Font.Code
    text.TextSize = 13
    text.Parent = holder
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.15, 0, 1, 0)
    val.Position = UDim2.new(0.45, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.TextScaled = false
    val.Font = Enum.Font.Code
    val.TextSize = 13
    val.Parent = holder
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.25, 0, 0.2, 0)
    slider.Position = UDim2.new(0.65, 0, 0.4, 0)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slider.BorderSizePixel = 1
    slider.BorderColor3 = Color3.fromRGB(100, 100, 100)
    slider.Parent = holder
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local function UpdateSlider()
        local current = Config
        for _, v in ipairs(path) do current = current[v] end
        local percent = (current - min) / (max - min)
        fill.Size = UDim2.new(math.clamp(percent,0,1), 0, 1, 0)
        if decimal then
            val.Text = string.format("%.2f", current)
        else
            val.Text = tostring(math.round(current))
        end
    end
    UpdateSlider()
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = input.Position.X - slider.AbsolutePosition.X
            local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            if decimal then value = math.round(value / 0.01) * 0.01 else value = math.round(value) end
            local current = Config
            for i = 1, #path - 1 do current = current[path[i]] end
            current[path[#path]] = value
            UpdateSlider()
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            if decimal then value = math.round(value / 0.01) * 0.01 else value = math.round(value) end
            local current = Config
            for i = 1, #path - 1 do current = current[path[i]] end
            current[path[#path]] = value
            UpdateSlider()
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Наполнение вкладок
local CombatTab = AllTabs["Combat"]
local aimPanel = CreateSettingPanel(CombatTab, "AimBot")
CreateToggle(aimPanel, "Enable", {"AimBot","Enabled"}, 30)
CreateSlider(aimPanel, "FOV", {"AimBot","FOV"}, 1, 180, false, 60)
CreateSlider(aimPanel, "Smooth", {"AimBot","Smooth"}, 0, 1, true, 90)
CreateSlider(aimPanel, "Range", {"AimBot","Range"}, 1, 50, false, 120)
aimPanel.Size = UDim2.new(1, -10, 0, 150)

local silentPanel = CreateSettingPanel(CombatTab, "Silent Aim")
CreateToggle(silentPanel, "Enable", {"Silent","Enabled"}, 30)
CreateSlider(silentPanel, "FOV", {"Silent","FOV"}, 1, 180, false, 60)
CreateSlider(silentPanel, "Range", {"Silent","Range"}, 1, 50, false, 90)
silentPanel.Size = UDim2.new(1, -10, 0, 120)
silentPanel.Position = UDim2.new(0, 5, 0, 160)

local triggerPanel = CreateSettingPanel(CombatTab, "Trigger")
CreateToggle(triggerPanel, "Enable", {"Trigger","Enabled"}, 30)
CreateSlider(triggerPanel, "FOV", {"Trigger","FOV"}, 1, 180, false, 60)
CreateSlider(triggerPanel, "Range", {"Trigger","Range"}, 1, 50, false, 90)
CreateSlider(triggerPanel, "Delay", {"Trigger","Delay"}, 10, 500, false, 120)
triggerPanel.Size = UDim2.new(1, -10, 0, 150)
triggerPanel.Position = UDim2.new(0, 5, 0, 290)

local VisualsTab = AllTabs["Visuals"]
local espPanel = CreateSettingPanel(VisualsTab, "ESP")
CreateToggle(espPanel, "Enable", {"ESP","Enabled"}, 30)
CreateToggle(espPanel, "Box", {"ESP","Box"}, 60)
CreateToggle(espPanel, "Name", {"ESP","Name"}, 90)
CreateToggle(espPanel, "Health", {"ESP","Health"}, 120)
CreateToggle(espPanel, "Distance", {"ESP","Distance"}, 150)
CreateToggle(espPanel, "Skeleton", {"ESP","Skeleton"}, 180)
CreateToggle(espPanel, "Trail", {"ESP","Trail"}, 210)
CreateToggle(espPanel, "Highlight", {"ESP","Highlight"}, 240)
espPanel.Size = UDim2.new(1, -10, 0, 270)

local chamsPanel = CreateSettingPanel(VisualsTab, "Chams")
CreateToggle(chamsPanel, "Enable", {"Chams","Enabled"}, 30)
CreateSlider(chamsPanel, "Transparency", {"Chams","Transparency"}, 0, 1, true, 60)
chamsPanel.Size = UDim2.new(1, -10, 0, 90)
chamsPanel.Position = UDim2.new(0, 5, 0, 280)

local fovPanel = CreateSettingPanel(VisualsTab, "FOV Circle")
CreateToggle(fovPanel, "Show", {"FOVCircle","Enabled"}, 30)
fovPanel.Size = UDim2.new(1, -10, 0, 60)
fovPanel.Position = UDim2.new(0, 5, 0, 380)

local worldPanel = CreateSettingPanel(VisualsTab, "World")
CreateToggle(worldPanel, "Fog", {"World","Fog","Enabled"}, 30)
CreateSlider(worldPanel, "Fog Density", {"World","Fog","Density"}, 0, 1, true, 60)
CreateToggle(worldPanel, "Sky", {"World","Sky","Enabled"}, 90)
CreateToggle(worldPanel, "Ambient", {"World","Ambient","Enabled"}, 120)
worldPanel.Size = UDim2.new(1, -10, 0, 150)
worldPanel.Position = UDim2.new(0, 5, 0, 450)

local MovementTab = AllTabs["Movement"]
local speedPanel = CreateSettingPanel(MovementTab, "Speed")
CreateToggle(speedPanel, "Enable", {"Speed","Enabled"}, 30)
CreateSlider(speedPanel, "Speed", {"Speed","Speed"}, 10, 200, false, 60)
speedPanel.Size = UDim2.new(1, -10, 0, 90)

local flyPanel = CreateSettingPanel(MovementTab, "Fly")
CreateToggle(flyPanel, "Enable", {"Fly","Enabled"}, 30)
CreateSlider(flyPanel, "Speed", {"Fly","Speed"}, 10, 200, false, 60)
flyPanel.Size = UDim2.new(1, -10, 0, 90)
flyPanel.Position = UDim2.new(0, 5, 0, 100)

local bhopPanel = CreateSettingPanel(MovementTab, "Bunny Hop")
CreateToggle(bhopPanel, "Enable", {"BunnyHop","Enabled"}, 30)
bhopPanel.Size = UDim2.new(1, -10, 0, 60)
bhopPanel.Position = UDim2.new(0, 5, 0, 200)

local MiscTab = AllTabs["Misc"]
local antiAimPanel = CreateSettingPanel(MiscTab, "Anti-Aim")
CreateToggle(antiAimPanel, "Enable", {"AntiAim","Enabled"}, 30)
CreateToggle(antiAimPanel, "Head Down", {"AntiAim","HeadDown"}, 60)
antiAimPanel.Size = UDim2.new(1, -10, 0, 90)

local watermarkPanel = CreateSettingPanel(MiscTab, "Watermark")
CreateToggle(watermarkPanel, "Enable", {"Watermark","Enabled"}, 30)
watermarkPanel.Size = UDim2.new(1, -10, 0, 60)
watermarkPanel.Position = UDim2.new(0, 5, 0, 100)

local speedIndPanel = CreateSettingPanel(MiscTab, "Speed Indicator")
CreateToggle(speedIndPanel, "Enable", {"SpeedIndicator","Enabled"}, 30)
speedIndPanel.Size = UDim2.new(1, -10, 0, 60)
speedIndPanel.Position = UDim2.new(0, 5, 0, 170)

-- Функция переключения вкладок
local function SwitchTab(name)
    for _, tab in pairs(AllTabs) do
        tab.Visible = false
    end
    AllTabs[name].Visible = true
    for _, btn in pairs(TabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    TabButtons[name].BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabButtons[name].TextColor3 = Color3.fromRGB(255, 255, 255)
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end
SwitchTab("Combat")

-- FOV через Drawing (работает на мобильных)
local FOVCircle = nil
function CreateFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Radius = Config.AimBot.FOV
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Transparency = 0.5
    FOVCircle.Filled = false
    FOVCircle.Visible = Config.FOVCircle.Enabled
end

if Config.FOVCircle.Enabled then CreateFOVCircle() end

-- ESP из файла (с 2D боксами, именем, скелетом, трейлом, хайлайтом)
local default = {
    ["2dbox"] = { color = Color3.fromRGB(255, 255, 255), enable = true },
    ["name"] = { enable = true, placement = "Top" },
    ["studs"] = { enable = true },
    ["tool"] = { enable = true, placement = "Bottom" },
    ["flags"] = { enable = true, placement = "Right" },
    ["skeleton"] = { enable = true, color = Color3.new(1, 1, 1), outlineEnabled = true, outlineColor = Color3.new(0, 0, 0), lineThickness = 1, outlineThickness = 3 },
    ["trail"] = { enable = true, rgb = Color3.fromRGB(255, 255, 255), thickness = 1 },
    ["highlight"] = { enable = true, fillColor = Color3.fromRGB(128, 128, 128), outlineColor = Color3.fromRGB(0, 0, 0), fillTransparency = 0.5, outlineTransparency = 0 }
}

local boxCache = {}
local flagsCache = {}
local stackingInfo = {}

local function getdistancefc(part)
    return (part.Position - Camera.CFrame.Position).Magnitude
end

local function getMovementState(humanoid, hrp)
    local velocity = hrp.Velocity
    if velocity.Y > 1 then return "jumping" end
    if velocity.Y < -1 then return "falling" end
    local horizontalSpeed = math.sqrt(velocity.X^2 + velocity.Z^2)
    if horizontalSpeed < 0.5 then return "idling" elseif horizontalSpeed <= 15 then return "walking" else return "running" end
end

local function getPosition(placement, boxPos, boxSize, userId, elementType)
    if not stackingInfo[userId] then
        stackingInfo[userId] = {
            Top = { count = 0, elements = {} },
            Bottom = { count = 0, elements = {} },
            Left = { count = 0, elements = {} },
            Right = { count = 0, elements = {} }
        }
    end
    if not stackingInfo[userId][placement].elements[elementType] then
        stackingInfo[userId][placement].count = stackingInfo[userId][placement].count + 1
        stackingInfo[userId][placement].elements[elementType] = stackingInfo[userId][placement].count
    end
    local stackPosition = stackingInfo[userId][placement].elements[elementType]
    local stackOffset = (stackPosition - 1) * 15
    if placement == "Top" then
        return Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 20 - stackOffset), true
    elseif placement == "Bottom" then
        return Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y + boxSize.Y + 10 + stackOffset), true
    elseif placement == "Left" then
        return Vector2.new(boxPos.X - 10, boxPos.Y + boxSize.Y/2 + stackOffset), false
    elseif placement == "Right" then
        return Vector2.new(boxPos.X + boxSize.X + 10, boxPos.Y + boxSize.Y/2 + stackOffset), false
    else
        return Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 20), true
    end
end

local function resetStackingInfo(userId)
    stackingInfo[userId] = nil
end

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)
local boxScaleFactor = 1.2

local function esp(p, cr)
    local h = cr:WaitForChild("Humanoid")
    local head = cr:WaitForChild("Head")
    local text = Drawing.new("Text")
    text.Visible = false
    text.Outline = true
    text.Font = 2
    text.Color = Color3.fromRGB(255,255,255)
    text.Size = 13
    local c1, c2, c3
    local function dc()
        text.Visible = false
        text:Remove()
        resetStackingInfo(p.UserId)
        if c1 then c1:Disconnect() end
        if c2 then c2:Disconnect() end
        if c3 then c3:Disconnect() end
    end
    c2 = cr.AncestryChanged:Connect(function(_, parent)
        if not parent then dc() end
    end)
    c3 = h.HealthChanged:Connect(function(v)
        if v <= 0 or h:GetState() == Enum.HumanoidStateType.Dead then dc() end
    end)
    c1 = RunService.RenderStepped:Connect(function()
        if not boxCache[p.UserId] then return end
        local boxPos = boxCache[p.UserId].Box.Position
        local boxSize = boxCache[p.UserId].Box.Size
        if boxCache[p.UserId].Box.Visible then
            local pos, centered = getPosition(default.name.placement, boxPos, boxSize, p.UserId, "name")
            text.Position = pos
            text.Center = centered
            text.Text = p.Name .. ' (' .. tostring(math.floor(getdistancefc(head))) .. ' studs)'
            text.Visible = default.studs.enable and Config.ESP.Name
        else
            text.Visible = false
        end
    end)
end

local function flagsEsp(p, cr)
    local h = cr:WaitForChild("Humanoid")
    local hrp = cr:WaitForChild("HumanoidRootPart")
    local text = Drawing.new("Text")
    text.Visible = false
    text.Outline = true
    text.Font = 2
    text.Color = Color3.fromRGB(255,255,255)
    text.Size = 13
    flagsCache[p.UserId] = text
    local c1, c2, c3
    local function dc()
        text.Visible = false
        text:Remove()
        flagsCache[p.UserId] = nil
        if c1 then c1:Disconnect() end
        if c2 then c2:Disconnect() end
        if c3 then c3:Disconnect() end
    end
    c2 = cr.AncestryChanged:Connect(function(_, parent)
        if not parent then dc() end
    end)
    c3 = h.HealthChanged:Connect(function(v)
        if v <= 0 or h:GetState() == Enum.HumanoidStateType.Dead then dc() end
    end)
    c1 = RunService.RenderStepped:Connect(function()
        if not boxCache[p.UserId] then return end
        local boxPos = boxCache[p.UserId].Box.Position
        local boxSize = boxCache[p.UserId].Box.Size
        if boxCache[p.UserId].Box.Visible and Config.ESP.Box then
            local movementState = getMovementState(h, hrp)
            local pos, centered = getPosition(default.flags.placement, boxPos, boxSize, p.UserId, "flags")
            text.Position = pos
            text.Center = centered
            text.Text = "[" .. movementState .. "]"
            text.Visible = default.flags.enable and Config.ESP.Health
        else
            text.Visible = false
        end
    end)
end

local function updateBoxESP(v)
    if not boxCache[v.UserId] then
        boxCache[v.UserId] = {
            BoxOutline = Drawing.new("Square"),
            Box = Drawing.new("Square")
        }
        local BoxOutline = boxCache[v.UserId].BoxOutline
        BoxOutline.Visible = false
        BoxOutline.Color = Color3.new(0, 0, 0)
        BoxOutline.Thickness = 3
        BoxOutline.Transparency = 1
        BoxOutline.Filled = false
        local Box = boxCache[v.UserId].Box
        Box.Visible = false
        Box.Color = default["2dbox"].color
        Box.Thickness = 1
        Box.Transparency = 1
        Box.Filled = false
    end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not v or not v.Character or 
           not v.Character:FindFirstChild("Humanoid") or 
           not v.Character:FindFirstChild("HumanoidRootPart") or 
           v.Character.Humanoid.Health <= 0 then
            if boxCache[v.UserId] then
                boxCache[v.UserId].BoxOutline.Visible = false
                boxCache[v.UserId].Box.Visible = false
            end
            if connection then connection:Disconnect() end
            return
        end
        
        local hrp = v.Character.HumanoidRootPart
        local head = v.Character:FindFirstChild("Head")
        if head then
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + HeadOff)
            local footPos, footOnScreen = Camera:WorldToViewportPoint(hrp.Position - LegOff)
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if headOnScreen and footOnScreen and onScreen then
                local scaleFactor = 1000 / hrpPos.Z
                local width = hrp.Size.X * scaleFactor * boxScaleFactor * 1.1 * 1.2  
                local height = (headPos.Y - footPos.Y) * 1.1
                local centerX = hrpPos.X
                local centerY = (headPos.Y + footPos.Y) / 2
                local BoxOutline = boxCache[v.UserId].BoxOutline
                local Box = boxCache[v.UserId].Box
                BoxOutline.Size = Vector2.new(width, height)
                BoxOutline.Position = Vector2.new(centerX - width / 2, centerY - height / 2)
                BoxOutline.Visible = default["2dbox"].enable and Config.ESP.Box
                Box.Size = Vector2.new(width, height)
                Box.Position = Vector2.new(centerX - width / 2, centerY - height / 2)
                Box.Visible = default["2dbox"].enable and Config.ESP.Box
                Box.Color = default["2dbox"].color
            else
                boxCache[v.UserId].BoxOutline.Visible = false
                boxCache[v.UserId].Box.Visible = false
            end
        end
    end)
end

local function ftool(cr)
    for _, b in next, cr:GetChildren() do 
        if b.ClassName == 'Tool' then return tostring(b.Name) end
    end
    return 'empty'
end

local function toolEsp(p, cr)
    local h = cr:WaitForChild("Humanoid")
    local hrp = cr:WaitForChild("HumanoidRootPart")
    local text = Drawing.new('Text')
    text.Visible = false
    text.Outline = true
    text.Color = Color3.new(1, 1, 1)
    text.Font = 2
    text.Size = 13
    local c1, c2, c3
    local function dc()
        text.Visible = false
        text:Remove()
        if c1 then c1:Disconnect() end
        if c2 then c2:Disconnect() end
        if c3 then c3:Disconnect() end
    end
    c2 = cr.AncestryChanged:Connect(function(_, parent)
        if not parent then dc() end
    end)
    c3 = h.HealthChanged:Connect(function(v)
        if v <= 0 or h:GetState() == Enum.HumanoidStateType.Dead then dc() end
    end)
    c1 = RunService.Heartbeat:Connect(function()
        if not boxCache[p.UserId] then return end
        local boxPos = boxCache[p.UserId].Box.Position
        local boxSize = boxCache[p.UserId].Box.Size
        if boxCache[p.UserId].Box.Visible then
            local pos, centered = getPosition(default.tool.placement, boxPos, boxSize, p.UserId, "tool")
            text.Position = pos
            text.Center = centered
            text.Text = '[ ' .. tostring(ftool(cr)) .. ' ]'
            text.Visible = default.tool.enable and Config.ESP.Distance
        else
            text.Visible = false
        end
    end)
end

local function createTrail(character)
    if not Config.ESP.Trail then return end
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return end
    local attachment0 = Instance.new("Attachment")
    attachment0.Position = Vector3.new(0, 0, 0)
    attachment0.Parent = humanoidRootPart
    local attachment1 = Instance.new("Attachment")
    attachment1.Position = Vector3.new(0, 0, -0.5)
    attachment1.Parent = humanoidRootPart
    local trail = Instance.new("Trail")
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.WidthScale = NumberSequence.new(default.trail.thickness)
    trail.Color = ColorSequence.new(default.trail.rgb)
    trail.Parent = humanoidRootPart
    table.insert(ESPObjects, trail)
end

local function createHighlight(player)
    if not Config.ESP.Highlight then return end
    if not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = default.highlight.fillColor
    highlight.OutlineColor = default.highlight.outlineColor
    highlight.FillTransparency = default.highlight.fillTransparency
    highlight.OutlineTransparency = default.highlight.outlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = default.highlight.enable
    highlight.Parent = player.Character
    table.insert(ESPObjects, highlight)
end

local R6_CONNECTIONS = {
    {'Head', 'Torso'}, {'Torso', 'Left Arm'}, {'Torso', 'Right Arm'}, {'Torso', 'Left Leg'}, {'Torso', 'Right Leg'}
}

local R15_CONNECTIONS = {
    {'Head', 'UpperTorso'}, {'UpperTorso', 'LowerTorso'}, {'UpperTorso', 'LeftUpperArm'}, {'UpperTorso', 'RightUpperArm'},
    {'LeftUpperArm', 'LeftLowerArm'}, {'LeftLowerArm', 'LeftHand'}, {'RightUpperArm', 'RightLowerArm'}, {'RightLowerArm', 'RightHand'},
    {'LowerTorso', 'LeftUpperLeg'}, {'LowerTorso', 'RightUpperLeg'}, {'LeftUpperLeg', 'LeftLowerLeg'}, {'LeftLowerLeg', 'LeftFoot'},
    {'RightUpperLeg', 'RightLowerLeg'}, {'RightLowerLeg', 'RightFoot'}
}

local lines = {}
local outlines = {}

local function worldToScreen(part)
    local position, onScreen = Camera:WorldToViewportPoint(part.Position)
    return Vector2.new(position.X, position.Y), onScreen
end

local function getCharacterRig(character)
    return character:FindFirstChild('Torso') and 'R6' or 'R15'
end

local function clearLines()
    for _, line in ipairs(lines) do line:Remove() end
    for _, outline in ipairs(outlines) do outline:Remove() end
    lines = {}
    outlines = {}
end

local function drawSkeleton()
    clearLines()
    if not Config.ESP.Skeleton then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild('Humanoid')
                local rootPart = character:FindFirstChild('HumanoidRootPart')
                if humanoid and rootPart and humanoid.Health > 0 then
                    local connections = getCharacterRig(character) == 'R6' and R6_CONNECTIONS or R15_CONNECTIONS
                    for _, connection in ipairs(connections) do
                        local fromPart = character:FindFirstChild(connection[1])
                        local toPart = character:FindFirstChild(connection[2])
                        if fromPart and toPart then
                            local fromScreen, fromVisible = worldToScreen(fromPart)
                            local toScreen, toVisible = worldToScreen(toPart)
                            if fromVisible and toVisible then
                                if default.skeleton.outlineEnabled then
                                    local outline = Drawing.new('Line')
                                    outline.From = fromScreen
                                    outline.To = toScreen
                                    outline.Color = default.skeleton.outlineColor
                                    outline.Thickness = default.skeleton.outlineThickness
                                    outline.Visible = true
                                    table.insert(outlines, outline)
                                end
                                local line = Drawing.new('Line')
                                line.From = fromScreen
                                line.To = toScreen
                                line.Color = default.skeleton.color
                                line.Thickness = default.skeleton.lineThickness
                                line.Visible = true
                                table.insert(lines, line)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function playerAdded(p)
    if p == LocalPlayer then return end
    local function characterAdded(cr)
        wait(0.5)
        if Config.ESP.Enabled then
            esp(p, cr)
            toolEsp(p, cr)
            updateBoxESP(p)
            flagsEsp(p, cr)
            createTrail(cr)
            createHighlight(p)
        end
    end
    if p.Character then characterAdded(p.Character) end
    p.CharacterAdded:Connect(characterAdded)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then playerAdded(p) end
end
Players.PlayerAdded:Connect(playerAdded)

Players.PlayerRemoving:Connect(function(player)
    for _, obj in pairs(ESPObjects) do
        if obj.Parent == player.Character then pcall(function() obj:Destroy() end) end
    end
end)

-- Функции ESP, Chams, Fly, Speed, AntiAim
function EnableESP()
    ESPActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            esp(player, player.Character)
            toolEsp(player, player.Character)
            updateBoxESP(player)
            flagsEsp(player, player.Character)
            createTrail(player.Character)
            createHighlight(player)
        end
    end
end

function DisableESP()
    ESPActive = false
    for _, obj in pairs(ESPObjects) do pcall(function() obj:Destroy() end) end
    ESPObjects = {}
    clearLines()
    for _, p in ipairs(Players:GetPlayers()) do resetStackingInfo(p.UserId) end
end

function EnableChams()
    ChamsActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = part
                    highlight.FillColor = Color3.fromRGB(255,255,255)
                    highlight.FillTransparency = Config.Chams.Transparency
                    highlight.OutlineColor = Color3.fromRGB(255,255,255)
                    highlight.OutlineTransparency = 0.5
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = part
                    table.insert(ChamsObjects, highlight)
                end
            end
        end
    end
end

function DisableChams()
    ChamsActive = false
    for _, obj in pairs(ChamsObjects) do pcall(function() obj:Destroy() end) end
    ChamsObjects = {}
end

function EnableFly()
    FlyActive = true
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = true end
    end
end

function DisableFly()
    FlyActive = false
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(0,0,0) end
    end
end

function EnableSpeed()
    SpeedActive = true
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = Config.Speed.Speed end
    end
end

function DisableSpeed()
    SpeedActive = false
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end

function EnableAntiAim()
    AntiAimActive = true
end

function DisableAntiAim()
    AntiAimActive = false
end

-- Перетаскивание кнопки H с обработкой клика
local isDragging = false
local dragStart = Vector2.new()
local dragOffset = Vector2.new()
local isClick = false

CircleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        isClick = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        dragOffset = Vector2.new(input.Position.X - CircleButton.AbsolutePosition.X, input.Position.Y - CircleButton.AbsolutePosition.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        if (currentPos - dragStart).Magnitude > 8 then
            isClick = false
            CircleButton.Position = UDim2.new(0, currentPos.X - dragOffset.X, 0, currentPos.Y - dragOffset.Y)
        end
    end
end)

CircleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isClick then
            MenuOpen = not MenuOpen
            MainFrame.Visible = MenuOpen
            if MenuOpen then
                if Config.FOVCircle.Enabled then CreateFOVCircle() end
            else
                if FOVCircle then FOVCircle.Visible = false end
            end
        end
        isDragging = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
    if FOVCircle then FOVCircle.Visible = false end
end)

CloseBtn.TouchTap:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
    if FOVCircle then FOVCircle.Visible = false end
end)

-- Silent Aim (наведение камеры)
local function GetClosestPlayerForAim()
    local closest = nil
    local shortest = Config.AimBot.Range
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(Config.AimBot.AimPart) or player.Character:FindFirstChild("Head")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (pos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < Config.AimBot.FOV and dist < shortest then
                        closest = player
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosestPlayerForSilent()
    local closest = nil
    local shortest = Config.Silent.Range
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(Config.Silent.AimPart) or player.Character:FindFirstChild("Head")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (pos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < Config.Silent.FOV and dist < shortest then
                        closest = player
                        shortest = dist
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
            local part = player.Character:FindFirstChild("Head")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (pos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < Config.Trigger.FOV and dist < shortest then
                        closest = player
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

local triggerDelay = 0

-- Отрисовка стрелок и полосок
local function UpdateIndicators()
    for _, obj in pairs(IndicatorObjects) do obj:Destroy() end
    IndicatorObjects = {}
    if not (Config.ESP.Enabled and Config.ESP.Box) then return end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if not onScreen then
                local dir = (Vector2.new(pos.X, pos.Y) - center)
                if dir.Magnitude > 0 then
                    dir = dir.Unit
                    local arrow = Instance.new("TextLabel")
                    arrow.Size = UDim2.new(0, 24, 0, 24)
                    arrow.Position = UDim2.new(0, center.X + dir.X * 100 - 12, 0, center.Y + dir.Y * 100 - 12)
                    arrow.BackgroundTransparency = 1
                    arrow.Text = "➤"
                    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
                    arrow.TextScaled = true
                    arrow.Font = Enum.Font.Code
                    arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X)) + 90
                    arrow.Parent = ScreenGui
                    table.insert(IndicatorObjects, arrow)
                end
            end
        end
    end
end

local function UpdateDistanceLines()
    for _, obj in pairs(DistanceLines) do obj:Destroy() end
    DistanceLines = {}
    if not (Config.ESP.Enabled and Config.ESP.Distance) then return end
    
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local myScreen, myOn = Camera:WorldToViewportPoint(myPos.Position)
            local hrpScreen, hrpOn = Camera:WorldToViewportPoint(hrp.Position)
            if myOn and hrpOn then
                local line = Instance.new("Frame")
                line.Size = UDim2.new(0, 1, 0, 1)
                line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                line.BackgroundTransparency = 0.5
                line.BorderSizePixel = 0
                line.Parent = ScreenGui
                table.insert(DistanceLines, line)
                
                local angle = math.atan2(hrpScreen.Y - myScreen.Y, hrpScreen.X - myScreen.X)
                line.Rotation = math.deg(angle)
                line.Position = UDim2.new(0, myScreen.X, 0, myScreen.Y)
            end
        end
    end
end

-- Главный цикл
RunService.Heartbeat:Connect(function()
    local currentTick = tick()
    if currentTick - LastFrameTime > 0 then
        CurrentFPS = math.floor(1 / (currentTick - LastFrameTime))
        LastFrameTime = currentTick
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.FOVCircle.Enabled and FOVCircle then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = center
        FOVCircle.Radius = Config.AimBot.FOV
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
    
    if Config.AimBot.Enabled and not MenuOpen then
        local target = GetClosestPlayerForAim()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Config.AimBot.AimPart) or target.Character:FindFirstChild("Head")
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
    
    if Config.Silent.Enabled and not MenuOpen then
        local target = GetClosestPlayerForSilent()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Config.Silent.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            end
        end
    end
    
    if Config.Trigger.Enabled and not MenuOpen then
        triggerDelay = triggerDelay + 1
        if triggerDelay >= Config.Trigger.Delay then
            local target = GetClosestPlayerForTrigger()
            if target then
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                if remote then
                    pcall(function() remote:FireServer("MouseButton1Down") end)
                    wait(0.05)
                    pcall(function() remote:FireServer("MouseButton1Up") end)
                end
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
            local moveDirection = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0,1,0) end
            if moveDirection.Magnitude > 0 then
                root.Velocity = moveDirection.Unit * Config.Fly.Speed
            else
                root.Velocity = Vector3.new(0,0,0)
            end
            humanoid.PlatformStand = true
        end
    end
    
    if SpeedActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = Config.Speed.Speed end
    end
    
    if AntiAimActive and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if root then
            if Config.AntiAim.Mode == "Jitter" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10 * math.sin(tick() * 10)), 0)
            elseif Config.AntiAim.Mode == "Spin" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(tick() * Config.AntiAim.SpinSpeed), 0)
            elseif Config.AntiAim.Mode == "Backwards" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
            end
            if Config.AntiAim.HeadDown and head then
                head.CFrame = head.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            end
        end
    end
    
    if Config.World.Fog.Enabled then
        Lighting.Fog = true
        Lighting.FogColor = Config.World.Fog.Color
        Lighting.FogEnd = 1000 / (Config.World.Fog.Density + 0.1)
    else
        Lighting.Fog = false
    end
    
    if Config.World.Sky.Enabled then
        local sky = Lighting:FindFirstChild("Sky")
        if sky then
            for _, child in ipairs(sky:GetChildren()) do
                if child:IsA("ImageLabel") then
                    child.Color = Config.World.Sky.Color
                end
            end
        end
    end
    
    if Config.World.Ambient.Enabled then
        Lighting.Ambient = Config.World.Ambient.Color
    end
    
    UpdateIndicators()
    UpdateDistanceLines()
end)

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 200, 0, 20)
Watermark.Position = UDim2.new(0.5, -100, 0, 5)
Watermark.BackgroundColor3 = Color3.fromRGB(0,0,0)
Watermark.BackgroundTransparency = 0.3
Watermark.TextColor3 = Color3.fromRGB(255,255,255)
Watermark.TextScaled = true
Watermark.Font = Enum.Font.Code
Watermark.Text = "Hiruku | FPS: 0"
Watermark.Parent = ScreenGui

local watermarkCorner = Instance.new("UICorner")
watermarkCorner.CornerRadius = UDim.new(1,0)
watermarkCorner.Parent = Watermark

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 100, 0, 20)
SpeedLabel.Position = UDim2.new(0.5, -50, 1, -30)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
SpeedLabel.BackgroundTransparency = 0.3
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Code
SpeedLabel.Text = "Speed: 0"
SpeedLabel.Parent = ScreenGui

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(1,0)
speedCorner.Parent = SpeedLabel

RunService.Heartbeat:Connect(function()
    if Config.Watermark.Enabled then
        Watermark.Visible = true
        Watermark.Text = "Hiruku | FPS: " .. CurrentFPS .. " | Players: " .. #Players:GetPlayers()
    else
        Watermark.Visible = false
    end
    
    if Config.SpeedIndicator.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SpeedLabel.Visible = true
        local speed = LocalPlayer.Character.HumanoidRootPart.Velocity.Magnitude
        SpeedLabel.Text = "Speed: " .. math.floor(speed)
    else
        SpeedLabel.Visible = false
    end
end)