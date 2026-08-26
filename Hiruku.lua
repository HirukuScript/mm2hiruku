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
        Enabled = true,
        Mode = "Always",
        VisibleColor = Color3.fromRGB(0, 255, 0),
        HiddenColor = Color3.fromRGB(255, 0, 0),
        GlowIntensity = 0.5,
        Transparency = 0.3
    },
    ESP = {
        Enabled = true,
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
local Dragging = false
local DragStart = nil
local DragOffset = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HirukuInternal"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 60, 0, 60)
CircleButton.Position = UDim2.new(0.5, -30, 0.5, -30)
CircleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CircleButton.BackgroundTransparency = 0
CircleButton.BorderSizePixel = 0
CircleButton.Image = "rbxassetid://0"
CircleButton.AutoButtonColor = false
CircleButton.Parent = ScreenGui

local CircleBorder = Instance.new("ImageLabel")
CircleBorder.Size = UDim2.new(1, -4, 1, -4)
CircleBorder.Position = UDim2.new(0, 2, 0, 2)
CircleBorder.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
CircleBorder.BackgroundTransparency = 0
CircleBorder.BorderSizePixel = 0
CircleBorder.Image = "rbxassetid://0"
CircleBorder.Parent = CircleButton

local CircleInner = Instance.new("ImageLabel")
CircleInner.Size = UDim2.new(1, -8, 1, -8)
CircleInner.Position = UDim2.new(0, 4, 0, 4)
CircleInner.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CircleInner.BackgroundTransparency = 0
CircleInner.BorderSizePixel = 0
CircleInner.Image = "rbxassetid://0"
CircleInner.Parent = CircleButton

local CircleGlow = Instance.new("ImageLabel")
CircleGlow.Size = UDim2.new(1.2, 0, 1.2, 0)
CircleGlow.Position = UDim2.new(-0.1, 0, -0.1, 0)
CircleGlow.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
CircleGlow.BackgroundTransparency = 0.8
CircleGlow.BorderSizePixel = 0
CircleGlow.Image = "rbxassetid://0"
CircleGlow.Parent = CircleButton

local HirukuText = Instance.new("TextLabel")
HirukuText.Size = UDim2.new(1, 0, 1, 0)
HirukuText.Position = UDim2.new(0, 0, 0, 0)
HirukuText.BackgroundTransparency = 1
HirukuText.Text = "H"
HirukuText.TextColor3 = Color3.fromRGB(255, 255, 255)
HirukuText.TextScaled = true
HirukuText.Font = Enum.Font.GothamBold
HirukuText.Parent = CircleButton

local function MakeCircular(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
end

MakeCircular(CircleButton)
MakeCircular(CircleBorder)
MakeCircular(CircleInner)
MakeCircular(CircleGlow)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 50)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hiruku Internal v1.0"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 220)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

local TabButtons = {}
local TabNames = {"Combat", "Visuals", "Misc", "Settings"}
local TabContents = {}

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0, 30)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 180)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 0)
    btnCorner.Parent = btn
    
    TabButtons[name] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -65)
    content.Position = UDim2.new(0, 0, 0, 65)
    content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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
    val.TextColor3 = Color3.fromRGB(80, 150, 255)
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
    fill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
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
    check.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
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
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            b.TextColor3 = Color3.fromRGB(150, 150, 180)
        end
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.TextColor3 = Color3.fromRGB(80, 150, 255)
    end)
end

TabButtons["Combat"].BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TabButtons["Combat"].TextColor3 = Color3.fromRGB(80, 150, 255)

local circleDragging = false
local circleDragStart = nil
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
        circleDragStart = nil
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
        MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
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
        MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
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

local function GetClosestPlayer(customFOV)
    local closest = nil
    local closestAngle = math.huge
    local center = Camera.ViewportSize / 2
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local angle = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if angle < customFOV * 1.5 and angle < closestAngle then
                    local dist = (Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < Config.AimBot.Range then
                        closest = player
                        closestAngle = angle
                    end
                end
            end
        end
    end
    return closest
end

local function IsVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
    local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then
        local dist1 = (pos - Camera.CFrame.Position).Magnitude
        local dist2 = (part.Position - Camera.CFrame.Position).Magnitude
        return dist1 >= dist2 - 2
    end
    return true
end

local function GetHead(character)
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

RunService.RenderStepped:Connect(function()
    if Config.AimBot.Enabled and not MenuOpen then
        local target = GetClosestPlayer(Config.AimBot.FOV)
        if target and target.Character then
            local head = GetHead(target.Character)
            if head and (not Config.AimBot.VisibleCheck or IsVisible(head)) then
                local lookAt = head.Position
                local newCFrame = CFrame.new(Camera.CFrame.Position, lookAt)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.AimBot.Smooth)
            end
        end
    end
    
    if Config.Silent.Enabled and not MenuOpen then
        local target = GetClosestPlayer(Config.Silent.FOV)
        if target and target.Character then
            local head = GetHead(target.Character)
            if head and (not Config.Silent.VisibleCheck or IsVisible(head)) then
                local direction = (head.Position - Camera.CFrame.Position).Unit
                local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.Silent.Smooth)
            end
        end
    end
    
    if Config.Trigger.Enabled and not MenuOpen then
        local target = GetClosestPlayer(Config.Trigger.FOV)
        if target and target.Character then
            local head = GetHead(target.Character)
            if head and (not Config.Trigger.VisibleCheck or IsVisible(head)) then
                if (Camera.CFrame.Position - head.Position).Magnitude < Config.Trigger.Range then
                    task.wait(Config.Trigger.Delay / 1000)
                    mouse1click()
                end
            end
        end
    end
    
    if Config.AntiAim.Enabled then
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Config.AntiAim.Mode == "Jitter" then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.AntiAim.Angle * math.sin(tick() * 10)), 0)
                elseif Config.AntiAim.Mode == "Spin" then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(tick() * 100), 0)
                elseif Config.AntiAim.Mode == "Fake" then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.AntiAim.Angle), 0)
                end
            end
        end
    end
    
    if Config.BunnyHop.Enabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Landed then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    humanoid.Jump = true
                end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and Config.ESP.Enabled then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            if hrp and head then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local scale = 100 / distance
                    local size = Vector2.new(2 * scale, 3 * scale)
                    
                    if Config.ESP.Box then
                        local box = Instance.new("Frame")
                        box.Size = UDim2.new(0, size.X, 0, size.Y)
                        box.Position = UDim2.new(0, pos.X - size.X/2, 0, pos.Y - size.Y/2)
                        box.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        box.BackgroundTransparency = 0.5
                        box.BorderSizePixel = 1
                        box.BorderColor3 = Color3.fromRGB(0, 255, 0)
                        box.Parent = ScreenGui
                        game:GetService("Debris"):AddItem(box, 0.05)
                    end
                    
                    if Config.ESP.Name then
                        local name = Instance.new("TextLabel")
                        name.Size = UDim2.new(0, 100, 0, 20)
                        name.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - size.Y/2 - 20)
                        name.BackgroundTransparency = 1
                        name.Text = player.Name
                        name.TextColor3 = Color3.fromRGB(255, 255, 255)
                        name.TextScaled = true
                        name.Font = Enum.Font.Gotham
                        name.Parent = ScreenGui
                        game:GetService("Debris"):AddItem(name, 0.05)
                    end
                    
                    if Config.ESP.Health then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local health = Instance.new("TextLabel")
                            health.Size = UDim2.new(0, 50, 0, 20)
                            health.Position = UDim2.new(0, pos.X + size.X/2 + 10, 0, pos.Y - size.Y/2)
                            health.BackgroundTransparency = 1
                            health.Text = tostring(math.round(humanoid.Health)) .. " HP"
                            health.TextColor3 = Color3.fromRGB(255, 0, 0)
                            health.TextScaled = true
                            health.Font = Enum.Font.Gotham
                            health.Parent = ScreenGui
                            game:GetService("Debris"):AddItem(health, 0.05)
                        end
                    end
                    
                    if Config.ESP.Distance then
                        local dist = Instance.new("TextLabel")
                        dist.Size = UDim2.new(0, 50, 0, 20)
                        dist.Position = UDim2.new(0, pos.X - 25, 0, pos.Y + size.Y/2)
                        dist.BackgroundTransparency = 1
                        dist.Text = tostring(math.round(distance)) .. "m"
                        dist.TextColor3 = Color3.fromRGB(200, 200, 200)
                        dist.TextScaled = true
                        dist.Font = Enum.Font.Gotham
                        dist.Parent = ScreenGui
                        game:GetService("Debris"):AddItem(dist, 0.05)
                    end
                    
                    if Config.ESP.Skeleton then
                        local joints = {
                            {"Head", "UpperTorso"},
                            {"UpperTorso", "LowerTorso"},
                            {"LeftUpperArm", "LeftLowerArm"},
                            {"RightUpperArm", "RightLowerArm"},
                            {"LeftUpperLeg", "LeftLowerLeg"},
                            {"RightUpperLeg", "RightLowerLeg"}
                        }
                        for _, joint in pairs(joints) do
                            local part1 = character:FindFirstChild(joint[1])
                            local part2 = character:FindFirstChild(joint[2])
                            if part1 and part2 then
                                local p1, _ = Camera:WorldToViewportPoint(part1.Position)
                                local p2, _ = Camera:WorldToViewportPoint(part2.Position)
                                local line = Instance.new("Frame")
                                line.Size = UDim2.new(0, (Vector2.new(p1.X, p1.Y) - Vector2.new(p2.X, p2.Y)).Magnitude, 0, 2)
                                line.Position = UDim2.new(0, (p1.X + p2.X)/2 - line.Size.X.Offset/2, 0, (p1.Y + p2.Y)/2 - 1)
                                line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                line.BackgroundTransparency = 0.3
                                line.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
                                line.Parent = ScreenGui
                                game:GetService("Debris"):AddItem(line, 0.05)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function SetupChams()
    if not Config.Chams.Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part:FindFirstChild("ChamHandle") then
                    local cham = Instance.new("BoxHandleAdornment")
                    cham.Name = "ChamHandle"
                    cham.Size = part.Size
                    cham.CFrame = part.CFrame
                    if Config.Chams.Mode == "Glow" then
                        cham.Color3 = Config.Chams.VisibleColor
                        cham.Transparency = Config.Chams.Transparency
                    elseif Config.Chams.Mode == "Wireframe" then
                        cham.Color3 = Config.Chams.VisibleColor
                        cham.Transparency = 0.9
                    else
                        cham.Color3 = Config.Chams.VisibleColor
                        cham.Transparency = Config.Chams.Transparency
                    end
                    cham.ZIndex = 10
                    cham.AlwaysOnTop = (Config.Chams.Mode == "Always")
                    cham.Parent = part
                    game:GetService("Debris"):AddItem(cham, 0.1)
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    SetupChams()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    SetupChams()
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        SetupChams()
    end
end)

local function Inject()
    print("Hiruku Internal v1.0 injected successfully")
    print("Click the black circle to open menu")
end

Inject()