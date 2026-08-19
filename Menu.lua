--!strict

-- Configuration
local CONFIG = {
    INVISIBILITY_POSITION = Vector3.new(0, 20, 0),
    DEFAULT_SPEED = 16,
    BOOSTED_SPEED = 48,
    BACKGROUND_COLOR = Color3.fromRGB(11, 11, 13),
    ACCENT_COLOR = Color3.fromRGB(24, 24, 28),
    PRIMARY_COLOR = Color3.fromRGB(0, 160, 255),
    SUCCESS_COLOR = Color3.fromRGB(0, 255, 140),
    DANGER_COLOR = Color3.fromRGB(255, 55, 55),
    TEXT_COLOR = Color3.fromRGB(245, 245, 245),
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

-- Variables
local player = Players.LocalPlayer
local playerState = {
    isInvisible = false,
    isSpeedBoosted = false,
    isNoclip = false,
    isInfJump = false,
    isFlying = false, -- Reemplazado FC por vuelo
    walkSpeed = CONFIG.BOOSTED_SPEED,
    originalSpeed = CONFIG.DEFAULT_SPEED,
    lastJumpTime = 0,
}

-- ✅ SISTEMA DE VUELO NUEVO (PC + MÓVIL)
local FLYING = false
local QEfly = true
local iyflyspeed = 1 -- Velocidad base
local flyKeyDown, flyKeyUp
local IsOnMobile = UserInputService.TouchEnabled
local velocityHandlerName = "Fly_" .. math.random(100000, 999999)
local gyroHandlerName = "Gyro_" .. math.random(100000, 999999)
local mfly1, mfly2

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

function sFLY()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        repeat task.wait() humanoid = char:FindFirstChildOfClass("Humanoid") until humanoid
    end
    if flyKeyDown or flyKeyUp then
        flyKeyDown:Disconnect()
        flyKeyUp:Disconnect()
    end
    local T = getRoot(char)
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0
    local BG = Instance.new('BodyGyro')
    local BV = Instance.new('BodyVelocity')
    BG.P = 9e4
    BG.Parent = T
    BV.Parent = T
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.CFrame = T.CFrame
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FLYING = true
    task.spawn(function()
        repeat task.wait()
            local camera = workspace.CurrentCamera
            humanoid.PlatformStand = true
            local hayMov = CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0
            SPEED = hayMov and 50 or 0
            if hayMov then
                BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - camera.CFrame.Position)) * SPEED
                lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
            elseif SPEED ~= 0 then
                BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position) - camera.CFrame.Position)) * SPEED
            else
                BV.Velocity = Vector3.new(0, 0, 0)
            end
            BG.CFrame = camera.CFrame
        until not FLYING
        CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        SPEED = 0
        BG:Destroy()
        BV:Destroy()
        if humanoid then humanoid.PlatformStand = false end
    end)
    flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local vel = iyflyspeed
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = vel
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -vel
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -vel
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = vel
        elseif input.KeyCode == Enum.KeyCode.E and QEfly then CONTROL.Q = vel * 2
        elseif input.KeyCode == Enum.KeyCode.Q and QEfly then CONTROL.E = -vel * 2
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)
    flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
        elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
        elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
        end
    end)
end

function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    if mfly1 then mfly1:Disconnect() mfly1 = nil end
    if mfly2 then mfly2:Disconnect() mfly2 = nil end
    local char = player.Character
    if char then
        local root = getRoot(char)
        if root then
            if root:FindFirstChild(velocityHandlerName) then root:FindFirstChild(velocityHandlerName):Destroy() end
            if root:FindFirstChild(gyroHandlerName) then root:FindFirstChild(gyroHandlerName):Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

function mobilefly()
    NOFLY()
    FLYING = true
    local char = player.Character or player.CharacterAdded:Wait()
    local root = getRoot(char)
    local camera = workspace.CurrentCamera
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)
    local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule", 10):WaitForChild("ControlModule", 10))
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero
    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50
    mfly1 = player.CharacterAdded:Connect(function()
        local newChar = player.Character
        local newRoot = getRoot(newChar)
        local newBv = Instance.new("BodyVelocity")
        newBv.Name = velocityHandlerName
        newBv.Parent = newRoot
        newBv.MaxForce = v3inf
        newBv.Velocity = v3zero
        local newBg = Instance.new("BodyGyro")
        newBg.Name = gyroHandlerName
        newBg.Parent = newRoot
        newBg.MaxTorque = v3inf
        newBg.P = 1000
        newBg.D = 50
    end)
    mfly2 = RunService.RenderStepped:Connect(function()
        if not FLYING then return end
        root = getRoot(player.Character)
        camera = workspace.CurrentCamera
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)
            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            hum.PlatformStand = true
            GyroHandler.CFrame = camera.CFrame
            VelocityHandler.Velocity = v3zero
            local direction = controlModule:GetMoveVector()
            local speed = iyflyspeed
            if direction.X ~= 0 then VelocityHandler.Velocity += camera.CFrame.RightVector * (direction.X * speed * 50) end
            if direction.Z ~= 0 then VelocityHandler.Velocity -= camera.CFrame.LookVector * (direction.Z * speed * 50) end
        end
    end)
end

function ActivarVuelo()
    if IsOnMobile then
        mobilefly()
    else
        sFLY()
    end
end

-- GUI Elements
local screenGui: ScreenGui
local mainFrame: Frame
local toggleButton: TextButton
local speedButton: TextButton
local noclipButton: TextButton
local infJumpButton: TextButton
local flyButton: TextButton -- Botón de vuelo
local closeButton: TextButton
local statusLabel: TextLabel 
local statusCircle: Frame
local speedValueBox: TextBox
local flyValueBox: TextBox -- Caja de velocidad de vuelo

-- Utility Functions
local function setCharacterTransparency(character: Model, transparency: number): ()
    for _, descendant in character:GetDescendants() do
        if descendant:IsA("BasePart") or descendant:IsA("Decal") then
            descendant.Transparency = transparency
        end
    end
end

local function getHumanoid(): Humanoid?
    local character = player.Character
    return character and character:FindFirstChild("Humanoid") :: Humanoid?
end

local function updateStatusUI()
    if not statusLabel or not statusCircle then return end
    if playerState.isInvisible then
        statusLabel.Text = "SYSTEM: ACTIVE"
        TweenService:Create(statusCircle, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.SUCCESS_COLOR}):Play()
        local stroke = statusCircle:FindFirstChildOfClass("UIStroke")
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.3), {Color = CONFIG.SUCCESS_COLOR, Transparency = 0.4}):Play()
        end
    else
        statusLabel.Text = "SYSTEM: INACTIVE"
        TweenService:Create(statusCircle, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.DANGER_COLOR}):Play()
        local stroke = statusCircle:FindFirstChildOfClass("UIStroke")
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(0.3), {Color = CONFIG.DANGER_COLOR, Transparency = 0.5}):Play()
        end
    end
end

-- Invisibility
local function toggleInvisibility()
    if not player.Character then return end
    playerState.isInvisible = not playerState.isInvisible
    if playerState.isInvisible then
        local hrp = getRoot(player.Character)
        if not hrp then return end
        local savedPosition = hrp.CFrame
        player.Character:MoveTo(CONFIG.INVISIBILITY_POSITION)
        task.wait(0.15)
        local seat = Instance.new("Seat")
        seat.Name = "InvisChair"
        seat.Anchored = false
        seat.CanCollide = false
        seat.Transparency = 1
        seat.Position = CONFIG.INVISIBILITY_POSITION
        seat.Parent = workspace
        local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
        if torso then
            local weld = Instance.new("Weld")
            weld.Part0 = seat
            weld.Part1 = torso
            weld.Parent = seat
        end
        task.wait()
        seat.CFrame = savedPosition
        setCharacterTransparency(player.Character, 0.5)
        toggleButton.Text = "BECOME VISIBLE"
    else
        local invisChair = workspace:FindFirstChild("InvisChair")
        if invisChair then invisChair:Destroy() end
        if player.Character then setCharacterTransparency(player.Character, 0) end
        toggleButton.Text = "BECOME INVISIBLE"
    end
    updateStatusUI()
end

-- Speed Boost
local function applySpeed()
    local humanoid = getHumanoid()
    if not humanoid then return end
    if playerState.isSpeedBoosted and not playerState.isFlying then
        humanoid.WalkSpeed = playerState.walkSpeed
    elseif not playerState.isFlying then
        humanoid.WalkSpeed = playerState.originalSpeed
    end
end

local function toggleSpeedBoost()
    playerState.isSpeedBoosted = not playerState.isSpeedBoosted
    applySpeed()
    if playerState.isSpeedBoosted then
        speedButton.Text = "SPEED: ON"
        TweenService:Create(speedButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.SUCCESS_COLOR}):Play()
    else
        speedButton.Text = "SPEED BOOST"
        TweenService:Create(speedButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.TEXT_COLOR}):Play()
    end
end

-- Noclip
local function toggleNoclip()
    playerState.isNoclip = not playerState.isNoclip
    if playerState.isNoclip then
        noclipButton.Text = "NOCLIP: ON"
        TweenService:Create(noclipButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.SUCCESS_COLOR}):Play()
    else
        noclipButton.Text = "NOCLIP"
        TweenService:Create(noclipButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.TEXT_COLOR}):Play()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Infinite Jump
local function toggleInfJump()
    playerState.isInfJump = not playerState.isInfJump
    if playerState.isInfJump then
        infJumpButton.Text = "INF JUMP: ON"
        TweenService:Create(infJumpButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.SUCCESS_COLOR}):Play()
    else
        infJumpButton.Text = "INFINITE JUMP"
        TweenService:Create(infJumpButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.TEXT_COLOR}):Play()
    end
end

-- ✅ FUNCIÓN PARA ACTIVAR/DESACTIVAR VUELO
local function toggleFly()
    playerState.isFlying = not playerState.isFlying
    if playerState.isFlying then
        ActivarVuelo()
        flyButton.Text = "FLY: ON"
        TweenService:Create(flyButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.SUCCESS_COLOR}):Play()
    else
        NOFLY()
        flyButton.Text = "FLY"
        TweenService:Create(flyButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.TEXT_COLOR}):Play()
        applySpeed()
    end
end

-- AntiPausa
local function antiPausa()
    pcall(function()
        StarterGui:SetCore("GameplayPaused", false)
        StarterGui:SetCore("ResetButtonCallback", function() end)
    end)
end

RunService.Heartbeat:Connect(antiPausa)

-- GUI Creation
local function createGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Ziaa_FE_Refined"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -100, 0, -350)
    mainFrame.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    local mStroke = Instance.new("UIStroke", mainFrame)
    mStroke.Color = Color3.fromRGB(255, 255, 255)
    mStroke.Transparency = 0.94
    mStroke.Thickness = 1

    TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -100, 0.5, -210)}):Play()

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.Text = "FE FULL TOOLS"
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = CONFIG.TEXT_COLOR
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.Parent = mainFrame

    local function style(btn: TextButton)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", btn)
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = Color3.fromRGB(255, 255, 255)
        s.Transparency = 0.9

        btn.MouseEnter:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.5, Color = CONFIG.PRIMARY_COLOR}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.9, Color = Color3.fromRGB(255, 255, 255)}):Play()
        end)
    end

    local y = 50

    toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -28, 0, 42)
    toggleButton.Position = UDim2.new(0, 14, 0, y)
    toggleButton.Text = "BECOME INVISIBLE"
    toggleButton.BackgroundColor3 = CONFIG.ACCENT_COLOR
    toggleButton.TextColor3 = CONFIG.TEXT_COLOR
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 10
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = mainFrame
    style(toggleButton)
    y += 50

    local speedFrame = Instance.new("Frame", mainFrame)
    speedFrame.Size = UDim2.new(1, -28, 0, 42)
    speedFrame.Position = UDim2.new(0, 14, 0, y)
    speedFrame.BackgroundTransparency = 1

    speedButton = Instance.new("TextButton", speedFrame)
    speedButton.Size = UDim2.new(0.6, -5, 1, 0)
    speedButton.Text = "SPEED BOOST"
    speedButton.BackgroundColor3 = CONFIG.ACCENT_COLOR
    speedButton.TextColor3 = CONFIG.TEXT_COLOR
    speedButton.Font = Enum.Font.GothamBold
    speedButton.TextSize = 10
    speedButton.AutoButtonColor = false
    style(speedButton)

    speedValueBox = Instance.new("TextBox", speedFrame)
    speedValueBox.Size = UDim2.new(0.4, -5, 1, 0)
    speedValueBox.Position = UDim2.new(0.6, 5, 0, 0)
    speedValueBox.Text = tostring(playerState.walkSpeed)
    speedValueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    speedValueBox.TextColor3 = CONFIG.TEXT_COLOR
    speedValueBox.Font = Enum.Font.GothamBold
    speedValueBox.TextSize = 10
    Instance.new("UICorner", speedValueBox).CornerRadius = UDim.new(0, 10)
    speedValueBox.FocusLost:Connect(function()
        local newSpeed = tonumber(speedValueBox.Text)
        if newSpeed then
            playerState.walkSpeed = math.clamp(newSpeed, 10, 300)
            applySpeed()
        end
        speedValueBox.Text = tostring(playerState.walkSpeed)
    end)
    y += 50

    noclipButton = Instance.new("TextButton")
    noclipButton.Size = UDim2.new(1, -28, 0, 42)
    noclipButton.Position = UDim2.new(0, 14, 0, y)
    noclipButton.Text = "NOCLIP"
    noclipButton.BackgroundColor3 = CONFIG.ACCENT_COLOR
    noclipButton.TextColor3 = CONFIG.TEXT_COLOR
    noclipButton.Font = Enum.Font.GothamBold
    noclipButton.TextSize = 10
    noclipButton.AutoButtonColor = false
    noclipButton.Parent = mainFrame
    style(noclipButton)
    y += 50

    infJumpButton = Instance.new("TextButton")
    infJumpButton.Size = UDim2.new(1, -28, 0, 42)
    infJumpButton.Position = UDim2.new(0, 14, 0, y)
    infJumpButton.Text = "INFINITE JUMP"
    infJumpButton.BackgroundColor3 = CONFIG.ACCENT_COLOR
    infJumpButton.TextColor3 = CONFIG.TEXT_COLOR
    infJumpButton.Font = Enum.Font.GothamBold
    infJumpButton.TextSize = 10
    infJumpButton.AutoButtonColor = false
    infJumpButton.Parent = mainFrame
    style(infJumpButton)
    y += 50

    -- BOTÓN DE VUELO
    local flyFrame = Instance.new("Frame", mainFrame)
    flyFrame.Size = UDim2.new(1, -28, 0, 42)
    flyFrame.Position = UDim2.new(0, 14, 0, y)
    flyFrame.BackgroundTransparency = 1

    flyButton = Instance.new("TextButton", flyFrame)
    flyButton.Size = UDim2.new(0.6, -5, 1, 0)
    flyButton.Text = "FLY"
    flyButton.BackgroundColor3 = CONFIG.ACCENT_COLOR
    flyButton.TextColor3 = CONFIG.TEXT_COLOR
    flyButton.Font = Enum.Font.GothamBold
    flyButton.TextSize = 10
    flyButton.AutoButtonColor = false
    style(flyButton)

    flyValueBox = Instance.new("TextBox", flyFrame)
    flyValueBox.Size = UDim2.new(0.4, -5, 1, 0)
    flyValueBox.Position = UDim2.new(0.6, 5, 0, 0)
    flyValueBox.Text = tostring(iyflyspeed)
    flyValueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    flyValueBox.TextColor3 = CONFIG.TEXT_COLOR
    flyValueBox.Font = Enum.Font.GothamBold
    flyValueBox.TextSize = 10
    Instance.new("UICorner", flyValueBox).CornerRadius = UDim.new(0, 10)
    -- Cambiar velocidad del vuelo
    flyValueBox.FocusLost:Connect(function()
        local newFlySpeed = tonumber(flyValueBox.Text)
        if newFlySpeed and newFlySpeed > 0 then
            iyflyspeed = math.clamp(newFlySpeed, 0.5, 20)
        end
        flyValueBox.Text = tostring(iyflyspeed)
    end)
    y += 50

    statusCircle = Instance.new("Frame")
    statusCircle.Size = UDim2.new(0, 8, 0, 8)
    statusCircle.Position = UDim2.new(0.5, -4, 0, 370)
    statusCircle.BackgroundColor3 = CONFIG.DANGER_COLOR
    statusCircle.Parent = mainFrame
    Instance.new("UICorner", statusCircle).CornerRadius = UDim.new(1, 0)
    local glowCircle = Instance.new("UIStroke", statusCircle)
    glowCircle.Thickness = 2
    glowCircle.Color = CONFIG.DANGER_COLOR
    glowCircle.Transparency = 0.5

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 18)
    statusLabel.Position = UDim2.new(0, 0, 0, 382)
    statusLabel.Text = "SYSTEM: INACTIVE"
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 8
    statusLabel.Parent = mainFrame

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, 0, 0, 15)
    footer.Position = UDim2.new(0, 0, 1, -15)
    footer.Text = "by ziaa on scriptblox"
    footer.BackgroundTransparency = 1
    footer.TextColor3 = Color3.fromRGB(255, 255, 255)
    footer.TextTransparency = 0.5
    footer.Font = Enum.Font.GothamBold
    footer.TextSize = 6
    footer.Parent = mainFrame

    closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -30, 0, 8)
    closeButton.Text = "×"
    closeButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    closeButton.TextColor3 = CONFIG.TEXT_COLOR
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = mainFrame
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    local openButton = Instance.new("TextButton", screenGui)
    openButton.Size = UDim2.new(0, 60, 0, 50)
    openButton.Position = UDim2.new(1, -70, 0, 10)
    openButton.BackgroundColor3 = CONFIG.PRIMARY_COLOR
    openButton.Text = "≡"
    openButton.TextColor3 = Color3.new(1, 1, 1)
    openButton.TextSize = 26
    openButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", openButton).CornerRadius = UDim.new(0.3, 0)
    openButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

-- Iniciar
createGUI()

-- Conexiones de botones
toggleButton.MouseButton1Click:Connect(toggleInvisibility)
speedButton.MouseButton1Click:Connect(toggleSpeedBoost)
noclipButton.MouseButton1Click:Connect(toggleNoclip)
infJumpButton.MouseButton1Click:Connect(toggleInfJump)
flyButton.MouseButton1Click:Connect(toggleFly)

-- Recargar al revivir
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    applySpeed()
    -- Desactivar vuelo al revivir
    if playerState.isFlying then
        NOFLY()
        playerState.isFlying = false
        flyButton.Text = "FLY"
        TweenService:Create(flyButton, TweenInfo.new(0.3), {TextColor3 = CONFIG.TEXT_COLOR}):Play()
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if playerState.isNoclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Salto infinito
UserInputService.JumpRequest:Connect(function()
    if not playerState.isInfJump then return end
    local hum = getHumanoid()
    local now = os.clock()
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and now - playerState.lastJumpTime > 0.1 then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        playerState.lastJumpTime = now
    end
end)

  print("ready")

-- Mantener velocidad
RunService.Heartbeat:Connect(function()
    if playerState.isSpeedBoosted and not playerState.isFlying then
        applySpeed()
    end
end)
