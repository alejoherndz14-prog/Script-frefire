local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ConfigFileName = "MatzzHub_MM2_Config.json"
local CustomSoundId = "rbxassetid://4499400560"

local DefaultConfig = {
    SilentAim = false,
    GunSilentAim = false,
    KnifeSilentAim = false,
    LeadShot = false,
    WallCheck = false,
    
    HitboxExpand = false,
    HitboxSize = 4,
    HitboxVisible = false,
    
    KnifeHoming = false,     
    KnifeTriggerDist = 25,
    KnifeAura = false,
    KnifeAuraDist = 15,
    KnifeLegitMode = false,
    
    NotifyRoles = false,
    NotifyGunPickup = false,
    NotifyGunDrop = false,
    
    WalkSpeedEnabled = false,
    WalkSpeedValue = 24,
    JumpPowerEnabled = false,
    JumpPowerValue = 80,
    
    AntiFling = false,
    SecondLife = false,
    
    AutoGrabGun = false,
    ShowGrabBtn = false,
    GrabDistance = 15,

    ShowInvisBtn = false,
    
    DesyncEnabled = false,
    ShowDesyncBtn = false,
    
    AntiSilentAim = false,
    AntiSilentAimKey = "X",
    
    Murder_Fill = false, Murder_Outline = false, Murder_Tracer = false, Murder_Name = false, Murder_Dist = false,
    Sheriff_Fill = false, Sheriff_Outline = false, Sheriff_Tracer = false, Sheriff_Name = false, Sheriff_Dist = false,
    Hero_Fill = false, Hero_Outline = false, Hero_Tracer = false, Hero_Name = false, Hero_Dist = false,
    Innocent_Fill = false, Innocent_Outline = false, Innocent_Tracer = false, Innocent_Name = false, Innocent_Dist = false,
    Lobby_Fill = false, Lobby_Outline = false, Lobby_Tracer = false, Lobby_Name = false, Lobby_Dist = false,
    Gun_Fill = false, Gun_Outline = false, Gun_Name = false, Gun_Dist = false, Gun_Tracer = false,
    
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    
    InstantRole = false,
    AntiLag = false,
    DisableFootstep = false,
    ShowRoundTimer = false,
    
    FlingSheriff = false,
    FlingMurderer = false,
    FlingHero = false,
    FlingAll = false,
    
    CoinsReach = false,
    AutoFarmCoins = false,
    
    CoinsRemove = false,
    OptimizerCoins = false,
    
    CustomTheme = "Original",
    
    GamepadEnabled = false,
    SilentAimKey = "ButtonR2",
    InvisibleKey = "ButtonY",
    GrabGunKey = "ButtonB",
    
    AutoPrankBomb = false,
    
    GuiPositions = {}
}

local function DeepCopy(orig)
    local copy = {}
    if type(orig) == 'table' then
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

local Config = DeepCopy(DefaultConfig)

local Themes = {
    Original = {
        Background = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(0, 170, 255),
        AccentDark = Color3.fromRGB(0, 80, 150),
        Ghost = Color3.fromRGB(140, 50, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(30, 30, 35),
        InputBG = Color3.fromRGB(10, 10, 15)
    },
    Red = {
        Background = Color3.fromRGB(20, 15, 15),
        Sidebar = Color3.fromRGB(25, 20, 20),
        Accent = Color3.fromRGB(255, 0, 0),
        AccentDark = Color3.fromRGB(150, 0, 0),
        Ghost = Color3.fromRGB(255, 50, 140),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(35, 30, 30),
        InputBG = Color3.fromRGB(15, 10, 10)
    },
    Blue = {
        Background = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(0, 100, 255),
        AccentDark = Color3.fromRGB(0, 50, 150),
        Ghost = Color3.fromRGB(50, 140, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(30, 30, 35),
        InputBG = Color3.fromRGB(10, 10, 15)
    },
    Verde = {
        Background = Color3.fromRGB(15, 20, 15),
        Sidebar = Color3.fromRGB(20, 25, 20),
        Accent = Color3.fromRGB(0, 255, 0),
        AccentDark = Color3.fromRGB(0, 150, 0),
        Ghost = Color3.fromRGB(140, 255, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(30, 35, 30),
        InputBG = Color3.fromRGB(10, 15, 10)
    },
    Purple = {
        Background = Color3.fromRGB(20, 15, 20),
        Sidebar = Color3.fromRGB(25, 20, 25),
        Accent = Color3.fromRGB(170, 0, 255),
        AccentDark = Color3.fromRGB(80, 0, 150),
        Ghost = Color3.fromRGB(200, 50, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(35, 30, 35),
        InputBG = Color3.fromRGB(15, 10, 15)
    },
    Yellow = {
        Background = Color3.fromRGB(20, 20, 15),
        Sidebar = Color3.fromRGB(25, 25, 20),
        Accent = Color3.fromRGB(255, 255, 0),
        AccentDark = Color3.fromRGB(150, 150, 0),
        Ghost = Color3.fromRGB(255, 255, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(35, 35, 30),
        InputBG = Color3.fromRGB(15, 15, 10)
    },
    Branco = {
        Background = Color3.fromRGB(240, 240, 240),
        Sidebar = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 120, 255),
        AccentDark = Color3.fromRGB(0, 80, 200),
        Ghost = Color3.fromRGB(100, 100, 100),
        Text = Color3.fromRGB(0, 0, 0),
        TextDim = Color3.fromRGB(80, 80, 80),
        ItemBG = Color3.fromRGB(200, 200, 200),
        InputBG = Color3.fromRGB(180, 180, 180)
    },
    Preto = {
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(255, 255, 255),
        AccentDark = Color3.fromRGB(150, 150, 150),
        Ghost = Color3.fromRGB(100, 100, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        ItemBG = Color3.fromRGB(30, 30, 30),
        InputBG = Color3.fromRGB(20, 20, 20)
    }
}

local function LoadConfigDataOnly()
    if isfile and isfile(ConfigFileName) then
        local content = readfile(ConfigFileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        if success and decoded then 
            for key, value in pairs(decoded) do 
                if key ~= "GuiPositions" then
                    if Config[key] ~= nil then 
                        Config[key] = value 
                    end
                else
                    Config.GuiPositions = value or {}
                end
            end
        end
    end
end

LoadConfigDataOnly()

local RoleColors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 0, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
    Lobby = Color3.fromRGB(150, 150, 150),
    Gun = Color3.fromRGB(255, 255, 255)
}

local Theme
if Config.CustomTheme and Themes[Config.CustomTheme] then
    Theme = Themes[Config.CustomTheme]
else
    Config.CustomTheme = "Original"
    Theme = Themes.Original
end

local foundGunDrop = nil
local RoleCache = {} 
local tabs = {} 
local lastMyRole = "FORCE_RESET" 
local rolesNotified = false
local playerDataRemote = nil
local ShootGui, GrabFrame, InvisFrame, DesyncFrame, ToggleButton, MainFrame, ShootButton
local InvisActive = false
local FirstRow, SecondRow, ThirdRow

local desync_on = false
local ghostPart = nil
local desyncChair = nil
local desyncWeld = nil

local flingActive = false
local flingAllActive = false
local flingTargetPlayer = nil
local flingThread = nil
local flingInProgress = false

local closesthitpart = nil
local closestKnifePart = nil
local knifeEquipped = false
local murder = nil
local originalKnifeThrown = nil

local coinOrig = {}
local coinReachConn = nil
local autoFarmCoinsRunning = false
local autoFarmCoinsThread = nil

local coinsRemoveConn = nil
local optimizerCoinsConn = nil

local footstepConnection = nil
local roundTimerGui = nil
local roundTimerConnection = nil

local gamepadConnections = {}
local gamepadActive = false
local keyCodes = {
    ButtonR2 = Enum.KeyCode.ButtonR2,
    ButtonY = Enum.KeyCode.ButtonY,
    ButtonB = Enum.KeyCode.ButtonB,
    ButtonA = Enum.KeyCode.ButtonA,
    ButtonX = Enum.KeyCode.ButtonX,
    ButtonL2 = Enum.KeyCode.ButtonL2,
    ButtonR1 = Enum.KeyCode.ButtonR1,
    ButtonL1 = Enum.KeyCode.ButtonL1,
    DPadUp = Enum.KeyCode.DPadUp,
    DPadDown = Enum.KeyCode.DPadDown,
    DPadLeft = Enum.KeyCode.DPadLeft,
    DPadRight = Enum.KeyCode.DPadRight
}

local isRTPressed = false
local lastRTInputTime = 0
local rtHoldDuration = 0

local secondLifeConnection = nil

local notifyOrder = 0

local gunTracerLine = nil
local desyncTracerLine = nil

local prankBombConnection = nil

local antiSilentAimData = {
    savedCFrame = nil,
    savedVelocity = nil
}

if _G.MatzzHubLoaded then
    if CoreGui:FindFirstChild("MatzzHubMain") then CoreGui.MatzzHubMain:Destroy() end
    if CoreGui:FindFirstChild("ShootGui_Overlay_V19") then CoreGui.ShootGui_Overlay_V19:Destroy() end
    if CoreGui:FindFirstChild("MatzzRoleAlert") then CoreGui.MatzzRoleAlert:Destroy() end
    if CoreGui:FindFirstChild("MatzzTracersGui") then CoreGui.MatzzTracersGui:Destroy() end
    if CoreGui:FindFirstChild("MatzzNotifyContainer") then CoreGui.MatzzNotifyContainer:Destroy() end
    if CoreGui:FindFirstChild("MatzzGrabGunBtn") then CoreGui.MatzzGrabGunBtn:Destroy() end
    if CoreGui:FindFirstChild("MatzzInvisBtn") then CoreGui.MatzzInvisBtn:Destroy() end
    if CoreGui:FindFirstChild("MatzzDesyncBtn") then CoreGui.MatzzDesyncBtn:Destroy() end
    if CoreGui:FindFirstChild("MatzzRoundTimer") then CoreGui.MatzzRoundTimer:Destroy() end
end
_G.MatzzHubLoaded = true

local function AddCorner(instance, radius) 
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner 
end

local function AddStroke(instance, color, thickness) 
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke 
end

local function PlayClickSound()
    task.spawn(function()
        local s = Instance.new("Sound")
        s.Name = "MatzzClickSound"
        s.SoundId = CustomSoundId
        s.Volume = 1
        s.Parent = CoreGui
        s:Play()
        s.Ended:Connect(function()
            s:Destroy()
        end)
    end)
end

local function MakeDraggableCornersOnly(frame)
    local dragging, dragInput, dragStart, startPos
    
    local cornerSize = 20
    
    local function createCornerDetector(position, size)
        local detector = Instance.new("Frame")
        detector.Name = "DragCorner_" .. position
        detector.Size = UDim2.new(0, size, 0, size)
        detector.BackgroundTransparency = 1
        detector.ZIndex = frame.ZIndex + 1
        detector.Parent = frame
        
        if position == "TopLeft" then
            detector.Position = UDim2.new(0, 0, 0, 0)
        elseif position == "TopRight" then
            detector.Position = UDim2.new(1, -size, 0, 0)
        elseif position == "BottomLeft" then
            detector.Position = UDim2.new(0, 0, 1, -size)
        elseif position == "BottomRight" then
            detector.Position = UDim2.new(1, -size, 1, -size)
        end
        
        return detector
    end
    
    local topLeftDetector = createCornerDetector("TopLeft", cornerSize)
    local topRightDetector = createCornerDetector("TopRight", cornerSize)
    local bottomLeftDetector = createCornerDetector("BottomLeft", cornerSize)
    local bottomRightDetector = createCornerDetector("BottomRight", cornerSize)
    
    local function startDragging(input)
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
    
    local detectors = {topLeftDetector, topRightDetector, bottomLeftDetector, bottomRightDetector}
    
    for _, detector in ipairs(detectors) do
        detector.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                PlayClickSound()
                startDragging(input)
            end
        end)
    end
    
    for _, detector in ipairs(detectors) do
        detector.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
    end
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function MakeDraggable(frame, trigger)
    trigger = trigger or frame
    local dragging, dragInput, dragStart, startPos
    trigger.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end 
            end) 
        end 
    end)
    trigger.InputChanged:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end 
    end)
    UserInputService.InputChanged:Connect(function(input) 
        if dragging and input == dragInput then 
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end 
    end)
end

local function ApplyThemeToGUI()
    if MainFrame then
        MainFrame.BackgroundColor3 = Theme.Background
        local mainStroke = MainFrame:FindFirstChildOfClass("UIStroke")
        if mainStroke then
            mainStroke.Color = Theme.Accent
        end
    end
    
    if Sidebar then
        Sidebar.BackgroundColor3 = Theme.Sidebar
    end
    
    if TitleLabel then
        TitleLabel.TextColor3 = Theme.Accent
    end
    
    for _, tab in ipairs(tabs) do
        if tab.Btn then
            tab.Btn.BackgroundColor3 = Theme.Background
            tab.Btn.TextColor3 = Theme.TextDim
            if tab.Frame and tab.Frame.Visible then
                tab.Btn.BackgroundColor3 = Theme.AccentDark
                tab.Btn.TextColor3 = Theme.Text
            end
        end
    end
    
    if ShootButton then
        ShootButton.BackgroundColor3 = Theme.Background
        ShootButton.TextColor3 = Theme.Accent
        local shootStroke = ShootButton:FindFirstChildOfClass("UIStroke")
        if shootStroke then
            shootStroke.Color = Theme.Accent
            local gradient = shootStroke:FindFirstChildOfClass("UIGradient")
            if gradient then
                gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0.00, Theme.Accent),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1.00, Theme.Accent)
                }
            end
        end
    end
    
    if GrabFrame then
        GrabFrame.BackgroundColor3 = Theme.Background
        local grabStroke = GrabFrame:FindFirstChildOfClass("UIStroke")
        if grabStroke then
            grabStroke.Color = Theme.Accent
        end
    end
    
    if GrabBtn then
        GrabBtn.TextColor3 = Theme.Accent
    end
    
    if InvisFrame then
        InvisFrame.BackgroundColor3 = Theme.Background
        local invisStroke = InvisFrame:FindFirstChildOfClass("UIStroke")
        if invisStroke then
            invisStroke.Color = Theme.Ghost
        end
    end
    
    if InvisBtn then
        InvisBtn.TextColor3 = Theme.Ghost
    end
    
    if DesyncFrame then
        DesyncFrame.BackgroundColor3 = Theme.Background
        local desyncStroke = DesyncFrame:FindFirstChildOfClass("UIStroke")
        if desyncStroke then
            if desync_on then
                desyncStroke.Color = Color3.fromRGB(0, 255, 150)
            else
                desyncStroke.Color = Theme.Ghost
            end
        end
    end
    
    if DesyncBtn then
        if desync_on then
            DesyncBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            DesyncBtn.TextColor3 = Theme.Ghost
        end
    end
    
    if NotifyContainer then
        for _, notify in ipairs(NotifyContainer:GetDescendants()) do
            if notify:IsA("TextLabel") and notify.Text == "MATZZ MM2" then
                notify.TextColor3 = Theme.Accent
            elseif notify:IsA("Frame") and notify:FindFirstChildOfClass("UIStroke") then
                notify.BackgroundColor3 = Theme.Sidebar
                local stroke = notify:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = Theme.Accent
                end
            end
        end
    end
    
    if FirstRow then
        for _, child in ipairs(FirstRow:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Theme.ItemBG
                child.TextColor3 = Config.CustomTheme == child.Text and Theme.Accent or Theme.TextDim
            end
        end
    end
    
    if SecondRow then
        for _, child in ipairs(SecondRow:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Theme.ItemBG
                child.TextColor3 = Config.CustomTheme == child.Text and Theme.Accent or Theme.TextDim
            end
        end
    end
    
    if ThirdRow then
        for _, child in ipairs(ThirdRow:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Theme.ItemBG
                child.TextColor3 = Config.CustomTheme == child.Text and Theme.Accent or Theme.TextDim
            end
        end
    end
    
    if ghostPart then
        local ghostColor = Theme.Ghost
        ghostPart.Color = ghostColor
        local highlight = ghostPart:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight.FillColor = ghostColor
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
        local bbGui = ghostPart:FindFirstChildOfClass("BillboardGui")
        if bbGui then
            local txt = bbGui:FindFirstChildOfClass("TextLabel")
            if txt then
                txt.TextColor3 = ghostColor
            end
        end
    end
end

local function SetTheme(themeName)
    if Themes[themeName] then
        Theme = Themes[themeName]
        Config.CustomTheme = themeName
        ApplyThemeToGUI()
        return true
    end
    return false
end

local function ApplySecondLife(state)
    if state then
        local function setupGodmode(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if secondLifeConnection then
                    secondLifeConnection:Disconnect()
                end
                secondLifeConnection = humanoid.HealthChanged:Connect(function()
                    if humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                    end
                end)
            end
        end

        if LocalPlayer.Character then
            setupGodmode(LocalPlayer.Character)
        end

        LocalPlayer.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            setupGodmode(character)
        end)
    else
        if secondLifeConnection then
            secondLifeConnection:Disconnect()
            secondLifeConnection = nil
        end
    end
end

local function ApplyDisableFootstep(state)
    if state then
        local function removeFootsteps()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Footsteps" then
                    obj:Destroy()
                end
            end
        end

        removeFootsteps()

        footstepConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name == "Footsteps" then
                task.wait(0.1)
                if obj and obj.Parent then
                    obj:Destroy()
                end
            end
        end)
    else
        if footstepConnection then
            footstepConnection:Disconnect()
            footstepConnection = nil
        end
    end
end

local function ApplyShowRoundTimer(state)
    if state then
        roundTimerGui = Instance.new("ScreenGui")
        roundTimerGui.Name = "MatzzRoundTimer"
        roundTimerGui.Parent = CoreGui
        roundTimerGui.IgnoreGuiInset = true
        roundTimerGui.ResetOnSpawn = false
        roundTimerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local timerFrame = Instance.new("Frame")
        timerFrame.Size = UDim2.new(0, 150, 0, 40)
        timerFrame.Position = UDim2.new(0.5, -75, 0, 20)
        timerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        timerFrame.BackgroundTransparency = 0.5
        timerFrame.BorderSizePixel = 0
        timerFrame.Parent = roundTimerGui
        AddCorner(timerFrame, 6)
        AddStroke(timerFrame, Theme.Accent, 1)

        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1, 0, 1, 0)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = "00:00"
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBlack
        timerLabel.TextSize = 20
        timerLabel.TextStrokeTransparency = 0.5
        timerLabel.Parent = timerFrame

        local function updateTimer()
            local timerPart = Workspace:FindFirstChild("RoundTimerPart")
            if timerPart and timerPart:FindFirstChild("SurfaceGui") then
                local surfaceGui = timerPart.SurfaceGui
                local timerObj = surfaceGui:FindFirstChild("Timer")
                if timerObj and timerObj:IsA("TextLabel") then
                    timerLabel.Text = timerObj.Text
                else
                    timerLabel.Text = "00:00"
                end
            else
                timerLabel.Text = "00:00"
            end
        end

        updateTimer()
        roundTimerConnection = RunService.Heartbeat:Connect(updateTimer)
    else
        if roundTimerConnection then
            roundTimerConnection:Disconnect()
            roundTimerConnection = nil
        end
        if roundTimerGui then
            roundTimerGui:Destroy()
            roundTimerGui = nil
        end
    end
end

local NotifyContainer = Instance.new("ScreenGui")
NotifyContainer.Name = "MatzzNotifyContainer"
NotifyContainer.Parent = CoreGui
NotifyContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyContainer.IgnoreGuiInset = true

local NotifyList = Instance.new("Frame")
NotifyList.Size = UDim2.new(0, 300, 1, 0)
NotifyList.AnchorPoint = Vector2.new(0, 0)
NotifyList.Position = UDim2.new(0, 20, 0.8, 0)
NotifyList.BackgroundTransparency = 1
NotifyList.Parent = NotifyContainer

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyList
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifyLayout.Padding = UDim.new(0, 8)

local function MatzzNotify(title, text, duration)
    notifyOrder = notifyOrder - 1

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundColor3 = Theme.Sidebar
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.LayoutOrder = notifyOrder
    Frame.Parent = NotifyList
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Frame
    Stroke.Color = Theme.Accent
    Stroke.Thickness = 1.5
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Frame
    TitleLbl.Size = UDim2.new(1, -10, 0, 20)
    TitleLbl.Position = UDim2.new(0, 10, 0, 5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.Font = Enum.Font.GothamBlack
    TitleLbl.TextColor3 = Theme.Accent
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Parent = Frame
    MsgLbl.Size = UDim2.new(1, -10, 0, 30)
    MsgLbl.Position = UDim2.new(0, 10, 0, 25)
    MsgLbl.BackgroundTransparency = 1
    MsgLbl.Text = text
    MsgLbl.Font = Enum.Font.GothamSemibold
    MsgLbl.TextColor3 = Theme.Text
    MsgLbl.TextSize = 12
    MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
    MsgLbl.TextWrapped = true
    
    Frame.BackgroundTransparency = 1
    TitleLbl.TextTransparency = 1
    MsgLbl.TextTransparency = 1
    Stroke.Transparency = 1
    
    TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    
    task.delay(duration or 3, function()
        if Frame then
            TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.3)
            Frame:Destroy()
        end
    end)
end

local function GetLeadShotPosition(targetRootPart)
    local currentPos = targetRootPart.Position
    if Config.LeadShot then 
        local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        currentPos = currentPos + (targetRootPart.Velocity * ping * 1.7) 
    end
    return currentPos
end

local function PerformSilentAimDirectly()
    if not Config.SilentAim then
        return false
    end
    
    local gun = nil
    
    for _, i in ipairs(LocalPlayer.Character:GetChildren()) do
        if i:IsA("Tool") and (string.find(string.lower(i.Name), "gun") or i.Name == "Revolver") then
            gun = i
            break
        end
    end
    
    if not gun then
        for _, i in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if i:IsA("Tool") and (string.find(string.lower(i.Name), "gun") or i.Name == "Revolver") then
                gun = i
                break
            end
        end
    end
    
    if not gun then
        return false
    end
    
    local targetPlr = nil
    for plrName, role in pairs(RoleCache) do
        if role == "Murderer" then
            targetPlr = Players:FindFirstChild(plrName)
            if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
                break
            else
                targetPlr = nil
            end
        end
    end
    
    if not targetPlr or not targetPlr.Character or not targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    if Config.WallCheck then
        local origin = Camera.CFrame.Position
        local targetPosRaw = targetPlr.Character.HumanoidRootPart.Position
        local direction = (targetPosRaw - origin).Unit * (targetPosRaw - origin).Magnitude
        
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPlr.Character, workspace:FindFirstChild("GunDrop")}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        
        if workspace:Raycast(origin, direction, rayParams) then
            return false
        end
    end
    
    local wasInBackpack = (gun.Parent == LocalPlayer.Backpack)
    if wasInBackpack then
        LocalPlayer.Character.Humanoid:EquipTool(gun)
        task.wait(0.1)
    end
    
    local targetRoot = targetPlr.Character.HumanoidRootPart
    local targetPos = GetLeadShotPosition(targetRoot)
    
    local args = {CFrame.new(Camera.CFrame.Position, targetPos), CFrame.new(targetPos)}
    
    if gun:FindFirstChild("Shoot") then
        gun.Shoot:FireServer(unpack(args))
        
        if wasInBackpack and gun.Parent == LocalPlayer.Character then
            gun.Parent = LocalPlayer.Backpack
        end
        return true
    end
    
    return false
end

local function getGunTarget()
    if not Config.GunSilentAim then return nil end
    
    local myRole = RoleCache[LocalPlayer.Name]
    if myRole ~= "Sheriff" and myRole ~= "Hero" then
        return nil
    end
    
    for plrName, role in pairs(RoleCache) do
        if role == "Murderer" then
            local plr = Players:FindFirstChild(plrName)
            if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidrootpart = plr.Character.HumanoidRootPart
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                
                if humanoidrootpart and humanoid and humanoid.Health > 0 then
                    return humanoidrootpart
                end
            end
        end
    end
    
    return nil
end

local function hasKnife(player)
    if not player or not player.Character then return false end
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("knife") or name:find("fac") or name == "knife" or name == "murder knife" then
                return true
            end
        end
    end
    
    for _, item in pairs(player.Character:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("knife") or name:find("fac") or name == "knife" or name == "murder knife" then
                return true
            end
        end
    end
    
    return false
end

local function detectMurder()
    while true do
        task.wait(1)
        
        local foundMurder = nil
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and hasKnife(player) then
                foundMurder = player
                break
            end
        end
        
        murder = foundMurder
    end
end

local function getdirection(origin, position)
    return (position - origin).Unit
end

local function getclosestplayer()
    if not Config.KnifeSilentAim then return nil end
    if not knifeEquipped then return nil end

    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    local closestpart = nil
    local closestdistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player ~= murder and player.Character then
            local humanoidrootpart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if humanoidrootpart and humanoid and humanoid.Health > 0 then
                local screenpos, onscreen = Camera:WorldToViewportPoint(humanoidrootpart.Position)

                if onscreen then
                    local distance = (Vector2.new(screenpos.X, screenpos.Y) - center).Magnitude

                    if distance < closestdistance then
                        closestdistance = distance
                        closestpart = humanoidrootpart
                    end
                end
            end
        end
    end

    return closestpart
end

local function hookKnifeThrown()
    local character = LocalPlayer.Character
    if not character then return end
    
    local knifeTool = character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not knifeTool then return end
    
    local knifeEvents = knifeTool:FindFirstChild("Events")
    if not knifeEvents then return end
    
    local knifeThrownEvent = knifeEvents:FindFirstChild("KnifeThrown")
    if not knifeThrownEvent then return end
    
    if not originalKnifeThrown then
        originalKnifeThrown = knifeThrownEvent.FireServer
    end
    
    knifeThrownEvent.FireServer = function(self, ...)
        local args = {...}
        
        if closestKnifePart and knifeEquipped and Config.KnifeSilentAim then
            local targetPos = closestKnifePart.Position
            local characterPos = character:GetPivot().Position
            
            local direction = (targetPos - characterPos).Unit
            
            local newCFrame = CFrame.new(characterPos, characterPos + direction)
            
            if #args >= 1 then
                args[1] = newCFrame
            end
        end
        
        return originalKnifeThrown(self, unpack(args))
    end
end

local oldnamecall
oldnamecall = hookmetamethod(game, "__namecall", function(...)
    local method = getnamecallmethod()
    local arguments = {...}
    local self = arguments[1]

    if self == workspace and not checkcaller() and method == "Raycast" and Config.GunSilentAim then
        local hitpart = closesthitpart
        
        if hitpart then
            local origin = arguments[2]
            local direction = getdirection(origin, hitpart.Position) * 1000
            arguments[3] = direction
            return oldnamecall(unpack(arguments))
        end
    end
    
    if self == workspace and not checkcaller() and method == "Raycast" and Config.KnifeSilentAim and knifeEquipped then
        local hitpart = closestKnifePart
        
        if hitpart then
            local origin = arguments[2]
            local direction = getdirection(origin, hitpart.Position) * 1000
            arguments[3] = direction
            return oldnamecall(unpack(arguments))
        end
    end

    return oldnamecall(...)
end)

local function PerformGrabGun()
    PlayClickSound()
    
    local gunDrop = Workspace:FindFirstChild("GunDrop") 
    if not gunDrop then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                gunDrop = obj
                break
            end
        end
    end
    
    if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Root = LocalPlayer.Character.HumanoidRootPart
        gunDrop.CanCollide = false
        gunDrop.CFrame = Root.CFrame + Vector3.new(0, 0, -2)
        gunDrop.Velocity = Vector3.new(0,0,0)
        
        if GrabBtn then
            GrabBtn.Text = "SUCCESS"
            GrabBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
            local grabStroke = GrabFrame:FindFirstChildOfClass("UIStroke")
            if grabStroke then
                grabStroke.Color = Color3.fromRGB(0, 255, 100)
            end
            
            task.delay(0.5, function()
                if GrabBtn then
                    GrabBtn.Text = "GRAB GUN"
                    GrabBtn.TextColor3 = Theme.Accent
                    if grabStroke then
                        grabStroke.Color = Theme.Accent
                    end
                end
            end)
        end
        return true
    else
        return false
    end
end

local function GetKeyCodeFromString(keyString)
    return keyCodes[keyString] or Enum.KeyCode[keyString]
end

local function SetupGamepadControls()
    for _, conn in pairs(gamepadConnections) do
        conn:Disconnect()
    end
    gamepadConnections = {}
    
    if Config.GamepadEnabled then
        local silentAimKey = GetKeyCodeFromString(Config.SilentAimKey)
        if silentAimKey then
            local connBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == silentAimKey then
                    isRTPressed = true
                    lastRTInputTime = tick()
                    rtHoldDuration = 0
                    
                    if Config.SilentAim then
                        PerformSilentAimDirectly()
                    end
                end
            end)
            
            local connEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == silentAimKey then
                    isRTPressed = false
                    rtHoldDuration = 0
                end
            end)
            
            table.insert(gamepadConnections, connBegan)
            table.insert(gamepadConnections, connEnded)
        end
        
        local invisibleKey = GetKeyCodeFromString(Config.InvisibleKey)
        if invisibleKey then
            local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == invisibleKey then
                    ToggleInvis()
                end
            end)
            table.insert(gamepadConnections, conn)
        end
        
        local grabGunKey = GetKeyCodeFromString(Config.GrabGunKey)
        if grabGunKey then
            local conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == grabGunKey then
                    PerformGrabGun()
                end
            end)
            table.insert(gamepadConnections, conn)
        end
        
        task.spawn(function()
            while Config.GamepadEnabled do
                if isRTPressed and Config.SilentAim then
                    local currentTime = tick()
                    rtHoldDuration = currentTime - lastRTInputTime
                    
                    if rtHoldDuration > 0.3 then
                        PerformSilentAimDirectly()
                        lastRTInputTime = currentTime
                    end
                end
                task.wait(0.05)
            end
        end)
        
        gamepadActive = true
    else
        gamepadActive = false
        isRTPressed = false
    end
end

local function ApplyCoinsRemove(state)
    if state then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                local coinVisual = obj:FindFirstChild("CoinVisual")
                if coinVisual then
                    coinVisual:Destroy()
                end
                obj:Destroy()
            end
        end
        
        coinsRemoveConn = Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                task.wait(0.1)
                local coinVisual = obj:FindFirstChild("CoinVisual")
                if coinVisual then
                    coinVisual:Destroy()
                end
                obj:Destroy()
            end
        end)
    else
        if coinsRemoveConn then
            coinsRemoveConn:Disconnect()
            coinsRemoveConn = nil
        end
    end
end

local function ApplyOptimizerCoins(state)
    if state then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                if not obj.Parent then continue end
                obj.Material = Enum.Material.Plastic
                obj.Color = Color3.fromRGB(255, 255, 0)
                if obj:FindFirstChildOfClass("ParticleEmitter") then
                    for _, emitter in ipairs(obj:GetChildren()) do
                        if emitter:IsA("ParticleEmitter") then
                            emitter.Enabled = false
                        end
                    end
                end
            end
        end
        
        optimizerCoinsConn = Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                task.wait(0.1)
                if not obj.Parent then return end
                obj.Material = Enum.Material.Plastic
                obj.Color = Color3.fromRGB(255, 255, 0)
                if obj:FindFirstChildOfClass("ParticleEmitter") then
                    for _, emitter in ipairs(obj:GetChildren()) do
                        if emitter:IsA("ParticleEmitter") then
                            emitter.Enabled = false
                        end
                    end
                end
            end
        end)
    else
        if optimizerCoinsConn then
            optimizerCoinsConn:Disconnect()
            optimizerCoinsConn = nil
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                if not obj.Parent then continue end
                obj.Material = Enum.Material.Neon
                obj.Color = Color3.fromRGB(255, 215, 0)
                if obj:FindFirstChildOfClass("ParticleEmitter") then
                    for _, emitter in ipairs(obj:GetChildren()) do
                        if emitter:IsA("ParticleEmitter") then
                            emitter.Enabled = true
                        end
                    end
                end
            end
        end
    end
end

local GrabGunGui = Instance.new("ScreenGui")
GrabGunGui.Name = "MatzzGrabGunBtn"
GrabGunGui.Parent = CoreGui
GrabGunGui.IgnoreGuiInset = true
GrabGunGui.ResetOnSpawn = false

GrabFrame = Instance.new("Frame")
GrabFrame.Parent = GrabGunGui
GrabFrame.Size = UDim2.new(0, 80, 0, 30)
GrabFrame.Position = UDim2.new(0.7, 0, 0.5, 0)
GrabFrame.BackgroundColor3 = Theme.Background
GrabFrame.BackgroundTransparency = 0.5
GrabFrame.Visible = false
GrabFrame.BorderSizePixel = 0
AddCorner(GrabFrame, 6)
local GrabStroke = AddStroke(GrabFrame, Theme.Accent, 1.5)

local GrabBtn = Instance.new("TextButton")
GrabBtn.Parent = GrabFrame
GrabBtn.Size = UDim2.new(1, 0, 1, 0)
GrabBtn.BackgroundTransparency = 1
GrabBtn.Text = "GRAB GUN"
GrabBtn.TextColor3 = Theme.Accent
GrabBtn.Font = Enum.Font.GothamBlack
GrabBtn.TextSize = 11
GrabBtn.AutoButtonColor = true
GrabBtn.Name = "GrabButtonText"

MakeDraggableCornersOnly(GrabFrame)
GrabBtn.MouseButton1Click:Connect(PerformGrabGun)

local InvisGui = Instance.new("ScreenGui")
InvisGui.Name = "MatzzInvisBtn"
InvisGui.Parent = CoreGui
InvisGui.IgnoreGuiInset = true
InvisGui.ResetOnSpawn = false

InvisFrame = Instance.new("Frame")
InvisFrame.Parent = InvisGui
InvisFrame.Size = UDim2.new(0, 80, 0, 30)
InvisFrame.Position = UDim2.new(0.7, 0, 0.6, 0)
InvisFrame.BackgroundColor3 = Theme.Background
InvisFrame.BackgroundTransparency = 0.5
InvisFrame.Visible = false
InvisFrame.BorderSizePixel = 0
AddCorner(InvisFrame, 6)
local InvisStroke = AddStroke(InvisFrame, Theme.Ghost, 1.5)

local InvisBtn = Instance.new("TextButton")
InvisBtn.Parent = InvisFrame
InvisBtn.Size = UDim2.new(1, 0, 1, 0)
InvisBtn.BackgroundTransparency = 1
InvisBtn.Text = "INVISIBLE"
InvisBtn.TextColor3 = Theme.Ghost
InvisBtn.Font = Enum.Font.GothamBlack
InvisBtn.TextSize = 11
InvisBtn.AutoButtonColor = true
MakeDraggableCornersOnly(InvisFrame)

local DesyncGui = Instance.new("ScreenGui")
DesyncGui.Name = "MatzzDesyncBtn"
DesyncGui.Parent = CoreGui
DesyncGui.IgnoreGuiInset = true
DesyncGui.ResetOnSpawn = false

DesyncFrame = Instance.new("Frame")
DesyncFrame.Parent = DesyncGui
DesyncFrame.Size = UDim2.new(0, 80, 0, 30)
DesyncFrame.Position = UDim2.new(0.7, 0, 0.7, 0)
DesyncFrame.BackgroundColor3 = Theme.Background
DesyncFrame.BackgroundTransparency = 0.5
DesyncFrame.Visible = false
DesyncFrame.BorderSizePixel = 0
AddCorner(DesyncFrame, 6)
local DesyncStroke = AddStroke(DesyncFrame, Theme.Ghost, 1.5)

local DesyncBtn = Instance.new("TextButton")
DesyncBtn.Parent = DesyncFrame
DesyncBtn.Size = UDim2.new(1, 0, 1, 0)
DesyncBtn.BackgroundTransparency = 1
DesyncBtn.Text = "DESYNC"
DesyncBtn.TextColor3 = Theme.Ghost
DesyncBtn.Font = Enum.Font.GothamBlack
DesyncBtn.TextSize = 11
DesyncBtn.AutoButtonColor = true
MakeDraggableCornersOnly(DesyncFrame)

local FLING_TIMEOUT = 2.5

local function FlingPlayer(targetPlayer)
    flingInProgress = true
    local myChar = LocalPlayer.Character
    if not myChar then flingInProgress = false return end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not (myHum and myRoot) then flingInProgress = false return end

    local targetChar = targetPlayer.Character
    if not targetChar then flingInProgress = false return end
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetHum and targetHum.RootPart
    local targetHead = targetChar:FindFirstChild("Head")
    local accessory = targetChar:FindFirstChildOfClass("Accessory")
    local handle = accessory and accessory:FindFirstChild("Handle")

    local oldPos = myRoot.CFrame

    repeat
        task.wait()
        workspace.CurrentCamera.CameraSubject = targetHead or handle or targetHum
    until workspace.CurrentCamera.CameraSubject == targetHead or handle or targetHum

    local function forcePosition(basePart, offset, angle)
        local targetCF = CFrame.new(basePart.Position) * offset * angle
        myRoot.CFrame = targetCF
        myChar:SetPrimaryPartCFrame(targetCF)
        myRoot.Velocity = Vector3.new(9e7, 9e8, 9e7)
        myRoot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function flingBasePart(basePart)
        local start = tick()
        local ang = 0
        repeat
            if myRoot and targetHum then
                ang = ang + 100
                for _, off in ipairs{
                    CFrame.new(0, 1.5, 0),
                    CFrame.new(0, -1.5, 0),
                    CFrame.new(2.25, 1.5, -2.25),
                    CFrame.new(-2.25, -1.5, 2.25)
                } do
                    forcePosition(basePart, off + targetHum.MoveDirection, CFrame.Angles(math.rad(ang), 0, 0))
                    task.wait()
                end
            end
        until basePart.Velocity.Magnitude > 500 or tick() - start > FLING_TIMEOUT
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlingVelocity"
    bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = myRoot
    myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local targetPart = targetRoot or targetHead or handle
    if targetPart then
        flingBasePart(targetPart)
    end

    bv:Destroy()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    repeat
        task.wait()
        workspace.CurrentCamera.CameraSubject = myHum
    until workspace.CurrentCamera.CameraSubject == myHum

    repeat
        local cf = oldPos * CFrame.new(0, 0.5, 0)
        myRoot.CFrame = cf
        myChar:SetPrimaryPartCFrame(cf)
        myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        for _, part in ipairs(myChar:GetChildren()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.zero
                part.RotVelocity = Vector3.zero
            end
        end
        task.wait()
    until (myRoot.Position - oldPos.p).Magnitude < 25
    
    flingInProgress = false
end

local function FlingAllLoop()
    flingInProgress = true
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(players, plr)
        end
    end
    if #players == 0 then flingInProgress = false return end

    local index = 1
    while flingAllActive do
        local target = players[index]
        if target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
            flingActive = true
            flingTargetPlayer = target
            FlingPlayer(target)
            flingActive = false
        end
        index = index % #players + 1
        task.wait(0.5)
    end
    flingInProgress = false
end

local function StartFling(targetRoleOrPlayer)
    if flingInProgress then
        MatzzNotify("FLING", "Aguarde, o fling está em andamento!", 3)
        return
    end
    
    if flingThread then
        task.cancel(flingThread)
        flingThread = nil
    end
    flingActive = false
    flingAllActive = false

    if targetRoleOrPlayer == "all" then
        flingAllActive = true
        flingThread = task.spawn(FlingAllLoop)
    else
        local targetPlayer
        if type(targetRoleOrPlayer) == "string" then
            for plrName, role in pairs(RoleCache) do
                if role == targetRoleOrPlayer then
                    targetPlayer = Players:FindFirstChild(plrName)
                    break
                end
            end
        else
            targetPlayer = targetRoleOrPlayer
        end
        if targetPlayer then
            flingActive = true
            flingTargetPlayer = targetPlayer
            flingThread = task.spawn(FlingPlayer, targetPlayer)
        end
    end
end

local function StopFling()
    flingActive = false
    flingAllActive = false
    if flingThread then
        task.cancel(flingThread)
        flingThread = nil
    end
    Config.FlingSheriff = false
    Config.FlingMurderer = false
    Config.FlingHero = false
    Config.FlingAll = false
    flingInProgress = false
end

local function ToggleFling(roleName)
    PlayClickSound()
    if flingInProgress then
        MatzzNotify("FLING", "Aguarde, o fling está em andamento!", 3)
        return
    end
    if (roleName == "Sheriff" and Config.FlingSheriff) or
       (roleName == "Murderer" and Config.FlingMurderer) or
       (roleName == "Hero" and Config.FlingHero) then
        StopFling()
    else
        StopFling()
        StartFling(roleName)
        if roleName == "Sheriff" then
            Config.FlingSheriff = true
        elseif roleName == "Murderer" then
            Config.FlingMurderer = true
        elseif roleName == "Hero" then
            Config.FlingHero = true
        end
    end
end

local function ToggleFlingAll()
    PlayClickSound()
    if flingInProgress then
        MatzzNotify("FLING", "Aguarde, o fling está em andamento!", 3)
        return
    end
    if Config.FlingAll then
        StopFling()
    else
        StopFling()
        StartFling("all")
        Config.FlingAll = true
    end
end

local function ToggleFlingPlayer(playerName)
    PlayClickSound()
    if flingInProgress then
        MatzzNotify("FLING", "Aguarde, o fling está em andamento!", 3)
        return
    end
    local plr = Players:FindFirstChild(playerName)
    if not plr then
        MatzzNotify("FLING", "Player not found!", 3)
        return
    end

    if flingActive and flingTargetPlayer == plr then
        StopFling()
    else
        StopFling()
        StartFling(plr)
    end
end

ShootGui = Instance.new("ScreenGui")
ShootGui.Name = "ShootGui_Overlay_V19"
ShootGui.Parent = CoreGui
ShootGui.Enabled = false
ShootGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ShootButton = Instance.new("TextButton")
ShootButton.Parent = ShootGui
ShootButton.BackgroundColor3 = Theme.Background
ShootButton.BackgroundTransparency = 0.5
ShootButton.Position = UDim2.new(0.65, 0, 0.6, 0)
ShootButton.Size = UDim2.new(0, 220, 0, 80)
ShootButton.Font = Enum.Font.GothamBold
ShootButton.Text = "MATZZ AIM"
ShootButton.TextColor3 = Theme.Accent
ShootButton.TextSize = 24
ShootButton.AutoButtonColor = false
ShootButton.TextStrokeTransparency = 0.8

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(0, 10)
ShootCorner.Parent = ShootButton

local ShootStroke = Instance.new("UIStroke")
ShootStroke.Parent = ShootButton
ShootStroke.Color = Theme.Accent
ShootStroke.Thickness = 2
ShootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local ShootGradient = Instance.new("UIGradient")
ShootGradient.Parent = ShootStroke
ShootGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Theme.Accent),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.00, Theme.Accent)
}
ShootGradient.Rotation = 45

task.spawn(function()
    while ShootGui do
        if ShootGui.Enabled then
            ShootGradient.Rotation = (ShootGradient.Rotation + 2) % 360
            local t = tick() % 2
            local alpha = 0.5 + 0.5 * math.sin(t * math.pi)
            ShootButton.TextColor3 = Theme.Accent:Lerp(Color3.fromRGB(255, 255, 255), alpha)
        end
        task.wait(0.03)
    end
end)

MakeDraggableCornersOnly(ShootButton)

if Config.SilentAim then
    ShootGui.Enabled = true
end

local function PerformSilentAimMouse()
    PlayClickSound()
    if not Config.SilentAim then
        return
    end
    
    local success = PerformSilentAimDirectly()
    
    if success then
        ShootButton.Text = "FIRED"
        ShootStroke.Color = Color3.fromRGB(255, 50, 50)
        
        task.delay(0.2, function()
            ShootButton.Text = "MATZZ AIM"
            ShootStroke.Color = Theme.Accent
        end)
    else
        ShootButton.Text = "NO TARGET"
        ShootStroke.Color = Color3.fromRGB(255, 50, 50)
        
        task.delay(0.5, function()
            ShootButton.Text = "MATZZ AIM"
            ShootStroke.Color = Theme.Accent
        end)
    end
end

ShootButton.MouseButton1Click:Connect(PerformSilentAimMouse)

local function getRoles()
    if not playerDataRemote then
        playerDataRemote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    end
    
    if playerDataRemote then
        local success, data = pcall(function()
            return playerDataRemote:InvokeServer()
        end)
        
        if success and data then
            local newRoles = {}
            local hasMurder = false
            
            for plr, plrData in pairs(data) do
                if plrData.Dead or not plrData.Role or plrData.Role == "" then
                    newRoles[plr] = "Lobby"
                else
                    newRoles[plr] = plrData.Role
                end
                
                if plrData.Role == "Murderer" then
                    hasMurder = true
                end
            end
            
            if not hasMurder then
                rolesNotified = false
            end
            
            return newRoles
        end
    end
    return nil
end

local function ShowRoleAlert(role)
    if not Config.InstantRole then
        return
    end
    
    if role == "Hero" then
        return
    end
    
    if CoreGui:FindFirstChild("MatzzRoleAlert") then
        CoreGui.MatzzRoleAlert:Destroy()
    end
    
    local AlertGui = Instance.new("ScreenGui")
    AlertGui.Name = "MatzzRoleAlert"
    AlertGui.Parent = CoreGui
    AlertGui.IgnoreGuiInset = true
    
    local yPosition = 0.35
    
    local MainLabel = Instance.new("TextLabel")
    MainLabel.Parent = AlertGui
    MainLabel.Size = UDim2.new(1, 0, 0, 100)
    MainLabel.Position = UDim2.new(0, 0, yPosition, 0)
    MainLabel.BackgroundTransparency = 1
    MainLabel.Font = Enum.Font.GothamBlack
    MainLabel.Text = "YOU ARE " .. string.upper(role)
    MainLabel.TextColor3 = RoleColors[role] or Color3.fromRGB(255, 255, 255)
    MainLabel.TextSize = 0
    MainLabel.TextStrokeTransparency = 0.5
    MainLabel.TextStrokeColor3 = Color3.new(0,0,0)
    
    TweenService:Create(MainLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 60}):Play()
    
    local sound = Instance.new("Sound", AlertGui)
    sound.SoundId = "rbxassetid://10548111966"
    sound.Volume = 2
    sound:Play()
    
    task.delay(4, function()
        if MainLabel then
            TweenService:Create(MainLabel, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            task.wait(0.5)
            if AlertGui then
                AlertGui:Destroy()
            end
        end
    end)
end

task.spawn(function()
    while true do
        local roles = getRoles()
        if roles then
            RoleCache = roles
            local myRole = RoleCache[LocalPlayer.Name] or "Lobby"
            
            if myRole ~= "Lobby" and myRole ~= lastMyRole then
                lastMyRole = myRole
                ShowRoleAlert(myRole)
            elseif myRole == "Lobby" then
                lastMyRole = "Lobby"
            end
            
            local hasMurder = false
            for _, r in pairs(RoleCache) do
                if r == "Murderer" then
                    hasMurder = true
                    break
                end
            end
            
            if not hasMurder then
                rolesNotified = false
            end
            
            if Config.NotifyRoles and not rolesNotified then
                local m, s = "None", "None"
                
                for p, r in pairs(RoleCache) do
                    if r == "Murderer" then
                        m = p
                    elseif r == "Sheriff" then
                        s = p
                    end
                end
                
                if m ~= "None" then
                    MatzzNotify("ROLES REVEALED", "Murderer: " .. m .. "\nSheriff: " .. s, 5)
                    rolesNotified = true
                end
            end
        end
        task.wait(0.25)
    end
end)

local wasGunDropped = false

task.spawn(function()
    while true do
        local dropped = Workspace:FindFirstChild("GunDrop", true)
        foundGunDrop = dropped
        
        if GrabFrame then
            GrabFrame.Visible = Config.ShowGrabBtn and not Config.GamepadEnabled
        end
        
        if InvisFrame then
            InvisFrame.Visible = Config.ShowInvisBtn and not Config.GamepadEnabled
        end
        
        if DesyncFrame then
            DesyncFrame.Visible = Config.ShowDesyncBtn and Config.DesyncEnabled and not Config.GamepadEnabled
        end

        if dropped and not wasGunDropped then
            if Config.NotifyGunDrop then
                MatzzNotify("GUN DROPPED", "The gun has been dropped on the map!", 4)
            end
        end
        
        if wasGunDropped and not dropped and Config.NotifyGunPickup then
            task.wait(0.5)
            for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                if char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or (p.Backpack and (p.Backpack:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver")))) then
                    MatzzNotify("GUN TAKEN", p.Name .. " picked up the gun!", 4)
                    break
                end
            end
        end
        
        wasGunDropped = (dropped ~= nil)
        task.wait(0.2)
    end
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if Config.WalkSpeedEnabled then
                hum.WalkSpeed = Config.WalkSpeedValue
            end
            
            if Config.JumpPowerEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPowerValue
            end
        end
    end
end)

local function GetKnifeRemote()
    if not LocalPlayer.Character then
        return nil
    end
    
    local tool = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    
    if tool then
        return tool:FindFirstChild("HandleTouched", true)
    end
    
    return nil
end

RunService.RenderStepped:Connect(function()
    if Config.HitboxExpand then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    root.Transparency = Config.HitboxVisible and 0.5 or 1
                    root.CanCollide = false
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if Config.KnifeAura and RoleCache[LocalPlayer.Name] == "Murderer" then
            local myChar = LocalPlayer.Character
            local knife = myChar and myChar:FindFirstChild("Knife")
            
            if knife and knife:FindFirstChild("Handle") then
                local targetFound = false
                
                for _, enemy in ipairs(Players:GetPlayers()) do
                    if enemy ~= LocalPlayer and enemy.Character then
                        local eRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
                        local eHum = enemy.Character:FindFirstChild("Humanoid")
                        local eRole = RoleCache[enemy.Name]
                        
                        if eRoot and eHum and eHum.Health > 0 and eRole ~= "Murderer" and eRole ~= "Lobby" then
                            local dist = (eRoot.Position - myChar.HumanoidRootPart.Position).Magnitude
                            
                            if dist <= Config.KnifeAuraDist then
                                eRoot.CFrame = knife.Handle.CFrame
                                eRoot.Velocity = Vector3.new(0,0,0)
                                eRoot.RotVelocity = Vector3.new(0,0,0)
                                
                                local remote = GetKnifeRemote()
                                if remote then
                                    pcall(function()
                                        remote:FireServer(eRoot)
                                    end)
                                end
                                
                                if Config.KnifeLegitMode then
                                    targetFound = true
                                    break
                                end
                            end
                        end
                    end
                    
                    if Config.KnifeLegitMode and targetFound then
                        break
                    end
                end
            end
        end
        task.wait()
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.KnifeHoming and RoleCache[LocalPlayer.Name] == "Murderer" then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name == "ThrowingKnife" then
                if not obj:IsDescendantOf(LocalPlayer.Character) then
                    local targetFound = false
                    
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local enemyRoot = plr.Character.HumanoidRootPart
                            local role = RoleCache[plr.Name]
                            
                            if role ~= "Lobby" and role ~= "Murderer" then
                                local knifePos = nil
                                
                                if obj:FindFirstChild("BladePosition") then
                                    knifePos = obj.BladePosition.Position
                                elseif obj:IsA("BasePart") then
                                    knifePos = obj.Position
                                elseif obj:FindFirstChild("Handle") then
                                    knifePos = obj.Handle.Position
                                end
                                
                                if knifePos then
                                    local dist = (knifePos - enemyRoot.Position).Magnitude
                                    
                                    if dist <= Config.KnifeTriggerDist then
                                        enemyRoot.CFrame = CFrame.new(knifePos)
                                        enemyRoot.Velocity = Vector3.new(0,0,0)
                                        
                                        local remote = GetKnifeRemote()
                                        if remote then
                                            pcall(function()
                                                remote:FireServer(enemyRoot)
                                            end)
                                        end
                                        
                                        if Config.KnifeLegitMode then
                                            targetFound = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if Config.KnifeLegitMode and targetFound then
                            break
                        end
                    end
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.AntiFling then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AutoGrabGun then
        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        
        if Char and Root and RoleCache[LocalPlayer.Name] ~= "Murderer" and RoleCache[LocalPlayer.Name] ~= "Sheriff" then
            local gun = Workspace:FindFirstChild("GunDrop", true)
            
            if gun and (gun.Position - Root.Position).Magnitude <= Config.GrabDistance then
                gun.CanCollide = false
                gun.CFrame = Root.CFrame
                gun.Velocity = Vector3.new(0,0,0)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    closesthitpart = getGunTarget()
    closestKnifePart = getclosestplayer()
    knifeEquipped = hasKnife(LocalPlayer)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name:find("knife") or name:find("fac") or name == "knife" then
                knifeEquipped = true
                hookKnifeThrown()
            end
        end
    end)
    
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name:find("knife") or name:find("fac") or name == "knife" then
                knifeEquipped = false
            end
        end
    end)
    
    task.wait(0.5)
    hookKnifeThrown()
end)

task.spawn(detectMurder)

if LocalPlayer.Character then
    task.wait(0.5)
    hookKnifeThrown()
end

local function KillAll()
    if RoleCache[LocalPlayer.Name] ~= "Murderer" then
        MatzzNotify("KILL ALL", "You must be the Murderer to use this!", 3)
        return
    end
    
    local myChar = LocalPlayer.Character
    local knife = myChar and myChar:FindFirstChild("Knife")
    
    if not knife then
        knife = LocalPlayer.Backpack:FindFirstChild("Knife")
    end
    
    if knife and knife:FindFirstChild("Handle") then
        local killed = 0
        
        for _, enemy in ipairs(Players:GetPlayers()) do
            if enemy ~= LocalPlayer and enemy.Character then
                local eRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
                local eHum = enemy.Character:FindFirstChild("Humanoid")
                local eRole = RoleCache[enemy.Name]
                
                if eRoot and eHum and eHum.Health > 0 and eRole ~= "Murderer" and eRole ~= "Lobby" then
                    eRoot.CFrame = knife.Handle.CFrame
                    eRoot.Velocity = Vector3.new(0,0,0)
                    eRoot.RotVelocity = Vector3.new(0,0,0)
                    
                    local remote = GetKnifeRemote()
                    if remote then
                        pcall(function()
                            remote:FireServer(eRoot)
                        end)
                    end
                    
                    killed = killed + 1
                    
                    if Config.KnifeLegitMode then
                        break
                    end
                end
            end
        end
        
        if killed > 0 then
            MatzzNotify("KILL ALL", "Attempted to kill " .. killed .. " players.", 3)
        else
            MatzzNotify("KILL ALL", "No valid targets found.", 3)
        end
    else
        MatzzNotify("KILL ALL", "You need a knife!", 3)
    end
end

local function ApplyAutoPrankBomb(state)
    if state then
        if prankBombConnection then
            prankBombConnection:Disconnect()
        end
        prankBombConnection = Workspace.ChildAdded:Connect(function(obj)
            if obj.Name == "Handle" then
                task.spawn(function()
                    local creator = obj:WaitForChild("creator", 0.5)
                    if creator then
                        local donoDaBomba = false
                        if creator:IsA("ObjectValue") and creator.Value == LocalPlayer then
                            donoDaBomba = true
                        elseif creator:IsA("StringValue") and creator.Value == LocalPlayer.Name then
                            donoDaBomba = true
                        elseif creator.Value == LocalPlayer.Name then
                            donoDaBomba = true
                        end

                        if donoDaBomba then
                            local character = LocalPlayer.Character
                            if character then
                                local rootPart = character:FindFirstChild("HumanoidRootPart")
                                local humanoid = character:FindFirstChild("Humanoid")
                                if rootPart and humanoid and obj:IsA("BasePart") then
                                    obj.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
                                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        if prankBombConnection then
            prankBombConnection:Disconnect()
            prankBombConnection = nil
        end
    end
end

local TracerGui = Instance.new("ScreenGui")
TracerGui.Name = "MatzzTracersGui"
TracerGui.Parent = CoreGui
TracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TracerGui.IgnoreGuiInset = true

local TracerCache = {}

local function UpdateESP()
    for uuid, line in pairs(TracerCache) do
        line.Visible = false
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local role = RoleCache[plr.Name] or "Lobby"
            local color = RoleColors[role] or RoleColors.Lobby
            
            local showFill, showOutline, showTracer, showName, showDist = false, false, false, false, false
            
            if role == "Murderer" then
                showFill = Config.Murder_Fill
                showOutline = Config.Murder_Outline
                showTracer = Config.Murder_Tracer
                showName = Config.Murder_Name
                showDist = Config.Murder_Dist
            elseif role == "Sheriff" then
                showFill = Config.Sheriff_Fill
                showOutline = Config.Sheriff_Outline
                showTracer = Config.Sheriff_Tracer
                showName = Config.Sheriff_Name
                showDist = Config.Sheriff_Dist
            elseif role == "Hero" then
                showFill = Config.Hero_Fill
                showOutline = Config.Hero_Outline
                showTracer = Config.Hero_Tracer
                showName = Config.Hero_Name
                showDist = Config.Hero_Dist
            elseif role == "Innocent" then
                showFill = Config.Innocent_Fill
                showOutline = Config.Innocent_Outline
                showTracer = Config.Innocent_Tracer
                showName = Config.Innocent_Name
                showDist = Config.Innocent_Dist
            else
                showFill = Config.Lobby_Fill
                showOutline = Config.Lobby_Outline
                showTracer = Config.Lobby_Tracer
                showName = Config.Lobby_Name
                showDist = Config.Lobby_Dist
            end
            
            local holder = plr.Character:FindFirstChild("MatzzESP_Holder")
            if not holder then
                holder = Instance.new("Folder", plr.Character)
                holder.Name = "MatzzESP_Holder"
            end
            
            local hl = holder:FindFirstChild("Highlight")
            if showFill or showOutline then
                if not hl then
                    hl = Instance.new("Highlight", holder)
                    hl.Adornee = plr.Character
                end
                
                hl.FillColor = color
                hl.OutlineColor = color
                hl.FillTransparency = showFill and Config.FillTransparency or 1
                hl.OutlineTransparency = showOutline and Config.OutlineTransparency or 1
            else
                if hl then
                    hl:Destroy()
                end
            end
            
            local head = plr.Character:FindFirstChild("Head")
            if head and (showName or showDist) then
                local bg = holder:FindFirstChild("NameGui")
                if not bg then
                    bg = Instance.new("BillboardGui", holder)
                    bg.Name = "NameGui"
                    bg.Adornee = head
                    bg.Size = UDim2.new(0, 200, 0, 50)
                    bg.StudsOffset = Vector3.new(0, 3, 0)
                    bg.AlwaysOnTop = true
                    
                    local t = Instance.new("TextLabel", bg)
                    t.Name = "Txt"
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.Font = Enum.Font.GothamBold
                    t.TextStrokeTransparency = 0.5
                    t.TextSize = 13
                end
                
                local finalText = ""
                if showName then
                    finalText = "[" .. string.upper(role) .. "]"
                end
                
                if showDist and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    finalText = finalText .. "\n[" .. tostring(dist) .. "m]"
                end
                
                bg.Txt.Text = finalText
                bg.Txt.TextColor3 = color
            else
                if holder:FindFirstChild("NameGui") then
                    holder.NameGui:Destroy()
                end
            end
            
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root and showTracer then
                local vec, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local line = TracerCache[plr.Name]
                    if not line then
                        line = Instance.new("Frame")
                        line.Name = plr.Name
                        line.AnchorPoint = Vector2.new(0.5, 0.5)
                        line.BorderSizePixel = 0
                        line.Parent = TracerGui
                        TracerCache[plr.Name] = line
                    end
                    
                    line.Visible = true
                    line.BackgroundColor3 = color
                    
                    local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local target = Vector2.new(vec.X, vec.Y)
                    local length = (origin - target).Magnitude
                    local center = (origin + target) / 2
                    local angle = math.atan2(target.Y - origin.Y, target.X - origin.X)
                    
                    line.Size = UDim2.new(0, length, 0, 1.5)
                    line.Position = UDim2.new(0, center.X, 0, center.Y)
                    line.Rotation = math.deg(angle)
                end
            end
        end
    end
    
    if foundGunDrop then
        local holder = foundGunDrop:FindFirstChild("MatzzESP_Holder")
        if not holder then
            holder = Instance.new("Folder", foundGunDrop)
            holder.Name = "MatzzESP_Holder"
        end
        
        local hl = holder:FindFirstChild("Highlight")
        if Config.Gun_Fill or Config.Gun_Outline then
            if not hl then
                hl = Instance.new("Highlight", holder)
                hl.Adornee = foundGunDrop
            end
            
            hl.FillColor = RoleColors.Gun
            hl.OutlineColor = RoleColors.Gun
            hl.FillTransparency = Config.Gun_Fill and 0.5 or 1
            hl.OutlineTransparency = Config.Gun_Outline and 0 or 1
        else
            if hl then
                hl:Destroy()
            end
        end
        
        if Config.Gun_Name or Config.Gun_Dist then
            local bg = holder:FindFirstChild("NameGui")
            if not bg then
                bg = Instance.new("BillboardGui", holder)
                bg.Name = "NameGui"
                bg.Adornee = foundGunDrop
                bg.Size = UDim2.new(0, 200, 0, 50)
                bg.StudsOffset = Vector3.new(0, 2, 0)
                bg.AlwaysOnTop = true
                
                local t = Instance.new("TextLabel", bg)
                t.Name = "Txt"
                t.Size = UDim2.new(1, 0, 1, 0)
                t.BackgroundTransparency = 1
                t.Font = Enum.Font.GothamBold
                t.TextStrokeTransparency = 0.5
                t.TextSize = 13
            end
            
            local txt = "GUN DROP"
            if Config.Gun_Dist and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - foundGunDrop.Position).Magnitude)
                txt = txt .. " ["..dist.."m]"
            end
            
            bg.Txt.Text = txt
            bg.Txt.TextColor3 = RoleColors.Gun
        else
            if holder:FindFirstChild("NameGui") then
                holder.NameGui:Destroy()
            end
        end
        
        if Config.Gun_Tracer then
            local vec, onScreen = Camera:WorldToViewportPoint(foundGunDrop.Position)
            if onScreen then
                if not gunTracerLine then
                    gunTracerLine = Instance.new("Frame")
                    gunTracerLine.Name = "GunTracer"
                    gunTracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
                    gunTracerLine.BorderSizePixel = 0
                    gunTracerLine.Parent = TracerGui
                end
                gunTracerLine.Visible = true
                gunTracerLine.BackgroundColor3 = RoleColors.Gun
                
                local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local target = Vector2.new(vec.X, vec.Y)
                local length = (origin - target).Magnitude
                local center = (origin + target) / 2
                local angle = math.atan2(target.Y - origin.Y, target.X - origin.X)
                
                gunTracerLine.Size = UDim2.new(0, length, 0, 1.5)
                gunTracerLine.Position = UDim2.new(0, center.X, 0, center.Y)
                gunTracerLine.Rotation = math.deg(angle)
            else
                if gunTracerLine then
                    gunTracerLine.Visible = false
                end
            end
        else
            if gunTracerLine then
                gunTracerLine.Visible = false
            end
        end
    else
        if gunTracerLine then
            gunTracerLine.Visible = false
        end
    end
    
    if ghostPart then
        local vec, onScreen = Camera:WorldToViewportPoint(ghostPart.Position)
        if onScreen then
            if not desyncTracerLine then
                desyncTracerLine = Instance.new("Frame")
                desyncTracerLine.Name = "DesyncTracer"
                desyncTracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
                desyncTracerLine.BorderSizePixel = 0
                desyncTracerLine.Parent = TracerGui
            end
            desyncTracerLine.Visible = true
            desyncTracerLine.BackgroundColor3 = Theme.Ghost
            
            local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local target = Vector2.new(vec.X, vec.Y)
            local length = (origin - target).Magnitude
            local center = (origin + target) / 2
            local angle = math.atan2(target.Y - origin.Y, target.X - origin.X)
            
            desyncTracerLine.Size = UDim2.new(0, length, 0, 1.5)
            desyncTracerLine.Position = UDim2.new(0, center.X, 0, center.Y)
            desyncTracerLine.Rotation = math.deg(angle)
        else
            if desyncTracerLine then
                desyncTracerLine.Visible = false
            end
        end
    else
        if desyncTracerLine then
            desyncTracerLine.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

local function AutoFarmCoinsFunc()
    local function GetMap()
        while true do
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
                    return obj
                end
            end
            task.wait(0.1)
        end
    end

    local function getNearest()
        local map = GetMap()
        local closest, dist = nil, math.huge
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
            return nil
        end
        
        local HRP = char:FindFirstChild("HumanoidRootPart")
        if not HRP then return nil end
        
        for _, coin in ipairs(map.CoinContainer:GetChildren()) do
            local v = coin:FindFirstChild("CoinVisual")
            if v and not v:GetAttribute("Collected") then
                local d = (HRP.Position - coin.Position).Magnitude
                if d < dist then
                    closest = coin
                    dist = d
                end
            end
        end
        return closest
    end

    local function tp(hp)
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") then return end
        
        local HRP = char:FindFirstChild("HumanoidRootPart")
        local Humanoid = char:FindFirstChild("Humanoid")
        if not HRP or not Humanoid then return end
        
        if Humanoid.Health <= 0 then
            autoFarmCoinsRunning = false
            return
        end
        
        Humanoid:ChangeState(11)
        local d = (HRP.Position - hp.Position).Magnitude
        local t = TweenService:Create(HRP, TweenInfo.new(d / 25, Enum.EasingStyle.Linear), {CFrame = hp.CFrame})
        t:Play()
        t.Completed:Wait()
    end

    while autoFarmCoinsRunning and task.wait(0.1) do
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
            autoFarmCoinsRunning = false
            if Config.AutoFarmCoins then
                Config.AutoFarmCoins = false
            end
            break
        end
        
        local target = getNearest()
        if target then
            tp(target)
            local v = target:FindFirstChild("CoinVisual")
            while v and not v:GetAttribute("Collected") and v.Parent do
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                    autoFarmCoinsRunning = false
                    break
                end
                
                local n = getNearest()
                if n and n ~= target then break end
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end
end

task.spawn(function()
    while true do
        if Config.AutoFarmCoins and autoFarmCoinsRunning then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if char.Humanoid.Health <= 0 then
                    autoFarmCoinsRunning = false
                    Config.AutoFarmCoins = false
                    
                    if autoFarmCoinsThread then
                        task.cancel(autoFarmCoinsThread)
                        autoFarmCoinsThread = nil
                    end
                end
            end
        end
        task.wait(1)
    end
end)

local function setTransparency(character, transparency)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            if part.Name ~= "HumanoidRootPart" then
                part.Transparency = transparency
            end
        end
    end
end

local function setHumanoidRootPartTransparency(character, transparency)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
        humanoidRootPart.Transparency = transparency
    end
end

local function createModernGhost(cframe)
    if ghostPart then ghostPart:Destroy() end
    
    local ghostColor = Theme.Ghost
    
    local ghost = Instance.new("Part")
    ghost.Name = "MatzzDesyncGhost"
    ghost.Size = Vector3.new(4, 6, 4)
    ghost.Shape = Enum.PartType.Cylinder
    ghost.CFrame = cframe * CFrame.Angles(0, 0, math.rad(90))
    ghost.Anchored = true
    ghost.CanCollide = false
    ghost.Material = Enum.Material.ForceField
    ghost.Color = ghostColor
    ghost.Transparency = 0
    ghost.CastShadow = false
    ghost.Parent = Workspace
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = ghost
    highlight.FillColor = ghostColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.2
    highlight.Parent = ghost
    
    local bbGui = Instance.new("BillboardGui")
    bbGui.Adornee = ghost
    bbGui.Size = UDim2.new(0, 200, 0, 50)
    bbGui.StudsOffset = Vector3.new(0, 4, 0)
    bbGui.AlwaysOnTop = true
    
    local txt = Instance.new("TextLabel", bbGui)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "SERVER POSITION"
    txt.Font = Enum.Font.Oswald
    txt.TextColor3 = ghostColor
    txt.TextStrokeTransparency = 0
    txt.TextSize = 14
    bbGui.Parent = ghost
    
    local info = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(highlight, info, {FillTransparency = 0.5})
    tween:Play()
    
    return ghost
end

local function ToggleDesync()
    PlayClickSound()
    desync_on = not desync_on
    
    local character = LocalPlayer.Character
    if not character then return end
    
    if desync_on then
        local originalCFrame = character.HumanoidRootPart.CFrame
        
        desyncChair = Instance.new('Seat', Workspace)
        desyncChair.Anchored = false
        desyncChair.CanCollide = false
        desyncChair.Name = 'MatzzDesyncChair'
        desyncChair.Transparency = 1
        desyncChair.CFrame = originalCFrame
        
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            desyncWeld = Instance.new("Weld", desyncChair)
            desyncWeld.Part0 = desyncChair
            desyncWeld.Part1 = torso
        end
        
        setTransparency(character, 0)
        setHumanoidRootPartTransparency(character, 1)
        
        ghostPart = createModernGhost(originalCFrame)
        
        DesyncBtn.Text = "ACTIVE"
        DesyncBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        DesyncStroke.Color = Color3.fromRGB(0, 255, 150)
        
        MatzzNotify("DESYNC", "Fake Position Enabled!", 3)
    else
        if desyncChair then 
            desyncChair:Destroy() 
            desyncChair = nil 
        end
        
        if ghostPart then 
            ghostPart:Destroy() 
            ghostPart = nil 
        end
        
        desyncWeld = nil
        
        setTransparency(character, 0)
        setHumanoidRootPartTransparency(character, 1)
        
        DesyncBtn.Text = "DESYNC"
        DesyncBtn.TextColor3 = Theme.Ghost
        DesyncStroke.Color = Theme.Ghost
        
        MatzzNotify("DESYNC", "Fake Position Disabled!", 3)
    end
end

DesyncBtn.MouseButton1Click:Connect(ToggleDesync)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    
    local desyncChair = Workspace:FindFirstChild('MatzzDesyncChair')
    if desyncChair then desyncChair:Destroy() end
    
    if ghostPart then ghostPart:Destroy() ghostPart = nil end
    
    desync_on = false
    desyncWeld = nil
    
    if DesyncBtn then
        DesyncBtn.Text = "DESYNC"
        DesyncBtn.TextColor3 = Theme.Ghost
        if DesyncStroke then
            DesyncStroke.Color = Theme.Ghost
        end
    end
    
    setTransparency(character, 0)
    setHumanoidRootPartTransparency(character, 1)
end)

local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if Config.AntiSilentAim and not checkcaller() then
        if key == "CFrame" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if self == LocalPlayer.Character.HumanoidRootPart then
                    return antiSilentAimData.savedCFrame or CFrame.new()
                elseif self == LocalPlayer.Character.Head then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    if root and antiSilentAimData.savedCFrame then
                        return antiSilentAimData.savedCFrame + Vector3.new(0, root.Size.Y/2 + 0.5, 0)
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end))

RunService.Heartbeat:Connect(function()
    if Config.AntiSilentAim then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                antiSilentAimData.savedCFrame = root.CFrame
                antiSilentAimData.savedVelocity = root.AssemblyLinearVelocity

                local fakeCFrame = root.CFrame * CFrame.new(0,0,0) * CFrame.Angles(
                    math.rad(math.random(-18000,18000)/100),
                    math.rad(math.random(-18000,18000)/100),
                    math.rad(math.random(-18000,18000)/100)
                )
                root.CFrame = fakeCFrame
                root.AssemblyLinearVelocity = Vector3.new(1,1,1) * 8192

                RunService.RenderStepped:Wait()

                root.CFrame = antiSilentAimData.savedCFrame
                root.AssemblyLinearVelocity = antiSilentAimData.savedVelocity
            end
        end
    else
        antiSilentAimData.savedCFrame = nil
        antiSilentAimData.savedVelocity = nil
    end
end)

local function onInputBeganAntiSilent(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Config.AntiSilentAimKey] then
        Config.AntiSilentAim = not Config.AntiSilentAim
        MatzzNotify("ANTI SILENT AIM", Config.AntiSilentAim and "Ativado" or "Desativado", 2)
    elseif input.KeyCode == Enum.KeyCode.Equal then -- tecla "="
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
end
UserInputService.InputBegan:Connect(onInputBeganAntiSilent)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MatzzHubMain"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ScreenGui.Destroying:Connect(function()
    if coinReachConn then
        coinReachConn:Disconnect()
        coinReachConn = nil
    end
    
    for obj, originalSize in pairs(coinOrig) do
        if obj and obj.Parent then
            obj.Size = originalSize
        end
    end
    
    autoFarmCoinsRunning = false
    if autoFarmCoinsThread then
        task.cancel(autoFarmCoinsThread)
        autoFarmCoinsThread = nil
    end
    
    for _, conn in pairs(gamepadConnections) do
        conn:Disconnect()
    end
    gamepadConnections = {}
    
    if coinsRemoveConn then
        coinsRemoveConn:Disconnect()
        coinsRemoveConn = nil
    end
    
    if optimizerCoinsConn then
        optimizerCoinsConn:Disconnect()
        optimizerCoinsConn = nil
    end
    
    local desyncChair = Workspace:FindFirstChild('MatzzDesyncChair')
    if desyncChair then desyncChair:Destroy() end
    
    if ghostPart then ghostPart:Destroy() ghostPart = nil end
    
    if footstepConnection then
        footstepConnection:Disconnect()
        footstepConnection = nil
    end
    
    if roundTimerConnection then
        roundTimerConnection:Disconnect()
        roundTimerConnection = nil
    end
    
    if roundTimerGui then
        roundTimerGui:Destroy()
        roundTimerGui = nil
    end
    
    if secondLifeConnection then
        secondLifeConnection:Disconnect()
        secondLifeConnection = nil
    end
    
    if gunTracerLine then gunTracerLine:Destroy() end
    if desyncTracerLine then desyncTracerLine:Destroy() end
    
    if prankBombConnection then
        prankBombConnection:Disconnect()
        prankBombConnection = nil
    end
    
    StopFling()
end)

ToggleButton = Instance.new("ImageButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Image = "rbxassetid://108999865215827"
ToggleButton.ImageColor3 = Color3.new(1, 1, 1)
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.ZIndex = 100
AddCorner(ToggleButton, 10)
MakeDraggable(ToggleButton, ToggleButton)

MainFrame = Instance.new("Frame")
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 400, 0, 320)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
AddCorner(MainFrame, 10)
AddStroke(MainFrame, Theme.Accent, 2)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.Parent = MainFrame
AddCorner(Sidebar, 10)
MakeDraggable(MainFrame, Sidebar)

ToggleButton.MouseButton1Click:Connect(function()
    PlayClickSound()
    MainFrame.Visible = not MainFrame.Visible
    
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 320), BackgroundTransparency = 0}):Play()
    end
end)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -110, 1, -20)
ContentContainer.Position = UDim2.new(0, 110, 0, 10)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Sidebar
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MATZZ MM2"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 14
TitleLabel.LayoutOrder = 0

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 30)
    TabBtn.Position = UDim2.new(0, 5, 0, 50 + (#tabs * 35))
    TabBtn.BackgroundColor3 = Theme.Background
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextColor3 = Theme.TextDim
    TabBtn.TextSize = 12
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = Sidebar
    AddCorner(TabBtn, 6)
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 2
    TabFrame.ScrollBarImageColor3 = Theme.Accent
    TabFrame.Visible = false
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = TabFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = TabFrame
    
    table.insert(tabs, {Btn = TabBtn, Frame = TabFrame})
    
    TabBtn.MouseButton1Click:Connect(function()
        PlayClickSound()
        
        for _, t in ipairs(tabs) do
            t.Frame.Visible = false
            TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = Theme.TextDim, BackgroundColor3 = Theme.Background}):Play()
        end
        
        TabFrame.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Text, BackgroundColor3 = Theme.AccentDark}):Play()
    end)
    
    return TabFrame
end

local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 32)
    ToggleFrame.BackgroundColor3 = Theme.ItemBG
    ToggleFrame.Parent = parent
    AddCorner(ToggleFrame, 6)
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.8, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(1, -24, 0.5, -8)
    Indicator.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60, 60, 60)
    Indicator.Parent = ToggleFrame
    AddCorner(Indicator, 4)
    
    local toggled = default
    
    if toggled then
        Indicator.BackgroundColor3 = Theme.Accent
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        PlayClickSound()
        toggled = not toggled
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(60, 60, 60)}):Play()
        callback(toggled)
    end)
    
    return function(state)
        toggled = state
        Indicator.BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(60, 60, 60)
    end
end

local function CreateButton(parent, text, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -10, 0, 32)
    ButtonFrame.BackgroundColor3 = Theme.ItemBG
    ButtonFrame.Parent = parent
    AddCorner(ButtonFrame, 6)
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = text
    Btn.TextColor3 = Theme.Accent
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = ButtonFrame
    
    Btn.MouseButton1Click:Connect(function()
        PlayClickSound()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentDark}):Play()
        task.wait(0.1)
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ItemBG}):Play()
        callback(Btn, ButtonFrame)
    end)
end

local function CreateSection(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Accent
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
end

local function CreateInput(parent, text, placeholder, defaultVal, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -10, 0, 32)
    InputFrame.BackgroundColor3 = Theme.ItemBG
    InputFrame.Parent = parent
    AddCorner(InputFrame, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = InputFrame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.4, 0, 0.7, 0)
    Box.Position = UDim2.new(0.55, 0, 0.15, 0)
    Box.BackgroundColor3 = Theme.InputBG
    Box.Text = defaultVal or ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = Theme.Accent
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 11
    Box.Parent = InputFrame
    AddCorner(Box, 4)
    
    local BoxStroke = AddStroke(Box, Color3.fromRGB(50, 50, 60), 1)
    
    Box.Focused:Connect(function()
        TweenService:Create(BoxStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
    end)
    
    Box.FocusLost:Connect(function()
        TweenService:Create(BoxStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 60)}):Play()
        if callback then
            callback(Box.Text)
        end
    end)
end

local function CreateKeybind(parent, text, defaultVal, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, -10, 0, 32)
    KeybindFrame.BackgroundColor3 = Theme.ItemBG
    KeybindFrame.Parent = parent
    AddCorner(KeybindFrame, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = KeybindFrame
    
    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
    KeyBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
    KeyBtn.BackgroundColor3 = Theme.InputBG
    KeyBtn.Text = defaultVal
    KeyBtn.TextColor3 = Theme.Accent
    KeyBtn.Font = Enum.Font.GothamBold
    KeyBtn.TextSize = 11
    KeyBtn.Parent = KeybindFrame
    AddCorner(KeyBtn, 4)
    
    local KeyStroke = AddStroke(KeyBtn, Color3.fromRGB(50, 50, 60), 1)
    
    local listening = false
    
    KeyBtn.MouseButton1Click:Connect(function()
        PlayClickSound()
        listening = true
        KeyBtn.Text = "..."
        KeyBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
        KeyStroke.Color = Color3.fromRGB(255, 50, 50)
    end)
    
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            
            if keyCodes[keyName] or keyName:find("Button") or keyName:find("DPad") then
                KeyBtn.Text = keyName
                KeyBtn.TextColor3 = Theme.Accent
                KeyStroke.Color = Theme.Accent
                listening = false
                
                if callback then
                    callback(keyName)
                end
                
                connection:Disconnect()
            else
                MatzzNotify("KEYBIND", "Por favor, use um botão de gamepad válido!", 2)
            end
        end
    end)
    
    task.delay(10, function()
        if listening then
            listening = false
            KeyBtn.Text = defaultVal
            KeyBtn.TextColor3 = Theme.Accent
            KeyStroke.Color = Theme.Accent
            connection:Disconnect()
        end
    end)
end

local TabCombat = CreateTab("COMBAT")
CreateSection(TabCombat, "LEGIT MODE")
CreateToggle(TabCombat, "Legit Mode (1 Target Only)", Config.KnifeLegitMode, function(v)
    Config.KnifeLegitMode = v
end)

CreateSection(TabCombat, "MURDERER (KNIFE)")
CreateToggle(TabCombat, "Knife Throwing TP", Config.KnifeHoming, function(v)
    Config.KnifeHoming = v
end)
CreateToggle(TabCombat, "Knife Silent Aim", Config.KnifeSilentAim, function(v)
    Config.KnifeSilentAim = v
end)
CreateInput(TabCombat, "Throw Trigger Dist", "Ex: 25", tostring(Config.KnifeTriggerDist), function(txt)
    Config.KnifeTriggerDist = tonumber(txt) or 25
end)
CreateButton(TabCombat, "KILL ALL (MURDERER)", function(btn, frame)
    PlayClickSound()
    KillAll()
end)

CreateSection(TabCombat, "KNIFE AURA")
CreateToggle(TabCombat, "Enable Knife Aura", Config.KnifeAura, function(v)
    Config.KnifeAura = v
end)
CreateInput(TabCombat, "Aura Distance", "Ex: 15", tostring(Config.KnifeAuraDist), function(txt)
    Config.KnifeAuraDist = tonumber(txt) or 15
end)

CreateSection(TabCombat, "HITBOX EXPANDER")
CreateToggle(TabCombat, "Enable Expand", Config.HitboxExpand, function(v)
    Config.HitboxExpand = v
end)
CreateInput(TabCombat, "Size (Default: 4)", "Ex: 4", tostring(Config.HitboxSize), function(txt)
    Config.HitboxSize = tonumber(txt) or 4
end)
CreateToggle(TabCombat, "Visible Hitbox", Config.HitboxVisible, function(v)
    Config.HitboxVisible = v
end)

CreateSection(TabCombat, "SHERIFF/HERO (GUN)")
CreateToggle(TabCombat, "Silent Aim (Button)", Config.SilentAim, function(v)
    Config.SilentAim = v
    ShootGui.Enabled = v
end)

CreateToggle(TabCombat, "Gun Silent Aim", Config.GunSilentAim, function(v)
    Config.GunSilentAim = v
end)

CreateToggle(TabCombat, "Aim WallCheck", Config.WallCheck, function(v)
    Config.WallCheck = v
end)
CreateToggle(TabCombat, "Lead Shot (Ping Predict)", Config.LeadShot, function(v)
    Config.LeadShot = v
end)

local TabVisuals = CreateTab("VISUALS")
CreateSection(TabVisuals, "NOTIFICATIONS")
CreateToggle(TabVisuals, "Notify Roles (Murd/Sher)", Config.NotifyRoles, function(v)
    Config.NotifyRoles = v
end)
CreateToggle(TabVisuals, "Notify Gun Pickup", Config.NotifyGunPickup, function(v)
    Config.NotifyGunPickup = v
end)
CreateToggle(TabVisuals, "Notify Gun Drop", Config.NotifyGunDrop, function(v)
    Config.NotifyGunDrop = v
end)

CreateSection(TabVisuals, "MURDERER (RED)")
CreateToggle(TabVisuals, "Show Highlight", Config.Murder_Fill, function(v)
    Config.Murder_Fill = v
end)
CreateToggle(TabVisuals, "Show Outline", Config.Murder_Outline, function(v)
    Config.Murder_Outline = v
end)
CreateToggle(TabVisuals, "Show Tracer", Config.Murder_Tracer, function(v)
    Config.Murder_Tracer = v
end)
CreateToggle(TabVisuals, "Show Role Text", Config.Murder_Name, function(v)
    Config.Murder_Name = v
end)
CreateToggle(TabVisuals, "Show Distance", Config.Murder_Dist, function(v)
    Config.Murder_Dist = v
end)

CreateSection(TabVisuals, "SHERIFF (BLUE)")
CreateToggle(TabVisuals, "Show Highlight", Config.Sheriff_Fill, function(v)
    Config.Sheriff_Fill = v
end)
CreateToggle(TabVisuals, "Show Outline", Config.Sheriff_Outline, function(v)
    Config.Sheriff_Outline = v
end)
CreateToggle(TabVisuals, "Show Tracer", Config.Sheriff_Tracer, function(v)
    Config.Sheriff_Tracer = v
end)
CreateToggle(TabVisuals, "Show Role Text", Config.Sheriff_Name, function(v)
    Config.Sheriff_Name = v
end)
CreateToggle(TabVisuals, "Show Distance", Config.Sheriff_Dist, function(v)
    Config.Sheriff_Dist = v
end)

CreateSection(TabVisuals, "HERO (YELLOW)")
CreateToggle(TabVisuals, "Show Highlight", Config.Hero_Fill, function(v)
    Config.Hero_Fill = v
end)
CreateToggle(TabVisuals, "Show Outline", Config.Hero_Outline, function(v)
    Config.Hero_Outline = v
end)
CreateToggle(TabVisuals, "Show Tracer", Config.Hero_Tracer, function(v)
    Config.Hero_Tracer = v
end)
CreateToggle(TabVisuals, "Show Role Text", Config.Hero_Name, function(v)
    Config.Hero_Name = v
end)
CreateToggle(TabVisuals, "Show Distance", Config.Hero_Dist, function(v)
    Config.Hero_Dist = v
end)

CreateSection(TabVisuals, "INNOCENT (GREEN)")
CreateToggle(TabVisuals, "Show Highlight", Config.Innocent_Fill, function(v)
    Config.Innocent_Fill = v
end)
CreateToggle(TabVisuals, "Show Outline", Config.Innocent_Outline, function(v)
    Config.Innocent_Outline = v
end)
CreateToggle(TabVisuals, "Show Tracer", Config.Innocent_Tracer, function(v)
    Config.Innocent_Tracer = v
end)
CreateToggle(TabVisuals, "Show Role Text", Config.Innocent_Name, function(v)
    Config.Innocent_Name = v
end)
CreateToggle(TabVisuals, "Show Distance", Config.Innocent_Dist, function(v)
    Config.Innocent_Dist = v
end)

CreateSection(TabVisuals, "LOBBY / DEAD (GREY)")
CreateToggle(TabVisuals, "Show Highlight", Config.Lobby_Fill, function(v)
    Config.Lobby_Fill = v
end)
CreateToggle(TabVisuals, "Show Outline", Config.Lobby_Outline, function(v)
    Config.Lobby_Outline = v
end)
CreateToggle(TabVisuals, "Show Tracer", Config.Lobby_Tracer, function(v)
    Config.Lobby_Tracer = v
end)
CreateToggle(TabVisuals, "Show Role Text", Config.Lobby_Name, function(v)
    Config.Lobby_Name = v
end)
CreateToggle(TabVisuals, "Show Distance", Config.Lobby_Dist, function(v)
    Config.Lobby_Dist = v
end)

CreateSection(TabVisuals, "GUN DROP")
CreateToggle(TabVisuals, "Show Highlight", Config.Gun_Fill, function(v)
    Config.Gun_Fill = v
end)
CreateToggle(TabVisuals, "Show Outline", Config.Gun_Outline, function(v)
    Config.Gun_Outline = v
end)
CreateToggle(TabVisuals, "Show Name", Config.Gun_Name, function(v)
    Config.Gun_Name = v
end)
CreateToggle(TabVisuals, "Show Distance", Config.Gun_Dist, function(v)
    Config.Gun_Dist = v
end)
CreateToggle(TabVisuals, "Show Tracer", Config.Gun_Tracer, function(v)
    Config.Gun_Tracer = v
end)

local TabLegit = CreateTab("LEGIT / PLAYER")
CreateSection(TabLegit, "ANTI SILENT AIM (DESYNC)")
CreateToggle(TabLegit, "Enable Anti Silent Aim", Config.AntiSilentAim, function(v)
    Config.AntiSilentAim = v
end)

CreateSection(TabLegit, "FAKE LAG / FAKE POS")
CreateToggle(TabLegit, "Enable Desync", Config.DesyncEnabled, function(v)
    Config.DesyncEnabled = v
    if not v and desync_on then
        ToggleDesync()
    end
end)

CreateToggle(TabLegit, "Show Desync Button", Config.ShowDesyncBtn, function(v)
    Config.ShowDesyncBtn = v
end)

CreateButton(TabLegit, "TOGGLE DESYNC", function(btn, frame)
    ToggleDesync()
    if desync_on then
        btn.Text = "DESYNC ACTIVE ✓"
        btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        task.delay(1, function()
            if btn then
                btn.Text = "TOGGLE DESYNC"
                btn.TextColor3 = Theme.Accent
            end
        end)
    else
        btn.Text = "TOGGLE DESYNC"
        btn.TextColor3 = Theme.Accent
    end
end)

CreateSection(TabLegit, "FLING")
CreateButton(TabLegit, "FLING (SHERIFF)", function(btn, frame)
    ToggleFling("Sheriff")
    if Config.FlingSheriff then
        btn.Text = "FLING SHERIFF ✓"
        btn.TextColor3 = Color3.fromRGB(0, 100, 255)
        task.delay(1, function()
            if btn then
                btn.Text = "FLING (SHERIFF)"
                btn.TextColor3 = Theme.Accent
            end
        end)
    else
        btn.Text = "FLING (SHERIFF)"
        btn.TextColor3 = Theme.Accent
    end
end)

CreateButton(TabLegit, "FLING (MURDERER)", function(btn, frame)
    ToggleFling("Murderer")
    if Config.FlingMurderer then
        btn.Text = "FLING MURDERER ✓"
        btn.TextColor3 = Color3.fromRGB(255, 50, 50)
        task.delay(1, function()
            if btn then
                btn.Text = "FLING (MURDERER)"
                btn.TextColor3 = Theme.Accent
            end
        end)
    else
        btn.Text = "FLING (MURDERER)"
        btn.TextColor3 = Theme.Accent
    end
end)

CreateButton(TabLegit, "FLING (HERO)", function(btn, frame)
    ToggleFling("Hero")
    if Config.FlingHero then
        btn.Text = "FLING HERO ✓"
        btn.TextColor3 = Color3.fromRGB(255, 255, 0)
        task.delay(1, function()
            if btn then
                btn.Text = "FLING (HERO)"
                btn.TextColor3 = Theme.Accent
            end
        end)
    else
        btn.Text = "FLING (HERO)"
        btn.TextColor3 = Theme.Accent
    end
end)

CreateButton(TabLegit, "FLING ALL", function(btn, frame)
    ToggleFlingAll()
    if Config.FlingAll then
        btn.Text = "FLING ALL ✓"
        btn.TextColor3 = Color3.fromRGB(255, 0, 255)
        task.delay(1, function()
            if btn then
                btn.Text = "FLING ALL"
                btn.TextColor3 = Theme.Accent
            end
        end)
    else
        btn.Text = "FLING ALL"
        btn.TextColor3 = Theme.Accent
    end
end)

CreateSection(TabLegit, "FLING PLAYER (SELECT)")
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -10, 0, 100)
playerList.BackgroundColor3 = Theme.ItemBG
playerList.Parent = TabLegit
AddCorner(playerList, 6)

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.Parent = playerList

local selectedPlayer = nil

local function updatePlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundColor3 = Theme.InputBG
            btn.Text = plr.Name
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 11
            btn.Parent = playerList
            AddCorner(btn, 4)
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr.Name
                for _, child in ipairs(playerList:GetChildren()) do
                    if child:IsA("TextButton") then
                        if child.Text == selectedPlayer then
                            child.BackgroundColor3 = Theme.Accent
                            child.TextColor3 = Color3.new(1,1,1)
                        else
                            child.BackgroundColor3 = Theme.InputBG
                            child.TextColor3 = Theme.Text
                        end
                    end
                end
            end)
        end
    end
end

updatePlayerList()

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

CreateButton(TabLegit, "FLING SELECTED PLAYER", function(btn, frame)
    if selectedPlayer then
        ToggleFlingPlayer(selectedPlayer)
        if flingActive and flingTargetPlayer and flingTargetPlayer.Name == selectedPlayer then
            btn.Text = "FLING " .. selectedPlayer .. " ✓"
            btn.TextColor3 = Color3.fromRGB(0, 255, 255)
            task.delay(1, function()
                if btn then
                    btn.Text = "FLING SELECTED PLAYER"
                    btn.TextColor3 = Theme.Accent
                end
            end)
        else
            btn.Text = "FLING SELECTED PLAYER"
            btn.TextColor3 = Theme.Accent
        end
    else
        MatzzNotify("FLING", "Select a player first!", 3)
    end
end)

CreateSection(TabLegit, "PROTECTION")
CreateToggle(TabLegit, "Anti-Fling", Config.AntiFling, function(v)
    Config.AntiFling = v
end)

CreateToggle(TabLegit, "Seconds Life (Godmode)", Config.SecondLife, function(v)
    Config.SecondLife = v
    ApplySecondLife(v)
end)

CreateSection(TabLegit, "PRANK BOMB")
CreateToggle(TabLegit, "Auto Prank Bomb", Config.AutoPrankBomb, function(v)
    Config.AutoPrankBomb = v
    ApplyAutoPrankBomb(v)
end)

CreateSection(TabLegit, "AUTO GRAB")
CreateToggle(TabLegit, "Grab Gun", Config.AutoGrabGun, function(v)
    Config.AutoGrabGun = v
end)
CreateToggle(TabLegit, "Show Grab Floating Btn", Config.ShowGrabBtn, function(v)
    Config.ShowGrabBtn = v
end)
CreateButton(TabLegit, "FORCE GRAB GUN (Click)", function()
    PerformGrabGun()
end)
CreateInput(TabLegit, "Grab Dist", "Ex: 15", tostring(Config.GrabDistance), function(txt)
    Config.GrabDistance = tonumber(txt) or 15
end)

CreateSection(TabLegit, "TELEPORT")
CreateButton(TabLegit, "TP TO MAP", function()
    PlayClickSound()
    
    local function getMap()
        for _, o in ipairs(workspace:GetChildren()) do
            if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
                return o
            end
        end
        return nil
    end

    local map = getMap()
    if not map then 
        MatzzNotify("TELEPORT", "Map not found!", 3)
        return 
    end

    local spawns = map:FindFirstChild("Spawns")
    if not spawns then 
        MatzzNotify("TELEPORT", "No spawns found!", 3)
        return 
    end

    local spawnPoints = spawns:GetChildren()
    if #spawnPoints == 0 then 
        MatzzNotify("TELEPORT", "No spawn points!", 3)
        return 
    end

    local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:MoveTo(randomSpawn.Position)
        MatzzNotify("TELEPORT", "Teleported to map!", 3)
    end
end)

CreateSection(TabLegit, "GHOST / INVISIBLE")
CreateToggle(TabLegit, "Show Ghost Button", Config.ShowInvisBtn, function(v)
    Config.ShowInvisBtn = v
end)

CreateSection(TabLegit, "MOVEMENT MODS")
CreateToggle(TabLegit, "Enable WalkSpeed", Config.WalkSpeedEnabled, function(v)
    Config.WalkSpeedEnabled = v
end)
CreateInput(TabLegit, "Speed (Def: 16)", "Ex: 24", tostring(Config.WalkSpeedValue), function(txt)
    Config.WalkSpeedValue = tonumber(txt) or 16
end)
CreateToggle(TabLegit, "Enable JumpPower", Config.JumpPowerEnabled, function(v)
    Config.JumpPowerEnabled = v
end)
CreateInput(TabLegit, "Power (Def: 50)", "Ex: 80", tostring(Config.JumpPowerValue), function(txt)
    Config.JumpPowerValue = tonumber(txt) or 50
end)

local TabAutoFarm = CreateTab("AUTO FARM")

CreateSection(TabAutoFarm, "COINS REACH")
CreateToggle(TabAutoFarm, "Coins Reach (4x Size)", Config.CoinsReach, function(v)
    Config.CoinsReach = v
    
    if v then
        coinOrig = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                if not coinOrig[obj] then
                    coinOrig[obj] = obj.Size
                end
                obj.Size = coinOrig[obj] * 4
            end
        end
        
        coinReachConn = Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                if not coinOrig[obj] then
                    coinOrig[obj] = obj.Size
                end
                obj.Size = coinOrig[obj] * 4
            end
        end)
    else
        for obj, originalSize in pairs(coinOrig) do
            if obj and obj.Parent then
                obj.Size = originalSize
            end
        end
        
        if coinReachConn then
            coinReachConn:Disconnect()
            coinReachConn = nil
        end
        
        coinOrig = {}
    end
end)

CreateSection(TabAutoFarm, "AUTO FARM COINS")
CreateToggle(TabAutoFarm, "Auto Farm Coins", Config.AutoFarmCoins, function(v)
    Config.AutoFarmCoins = v
    
    if v then
        autoFarmCoinsRunning = true
        autoFarmCoinsThread = task.spawn(function()
            AutoFarmCoinsFunc()
        end)
    else
        autoFarmCoinsRunning = false
        if autoFarmCoinsThread then
            task.cancel(autoFarmCoinsThread)
            autoFarmCoinsThread = nil
        end
    end
end)

CreateButton(TabAutoFarm, "FORCE STOP FARM (if dead)", function(btn, frame)
    PlayClickSound()
    autoFarmCoinsRunning = false
    Config.AutoFarmCoins = false
    
    if autoFarmCoinsThread then
        task.cancel(autoFarmCoinsThread)
        autoFarmCoinsThread = nil
    end
    
    btn.Text = "STOPPED!"
    btn.TextColor3 = Color3.fromRGB(255, 50, 50)
    
    task.delay(1, function()
        if btn then
            btn.Text = "FORCE STOP FARM (if dead)"
            btn.TextColor3 = Theme.Accent
        end
    end)
end)

local TabUpdates = CreateTab("UPDATES")
CreateSection(TabUpdates, "📅 ÚLTIMAS ATUALIZAÇÕES")

local UpdatesFrame = Instance.new("Frame")
UpdatesFrame.Size = UDim2.new(1, -10, 0, 200)
UpdatesFrame.BackgroundColor3 = Theme.ItemBG
UpdatesFrame.Parent = TabUpdates
AddCorner(UpdatesFrame, 8)

local UpdatesLayout = Instance.new("Frame")
UpdatesLayout.Size = UDim2.new(1, 0, 1, 0)
UpdatesLayout.BackgroundTransparency = 1
UpdatesLayout.Parent = UpdatesFrame

local VersionTitle = Instance.new("TextLabel")
VersionTitle.Size = UDim2.new(1, -10, 0, 30)
VersionTitle.Position = UDim2.new(0, 10, 0, 5)
VersionTitle.BackgroundTransparency = 1
VersionTitle.Text = "🔄 VERSÃO 3.9 - MATZZ MM2🇧🇷"
VersionTitle.TextColor3 = Theme.Accent
VersionTitle.Font = Enum.Font.GothamBlack
VersionTitle.TextSize = 14
VersionTitle.TextXAlignment = Enum.TextXAlignment.Left
VersionTitle.Parent = UpdatesLayout

local UpdateDate = Instance.new("TextLabel")
UpdateDate.Size = UDim2.new(1, -10, 0, 20)
UpdateDate.Position = UDim2.new(0, 10, 0, 35)
UpdateDate.BackgroundTransparency = 1
UpdateDate.Text = "📅 Data: 14 de fevereiro 2026"
UpdateDate.TextColor3 = Theme.TextDim
UpdateDate.Font = Enum.Font.GothamSemibold
UpdateDate.TextSize = 11
UpdateDate.TextXAlignment = Enum.TextXAlignment.Left
UpdateDate.Parent = UpdatesLayout

local ChangesFrame = Instance.new("Frame")
ChangesFrame.Size = UDim2.new(1, -20, 0, 140)
ChangesFrame.Position = UDim2.new(0, 10, 0, 60)
ChangesFrame.BackgroundTransparency = 1
ChangesFrame.Parent = UpdatesLayout

local ChangesText = Instance.new("TextLabel")
ChangesText.Size = UDim2.new(1, 0, 1, 0)
ChangesText.BackgroundTransparency = 1
ChangesText.Text = "✅ NOVAS FUNÇÕES:\n• 🖼️ Botão com imagem personalizada\n• 🔪 Knife Silent Aim\n• 🎯 Gun Silent Aim\n• 🌀 FLING atualizado (com timeout)\n• ❤️ Second Life (Godmode)\n• 🔝 Notificações sempre no topo\n• 🎯 Tracer para Gun Drop\n• 👻 Tracer para Ghost Part (nativo)\n• 🔄 Matzz Aim desequipa arma\n• 💣 Auto Prank Bomb\n• 🛡️ Anti Silent Aim (Desync alternativo)\n\n🔄 MELHORIAS:\n• ⚡ Otimização geral\n• 🔧 Correção de bugs\n• 🎨 Interface melhorada\n\n⚠️ AVISO:\n• Gun Silent Aim: 100% foco no Murderer\n• Knife Silent Aim: Foco em todos (ignora paredes, mira no centro da tela)\n• Anti Silent Aim ativável por tecla (padrão X) ou pelo menu."
ChangesText.TextColor3 = Theme.Text
ChangesText.Font = Enum.Font.GothamSemibold
ChangesText.TextSize = 11
ChangesText.TextXAlignment = Enum.TextXAlignment.Left
ChangesText.TextYAlignment = Enum.TextYAlignment.Top
ChangesText.TextWrapped = true
ChangesText.Parent = ChangesFrame

local TabSettings = CreateTab("SETTINGS")

CreateSection(TabSettings, "GAMEPAD CONTROLS")
CreateToggle(TabSettings, "Enable Gamepad Controls", Config.GamepadEnabled, function(v)
    Config.GamepadEnabled = v
    SetupGamepadControls()
end)

CreateSection(TabSettings, "KEYBINDS")
CreateKeybind(TabSettings, "Silent Aim (RT)", Config.SilentAimKey, function(key)
    Config.SilentAimKey = key
    SetupGamepadControls()
end)

CreateKeybind(TabSettings, "Invisible (Y)", Config.InvisibleKey, function(key)
    Config.InvisibleKey = key
    SetupGamepadControls()
end)

CreateKeybind(TabSettings, "Grab Gun (B)", Config.GrabGunKey, function(key)
    Config.GrabGunKey = key
    SetupGamepadControls()
end)

CreateKeybind(TabSettings, "Anti Silent Aim Key", Config.AntiSilentAimKey, function(key)
    Config.AntiSilentAimKey = key
end)

CreateSection(TabSettings, "COINS FUNCTIONS")
CreateToggle(TabSettings, "Coins Remove", Config.CoinsRemove, function(v)
    Config.CoinsRemove = v
    ApplyCoinsRemove(v)
end)

CreateToggle(TabSettings, "Optimizer Coins", Config.OptimizerCoins, function(v)
    Config.OptimizerCoins = v
    ApplyOptimizerCoins(v)
end)

CreateSection(TabSettings, "VISUAL SETTINGS")
CreateToggle(TabSettings, "Instant Role Reveal", Config.InstantRole, function(v)
    Config.InstantRole = v
end)
CreateToggle(TabSettings, "Anti Lag (Remove Shadows)", Config.AntiLag, function(v)
    Config.AntiLag = v
    if v then
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.ShadowColor = Color3.new(0,0,0)
    else
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 1
    end
end)

CreateSection(TabSettings, "GAME MISC")

CreateToggle(TabSettings, "Disable Footstep", Config.DisableFootstep, function(v)
    Config.DisableFootstep = v
    ApplyDisableFootstep(v)
end)

CreateToggle(TabSettings, "Show Round Timer", Config.ShowRoundTimer, function(v)
    Config.ShowRoundTimer = v
    ApplyShowRoundTimer(v)
end)

CreateSection(TabSettings, "CUSTOM THEME")

local themeNames = {"Original", "Red", "Blue", "Verde", "Purple", "Yellow", "Branco", "Preto"}

FirstRow = Instance.new("Frame")
FirstRow.Size = UDim2.new(1, -10, 0, 32)
FirstRow.BackgroundTransparency = 1
FirstRow.Parent = TabSettings

for i = 1, 3 do
    local themeName = themeNames[i]
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.32, -5, 1, 0)
    Btn.Position = UDim2.new((i-1) * 0.33, 0, 0, 0)
    Btn.BackgroundColor3 = Theme.ItemBG
    Btn.Text = themeName
    Btn.TextColor3 = Config.CustomTheme == themeName and Theme.Accent or Theme.TextDim
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = FirstRow
    AddCorner(Btn, 4)
    
    Btn.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetTheme(themeName)
    end)
end

SecondRow = Instance.new("Frame")
SecondRow.Size = UDim2.new(1, -10, 0, 32)
SecondRow.Position = UDim2.new(0, 0, 0, 40)
SecondRow.BackgroundTransparency = 1
SecondRow.Parent = TabSettings

for i = 4, 6 do
    local themeName = themeNames[i]
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.32, -5, 1, 0)
    Btn.Position = UDim2.new((i-4) * 0.33, 0, 0, 0)
    Btn.BackgroundColor3 = Theme.ItemBG
    Btn.Text = themeName
    Btn.TextColor3 = Config.CustomTheme == themeName and Theme.Accent or Theme.TextDim
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = SecondRow
    AddCorner(Btn, 4)
    
    Btn.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetTheme(themeName)
    end)
end

ThirdRow = Instance.new("Frame")
ThirdRow.Size = UDim2.new(1, -10, 0, 32)
ThirdRow.Position = UDim2.new(0, 0, 0, 80)
ThirdRow.BackgroundTransparency = 1
ThirdRow.Parent = TabSettings

for i = 7, 8 do
    local themeName = themeNames[i]
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.32, -5, 1, 0)
    Btn.Position = UDim2.new((i-7) * 0.33, 0, 0, 0)
    Btn.BackgroundColor3 = Theme.ItemBG
    Btn.Text = themeName
    Btn.TextColor3 = Config.CustomTheme == themeName and Theme.Accent or Theme.TextDim
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = ThirdRow
    AddCorner(Btn, 4)
    
    Btn.MouseButton1Click:Connect(function()
        PlayClickSound()
        SetTheme(themeName)
    end)
end

CreateSection(TabSettings, "CONFIGURATION")

local function SaveConfig(btnLabel, btnFrame)
    if writefile then
        Config.CustomTheme = Config.CustomTheme or "Original"
        
        Config.GuiPositions = {}
        
        if MainFrame and MainFrame.Visible then
            Config.GuiPositions["MainFrame"] = {
                MainFrame.Position.X.Scale,
                MainFrame.Position.X.Offset,
                MainFrame.Position.Y.Scale,
                MainFrame.Position.Y.Offset
            }
        end
        
        if ToggleButton then
            Config.GuiPositions["ToggleButton"] = {
                ToggleButton.Position.X.Scale,
                ToggleButton.Position.X.Offset,
                ToggleButton.Position.Y.Scale,
                ToggleButton.Position.Y.Offset
            }
        end
        
        if ShootButton then
            Config.GuiPositions["ShootButton"] = {
                ShootButton.Position.X.Scale,
                ShootButton.Position.X.Offset,
                ShootButton.Position.Y.Scale,
                ShootButton.Position.Y.Offset
            }
        end
        
        if GrabFrame then
            Config.GuiPositions["GrabFrame"] = {
                GrabFrame.Position.X.Scale,
                GrabFrame.Position.X.Offset,
                GrabFrame.Position.Y.Scale,
                GrabFrame.Position.Y.Offset
            }
        end
        
        if InvisFrame then
            Config.GuiPositions["InvisFrame"] = {
                InvisFrame.Position.X.Scale,
                InvisFrame.Position.X.Offset,
                InvisFrame.Position.Y.Scale,
                InvisFrame.Position.Y.Offset
            }
        end
        
        if DesyncFrame then
            Config.GuiPositions["DesyncFrame"] = {
                DesyncFrame.Position.X.Scale,
                DesyncFrame.Position.X.Offset,
                DesyncFrame.Position.Y.Scale,
                DesyncFrame.Position.Y.Offset
            }
        end
        
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(Config)
        end)
        
        if success then
            pcall(function()
                writefile(ConfigFileName, encoded)
            end)
            
            ApplyThemeToGUI()
            
            if btnLabel then
                btnLabel.Text = "SAVED!"
                btnLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                
                task.delay(1, function()
                    if btnLabel then
                        btnLabel.Text = "SAVE CONFIGURATION"
                        btnLabel.TextColor3 = Theme.Accent
                    end
                end)
            end
        else
            if btnLabel then
                btnLabel.Text = "ERROR!"
                btnLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                task.delay(1, function()
                    btnLabel.Text = "SAVE CONFIGURATION"
                    btnLabel.TextColor3 = Theme.Accent
                end)
            end
            MatzzNotify("ERROR", "Failed to save configuration!", 3)
        end
    else
        MatzzNotify("ERROR", "writefile not available!", 3)
    end
end

CreateButton(TabSettings, "SAVE CONFIGURATION", function(btn, frame)
    SaveConfig(btn, frame)
end)

CreateButton(TabSettings, "RESET SETTINGS", function(btn, frame)
    Config = DeepCopy(DefaultConfig)
    Config.GuiPositions = {}
    SetTheme("Original")
    
    if writefile then
        pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(Config))
        end)
    end
    
    btn.Text = "RESET DONE!"
    btn.TextColor3 = Color3.fromRGB(0, 255, 100)
    
    task.delay(1, function()
        btn.Text = "RESET SETTINGS"
        btn.TextColor3 = Theme.Accent
        MatzzNotify("RESET", "Settings reset!", 5)
    end)
end)

function ToggleInvis()
    PlayClickSound()
    InvisActive = not InvisActive
    
    if InvisActive then
        InvisBtn.Text = "ACTIVE"
        InvisBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
        InvisStroke.Color = Color3.fromRGB(0, 255, 100)
        
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0 then
                    v.Transparency = 0.5
                end
            end
        end
    else
        InvisBtn.Text = "INVISIBLE"
        InvisBtn.TextColor3 = Theme.Ghost
        InvisStroke.Color = Theme.Ghost
        
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0.5 then
                    v.Transparency = 0
                end
            end
        end
    end
end

InvisBtn.MouseButton1Click:Connect(ToggleInvis)

RunService.Heartbeat:Connect(function()
    if InvisActive then
        local Char = LocalPlayer.Character
        if Char then
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChild("Humanoid")
            
            if Root and Hum then
                local oldCF = Root.CFrame
                local oldCamOffset = Hum.CameraOffset
                local invisCF = oldCF * CFrame.new(0, -200000, 0)
                
                Root.CFrame = invisCF
                Hum.CameraOffset = invisCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
                
                RunService.RenderStepped:Wait()
                
                Root.CFrame = oldCF
                Hum.CameraOffset = oldCamOffset
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    InvisActive = false
    InvisBtn.Text = "INVISIBLE"
    InvisBtn.TextColor3 = Theme.Ghost
    InvisStroke.Color = Theme.Ghost
    
    if Config.AutoFarmCoins then
        autoFarmCoinsRunning = false
        Config.AutoFarmCoins = false
        
        if autoFarmCoinsThread then
            task.cancel(autoFarmCoinsThread)
            autoFarmCoinsThread = nil
        end
    end
end)

task.spawn(function()
    while true do
        if GrabFrame and GrabFrame.Visible then
            local t1 = TweenService:Create(GrabStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Transparency = 0.4})
            t1:Play()
            t1.Completed:Wait()
            
            local t2 = TweenService:Create(GrabStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Transparency = 0})
            t2:Play()
            t2.Completed:Wait()
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if InvisFrame and InvisFrame.Visible and not InvisActive then
            local t1 = TweenService:Create(InvisStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.4})
            t1:Play()
            t1.Completed:Wait()
            
            local t2 = TweenService:Create(InvisStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0})
            t2:Play()
            t2.Completed:Wait()
        elseif InvisActive then
            InvisStroke.Transparency = 0
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if DesyncFrame and DesyncFrame.Visible and not desync_on then
            local t1 = TweenService:Create(DesyncStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.4})
            t1:Play()
            t1.Completed:Wait()
            
            local t2 = TweenService:Create(DesyncStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0})
            t2:Play()
            t2.Completed:Wait()
        elseif desync_on then
            DesyncStroke.Transparency = 0
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

local function LoadGuiPositions()
    if Config.GuiPositions then
        local function SetPos(uiObj, name)
            if uiObj and Config.GuiPositions[name] then
                local p = Config.GuiPositions[name]
                if #p >= 4 then
                    uiObj.Position = UDim2.new(p[1], p[2], p[3], p[4])
                end
            end
        end
        
        SetPos(MainFrame, "MainFrame")
        SetPos(ToggleButton, "ToggleButton")
        SetPos(ShootButton, "ShootButton")
        SetPos(GrabFrame, "GrabFrame")
        SetPos(InvisFrame, "InvisFrame")
        SetPos(DesyncFrame, "DesyncFrame")
    end
end

if tabs[1] then
    tabs[1].Frame.Visible = true
    tabs[1].Btn.TextColor3 = Theme.Text
    tabs[1].Btn.BackgroundColor3 = Theme.AccentDark
end

MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 400, 0, 320)}):Play()

if Config.AntiLag then
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.ShadowColor = Color3.new(0,0,0)
end

if Config.CoinsRemove then
    ApplyCoinsRemove(true)
end

if Config.OptimizerCoins then
    ApplyOptimizerCoins(true)
end

if Config.DisableFootstep then
    ApplyDisableFootstep(true)
end

if Config.ShowRoundTimer then
    ApplyShowRoundTimer(true)
end

if Config.SecondLife then
    ApplySecondLife(true)
end

if Config.AutoPrankBomb then
    ApplyAutoPrankBomb(true)
end

task.wait(0.5)
ApplyThemeToGUI()

task.wait(0.1)
LoadGuiPositions()

task.wait(0.1)
ApplyThemeToGUI()

if Config.CoinsReach then
    coinOrig = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
            if not coinOrig[obj] then
                coinOrig[obj] = obj.Size
            end
            obj.Size = coinOrig[obj] * 4
        end
    end
    
    coinReachConn = Workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
            if not coinOrig[obj] then
                coinOrig[obj] = obj.Size
            end
            obj.Size = coinOrig[obj] * 4
        end
    end)
end

SetupGamepadControls()

task.spawn(function()
    task.wait(0.5)
    
    if ShootButton and ShootButton.Position == UDim2.new(0.65, 0, 0.6, 0) then
        LoadGuiPositions()
    end
    
    ApplyThemeToGUI()
end)

task.wait(1)
MatzzNotify("MATZZ HUB MM2 V6.7",
    "✅ Script carregado com sucesso!\n\n" ..
    "🎯 NOVAS FUNÇÕES:\n" ..
    "• 🖼️ Botão com imagem personalizada\n" ..
    "• 🔪 Knife Silent Aim\n" ..
    "• 🎯 Gun Silent Aim\n" ..
    "• 🌀 Fling atualizado (com timeout)\n" ..
    "• ❤️ Second Life (Godmode)\n" ..
    "• 🔝 Notificações sempre no topo\n" ..
    "• 🎯 Tracer para Gun Drop\n" ..
    "• 👻 Tracer para Ghost Part (nativo)\n" ..
    "• 🔄 Matzz Aim desequipa tool\n" ..
    "• 💣 Auto Prank Bomb\n" ..
    "• 📍 TP Map corrigido\n" ..
    "• 👣 Disable Footstep\n" ..
    "• ⏰ Show Round Timer\n" ..
    "• 🛡️ Anti Silent Aim (Desync alternativo)\n\n" ..
    "⚠️ IMPORTANTE:\n" ..
    "• Gun Silent Aim: 100% foco no Murderer\n" ..
    "• Knife Silent Aim: Foco em todos (ignora paredes, mira no centro da tela)\n" ..
    "• Anti Silent Aim ativável por tecla (padrão X) ou pelo menu.\n\n" ..
    "🎮 Controles funcionando!", 15)
