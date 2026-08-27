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
    ESP = {Enabled = false, Box = true, Name = true, Health = true, Distance = true, Skeleton = false},
    BunnyHop = {Enabled = false},
    Speed = {Enabled = false, Speed = 50},
    Fly = {Enabled = false, Speed = 50},
    AntiAim = {Enabled = false, Mode = "Jitter", SpinSpeed = 90, HeadDown = false},
    Watermark = {Enabled = true},
    FOVCircle = {Enabled = true},
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
local SkeletonLines = {}
local EspCache = {}
local IndicatorObjects = {}
local DistanceLines = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local CircleButton = Instance.new("TextButton")
CircleButton.Size = UDim2.new(0, 40, 0, 40)
CircleButton.Position = UDim2.new(0.02, 0, 0.5, -20)
CircleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
CircleButton.Text = "H"
CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.TextScaled = true
CircleButton.Font = Enum.Font.Code
CircleButton.BorderSizePixel = 1
CircleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.AutoButtonColor = false
CircleButton.Parent = ScreenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = CircleButton

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hiruku"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextScaled = false
TitleText.Font = Enum.Font.Code
TitleText.TextSize = 16
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Code
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = CloseBtn

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 110, 1, -30)
Tabs.Position = UDim2.new(0, 0, 0, 30)
Tabs.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Tabs.BorderSizePixel = 0
Tabs.Parent = MainFrame

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -120, 1, -30)
ContentArea.Position = UDim2.new(0, 120, 0, 30)
ContentArea.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ContentArea.Parent = MainFrame

local UILayout = Instance.new("UIListLayout")
UILayout.SortOrder = Enum.SortOrder.LayoutOrder
UILayout.Padding = UDim.new(0, 5)
UILayout.Parent = ContentArea

local Sections = {"Combat", "Visuals", "Movement", "Misc"}
local SectionIconIds = {
    Combat = "rbxassetid://6031094667",
    Visuals = "rbxassetid://6031094667",
    Movement = "rbxassetid://6031094667",
    Misc = "rbxassetid://6031094667"
}

local TabsList = Instance.new("UIListLayout")
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.Padding = UDim.new(0, 3)
TabsList.Parent = Tabs

local TabButtons = {}
local AllTabs = {}

for i, name in ipairs(Sections) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, (i-1) * 40)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = false
    btn.Font = Enum.Font.Code
    btn.TextSize = 13
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(30, 30, 30)
    btn.Parent = Tabs
    TabButtons[name] = btn
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = btn
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, 6, 0.5, -9)
    icon.BackgroundTransparency = 1
    icon.Image = SectionIconIds[name]
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = false
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Parent = btn
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = ContentArea
    AllTabs[name] = content
end

local function CreateFolder(parent, title, options)
    local folder = Instance.new("Frame")
    folder.Size = UDim2.new(1, 0, 0, 30)
    folder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    folder.BorderSizePixel = 1
    folder.BorderColor3 = Color3.fromRGB(30, 30, 30)
    folder.Parent = parent
    
    local folderCorner = Instance.new("UICorner")
    folderCorner.CornerRadius = UDim.new(0, 4)
    folderCorner.Parent = folder
    
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 1, 0)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextScaled = false
    header.Font = Enum.Font.Code
    header.TextSize = 13
    header.BorderSizePixel = 0
    header.Parent = folder
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -16, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.TextScaled = true
    arrow.Font = Enum.Font.Code
    arrow.Parent = header
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = folder
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 2)
    contentLayout.Parent = content
    
    local expanded = false
    
    local function updateContent()
        local childCount = 0
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("Frame") then childCount = childCount + 1 end
        end
        if expanded then
            folder.Size = UDim2.new(1, 0, 0, 30 + childCount * 28)
            arrow.Text = "▲"
        else
            folder.Size = UDim2.new(1, 0, 0, 30)
            arrow.Text = "▼"
        end
    end
    
    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateContent()
    end)
    
    for _, opt in ipairs(options) do
        if opt.type == "toggle" then
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 28)
            holder.BackgroundTransparency = 1
            holder.Parent = content
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.65, 0, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opt.label
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextScaled = false
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.Parent = holder
            
            local toggle = Instance.new("Frame")
            toggle.Size = UDim2.new(0, 30, 0, 16)
            toggle.Position = UDim2.new(0.75, 0, 0.2, 0)
            toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            toggle.BorderSizePixel = 1
            toggle.BorderColor3 = Color3.fromRGB(80, 80, 80)
            toggle.Parent = holder
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(1, 0)
            toggleCorner.Parent = toggle
            
            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 12, 0, 12)
            check.Position = UDim2.new(0, 2, 0, 2)
            check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            check.BorderSizePixel = 0
            check.Parent = toggle
            
            local checkCorner = Instance.new("UICorner")
            checkCorner.CornerRadius = UDim.new(1, 0)
            checkCorner.Parent = check
            
            local function updateToggle()
                local current = Config
                for _, v in ipairs(opt.path) do current = current[v] end
                if current then
                    check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    TweenService:Create(check, TweenInfo.new(0.2), {Position = UDim2.new(0, 16, 0, 2)}):Play()
                else
                    check.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    TweenService:Create(check, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
                end
            end
            updateToggle()
            
            toggle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local current = Config
                    for i = 1, #opt.path - 1 do current = current[opt.path[i]] end
                    current[opt.path[#opt.path]] = not current[opt.path[#opt.path]]
                    updateToggle()
                    if opt.path[1] == "ESP" and opt.path[2] == "Enabled" then
                        if Config.ESP.Enabled then EnableESP() else DisableESP() end
                    end
                    if opt.path[1] == "Chams" and opt.path[2] == "Enabled" then
                        if Config.Chams.Enabled then EnableChams() else DisableChams() end
                    end
                    if opt.path[1] == "Fly" and opt.path[2] == "Enabled" then
                        if Config.Fly.Enabled then EnableFly() else DisableFly() end
                    end
                    if opt.path[1] == "Speed" and opt.path[2] == "Enabled" then
                        if Config.Speed.Enabled then EnableSpeed() else DisableSpeed() end
                    end
                    if opt.path[1] == "AntiAim" and opt.path[2] == "Enabled" then
                        if Config.AntiAim.Enabled then EnableAntiAim() else DisableAntiAim() end
                    end
                end
            end)
        elseif opt.type == "slider" then
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 28)
            holder.BackgroundTransparency = 1
            holder.Parent = content
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.4, 0, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opt.label
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextScaled = false
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.Parent = holder
            
            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(0.15, 0, 1, 0)
            val.Position = UDim2.new(0.45, 0, 0, 0)
            val.BackgroundTransparency = 1
            val.Text = "0"
            val.TextColor3 = Color3.fromRGB(255, 255, 255)
            val.TextScaled = false
            val.Font = Enum.Font.Code
            val.TextSize = 12
            val.Parent = holder
            
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(0.3, 0, 0.2, 0)
            slider.Position = UDim2.new(0.65, 0, 0.4, 0)
            slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            slider.BorderSizePixel = 1
            slider.BorderColor3 = Color3.fromRGB(80, 80, 80)
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
            
            local function updateSlider()
                local current = Config
                for _, v in ipairs(opt.path) do current = current[v] end
                local percent = (current - opt.min) / (opt.max - opt.min)
                fill.Size = UDim2.new(math.clamp(percent,0,1), 0, 1, 0)
                if opt.decimal then
                    val.Text = string.format("%.2f", current)
                else
                    val.Text = tostring(math.round(current))
                end
            end
            updateSlider()
            
            local dragging = false
            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local pos = input.Position.X - slider.AbsolutePosition.X
                    local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                    local value = opt.min + (opt.max - opt.min) * percent
                    if opt.decimal then value = math.round(value / 0.01) * 0.01 else value = math.round(value) end
                    local current = Config
                    for i = 1, #opt.path - 1 do current = current[opt.path[i]] end
                    current[opt.path[#opt.path]] = value
                    updateSlider()
                end
            end)
            slider.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position.X - slider.AbsolutePosition.X
                    local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                    local value = opt.min + (opt.max - opt.min) * percent
                    if opt.decimal then value = math.round(value / 0.01) * 0.01 else value = math.round(value) end
                    local current = Config
                    for i = 1, #opt.path - 1 do current = current[opt.path[i]] end
                    current[opt.path[#opt.path]] = value
                    updateSlider()
                    if opt.path[1] == "AimBot" and opt.path[2] == "FOV" and Config.FOVCircle.Enabled then
                        CreateFOVCircle()
                    end
                end
            end)
            slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        elseif opt.type == "dropdown" then
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 28)
            holder.BackgroundTransparency = 1
            holder.Parent = content
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.4, 0, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opt.label
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextScaled = false
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.Parent = holder
            
            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(0.3, 0, 0.6, 0)
            dropdown.Position = UDim2.new(0.65, 0, 0.2, 0)
            dropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdown.TextScaled = false
            dropdown.Font = Enum.Font.Code
            dropdown.TextSize = 12
            dropdown.BorderSizePixel = 1
            dropdown.BorderColor3 = Color3.fromRGB(80, 80, 80)
            dropdown.Parent = holder
            
            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 2)
            dropCorner.Parent = dropdown
            
            local current = Config
            for _, v in ipairs(opt.path) do current = current[v] end
            dropdown.Text = current
            
            local expanded = false
            local optionFrame = Instance.new("Frame")
            optionFrame.Size = UDim2.new(0.3, 0, 0, 0)
            optionFrame.Position = UDim2.new(0.65, 0, 0.8, 0)
            optionFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            optionFrame.BorderSizePixel = 1
            optionFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
            optionFrame.Visible = false
            optionFrame.ClipsDescendants = true
            optionFrame.Parent = holder
            
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 2)
            optCorner.Parent = optionFrame
            
            local function updateOptions()
                for _, child in pairs(optionFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, option in ipairs(opt.options) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 20)
                    btn.Position = UDim2.new(0, 0, 0, (i-1) * 20)
                    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                    btn.Text = option
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.TextScaled = false
                    btn.Font = Enum.Font.Code
                    btn.TextSize = 12
                    btn.BorderSizePixel = 0
                    btn.Parent = optionFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        local current = Config
                        for i = 1, #opt.path - 1 do current = current[opt.path[i]] end
                        current[opt.path[#opt.path]] = option
                        dropdown.Text = option
                        expanded = false
                        optionFrame.Visible = false
                        optionFrame.Size = UDim2.new(0.3, 0, 0, 0)
                    end)
                end
                optionFrame.Size = UDim2.new(0.3, 0, 0, #opt.options * 20)
            end
            updateOptions()
            
            dropdown.MouseButton1Click:Connect(function()
                expanded = not expanded
                optionFrame.Visible = expanded
                if expanded then
                    optionFrame.Size = UDim2.new(0.3, 0, 0, #opt.options * 20)
                else
                    optionFrame.Size = UDim2.new(0.3, 0, 0, 0)
                end
            end)
        end
    end
    
    updateContent()
    return folder
end

CreateFolder(AllTabs["Combat"], "AimBot", {
    {type = "toggle", label = "Enable", path = {"AimBot","Enabled"}},
    {type = "slider", label = "FOV", path = {"AimBot","FOV"}, min = 1, max = 180},
    {type = "slider", label = "Smooth", path = {"AimBot","Smooth"}, min = 0, max = 1, decimal = true},
    {type = "slider", label = "Range", path = {"AimBot","Range"}, min = 1, max = 50},
    {type = "dropdown", label = "Aim Part", path = {"AimBot","AimPart"}, options = {"Head","Torso","HumanoidRootPart"}}
})
CreateFolder(AllTabs["Combat"], "Silent", {
    {type = "toggle", label = "Enable", path = {"Silent","Enabled"}},
    {type = "slider", label = "FOV", path = {"Silent","FOV"}, min = 1, max = 180},
    {type = "slider", label = "Range", path = {"Silent","Range"}, min = 1, max = 50}
})
CreateFolder(AllTabs["Combat"], "Trigger", {
    {type = "toggle", label = "Enable", path = {"Trigger","Enabled"}},
    {type = "slider", label = "FOV", path = {"Trigger","FOV"}, min = 1, max = 180},
    {type = "slider", label = "Range", path = {"Trigger","Range"}, min = 1, max = 50},
    {type = "slider", label = "Delay", path = {"Trigger","Delay"}, min = 10, max = 500}
})
CreateFolder(AllTabs["Visuals"], "ESP", {
    {type = "toggle", label = "Enable", path = {"ESP","Enabled"}},
    {type = "toggle", label = "Box", path = {"ESP","Box"}},
    {type = "toggle", label = "Name", path = {"ESP","Name"}},
    {type = "toggle", label = "Health", path = {"ESP","Health"}},
    {type = "toggle", label = "Distance", path = {"ESP","Distance"}},
    {type = "toggle", label = "Skeleton", path = {"ESP","Skeleton"}}
})
CreateFolder(AllTabs["Visuals"], "Chams", {
    {type = "toggle", label = "Enable", path = {"Chams","Enabled"}},
    {type = "slider", label = "Transparency", path = {"Chams","Transparency"}, min = 0, max = 1, decimal = true}
})
CreateFolder(AllTabs["Visuals"], "FOV", {
    {type = "toggle", label = "Show", path = {"FOVCircle","Enabled"}}
})
CreateFolder(AllTabs["Visuals"], "World", {
    {type = "toggle", label = "Fog", path = {"World","Fog","Enabled"}},
    {type = "slider", label = "Fog Density", path = {"World","Fog","Density"}, min = 0, max = 1, decimal = true},
    {type = "toggle", label = "Sky", path = {"World","Sky","Enabled"}},
    {type = "toggle", label = "Ambient", path = {"World","Ambient","Enabled"}}
})
CreateFolder(AllTabs["Movement"], "Speed", {
    {type = "toggle", label = "Enable", path = {"Speed","Enabled"}},
    {type = "slider", label = "Speed", path = {"Speed","Speed"}, min = 10, max = 200}
})
CreateFolder(AllTabs["Movement"], "Fly", {
    {type = "toggle", label = "Enable", path = {"Fly","Enabled"}},
    {type = "slider", label = "Speed", path = {"Fly","Speed"}, min = 10, max = 200}
})
CreateFolder(AllTabs["Movement"], "Bunny Hop", {
    {type = "toggle", label = "Enable", path = {"BunnyHop","Enabled"}}
})
CreateFolder(AllTabs["Misc"], "Anti-Aim", {
    {type = "toggle", label = "Enable", path = {"AntiAim","Enabled"}},
    {type = "dropdown", label = "Mode", path = {"AntiAim","Mode"}, options = {"Jitter","Spin","Backwards"}},
    {type = "slider", label = "Spin Speed", path = {"AntiAim","SpinSpeed"}, min = 30, max = 360},
    {type = "toggle", label = "Head Down", path = {"AntiAim","HeadDown"}}
})
CreateFolder(AllTabs["Misc"], "Watermark", {
    {type = "toggle", label = "Enable", path = {"Watermark","Enabled"}}
})

local function SwitchTab(name)
    for _, tab in pairs(AllTabs) do
        tab.Visible = false
    end
    AllTabs[name].Visible = true
    for _, btn in pairs(TabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    TabButtons[name].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabButtons[name].TextColor3 = Color3.fromRGB(255, 255, 255)
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end
SwitchTab("Combat")

function CreateFOVCircle()
    if FOVCircle then FOVCircle:Destroy() end
    FOVCircle = Instance.new("ImageLabel")
    FOVCircle.Size = UDim2.new(0, Config.AimBot.FOV * 2, 0, Config.AimBot.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Config.AimBot.FOV, 0.5, -Config.AimBot.FOV)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.Image = "rbxassetid://0"
    FOVCircle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    FOVCircle.BackgroundTransparency = 0.85
    FOVCircle.BorderSizePixel = 2
    FOVCircle.BorderColor3 = Color3.fromRGB(255,255,255)
    FOVCircle.ZIndex = 0
    FOVCircle.Parent = ScreenGui
    
    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(1,0)
    fovCorner.Parent = FOVCircle
end

function CreateESPForPlayer(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = char
    table.insert(ESPObjects, espFolder)
    
    if Config.ESP.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3,5,3)
        box.Adornee = root
        box.Color3 = Color3.fromRGB(255,255,255)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.ZIndex = 0
        box.Parent = espFolder
        table.insert(ESPObjects, box)
    end
    
    if Config.ESP.Name then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0,120,0,20)
        nameTag.Adornee = root
        nameTag.AlwaysOnTop = true
        nameTag.Parent = espFolder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1,0,1,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Code
        nameLabel.Parent = nameTag
        table.insert(ESPObjects, nameTag)
    end
    
    if Config.ESP.Health then
        local healthTag = Instance.new("BillboardGui")
        healthTag.Size = UDim2.new(0,100,0,20)
        healthTag.Position = UDim2.new(0,0,0,20)
        healthTag.Adornee = root
        healthTag.AlwaysOnTop = true
        healthTag.Parent = espFolder
        
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1,0,1,0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
        healthLabel.TextColor3 = Color3.fromRGB(255,255,255)
        healthLabel.TextScaled = true
        healthLabel.Font = Enum.Font.Code
        healthLabel.Parent = healthTag
        table.insert(ESPObjects, healthTag)
    end
    
    if Config.ESP.Distance then
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0,80,0,20)
        distTag.Position = UDim2.new(0,0,0,40)
        distTag.Adornee = root
        distTag.AlwaysOnTop = true
        distTag.Parent = espFolder
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1,0,1,0)
        distLabel.BackgroundTransparency = 1
        local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        distLabel.Text = math.floor(dist) .. "m"
        distLabel.TextColor3 = Color3.fromRGB(255,255,255)
        distLabel.TextScaled = true
        distLabel.Font = Enum.Font.Code
        distLabel.Parent = distTag
        table.insert(ESPObjects, distTag)
    end
    
    if Config.ESP.Skeleton then
        DrawSkeletonForPlayer(char)
    end
end

function DrawSkeletonForPlayer(char)
    local parts = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    }
    
    for _, connection in ipairs(parts) do
        local part1 = char:FindFirstChild(connection[1])
        local part2 = char:FindFirstChild(connection[2])
        if part1 and part2 then
            local attachment1 = Instance.new("Attachment")
            attachment1.Position = Vector3.new(0,0,0)
            attachment1.Parent = part1
            
            local attachment2 = Instance.new("Attachment")
            attachment2.Position = Vector3.new(0,0,0)
            attachment2.Parent = part2
            
            local line = Instance.new("Beam")
            line.Attachment0 = attachment1
            line.Attachment1 = attachment2
            line.Width0 = 0.1
            line.Width1 = 0.1
            line.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
            line.Transparency = NumberSequence.new(0)
            line.Parent = char
            table.insert(SkeletonLines, line)
        end
    end
end

function EnableESP()
    if ESPActive then return end
    ESPActive = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then CreateESPForPlayer(player) end
        end
    end
end

function DisableESP()
    ESPActive = false
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
    for _, line in pairs(SkeletonLines) do
        pcall(function() line:Destroy() end)
    end
    SkeletonLines = {}
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
        pcall(function() obj:Destroy() end)
    end
    ChamsObjects = {}
end

function CreateChamsForPlayer(player)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
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

function EnableFly()
    if FlyActive then return end
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

local circleDragging = false
local circleDragOffset = nil

CircleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        circleDragging = true
        circleDragOffset = Vector2.new(input.Position.X - CircleButton.AbsolutePosition.X, input.Position.Y - CircleButton.AbsolutePosition.Y)
    end
end)

CircleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        circleDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if circleDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local newPos = UDim2.new(0, input.Position.X - circleDragOffset.X, 0, input.Position.Y - circleDragOffset.Y)
        CircleButton.Position = newPos
    end
end)

CircleButton.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    if MenuOpen then
        if Config.FOVCircle.Enabled then CreateFOVCircle() end
    else
        if FOVCircle then FOVCircle:Destroy() end
    end
end)

CircleButton.TouchTap:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    if MenuOpen then
        if Config.FOVCircle.Enabled then CreateFOVCircle() end
    else
        if FOVCircle then FOVCircle:Destroy() end
    end
end)

local titleDragging = false
local titleDragOffset = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        titleDragging = true
        titleDragOffset = Vector2.new(input.Position.X - MainFrame.AbsolutePosition.X, input.Position.Y - MainFrame.AbsolutePosition.Y)
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        titleDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if titleDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local newPos = UDim2.new(0, input.Position.X - titleDragOffset.X, 0, input.Position.Y - titleDragOffset.Y)
        MainFrame.Position = newPos
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
    if FOVCircle then FOVCircle:Destroy() end
end)

CloseBtn.TouchTap:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
    if FOVCircle then FOVCircle:Destroy() end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if ESPActive then CreateESPForPlayer(player) end
        if ChamsActive then CreateChamsForPlayer(player) end
    end)
end)

local function GetClosestPlayer()
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
local function UpdateIndicators()
    for _, obj in pairs(IndicatorObjects) do
        obj:Destroy()
    end
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
    for _, obj in pairs(DistanceLines) do
        obj:Destroy()
    end
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

RunService.RenderStepped:Connect(function()
    if Config.AimBot.Enabled and not MenuOpen then
        local target = GetClosestPlayer()
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
    
    if Config.Watermark.Enabled then
        local frameTime = tick() - LastFrameTime
        LastFrameTime = tick()
        if frameTime > 0 then
            CurrentFPS = math.floor(1 / frameTime)
        end
    end
    
    UpdateIndicators()
    UpdateDistanceLines()
end)

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 180, 0, 18)
Watermark.Position = UDim2.new(0.5, -90, 0, 5)
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

RunService.Heartbeat:Connect(function()
    if Config.Watermark.Enabled then
        Watermark.Visible = true
        Watermark.Text = "Hiruku | FPS: " .. CurrentFPS .. " | Players: " .. #Players:GetPlayers()
    else
        Watermark.Visible = false
    end
end)

if Config.FOVCircle.Enabled then CreateFOVCircle() end
print("Hiruku Internal Loaded! Press H to open menu")