local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    AimBot = {Enabled = false, FOV = 35, Smooth = 0.45, Range = 15},
    Silent = {Enabled = false, Range = 15, FOV = 35, Smooth = 0.45},
    Trigger = {Enabled = false, Range = 20, FOV = 10, Delay = 50},
    Chams = {Enabled = false, Transparency = 0.3},
    ESP = {Enabled = false, Box = true, Name = true, Health = true, Distance = true},
    BunnyHop = {Enabled = false},
    Speed = {Enabled = false, Speed = 50},
    Fly = {Enabled = false, Speed = 50},
    AntiAim = {Enabled = false, Mode = "Jitter"},
    Watermark = {Enabled = true}
}

local MenuOpen = false
local ESPActive = false
local ChamsActive = false
local FlyActive = false
local SpeedActive = false
local AntiAimActive = false
local CurrentFPS = 0
local LastFrameTime = tick()
local SelectedSection = "Combat"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 45, 0, 45)
CircleButton.Position = UDim2.new(0.02, 0, 0.5, -22.5)
CircleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CircleButton.BackgroundTransparency = 0
CircleButton.BorderSizePixel = 2
CircleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
CircleButton.Image = "rbxassetid://0"
CircleButton.AutoButtonColor = false
CircleButton.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = CircleButton

local CircleInner = Instance.new("ImageLabel")
CircleInner.Size = UDim2.new(1, -6, 1, -6)
CircleInner.Position = UDim2.new(0, 3, 0, 3)
CircleInner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
CircleInner.BackgroundTransparency = 0
CircleInner.BorderSizePixel = 0
CircleInner.Image = "rbxassetid://0"
CircleInner.Parent = CircleButton

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = CircleInner

local HirukuText = Instance.new("TextLabel")
HirukuText.Size = UDim2.new(1, 0, 1, 0)
HirukuText.BackgroundTransparency = 1
HirukuText.Text = "H"
HirukuText.TextColor3 = Color3.fromRGB(255, 0, 0)
HirukuText.TextScaled = true
HirukuText.Font = Enum.Font.GothamBold
HirukuText.Parent = CircleInner

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.BorderColor3 = Color3.fromRGB(255, 0, 0)
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hiruku Internal"
TitleText.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 3)
closeCorner.Parent = CloseBtn

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 80, 1, -30)
LeftPanel.Position = UDim2.new(0, 0, 0, 30)
LeftPanel.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -80, 1, -30)
RightPanel.Position = UDim2.new(0, 80, 0, 30)
RightPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightPanel.BorderSizePixel = 1
RightPanel.BorderColor3 = Color3.fromRGB(20, 20, 20)
RightPanel.Parent = MainFrame

local Sections = {"Combat", "Visuals", "Movement", "Misc"}
local SectionButtons = {}
local SectionContents = {}

for i, name in ipairs(Sections) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 35)
    btn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = LeftPanel
    SectionButtons[name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    content.BackgroundTransparency = 0
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = RightPanel
    SectionContents[name] = content
end

local function CreateSlider(parent, title, configPath, min, max, decimal)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 40)
    holder.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 42)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.15, 0, 0.5, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.TextColor3 = Color3.fromRGB(255, 0, 0)
    val.TextScaled = true
    val.Font = Enum.Font.GothamBold
    val.Parent = holder
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.4, 0, 0.25, 0)
    slider.Position = UDim2.new(0.55, 0, 0.5, 0)
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    slider.BorderSizePixel = 0
    slider.Parent = holder
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
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
    end
    
    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    
    slider.InputBegan:Connect(onInputBegan)
    slider.InputChanged:Connect(onInputChanged)
    slider.InputEnded:Connect(onInputEnded)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 42 + 10)
end

local function CreateToggle(parent, title, configPath)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 35)
    holder.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 37)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 35, 0, 18)
    toggle.Position = UDim2.new(0.75, 0, 0.25, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggle.BorderSizePixel = 0
    toggle.Parent = holder
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 14, 0, 14)
    check.Position = UDim2.new(0, 2, 0, 2)
    check.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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
            check.Position = UDim2.new(0, 19, 0, 2)
            toggle.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        else
            check.Position = UDim2.new(0, 2, 0, 2)
            toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end
    updateToggle()
    
    local function onToggle()
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
        if configPath[1] == "Speed" and configPath[2] == "Enabled" then
            if Config.Speed.Enabled then EnableSpeed() else DisableSpeed() end
        end
        if configPath[1] == "AntiAim" and configPath[2] == "Enabled" then
            if Config.AntiAim.Enabled then EnableAntiAim() else DisableAntiAim() end
        end
    end
    
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onToggle()
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 37 + 10)
end

local function CreateDropdown(parent, title, configPath, options)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 35)
    holder.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 37)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.4, 0, 0.7, 0)
    dropdown.Position = UDim2.new(0.55, 0, 0.15, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    dropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdown.TextScaled = true
    dropdown.Font = Enum.Font.Gotham
    dropdown.BorderSizePixel = 1
    dropdown.BorderColor3 = Color3.fromRGB(255, 0, 0)
    dropdown.Parent = holder
    
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 3)
    dropCorner.Parent = dropdown
    
    local current = Config
    for _, v in ipairs(configPath) do current = current[v] end
    dropdown.Text = current
    
    local expanded = false
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(0.4, 0, 0, 0)
    optionFrame.Position = UDim2.new(0.55, 0, 0.85, 0)
    optionFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    optionFrame.BorderSizePixel = 1
    optionFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    optionFrame.Visible = false
    optionFrame.ClipsDescendants = true
    optionFrame.Parent = holder
    
    local optCorner = Instance.new("UICorner")
    optCorner.CornerRadius = UDim.new(0, 3)
    optCorner.Parent = optionFrame
    
    local function updateOptions()
        for _, child in pairs(optionFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, (i-1) * 22)
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
                optionFrame.Size = UDim2.new(0.4, 0, 0, 0)
                if configPath[1] == "AntiAim" and configPath[2] == "Mode" then
                    if Config.AntiAim.Enabled then
                        DisableAntiAim()
                        EnableAntiAim()
                    end
                end
            end)
        end
        optionFrame.Size = UDim2.new(0.4, 0, 0, #options * 22)
    end
    updateOptions()
    
    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionFrame.Visible = expanded
        if expanded then
            optionFrame.Size = UDim2.new(0.4, 0, 0, #options * 22)
        else
            optionFrame.Size = UDim2.new(0.4, 0, 0, 0)
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 37 + 10)
end

local CombatTab = SectionContents["Combat"]
CreateToggle(CombatTab, "AimBot", {"AimBot", "Enabled"})
CreateSlider(CombatTab, "FOV", {"AimBot", "FOV"}, 1, 180, false)
CreateSlider(CombatTab, "Smooth", {"AimBot", "Smooth"}, 0, 1, true)
CreateSlider(CombatTab, "Range", {"AimBot", "Range"}, 1, 50, false)
CreateToggle(CombatTab, "Silent Aim", {"Silent", "Enabled"})
CreateSlider(CombatTab, "Silent FOV", {"Silent", "FOV"}, 1, 180, false)
CreateSlider(CombatTab, "Silent Range", {"Silent", "Range"}, 1, 50, false)
CreateToggle(CombatTab, "TriggerBot", {"Trigger", "Enabled"})
CreateSlider(CombatTab, "Trigger FOV", {"Trigger", "FOV"}, 1, 180, false)
CreateSlider(CombatTab, "Trigger Range", {"Trigger", "Range"}, 1, 50, false)
CreateSlider(CombatTab, "Trigger Delay", {"Trigger", "Delay"}, 10, 500, false)

local VisualsTab = SectionContents["Visuals"]
CreateToggle(VisualsTab, "ESP", {"ESP", "Enabled"})
CreateToggle(VisualsTab, "ESP Box", {"ESP", "Box"})
CreateToggle(VisualsTab, "ESP Name", {"ESP", "Name"})
CreateToggle(VisualsTab, "ESP Health", {"ESP", "Health"})
CreateToggle(VisualsTab, "ESP Distance", {"ESP", "Distance"})
CreateToggle(VisualsTab, "Chams", {"Chams", "Enabled"})
CreateSlider(VisualsTab, "Chams Transparency", {"Chams", "Transparency"}, 0, 1, true)

local MovementTab = SectionContents["Movement"]
CreateToggle(MovementTab, "Bunny Hop", {"BunnyHop", "Enabled"})
CreateToggle(MovementTab, "Speed", {"Speed", "Enabled"})
CreateSlider(MovementTab, "Speed Value", {"Speed", "Speed"}, 10, 200, false)
CreateToggle(MovementTab, "Fly", {"Fly", "Enabled"})
CreateSlider(MovementTab, "Fly Speed", {"Fly", "Speed"}, 10, 200, false)

local MiscTab = SectionContents["Misc"]
CreateToggle(MiscTab, "Anti-Aim", {"AntiAim", "Enabled"})
CreateDropdown(MiscTab, "Mode", {"AntiAim", "Mode"}, {"Jitter", "Spin", "Backwards"})
CreateToggle(MiscTab, "Watermark", {"Watermark", "Enabled"})

for name, btn in pairs(SectionButtons) do
    btn.MouseButton1Click:Connect(function()
        for _, content in pairs(SectionContents) do
            content.Visible = false
        end
        SectionContents[name].Visible = true
        SelectedSection = name
        for _, b in pairs(SectionButtons) do
            b.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            b.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        btn.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    end)
end

SectionButtons["Combat"].BackgroundColor3 = Color3.fromRGB(20, 0, 0)
SectionButtons["Combat"].TextColor3 = Color3.fromRGB(255, 0, 0)

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
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = char
    table.insert(ESPObjects, espFolder)
    
    if Config.ESP.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 5, 3)
        box.Adornee = root
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Parent = espFolder
        table.insert(ESPObjects, box)
    end
    
    if Config.ESP.Name then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 100, 0, 20)
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
        healthTag.Size = UDim2.new(0, 100, 0, 20)
        healthTag.Position = UDim2.new(0, 0, 0, 20)
        healthTag.Adornee = root
        healthTag.AlwaysOnTop = true
        healthTag.Parent = espFolder
        
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 1, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        healthLabel.TextScaled = true
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.Parent = healthTag
        table.insert(ESPObjects, healthTag)
    end
    
    if Config.ESP.Distance then
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0, 80, 0, 20)
        distTag.Position = UDim2.new(0, 0, 0, 40)
        distTag.Adornee = root
        distTag.AlwaysOnTop = true
        distTag.Parent = espFolder
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        distLabel.Text = math.floor(dist) .. "m"
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.TextScaled = true
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = distTag
        table.insert(ESPObjects, distTag)
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
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = Config.Chams.Transparency
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
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

function EnableSpeed()
    SpeedActive = true
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.Speed.Speed
        end
    end
end

function DisableSpeed()
    SpeedActive = false
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
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
        circleDragOffset = Vector2.new(
            input.Position.X - CircleButton.AbsolutePosition.X,
            input.Position.Y - CircleButton.AbsolutePosition.Y
        )
    end
end)

CircleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        circleDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if circleDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
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
end)

CircleButton.TouchTap:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
end)

local titleDragging = false
local titleDragOffset = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        titleDragging = true
        titleDragOffset = Vector2.new(
            input.Position.X - MainFrame.AbsolutePosition.X,
            input.Position.Y - MainFrame.AbsolutePosition.Y
        )
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        titleDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if titleDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
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

CloseBtn.TouchTap:Connect(function()
    MenuOpen = false
    MainFrame.Visible = false
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
            local part = player.Character:FindFirstChild("Head")
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

RunService.RenderStepped:Connect(function()
    if Config.AimBot.Enabled and not MenuOpen then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local pos = Camera:WorldToViewportPoint(head.Position)
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
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10 * math.sin(tick() * 10)), 0)
            elseif Config.AntiAim.Mode == "Spin" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(tick() * 360), 0)
            elseif Config.AntiAim.Mode == "Backwards" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
            end
        end
    end
    
    if Config.Watermark.Enabled then
        local frameTime = tick() - LastFrameTime
        LastFrameTime = tick()
        CurrentFPS = math.floor(1 / frameTime)
    end
end)

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 200, 0, 25)
Watermark.Position = UDim2.new(0.5, -100, 0, 10)
Watermark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Watermark.BackgroundTransparency = 0.3
Watermark.TextColor3 = Color3.fromRGB(255, 0, 0)
Watermark.TextScaled = true
Watermark.Font = Enum.Font.GothamBold
Watermark.Text = "Hiruku | FPS: 0"
Watermark.Parent = ScreenGui

local watermarkCorner = Instance.new("UICorner")
watermarkCorner.CornerRadius = UDim.new(1, 0)
watermarkCorner.Parent = Watermark

RunService.Heartbeat:Connect(function()
    if Config.Watermark.Enabled then
        Watermark.Visible = true
        Watermark.Text = "Hiruku | FPS: " .. CurrentFPS .. " | Players: " .. #Players:GetPlayers()
    else
        Watermark.Visible = false
    end
end)

print("Hiruku Internal Loaded! Press H to open menu")