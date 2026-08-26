local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    AimBot = {
        Enabled = true,
        FOV = 35,
        Smooth = 0.45,
        VisibleCheck = false,
        Range = 15,
        OnKey = ""
    },
    Silent = {
        Enabled = true,
        Range = 15.0,
        FOV = 35,
        Smooth = 0.45,
        VisibleCheck = false,
        OnKey = ""
    },
    Trigger = {
        Enabled = false,
        Range = 20.0,
        FOV = 10,
        Delay = 50,
        VisibleCheck = false,
        OnKey = ""
    },
    Chams = {
        Enabled = false,
        Mode = "Always",
        VisibleColor = Color3.fromRGB(0, 255, 0),
        HiddenColor = Color3.fromRGB(255, 0, 0),
        GlowIntensity = 0.5,
        Transparency = 0.3
    },
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Skeleton = false
    },
    AntiAim = {
        Enabled = false,
        Mode = "Jitter",
        Angle = 90
    },
    BunnyHop = {
        Enabled = false,
        HoldKey = "Spacebar"
    }
}

local MenuOpen = false
local SelectedTab = "Combat"
local ESPObjects = {}
local ChamsObjects = {}
local ESPActive = false
local ChamsActive = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 55, 0, 55)
CircleButton.Position = UDim2.new(0.02, 0, 0.5, -27.5)
CircleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
CircleButton.BackgroundTransparency = 0
CircleButton.BorderSizePixel = 0
CircleButton.Image = "rbxassetid://0"
CircleButton.AutoButtonColor = false
CircleButton.Parent = ScreenGui

local function MakeCircular(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
end
MakeCircular(CircleButton)

local CircleInner = Instance.new("ImageLabel")
CircleInner.Size = UDim2.new(1, -8, 1, -8)
CircleInner.Position = UDim2.new(0, 4, 0, 4)
CircleInner.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
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
HirukuText.TextColor3 = Color3.fromRGB(150, 200, 255)
HirukuText.TextScaled = true
HirukuText.Font = Enum.Font.GothamBold
HirukuText.Parent = CircleButton

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(30, 30, 45)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 10)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hiruku Internal"
TitleText.TextColor3 = Color3.fromRGB(150, 200, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabNames = {"Combat", "Visuals", "Misc", "Settings"}
local TabButtons = {}
local TabContents = {}

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 180)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    
    TabButtons[name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -75)
    content.Position = UDim2.new(0, 0, 0, 75)
    content.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = MainFrame
    TabContents[name] = content
end

local function CreateSlider(parent, title, configPath, min, max, decimal)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 35)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 38)
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
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.12, 0, 1, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.TextColor3 = Color3.fromRGB(150, 200, 255)
    val.TextScaled = true
    val.Font = Enum.Font.GothamBold
    val.Parent = holder
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.33, 0, 0.4, 0)
    slider.Position = UDim2.new(0.65, 0, 0.3, 0)
    slider.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    slider.BorderSizePixel = 0
    slider.Parent = holder
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
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
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 38 + 20)
end

local function CreateToggle(parent, title, configPath)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 35)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 38)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = holder
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 35, 0, 20)
    toggle.Position = UDim2.new(0.82, 0, 0.2, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    toggle.BorderSizePixel = 0
    toggle.Parent = holder
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0, 16, 0, 16)
    check.Position = UDim2.new(0, 2, 0, 2)
    check.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
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
            check.Position = UDim2.new(0, 17, 0, 2)
            toggle.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        else
            check.Position = UDim2.new(0, 2, 0, 2)
            toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
                if Config.ESP.Enabled then
                    EnableESP()
                else
                    DisableESP()
                end
            end
            if configPath[1] == "Chams" and configPath[2] == "Enabled" then
                if Config.Chams.Enabled then
                    EnableChams()
                else
                    DisableChams()
                end
            end
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 38 + 20)
end

local function CreateDropdown(parent, title, configPath, options)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 35)
    holder.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 38)
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
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.4, 0, 0.7, 0)
    dropdown.Position = UDim2.new(0.6, 0, 0.15, 0)
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
    optionFrame.Size = UDim2.new(0.4, 0, 0, 0)
    optionFrame.Position = UDim2.new(0.6, 0, 0.85, 0)
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
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Position = UDim2.new(0, 0, 0, (i-1) * 25)
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
                optionFrame.Size = UDim2.new(0.4, 0, 0, 0)
                if configPath[1] == "Chams" and configPath[2] == "Mode" and Config.Chams.Enabled then
                    DisableChams()
                    EnableChams()
                end
            end)
        end
        optionFrame.Size = UDim2.new(0.4, 0, 0, #options * 25)
    end
    updateOptions()
    
    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionFrame.Visible = expanded
        if expanded then
            optionFrame.Size = UDim2.new(0.4, 0, 0, #options * 25)
        else
            optionFrame.Size = UDim2.new(0.4, 0, 0, 0)
        end
    end)
    
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 38 + 20)
end

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
        box.Color3 = Color3.fromRGB(100, 150, 255)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.ZIndex = 0
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
        distTag.Size = UDim2.new(0, 100, 0, 20)
        distTag.Position = UDim2.new(0, 0, 0, 40)
        distTag.Adornee = root
        distTag.AlwaysOnTop = true
        distTag.Parent = espFolder
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        distLabel.Text = math.floor(dist) .. " studs"
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
            highlight.FillColor = Config.Chams.VisibleColor
            highlight.FillTransparency = Config.Chams.Transparency
            highlight.OutlineColor = Config.Chams.HiddenColor
            highlight.OutlineTransparency = 0.5
            highlight.Parent = part
            table.insert(ChamsObjects, highlight)
        end
    end
end

local CombatTab = TabContents["Combat"]
CreateToggle(CombatTab, "AimBot", {"AimBot", "Enabled"})
CreateSlider(CombatTab, "Aim FOV", {"AimBot", "FOV"}, 1, 180, false)
CreateSlider(CombatTab, "Aim Smooth", {"AimBot", "Smooth"}, 0, 1, true)
CreateToggle(CombatTab, "Visible Check", {"AimBot", "VisibleCheck"})
CreateSlider(CombatTab, "Range", {"AimBot", "Range"}, 1, 50, false)
CreateToggle(CombatTab, "Silent Aim", {"Silent", "Enabled"})
CreateSlider(CombatTab, "Silent Range", {"Silent", "Range"}, 1, 50, false)
CreateSlider(CombatTab, "Silent FOV", {"Silent", "FOV"}, 1, 180, false)
CreateSlider(CombatTab, "Silent Smooth", {"Silent", "Smooth"}, 0, 1, true)
CreateToggle(CombatTab, "TriggerBot", {"Trigger", "Enabled"})
CreateSlider(CombatTab, "Trigger Range", {"Trigger", "Range"}, 1, 50, false)
CreateSlider(CombatTab, "Trigger FOV", {"Trigger", "FOV"}, 1, 180, false)
CreateSlider(CombatTab, "Trigger Delay", {"Trigger", "Delay"}, 10, 500, false)
CreateToggle(CombatTab, "Trigger Visible", {"Trigger", "VisibleCheck"})

local VisualsTab = TabContents["Visuals"]
CreateToggle(VisualsTab, "ESP", {"ESP", "Enabled"})
CreateToggle(VisualsTab, "ESP Box", {"ESP", "Box"})
CreateToggle(VisualsTab, "ESP Name", {"ESP", "Name"})
CreateToggle(VisualsTab, "ESP Health", {"ESP", "Health"})
CreateToggle(VisualsTab, "ESP Distance", {"ESP", "Distance"})
CreateToggle(VisualsTab, "ESP Skeleton", {"ESP", "Skeleton"})
CreateToggle(VisualsTab, "Chams", {"Chams", "Enabled"})
CreateDropdown(VisualsTab, "Chams Mode", {"Chams", "Mode"}, {"Always", "Visible", "Glow", "Wireframe"})
CreateSlider(VisualsTab, "Chams Transparency", {"Chams", "Transparency"}, 0, 1, true)

local MiscTab = TabContents["Misc"]
CreateToggle(MiscTab, "Anti-Aim", {"AntiAim", "Enabled"})
CreateDropdown(MiscTab, "Anti-Aim Mode", {"AntiAim", "Mode"}, {"Jitter", "Spin", "Fake"})
CreateSlider(MiscTab, "Anti-Aim Angle", {"AntiAim", "Angle"}, 0, 180, false)
CreateToggle(MiscTab, "Bunny Hop", {"BunnyHop", "Enabled"})

local SettingsTab = TabContents["Settings"]

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
        btn.TextColor3 = Color3.fromRGB(150, 200, 255)
    end)
end

TabButtons["Combat"].BackgroundColor3 = Color3.fromRGB(30, 30, 50)
TabButtons["Combat"].TextColor3 = Color3.fromRGB(150, 200, 255)

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
        MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
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
        if ESPActive then
            CreateESPForPlayer(player)
        end
        if ChamsActive then
            CreateChamsForPlayer(player)
        end
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
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 999)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        if not Config.AimBot.VisibleCheck or not hit or hit:IsDescendantOf(player.Character) then
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
end)