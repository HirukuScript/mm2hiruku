local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    AimBot = {Enabled = false, Range = 100},
    Silent = {Enabled = false, Range = 100},
    Trigger = {Enabled = false, Range = 50, Delay = 50},
    WallHack = {Enabled = false},
    Chams = {Enabled = false, Transparency = 0.3, FillColor = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(0,0,0)},
    ESP = {Enabled = false, Box = true, Name = true, Health = true, Distance = true},
    BunnyHop = {Enabled = false, MaxSpeed = 100},
    Speed = {Enabled = false, Speed = 50},
    Fly = {Enabled = false, Speed = 50, HeightOffset = 10},
    Spin = {Enabled = false, Speed = 360},
    Collisions = {Enabled = false},
    Watermark = {Enabled = true},
    FOV = {Radius = 35, Thickness = 2, Color = Color3.fromRGB(255,255,255)},
    FOVCircle = {Enabled = true},
    SpeedIndicator = {Enabled = true}
}

local MenuOpen = false
local ESPActive = false
local ChamsActive = false
local FlyActive = false
local SpeedActive = false
local SpinActive = false
local CollisionsActive = false
local CurrentFPS = 0
local LastFrameTime = tick()
local FOVCircle = nil
local ESPCache = {}
local ChamsObjects = {}
local BhopSpeed = 16
local LastBhopTime = 0
local triggerDelay = 0

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 99999
ScreenGui.IgnoreGuiInset = true

local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 50, 0, 50)
CircleButton.Position = UDim2.new(0.02, 0, 0.5, -25)
CircleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CircleButton.Text = "H"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextScaled = false
CircleButton.TextSize = 24
CircleButton.Font = Enum.Font.Code
CircleButton.BorderSizePixel = 1
CircleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.AutoButtonColor = false
CircleButton.ZIndex = 500
CircleButton.Parent = ScreenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(0, 10)
circleCorner.Parent = CircleButton

-- МЕНЮ (Закругление усилено)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ZIndex = 400
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12) -- Более сильное закругление
mainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
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
TitleText.TextSize = 16
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -31, 0, 4)
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

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 100, 1, -35)
Tabs.Position = UDim2.new(0, 0, 0, 35)
Tabs.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Tabs.BorderSizePixel = 0
Tabs.Parent = MainFrame

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -110, 1, -35)
ContentArea.Position = UDim2.new(0, 110, 0, 35)
ContentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ContentArea.Parent = MainFrame

local Sections = {"Combat", "Visuals", "Movement", "Misc"}
local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 4)
TabsLayout.Parent = Tabs

local TabButtons = {}
local AllTabs = {}

for i, name in ipairs(Sections) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, (i-1) * 40)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = false
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(30, 30, 30)
    btn.Parent = Tabs
    TabButtons[name] = btn

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 5)
    tabCorner.Parent = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ContentArea
    AllTabs[name] = content

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = content
end

local function CreateSettingPanel(parent, title)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, -10, 0, 30)
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    panel.BorderSizePixel = 1
    panel.BorderColor3 = Color3.fromRGB(30, 30, 30)
    panel.Parent = parent

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 5)
    panelCorner.Parent = panel

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextScaled = false
    header.Font = Enum.Font.Code
    header.TextSize = 13
    header.BorderSizePixel = 0
    header.Parent = panel

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 5)
    headerCorner.Parent = header

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = panel

    return panel
end

local function CreateToggle(parent, label, path)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 30)
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
    text.TextSize = 12
    text.Parent = holder

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 30, 0, 16)
    toggle.Position = UDim2.new(0.8, 0, 0.2, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 1
    toggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
    toggle.Parent = holder

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle

    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 12, 0, 12)
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
            TweenService:Create(check, TweenInfo.new(0.15), {Position = UDim2.new(0, 16, 0, 2)}):Play()
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
            elseif path[1] == "Spin" and path[2] == "Enabled" then
                if Config.Spin.Enabled then EnableSpin() else DisableSpin() end
            elseif path[1] == "Collisions" and path[2] == "Enabled" then
                if Config.Collisions.Enabled then EnableCollisions() else DisableCollisions() end
            elseif path[1] == "WallHack" and path[2] == "Enabled" then
                -- Wall Hack doesn't need special enabling, it changes attack logic
            end
        end
    end)
end

local function CreateSlider(parent, label, path, min, max, decimal)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 45)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.5, 0, 0, 20)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextScaled = false
    text.Font = Enum.Font.Code
    text.TextSize = 12
    text.Parent = holder

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.2, 0, 0, 20)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.TextScaled = false
    val.Font = Enum.Font.Code
    val.TextSize = 12
    val.Parent = holder

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0.2, 0)
    slider.Position = UDim2.new(0, 0, 0.5, 0)
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

local function CreateColorButton(parent, label, path, colorList)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 40)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.8, 0, 0, 20)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextScaled = false
    text.Font = Enum.Font.Code
    text.TextSize = 12
    text.Parent = holder

    local btnHolder = Instance.new("Frame")
    btnHolder.Size = UDim2.new(1, 0, 0, 20)
    btnHolder.Position = UDim2.new(0, 0, 0, 20)
    btnHolder.BackgroundTransparency = 1
    btnHolder.Parent = holder

    local colorBtns = {}

    for idx, color in ipairs(colorList) do
        local btn = Instance.new("Frame")
        btn.Size = UDim2.new(0, 18, 0, 18)
        btn.Position = UDim2.new(0 + (idx-1)*0.08, 0, 0, 0)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
        btn.Parent = btnHolder

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 3)
        btnCorner.Parent = btn

        table.insert(colorBtns, btn)

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local current = Config
                for i = 1, #path - 1 do current = current[path[i]] end
                current[path[#path]] = color

                for _, b in ipairs(colorBtns) do
                    if b.BackgroundColor3 == color then
                        b.BorderColor3 = Color3.fromRGB(255, 255, 255)
                        b.BorderSizePixel = 2
                    else
                        b.BorderColor3 = Color3.fromRGB(60, 60, 60)
                        b.BorderSizePixel = 1
                    end
                end

                if path[1] == "Chams" and path[2] == "FillColor" then EnableChams() end
                if path[1] == "Chams" and path[2] == "OutlineColor" then EnableChams() end
                if path[1] == "FOV" and path[2] == "Color" then CreateFOVCircle() end
            end
        end)
    end

    local current = Config
    for _, v in ipairs(path) do current = current[v] end
    for _, b in ipairs(colorBtns) do
        if b.BackgroundColor3 == current then
            b.BorderColor3 = Color3.fromRGB(255, 255, 255)
            b.BorderSizePixel = 2
        end
    end
end

local CombatTab = AllTabs["Combat"]
local aimPanel = CreateSettingPanel(CombatTab, "AimBot")
CreateToggle(aimPanel, "Enable", {"AimBot","Enabled"})
CreateSlider(aimPanel, "Range", {"AimBot","Range"}, 1, 100, false)
aimPanel.Size = UDim2.new(1, -10, 0, 100)

local silentPanel = CreateSettingPanel(CombatTab, "Silent Aim")
CreateToggle(silentPanel, "Enable", {"Silent","Enabled"})
CreateSlider(silentPanel, "Range", {"Silent","Range"}, 1, 100, false)
silentPanel.Size = UDim2.new(1, -10, 0, 100)
silentPanel.Position = UDim2.new(0, 5, 0, 110)

local triggerPanel = CreateSettingPanel(CombatTab, "Trigger")
CreateToggle(triggerPanel, "Enable", {"Trigger","Enabled"})
CreateSlider(triggerPanel, "Range", {"Trigger","Range"}, 1, 50, false)
CreateSlider(triggerPanel, "Delay", {"Trigger","Delay"}, 10, 500, false)
triggerPanel.Size = UDim2.new(1, -10, 0, 130)
triggerPanel.Position = UDim2.new(0, 5, 0, 220)

local VisualsTab = AllTabs["Visuals"]
local fovPanel = CreateSettingPanel(VisualsTab, "FOV Circle")
CreateToggle(fovPanel, "Show", {"FOVCircle","Enabled"})
CreateSlider(fovPanel, "Radius", {"FOV","Radius"}, 1, 180, false)
CreateSlider(fovPanel, "Thickness", {"FOV","Thickness"}, 1, 5, false)
CreateColorButton(fovPanel, "Color", {"FOV","Color"}, {Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255)})
fovPanel.Size = UDim2.new(1, -10, 0, 170)

local espPanel = CreateSettingPanel(VisualsTab, "ESP")
CreateToggle(espPanel, "Enable", {"ESP","Enabled"})
CreateToggle(espPanel, "Box", {"ESP","Box"})
CreateToggle(espPanel, "Name", {"ESP","Name"})
CreateToggle(espPanel, "Health", {"ESP","Health"})
CreateToggle(espPanel, "Distance", {"ESP","Distance"})
espPanel.Size = UDim2.new(1, -10, 0, 180)
espPanel.Position = UDim2.new(0, 5, 0, 180)

local chamsPanel = CreateSettingPanel(VisualsTab, "Chams")
CreateToggle(chamsPanel, "Enable", {"Chams","Enabled"})
CreateSlider(chamsPanel, "Transparency", {"Chams","Transparency"}, 0, 1, true)
CreateColorButton(chamsPanel, "Fill", {"Chams","FillColor"}, {Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255)})
CreateColorButton(chamsPanel, "Outline", {"Chams","OutlineColor"}, {Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,0,255)})
chamsPanel.Size = UDim2.new(1, -10, 0, 170)
chamsPanel.Position = UDim2.new(0, 5, 0, 370)

local MovementTab = AllTabs["Movement"]
local speedPanel = CreateSettingPanel(MovementTab, "Speed")
CreateToggle(speedPanel, "Enable", {"Speed","Enabled"})
CreateSlider(speedPanel, "Speed", {"Speed","Speed"}, 10, 200, false)
speedPanel.Size = UDim2.new(1, -10, 0, 100)

local flyPanel = CreateSettingPanel(MovementTab, "Fly")
CreateToggle(flyPanel, "Enable", {"Fly","Enabled"})
CreateSlider(flyPanel, "Speed", {"Fly","Speed"}, 10, 200, false)
CreateSlider(flyPanel, "Height", {"Fly","HeightOffset"}, 1, 50, false)
flyPanel.Size = UDim2.new(1, -10, 0, 140)
flyPanel.Position = UDim2.new(0, 5, 0, 110)

local bhopPanel = CreateSettingPanel(MovementTab, "Bunny Hop")
CreateToggle(bhopPanel, "Enable", {"BunnyHop","Enabled"})
CreateSlider(bhopPanel, "Max Speed", {"BunnyHop","MaxSpeed"}, 16, 200, false)
bhopPanel.Size = UDim2.new(1, -10, 0, 100)
bhopPanel.Position = UDim2.new(0, 5, 0, 260)

local MiscTab = AllTabs["Misc"]
local wallHackPanel = CreateSettingPanel(MiscTab, "Wall Hack")
CreateToggle(wallHackPanel, "Enable", {"WallHack","Enabled"})
wallHackPanel.Size = UDim2.new(1, -10, 0, 60)

local spinPanel = CreateSettingPanel(MiscTab, "Spin")
CreateToggle(spinPanel, "Enable", {"Spin","Enabled"})
CreateSlider(spinPanel, "Speed", {"Spin","Speed"}, 60, 720, false)
spinPanel.Size = UDim2.new(1, -10, 0, 130)
spinPanel.Position = UDim2.new(0, 5, 0, 70)

local collisionsPanel = CreateSettingPanel(MiscTab, "Collisions")
CreateToggle(collisionsPanel, "Enable", {"Collisions","Enabled"})
collisionsPanel.Size = UDim2.new(1, -10, 0, 60)
collisionsPanel.Position = UDim2.new(0, 5, 0, 210)

local watermarkPanel = CreateSettingPanel(MiscTab, "Watermark")
CreateToggle(watermarkPanel, "Enable", {"Watermark","Enabled"})
watermarkPanel.Size = UDim2.new(1, -10, 0, 60)
watermarkPanel.Position = UDim2.new(0, 5, 0, 280)

local speedIndPanel = CreateSettingPanel(MiscTab, "Speed Indicator")
CreateToggle(speedIndPanel, "Enable", {"SpeedIndicator","Enabled"})
speedIndPanel.Size = UDim2.new(1, -10, 0, 60)
speedIndPanel.Position = UDim2.new(0, 5, 0, 350)

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

local FOVCircle = nil
function CreateFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = Config.FOV.Thickness
    FOVCircle.Radius = Config.FOV.Radius
    FOVCircle.Color = Config.FOV.Color
    FOVCircle.Transparency = 0.5
    FOVCircle.Filled = false
    FOVCircle.Visible = Config.FOVCircle.Enabled
end

if Config.FOVCircle.Enabled then CreateFOVCircle() end

-- Вспомогательные функции
local function FindTorso(char)
    return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function FindHead(char)
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end

-- Функция видимости
local function IsTargetVisible(target)
    local char = LocalPlayer.Character
    if not char then return false end
    local myHrp = char:FindFirstChild("HumanoidRootPart")
    local targetChar = target.Character
    if not myHrp or not targetChar then return false end
    local targetHead = FindHead(targetChar)
    if not targetHead then return false end

    local origin = myHrp.Position
    local destination = targetHead.Position
    local delta = destination - origin
    local raycastResult = workspace:Raycast(origin, delta)
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart ~= targetHead and hitPart.Parent ~= targetChar then
            return false
        end
    end
    return true
end

-- Поиск цели. Если WallHack включен, видимость не проверяется.
local function GetClosestTargetByDistance(range, ignoreWalls)
    local closest = nil
    local bestDist = range
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if not ignoreWalls and not IsTargetVisible(player) then continue end
            local hrp = player.Character:FindFirstChild("HumanoidRootPart") or FindTorso(player.Character)
            if hrp then
                local dist = (myPos.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

local function GetClosestTargetByScreen(range, ignoreWalls)
    local closest = nil
    local bestDist = range
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if not ignoreWalls and not IsTargetVisible(player) then continue end
            local head = FindHead(player.Character)
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (pos - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ПЕРЕХВАТ ВЫСТРЕЛА / Silent Aim / WallHack
local function AttemptAttack()
    if Config.Silent.Enabled or Config.WallHack.Enabled then
        local ignoreWalls = Config.WallHack.Enabled
        local target = GetClosestTargetByDistance(Config.Silent.Range, ignoreWalls)
        if target and target.Character then
            local aimPart = FindHead(target.Character)
            if aimPart then
                -- Если Silent Aim или WallHack: отправляем координаты цели в RemoteEvent (для пули)
                -- Наводим камеру на цель (чтобы пуля "вылетела" в нужную сторону)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                
                -- Активируем Tool
                local char = LocalPlayer.Character
                if char then
                    for _, child in ipairs(char:GetChildren()) do
                        if child:IsA("Tool") then
                            pcall(function() child:Activate() end)
                        end
                    end
                end
                -- Отправляем координаты цели в RemoteEvent (для обхода стен)
                for _, remote in ipairs(ReplicatedStorage:GetChildren()) do
                    if remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer(aimPart.Position) end)
                    end
                end
            end
        end
    end
end

-- Перехват клика для Silent Aim / WallHack
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if (Config.Silent.Enabled or Config.WallHack.Enabled) and not MenuOpen then
            AttemptAttack()
        end
    end
end)

-- Обработка AimBot наведения
RunService.RenderStepped:Connect(function()
    if Config.FOVCircle.Enabled and FOVCircle then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = center
        FOVCircle.Radius = Config.FOV.Radius
        FOVCircle.Thickness = Config.FOV.Thickness
        FOVCircle.Color = Config.FOV.Color
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end

    if Config.AimBot.Enabled and not MenuOpen then
        local ignoreWalls = Config.WallHack.Enabled
        local target = GetClosestTargetByScreen(Config.FOV.Radius, ignoreWalls)
        if not target then target = GetClosestTargetByDistance(Config.AimBot.Range, ignoreWalls) end
        if target and target.Character then
            local aimPart = FindHead(target.Character)
            if aimPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
            end
        end
    end

    if Config.Trigger.Enabled and not MenuOpen then
        triggerDelay = triggerDelay + 1
        if triggerDelay >= Config.Trigger.Delay then
            local ignoreWalls = Config.WallHack.Enabled
            local target = GetClosestTargetByDistance(Config.Trigger.Range, ignoreWalls)
            if target then
                AttemptAttack()
            end
            triggerDelay = 0
        end
    end

    if SpinActive then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.Spin.Speed * 3), 0)
            end
        end
    end
end)

-- ESP (с удалением при смерти)
local function RemoveESPForPlayer(player)
    local data = ESPCache[player]
    if data then
        for _, obj in ipairs(data) do
            pcall(function() obj:Remove() end)
        end
        ESPCache[player] = nil
    end
end

local function CreateESPForPlayer(player)
    if not ESPActive then return end
    local data = {}
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false
    table.insert(data, box)

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size = 13
    nameText.Font = 2
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Outline = true
    nameText.Center = true
    table.insert(data, nameText)

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Size = 13
    healthText.Font = 2
    healthText.Color = Color3.fromRGB(255, 255, 255)
    healthText.Outline = true
    healthText.Center = true
    table.insert(data, healthText)

    local distText = Drawing.new("Text")
    distText.Visible = false
    distText.Size = 13
    distText.Font = 2
    distText.Color = Color3.fromRGB(255, 255, 255)
    distText.Outline = true
    distText.Center = true
    table.insert(data, distText)

    ESPCache[player] = data

    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            RemoveESPForPlayer(player)
        end)
    end
end

function EnableESP()
    ESPActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESPForPlayer(player)
        end
    end
end

function DisableESP()
    ESPActive = false
    for _, data in pairs(ESPCache) do
        for _, obj in ipairs(data) do
            pcall(function() obj:Remove() end)
        end
    end
    ESPCache = {}
end

Players.PlayerRemoving:Connect(function(player)
    RemoveESPForPlayer(player)
end)

RunService.RenderStepped:Connect(function()
    if ESPActive then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local data = ESPCache[player]
                if not data then
                    CreateESPForPlayer(player)
                    data = ESPCache[player]
                end
                if data then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart") or FindTorso(player.Character)
                    local head = FindHead(player.Character)
                    if hrp and head then
                        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local footPos, footOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                        if onScreen and headOnScreen and footOnScreen then
                            local box = data[1]
                            local nameText = data[2]
                            local healthText = data[3]
                            local distText = data[4]

                            if Config.ESP.Box then
                                local scale = 1000 / hrpPos.Z
                                local width = 0.7 * scale
                                local height = (headPos.Y - footPos.Y) * 1.1
                                box.Size = Vector2.new(width, height)
                                box.Position = Vector2.new(hrpPos.X - width / 2, (headPos.Y + footPos.Y) / 2 - height / 2)
                                box.Visible = true
                            else
                                box.Visible = false
                            end

                            if Config.ESP.Name then
                                nameText.Position = Vector2.new(headPos.X, headPos.Y - 15)
                                nameText.Text = player.Name
                                nameText.Visible = true
                            else
                                nameText.Visible = false
                            end

                            if Config.ESP.Health then
                                healthText.Position = Vector2.new(headPos.X, headPos.Y - 30)
                                healthText.Text = tostring(math.floor(player.Character.Humanoid.Health))
                                healthText.Visible = true
                            else
                                healthText.Visible = false
                            end

                            if Config.ESP.Distance then
                                local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                distText.Position = Vector2.new(headPos.X, headPos.Y - 45)
                                distText.Text = tostring(math.floor(dist)) .. "m"
                                distText.Visible = true
                            else
                                distText.Visible = false
                            end
                        else
                            for _, obj in ipairs(data) do obj.Visible = false end
                        end
                    end
                end
            end
        end
    end
end)

function EnableChams()
    ChamsActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, desc in ipairs(player.Character:GetDescendants()) do
                if desc:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = desc
                    highlight.FillColor = Config.Chams.FillColor
                    highlight.OutlineColor = Config.Chams.OutlineColor
                    highlight.FillTransparency = Config.Chams.Transparency
                    highlight.OutlineTransparency = 0.5
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = desc
                    table.insert(ChamsObjects, highlight)
                end
            end
        end
    end
end

function DisableChams()
    ChamsActive = false
    for _, obj in pairs(ChamsObjects) do
        pcall(function() obj:Destroy() end)
    end
    ChamsObjects = {}
end

function EnableFly()
    FlyActive = true
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
            humanoid.WalkSpeed = 0
        end
    end
end

function DisableFly()
    FlyActive = false
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = 16
        end
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
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

function EnableSpin()
    SpinActive = true
end

function DisableSpin()
    SpinActive = false
end

-- КОЛЛИЗИИ (правильно: не проваливаемся сквозь пол)
function EnableCollisions()
    CollisionsActive = true
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local playerY = hrp.Position.Y
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    if v.Position.Y >= playerY - 1 then
                        v.CanCollide = false
                    end
                end
            end
        end
    end
end

function DisableCollisions()
    CollisionsActive = false
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end

RunService.Heartbeat:Connect(function()
    if CollisionsActive then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local playerY = hrp.Position.Y
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        if v.Position.Y >= playerY - 1 then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local currentTick = tick()
    if currentTick - LastFrameTime > 0 then
        CurrentFPS = math.floor(1 / (currentTick - LastFrameTime))
        LastFrameTime = currentTick
    end

    if Config.BunnyHop.Enabled then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid.Jump = true
                    if tick() - LastBhopTime > 0.1 then
                        BhopSpeed = math.min(BhopSpeed + 5, Config.BunnyHop.MaxSpeed)
                        humanoid.WalkSpeed = BhopSpeed
                        LastBhopTime = tick()
                    end
                end
            end
        else
            BhopSpeed = 16
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if FlyActive and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if hrp and humanoid then
            local moveDir = humanoid.MoveDirection
            local vel = moveDir * Config.Fly.Speed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
                vel = vel + Vector3.new(0, 50, 0)
                humanoid.Jump = false
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vel = vel - Vector3.new(0, 50, 0)
            end
            vel = vel + Vector3.new(0, Config.Fly.HeightOffset, 0)
            hrp.AssemblyLinearVelocity = vel
            humanoid.PlatformStand = true
        end
    end

    if SpeedActive and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = Config.Speed.Speed end
    end
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
Watermark.ZIndex = 300
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
SpeedLabel.ZIndex = 300
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
        local speed = LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude
        SpeedLabel.Text = "Speed: " .. math.floor(speed)
    else
        SpeedLabel.Visible = false
    end
end)

-- ПЕРЕТАСКИВАНИЕ МЕНЮ ЗА ЛЮБОЙ КРАЙ/ФОН
local isDraggingMenu = false
local dragOffsetMenu = Vector2.new()

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Проверяем, что не нажали на кнопки/переключатели внутри
        local objects = UserInputService:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        local isInteractable = false
        for _, obj in ipairs(objects) do
            if obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("ImageButton") or obj:IsA("Frame") then
                if obj.Name ~= "MainFrame" and obj.Name ~= "TitleBar" and obj.Name ~= "ContentArea" then
                    isInteractable = true
                    break
                end
            end
        end

        if not isInteractable or objects[1] == MainFrame or objects[1] == TitleBar or objects[1] == ContentArea then
            isDraggingMenu = true
            dragOffsetMenu = Vector2.new(input.Position.X - MainFrame.AbsolutePosition.X, input.Position.Y - MainFrame.AbsolutePosition.Y)
        end
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingMenu = false
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if isDraggingMenu then
        MainFrame.Position = UDim2.new(0, input.Position.X - dragOffsetMenu.X, 0, input.Position.Y - dragOffsetMenu.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
        MainFrame.Position = UDim2.new(0, input.Position.X - dragOffsetMenu.X, 0, input.Position.Y - dragOffsetMenu.Y)
    end
end)

-- КНОПКА ОТКРЫТИЯ
local isDraggingCircle = false
local dragStartCircle = Vector2.new()
local dragOffsetCircle = Vector2.new()
local isClickCircle = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        local absPos = CircleButton.AbsolutePosition
        local size = CircleButton.AbsoluteSize
        if pos.X >= absPos.X and pos.X <= absPos.X + size.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + size.Y then
            isDraggingCircle = true
            isClickCircle = true
            dragStartCircle = pos
            dragOffsetCircle = Vector2.new(pos.X - CircleButton.AbsolutePosition.X, pos.Y - CircleButton.AbsolutePosition.Y)
        end
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if isDraggingCircle then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        if (pos - dragStartCircle).Magnitude > 10 then
            isClickCircle = false
            CircleButton.Position = UDim2.new(0, pos.X - dragOffsetCircle.X, 0, pos.Y - dragOffsetCircle.Y)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingCircle and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        if (pos - dragStartCircle).Magnitude > 10 then
            isClickCircle = false
            CircleButton.Position = UDim2.new(0, pos.X - dragOffsetCircle.X, 0, pos.Y - dragOffsetCircle.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isDraggingCircle then
            if isClickCircle then
                MenuOpen = not MenuOpen
                MainFrame.Visible = MenuOpen
                if MenuOpen then
                    if Config.FOVCircle.Enabled then CreateFOVCircle() end
                else
                    if FOVCircle then FOVCircle.Visible = false end
                end
            end
            isDraggingCircle = false
        end
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

-- Авто-респавн
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            if ESPActive then CreateESPForPlayer(player) end
            if ChamsActive then
                DisableChams()
                EnableChams()
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if CollisionsActive then
        wait(0.5)
        EnableCollisions()
    end
    if SpinActive then
        wait(0.5)
        EnableSpin()
    end
end)

if Config.FOVCircle.Enabled then CreateFOVCircle() end
print("Hiruku MM2 Script Loaded!")