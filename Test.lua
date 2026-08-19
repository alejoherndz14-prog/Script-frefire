-- [OnyxHub] Cargado con éxito para: 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- 🔥 RUTAS DIRECTAS Y CACHÉ (Evita lag de llamadas constantes)
local ws_Raycast = workspace.Raycast
local cam_WTVP = workspace.CurrentCamera.WorldToViewportPoint
local ffc = game.FindFirstChild

local listaJugadores = Players:GetPlayers()
Players.PlayerAdded:Connect(function(p) table.insert(listaJugadores, p) end)
Players.PlayerRemoving:Connect(function(p)
    for i, v in ipairs(listaJugadores) do
        if v == p then 
            table.remove(listaJugadores, i) 
            cleanESP(p) -- Limpieza inmediata
            break 
        end
    end
end)

-- Estado maestro
local mState = {
    tESP = 0, tAura = 0, tStab = 0,
    espAct = false, auraAct = false, stabAct = false
}

-- ==========================================
-- 🛡️ FUNCIÓN MAESTRA DE CONEXIÓN SEGURA
-- ==========================================
local function AstraRequest(ruta)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local success, response = pcall(function()
            return req({
                Url = "https://hub.onyx-scripts.com" .. ruta,
                Method = "GET",
                Headers = {
                    ["Astra-Auth"] = "OnyxHub!",
                    ["User-Agent"] = "Roblox/AstraHub"
                }
            })
        end)
        if success and response then return response.Body end
    end
    return nil
end


task.spawn(function()
    task.wait(15) 
    local myName = HttpService:UrlEncode(player.Name)
    local exec = identifyexecutor and identifyexecutor() or "Desconocido"
    exec = HttpService:UrlEncode(exec)
    
    local plataforma = "Desconocida"
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then plataforma = "Mobile 📱"
    elseif UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then plataforma = "PC 💻"
    elseif UserInputService.GamepadEnabled then plataforma = "Consola 🎮" end
    
    local pais = "Desconocido"
    pcall(function()
        local ipData = game:HttpGet("http://ip-api.com/json/")
        local decoded = HttpService:JSONDecode(ipData)
        if decoded and decoded.country then pais = decoded.country end
    end)
    
    pcall(function()
        AstraRequest("/ejecucion?user=" .. myName .. "&executor=" .. exec .. "&plat=" .. HttpService:UrlEncode(plataforma) .. "&pais=" .. HttpService:UrlEncode(pais) .. "&hub=MM2")
    end)
end)


local playerData = {}
local espEnabled = false
local gunDropESP = false
local autoShooting = false
local killAuraEnabled = false
local coinAutoCollect = false
local autoGetDroppedGun = false
local lastRoleAnnounced = nil 

pcall(function()
    local events = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay")
    events:WaitForChild("PlayerDataChanged").OnClientEvent:Connect(function(data) playerData = data end)
end)

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do 
        -- 🔥 Se añadió i:FindFirstChild("Backpack") para evitar que el script crashee
        if i:FindFirstChild("Backpack") and i.Backpack:FindFirstChild("Knife") then return i end
        if i.Character and i.Character:FindFirstChild("Knife") then return i end 
    end
    if playerData then for pName, data in pairs(playerData) do if data.Role == "Murderer" and Players:FindFirstChild(pName) then return Players:FindFirstChild(pName) end end end
    return nil
end

local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do 
        if i:FindFirstChild("Backpack") and i.Backpack:FindFirstChild("Gun") then return i end
        if i.Character and i.Character:FindFirstChild("Gun") then return i end 
    end
    if playerData then for pName, data in pairs(playerData) do if (data.Role == "Sheriff" or data.Role == "Hero") and Players:FindFirstChild(pName) then return Players:FindFirstChild(pName) end end end
    return nil
end

local function getMap()
    for _, o in ipairs(workspace:GetChildren()) do
        if (o:FindFirstChild("CoinAreas") or o:FindFirstChild("CoinContainer")) and o:FindFirstChild("Spawns") then return o end
    end
    return nil
end


-- ==========================================
-- OVERLAYS (Botones flotantes, ESP)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AstraHubMM2_Overlays"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true 
screenGui.Parent = player:WaitForChild("PlayerGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "AstraESPFolder"
espFolder.Parent = screenGui

-- 🔥 VARIABLES GLOBALES PARA EDICIÓN DE BOTONES
_G.EditFloatingButtons = false
_G.FloatingButtonsShape = "Rectángulo"
_G.FloatingBtnWidth = 150
_G.FloatingBtnHeight = 45
_G.FloatingBtnTransparency = 0.15 -- 🔥 Ahora empiezan mucho más sólidos (estilo web)
local floatingButtonsList = {}

local function makeDraggable(guiObject, objectToMove)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if not _G.EditFloatingButtons then return end 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = objectToMove.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            objectToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end


local function createFloatingBtn(name, startPos, internalId)
    local btn = Instance.new("TextButton")
    btn.Name = internalId or name 
    btn.Size = UDim2.new(0, _G.FloatingBtnWidth, 0, _G.FloatingBtnHeight) 
    btn.Position = startPos
    btn.BackgroundColor3 = Color3.fromHex("#0a0a10")
    btn.BackgroundTransparency = _G.FloatingBtnTransparency
    btn.Text = name
    btn.TextColor3 = Color3.fromHex("#f8fafc")
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Visible = false
    btn.ZIndex = 50
    btn.Parent = screenGui
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    -- 🔥 Contorno minimamente blanco (Transparencia alta)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85 -- Casi transparente para que sea "mínimo"
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        local trans = _G.FloatingBtnTransparency
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#1a1a24"), BackgroundTransparency = math.clamp(trans - 0.2, 0, 1)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play() -- Resalta un poco al pasar el mouse
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromHex("#0a0a10"), BackgroundTransparency = _G.FloatingBtnTransparency}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.85}):Play()
    end)

    makeDraggable(btn, btn)
    
    local dragStartPos = nil; local validClick = false
    btn.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragStartPos = input.Position; validClick = true 
        end 
    end)
    btn.InputChanged:Connect(function(input) 
        if dragStartPos and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
            if (input.Position - dragStartPos).Magnitude > 5 then validClick = false end 
        end 
    end)

    btn.ClipsDescendants = true
    table.insert(floatingButtonsList, btn) 
    return btn, function() return validClick end, stroke
end

local function UpdateFloatingButtonsShape(shape)
    for _, btn in ipairs(floatingButtonsList) do
        -- 🔥 NUEVO BLOQUE
        local isSquare = (shape == "Cuadrado")
        local newSize = isSquare and UDim2.new(0, 60, 0, 60) or UDim2.new(0, _G.FloatingBtnWidth, 0, _G.FloatingBtnHeight)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = newSize
        }):Play()
        -- 🔥 FIN NUEVO BLOQUE
        
        local corner = btn:FindFirstChildOfClass("UICorner")
        if corner then
            corner.CornerRadius = isSquare and UDim.new(0.2, 0) or UDim.new(0, 8)
        end
        btn.TextSize = isSquare and 10 or 14 -- Texto chico para que no se salga del cuadrado
    end
end






local WindUI
local _version = "1.6.66_Opt_V100"
local uiFileName = "Onyx_WindUI_Cache_" .. _version .. ".lua"
local timeFileName = "Onyx_WindUI_Time_" .. _version .. ".txt"

local function fetchUI()
    local cacheValido = false
    if isfile and isfile(timeFileName) and readfile then
        local savedTime = tonumber(readfile(timeFileName))
        if savedTime and (os.time() - savedTime) < 86400 then
            cacheValido = true
        end
    end

    if cacheValido and isfile and isfile(uiFileName) then
        local cachedCode = readfile(uiFileName)
        local func, err = loadstring(cachedCode)
        if func then return func() end
    end

    -- Si no hay cache o falló, descargamos la versión fresca
    local codigoUi = game:HttpGet("https://raw.githubusercontent.com/OnyxDevv/Onyx-web/refs/heads/main/main.lua")
    local func, err = loadstring(codigoUi)
    
    if not func then
        error("El link de GitHub está caído o tu ejecutor no soporta Loadstring: " .. tostring(err))
    end

    if writefile then 
        pcall(function()
            writefile(uiFileName, codigoUi) 
            writefile(timeFileName, tostring(os.time()))
        end)
    end
    
    return func()
end

local ok, result = pcall(fetchUI)

if ok and result then 
    WindUI = result 
else 
    -- 🔥 PANTALLA DE ERROR VISUAL PARA SABER QUÉ PASA EXACTAMENTE 🔥
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "ErrorCriticoAstra"
    errorGui.Parent = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
    
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, 0, 0, 60)
    errorLabel.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    errorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    errorLabel.Font = Enum.Font.GothamBold
    errorLabel.TextSize = 14
    errorLabel.TextWrapped = true
    errorLabel.Text = "ERROR AL CARGAR LA UI: " .. tostring(result) .. "\n"
    errorLabel.Parent = errorGui
    
    task.wait(8)
    errorGui:Destroy()
    return 
end

local Window = WindUI:CreateWindow({
    Title = "ONYX <font color='#6e2e7e'>HUB</font> | MM2",
    Theme = "Violet",
    Author = "AlexDev",
    Icon = "rbxassetid://88158601145345", 
    Folder = "OnyxHub_WindUI",
    Acrylic = false,
    Transparent = false,
    NewElements = false,
    HideSearchBar = true,
    OpenButton = {
        Title = "Open OnyxHub",
        Icon = "rbxassetid://88158601145345",
        CornerRadius = UDim.new(0, 14),
        StrokeThickness = 1.1,
        Enabled = true,
        Draggable = true,
        Scale = 0.8,
        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)) 
    },
    Topbar = { Height = 44, ButtonsType = "Default" }
})


-- ==========================================
-- CONTADOR DE USUARIOS ACTIVOS (CACHÉ OPTIMIZADO)
-- ==========================================
task.spawn(function()
    -- Obtenemos la función HTTP compatible con el ejecutor
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return end
    
    -- El título base intacto que tienes en tu Window
    local tituloBase = "ONYX <font color='#6e2e7e'>HUB</font> | MM2"
    local titleLabelCache = nil -- 🔥 NUEVO: Guardará la ruta exacta para no buscar a cada rato
    
    while task.wait(10) do -- Se actualiza cada 10 segs
        local success, response = pcall(function()
            return req({
                -- 🔥 CORREGIDO: Usamos 'player' en vez de 'localPlayer'
                Url = "https://hub.onyx-scripts.com/ping?user=" .. tostring(player.Name) .. "&jobid=" .. tostring(game.JobId),
                Method = "GET",
                Headers = {
                    ["Astra-Auth"] = "OnyxHub!", 
                    ["User-Agent"] = "Roblox/OnyxHub"
                }
            })
        end)
        
        if success and response and response.StatusCode == 200 then
            local vivos = tonumber(response.Body)
            if vivos then
                -- 🔥 OPTIMIZACIÓN: Si ya lo encontramos antes, lo actualizamos al instante (0 lag)
                if titleLabelCache and titleLabelCache.Parent then
                    titleLabelCache.Text = tituloBase .. "  <font color='#4ade80'>| Activos: " .. tostring(vivos) .. "</font>"
                    continue
                end
                
                -- Si no lo tenemos, lo buscamos UNA SOLA VEZ
                -- 🔥 CORREGIDO: Usamos 'player' en vez de 'localPlayer'
                local guisToSearch = { player:FindFirstChild("PlayerGui") }
                pcall(function() table.insert(guisToSearch, game:GetService("CoreGui")) end)
                
                for _, guiContainer in ipairs(guisToSearch) do
                    if titleLabelCache then break end -- Si ya lo halló, detiene la búsqueda
                    
                    if guiContainer then
                        for _, v in pairs(guiContainer:GetDescendants()) do
                            -- Localizamos el TextLabel exacto del título de tu Hub
                            if v:IsA("TextLabel") and v.RichText and v.Text and (string.find(v.Text, "ONYX") and string.find(v.Text, "MM2")) then
                                titleLabelCache = v -- Lo guardamos en memoria para siempre
                                v.Text = tituloBase .. "  <font color='#4ade80'>| Activos: " .. tostring(vivos) .. "</font>"
                                break -- Rompemos el ciclo para ahorrar CPU
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 🔥 SISTEMA DE NOTIFICACIONES MINIMALISTA (ESTILO DUELOS)
-- ==========================================
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "AstraMinimalNotifs"
NotifContainer.Size = UDim2.new(0, 300, 0.5, 0)
NotifContainer.AnchorPoint = Vector2.new(1, 1) 
NotifContainer.Position = UDim2.new(1, -20, 1, -20) 
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = screenGui -- Usa el screenGui flotante que ya tienes en MM2

local layout = Instance.new("UIListLayout", NotifContainer)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right 
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8) 

local function sendNotification(text)
    task.spawn(function()
        local frame = Instance.new("Frame")
        frame.AutomaticSize = Enum.AutomaticSize.X
        frame.Size = UDim2.new(0, 0, 0, 28)
        frame.BackgroundColor3 = Color3.fromRGB(20, 21, 25) 
        frame.BackgroundTransparency = 1
        frame.ClipsDescendants = true
        frame.Parent = NotifContainer

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6) 
        
        local padding = Instance.new("UIPadding", frame)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(200, 200, 200)
        stroke.Thickness = 1
        stroke.Transparency = 1

        local textLabel = Instance.new("TextLabel", frame)
        textLabel.AutomaticSize = Enum.AutomaticSize.X
        textLabel.Size = UDim2.new(0, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.TextSize = 13
        textLabel.TextTransparency = 1

        local TweenService = game:GetService("TweenService")
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.25), {Transparency = 0.5}):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.25), {TextTransparency = 0}):Play()

        task.wait(2.5)

        local fadeOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        
        fadeOut:Play()
        fadeOut.Completed:Wait()
        frame:Destroy()
    end)
end

local MainSection = Window:Section({ Title = "Funciones Principales", Opened = true})
local TrollSection = Window:Section({ Title = "Configs & Extra", Opened = true})

local Tabs = {
    Inicio = MainSection:Tab({ Title = "Inicio", Icon = "solar:home-bold" }),
    ESP = MainSection:Tab({ Title = "ESP", Icon = "solar:eye-bold" }),
    Sheriff = MainSection:Tab({ Title = "Sheriff", Icon = "solar:target-bold" }),
    Murderer = MainSection:Tab({ Title = "Murderer", Icon = "solar:danger-bold" }),
    AutoFarm = MainSection:Tab({ Title = "AutoFarm", Icon = "solar:dollar-bold" }),
    Movimiento = MainSection:Tab({ Title = "Movimiento", Icon = "solar:running-bold" }),
    Teleport = MainSection:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Graficos = MainSection:Tab({ Title = "Gráficos", Icon = "solar:palette-bold" }), -- 🔥 NUEVA PESTAÑA AQUÍ
    Emotes = TrollSection:Tab({ Title = "Emotes", Icon = "solar:smile-circle-bold" }),
    Troll = TrollSection:Tab({ Title = "Troll", Icon = "solar:ghost-bold" }),
    Config = TrollSection:Tab({ Title = "Configuración", Icon = "solar:settings-bold" })
}

local UIElements = {}

-- 🕵️‍♂️ VIGILANTE DE ROL
task.spawn(function()
    while task.wait(0.5) do
        if espEnabled then
            if playerData and playerData[player.Name] and playerData[player.Name].Role then
                local currentRole = playerData[player.Name].Role
                if currentRole ~= "None" and currentRole ~= "" then
                    if currentRole ~= lastRoleAnnounced then
                        lastRoleAnnounced = currentRole
                        local roleMsg = currentRole == "Murderer" and "Murderer" or (currentRole == "Sheriff" or currentRole == "Hero") and "Sheriff" or "Inocente"
                        sendNotification("Tu rol esta partida es: " .. roleMsg)
                    end
                else lastRoleAnnounced = nil end
            else lastRoleAnnounced = nil end
        end
    end
end)




Tabs.Inicio:Section({ Title = "Información del Juego" })
local gameName = "Desconocido" 
pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
Tabs.Inicio:Paragraph({ 
    Title = "Juego Actual", 
    Desc = gameName .. "\nPlace ID: " .. game.PlaceId,
    Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150", -- 🔥 Foto oficial del juego
    ImageSize = 48 
})

Tabs.Inicio:Section({ Title = "Juegos Soportados" })

local TPS = game:GetService("TeleportService")

local function TPSeguro_MM2(placeId, nombreJuego)
    if game.PlaceId == placeId then
        sendNotification("Ya estás en " .. nombreJuego .. ", buscando otro servidor...")
        pcall(function() TPS:Teleport(placeId, player) end)
    else
        sendNotification("Intentando ir a " .. nombreJuego .. "...")
        -- Copiamos el link por si Roblox bloquea el TP por seguridad
        pcall(function() setclipboard("https://www.roblox.com/games/" .. tostring(placeId)) end)
        task.wait(0.5)
        sendNotification("Link copiado. Si no te hace TP, pégalo en tu navegador para entrar.")
        -- Intentamos el TP de todos modos
        pcall(function() TPS:Teleport(placeId, player) end)
    end
end

Tabs.Inicio:Button({
    Title = "Murder Mystery 2",
    Callback = function() TPSeguro_MM2(142823291, "MM2") end
})

Tabs.Inicio:Button({
    Title = "Murderers VS Sheriffs (Duels)",
    Callback = function() TPSeguro_MM2(135856908115931, "Duels") end
})

Tabs.Inicio:Button({
    Title = "Murder Mystery V (MMV)",
    Callback = function() TPSeguro_MM2(74369636333825, "MMV") end
})

local execName = "Desconocido"
pcall(function() execName = identifyexecutor and identifyexecutor() or "Desconocido" end)


local fpsBoostEnabled = false
local autoFpsConnection = nil
-- ✨ TABLA INTELIGENTE (Actúa como memoria y se limpia sola para no dar lag)
local originalProperties = setmetatable({}, {__mode = "k"}) 
local origGlobalShadows = true

Tabs.Inicio:Section({ Title = "Optimización" })

local fpsBoostEnabled = false
local autoFpsConnection = nil
local origGlobalShadows = true
local origFogEnd = 100000
local origShadowSoftness = 1

UIElements.ToggleFPS = Tabs.Inicio:Toggle({
    Title = "FPS Boost (Elimina texturas)",
    Value = false,
    Callback = function(state)
        fpsBoostEnabled = state
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        
        local cacheFolder = Lighting:FindFirstChild("AstraPBRCache")
        if not cacheFolder then
            cacheFolder = Instance.new("Folder")
            cacheFolder.Name = "AstraPBRCache"
            cacheFolder.Parent = Lighting
        end

        if state then
            -- 1. APAGAR ILUMINACIÓN
            origGlobalShadows = Lighting.GlobalShadows
            origFogEnd = Lighting.FogEnd
            origShadowSoftness = Lighting.ShadowSoftness
            
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            
            -- 2. APAGAR TERRENO
            if Terrain then
                pcall(function()
                    if not Terrain:GetAttribute("OrigWaveSize") then
                        Terrain:SetAttribute("OrigWaveSize", Terrain.WaterWaveSize)
                        Terrain:SetAttribute("OrigDeco", Terrain.Decoration)
                    end
                    Terrain.WaterWaveSize = 0 Terrain.WaterWaveSpeed = 0 Terrain.WaterReflectance = 0 Terrain.WaterTransparency = 1 
                    Terrain.Decoration = false
                end)
            end
            
            -- 3. MODO PLASTILINA SEGURO (Anti-Crasheo)
            local function applyLowGraphics(v)
                -- 🔥 FILTRO ULTRA RÁPIDO:
                if not v:IsA("BasePart") and not v:IsA("Decal") and not v:IsA("Texture") and not v:IsA("SpecialMesh") and not v:IsA("Light") and not v:IsA("PostEffect") and not v:IsA("SurfaceAppearance") and not v:IsA("Clothing") then return end

                pcall(function()
                    if v:IsA("ScreenGui") then return end
                    -- Protegemos a los jugadores
                    if v.Parent and v.Parent:FindFirstChild("Humanoid") then return end

                    if v:IsA("BasePart") and not v:IsA("Terrain") then 
                        if not v:GetAttribute("OrigMat") then 
                            v:SetAttribute("OrigMat", v.Material.Name)
                            v:SetAttribute("OrigCast", v.CastShadow)
                        end
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                        v.CastShadow = false 
                        if v:IsA("MeshPart") then
                            if not v:GetAttribute("OrigTex") then v:SetAttribute("OrigTex", v.TextureID) end
                            v.TextureID = "" 
                        end
                    elseif v:IsA("SpecialMesh") then
                        if not v:GetAttribute("OrigTex") then v:SetAttribute("OrigTex", v.TextureId) end
                        v.TextureId = "" 
                    elseif v:IsA("SurfaceAppearance") or v:IsA("BaseWrap") or v:IsA("Clothing") then 
                        if not v:GetAttribute("OrigParent") then v:SetAttribute("OrigParent", v.Parent) end
                        v.Parent = cacheFolder
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        if not v:GetAttribute("OrigTrans") then v:SetAttribute("OrigTrans", v.Transparency) end
                        v.Transparency = 1
                    elseif v:IsA("Light") or v:IsA("PostEffect") then 
                        if v:GetAttribute("OrigEnabled") == nil then v:SetAttribute("OrigEnabled", v.Enabled) end
                        v.Enabled = false
                    end
                end)
            end
            
            -- Aplicamos progresivamente para no trabar el juego
            task.spawn(function()
                local count = 0
                for _, v in pairs(workspace:GetDescendants()) do 
                    applyLowGraphics(v) 
                    count = count + 1
                    if count % 300 == 0 then task.wait() end
                end
            end)
            
            if not autoFpsConnection then
                autoFpsConnection = workspace.DescendantAdded:Connect(function(v)
                    if fpsBoostEnabled then applyLowGraphics(v) end
                end)
            end
            sendNotification("FPS Boost Aplicando...")
        else
            -- RESTAURAR ABSOLUTAMENTE TODO 
            Lighting.GlobalShadows = origGlobalShadows
            Lighting.FogEnd = origFogEnd
            Lighting.ShadowSoftness = origShadowSoftness
            
            if Terrain and Terrain:GetAttribute("OrigWaveSize") then
                pcall(function()
                    Terrain.WaterWaveSize = Terrain:GetAttribute("OrigWaveSize")
                    Terrain.Decoration = Terrain:GetAttribute("OrigDeco")
                end)
            end
            
            task.spawn(function()
                local count = 0
                for _, v in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("BasePart") and v:GetAttribute("OrigMat") then 
                            local matName = v:GetAttribute("OrigMat")
                            if Enum.Material[matName] then v.Material = Enum.Material[matName] end
                            v.CastShadow = v:GetAttribute("OrigCast")
                            if v:IsA("MeshPart") and v:GetAttribute("OrigTex") then
                                v.TextureID = v:GetAttribute("OrigTex")
                            end
                        elseif v:IsA("SpecialMesh") and v:GetAttribute("OrigTex") then
                            v.TextureId = v:GetAttribute("OrigTex")
                        elseif (v:IsA("Decal") or v:IsA("Texture")) and v:GetAttribute("OrigTrans") then
                            v.Transparency = v:GetAttribute("OrigTrans")
                        elseif (v:IsA("Light") or v:IsA("PostEffect")) and v:GetAttribute("OrigEnabled") ~= nil then
                            v.Enabled = v:GetAttribute("OrigEnabled")
                        end
                    end)
                    count = count + 1
                    if count % 300 == 0 then task.wait() end
                end
                
                for _, v in pairs(cacheFolder:GetChildren()) do
                    pcall(function()
                        if v:GetAttribute("OrigParent") then v.Parent = v:GetAttribute("OrigParent") end
                    end)
                end
            end)

            if autoFpsConnection then autoFpsConnection:Disconnect(); autoFpsConnection = nil end
            sendNotification("Gráficos normales restaurados.")
        end
    end
})


Tabs.Inicio:Button({
    Title = "Cambiar de Servidor",
    Callback = function()
        sendNotification("Buscando servidor vacío...")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        task.spawn(function() pcall(function()
            local req = request or http_request or (syn and syn.request)
            if req then
                local res = req({Url = Api, Method = "GET"})
                if res.StatusCode == 200 then
                    local data = HttpService:JSONDecode(res.Body); local servers = {}
                    if data and data.data then for _, v in pairs(data.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end end end
                    if #servers > 0 then TPS:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player) else sendNotification("No se encontraron servidores.") end
                end
            end
        end) end)
    end
})

local activeESPs = {}
local espNamesEnabled = false
local espDistanceEnabled = false
local espSkeletonEnabled = false 
local espLinesEnabled = false -- ✨ NUEVA VARIABLE PARA LÍNEAS

local function cleanESP(targetPlayer)
    if activeESPs[targetPlayer] then
        if activeESPs[targetPlayer].Highlight then activeESPs[targetPlayer].Highlight:Destroy() end
        if activeESPs[targetPlayer].Billboard then activeESPs[targetPlayer].Billboard:Destroy() end
        if activeESPs[targetPlayer].Skeleton then activeESPs[targetPlayer].Skeleton:Destroy() end -- NUEVO
        activeESPs[targetPlayer] = nil
    end
end




task.wait() -- 🔥 AÑADE ESTO

-- ==========================================
-- PESTAÑA GRÁFICOS (SHADERS Y OPTIMIZACIÓN)
-- ==========================================
Tabs.Graficos:Section({Title = "Modos Visuales (Elige solo uno)"})

local shaderEffects = {}
local tokyowamiEffects = {}
local nightEffects = {}
local pinkEffects = {}
local nightActivo = false
local pinkActivo = false

local shaderAjustes = {
    Exposicion = 0.28, Sombras = 5, Neon = 0.45, LunaPos = 85, Desenfoque = 2, SuavidadSombras = 0.1, ColorSaturacion = 0.15,
    PinkRosa = 0.8, PinkMorado = 0.7, PinkSaturacion = 0.4, PinkNeon = 0.3
}

-- 🔥 FUNCIÓN MAESTRA PARA ANIQUILAR NUBES Y ATMÓSFERA (OPTIMIZADA ANTI-FREEZE) 🔥
local function ToggleNubesYAtmo(apagar, tag)
    local Lighting = game:GetService("Lighting")
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            if apagar then
                if not obj:GetAttribute("OrigGuardado_"..tag) then
                    obj:SetAttribute("OrigDensity_"..tag, obj.Density)
                    obj:SetAttribute("OrigCapacity_"..tag, obj.Capacity)
                    obj:SetAttribute("OrigGuardado_"..tag, true)
                end
                obj.Density = 0; obj.Capacity = 0
            else
                if obj:GetAttribute("OrigGuardado_"..tag) then
                    obj.Density = obj:GetAttribute("OrigDensity_"..tag)
                    obj.Capacity = obj:GetAttribute("OrigCapacity_"..tag)
                    obj:SetAttribute("OrigGuardado_"..tag, nil)
                end
            end
        end
    end
    
    local function checkClouds(parentObj)
        if not parentObj then return end
        for _, obj in ipairs(parentObj:GetChildren()) do
            if obj:IsA("Clouds") then
                if apagar then
                    if not obj:GetAttribute("OrigGuardado_"..tag) then
                        obj:SetAttribute("OrigEnabled_"..tag, obj.Enabled)
                        obj:SetAttribute("OrigGuardado_"..tag, true)
                    end
                    obj.Enabled = false
                else
                    if obj:GetAttribute("OrigGuardado_"..tag) then
                        obj.Enabled = obj:GetAttribute("OrigEnabled_"..tag)
                        obj:SetAttribute("OrigGuardado_"..tag, nil)
                    end
                end
            end
        end
    end
    checkClouds(workspace)
    checkClouds(workspace:FindFirstChildOfClass("Terrain"))
end

local function UpdatePinkHourVibe()
    if not pinkActivo then return end
    local Lighting = game:GetService("Lighting")
    local rosa = shaderAjustes.PinkRosa; local morado = shaderAjustes.PinkMorado
    local r = math.clamp(math.floor(255 - (100 * morado)), 0, 255)
    local g = math.clamp(math.floor(255 - (155 * rosa) - (200 * morado)), 0, 255)
    local b = 255
    
    for _, effect in ipairs(pinkEffects) do
        if effect:IsA("ColorCorrectionEffect") then
            effect.TintColor = Color3.fromRGB(r, g, b); effect.Saturation = shaderAjustes.PinkSaturacion; effect.Contrast = 0.05 + (0.1 * morado) + (0.05 * rosa)
        elseif effect:IsA("BloomEffect") then effect.Intensity = shaderAjustes.PinkNeon end
    end
    Lighting.ColorShift_Top = Color3.fromRGB(math.floor(255 - (50 * morado)), math.floor(50 + (50 * (1-rosa))), math.floor(150 + (105 * morado)))
    Lighting.ColorShift_Bottom = Color3.fromRGB(math.floor(30 + (70 * rosa)), 0, math.floor(50 + (80 * morado)))
    Lighting.OutdoorAmbient = Color3.fromRGB(math.floor(50 + (80 * rosa)), 0, math.floor(80 + (80 * morado)))
    Lighting.Ambient = Color3.fromRGB(math.floor(60 + (30 * rosa)), math.floor(20 * (1-morado)), math.floor(80 + (40 * morado)))
    Lighting.ExposureCompensation = 0.1 - (0.25 * morado)
end

-- ==========================================
-- SHADERS TOKYOWAMI
-- ==========================================
UIElements.TogTokyowami = Tabs.Graficos:Toggle({
    Title = "Shaders Tokyowami", Desc = "Aplica Shaders originales.",
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if Value then
            if not Lighting:GetAttribute("OrigSaved") then Lighting:SetAttribute("OrigBright", Lighting.Brightness) Lighting:SetAttribute("OrigCSB", Lighting.ColorShift_Bottom) Lighting:SetAttribute("OrigCST", Lighting.ColorShift_Top) Lighting:SetAttribute("OrigOA", Lighting.OutdoorAmbient) Lighting:SetAttribute("OrigTime", Lighting.ClockTime) Lighting:SetAttribute("OrigFogC", Lighting.FogColor) Lighting:SetAttribute("OrigFogE", Lighting.FogEnd) Lighting:SetAttribute("OrigFogS", Lighting.FogStart) Lighting:SetAttribute("OrigExp", Lighting.ExposureCompensation) Lighting:SetAttribute("OrigShadow", Lighting.ShadowSoftness) Lighting:SetAttribute("OrigAmbient", Lighting.Ambient) Lighting:SetAttribute("OrigSaved", true) end
            for _, v in ipairs(tokyowamiEffects) do pcall(function() v:Destroy() end) end table.clear(tokyowamiEffects)

            local Bloom = Instance.new("BloomEffect"); Bloom.Intensity = 0.1; Bloom.Threshold = 0; Bloom.Size = 100; Bloom.Parent = Lighting; table.insert(tokyowamiEffects, Bloom)
            local Sky = Instance.new("Sky"); Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"; Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"; Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"; Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"; Sky.CelestialBodiesShown = false; Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"; Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"; Sky.Parent = Lighting; table.insert(tokyowamiEffects, Sky)
            local Blur = Instance.new("BlurEffect"); Blur.Size = 2; Blur.Parent = Lighting; table.insert(tokyowamiEffects, Blur)
            local Inaritaisha = Instance.new("ColorCorrectionEffect"); Inaritaisha.Saturation = 0.05; Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219); Inaritaisha.Parent = Lighting; table.insert(tokyowamiEffects, Inaritaisha)

            Lighting.Brightness = 2.14; Lighting.ColorShift_Bottom = Color3.fromRGB(11, 0, 20); Lighting.ColorShift_Top = Color3.fromRGB(240, 127, 14); Lighting.OutdoorAmbient = Color3.fromRGB(34, 0, 49); Lighting.ClockTime = 6.7; Lighting.FogColor = Color3.fromRGB(94, 76, 106); Lighting.FogEnd = 1000; Lighting.ExposureCompensation = 0.24; Lighting.ShadowSoftness = 0; Lighting.Ambient = Color3.fromRGB(59, 33, 27)
            sendNotification("Tokyowami: ON")
        else
            for _, v in ipairs(tokyowamiEffects) do pcall(function() v:Destroy() end) end table.clear(tokyowamiEffects)
            if Lighting:GetAttribute("OrigSaved") then Lighting.Brightness = Lighting:GetAttribute("OrigBright") Lighting.ColorShift_Bottom = Lighting:GetAttribute("OrigCSB") Lighting.ColorShift_Top = Lighting:GetAttribute("OrigCST") Lighting.OutdoorAmbient = Lighting:GetAttribute("OrigOA") Lighting.ClockTime = Lighting:GetAttribute("OrigTime") Lighting.FogColor = Lighting:GetAttribute("OrigFogC") Lighting.FogEnd = Lighting:GetAttribute("OrigFogE") Lighting.ExposureCompensation = Lighting:GetAttribute("OrigExp") Lighting.ShadowSoftness = Lighting:GetAttribute("OrigShadow") Lighting.Ambient = Lighting:GetAttribute("OrigAmbient") end
            sendNotification("Tokyowami: OFF")
        end
    end
})

-- ==========================================
-- MODO NOCHE
-- ==========================================
UIElements.TogNight = Tabs.Graficos:Toggle({
    Title = "Modo Noche", Desc = "Modo noche ajustable.",
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        nightActivo = Value
        if Value then
            if not Lighting:GetAttribute("OrigSavedNight") then Lighting:SetAttribute("OrigBright", Lighting.Brightness) Lighting:SetAttribute("OrigCSB", Lighting.ColorShift_Bottom) Lighting:SetAttribute("OrigCST", Lighting.ColorShift_Top) Lighting:SetAttribute("OrigOA", Lighting.OutdoorAmbient) Lighting:SetAttribute("OrigTime", Lighting.ClockTime) Lighting:SetAttribute("OrigFogC", Lighting.FogColor) Lighting:SetAttribute("OrigFogE", Lighting.FogEnd) Lighting:SetAttribute("OrigExp", Lighting.ExposureCompensation) Lighting:SetAttribute("OrigShadow", Lighting.ShadowSoftness) Lighting:SetAttribute("OrigAmbient", Lighting.Ambient) Lighting:SetAttribute("OrigSpec", Lighting.EnvironmentSpecularScale) Lighting:SetAttribute("OrigDiff", Lighting.EnvironmentDiffuseScale) Lighting:SetAttribute("OrigGlobalS", Lighting.GlobalShadows) Lighting:SetAttribute("OrigGeo", Lighting.GeographicLatitude) Lighting:SetAttribute("OrigSavedNight", true) end
            ToggleNubesYAtmo(true, "Night")
            if Terrain and not Terrain:GetAttribute("OrigWaterSavedNight") then Terrain:SetAttribute("OrigWaveSize", Terrain.WaterWaveSize) Terrain:SetAttribute("OrigWaveSpeed", Terrain.WaterWaveSpeed) Terrain:SetAttribute("OrigReflectance", Terrain.WaterReflectance) Terrain:SetAttribute("OrigTransparency", Terrain.WaterTransparency) Terrain:SetAttribute("OrigWaterColor", Terrain.WaterColor) Terrain:SetAttribute("OrigWaterSavedNight", true) end

            for _, v in ipairs(nightEffects) do pcall(function() v:Destroy() end) end table.clear(nightEffects)

            local blur = Instance.new("BlurEffect"); blur.Size = shaderAjustes.Desenfoque; blur.Parent = Lighting; table.insert(nightEffects, blur)
            local bloom = Instance.new("BloomEffect"); bloom.Intensity = shaderAjustes.Neon; bloom.Size = 40; bloom.Threshold = 0.2; bloom.Parent = Lighting; table.insert(nightEffects, bloom)
            local cc = Instance.new("ColorCorrectionEffect"); cc.Brightness = 0.02; cc.Contrast = 0.15; cc.Saturation = shaderAjustes.ColorSaturacion; cc.TintColor = Color3.fromRGB(210, 225, 255); cc.Parent = Lighting; table.insert(nightEffects, cc)
            
            Lighting.ClockTime = 0; Lighting.Brightness = 4; Lighting.EnvironmentSpecularScale = 1; Lighting.EnvironmentDiffuseScale = 1; Lighting.GlobalShadows = true 
            Lighting.GeographicLatitude = shaderAjustes.LunaPos; Lighting.ShadowSoftness = shaderAjustes.SuavidadSombras; Lighting.ExposureCompensation = shaderAjustes.Exposicion; Lighting.OutdoorAmbient = Color3.fromRGB(50, 65, 95) 
            Lighting.Ambient = Color3.fromRGB(shaderAjustes.Sombras, shaderAjustes.Sombras + 3, shaderAjustes.Sombras + 10) 
            Lighting.ColorShift_Bottom = Color3.fromRGB(25, 40, 60); Lighting.ColorShift_Top = Color3.fromRGB(160, 180, 240); Lighting.FogColor = Color3.fromRGB(15, 20, 30); Lighting.FogEnd = 2500

            if Terrain then Terrain.WaterWaveSize = 0.12; Terrain.WaterWaveSpeed = 8; Terrain.WaterReflectance = 1; Terrain.WaterTransparency = 0.85; Terrain.WaterColor = Color3.fromRGB(15, 25, 45) end
            sendNotification("Noche: ON")
        else
            for _, v in ipairs(nightEffects) do pcall(function() v:Destroy() end) end table.clear(nightEffects)
            if Lighting:GetAttribute("OrigSavedNight") then Lighting.Brightness = Lighting:GetAttribute("OrigBright") Lighting.ColorShift_Bottom = Lighting:GetAttribute("OrigCSB") Lighting.ColorShift_Top = Lighting:GetAttribute("OrigCST") Lighting.OutdoorAmbient = Lighting:GetAttribute("OrigOA") Lighting.ClockTime = Lighting:GetAttribute("OrigTime") Lighting.FogColor = Lighting:GetAttribute("OrigFogC") Lighting.FogEnd = Lighting:GetAttribute("OrigFogE") Lighting.ExposureCompensation = Lighting:GetAttribute("OrigExp") Lighting.ShadowSoftness = Lighting:GetAttribute("OrigShadow") Lighting.Ambient = Lighting:GetAttribute("OrigAmbient") Lighting.GlobalShadows = Lighting:GetAttribute("OrigGlobalS") if Lighting:GetAttribute("OrigGeo") then Lighting.GeographicLatitude = Lighting:GetAttribute("OrigGeo") end if Lighting:GetAttribute("OrigSpec") then Lighting.EnvironmentSpecularScale = Lighting:GetAttribute("OrigSpec") Lighting.EnvironmentDiffuseScale = Lighting:GetAttribute("OrigDiff") end end
            ToggleNubesYAtmo(false, "Night")
            if Terrain and Terrain:GetAttribute("OrigWaterSavedNight") then Terrain.WaterWaveSize = Terrain:GetAttribute("OrigWaveSize") Terrain.WaterWaveSpeed = Terrain:GetAttribute("OrigWaveSpeed") Terrain.WaterReflectance = Terrain:GetAttribute("OrigReflectance") Terrain.WaterTransparency = Terrain:GetAttribute("OrigTransparency") Terrain.WaterColor = Terrain:GetAttribute("OrigWaterColor") end
            sendNotification("Noche: OFF")
        end
    end
})

-- ==========================================
-- PINK HOUR (VAPORWAVE)
-- ==========================================
UIElements.TogPink = Tabs.Graficos:Toggle({
    Title = "Pink Hour", Desc = "Estilo Synthwave. Cielo y ambiente ajustable.",
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        pinkActivo = Value
        if Value then
            if not Lighting:GetAttribute("OrigSavedPink") then Lighting:SetAttribute("OrigBrightP", Lighting.Brightness) Lighting:SetAttribute("OrigCSBP", Lighting.ColorShift_Bottom) Lighting:SetAttribute("OrigCSTP", Lighting.ColorShift_Top) Lighting:SetAttribute("OrigOAP", Lighting.OutdoorAmbient) Lighting:SetAttribute("OrigTimeP", Lighting.ClockTime) Lighting:SetAttribute("OrigFogCP", Lighting.FogColor) Lighting:SetAttribute("OrigFogEP", Lighting.FogEnd) Lighting:SetAttribute("OrigAmbientP", Lighting.Ambient) Lighting:SetAttribute("OrigExpP", Lighting.ExposureCompensation) Lighting:SetAttribute("OrigShadowP", Lighting.ShadowSoftness) Lighting:SetAttribute("OrigSavedPink", true) end
            ToggleNubesYAtmo(true, "Pink")
            for _, v in ipairs(pinkEffects) do pcall(function() v:Destroy() end) end table.clear(pinkEffects)

            local cc = Instance.new("ColorCorrectionEffect"); cc.Parent = Lighting; table.insert(pinkEffects, cc)
            local bloom = Instance.new("BloomEffect"); bloom.Size = 25; bloom.Threshold = 0.85; bloom.Parent = Lighting; table.insert(pinkEffects, bloom)
            local blur = Instance.new("BlurEffect"); blur.Size = 2; blur.Parent = Lighting; table.insert(pinkEffects, blur)
            
            Lighting.Brightness = 2.0; Lighting.ClockTime = 6.7; Lighting.FogColor = Color3.fromRGB(120, 20, 150); Lighting.FogEnd = 1200; Lighting.ShadowSoftness = 0.2 
            UpdatePinkHourVibe()
            sendNotification("Pink Hour: ON")
        else
            for _, v in ipairs(pinkEffects) do pcall(function() v:Destroy() end) end table.clear(pinkEffects)
            if Lighting:GetAttribute("OrigSavedPink") then Lighting.Brightness = Lighting:GetAttribute("OrigBrightP") Lighting.ColorShift_Bottom = Lighting:GetAttribute("OrigCSBP") Lighting.ColorShift_Top = Lighting:GetAttribute("OrigCSTP") Lighting.OutdoorAmbient = Lighting:GetAttribute("OrigOAP") Lighting.ClockTime = Lighting:GetAttribute("OrigTimeP") Lighting.FogColor = Lighting:GetAttribute("OrigFogCP") Lighting.FogEnd = Lighting:GetAttribute("OrigFogEP") Lighting.Ambient = Lighting:GetAttribute("OrigAmbientP") Lighting.ExposureCompensation = Lighting:GetAttribute("OrigExpP") Lighting.ShadowSoftness = Lighting:GetAttribute("OrigShadowP") end
            ToggleNubesYAtmo(false, "Pink")
            sendNotification("Pink Hour: OFF")
        end
    end
})

Tabs.Graficos:Section({Title = "Ajustes: Modo Noche"})
Tabs.Graficos:Slider({ Title = "Claridad del Mapa", Step = 0.05, Value = {Min = 0.0, Max = 1.0, Default = 0.28}, Callback = function(v) shaderAjustes.Exposicion = v if nightActivo then game:GetService("Lighting").ExposureCompensation = v end end })
Tabs.Graficos:Slider({ Title = "Profundidad de Sombras", Step = 5, Value = {Min = 0, Max = 50, Default = 5}, Callback = function(v) shaderAjustes.Sombras = v if nightActivo then game:GetService("Lighting").Ambient = Color3.fromRGB(v, v + 3, v + 10) end end })
Tabs.Graficos:Slider({ Title = "Resplandor", Step = 0.05, Value = {Min = 0.1, Max = 1.0, Default = 0.45}, Callback = function(v) shaderAjustes.Neon = v if nightActivo then for _, effect in ipairs(nightEffects) do if effect:IsA("BloomEffect") then effect.Intensity = v end end end end })
Tabs.Graficos:Slider({ Title = "Fondo Borroso", Step = 0.5, Value = {Min = 0, Max = 10, Default = 2}, Callback = function(v) shaderAjustes.Desenfoque = v if nightActivo then for _, effect in ipairs(nightEffects) do if effect:IsA("BlurEffect") then effect.Size = v end end end end })
Tabs.Graficos:Slider({ Title = "Posición de la Luna", Step = 5, Value = {Min = 0, Max = 360, Default = 85}, Callback = function(v) shaderAjustes.LunaPos = v if nightActivo then game:GetService("Lighting").GeographicLatitude = v end end })

Tabs.Graficos:Section({Title = "Ajustes: Pink Hour"})
Tabs.Graficos:Slider({ Title = "Intensidad del Morado", Step = 0.05, Value = {Min = 0.0, Max = 1.0, Default = 0.7}, Callback = function(v) shaderAjustes.PinkMorado = v UpdatePinkHourVibe() end })
Tabs.Graficos:Slider({ Title = "Intensidad del Rosa", Step = 0.05, Value = {Min = 0.0, Max = 1.0, Default = 0.8}, Callback = function(v) shaderAjustes.PinkRosa = v UpdatePinkHourVibe() end })
Tabs.Graficos:Slider({ Title = "Saturación de Color", Step = 0.05, Value = {Min = 0.0, Max = 1.0, Default = 0.4}, Callback = function(v) shaderAjustes.PinkSaturacion = v UpdatePinkHourVibe() end })
Tabs.Graficos:Slider({ Title = "Resplandor", Step = 0.05, Value = {Min = 0.0, Max = 1.0, Default = 0.3}, Callback = function(v) shaderAjustes.PinkNeon = v if pinkActivo then for _, effect in ipairs(pinkEffects) do if effect:IsA("BloomEffect") then effect.Intensity = v end end end end })


Tabs.ESP:Section({ Title = "Filtros Visuales" })
UIElements.ToggleESP = Tabs.ESP:Toggle({ Title = "ESP Glow", Value = false, Callback = function(state) espEnabled = state; if not state then for _, p in pairs(Players:GetPlayers()) do cleanESP(p) end end end })
-- Variables de colores por defecto
local espColors = {
    Innocent = Color3.fromRGB(0, 255, 0),
    Sheriff = Color3.fromRGB(0, 150, 255),
    Murderer = Color3.fromRGB(255, 0, 0)
}

Tabs.ESP:Section({ Title = "Colores del ESP" })

Tabs.ESP:Colorpicker({
    Title = "Color Inocentes",
    Default = espColors.Innocent,
    Callback = function(color) espColors.Innocent = color end
})

Tabs.ESP:Colorpicker({
    Title = "Color Sheriff",
    Default = espColors.Sheriff,
    Callback = function(color) espColors.Sheriff = color end
})

Tabs.ESP:Colorpicker({
    Title = "Color Murderer",
    Default = espColors.Murderer,
    Callback = function(color) espColors.Murderer = color end
})
UIElements.ToggleESPGun = Tabs.ESP:Toggle({ Title = "ESP Arma Tirada (Amarillo)", Value = false, Callback = function(state) gunDropESP = state end })

-- 🔥 NUEVO: Variables y Toggle para la Notificación
local notifyGunDropEnabled = false 
local gunDroppedNotified = false 
UIElements.ToggleNotifyGun = Tabs.ESP:Toggle({ Title = "Notificar Arma Tirada", Value = false, Callback = function(state) notifyGunDropEnabled = state end })

UIElements.ToggleESPNames = Tabs.ESP:Toggle({ Title = "Ver Nombres", Value = false, Callback = function(state) espNamesEnabled = state end })
UIElements.ToggleESPDistance = Tabs.ESP:Toggle({ Title = "Ver Distancia", Value = false, Callback = function(state) espDistanceEnabled = state end })
UIElements.ToggleESPSkeleton = Tabs.ESP:Toggle({ Title = "ESP Esqueleto", Value = false, Callback = function(state) espSkeletonEnabled = state end })
UIElements.ToggleESPLines = Tabs.ESP:Toggle({ Title = "ESP Líneas", Value = false, Callback = function(state) espLinesEnabled = state end })

Tabs.ESP:Section({ Title = "Ocultar / Cambiar tu Nombre" })

local hideNameEnabled = false 
local fakeNameEnabled = false 
local rainbowEnabled = false 
local spoofNameText = "Nombre falso" 
local originalData = {}
local textScannerLoop = nil
local rainbowLoop = nil

-- ==========================================
-- SISTEMA DE NOMBRES (OPTIMIZADO CON EVENTOS)
-- ==========================================
local textConnections = {} -- Almacenará los eventos para limpiarlos sin lag

local function safeReplace(str, find, replace) 
    local safeFind = find:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1") 
    return (str:gsub(safeFind, replace)) 
end

local function processText(v, myName, myDisp)
    if not originalData[v] then return end
    if fakeNameEnabled then
        local newText = safeReplace(originalData[v].Text, myName, spoofNameText)
        newText = safeReplace(newText, myDisp, spoofNameText)
        v.Text = newText
        v.TextTransparency = originalData[v].TextTransp
        v.TextStrokeTransparency = originalData[v].StrokeTransp
        if not rainbowEnabled then v.TextColor3 = originalData[v].Color end
    elseif hideNameEnabled then
        v.Text = " "
        v.TextTransparency = 1
        v.TextStrokeTransparency = 1
    else
        v.Text = originalData[v].Text
        v.TextTransparency = originalData[v].TextTransp
        v.TextStrokeTransparency = originalData[v].StrokeTransp
        if not rainbowEnabled then v.TextColor3 = originalData[v].Color end
    end
end

-- 🚀 NUEVA FUNCIÓN: Solo se engancha a los textos necesarios
local function setupTextElement(v, myName, myDisp)
    -- 🔥 IGNORAMOS EL HUB PARA QUE LOS BOTONES NO SE CONGELEN
    local parentGui = v:FindFirstAncestorWhichIsA("ScreenGui")
    if parentGui and string.find(parentGui.Name, "WindUI") then return end

    if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
        -- 🔥 ESTA ES LA PROTECCIÓN QUE FALTA
        if v:GetAttribute("AstraInfectado") then return end
        v:SetAttribute("AstraInfectado", true)

    local function checkAndReplace()
            local txt = v.Text
            if txt and txt ~= "" and txt ~= " " and not string.find(txt, spoofNameText, 1, true) then
                if string.find(txt, myName, 1, true) or string.find(txt, myDisp, 1, true) then
                    if not originalData[v] then
                        originalData[v] = { Text = txt, Color = v.TextColor3, TextTransp = v.TextTransparency, StrokeTransp = v.TextStrokeTransparency }
                    else
                        originalData[v].Text = txt
                    end
                    processText(v, myName, myDisp)
                end
            end
        end
        
        checkAndReplace()
        
        if not textConnections[v] then
            textConnections[v] = v:GetPropertyChangedSignal("Text"):Connect(function()
                if originalData[v] and v.Text ~= " " and not string.find(v.Text, spoofNameText, 1, true) then
                    if string.find(v.Text, myName, 1, true) or string.find(v.Text, myDisp, 1, true) then
                        originalData[v].Text = v.Text
                        processText(v, myName, myDisp)
                    end
                end
            end)
        end
    end
end

local function updateSystem()
    local myName = player.Name 
    local myDisp = player.DisplayName
    local stateActive = hideNameEnabled or fakeNameEnabled or rainbowEnabled

    if stateActive then
        if not textScannerLoop then
            textScannerLoop = {} -- Lo usamos como bandera para saber que está encendido
            
            local function scanInitial()
                if player.Character then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
                    for _, v in ipairs(player.Character:GetDescendants()) do setupTextElement(v, myName, myDisp) end
                end
                local pGui = player:FindFirstChild("PlayerGui")
                if pGui then
                    for _, v in ipairs(pGui:GetDescendants()) do setupTextElement(v, myName, myDisp) end
                end
            end
            
            scanInitial()
            
            -- 🚀 OPTIMIZACIÓN: Solo escuchar cuando el juego agrega elementos nuevos
            local pGui = player:FindFirstChild("PlayerGui")
            if pGui then
                textScannerLoop.GuiConn = pGui.DescendantAdded:Connect(function(v) setupTextElement(v, myName, myDisp) end)
            end
            
            textScannerLoop.CharAddedConn = player.CharacterAdded:Connect(function(newChar)
                local hum = newChar:WaitForChild("Humanoid", 3)
                if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
                textScannerLoop.CharDescConn = newChar.DescendantAdded:Connect(function(v) setupTextElement(v, myName, myDisp) end)
                for _, v in ipairs(newChar:GetDescendants()) do setupTextElement(v, myName, myDisp) end
            end)
            
            if player.Character then
                textScannerLoop.CharDescConn = player.Character.DescendantAdded:Connect(function(v) setupTextElement(v, myName, myDisp) end)
            end
        else
            for v, _ in pairs(originalData) do if v.Parent then processText(v, myName, myDisp) end end
        end
        
        -- El Rainbow se queda en RenderStepped porque es ultra ligero al ser solo color
        if rainbowEnabled and not rainbowLoop then
            rainbowLoop = RunService.RenderStepped:Connect(function()
                local rColor = Color3.fromHSV(tick() % 4 / 4, 1, 1)
                for v, _ in pairs(originalData) do
                    if v.Parent then
                        if not hideNameEnabled then v.TextColor3 = rColor end
                    else
                        originalData[v] = nil
                    end
                end
            end)
        elseif not rainbowEnabled and rainbowLoop then
            rainbowLoop:Disconnect(); rainbowLoop = nil
            for v, data in pairs(originalData) do if v.Parent then v.TextColor3 = data.Color end end
        end
    else
        -- 🛑 APAGAR TODO LIMPIAMENTE
        if textScannerLoop then 
            if textScannerLoop.GuiConn then textScannerLoop.GuiConn:Disconnect() end
            if textScannerLoop.CharAddedConn then textScannerLoop.CharAddedConn:Disconnect() end
            if textScannerLoop.CharDescConn then textScannerLoop.CharDescConn:Disconnect() end
            textScannerLoop = nil 
        end
        if rainbowLoop then rainbowLoop:Disconnect(); rainbowLoop = nil end
        
        for _, conn in pairs(textConnections) do conn:Disconnect() end
        textConnections = {}
        
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
        end
        
        for v, data in pairs(originalData) do
            if v and v.Parent then
                v.Text = data.Text; v.TextColor3 = data.Color
                v.TextTransparency = data.TextTransp; v.TextStrokeTransparency = data.StrokeTransp
            end
        end
        originalData = {}
    end
end

UIElements.ToggleHideName = Tabs.ESP:Toggle({ Title = "Ocultar mi Nombre", Value = false, Callback = function(state) hideNameEnabled = state; updateSystem(); sendNotification(state and "Nombre invisible." or "Nombre visible.") end })
UIElements.ToggleFakeName = Tabs.ESP:Toggle({ Title = "Activar Nombre Falso", Value = false, Callback = function(state) fakeNameEnabled = state; updateSystem(); sendNotification(state and "Nombre falso activado." or "Nombre falso desactivado.") end })
Tabs.ESP:Input({ Title = "Escribir Nuevo Nombre", Placeholder = "Tu nuevo nombre falso...", Callback = function(Text) if Text ~= "" then spoofNameText = Text; if fakeNameEnabled then updateSystem() end; sendNotification("Nombre guardado: " .. spoofNameText) end end })
UIElements.ToggleRbName = Tabs.ESP:Toggle({ Title = "Efecto Rainbow en nombre", Value = false, Callback = function(state) rainbowEnabled = state; updateSystem() end })


-- 🔥 AGREGA ESTA LÍNEA AQUÍ (Ajusta el número a lo que necesites)
local MAX_ESP_DISTANCE = 1500

-- 🔥 DECLARAMOS LA CACHÉ AFUERA PARA QUE TODO EL SCRIPT LA VEA
local globalMurderer = nil
local globalSheriff = nil

local activeGunHighlight = nil
local activeGunBillboard = nil

-- ==========================================
-- 🚀 HILO MAESTRO DE OPTIMIZACIÓN (CERO LAG)
-- ==========================================
RunService.Heartbeat:Connect(function(deltaTime)
    local myChar = player.Character
    local myHrp = myChar and ffc(myChar, "HumanoidRootPart")
    if not myHrp then return end

    -- 1. AUTO STAB OPTIMIZADO (Sin lag, controlado por deltaTime)
    if autoStabEnabled then
        mState.stabAct = true
        mState.tStab = mState.tStab + deltaTime
        if mState.tStab >= 0.05 then
            mState.tStab = 0
            local knife = ffc(myChar, "Knife") or (player.Backpack and ffc(player.Backpack, "Knife"))
            if knife then
                for i = 1, #listaJugadores do
                    local p = listaJugadores[i]
                    if p ~= player and p.Character then
                        local pHrp = ffc(p.Character, "HumanoidRootPart")
                        local pHum = ffc(p.Character, "Humanoid")
                        if pHrp and pHum and pHum.Health > 0 then
                            if (myHrp.Position - pHrp.Position).Magnitude <= 6 then
                                if knife.Parent == player.Backpack then
                                    myChar.Humanoid:EquipTool(knife)
                                end
                                pcall(function()
                                    knife.Events.KnifeStabbed:FireServer()
                                    knife.Events.HandleTouched:FireServer(pHrp)
                                end)
                            end
                        end
                    end
                end
            end
        end
    elseif mState.stabAct then
        mState.stabAct = false
        mState.tStab = 0
    end

    -- 2. KILL AURA OPTIMIZADO
    if killAuraEnabled then
        mState.auraAct = true
        mState.tAura = mState.tAura + deltaTime
        if mState.tAura >= 0.15 then
            mState.tAura = 0
            local knife = ffc(myChar, "Knife") or (player.Backpack and ffc(player.Backpack, "Knife"))
            if knife then
                local targetInRange = false
                for i = 1, #listaJugadores do
                    local p = listaJugadores[i]
                    if p ~= player and p.Character then
                        local pHrp = ffc(p.Character, "HumanoidRootPart")
                        local pHum = ffc(p.Character, "Humanoid")
                        if pHrp and pHum and pHum.Health > 0 then
                            local dist = (pHrp.Position - myHrp.Position).Magnitude
                            local head = ffc(p.Character, "Head")
                            if head then
                                local billboard = ffc(head, "AstraMarca")
                                if dist <= killAuraRadius then
                                    targetInRange = true
                                    if not billboard then
                                        billboard = Instance.new("BillboardGui") 
                                        billboard.Name = "AstraMarca" 
                                        billboard.Size = UDim2.new(0, 120, 0, 40) 
                                        billboard.StudsOffset = Vector3.new(0, 3, 0) 
                                        billboard.AlwaysOnTop = true 
                                        billboard.Parent = head
                                        local txt = Instance.new("TextLabel") 
                                        txt.Size = UDim2.new(1, 0, 1, 0) 
                                        txt.BackgroundTransparency = 1 
                                        txt.Text = "EN RANGO" 
                                        txt.TextColor3 = Color3.fromRGB(168, 199, 250) 
                                        txt.TextStrokeTransparency = 0 
                                        txt.Font = Enum.Font.GothamBlack 
                                        txt.TextSize = 14 
                                        txt.Parent = billboard
                                    end
                                    if knife.Parent == player.Backpack then 
                                        myChar.Humanoid:EquipTool(knife) 
                                        task.wait(0.05) 
                                    end
                                    pcall(function() 
                                        knife.Events.KnifeStabbed:FireServer() 
                                        knife.Events.HandleTouched:FireServer(pHrp) 
                                    end)
                                else 
                                    if billboard then billboard:Destroy() end 
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif mState.auraAct then
        mState.auraAct = false
        mState.tAura = 0
        for i = 1, #listaJugadores do
            local p = listaJugadores[i]
            if p and p.Character then
                local h = ffc(p.Character, "Head")
                if h and ffc(h, "AstraMarca") then ffc(h, "AstraMarca"):Destroy() end
            end
        end
    end

    -- 3. ESP DE JUGADORES Y ARMA TIRADA (0.2s)
    if espEnabled or gunDropESP then
        mState.espAct = true
        mState.tESP = mState.tESP + deltaTime
        if mState.tESP >= 0.20 then
            mState.tESP = 0
            
            globalMurderer = findMurderer()
            globalSheriff = findSheriff()
            local currentMap = getMap()

            -- Procesar ESP de Jugadores
            if espEnabled then
                for i = 1, #listaJugadores do
                    local p = listaJugadores[i]
                    if p ~= player then
                        local char = p.Character
                        local hrp = char and ffc(char, "HumanoidRootPart")
                        local isAlive = hrp and ffc(char, "Humanoid") and char.Humanoid.Health > 0
                        
                        if isAlive then
                            local dist = (myHrp.Position - hrp.Position).Magnitude
                            if dist <= MAX_ESP_DISTANCE then
                                local roleColor = espColors.Innocent
                                if p == globalMurderer then roleColor = espColors.Murderer 
                                elseif p == globalSheriff then roleColor = espColors.Sheriff end

                                if activeESPs[p] and activeESPs[p].Char ~= char then cleanESP(p) end

                                if not activeESPs[p] then
                                    local highlight = Instance.new("Highlight") 
                                    highlight.Name = p.Name.."_Glow" 
                                    highlight.FillTransparency = 0.4
                                    highlight.OutlineTransparency = 1 
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                                    highlight.Adornee = char 
                                    highlight.Parent = espFolder
                                    
                                    local billboard = Instance.new("BillboardGui") 
                                    billboard.Name = p.Name.."_Tag" 
                                    billboard.Size = UDim2.new(0, 200, 0, 75)
                                    billboard.StudsOffset = Vector3.new(0, 3.5, 0) 
                                    billboard.AlwaysOnTop = true 
                                    billboard.Adornee = ffc(char, "Head") or hrp 
                                    billboard.Parent = espFolder
                                    
                                    local textLabel = Instance.new("TextLabel") 
                                    textLabel.Size = UDim2.new(1, 0, 1, 0) 
                                    textLabel.BackgroundTransparency = 1 
                                    textLabel.TextStrokeTransparency = 1 
                                    textLabel.RichText = true 
                                    textLabel.Font = Enum.Font.SourceSansBold
                                    textLabel.TextSize = 14 
                                    textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
                                    textLabel.Parent = billboard

                                    local stroke = Instance.new("UIStroke")
                                    stroke.Color = Color3.fromRGB(0, 0, 0)
                                    stroke.Thickness = 1.2
                                    stroke.Parent = textLabel
                                    
                                    activeESPs[p] = {Highlight = highlight, Char = char, Billboard = billboard, Text = textLabel}
                                end

                                local espObj = activeESPs[p]
                                espObj.Highlight.FillColor = roleColor
                                espObj.Highlight.OutlineColor = roleColor
                                
                                local infoText = ""
                                if espNamesEnabled then 
                                    local r = math.floor((roleColor.R * 255) + 0.5)
                                    local g = math.floor((roleColor.G * 255) + 0.5)
                                    local b = math.floor((roleColor.B * 255) + 0.5)
                                    local hexESP = string.format("#%02X%02X%02X", r, g, b)
                                    
                                    local etiquetaRol = ""
                                    if p == globalMurderer then etiquetaRol = " <b>[MURDERER]</b>"
                                    elseif p == globalSheriff then etiquetaRol = " <b>[SHERIFF]</b>" end
                                    
                                    infoText = '<font color="' .. hexESP .. '">' .. p.Name .. etiquetaRol .. '</font>' 
                                end
                                if espDistanceEnabled then
                                    local separador2 = infoText == "" and "" or "\n"
                                    infoText = infoText .. separador2 .. '<font size="11" color="#bdc3c7">' .. math.floor(dist) .. 'm</font>'
                                end
                                
                                if infoText ~= "" then
                                    espObj.Text.Text = infoText
                                    espObj.Billboard.Enabled = true
                                else
                                    espObj.Billboard.Enabled = false
                                end
                            else cleanESP(p) end
                        else cleanESP(p) end
                    end
                end
            else
                for i = 1, #listaJugadores do cleanESP(listaJugadores[i]) end 
            end

            -- Procesar ESP Arma Tirada
            if currentMap then
                local gunDrop = ffc(currentMap, "GunDrop")
                if gunDrop then
                    if notifyGunDropEnabled and not gunDroppedNotified then
                        sendNotification("La pistola esta tirada")
                        gunDroppedNotified = true
                    end
                    if gunDropESP then
                        local dist = (myHrp.Position - gunDrop.Position).Magnitude
                        if dist <= MAX_ESP_DISTANCE then
                            if not activeGunHighlight then
                                activeGunHighlight = Instance.new("Highlight")
                                activeGunHighlight.Name = "Astra_GunDropESP"
                                activeGunHighlight.FillColor = Color3.fromRGB(255, 255, 0)
                                activeGunHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                                activeGunHighlight.FillTransparency = 0.4
                                activeGunHighlight.OutlineTransparency = 1 
                                activeGunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                activeGunHighlight.Parent = espFolder 

                                activeGunBillboard = Instance.new("BillboardGui")
                                activeGunBillboard.Name = "Astra_GunTextESP"
                                activeGunBillboard.Size = UDim2.new(0, 100, 0, 50) 
                                activeGunBillboard.StudsOffset = Vector3.new(0, 2.5, 0) 
                                activeGunBillboard.AlwaysOnTop = true
                                activeGunBillboard.Parent = espFolder
                                
                                local gunLabel = Instance.new("TextLabel")
                                gunLabel.Name = "GunText"
                                gunLabel.Size = UDim2.new(1, 0, 1, 0)
                                gunLabel.BackgroundTransparency = 1
                                gunLabel.RichText = true 
                                gunLabel.Text = "GUN"
                                gunLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                                gunLabel.Font = Enum.Font.SourceSansBold
                                gunLabel.TextSize = 16
                                gunLabel.TextYAlignment = Enum.TextYAlignment.Bottom
                                
                                local gunStroke = Instance.new("UIStroke")
                                gunStroke.Color = Color3.fromRGB(0, 0, 0)
                                gunStroke.Thickness = 1.2
                                gunStroke.Parent = gunLabel
                                gunLabel.Parent = activeGunBillboard
                            end
                            
                            if activeGunHighlight.Adornee ~= gunDrop then
                                activeGunHighlight.Adornee = gunDrop
                                activeGunBillboard.Adornee = gunDrop
                            end
                            
                            if activeGunBillboard then
                                local txtLabel = ffc(activeGunBillboard, "GunText")
                                if txtLabel then
                                    local baseText = "GUN"
                                    if espDistanceEnabled then
                                        baseText = baseText .. '\n<font size="12" color="#bdc3c7">' .. math.floor(dist) .. 'm</font>'
                                    end
                                    txtLabel.Text = baseText
                                end
                            end
                        else
                            if activeGunHighlight then activeGunHighlight:Destroy(); activeGunHighlight = nil end
                            if activeGunBillboard then activeGunBillboard:Destroy(); activeGunBillboard = nil end
                        end
                    else
                        if activeGunHighlight then activeGunHighlight:Destroy(); activeGunHighlight = nil end
                        if activeGunBillboard then activeGunBillboard:Destroy(); activeGunBillboard = nil end
                    end
                else
                    gunDroppedNotified = false 
                    if activeGunHighlight then activeGunHighlight:Destroy(); activeGunHighlight = nil end
                    if activeGunBillboard then activeGunBillboard:Destroy(); activeGunBillboard = nil end
                end
            else
                gunDroppedNotified = false
                if activeGunHighlight then activeGunHighlight:Destroy(); activeGunHighlight = nil end
                if activeGunBillboard then activeGunBillboard:Destroy(); activeGunBillboard = nil end
            end
        end
    elseif mState.espAct then
        mState.espAct = false
        mState.tESP = 0
        for i = 1, #listaJugadores do cleanESP(listaJugadores[i]) end
        if activeGunHighlight then activeGunHighlight:Destroy(); activeGunHighlight = nil end
        if activeGunBillboard then activeGunBillboard:Destroy(); activeGunBillboard = nil end
    end
end)

-- ==========================================
-- 2. SISTEMA DRAWING 2D (Esqueleto y Líneas Tracers) OPTIMIZADO
-- ==========================================
-- 🔥 VARIABLES QUE FALTABAN
local skeletonLines = {}
local tracerLines = {}
local skeletonJoints = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, 
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local MAX_RENDER_DISTANCE = 250 -- Límite de studs para dibujar líneas

RunService.RenderStepped:Connect(function()
    -- 🔥 JALAMOS LA CACHÉ GLOBAL
    local murderer = globalMurderer
    local sheriff = globalSheriff
    local screenSize = camera.ViewportSize

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            -- Crear líneas si no existen
            if not skeletonLines[p] then
                skeletonLines[p] = {}
                for i = 1, #skeletonJoints do
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5; line.Transparency = 1; line.Visible = false
                    table.insert(skeletonLines[p], line)
                end
            end
            if not tracerLines[p] then
                local tLine = Drawing.new("Line")
                tLine.Thickness = 1.5; tLine.Transparency = 1; tLine.Visible = false
                tracerLines[p] = tLine
            end
            
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local isAlive = hrp and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
            
            if isAlive and (espSkeletonEnabled or espLinesEnabled) then
                -- 🚀 OPTIMIZACIÓN 1: Solo calcular la HRP primero
                local hrpPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                local dist = (camera.CFrame.Position - hrp.Position).Magnitude
                
                -- 🚀 OPTIMIZACIÓN 2: Si no está en pantalla o está muy lejos, apagar todo y saltar matemáticas
                if onScreen and dist <= MAX_RENDER_DISTANCE then
                    
                    -- 🔥 FIX DE COLORES AQUÍ WE:
                    -- Ahora usa tu tabla de espColors en lugar de los colores fijos
                    local roleColor = espColors.Innocent 
                    if p == murderer then 
                        roleColor = espColors.Murderer 
                    elseif p == sheriff then 
                        roleColor = espColors.Sheriff 
                    end
                    
                    if espLinesEnabled then
                        tracerLines[p].From = Vector2.new(screenSize.X / 2, 0)
                        tracerLines[p].To = Vector2.new(hrpPos.X, hrpPos.Y)
                        tracerLines[p].Color = roleColor
                        tracerLines[p].Visible = true
                    else
                        tracerLines[p].Visible = false
                    end

                    if espSkeletonEnabled then
                        for i, joint in ipairs(skeletonJoints) do
                            local part1 = char:FindFirstChild(joint[1])
                            local part2 = char:FindFirstChild(joint[2])
                            local line = skeletonLines[p][i]
                            
                            if part1 and part2 then
                                local pos1, vis1 = camera:WorldToViewportPoint(part1.Position)
                                local pos2, vis2 = camera:WorldToViewportPoint(part2.Position)
                                if vis1 or vis2 then
                                    line.From = Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Color = roleColor
                                    line.Visible = true
                                else 
                                    line.Visible = false 
                                end
                            else 
                                line.Visible = false 
                            end
                        end
                    else
                        for _, line in ipairs(skeletonLines[p]) do line.Visible = false end
                    end
                else
                    -- Apagar si está fuera de cámara
                    for _, line in ipairs(skeletonLines[p]) do line.Visible = false end
                    tracerLines[p].Visible = false
                end
            else
                for _, line in ipairs(skeletonLines[p]) do line.Visible = false end
                tracerLines[p].Visible = false
            end
        end
    end
end)

-- 🔥 IMPORTANTE: Limpiador de basura cuando los jugadores se salen
Players.PlayerRemoving:Connect(function(p) 
    cleanESP(p) 
    if skeletonLines[p] then
        for _, line in ipairs(skeletonLines[p]) do line:Remove() end
        skeletonLines[p] = nil
    end
    if tracerLines[p] then
        tracerLines[p]:Remove()
        tracerLines[p] = nil
    end
end)



local genesisSheriffCargado = false local genesisMurderCargado = false
task.wait() 

Tabs.Sheriff:Section({ Title = "Aimbot Predict" })

local showCrosshairEnabled = true -- Que se vea por defecto

UIElements.ToggleMira = Tabs.Sheriff:Toggle({
    Title = "Mostrar mira del aimbot", 
    Desc = "Dibuja el punto/cruz visual donde el aimbot está apuntando (Independiente del Aimlock).",
    Value = true,
    Callback = function(state)
        showCrosshairEnabled = state
    end
})

-- ==========================================
-- 🔫 AUTOSHOOT PREDICTIVO
-- ==========================================
UIElements.ToggleAutoShoot = Tabs.Sheriff:Toggle({ 
    Title = "AutoShoot Predictivo", 
    Desc = "Disparo automático al equipar el arma.",
    Value = false,
    Callback = function(state)
        if getgenv().NathConfig then getgenv().NathConfig.AutoShoot = state end
        
        -- Solo mandamos la notificación de "desactivado por AutoShoot" si realmente estaba prendido el Aimlock
        if state and aimlockConCandadoHabilitado then
            pcall(function() UIElements.ToggleNativeAimlock:Set(false) end)
            sendNotification("Aimlock desactivado por AutoShoot.")
        else
            sendNotification(state and "AutoShoot: ACTIVADO" or "AutoShoot: DESACTIVADO")
        end
    end
})

-- ==========================================
-- 🎯 BOTONES FLOTANTES DE DISPARO (IA)
-- ==========================================
-- Creamos el botón (SIN TEXTO VISIBLE)
local aiFloatingShoot, getShootClick, shootStroke = createFloatingBtn("", UDim2.new(0.8, -150, 0.4, 0), "BtnShootIA")

-- ✨ ICONO GIRATORIO INTELIGENTE (GRANDE Y EN MEDIO) ✨
local shootIcon = Instance.new("ImageLabel")
shootIcon.Size = UDim2.new(0, 32, 0, 32) 
shootIcon.Position = UDim2.new(0.5, 0, 0.5, 0) 
shootIcon.AnchorPoint = Vector2.new(0.5, 0.5) 
shootIcon.BackgroundTransparency = 1
shootIcon.Image = "rbxassetid://81532770001828"
shootIcon.ImageColor3 = Color3.fromRGB(255, 255, 255) 
shootIcon.ZIndex = 51
shootIcon.Parent = aiFloatingShoot

-- Animación de giro infinita
local spinInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
game:GetService("TweenService"):Create(shootIcon, spinInfo, {Rotation = 360}):Play()

-- Lógica del disparo
aiFloatingShoot.MouseButton1Click:Connect(function()
    if not getShootClick() then return end
    if getgenv().DispararEventoDirecto then getgenv().DispararEventoDirecto(true) end
end)

local aiFloatingToggle, getTogClick, togStroke = createFloatingBtn("AutoShoot: OFF", UDim2.new(0.8, -150, 0.5, 0), "BtnToggleIA")
aiFloatingToggle.MouseButton1Click:Connect(function()
    if not getTogClick() then return end
    if getgenv().NathConfig then
        local newState = not getgenv().NathConfig.AutoShoot
        getgenv().NathConfig.AutoShoot = newState
        aiFloatingToggle.Text = newState and "AutoShoot: ON" or "AutoShoot: OFF"
        aiFloatingToggle.TextColor3 = newState and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
    end
end)

UIElements.ToggleShootBtn = Tabs.Sheriff:Toggle({
    Title = "Mostrar Botón de disparo",
    Desc = "Botón flotante para disparar manualmente (Solo funciona con el Aimbot Predict).",
    Value = false,
    Callback = function(state) aiFloatingShoot.Visible = state end
})

Tabs.Sheriff:Toggle({
    Title = "Mostrar Botón Flotante Autoshoot",
    Desc = "Activa/Desactiva el AutoShoot rápido sin tener que abrir el menú.",
    Value = false,
    Callback = function(state) aiFloatingToggle.Visible = state end
})

Tabs.Sheriff:Dropdown({
    Title = "Estilo de Mira Aimbot",
    Values = {"Punto", "Cruz", "Anillo"},
    Value = "Punto",
    Callback = function(Value)
        if Value == "Punto" then _G.OnyxCrosshairType = 1
        elseif Value == "Cruz" then _G.OnyxCrosshairType = 2
        elseif Value == "Anillo" then _G.OnyxCrosshairType = 3 end
    end
})

-- ==========================================
-- 🔒 AIMLOCK NATIVO AL MURDERER (CANDADO)
-- ==========================================
local aimlockActiveLoop = false
local aimlockConCandadoHabilitado = false

UIElements.ToggleNativeAimlock = Tabs.Sheriff:Toggle({
    Title = "Aimlock",
    Desc = "Apunta al Murderer al usar Shiftlock.",
    Value = false,
    Callback = function(state)
        aimlockConCandadoHabilitado = state
        
        -- Solo apagamos el AutoShoot y avisamos si realmente estaba prendido
        if state and getgenv().NathConfig and getgenv().NathConfig.AutoShoot then
            pcall(function() UIElements.ToggleAutoShoot:Set(false) end)
            sendNotification("AutoShoot desactivado por Aimlock.")
        else
            sendNotification(state and "Aimlock: HABILITADO" or "Aimlock: DESHABILITADO")
        end

        -- Apagar de emergencia
        if not state and aimlockActiveLoop then
            aimlockActiveLoop = false
            pcall(function() RunService:UnbindFromRenderStep("AstraAimlockLoop") end)
        end
    end
})

UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
    -- Si el VIP no activó el Aimlock en el menú, ignoramos todo
    if not aimlockConCandadoHabilitado then return end

    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        if not aimlockActiveLoop then
            aimlockActiveLoop = true
            
            -- Usamos prioridad alta para tener la última orden sobre la cámara
            RunService:BindToRenderStep("AstraAimlockLoop", Enum.RenderPriority.Camera.Value + 2, function()
                local myChar = player.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                -- 1. Validar que estemos vivos y renderizados
                if not myHrp or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end
                
                -- 2. Validar que tengamos un arma (estamos en partida)
                local hasGun = myChar:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun"))
                if not hasGun then return end
                
                -- 3. Buscar al Murderer
                local targetMurder = findMurderer()
                if targetMurder and targetMurder.Character and targetMurder.Character:FindFirstChild("HumanoidRootPart") then
                    
                    -- 🔥 FIX: Candado absoluto. 
                    -- Quitamos el Lerp y forzamos la cámara a mirar al Murderer al instante.
                    -- Esto anula por completo el movimiento manual del mouse.
                    local targetPos = targetMurder.Character.HumanoidRootPart.Position
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                end
            end)
        end
    else
        -- Soltamos la cámara limpiamente al quitar el shiftlock
        if aimlockActiveLoop then
            aimlockActiveLoop = false
            pcall(function() RunService:UnbindFromRenderStep("AstraAimlockLoop") end)
        end
    end
end)



task.wait() 

Tabs.Murderer:Section({ Title = "Ataques Rápidos" })


local autoStabEnabled = false

UIElements.TogAutoStab = Tabs.Murderer:Toggle({
    Title = "Auto Stab",
    Desc = "Apuñala en automático.",
    Value = false,
    Callback = function(state)
        autoStabEnabled = state
        sendNotification(state and "Auto Stab: ACTIVADO" or "Auto Stab: DESACTIVADO")
    end
})



Tabs.Murderer:Button({ 
    Title = "Matar a Todos", 
    Desc = "Mata a todos al instante.", -- ✅ AQUÍ VA EL DESC
    Callback = function()
        local char = player.Character if not char then return end
        local knife = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
        if not knife then sendNotification("No tienes cuchillo.") return end
        if knife.Parent == player.Backpack then char.Humanoid:EquipTool(knife) task.wait(0.1) end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                pcall(function() knife.Events.KnifeStabbed:FireServer() knife.Events.HandleTouched:FireServer(p.Character.HumanoidRootPart) end)
            end
        end
        sendNotification("Kill all activado.")
    end
})

Tabs.Murderer:Button({ 
    Title = "Matar al Sheriff", 
    Desc = "Mata al Sheriff directamente.", -- ✅ AQUÍ VA EL DESC
    Callback = function()
        local char = player.Character if not char then return end
        local knife = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
        if not knife then sendNotification("No tienes cuchillo.") return end
        local targetSheriff = findSheriff() if not targetSheriff or not targetSheriff.Character then sendNotification("No hay sheriff.") return end
        if knife.Parent == player.Backpack then char.Humanoid:EquipTool(knife) task.wait(0.1) end
        pcall(function() knife.Events.KnifeStabbed:FireServer() knife.Events.HandleTouched:FireServer(targetSheriff.Character.HumanoidRootPart) end)
        sendNotification("Sheriff muerto.")
    end
})

Tabs.Murderer:Section({ Title = "Matar a jugador" })
local targetToKill = nil
local KillDropdown = Tabs.Murderer:Dropdown({ Title = "Seleccionar Jugador", Values = {"Esperando carga..."}, Value = "Esperando carga...", Callback = function(value) targetToKill = value end })
Tabs.Murderer:Button({ Title = "Actualizar Lista", Callback = function()
    local playerNames = {} for _, p in pairs(Players:GetPlayers()) do if p ~= player then table.insert(playerNames, p.Name) end end
    KillDropdown:Refresh(playerNames) KillDropdown:Select(playerNames[1]) sendNotification("Lista actualizada.")
end})
Tabs.Murderer:Button({ Title = "Matar Jugador", Callback = function()
    if not targetToKill then return end
    local char = player.Character local knife = char and (char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife"))
    if not knife then return end
    local tp = Players:FindFirstChild(targetToKill)
    if tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart") then
        if knife.Parent == player.Backpack then char.Humanoid:EquipTool(knife) task.wait(0.1) end
        pcall(function() knife.Events.KnifeStabbed:FireServer() knife.Events.HandleTouched:FireServer(tp.Character.HumanoidRootPart) end)
        sendNotification("Muerto: " .. tp.Name)
    end
end})

local killAuraRadius = 25
Tabs.Murderer:Section({ Title = "Kill Aura" })
UIElements.ToggleAura = Tabs.Murderer:Toggle({ Title = "Kill Aura", Desc = "Mata a jugadores cercanos", Value = false, Callback = function(state) killAuraEnabled = state end })

UIElements.SliderAura = Tabs.Murderer:Slider({ 
    Title = "Radio del Aura", 
    Step = 1, 
    Value = {Min = 10, Max = 100, Default = 25}, 
    Callback = function(Value) 
        killAuraRadius = Value 
    end 
})



Tabs.AutoFarm:Section({ Title = "Auto Farm de Monedas" })
local farmSpeed = 28; local currentTargetCoin = nil; local collectedCoins = {} 

local function isPlayerInLobby(hrp)
    local map = getMap() local lobby = workspace:FindFirstChild("Lobby")
    if not map then return true end
    local distToLobby = 999999 if lobby and lobby:FindFirstChild("Spawns") then local lobbySpawn = lobby.Spawns:GetChildren()[1] if lobbySpawn then distToLobby = (hrp.Position - lobbySpawn.Position).Magnitude end end
    local distToMap = 999999 if map:FindFirstChild("Spawns") then local mapSpawn = map.Spawns:GetChildren()[1] if mapSpawn then distToMap = (hrp.Position - mapSpawn.Position).Magnitude end end
    return distToLobby < distToMap
end

local function isBagFull()
    local bagFull = false
    pcall(function()
        local mainGui = player.PlayerGui:FindFirstChild("MainGUI") if not mainGui then return end
        local coinLabel = mainGui:FindFirstChild("Lobby") and mainGui.Lobby:FindFirstChild("Dock") and mainGui.Lobby.Dock:FindFirstChild("CoinBags") and mainGui.Lobby.Dock.CoinBags:FindFirstChild("Container") and mainGui.Lobby.Dock.CoinBags.Container:FindFirstChild("Coin") and mainGui.Lobby.Dock.CoinBags.Container.Coin:FindFirstChild("CurrencyFrame") and mainGui.Lobby.Dock.CoinBags.Container.Coin.CurrencyFrame:FindFirstChild("Icon") and mainGui.Lobby.Dock.CoinBags.Container.Coin.CurrencyFrame.Icon:FindFirstChild("Coins")
        if coinLabel and coinLabel:IsA("TextLabel") then
            local txtLimpio = string.lower(string.gsub(coinLabel.Text, "<.->", ""))
            if txtLimpio == "max" or txtLimpio == "full" or string.find(txtLimpio, "complet") then 
                bagFull = true 
                return 
            end
            -- Detección matemática por si dice "40/40" o "50/50"
            local current, max = string.match(txtLimpio, "(%d+)/(%d+)")
            if current and max and tonumber(current) >= tonumber(max) then
                bagFull = true
            end
        end
    end)
    return bagFull
end

local farmNoclip = nil 
local function stopFarming(char, hrp, teleportBack)
    coinAutoCollect = false; currentTargetCoin = nil
    if farmNoclip then farmNoclip:Disconnect(); farmNoclip = nil end
    
    if hrp then 
        local bv = hrp:FindFirstChild("AstraFarmBV") if bv then bv:Destroy() end 
        local bg = hrp:FindFirstChild("AstraFarmBG") if bg then bg:Destroy() end 
        hrp.Anchored = false 
        hrp.AssemblyLinearVelocity = Vector3.zero 
        hrp.AssemblyAngularVelocity = Vector3.zero 
    end
    
    task.wait(0.1) 
    if char then 
        for _, part in pairs(char:GetDescendants()) do 
            if part:IsA("BasePart") then part.CanCollide = true end 
        end 
        if char:FindFirstChild("Humanoid") then 
            char.Humanoid.PlatformStand = false 
            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) 
        end 
    end

    -- SISTEMA DE RETORNO AUTOMÁTICO SEGURO (Solo si se activó el trigger de fin)
    if teleportBack and hrp then
        task.wait(0.1)
        local map = getMap()
        local lobby = workspace:FindFirstChild("Lobby")
        
        if map and map:FindFirstChild("Spawns") and not isBagFull() then
            -- Si se acabó el farm pero la partida sigue (ej: solo le picaste apagar)
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then hrp.CFrame = spawns[math.random(1, #spawns)].CFrame + Vector3.new(0, 3, 0) end
        elseif lobby and lobby:FindFirstChild("Spawns") then
            -- Si se llenó la bolsa o se acabó la partida -> AL LOBBY
            local spawns = lobby.Spawns:GetChildren()
            if #spawns > 0 then hrp.CFrame = spawns[math.random(1, #spawns)].CFrame + Vector3.new(0, 3, 0) end
        end
    end
end

local ToggleFarmObj = Tabs.AutoFarm:Toggle({ 
    Title = "Auto-Recolectar Monedas", 
    Value = false, 
    Callback = function(state)
        local char = player.Character local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if state then 
            local map = getMap()
            if not map or (hrp and isPlayerInLobby(hrp)) then 
                sendNotification("Debes estar dentro de la partida para farmear.") 
                if ToggleFarmObj and type(ToggleFarmObj) == "table" and ToggleFarmObj.Set then ToggleFarmObj:Set(false) end
                coinAutoCollect = false
                return 
            end
            if isBagFull() then 
                sendNotification("Bolsa llena.") 
                if ToggleFarmObj and type(ToggleFarmObj) == "table" and ToggleFarmObj.Set then ToggleFarmObj:Set(false) end
                coinAutoCollect = false
                return 
            end
            
            collectedCoins = {}; coinAutoCollect = true; sendNotification("Farmeando monedas...")
            if not farmNoclip then farmNoclip = RunService.Stepped:Connect(function() if player.Character then for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) end
        else 
            stopFarming(char, hrp, true) 
        end
    end
})
UIElements.ToggleFarm = ToggleFarmObj

task.spawn(function()
    local skipCoins = {}; local targetStartTime = 0
    while task.wait(0.05) do
        pcall(function()
            if not coinAutoCollect then return end
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            local char = player.Character; local hrp = char.HumanoidRootPart; local hum = char:FindFirstChild("Humanoid"); 
            local map = getMap()
            
            -- DETECCIÓN DE FIN DE PARTIDA Y BOLSA LLENA
            if not map or isPlayerInLobby(hrp) or isBagFull() then 
                if isBagFull() then sendNotification("Bolsa llena, regresando al lobby...")
                else sendNotification("Partida terminada, regresando al lobby...") end
                
                -- Apagamos la UI y regresamos seguro
                if ToggleFarmObj and type(ToggleFarmObj) == "table" and ToggleFarmObj.Set then ToggleFarmObj:Set(false) end
                stopFarming(char, hrp, true) 
                return 
            end
            
            -- LIMPIEZA DE MONEDAS FANTASMAS
            if currentTargetCoin then
                if not currentTargetCoin.Parent or currentTargetCoin.Transparency >= 1 then
                    currentTargetCoin = nil
                end
            end

            for coin, t in pairs(skipCoins) do if not coin or not coin.Parent or (tick() - t) > 6 then skipCoins[coin] = nil end end
            local closestCoin = nil; local shortestDistance = math.huge
            local coinContainer = map:FindFirstChild("CoinContainer") or map:FindFirstChild("CoinAreas") or map
            
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetDescendants()) do
                    if coin:IsA("BasePart") and not skipCoins[coin] then
                        local isValidCoin = false
                        -- REGRESAMOS AL CÓDIGO 100% ESTABLE (Sin check de transparencia en mallas)
                        if (coin.Name == "Coin_Server" or coin.Name == "CoinServer") and coin:FindFirstChild("CoinVisual") then isValidCoin = true 
                        elseif coin.Name == "Coin" and coin.Transparency < 1 then isValidCoin = true end
                        
                        if isValidCoin then 
                            local dist = (hrp.Position - coin.Position).Magnitude 
                            if dist < shortestDistance then 
                                shortestDistance = dist; closestCoin = coin 
                            end 
                        end
                    end
                end
            end
            
            if closestCoin then
                if closestCoin ~= currentTargetCoin then 
                    currentTargetCoin = closestCoin; targetStartTime = tick() 
                elseif (tick() - targetStartTime) > 3 then 
                    skipCoins[closestCoin] = tick(); currentTargetCoin = nil 
                    return 
                end
                
                if hum then hum.PlatformStand = true end
                for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                local farmBv = hrp:FindFirstChild("AstraFarmBV") if not farmBv then farmBv = Instance.new("BodyVelocity") farmBv.Name = "AstraFarmBV" farmBv.MaxForce = Vector3.new(9e9, 9e9, 9e9) farmBv.Parent = hrp end
                local farmBg = hrp:FindFirstChild("AstraFarmBG") if not farmBg then farmBg = Instance.new("BodyGyro") farmBg.Name = "AstraFarmBG" farmBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) farmBg.P = 9e4 farmBg.Parent = hrp end
                
                local targetPos = Vector3.new(closestCoin.Position.X, closestCoin.Position.Y - 4.5, closestCoin.Position.Z)
                local distance = (targetPos - hrp.Position).Magnitude
                
                if distance > 2 then
                    local direction = (targetPos - hrp.Position).Unit 
                    farmBv.Velocity = direction * farmSpeed 
                    farmBg.CFrame = CFrame.new(hrp.Position, hrp.Position + direction) * CFrame.Angles(math.rad(90), 0, 0)
                else
                    farmBv.Velocity = Vector3.zero
                    if firetouchinterest then pcall(function() for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then firetouchinterest(part, closestCoin, 0) firetouchinterest(part, closestCoin, 1) end end end) end
                    task.wait(0.1) skipCoins[closestCoin] = tick(); currentTargetCoin = nil
                end
            else
                -- Si no hay monedas de momento, nos quedamos quietos en el aire
                local farmBv = hrp:FindFirstChild("AstraFarmBV") 
                if farmBv then farmBv.Velocity = Vector3.zero end
            end
        end) 
    end
end)

task.wait() -- 🔥 AÑADE ESTO
Tabs.Teleport:Section({ Title = "Teletransporte" })
Tabs.Teleport:Button({ Title = "Teletransportarse al Lobby", Callback = function()
    local char = player.Character if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(-108, 145, 20) end
end})
Tabs.Teleport:Button({ Title = "Teletransportarse al Mapa", Callback = function()
    local map = getMap() if map and map:FindFirstChild("Spawns") then player.Character.HumanoidRootPart.CFrame = map.Spawns:GetChildren()[1].CFrame end
end})
Tabs.Teleport:Button({ Title = "Teletransportarse al Arma Tirada", Callback = function()
    local map = getMap() if map and map:FindFirstChild("GunDrop") then player.Character.HumanoidRootPart.CFrame = map.GunDrop.CFrame end
end})

UIElements.ToggleAutoGun = Tabs.Teleport:Toggle({ Title = "Auto agarrar arma tirada", Value = false, Callback = function(state) autoGetDroppedGun = state end })
task.spawn(function()
    while task.wait(0.1) do
        if autoGetDroppedGun and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if not isPlayerInLobby(hrp) and findMurderer() ~= player then
                local map = getMap()
                if map and map:FindFirstChild("GunDrop") then
                    local origCFrame = hrp.CFrame; hrp.CFrame = map.GunDrop.CFrame; task.wait(0.15); hrp.CFrame = origCFrame
                end
            end
        end
    end
end)

Tabs.Teleport:Section({ Title = "Teleport a Jugador" })
local targetToTp = nil
local TpDropdown = Tabs.Teleport:Dropdown({ Title = "Seleccionar Jugador", Values = {"Esperando carga..."}, Value = "Esperando carga...", Callback = function(value) targetToTp = value end })
Tabs.Teleport:Button({ Title = "Actualizar Lista", Callback = function()
    local playerNames = {} for _, p in pairs(Players:GetPlayers()) do if p ~= player then table.insert(playerNames, p.Name) end end
    TpDropdown:Refresh(playerNames) TpDropdown:Select(playerNames[1])
end})
Tabs.Teleport:Button({ Title = "Ir al Jugador", Callback = function()
    if not targetToTp then return end
    local targetPlayer = Players:FindFirstChild(targetToTp)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end})

task.wait() -- 🔥 AÑADE ESTO
Tabs.Movimiento:Section({ Title = "Fly, Noclip y WalkSpeed" })
-- ==========================================
-- 🕊️ FIX: FLY (Persistente)
-- ==========================================
local flying = false
local flySpeed = 50
local bg, bv

-- Función maestra para inyectar físicas
local function inyectarVuelo(char)
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    local hum = char:WaitForChild("Humanoid", 3)
    
    if hrp and hum and flying then
        -- Limpiamos basuras viejas por si acaso
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        
        bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame
        bg.Parent = hrp
        
        bv = Instance.new("BodyVelocity")
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        
        hum.PlatformStand = true
    end
end

UIElements.ToggleFly = Tabs.Movimiento:Toggle({ 
    Title = "Volar", 
    Value = false, 
    Callback = function(state)
        flying = state
        local char = player.Character 
        
        if flying then
            inyectarVuelo(char)
        else
            if bg then bg:Destroy(); bg = nil end 
            if bv then bv:Destroy(); bv = nil end
            if char and char:FindFirstChild("Humanoid") then 
                char.Humanoid.PlatformStand = false 
            end
        end
    end
})

UIElements.SliderFly = Tabs.Movimiento:Slider({ 
    Title = "Velocidad de Vuelo", 
    Step = 1, 
    Value = {Min = 10, Max = 200, Default = 50}, 
    Callback = function(Value) 
        flySpeed = Value 
    end 
})

local cachedControls = nil
RunService.RenderStepped:Connect(function()
    if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if not cachedControls then
            local pScripts = player:FindFirstChild("PlayerScripts")
            if pScripts then 
                local pModule = pScripts:FindFirstChild("PlayerModule") 
                if pModule then 
                    local PlayerModule = require(pModule)
                    cachedControls = PlayerModule:GetControls() 
                end 
            end
        end
        
        -- Validación estricta: Nos aseguramos de que bg y bv existan en el cuerpo ACTUAL
        if cachedControls and bv and bv.Parent == player.Character.HumanoidRootPart and bg and bg.Parent == player.Character.HumanoidRootPart then
            local moveVector = cachedControls:GetMoveVector()
            local moveDir = camera.CFrame:VectorToWorldSpace(moveVector)
            bv.Velocity = moveDir * flySpeed
            bg.CFrame = camera.CFrame
        end
    end
end)

local noclipConnection = nil
UIElements.ToggleNoclip = Tabs.Movimiento:Toggle({ Title = "Atravesar Todo", Value = false, Callback = function(state)
    if state then if not noclipConnection then noclipConnection = RunService.Stepped:Connect(function() local char = player.Character if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) end
    else if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end end
end})

-- ==========================================
-- 🏃‍♂️ FIX: WALK SPEED & SPEED GLITCH
-- ==========================================
local customWalkSpeed = 25
local walkSpeedEnabled = false
local walkSpeedConnection = nil

local speedGlitchEnabled = false
local speedGlitchConnection = nil
local jumpRequestConnection = nil

UIElements.ToggleWalkSpeed = Tabs.Movimiento:Toggle({
    Title = "Caminar Rápido",
    Value = false,
    Callback = function(state)
        walkSpeedEnabled = state
        
        if state then
            -- Si activas el permanente, apagamos el Speed Glitch para no chocar
            if speedGlitchEnabled and UIElements.ToggleSpeedGlitch then
                pcall(function() UIElements.ToggleSpeedGlitch:Set(false) end)
            end
            
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = customWalkSpeed end
            
            if not walkSpeedConnection then
                walkSpeedConnection = RunService.Heartbeat:Connect(function()
                    if walkSpeedEnabled and player.Character then
                        local hum = player.Character:FindFirstChild("Humanoid")
                        if hum and hum.WalkSpeed ~= customWalkSpeed then hum.WalkSpeed = customWalkSpeed end
                    end
                end)
            end
        else
            if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
        end
    end
})

UIElements.ToggleSpeedGlitch = Tabs.Movimiento:Toggle({
    Title = "Speed Glitch",
    Value = false,
    Callback = function(state)
        speedGlitchEnabled = state
        
        if state then
            -- Si activas el Glitch, apagamos el caminar rápido permanente
            if walkSpeedEnabled and UIElements.ToggleWalkSpeed then
                pcall(function() UIElements.ToggleWalkSpeed:Set(false) end)
            end
            
            -- 🔥 FIX MÓVIL: Lee el microsegundo exacto en que tu dedo toca el botón de salto
            if not jumpRequestConnection then
                jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
                    if speedGlitchEnabled and player.Character then
                        local hum = player.Character:FindFirstChild("Humanoid")
                        if hum then
                            -- Inyecta la velocidad justo ANTES de despegar
                            hum.WalkSpeed = customWalkSpeed
                        end
                    end
                end)
            end
            
            -- Mantiene la velocidad si caes de una orilla y te frena al tocar el piso
            if not speedGlitchConnection then
                speedGlitchConnection = RunService.Stepped:Connect(function()
                    if speedGlitchEnabled and player.Character then
                        local hum = player.Character:FindFirstChild("Humanoid")
                        if hum then
                            local currentState = hum:GetState()
                            local isInAir = (currentState == Enum.HumanoidStateType.Jumping or currentState == Enum.HumanoidStateType.Freefall)
                            
                            if isInAir then
                                if hum.WalkSpeed ~= customWalkSpeed then
                                    hum.WalkSpeed = customWalkSpeed
                                end
                            else
                                if hum.WalkSpeed ~= 16 then
                                    hum.WalkSpeed = 16
                                end
                            end
                        end
                    end
                end)
            end
        else
            -- Apagado limpio
            if speedGlitchConnection then speedGlitchConnection:Disconnect(); speedGlitchConnection = nil end
            if jumpRequestConnection then jumpRequestConnection:Disconnect(); jumpRequestConnection = nil end
            
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and not walkSpeedEnabled then 
                char.Humanoid.WalkSpeed = 16 
            end
        end
    end
})

UIElements.SliderWalk = Tabs.Movimiento:Slider({ 
    Title = "Ajustar Velocidad", 
    Step = 1, 
    Value = {Min = 16, Max = 100, Default = 25}, 
    Callback = function(Value) 
        customWalkSpeed = Value 
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            if walkSpeedEnabled then
                hum.WalkSpeed = customWalkSpeed
            elseif speedGlitchEnabled then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or hum.FloorMaterial == Enum.Material.Air then
                    hum.WalkSpeed = customWalkSpeed
                end
            end
        end
    end 
})

local infinityJumpEnabled = false
UserInputService.JumpRequest:Connect(function() 
    if infinityJumpEnabled then 
        local char = player.Character 
        if char then 
            local hum = char:FindFirstChildOfClass("Humanoid") 
            -- Verificamos que esté en el aire (Freefall) para no duplicar el salto en el piso
            if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then 
                hum:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end 
    end 
end)
UIElements.ToggleInfJump = Tabs.Movimiento:Toggle({ Title = "Infinity Jump", Value = false, Callback = function(state) infinityJumpEnabled = state end })




Tabs.Movimiento:Section({ Title = "Modo Fantasma" })

local invisHumanoid = nil; local invisHumanoidRootPart = nil; local isInvisible = false; local invisCharacterParts = {}; local invisHeartbeatConnection = nil; local invisBg = nil; local invisBv = nil; local invisFlySpeed = 40 
local ghostBtn, getGhostClick, ghostStroke = createFloatingBtn("Fantasma", UDim2.new(0.8, -150, 0.5, 0), "BtnFantasma")

-- ==========================================
-- BOTÓN FLOTANTE: BOMB JUMP (COOLDOWN DINÁMICO, ANTI-BUG Y DETECCIÓN MANUAL)
-- ==========================================
local bombBtn, getBombClick, bombStroke = createFloatingBtn("Bomb Jump", UDim2.new(0.8, -150, 0.65, 0), "BtnBombJump")

local bombCooldownEnd = 0
local bombOnCooldown = false

local function TriggerBombCooldown()
    if bombOnCooldown then return end 
    bombCooldownEnd = tick() + 22
    bombOnCooldown = true
    
    task.spawn(function()
        -- 🔥 Estilo de carga (Morado oscuro apagado)
        bombBtn.BackgroundColor3 = Color3.fromHex("#120b18") 
        bombStroke.Color = Color3.fromHex("#2e1c3b")
        bombBtn.TextColor3 = Color3.fromRGB(150, 130, 170)
        
        while tick() < bombCooldownEnd do
            if not bombBtn or not bombBtn.Parent then break end
            local timeLeft = math.ceil(bombCooldownEnd - tick())
            bombBtn.Text = "Espera: " .. timeLeft .. "s"
            task.wait(0.2) 
        end
        
        if bombBtn and bombBtn.Parent then
            -- 🔥 Regresa al estilo Onyx Normal
            bombBtn.Text = "Bomb Jump"
            bombBtn.BackgroundColor3 = Color3.fromHex("#09070c")
            bombStroke.Color = Color3.fromHex("#1a1225")
            bombBtn.TextColor3 = Color3.fromHex("#ffffff")
        end
        bombOnCooldown = false
    end)
end

-- 🕵️‍♂️ Escáner IA: Sincroniza el botón si el VIP usa la bomba manualmente (Clic normal)
local function hookBomb(tool)
    if tool:IsA("Tool") and (string.find(tool.Name, "Bomb") or string.find(tool.Name, "FakeBomb")) then
        if not tool:GetAttribute("BombHooked") then
            tool:SetAttribute("BombHooked", true)
            tool.Activated:Connect(function()
                TriggerBombCooldown()
            end)
        end
    end
end

-- 📡 Mantener vigilado el inventario del jugador
task.spawn(function()
    pcall(function()
        for _, item in ipairs(player.Backpack:GetChildren()) do hookBomb(item) end
        if player.Character then
            for _, item in ipairs(player.Character:GetChildren()) do hookBomb(item) end
        end
    end)
    player.Backpack.ChildAdded:Connect(hookBomb)
    player.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(hookBomb)
    end)
end)

-- 🎯 Lógica cuando presionas el botón flotante del Hub
bombBtn.MouseButton1Click:Connect(function()
    if not getBombClick() then return end
    
    if tick() < bombCooldownEnd then return end -- Si sigue en cooldown, ignora el clic
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    local bomb = nil
    local backpack = player:FindFirstChild("Backpack")

    local function checkBomb(parent)
        if not parent then return nil end
        for _, item in ipairs(parent:GetChildren()) do
            if item:IsA("Tool") and (string.find(item.Name, "Bomb") or string.find(item.Name, "FakeBomb")) then
                return item
            end
        end
        return nil
    end

    bomb = checkBomb(char) or checkBomb(backpack)
    
    if bomb and hrp and hum then
        -- Activamos el bloqueo en el botón de inmediato
        TriggerBombCooldown()
        
        task.spawn(function()
            pcall(function()
                if bomb.Parent == player.Backpack then
                    hum:EquipTool(bomb)
                    task.wait(0.05) 
                end

                -- Tiramos la bomba al suelo
                local dropCFrame = hrp.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
                bomb.Remote:FireServer(dropCFrame, 50) 
                
                -- Hacemos que el jugador salte automáticamente
                task.wait(0.03) 
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end)
    else
        sendNotification("No tienes la Bomba lista.")
    end
end)

local function SetupInvisCharacter()
    local char = player.Character 
    if char then 
        invisHumanoid = char:FindFirstChild("Humanoid") 
        invisHumanoidRootPart = char:FindFirstChild("HumanoidRootPart") 
        invisCharacterParts = {} 
        for _, part in pairs(char:GetDescendants()) do 
            if part:IsA("BasePart") then table.insert(invisCharacterParts, part) end 
        end 
    end
end

local function ToggleInvisibilityState()
    isInvisible = not isInvisible; local char = player.Character
    for _, part in pairs(invisCharacterParts) do
        if part and part.Parent then
            if isInvisible then 
                if not part:FindFirstChild("OrigTrans") then 
                    local val = Instance.new("NumberValue"); val.Name = "OrigTrans"; val.Value = part.Transparency; val.Parent = part 
                end 
                part.Transparency = 0.5
            else 
                if part:FindFirstChild("OrigTrans") then part.Transparency = part.OrigTrans.Value end 
            end
        end
    end
    if isInvisible then
        ghostBtn.TextColor3 = Color3.fromRGB(168, 199, 250); ghostStroke.Color = Color3.fromRGB(255, 255, 255)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart 
            invisBg = Instance.new("BodyGyro"); invisBg.P = 9e4; invisBg.maxTorque = Vector3.new(9e9, 9e9, 9e9); invisBg.cframe = hrp.CFrame; invisBg.Parent = hrp 
            invisBv = Instance.new("BodyVelocity"); invisBv.velocity = Vector3.new(0, 0, 0); invisBv.maxForce = Vector3.new(9e9, 9e9, 9e9); invisBv.Parent = hrp 
            if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = true end
        end
    else
        ghostBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ghostStroke.Color = Color3.fromRGB(168, 199, 250) 
        if invisBg then invisBg:Destroy(); invisBg = nil end 
        if invisBv then invisBv:Destroy(); invisBv = nil end 
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
    end
end

ghostBtn.MouseButton1Click:Connect(function() if not getGhostClick() then return end ToggleInvisibilityState() end)

local cachedGhostControls = nil
RunService.RenderStepped:Connect(function()
    if isInvisible and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if not cachedGhostControls then
            local pScripts = player:FindFirstChild("PlayerScripts")
            if pScripts then 
                local pModule = pScripts:FindFirstChild("PlayerModule") 
                if pModule then 
                    local PlayerModule = require(pModule)
                    cachedGhostControls = PlayerModule:GetControls()
                end
            end
        end
        
        if cachedGhostControls and invisBv and invisBg then 
            local moveVector = cachedGhostControls:GetMoveVector()
            local moveDir = camera.CFrame:VectorToWorldSpace(moveVector)
            invisBv.Velocity = moveDir * invisFlySpeed
            invisBg.CFrame = camera.CFrame 
        end
    end
end)

UIElements.ToggleGhost = Tabs.Movimiento:Toggle({
    Title = "Mostrar Botón Fantasma",
    Value = false,
    Callback = function(state)
        if state then 
            SetupInvisCharacter(); ghostBtn.Visible = true
            if not invisHeartbeatConnection then
                invisHeartbeatConnection = RunService.Heartbeat:Connect(function()
                    if isInvisible and invisHumanoidRootPart and invisHumanoid then
                        local originalCFrame = invisHumanoidRootPart.CFrame; local originalCameraOffset = invisHumanoid.CameraOffset; local offsetCFrame = originalCFrame * CFrame.new(0, -200000, 0); local cameraOffset = offsetCFrame:ToObjectSpace(CFrame.new(originalCFrame.Position)).Position
                        invisHumanoidRootPart.CFrame = offsetCFrame; invisHumanoid.CameraOffset = cameraOffset; RunService.RenderStepped:Wait(); invisHumanoidRootPart.CFrame = originalCFrame; invisHumanoid.CameraOffset = originalCameraOffset
                    end
                end)
            end
        else 
            ghostBtn.Visible = false; if isInvisible then ToggleInvisibilityState() end; if invisHeartbeatConnection then invisHeartbeatConnection:Disconnect(); invisHeartbeatConnection = nil end 
        end
    end
})

UIElements.ToggleBombBtn = Tabs.Sheriff:Toggle({
    Title = "Mostrar Botón Bomb Jump",
    Value = false,
    Callback = function(state)
        bombBtn.Visible = state
    end
})

player.CharacterAdded:Connect(function()
    isInvisible = false; ghostBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ghostStroke.Color = Color3.fromRGB(168, 199, 250); if invisBg then invisBg:Destroy(); invisBg = nil end; if invisBv then invisBv:Destroy(); invisBv = nil end
    if ghostBtn.Visible then task.wait(1) SetupInvisCharacter() end
end)


-- ==========================================
-- 🔄 EVENTO MAESTRO: RECONEXIÓN AL REAPARECER
-- ==========================================
player.CharacterAdded:Connect(function(newChar)
    -- 1. Reconectar el Vuelo automáticamente si dejaron el Toggle prendido
    if flying then
        task.spawn(function()
            task.wait(0.25) -- Pequeña pausa para asegurar que el mapa cargó el personaje
            inyectarVuelo(newChar)
        end)
    end
    
    -- 2. Reconectar el WalkSpeed instantáneamente
    if walkSpeedEnabled then
        task.spawn(function()
            local hum = newChar:WaitForChild("Humanoid", 3)
            if hum then hum.WalkSpeed = customWalkSpeed end
        end)
    end
end)


-- ==========================================
-- 🎭 SISTEMA DE ANIMACIONES (ESTILO DUELOS)
-- ==========================================

-- 1. BASE DE DATOS LOCAL
local animationData = {
    ["Old School"] = { Walk = 10921244891, Run = 10921240218, Jump = 10921242013, Fall = 10921241244, SwimIdle = 10921244018, Swim = 10921243048, Idle = 10921230744, Idle2 = 10921232093, Climb = 10921229866 },
    ["Adidas Sports"] = { Walk = 18537392113, Run = 18537384940, Jump = 18537380791, Fall = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Idle = 18537376492, Idle2 = 18537371272, Climb = 18537363391 },
    ["Adidas Community"] = { Walk = 122150855457006, Run = 82598234841035, Jump = 75290611992385, Fall = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266208, Idle = 122257458498464, Idle2 = 102357151005774, Climb = 88763136693023 },
    ["Adidas Aura"] = { Walk = 83842218823011, Run = 118320322718866, Jump = 109996626521204, Fall = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383903, Idle = 110211186840347, Idle2 = 114191137265065, Climb = 97824616490448 },
    ["Wicked Popular"] = { Walk = 92072849924640, Run = 72301599441680, Jump = 104325245285198, Fall = 121152442762481, Idle = 118832222982049, Idle2 = 76049494037641, SwimIdle = 113199415118199, Swim = 99384245425157, Climb = 131326830509784 },
    ["Elder"] = { Walk = 10921111375, Run = 10921104374, Jump = 10921107367, Fall = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, Idle = 10921101664, Idle2 = 10921102574, Climb = 10921100400 },
    ["Zombie"] = { Walk = 10921355261, Run = 616163682, Jump = 10921351278, Fall = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Idle = 10921344533, Idle2 = 10921345304, Climb = 10921343576 },
    ["Mage"] = { Walk = 10921152678, Run = 10921148209, Jump = 10921149743, Fall = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, Idle = 10921144709, Idle2 = 10921145797, Climb = 10921143404 },
    ["Catwalk Glam"] = { Walk = 109168724482748, Run = 81024476153754, Jump = 116936326516985, Fall = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181628, Idle = 133806214992291, Idle2 = 94970088341563, Climb = 119377220967554 },
    ["Astronaut"] = { Walk = 10921046031, Run = 10921039308, Jump = 10921042494, Fall = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, Idle = 10921034824, Idle2 = 10921036806, Climb = 10921032124 },
    ['Wicked "Dancing Through Life"'] = { Walk = 73718308412641, Run = 135515454877967, Jump = 78508480717326, Fall = 78147885297412, SwimIdle = 129183123083281, Swim = 110657013921774, Idle = 92849173543269, Idle2 = 132238900951109, Climb = 129447497744818 },
    ["Werewolf"] = { Walk = 10921342074, Run = 10921336997, Fall = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, Idle = 10921330408, Idle2 = 10921333667, Climb = 10921329322 },
    ["Superhero"] = { Walk = 10921298616, Run = 10921291831, Jump = 10921294559, Fall = 10921293373, SwimIdle = 10921297391, Swim = 10921295495, Idle = 10921288909, Idle2 = 10921290167, Climb = 10921286911 },
    ["Toy"] = { Walk = 10921312010, Run = 10921306285, Jump = 10921308158, Fall = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, Idle = 10921301576, Climb = 10921300839 },
    ["No Boundaries"] = { Walk = 18747074203, Run = 18747070484, Jump = 18747069148, Fall = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, Idle = 18747067405, Idle2 = 18747063918, Climb = 18747060903 },
    ["NFL"] = { Walk = 110358958299415, Run = 117333533048078, Jump = 119846112151352, Fall = 129773241321032, SwimIdle = 79090109939093, Swim = 132697394189921, Idle = 92080889861410, Idle2 = 74451233229259, Climb = 134630013742019 },
    ["Amazon Unboxed"] = { Walk = 90478085024465, Run = 134824450619865, Jump = 121454505477205, Fall = 94788218468396, SwimIdle = 129126268464847, Swim = 105962919001086, Idle = 98281136301627, Climb = 121145883950231 },
    ["Vampire"] = { Walk = 10921326949, Run = 10921320299, Jump = 10921322186, Fall = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, Idle = 10921315373, Climb = 10921314188 },
    ["Ninja"] = { Walk = 656121766, Run = 656118852, Jump = 656117878, Fall = 656115606, SwimIdle = 656121397, Swim = 656119721, Idle = 656117400, Idle2 = 656118341, Climb = 656114359 },
    ["Robot"] = { Walk = 616095330, Run = 616091570, Jump = 616090535, Fall = 616087089, SwimIdle = 616094091, Swim = 616092998, Idle = 616088211, Idle2 = 616089559, Climb = 616086039 },
    ["Levitation"] = { Walk = 616013216, Run = 616010382, Jump = 616008936, Fall = 616005863, SwimIdle = 616012453, Swim = 616011509, Idle = 616006778, Idle2 = 616008087, Climb = 616003713 },
    ["Stylish"] = { Walk = 616146177, Run = 616140816, Jump = 616139451, Fall = 616134815, SwimIdle = 616144772, Swim = 616143378, Idle = 616136790, Idle2 = 616138447, Climb = 616133594 },
    ["Bubbly"] = { Walk = 910034870, Run = 910025107, Jump = 910016857, Fall = 910001910, SwimIdle = 910030921, Swim = 910028158, Idle = 910004836, Idle2 = 910009958, Climb = 909997997 },
    ["Cartoon"] = { Walk = 742640026, Run = 742638842, Jump = 742637942, Fall = 742637151, SwimIdle = 742639812, Swim = 742639220, Idle = 742637544, Idle2 = 742638445, Climb = 742636889 }
}

-- 2. LIMPIEZA DE TRACKS PREVIOS
local function clearAllAnimations()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) track:Destroy() end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) track:Destroy() end
    end
    task.wait(0.1)
end

local animacionActualActiva = nil 
local misAnimacionesOriginales = nil 

-- 3. INYECTOR UNIVERSAL
local function applyCustomAnims(customData)
    if not customData then return end
    local char = player.Character
    if not char then return end
    clearAllAnimations()

    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    
    if not misAnimacionesOriginales then
        local function getAnim(folderName, animName)
            local folder = animate:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChild(animName)
                if anim and anim:IsA("Animation") then
                    local idStr = anim.AnimationId:match("%d+")
                    if idStr then return tonumber(idStr) end
                end
            end
            return nil
        end

        misAnimacionesOriginales = {
            Idle = getAnim("idle", "Animation1") or 507766666,
            Idle2 = getAnim("idle", "Animation2") or 507766951,
            Walk = getAnim("walk", "WalkAnim") or 507777826,
            Run = getAnim("run", "RunAnim") or 507767714,
            Jump = getAnim("jump", "JumpAnim") or 507765000,
            Climb = getAnim("climb", "ClimbAnim") or 507765644,
            Fall = getAnim("fall", "FallAnim") or 507767968,
            Swim = getAnim("swim", "Swim") or 507784897,
            SwimIdle = getAnim("swimidle", "SwimIdle") or 507785072
        }
    end

    animate.Disabled = true
    task.wait(0.1)

    local function updateAnimation(folderName, animName, animId)
        if not animId then return end
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local anim = folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                anim.AnimationId = "rbxassetid://" .. tostring(animId)
            end
        end
    end

    updateAnimation("idle", "Animation1", customData.Idle)
    updateAnimation("idle", "Animation2", customData.Idle2 or customData.Idle)
    updateAnimation("walk", "WalkAnim", customData.Walk)
    updateAnimation("run", "RunAnim", customData.Run)
    updateAnimation("jump", "JumpAnim", customData.Jump)
    updateAnimation("climb", "ClimbAnim", customData.Climb)
    updateAnimation("fall", "FallAnim", customData.Fall)
    updateAnimation("swim", "Swim", customData.Swim)
    updateAnimation("swimidle", "SwimIdle", customData.SwimIdle or customData.Swim)

    task.wait(0.1)
    animate.Disabled = false

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        task.wait(0.05)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- 4. BUCLE ANTI-RESETEO (Mantiene las animaciones vivas tras respawn)
task.spawn(function()
    while task.wait(1) do
        if animacionActualActiva then
            local char = player.Character
            if char then
                local animate = char:FindFirstChild("Animate")
                if animate then
                    local idleFolder = animate:FindFirstChild("idle")
                    if idleFolder then
                        local anim1 = idleFolder:FindFirstChild("Animation1")
                        if anim1 then
                            local currentId = anim1.AnimationId:match("%d+")
                            if currentId ~= tostring(animacionActualActiva.Idle) then
                                applyCustomAnims(animacionActualActiva)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 5. INTERFAZ WINDUI EN TABS.EMOTES
local animList = {"Ninguno"}
for name, _ in pairs(animationData) do table.insert(animList, name) end
table.sort(animList)

Tabs.Emotes:Section({ Title = "Paquetes Completos" })

local selectedBundleCompleto = "Ninguno"
Tabs.Emotes:Dropdown({
    Title = "Elegir Paquete", 
    Values = animList, 
    Value = "Ninguno", 
    Callback = function(Value) selectedBundleCompleto = Value end
})

Tabs.Emotes:Button({
    Title = "Aplicar Paquete Completo", 
    Callback = function()
        if selectedBundleCompleto == "Ninguno" then return end
        task.spawn(function()
            sendNotification("Aplicando paquete: " .. selectedBundleCompleto)
            animacionActualActiva = animationData[selectedBundleCompleto]
            applyCustomAnims(animacionActualActiva)
        end)
    end
})

Tabs.Emotes:Button({
    Title = "Restaurar Default", 
    Callback = function()
        task.spawn(function()
            local defaultAnims = misAnimacionesOriginales or {
                Idle = 507766666, Idle2 = 507766951, Walk = 507777826, Run = 507767714,
                Jump = 507765000, Climb = 507765644, Fall = 507767968, Swim = 507784897, SwimIdle = 507785072
            }
            animacionActualActiva = nil 
            applyCustomAnims(defaultAnims)
            sendNotification("Animaciones por defecto restauradas.")
        end)
    end
})

Tabs.Emotes:Section({ Title = "Mezclador de Animaciones" })

local mixParts = {
    Idle = "Ninguno", Walk = "Ninguno", Run = "Ninguno", 
    Jump = "Ninguno", Fall = "Ninguno", Climb = "Ninguno"
}

Tabs.Emotes:Dropdown({Title = "Reposo", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Idle = Value end})
Tabs.Emotes:Dropdown({Title = "Caminar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Walk = Value end})
Tabs.Emotes:Dropdown({Title = "Correr", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Run = Value end})
Tabs.Emotes:Dropdown({Title = "Saltar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Jump = Value end})
Tabs.Emotes:Dropdown({Title = "Caer", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Fall = Value end})
Tabs.Emotes:Dropdown({Title = "Escalar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Climb = Value end})

Tabs.Emotes:Button({
    Title = "Combinar y Aplicar", 
    Callback = function()
        task.spawn(function()
            local customMix = {}
            
            if mixParts.Idle ~= "Ninguno" then
                customMix.Idle = animationData[mixParts.Idle].Idle
                customMix.Idle2 = animationData[mixParts.Idle].Idle2
            end
            if mixParts.Walk ~= "Ninguno" then customMix.Walk = animationData[mixParts.Walk].Walk end
            if mixParts.Run ~= "Ninguno" then customMix.Run = animationData[mixParts.Run].Run end
            if mixParts.Jump ~= "Ninguno" then customMix.Jump = animationData[mixParts.Jump].Jump end
            if mixParts.Fall ~= "Ninguno" then customMix.Fall = animationData[mixParts.Fall].Fall end
            if mixParts.Climb ~= "Ninguno" then customMix.Climb = animationData[mixParts.Climb].Climb end

            local hasValues = false
            for _, v in pairs(customMix) do if v then hasValues = true break end end
            
            if hasValues then
                sendNotification("Aplicando combinación...")
                animacionActualActiva = customMix 
                applyCustomAnims(animacionActualActiva)
            else
                sendNotification("Selecciona al menos una animación.")
            end
        end)
    end
})

task.wait() -- 🔥 AÑADE ESTO
Tabs.Troll:Section({ Title = "Fling a Jugadores" })

local currentFlingTarget = nil 
local flingLoop = nil 
local bV, bAv

local function stopFling()
    currentFlingTarget = nil 
    if flingLoop then flingLoop:Disconnect(); flingLoop = nil end 
    if bV then bV:Destroy(); bV = nil end 
    if bAv then bAv:Destroy(); bAv = nil end
    
    local char = player.Character 
    if char then
        if char:FindFirstChild("Humanoid") then 
            char.Humanoid.PlatformStand = false 
        end
        if char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart 
            for _, v in pairs(char:GetDescendants()) do 
                if v:IsA("BasePart") then 
                    v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1) 
                    v.CanCollide = true 
                end 
            end
            hrp.AssemblyLinearVelocity = Vector3.zero 
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

local function startFling(targetMode)
    stopFling() 
    local char = player.Character 
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    local hrp = char.HumanoidRootPart 
    local hum = char.Humanoid
    
    hum.PlatformStand = true 
    for _, v in pairs(char:GetDescendants()) do 
        if v:IsA("BasePart") then 
            v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 1, 1) 
        end 
    end
    
    bAv = Instance.new("BodyAngularVelocity") 
    bAv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
    bAv.AngularVelocity = Vector3.new(0, 99999, 0) 
    bAv.Parent = hrp
    
    bV = Instance.new("BodyVelocity") 
    bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
    bV.Velocity = Vector3.zero 
    bV.Parent = hrp
    
    currentFlingTarget = targetMode 
    local allIndex = 1 
    local tickCounter = 0

    flingLoop = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or player.Character.Humanoid.Health <= 0 then 
            stopFling() 
            return 
        end
        
        local myHrp = player.Character.HumanoidRootPart 
        myHrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0) 
        
        for _, v in pairs(player.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end

        local function isValidTarget(tPlayer) 
            return tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") and tPlayer.Character:FindFirstChild("Humanoid") and tPlayer.Character.Humanoid.Health > 0 
        end

        if type(currentFlingTarget) == "userdata" then 
            if isValidTarget(currentFlingTarget) then 
                local tHrp = currentFlingTarget.Character.HumanoidRootPart 
                myHrp.CFrame = tHrp.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
            else 
                sendNotification("El objetivo murió o se desconectó.") 
                stopFling() 
            end
            
        elseif currentFlingTarget == "All" then 
            local validTargets = {} 
            for _, p in ipairs(Players:GetPlayers()) do 
                if p ~= player and isValidTarget(p) then table.insert(validTargets, p) end 
            end
            
            if #validTargets > 0 then
                tickCounter = tickCounter + 1 
                if tickCounter > 15 then 
                    allIndex = allIndex + 1 
                    tickCounter = 0 
                end 
                if allIndex > #validTargets then allIndex = 1 end
                
                local tHrp = validTargets[allIndex].Character.HumanoidRootPart 
                myHrp.CFrame = tHrp.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
            else 
                sendNotification("Ya no hay nadie vivo en el mapa.") 
                stopFling() 
            end
        end
    end)
end

UIElements.ToggleFlingAll = Tabs.Troll:Toggle({
    Title = "Fling a Todos",
    Value = false,
    Callback = function(state)
        if state then 
            sendNotification("¡Fling All activado!...") 
            startFling("All")
        else 
            sendNotification("Fling apagado.") 
            stopFling() 
        end
    end
})

local selectedFlingTarget = nil
local FlingDropdown = Tabs.Troll:Dropdown({
    Title = "Seleccionar Jugador",
    Values = {"Esperando carga..."},
    Value = "Esperando carga...",
    Callback = function(Value) 
        if Value ~= "Esperando carga..." and Value ~= "No hay nadie más" then
            selectedFlingTarget = Value 
        end
    end
})

Tabs.Troll:Button({
    Title = "Actualizar Lista",
    Callback = function()
        local playerNames = {} 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= player then table.insert(playerNames, p.Name) end 
        end
        if #playerNames == 0 then table.insert(playerNames, "No hay nadie más") end
        
        FlingDropdown:Refresh(playerNames)
        sendNotification("Lista de jugadores actualizada.")
    end
})

Tabs.Troll:Toggle({
    Title = "Fling al Jugador Seleccionado",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedFlingTarget or selectedFlingTarget == "Esperando carga..." or selectedFlingTarget == "No hay nadie más" then 
                sendNotification("Primero selecciona un jugador de la lista arriba.") 
                return 
            end
            local targetPlayer = Players:FindFirstChild(selectedFlingTarget)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
                sendNotification("Fling apuntado a: " .. targetPlayer.Name) 
                startFling(targetPlayer)
            else 
                sendNotification("El jugador está muerto o se salió.") 
                stopFling()
            end
        else 
            sendNotification("Fling detenido.") 
            stopFling() 
        end
    end
})

Tabs.Troll:Section({ Title = "Protección" })

local antiFlingConnection = nil
UIElements.ToggleAntiFling = Tabs.Troll:Toggle({
    Title = "Anti-Fling",
    Value = false,
    Callback = function(state)
        if state then
            sendNotification("Anti-Fling Activado.")
            antiFlingConnection = RunService.Stepped:Connect(function()
                for _, p in pairs(Players:GetPlayers()) do 
                    if p ~= player and p.Character then 
                        for _, part in pairs(p.Character:GetDescendants()) do 
                            if part:IsA("BasePart") then part.CanCollide = false end 
                        end 
                    end 
                end
            end)
        else 
            sendNotification("Anti-Fling Desactivado.")
            if antiFlingConnection then 
                antiFlingConnection:Disconnect(); antiFlingConnection = nil 
            end 
        end
    end
})





Tabs.Config:Section({ Title = "Personalización de Interfaz" })

Tabs.Config:Toggle({
    Title = "Mover Botones Flotantes",
    Value = false,
    Callback = function(state)
        _G.EditFloatingButtons = state
        if state then sendNotification("Modo Edición ON. Ya puedes arrastrarlos.")
        else sendNotification("Modo Edición OFF. Botones anclados.") end
    end
})


local btnShapeDrop = Tabs.Config:Dropdown({
    Title = "Forma de Botones Flotantes",
    Values = {"Rectángulo", "Cuadrado"},
    Value = "Rectángulo",
    Callback = function(Value)
        _G.FloatingButtonsShape = Value
        UpdateFloatingButtonsShape(Value)
    end
})

Tabs.Config:Slider({
    Title = "Ancho del Botón Flotante",
    Step = 1,
    Value = {Min = 50, Max = 300, Default = 150},
    Callback = function(v)
        _G.FloatingBtnWidth = v
        if _G.FloatingButtonsShape == "Rectángulo" then UpdateFloatingButtonsShape("Rectángulo") end
    end
})

Tabs.Config:Slider({
    Title = "Alto del Botón Flotante",
    Step = 1,
    Value = {Min = 30, Max = 100, Default = 45},
    Callback = function(v)
        _G.FloatingBtnHeight = v
        if _G.FloatingButtonsShape == "Rectángulo" then UpdateFloatingButtonsShape("Rectángulo") end
    end
})


UIElements.SliderBtnTrans = Tabs.Config:Slider({
    Title = "Transparencia de Botones Flotantes",
    Step = 0.05,
    Value = {Min = 0.0, Max = 1.0, Default = 0.3},
    Callback = function(v)
        _G.FloatingBtnTransparency = v
        for _, btn in ipairs(floatingButtonsList) do
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = v}):Play()
        end
    end
})

Tabs.Config:Toggle({
    Title = "Ocultar Botón Flotante del menu",
    Callback = function(Value)
        local guisToSearch = { player:FindFirstChild("PlayerGui") }
        pcall(function() table.insert(guisToSearch, game:GetService("CoreGui")) end)

        for _, guiContainer in ipairs(guisToSearch) do
            if guiContainer then
                for _, v in pairs(guiContainer:GetDescendants()) do
                    if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text and string.find(v.Text, "Open OnyxHub") then
                        local btnContainer = v
                        while btnContainer.Parent and not btnContainer.Parent:IsA("ScreenGui") and not btnContainer.Parent:IsA("Folder") do
                            btnContainer = btnContainer.Parent
                        end
                        
                        if btnContainer:IsA("CanvasGroup") then
                            btnContainer.GroupTransparency = Value and 1 or 0
                        else
                            local function aplicarTransparencia(obj)
                                if obj:IsA("UIStroke") then
                                    if not obj:GetAttribute("OrigTrans") then obj:SetAttribute("OrigTrans", obj.Transparency) end
                                    obj.Transparency = Value and 1 or obj:GetAttribute("OrigTrans")
                                elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                                    if not obj:GetAttribute("OrigTxtTrans") then obj:SetAttribute("OrigTxtTrans", obj.TextTransparency) end
                                    obj.TextTransparency = Value and 1 or obj:GetAttribute("OrigTxtTrans")
                                    if not obj:GetAttribute("OrigBgTrans") then obj:SetAttribute("OrigBgTrans", obj.BackgroundTransparency) end
                                    obj.BackgroundTransparency = Value and 1 or obj:GetAttribute("OrigBgTrans")
                                elseif obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                                    if not obj:GetAttribute("OrigBgTrans") then obj:SetAttribute("OrigBgTrans", obj.BackgroundTransparency) end
                                    obj.BackgroundTransparency = Value and 1 or obj:GetAttribute("OrigBgTrans")
                                    pcall(function()
                                        if not obj:GetAttribute("OrigImgTrans") then obj:SetAttribute("OrigImgTrans", obj.ImageTransparency) end
                                        obj.ImageTransparency = Value and 1 or obj:GetAttribute("OrigImgTrans")
                                    end)
                                end
                            end
                            for _, obj in pairs(btnContainer:GetDescendants()) do aplicarTransparencia(obj) end
                            aplicarTransparencia(btnContainer)
                        end
                    end
                end
            end
        end
    end
})

task.wait() -- 🔥 AÑADE ESTO
Tabs.Config:Section({ Title = "Gestor de Configs" })
local configFolder = "OnyxHub_Configs_MM2_WindUI" 
if isfolder and not isfolder(configFolder) then pcall(function() makefolder(configFolder) end) end

local availableConfigs = {"Ninguna"}
local selectedConfig = "Ninguna"
local customConfigName = ""

local configDropdown = Tabs.Config:Dropdown({
    Title = "Seleccionar Configuración",
    Values = availableConfigs,
    Value = "Ninguna",
    Callback = function(Value)
        selectedConfig = Value
    end
})

local function refreshConfigs()
    local list = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(configFolder)) do
                if file:match("%.json$") then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(list, name) end
                end
            end
        end)
    end
    if #list == 0 then table.insert(list, "Ninguna") end
    
    pcall(function()
        configDropdown:Refresh(list)
        if selectedConfig == "Ninguna" or not table.find(list, selectedConfig) then
            configDropdown:Select(list[1])
            selectedConfig = list[1]
        end
    end)
end

Tabs.Config:Button({
    Title = "Actualizar Lista",
    Callback = function()
        refreshConfigs()
        sendNotification("Lista de configuraciones actualizada.")
    end
})

Tabs.Config:Input({ 
    Title = "Nombre para Guardar", 
    Placeholder = "Ej: Config 1, Config 2...", 
    Callback = function(Text) customConfigName = Text end 
})

Tabs.Config:Button({ Title = "Guardar Configuración", Callback = function()
    task.wait(0.1) 
    
    local finalName = customConfigName:gsub("[^%w%s%-]", "") 
    if finalName == "" then finalName = selectedConfig end
    
    if finalName == "" or finalName == "Ninguna" then
        sendNotification("Escribe un nombre válido o selecciona una config para sobreescribir.")
        return
    end
    
    local path = configFolder .. "/" .. finalName .. ".json"
    
    local floatPositions = {}
    for _, btn in ipairs(floatingButtonsList) do
        floatPositions[btn.Name] = {XS = btn.Position.X.Scale, XO = btn.Position.X.Offset, YS = btn.Position.Y.Scale, YO = btn.Position.Y.Offset}
    end

    local configData = {
        ConfigName = finalName,
        -- 🔥 REEMPLAZA LA LÍNEA DE ABAJO CON TU NUEVO CÓDIGO
        FloatSettings = { 
            Shape = _G.FloatingButtonsShape, 
            Positions = floatPositions,
            Width = _G.FloatingBtnWidth,
            Height = _G.FloatingBtnHeight,
            Transparency = _G.FloatingBtnTransparency -- 🔥 NUEVO
        },
        Toggles = {
            ["ESP Jugadores"] = espEnabled, ["ESP Arma Tirada"] = gunDropESP, 
            ["ESP Esqueleto"] = espSkeletonEnabled, ["ESP Lineas"] = espLinesEnabled,
            ["Aimlock Nativo"] = aimlockConCandadoHabilitado,
            ["Mostrar Botón BombJump"] = bombBtn.Visible,
            ["Notificar Arma Tirada"] = notifyGunDropEnabled,
            ["ESP Nombres"] = espNamesEnabled, ["ESP Distancia"] = espDistanceEnabled, 
            ["Ocultar Nombre"] = hideNameEnabled, ["Nombre Falso"] = fakeNameEnabled, 
            ["Efecto Rainbow"] = rainbowEnabled, ["Kill Aura"] = killAuraEnabled, 
            ["Auto Farm"] = coinAutoCollect, ["Auto Gun"] = autoGetDroppedGun, 
            ["Fly"] = flying, ["Noclip"] = (noclipConnection ~= nil), 
            
            ["Fling All"] = (currentFlingTarget == "All"), ["Anti Fling"] = (antiFlingConnection ~= nil), 
            ["Infinity Jump"] = infinityJumpEnabled, ["FPS Boost"] = fpsBoostEnabled,
            
            ["Walk Speed Enable"] = walkSpeedEnabled,
            ["Mostrar Botón Fantasma"] = ghostBtn.Visible,
            ["AutoShoot Predictivo"] = (getgenv().NathConfig and getgenv().NathConfig.AutoShoot or false),
            ["Mostrar Botón Shoot"] = aiFloatingShoot.Visible,
            ["Mostrar Toggle Shoot"] = aiFloatingToggle.Visible,
            ["Mostrar Mira"] = showCrosshairEnabled,
    
            ["Auto Stab"] = autoStabEnabled -- 🔥 AQUÍ GUARDAS EL ESTADO DEL AUTO STAB
        },
        Sliders = { 
            ["Aura Radius"] = killAuraRadius, 
            ["Fly Speed"] = flySpeed, 
            ["Walk Speed"] = customWalkSpeed -- Ahora guarda el slider correctamente
        },
        Colors = {
            ["Color Inocentes"] = {R = espColors.Innocent.R, G = espColors.Innocent.G, B = espColors.Innocent.B},
            ["Color Sheriff"] = {R = espColors.Sheriff.R, G = espColors.Sheriff.G, B = espColors.Sheriff.B},
            ["Color Murderer"] = {R = espColors.Murderer.R, G = espColors.Murderer.G, B = espColors.Murderer.B}
        },
        Extras = {
            ["Nombre Spoof"] = spoofNameText,
            ["Estilo Mira"] = _G.OnyxCrosshairType,
        },
        Animaciones = {
            Paquete = selectedBundleCompleto,
            Mix = mixParts
        }

    }
    
    if writefile then 
        local sEncode, encodedData = pcall(function() return HttpService:JSONEncode(configData) end)
        if sEncode then
            pcall(function() writefile(path, encodedData) end) 
            sendNotification("Guardado como: " .. finalName) 
            refreshConfigs()
            pcall(function() configDropdown:Select(finalName) end)
        else
            sendNotification("Error interno al procesar los datos.")
        end
    else 
        sendNotification("Error: Tu ejecutor no soporta guardar") 
    end
end})

local function secureLoadToggle(element, val) 
    if not element or val == nil then return end 
    pcall(function() element:Set(val) end) 
end

-- Función de ayuda para selectores de dropdown y color
local function secureLoadDropdown(element, val)
    if not element or val == nil then return end 
    pcall(function() element:Select(val) end)
end
local function secureLoadColor(element, r, g, b)
    if not element or r == nil then return end 
    pcall(function() element:Set(Color3.new(r, g, b)) end)
end

Tabs.Config:Button({ Title = "Cargar Configuración", Callback = function()
    if selectedConfig == "Ninguna" or selectedConfig == "" then
        sendNotification("No hay ninguna configuración seleccionada.")
        return
    end
    
    local path = configFolder .. "/" .. selectedConfig .. ".json"
    if isfile and isfile(path) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if success and type(decoded) == "table" then

            -- Posiciones Flotantes y Forma
            -- Posiciones Flotantes y Forma
            if decoded.FloatSettings then
                if decoded.FloatSettings.Width then _G.FloatingBtnWidth = decoded.FloatSettings.Width end
                if decoded.FloatSettings.Height then _G.FloatingBtnHeight = decoded.FloatSettings.Height end
                
                -- 🔥 CARGA DE TRANSPARENCIA
                if decoded.FloatSettings.Transparency then 
                    _G.FloatingBtnTransparency = decoded.FloatSettings.Transparency
                    secureLoadToggle(UIElements.SliderBtnTrans, _G.FloatingBtnTransparency)
                    for _, btn in ipairs(floatingButtonsList) do btn.BackgroundTransparency = _G.FloatingBtnTransparency end
                end

                if decoded.FloatSettings.Shape then
                    secureLoadDropdown(btnShapeDrop, decoded.FloatSettings.Shape)
                end
                
                if decoded.FloatSettings.Positions then
                    for _, btn in ipairs(floatingButtonsList) do
                        local pos = decoded.FloatSettings.Positions[btn.Name]
                        if pos then
                            btn.Position = UDim2.new(pos.XS, pos.XO, pos.YS, pos.YO)
                        end
                    end
                end
            end
            
            -- Toggles
            if decoded.Toggles then
                secureLoadToggle(UIElements.ToggleESP, decoded.Toggles["ESP Jugadores"]) 
                secureLoadToggle(UIElements.ToggleESPGun, decoded.Toggles["ESP Arma Tirada"]) 
                secureLoadToggle(UIElements.ToggleBombBtn, decoded.Toggles["Mostrar Botón BombJump"])
                secureLoadToggle(UIElements.ToggleESPSkeleton, decoded.Toggles["ESP Esqueleto"]) 
                secureLoadToggle(UIElements.ToggleNotifyGun, decoded.Toggles["Notificar Arma Tirada"])
                secureLoadToggle(UIElements.ToggleESPLines, decoded.Toggles["ESP Lineas"]) 
                secureLoadToggle(UIElements.ToggleESPNames, decoded.Toggles["ESP Nombres"]) 
                secureLoadToggle(UIElements.ToggleESPDistance, decoded.Toggles["ESP Distancia"]) 
                secureLoadToggle(UIElements.ToggleHideName, decoded.Toggles["Ocultar Nombre"]) 
                secureLoadToggle(UIElements.ToggleFakeName, decoded.Toggles["Nombre Falso"]) 
                secureLoadToggle(UIElements.ToggleRbName, decoded.Toggles["Efecto Rainbow"]) 
                secureLoadToggle(UIElements.ToggleAura, decoded.Toggles["Kill Aura"]) 
                secureLoadToggle(UIElements.ToggleFly, decoded.Toggles["Fly"]) 
                secureLoadToggle(UIElements.ToggleNoclip, decoded.Toggles["Noclip"]) 
                
       
                secureLoadToggle(UIElements.ToggleFlingAll, decoded.Toggles["Fling All"]) 
                secureLoadToggle(UIElements.ToggleInfJump, decoded.Toggles["Infinity Jump"]) 
                secureLoadToggle(UIElements.ToggleAntiFling, decoded.Toggles["Anti Fling"]) 
                secureLoadToggle(UIElements.ToggleFPS, decoded.Toggles["FPS Boost"])
                
                -- 🔥 CARGA DE NUEVOS TOGGLES
                secureLoadToggle(UIElements.ToggleWalkSpeed, decoded.Toggles["Walk Speed Enable"])
                secureLoadToggle(UIElements.ToggleGhost, decoded.Toggles["Mostrar Botón Fantasma"])
                -- AQUÍ PONES EL CÓDIGO NUEVO:
                if decoded.Toggles["Mostrar Botón Shoot"] ~= nil then 
                    secureLoadToggle(UIElements.ToggleShootBtn, decoded.Toggles["Mostrar Botón Shoot"]) 
                    
                end

                if decoded.Toggles["Aimlock Nativo"] ~= nil then 
                    secureLoadToggle(UIElements.ToggleNativeAimlock, decoded.Toggles["Aimlock Nativo"]) 
                end

                -- 🔥 AGREGAS ESTO PARA QUE CARGUE LA MIRA:
                if decoded.Toggles["Mostrar Mira"] ~= nil then 
                    secureLoadToggle(UIElements.ToggleMira, decoded.Toggles["Mostrar Mira"]) 
                end


                

                -- 🔥 AQUÍ METES LO DEL AUTO STAB
                if decoded.Toggles["Auto Stab"] ~= nil then 
                    autoStabEnabled = decoded.Toggles["Auto Stab"] 
                    secureLoadToggle(UIElements.TogAutoStab, autoStabEnabled) 
                end
                
                -- Botones IA (Buscamos directo en la UI de Sheriff si existen)
                if getgenv().NathConfig and decoded.Toggles["AutoShoot Predictivo"] ~= nil then 
                    getgenv().NathConfig.AutoShoot = decoded.Toggles["AutoShoot Predictivo"]
                    if aiFloatingToggle then
                        aiFloatingToggle.Text = getgenv().NathConfig.AutoShoot and "AutoShoot: ON" or "AutoShoot: OFF"
                        aiFloatingToggle.TextColor3 = getgenv().NathConfig.AutoShoot and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
                    end
                end
                
                if aiFloatingShoot and decoded.Toggles["Mostrar Botón Shoot"] ~= nil then aiFloatingShoot.Visible = decoded.Toggles["Mostrar Botón Shoot"] end
                if aiFloatingToggle and decoded.Toggles["Mostrar Toggle Shoot"] ~= nil then aiFloatingToggle.Visible = decoded.Toggles["Mostrar Toggle Shoot"] end
            end
            
            -- Sliders
            if decoded.Sliders then 
                secureLoadToggle(UIElements.SliderAura, decoded.Sliders["Aura Radius"])
                secureLoadToggle(UIElements.SliderFly, decoded.Sliders["Fly Speed"])
                secureLoadToggle(UIElements.SliderWalk, decoded.Sliders["Walk Speed"]) 
            end
            
            -- Colores
            if decoded.Colors then
                if decoded.Colors["Color Inocentes"] then espColors.Innocent = Color3.new(decoded.Colors["Color Inocentes"].R, decoded.Colors["Color Inocentes"].G, decoded.Colors["Color Inocentes"].B) end
                if decoded.Colors["Color Sheriff"] then espColors.Sheriff = Color3.new(decoded.Colors["Color Sheriff"].R, decoded.Colors["Color Sheriff"].G, decoded.Colors["Color Sheriff"].B) end
                if decoded.Colors["Color Murderer"] then espColors.Murderer = Color3.new(decoded.Colors["Color Murderer"].R, decoded.Colors["Color Murderer"].G, decoded.Colors["Color Murderer"].B) end
            end

            -- Extras
            if decoded.Extras then
                if decoded.Extras["Nombre Spoof"] then spoofNameText = decoded.Extras["Nombre Spoof"] end
                if decoded.Extras["Estilo Mira"] then 
                    _G.OnyxCrosshairType = decoded.Extras["Estilo Mira"]
                    -- Refresca la vista si está en juego
                    if CrossDot then CrossDot.Visible = (_G.OnyxCrosshairType == 1) end
                    if CrossT2 then CrossT2.Visible = (_G.OnyxCrosshairType == 2) end
                    if CrossT3 then CrossT3.Visible = (_G.OnyxCrosshairType == 3) end
                end
            end
            
            -- 🔥 AQUÍ PEGAS TU BLOQUE DE ANIMACIONES 🔥
            if decoded.Animaciones then
                task.spawn(function()
                    task.wait(1) 
                    if decoded.Animaciones.Paquete and decoded.Animaciones.Paquete ~= "Ninguno" then
                        selectedBundleCompleto = decoded.Animaciones.Paquete
                        applyCustomAnims(animationData[selectedBundleCompleto])
                    elseif decoded.Animaciones.Mix then
                        mixParts = decoded.Animaciones.Mix
                        local customMix = {}
                        if mixParts.Idle ~= "Ninguno" then
                            customMix.Idle = animationData[mixParts.Idle].Idle
                            customMix.Idle2 = animationData[mixParts.Idle].Idle2
                        end
                        if mixParts.Walk ~= "Ninguno" then customMix.Walk = animationData[mixParts.Walk].Walk end
                        if mixParts.Run ~= "Ninguno" then customMix.Run = animationData[mixParts.Run].Run end
                        if mixParts.Jump ~= "Ninguno" then customMix.Jump = animationData[mixParts.Jump].Jump end
                        if mixParts.Fall ~= "Ninguno" then customMix.Fall = animationData[mixParts.Fall].Fall end
                        if mixParts.Climb ~= "Ninguno" then customMix.Climb = animationData[mixParts.Climb].Climb end

                        applyCustomAnims(customMix)
                    end
                end)
            end
            
            sendNotification("'" .. selectedConfig .. "' cargada con éxito.")
        else 
            sendNotification("Error al leer el archivo.") 
        end
    else 
        sendNotification("La configuración no existe.") 
    end
end})

task.spawn(function()
    task.wait(1)
    refreshConfigs()
end)


-- ==========================================
-- 🔥 FIX DEFINITIVO: VRAM CACHE (0 LAG AL ABRIR/CERRAR EL HUB)
-- ==========================================
task.spawn(function()
    task.wait(1) 
    
    local core = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")
    local pGui = player:FindFirstChild("PlayerGui")
    local windUI = (core and core:FindFirstChild("OnyxHub_WindUI")) or (pGui and pGui:FindFirstChild("OnyxHub_WindUI"))
    
    if windUI then
        local mainCanvas = windUI:FindFirstChildWhichIsA("CanvasGroup", true)
        if mainCanvas then
            mainCanvas.GroupTransparency = 0.99 
            mainCanvas.Visible = true 
            
            task.wait(1.5) 
            
            mainCanvas:GetPropertyChangedSignal("Visible"):Connect(function()
                if not mainCanvas.Visible then
                    mainCanvas.Visible = true 
                end
            end)
            
            mainCanvas.GroupTransparency = 1
            mainCanvas.Visible = true
        end
    end
end)

-- ==========================================
-- 🔥 MOTOR GÉNESIS IA INTEGRADO
-- ==========================================
task.spawn(function()
    
   



local Players = game:GetService("Players")

local CoreGui = game:GetService("CoreGui")

local Workspace = game:GetService("Workspace")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local Camera = Workspace.CurrentCamera





-- ==========================================
-- 🕵️ SISTEMA DE RASTREO (360° SILENT AIM VIP)
-- ==========================================
GetClosestTarget = function()
    local mejorObjetivo = nil
    -- 🔥 AHORA USAMOS DISTANCIA 3D (360 GRADOS) EN VEZ DE LA PANTALLA
    local menorDistancia3D = (NathConfig and NathConfig.MaxTargetDist) or 5000 
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            
            local isMurderer = false
            for _, item in ipairs(p.Character:GetChildren()) do
                if item:IsA("Tool") and (item.Name == "Knife" or item:FindFirstChild("KnifeServer") or item:FindFirstChild("Throw")) then
                    isMurderer = true; break
                end
            end
            
            if not isMurderer and p:FindFirstChild("Backpack") then
                for _, item in ipairs(p.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name == "Knife" or item:FindFirstChild("KnifeServer") or item:FindFirstChild("Throw")) then
                        isMurderer = true; break
                    end
                end
            end
            
            if isMurderer then
                local partesParaRevisar = {
                    "HumanoidRootPart", "Torso", "UpperTorso", "Head",
                    "Right Arm", "Left Arm", "Right Leg", "Left Leg",
                    "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
                    "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg"
                }

                for _, nombreParte in ipairs(partesParaRevisar) do
                    local parteTarget = p.Character:FindFirstChild(nombreParte)
                    if parteTarget then
                        -- Calculamos la distancia real entre tu personaje y el asesino
                        local dist3D = (parteTarget.Position - myRoot.Position).Magnitude
                        
                        if dist3D < menorDistancia3D then
                            -- 🔥 YA NO COMPROBAMOS SI ESTÁ EN PANTALLA, PASAMOS DIRECTO AL RAYCAST 🔥
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.IgnoreWater = true
                            
                            local ignoreList = {myChar, Camera}
                            for _, otherP in ipairs(Players:GetPlayers()) do
                                if otherP ~= LocalPlayer and otherP.Character and otherP ~= p then
                                    table.insert(ignoreList, otherP.Character)
                                end
                            end
                            rayParams.FilterDescendantsInstances = ignoreList
                            
                            local curOrigin = Camera.CFrame.Position
                            local dir = (parteTarget.Position - curOrigin)
                            local distLeft = dir.Magnitude
                            local hitObstructed = false

                            for i = 1, 5 do
                                local rayo = Workspace:Raycast(curOrigin, dir.Unit * distLeft, rayParams)
                                if not rayo or rayo.Instance:IsDescendantOf(p.Character) then
                                    break
                                end
                                if rayo.Instance.Transparency >= 0.3 or not rayo.Instance.CanCollide then
                                    table.insert(ignoreList, rayo.Instance)
                                    rayParams.FilterDescendantsInstances = ignoreList
                                    curOrigin = rayo.Position + (dir.Unit * 0.01)
                                    distLeft = (parteTarget.Position - curOrigin).Magnitude
                                else
                                    hitObstructed = true
                                    break
                                end
                            end

                            -- Si no hay paredes atravesadas que estorben, fijamos objetivo
                            if not hitObstructed then
                                mejorObjetivo = p.Character
                                menorDistancia3D = dist3D -- Se actualiza para encontrar la parte más cercana
                                break 
                            end
                        end
                    end
                end
            end
        end
    end

    return mejorObjetivo
end






-- ==========================================

-- ⚙️ GENESIS CONFIG (V12.2)

-- ==========================================

-- ==========================================
-- ⚙️ GENESIS CONFIG (V12.2)
-- ==========================================
local NathConfig = {
    AutoShoot = false,
    BulletSpeed = 3000,    
    ShootDelay = 0.001,    -- 🔥 Reducido de 0.02 a 0.001 (Disparo casi instantáneo)
    PredMultiplier = 0.85, -- 🔥 Aumentado de 0.65 a 0.85 para compensar la falta de delay artificial
    MaxTargetDist = 5000, 
    ShowVisuals = true,
    ReplicationBuffer = -0.015, -- 🔥 Usar un valor negativo para adelantar el paquete al servidor
    TargetPingEstimate = 0.03, 
    MaxLeadTime = 0.4,     
    LongRangeThreshold = 250,
    AirborneTrustReduction = 1.0,
    VelocityDecayFactor = 15,
    SolverIterations = 4,
    SolverEpsilon = 0.005,
    DynamicLeadCap = false,
    MinLeadTime = 0.0,
    TerminalVelocity = -150
}


local TargetParts = {"HumanoidRootPart", "UpperTorso", "LowerTorso", "Head"}

local GRAVITY = Workspace.Gravity



local currentPing = 0.05

task.spawn(function()

    while task.wait(1) do

        pcall(function()

            local rawPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000

            currentPing = math.clamp(rawPing, 0.01, 0.15)

        end)

    end

end)

-- 🔥 RASTREADOR DE FPS (Para Desync)
local currentFPS = 60
RunService.Heartbeat:Connect(function(deltaTime)
    currentFPS = math.clamp(1 / deltaTime, 15, 240)
end)







-- ==========================================

-- 🌐 VPS BRIDGE - Conexión con Genesis Server

-- ==========================================





local VPS = {

    IP = "108.174.154.25", -- Tu IP de la VPS

    PORT = "22022",       -- El puerto del servidor Flask

    SECRET = "mi_clave_secreta_super_random_xyz789", -- Key de seguridad

    SessionID = HttpService:GenerateGUID(false)

}



local function SendToVPS(endpoint, payload)

    local req = (syn and syn.request) or (http and http.request) or request or http_request

    if not req then 

        warn("❌ [GENESIS] Tu executor no soporta peticiones HTTP.")

        return false 

    end



    local url = "http://" .. VPS.IP .. ":" .. VPS.PORT .. endpoint

    



    local success, res = pcall(function()

        return req({

            Url = url,

            Method = "POST",

                 Headers = {

                ["Content-Type"] = "application/json",

                ["X-API-Key"] = VPS.SECRET -- 🔑 ESTE ES EL CAMBIO IMPORTANTE

            },



            Body = HttpService:JSONEncode(payload)

        })

    end)

    

    if not success then

        warn(": " .. tostring(res))

        return false

    end



    if res.StatusCode ~= 200 then

        warn(".")

        return false, nil

    end



    -- Decodificamos lo que la IA nos está ordenando

    local responseData = HttpService:JSONDecode(res.Body)

    

    return true, responseData



end





-- Función segura para recolectar el estado actual de tu Auto-Tuner

local function CollectStats()

    local totalS, totalH, iter, bestHR = 0, 0, 0, 0

    

    pcall(function()

        if AutoTuner then

            if AutoTuner.global then

                totalS = AutoTuner.global.totalShots or 0

                totalH = AutoTuner.global.totalHits or 0

                iter = AutoTuner.global.iteration or 0

                bestHR = AutoTuner.global.bestHitRate or 0

            else

                totalS = AutoTuner.totalShots or 0

                totalH = AutoTuner.totalHits or 0

                iter = AutoTuner.iteration or 0

                bestHR = AutoTuner.bestHitRate or 0

            end

        end

    end)

    

    return {

        total_shots = totalS,

        total_hits = totalH,

        iteration = iter,

        best_hit_rate = bestHR,

        params = {} 

    }

end



-- 1. Heartbeat Loop (Avisa cada 15 segundos que sigues vivo)

task.spawn(function()

    task.wait(3)

    while true do

        local payload = {

            session_id = VPS.SessionID,

            stats = CollectStats()

        }

        local success, resData = SendToVPS("/heartbeat", payload)

        

        -- 🔥 AQUÍ SUCEDE LA MAGIA: Lua se reescribe con la mente de Génesis

        if success and resData and resData.config_overrides then

            for configKey, newValue in pairs(resData.config_overrides) do

                if NathConfig[configKey] and NathConfig[configKey] ~= newValue then

                    NathConfig[configKey] = newValue

                    print(" " .. configKey .. " a " .. tostring(newValue) .. ".")

                end

            end

        end

        

        task.wait(15)

    end

end)



-- 2. Reporte de Estadísticas (Avisa cada 60 segundos con updates)

task.spawn(function()

    task.wait(10) -- Manda el primer reporte a los 10 segundos

    while true do

        local payload = {

            session_id = VPS.SessionID,

            stats = CollectStats()

        }

        SendToVPS("/report_stats", payload)

        task.wait(60) -- Luego ya espera 60s

    end

end)









-- ==========================================

-- 🌌 MEDIDOR DE GRAVEDAD EFECTIVA

-- ==========================================

local MeasuredGravity = {}



local function UpdateMeasuredGravity(player, part, dt)

    local id = player.UserId

    if not MeasuredGravity[id] then

        MeasuredGravity[id] = {lastVelY = part.AssemblyLinearVelocity.Y, g = GRAVITY, samples = {}}

        return

    end

    local m = MeasuredGravity[id]

    local curVelY = part.AssemblyLinearVelocity.Y

    

    if curVelY < -1 and dt > 0.01 and dt < 0.1 then

        local measuredG = (m.lastVelY - curVelY) / dt

        if measuredG > 50 and measuredG < 400 then

            table.insert(m.samples, measuredG)

            if #m.samples > 8 then table.remove(m.samples, 1) end

            local sum = 0

            for _, g in ipairs(m.samples) do sum = sum + g end

            m.g = sum / #m.samples

        end

    end

    m.lastVelY = curVelY

end



local function GetEffectiveGravity(player)

    local m = MeasuredGravity[player.UserId]

    return (m and m.g) or GRAVITY

end



-- ==========================================

-- 🌊 ONE EURO FILTER (anti-jitter)

-- ==========================================

local OneEuroFilters = {}



local function makeOneEuro(minCutoff, beta)

    return {minCutoff = minCutoff or 1.0, beta = beta or 0.007, dCutoff = 1.0, xPrev = nil, dxPrev = Vector3.zero, tPrev = nil}

end



local function alphaFromCutoff(cutoff, dt)

    local tau = 1 / (2 * math.pi * cutoff)

    return 1 / (1 + tau / dt)

end



local function oneEuroFilter(f, x, t)

    if not f.tPrev then f.tPrev = t; f.xPrev = x; return x end

    local dt = math.max(t - f.tPrev, 1e-4)

    local dx = (x - f.xPrev) / dt

    local aD = alphaFromCutoff(f.dCutoff, dt)

    local dxHat = f.dxPrev + aD * (dx - f.dxPrev)

    local cutoff = f.minCutoff + f.beta * dxHat.Magnitude

    local a = alphaFromCutoff(cutoff, dt)

    local xHat = f.xPrev + (x - f.xPrev) * a

    f.xPrev = xHat; f.dxPrev = dxHat; f.tPrev = t

    return xHat

end



local function getEuroFilter(id, speed)
    if not OneEuroFilters[id] then 
        OneEuroFilters[id] = makeOneEuro(15.0, 0.03) -- 🔥 Base súper rígida para que no haya delay al apuntar
        OneEuroFilters[id].lastStablePos = nil 
    end
    
    -- 🧠 IA DINÁMICA: Ajuste agresivo ("Snappy")
    -- 🧠 IA DINÁMICA: Reacción violenta e instantánea
    if speed then
        if speed < 4 then
            OneEuroFilters[id].minCutoff = 2.0  -- Reacción hiper-rápida de cerca
            OneEuroFilters[id].beta = 0.01
        elseif speed > 20 then
            OneEuroFilters[id].minCutoff = 15.0  -- Latigazo agresivo si corre o salta
            OneEuroFilters[id].beta = 0.03
        else
            OneEuroFilters[id].minCutoff = 8.0   -- Cero delay en movimiento normal
            OneEuroFilters[id].beta = 0.02
        end
    end
    return OneEuroFilters[id]
end



-- ==========================================

-- ⚙️ AUTO-TUNING

-- ==========================================

local ShotHistory = {} 

local MAX_SHOT_HISTORY = 20



local AdaptiveTuning = {

    PredMultBias = 0, BufferBias = 0, DecayBias = 0, LearningRate = 0.015, Enabled = true

}



local function RegisterShot(targetPlayer, predictedPos, targetPartRef)

    if not targetPlayer or not targetPartRef then return end

    table.insert(ShotHistory, {playerId = targetPlayer.UserId, predicted = predictedPos, partRef = targetPartRef, time = tick(), evaluated = false})

    if #ShotHistory > MAX_SHOT_HISTORY then table.remove(ShotHistory, 1) end

end



task.spawn(function()

    while task.wait(0.3) do

        if not AdaptiveTuning.Enabled then continue end

        local now = tick()

        local totalError, samples = Vector3.zero, 0

        for _, shot in ipairs(ShotHistory) do

            if not shot.evaluated and shot.partRef and shot.partRef.Parent then

                local elapsed = now - shot.time

                if elapsed > 0.15 and elapsed < 1.5 then

                    local actualPos = shot.partRef.Position

                    local err = actualPos - shot.predicted

                    err = Vector3.new(err.X, 0, err.Z)

                    if err.Magnitude < 30 then 

                        totalError = totalError + err; samples = samples + 1

                    end

                    shot.evaluated = true

                end

            end

        end

        if samples >= 3 then

            local errMag = (totalError / samples).Magnitude

            if errMag > 1.5 then

                local sign = (errMag > 4) and 1 or 0.5

                AdaptiveTuning.PredMultBias = math.clamp(AdaptiveTuning.PredMultBias + (errMag / 20) * AdaptiveTuning.LearningRate * sign, -0.15, 0.20)

                AdaptiveTuning.BufferBias = math.clamp(AdaptiveTuning.BufferBias + (errMag / 200) * AdaptiveTuning.LearningRate, -0.015, 0.025)

            else

                AdaptiveTuning.PredMultBias = AdaptiveTuning.PredMultBias * 0.98

                AdaptiveTuning.BufferBias = AdaptiveTuning.BufferBias * 0.98

            end

        end

    end

end)



local function GetTunedPredMult() return NathConfig.PredMultiplier + AdaptiveTuning.PredMultBias end

local function GetTunedBuffer() return NathConfig.ReplicationBuffer + AdaptiveTuning.BufferBias end



-- ==========================================

-- 🐰 BHOP RHYTHM PREDICTOR

-- ==========================================

local BhopData = {}



local function UpdateBhop(playerId, velY, isAirborne)

    if not BhopData[playerId] then

        BhopData[playerId] = {jumps = {}, lastAir = isAirborne, lastJumpTime = 0, avgInterval = 0.5}

    end

    local b = BhopData[playerId]

    local now = tick()

    

    if isAirborne and not b.lastAir and velY > 10 then

        if b.lastJumpTime > 0 then

            local interval = now - b.lastJumpTime

            if interval > 0.2 and interval < 1.5 then

                table.insert(b.jumps, interval)

                if #b.jumps > 5 then table.remove(b.jumps, 1) end

                local sum = 0

                for _, j in ipairs(b.jumps) do sum = sum + j end

                b.avgInterval = sum / #b.jumps

            end

        end

        b.lastJumpTime = now

    end

    b.lastAir = isAirborne

end



local function GetBhopPrediction(playerId, currentVelY, isAirborne)

    local b = BhopData[playerId]

    if not b or #b.jumps < 2 then return 0, false end

    

    local variance = 0

    for _, j in ipairs(b.jumps) do variance = variance + (j - b.avgInterval)^2 end

    variance = variance / #b.jumps

    

    if variance < 0.05 then 

        local timeSinceJump = tick() - b.lastJumpTime

        local timeToNextJump = b.avgInterval - timeSinceJump

        return timeToNextJump, true

    end

    return 0, false

end



-- ==========================================

-- 🚀 JUMP IMPULSE DETECTOR

-- ==========================================

local JumpImpulse = {}



local function DetectJumpImpulse(player, currentVelY, dt)

    local id = player.UserId

    if not JumpImpulse[id] then

        JumpImpulse[id] = {lastVy = currentVelY, justJumped = false, jumpPower = 50}

        return

    end

    local j = JumpImpulse[id]

    local deltaVy = currentVelY - j.lastVy

    

    if deltaVy > 30 and dt < 0.1 then

        j.justJumped = true; j.jumpTime = tick(); j.jumpPower = currentVelY

    else

        if j.jumpTime and tick() - j.jumpTime > 0.1 then j.justJumped = false end

    end

    j.lastVy = currentVelY

end



local function GetJumpCompensation(player, leadT)

    local j = JumpImpulse[player.UserId]

    if not j or not j.justJumped then return 0 end

    local timeSinceJump = tick() - (j.jumpTime or 0)

    if timeSinceJump < 0.15 then

        return j.jumpPower * leadT * 0.25 

    end

    return 0

end



-- ==========================================

-- 💨 AIR CONTROL ESTIMATOR

-- ==========================================

local AirControl = {}



local function UpdateAirControl(playerId, vel, isAir, dt)

    if not AirControl[playerId] then

        AirControl[playerId] = {lastVel = vel, controlMag = 0, samples = {}}

        return

    end

    local a = AirControl[playerId]

    if isAir and dt > 0.001 then

        local horizDelta = Vector3.new(vel.X - a.lastVel.X, 0, vel.Z - a.lastVel.Z)

        local controlForce = horizDelta.Magnitude / dt

        if controlForce < 200 then

            table.insert(a.samples, controlForce)

            if #a.samples > 6 then table.remove(a.samples, 1) end

            local sum = 0

            for _, s in ipairs(a.samples) do sum = sum + s end

            a.controlMag = sum / #a.samples

        end

    end

    a.lastVel = vel

end



local function GetAirControlPenalty(playerId)

    local a = AirControl[playerId]

    if not a then return 1 end

    if a.controlMag > 30 then return 0.6

    elseif a.controlMag > 15 then return 0.8

    else return 1 end

end



-- ==========================================

-- 🧠 EKF CON JERK (V12)

-- ==========================================

local VelocityHistory = {}

local HISTORY_SIZE = 10

local EKFStates = {}









-- ==========================================

-- 🧠 LSTM-LITE

-- ==========================================

local LSTM = {Wf={},Wi={},Wo={},Wc={}, bf={},bi={},bo={},bc={}, Wy={}, by={}, lr=0.005, initialized=false}

local LSTMStates = {}



local function InitLSTM()

    math.randomseed(tick()*1000)

    local function rnd() return (math.random()*2-1)*0.3 end

    for i = 1, 6 do

        LSTM.Wf[i]={}; LSTM.Wi[i]={}; LSTM.Wo[i]={}; LSTM.Wc[i]={}

        for j = 1, 12 do

            LSTM.Wf[i][j]=rnd(); LSTM.Wi[i][j]=rnd(); LSTM.Wo[i][j]=rnd(); LSTM.Wc[i][j]=rnd()

        end

        LSTM.bf[i]=0; LSTM.bi[i]=0; LSTM.bo[i]=0; LSTM.bc[i]=0

    end

    for i = 1, 3 do

        LSTM.Wy[i]={}

        for j = 1, 6 do LSTM.Wy[i][j]=rnd() end

        LSTM.by[i]=0

    end

    LSTM.initialized = true

end



local function sigmoid(x) if x>10 then return 1 elseif x<-10 then return 0 end; return 1/(1+math.exp(-x)) end

local function tanhf(x) if x>10 then return 1 elseif x<-10 then return -1 end; local e1,e2=math.exp(x),math.exp(-x); return (e1-e2)/(e1+e2) end







local NNHistoryByPlayer = {}

local function GetNeuralCorrection(playerId, vel, accel, leadTime)

    local input = {vel.X/50, vel.Y/50, vel.Z/50, accel.X/100, accel.Y/100, accel.Z/100}

    local out = LSTMForward(playerId, input)

    NNHistoryByPlayer[playerId] = {input=input, time=tick(), predicted=out, leadTime=leadTime}

    return Vector3.new(out[1]*leadTime, out[2]*leadTime, out[3]*leadTime) * 2

end



InitLSTM()



-- ==========================================

-- 🦅 AERIAL NEURAL NETWORK

-- ==========================================

local AerialNN = {W1={}, b1={}, W2={}, b2={}, lr=0.012, initialized=false}

local aerialTrainingCount = 0



local function InitAerialNN()

    local function xv(n) return (math.random()*2-1)*math.sqrt(2/n) end

    for i = 1, 16 do

        AerialNN.W1[i] = {}

        for j = 1, 10 do AerialNN.W1[i][j] = xv(10) end

        AerialNN.b1[i] = 0

    end

    for i = 1, 3 do

        AerialNN.W2[i] = {}

        for j = 1, 16 do AerialNN.W2[i][j] = xv(16) end

        AerialNN.b2[i] = 0

    end

    AerialNN.initialized = true

end



local function relu(x) return x > 0 and x or x * 0.01 end 







local function AerialTrain(input, target, hidden)

    local pred, h = AerialForward(input)

    local errOut = {target[1]-pred[1], target[2]-pred[2], target[3]-pred[3]}

    

    local dH = {}

    for j = 1, 16 do

        local s = 0

        for i = 1, 3 do s = s + errOut[i] * AerialNN.W2[i][j] end

        dH[j] = (h[j] > 0) and s or s * 0.01

    end

    

    for i = 1, 3 do

        for j = 1, 16 do AerialNN.W2[i][j] = AerialNN.W2[i][j] + AerialNN.lr * errOut[i] * h[j] end

        AerialNN.b2[i] = AerialNN.b2[i] + AerialNN.lr * errOut[i]

    end

    for i = 1, 16 do

        for j = 1, 10 do AerialNN.W1[i][j] = AerialNN.W1[i][j] + AerialNN.lr * dH[i] * input[j] end

        AerialNN.b1[i] = AerialNN.b1[i] + AerialNN.lr * dH[i]

    end

end



InitAerialNN()



local AerialHistory = {}

local function GetAerialCorrection(playerId, myVel, myAir, tVel, tAir, dist, leadT, effG, phase)

    local phaseNum = (phase == "ASCENDING") and 1 or (phase == "PEAK") and 0 or -1

    local input = {

        myVel.Y/50, myAir and 1 or 0,

        tVel.Y/50, tAir and 1 or 0,

        dist/200,

        (tVel.X - myVel.X)/50, (tVel.Z - myVel.Z)/50,

        leadT, effG/200, phaseNum

    }

    local out, h = AerialForward(input)

    AerialHistory[playerId] = {input=input, hidden=h, time=tick(), leadT=leadT, predicted=out}

    return Vector3.new(out[1]*leadT*3, out[2]*leadT*3, out[3]*leadT*3)

end



task.spawn(function()

    while task.wait(0.35) do

        local now = tick()

        for pid, d in pairs(AerialHistory) do

            local elapsed = now - d.time

            if elapsed >= d.leadT and elapsed < d.leadT + 0.4 then

                local plr = Players:GetPlayerByUserId(pid)

                if plr and plr.Character then

                    local part = plr.Character:FindFirstChild("HumanoidRootPart")

                    if part then

                        local actual = part.Position

                        local target = {

                            math.clamp(actual.X/100, -2, 2),

                            math.clamp(actual.Y/100, -2, 2),

                            math.clamp(actual.Z/100, -2, 2)

                        }

                        AerialTrain(d.input, target, d.hidden)

                        aerialTrainingCount = aerialTrainingCount + 1

                    end

                end

                AerialHistory[pid] = nil

            elseif elapsed > 2 then AerialHistory[pid] = nil end

        end

    end

end)



-- ==========================================

-- 💾 NEURAL PERSISTENCE SYSTEM

-- ==========================================

local SAVE_FILE = "NathalyHub_NeuralBrain.json"

local SAVE_INTERVAL = 25 

local lastSaveTime = 0



local hasFileSystem = (writefile and readfile and isfile and delfile) ~= nil



local function SaveBrain()

    if not hasFileSystem then return end

    

    local data = {

        version = "V12.2",

        savedAt = os.time(),

        

        lstm = {

            Wf = LSTM.Wf, Wi = LSTM.Wi, Wo = LSTM.Wo, Wc = LSTM.Wc,

            bf = LSTM.bf, bi = LSTM.bi, bo = LSTM.bo, bc = LSTM.bc,

            Wy = LSTM.Wy, by = LSTM.by

        },

        

        aerial = {

            W1 = AerialNN.W1, b1 = AerialNN.b1,

            W2 = AerialNN.W2, b2 = AerialNN.b2

        },

        

        aerialTrainingCount = aerialTrainingCount or 0,

        totalShots = #ShotHistory or 0

    }

    

    local ok, encoded = pcall(function()

        return HttpService:JSONEncode(data)

    end)

    

    if ok and encoded then

        local writeOk = pcall(function() writefile(SAVE_FILE, encoded) end)

        if writeOk then

            print("[GENESIS] 🧠 Cerebro guardado ("..string.format("%.1f", #encoded/1024).." KB)")

        end

    end

end



local function LoadBrain()

    if not hasFileSystem then 

        warn("[GENESIS] Executor sin soporte de archivos, red empieza desde cero")

        return false 

    end

    

    if not isfile(SAVE_FILE) then

        print("[GENESIS] 🆕 Sin cerebro previo, iniciando aprendizaje desde cero")

        return false

    end

    

    local ok, data = pcall(function()

        local content = readfile(SAVE_FILE)

        return HttpService:JSONDecode(content)

    end)

    

    if not ok or not data then

        warn("[GENESIS] Archivo corrupto, iniciando desde cero")

        return false

    end

    

    if data.lstm and LSTM then

        LSTM.Wf = data.lstm.Wf or LSTM.Wf

        LSTM.Wi = data.lstm.Wi or LSTM.Wi

        LSTM.Wo = data.lstm.Wo or LSTM.Wo

        LSTM.Wc = data.lstm.Wc or LSTM.Wc

        LSTM.bf = data.lstm.bf or LSTM.bf

        LSTM.bi = data.lstm.bi or LSTM.bi

        LSTM.bo = data.lstm.bo or LSTM.bo

        LSTM.bc = data.lstm.bc or LSTM.bc

        LSTM.Wy = data.lstm.Wy or LSTM.Wy

        LSTM.by = data.lstm.by or LSTM.by

    end

    

    if data.aerial and AerialNN then

        AerialNN.W1 = data.aerial.W1 or AerialNN.W1

        AerialNN.b1 = data.aerial.b1 or AerialNN.b1

        AerialNN.W2 = data.aerial.W2 or AerialNN.W2

        AerialNN.b2 = data.aerial.b2 or AerialNN.b2

    end

    

    aerialTrainingCount = data.aerialTrainingCount or 0

    

    local age = data.savedAt and os.difftime(os.time(), data.savedAt) or 0

    local ageStr = age < 3600 and string.format("%.0f min", age/60) 

                 or age < 86400 and string.format("%.1f hrs", age/3600)

                 or string.format("%.1f días", age/86400)

    

    print("[GENESIS] 🧠 Cerebro cargado | Entrenamientos previos: "..aerialTrainingCount.." | Edad: "..ageStr)

    return true

end



LoadBrain()







task.spawn(function()

    while task.wait(SAVE_INTERVAL) do

        SaveBrain()

    end

end)



-- Aquí borramos el BindToClose que crasheaba todo alv



LocalPlayer.AncestryChanged:Connect(function()

    if not LocalPlayer.Parent then SaveBrain() end

end)







-- ==========================================

-- 🧠 PATTERN DETECTOR Y PARTICLE FILTER

-- ==========================================

local PatternData = {}

local function DetectPattern(playerId, vel)

    if not PatternData[playerId] then PatternData[playerId] = {velY_history = {}, velX_history = {}, lastPeriod = 0} end

    local p = PatternData[playerId]

    table.insert(p.velY_history, vel.Y)

    table.insert(p.velX_history, vel.X)

    if #p.velY_history > 20 then table.remove(p.velY_history, 1); table.remove(p.velX_history, 1) end

    if #p.velY_history < 12 then return 0, 0 end

    local crossings = 0

    for i = 2, #p.velY_history do

        if (p.velY_history[i] > 0) ~= (p.velY_history[i-1] > 0) then crossings = crossings + 1 end

    end

    local rhythm = math.min(crossings / 10, 1)

    p.lastPeriod = rhythm

    return rhythm, crossings

end



local function ParticlePredict(targetPos, vel, accel, t, isAirborne, effGravity, N)

    N = N or 250

    local sumX, sumY, sumZ, totalW = 0, 0, 0, 0

    for i = 1, N do

        local n1 = math.sqrt(-2*math.log(math.random()+1e-6)) * math.cos(2*math.pi*math.random())

        local n2 = math.sqrt(-2*math.log(math.random()+1e-6)) * math.cos(2*math.pi*math.random())

        local scale = 0.06 * vel.Magnitude + 2

        local vx = vel.X + n1*scale*0.4

        local vz = vel.Z + n2*scale*0.4

        local ax = accel.X * (1 + n1*0.15)

        local az = accel.Z * (1 + n2*0.15)

        local px = targetPos.X + vx*t + 0.5*ax*t*t

        local pz = targetPos.Z + vz*t + 0.5*az*t*t

        local py = targetPos.Y

        if isAirborne then py = targetPos.Y + vel.Y*t - 0.5*effGravity*t*t end

        local w = math.exp(-(n1*n1 + n2*n2) * 0.5)

        sumX = sumX + px*w; sumY = sumY + py*w; sumZ = sumZ + pz*w

        totalW = totalW + w

    end

    return Vector3.new(sumX/totalW, sumY/totalW, sumZ/totalW)

end



-- ==========================================

-- 🧠 COMPENSACIÓN, CONFIANZA Y ESTADOS

-- ==========================================

local SelfStateHistory = {samples = {}, lastPos = nil, lastTime = 0}



local function UpdateSelfState()

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not myRoot then return end

    local now = tick()

    if SelfStateHistory.lastPos then

        local dt = now - SelfStateHistory.lastTime

        if dt > 0.005 then

            local realVel = (myRoot.Position - SelfStateHistory.lastPos) / dt

            table.insert(SelfStateHistory.samples, {vel = realVel, time = now, pos = myRoot.Position})

            if #SelfStateHistory.samples > 8 then table.remove(SelfStateHistory.samples, 1) end

        end

    end

    SelfStateHistory.lastPos = myRoot.Position

    SelfStateHistory.lastTime = now

end



local function GetSelfBallistic()

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

    if not myRoot then return Vector3.zero, 1.0 end

    

    local myVel = myRoot.AssemblyLinearVelocity

    local airborne = myHum and myHum.FloorMaterial == Enum.Material.Air

    

    local myAccel = Vector3.zero

    if #SelfStateHistory.samples >= 2 then

        local s1 = SelfStateHistory.samples[#SelfStateHistory.samples]

        local s0 = SelfStateHistory.samples[#SelfStateHistory.samples-1]

        local dt = s1.time - s0.time

        if dt > 0.001 then myAccel = (s1.vel - s0.vel) / dt end

    end

    

    local shotDelay = NathConfig.ShootDelay + currentPing

    local futureOriginOffset = myVel * shotDelay + 0.5 * myAccel * shotDelay * shotDelay

    if airborne then

        futureOriginOffset = futureOriginOffset + Vector3.new(0, -0.5 * GRAVITY * shotDelay * shotDelay, 0)

    end

    

    local stability = 1.0

    local horizSpeed = Vector3.new(myVel.X, 0, myVel.Z).Magnitude

    if airborne then

        if math.abs(myVel.Y) > 30 then stability = 0.75

        elseif horizSpeed > 25 then stability = 0.82

        else stability = 0.90 end

    end

    

    return futureOriginOffset, stability

end



local function GetDirectionConfidence(player)

    local data = VelocityHistory[player.UserId]

    if not data or #data.samples < 3 then return 1 end

    local recent = data.samples[#data.samples].vel

    local older = data.samples[1].vel

    if recent.Magnitude < 1 or older.Magnitude < 1 then return 1 end

    local dot = recent.Unit:Dot(older.Unit)

    return math.clamp(dot, 0.75, 1)

end



local function GetDirectionChangeFactor(player, currentVel)

    local data = VelocityHistory[player.UserId]

    if not data or #data.samples < 3 then return 1 end

    local lastSample = data.samples[#data.samples].vel

    if lastSample.Magnitude < 2 or currentVel.Magnitude < 2 then return 1 end

    local dot = lastSample.Unit:Dot(currentVel.Unit)

    if dot < 0.3 then return 0.2 elseif dot < 0.6 then return 0.5 elseif dot < 0.85 then return 0.8 end

    return 1

end



local function GetAccelerationPenalty(player)

    local data = VelocityHistory[player.UserId]

    if not data or #data.samples < 2 then return 1 end

    local v1 = data.samples[#data.samples].vel

    local v0 = data.samples[#data.samples - 1].vel

    local deltaMag = (v1 - v0).Magnitude

    if deltaMag > 25 then return 0.4 elseif deltaMag > 15 then return 0.65 elseif deltaMag > 8 then return 0.85 end

    return 1

end



local function GetAverageAcceleration(player)

    local data = VelocityHistory[player.UserId]

    if not data or #data.samples < 4 then return Vector3.zero end

    local s1 = data.samples[#data.samples]

    local s2 = data.samples[math.max(1, #data.samples - 1)]

    local s3 = data.samples[math.max(1, #data.samples - 3)]

    local dt1, dt2 = s1.time - s2.time, s2.time - s3.time

    if dt1 <= 0.001 or dt2 <= 0.001 then return Vector3.zero end

    local accelNow = (s1.vel - s2.vel) / dt1

    local accelOld = (s2.vel - s3.vel) / dt2

    local smoothedAccel = (accelNow * 0.7) + (accelOld * 0.3)

    if smoothedAccel.Magnitude > 120 then smoothedAccel = smoothedAccel.Unit * 120 end

    return Vector3.new(smoothedAccel.X, 0, smoothedAccel.Z)

end



local function GetJumpPhase(velY)

    if velY > 5 then return "ASCENDING" elseif velY < -5 then return "FALLING" else return "PEAK" end

end



local function ClassifyMovementState(player, vel, isAirborne)

    local data = VelocityHistory[player.UserId]

    if not data or #data.samples < 4 then return "UNKNOWN", 1.0 end

    local speed = vel.Magnitude

    local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude

    local avgDir, validSamples = Vector3.zero, 0

    for _, s in ipairs(data.samples) do

        if s.vel.Magnitude > 1 then avgDir = avgDir + s.vel.Unit; validSamples = validSamples + 1 end

    end

    if validSamples > 0 then avgDir = avgDir / validSamples end

    local variance = 0

    for _, s in ipairs(data.samples) do

        if s.vel.Magnitude > 1 then variance = variance + (s.vel.Unit - avgDir).Magnitude end

    end

    if validSamples > 0 then variance = variance / validSamples end

    

    if speed < 1 then return "STATIONARY", 1.0

    elseif isAirborne and math.abs(vel.Y) > 15 then return "BHOP", 0.55

    elseif variance > 0.6 then return "STRAFING", 0.65

    elseif variance > 0.3 then return "EVASIVE", 0.80

    elseif horizontalSpeed > 10 then return "RUNNING_STRAIGHT", 0.95

    else return "WALKING", 0.90 end

end



local function GetAdaptiveReplicationBuffer(distance, vel)
    local baseBuffer = GetTunedBuffer()
    -- 🔥 Casi cero delay artificial, pura reacción cruda
    if distance < 35 then 
        return baseBuffer * 0.02 -- Reacción pura en corto alcance
    elseif distance < 100 then 
        return baseBuffer * 0.15 
    end
    return baseBuffer * 0.4 
end



local function GetDynamicLeadCap(distance)

    if not NathConfig.DynamicLeadCap then return NathConfig.MaxLeadTime end

    local timeOfFlight = distance / NathConfig.BulletSpeed

    return math.clamp(timeOfFlight * 1.3, 0.1, 2.5)

end



-- ==========================================

-- 🌌 RELATIVE PHYSICS SOLVER

-- ==========================================

local function SolveRelativePhysics(myOrigin, myVel, myAirborne, targetPos, targetVel, targetAirborne, effGravity)

    local t = (targetPos - myOrigin).Magnitude / NathConfig.BulletSpeed

    local bestT = t

    local bestErr = math.huge

    

    for iter = 1, 8 do

        local myFutureOrigin

        if myAirborne then

            myFutureOrigin = myOrigin + Vector3.new(

                myVel.X * t,

                myVel.Y * t - 0.5 * GRAVITY * t * t,

                myVel.Z * t

            )

        else

            myFutureOrigin = myOrigin + Vector3.new(myVel.X * t, 0, myVel.Z * t)

        end

        

        local targetFuturePos

        if targetAirborne then

            targetFuturePos = targetPos + Vector3.new(

                targetVel.X * t,

                targetVel.Y * t - 0.5 * effGravity * t * t,

                targetVel.Z * t

            )

        else

            targetFuturePos = targetPos + targetVel * t

        end

        

        local newDist = (targetFuturePos - myFutureOrigin).Magnitude

        local newT = newDist / NathConfig.BulletSpeed

        

        local err = math.abs(newT - t)

        if err < bestErr then

            bestErr = err

            bestT = newT

        end

        

        if err < 0.003 then break end

        t = t * 0.5 + newT * 0.5 

    end

    

    return bestT

end



-- ==========================================

-- 🎯 HITBOX-AWARE & RAYCASTS

-- ==========================================

local function GetOptimalHitPoint(part, origin, velocity, leadTime)
    -- 🔥 FIX: Retornamos el centro exacto de la parte sin mover la mira a los bordes. Cero picos.
    return part.Position
end



local function IsTrajectoryClear(origin, predictedPos, targetChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    -- Ignora a los demás jugadores vivos para que no estorben el tiro
    local ignoreList = {LocalPlayer.Character, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character ~= targetChar then
            table.insert(ignoreList, p.Character)
        end
    end
    params.FilterDescendantsInstances = ignoreList

    local dir = predictedPos - origin
    local distLeft = dir.Magnitude
    local curOrigin = origin

    -- Bucle para perforar hasta 5 capas de paredes falsas o cristales
    for i = 1, 5 do
        local res = Workspace:Raycast(curOrigin, dir.Unit * distLeft, params)
        if not res or (res.Instance and res.Instance:IsDescendantOf(targetChar)) then return true end
        
        if res.Instance.Transparency >= 0.5 or not res.Instance.CanCollide then
            table.insert(ignoreList, res.Instance)
            params.FilterDescendantsInstances = ignoreList
            curOrigin = res.Position + (dir.Unit * 0.01)
            distLeft = (predictedPos - curOrigin).Magnitude
        else
            return false -- Chocó con pared sólida real
        end
    end
    return false
end



local function GetSafePredictedPos(origin, currentPos, predictedPos, targetChar)

    if IsTrajectoryClear(origin, predictedPos, targetChar) then return predictedPos, 1.0 end

    for step = 0.8, 0.2, -0.15 do

        local lerped = currentPos:Lerp(predictedPos, step)

        if IsTrajectoryClear(origin, lerped, targetChar) then return lerped, step end

    end

    return currentPos, 0

end



local VisibilityMemory = {}

local function UpdateVisibilityMemory(player, isVisibleNow)

    local id = player.UserId

    local now = tick()

    if not VisibilityMemory[id] then

        VisibilityMemory[id] = {lastVisible = isVisibleNow and now or 0, lastHidden = isVisibleNow and 0 or now, wasVisible = isVisibleNow, justAppeared = isVisibleNow and now or nil}

        return

    end

    local mem = VisibilityMemory[id]

    if isVisibleNow then

        mem.lastVisible = now

        if not mem.wasVisible then mem.justAppeared = now end

    else mem.lastHidden = now end

    mem.wasVisible = isVisibleNow

end



local function JustPeeked(player, windowSec)

    local mem = VisibilityMemory[player.UserId]

    if not mem or not mem.justAppeared then return false end

    return (tick() - mem.justAppeared) <= (windowSec or 0.35)

end



-- ==========================================

-- 🎲 HMM INTENT PREDICTOR

-- ==========================================

local HMMStates = {}

local function HMMUpdate(playerId, vel, dt)

    if not HMMStates[playerId] then HMMStates[playerId] = {probs = {0.25,0.25,0.25,0.25}, lastVel = vel, framesInState = 0} end

    local h = HMMStates[playerId]

    local dv = vel - h.lastVel

    local horizMag = Vector3.new(dv.X,0,dv.Z).Magnitude

    local right = Vector3.new(vel.Z, 0, -vel.X)

    if right.Magnitude > 0.1 then right = right.Unit end

    local lateral = dv:Dot(right)

    local obs = {0,0,0,0}

    if horizMag < 1 then obs[1] = 0.7; obs[4] = 0.3

    elseif lateral > 1 then obs[3] = 0.8; obs[1] = 0.2

    elseif lateral < -1 then obs[2] = 0.8; obs[1] = 0.2

    else obs[1] = 0.7; obs[2] = 0.15; obs[3] = 0.15 end

    

    local newProbs, total = {}, 0

    for i = 1, 4 do

        newProbs[i] = (h.probs[i]*0.7 + 0.075) * obs[i]

        total = total + newProbs[i]

    end

    for i = 1, 4 do newProbs[i] = newProbs[i] / math.max(total, 1e-6) end

    h.probs = newProbs; h.lastVel = vel

    

    local maxI, maxP = 1, 0

    for i = 1, 4 do if newProbs[i] > maxP then maxP = newProbs[i]; maxI = i end end

    if maxI == 2 then return -right * vel.Magnitude * 0.15 * maxP

    elseif maxI == 3 then return right * vel.Magnitude * 0.15 * maxP

    elseif maxI == 4 then return -vel * 0.1 * maxP

    else return Vector3.zero end

end



Players.PlayerRemoving:Connect(function(p)

    local id = p.UserId

    VelocityHistory[id] = nil

    EKFStates[id] = nil

    OneEuroFilters[id] = nil

    HMMStates[id] = nil

    LSTMStates[id] = nil

    MeasuredGravity[id] = nil

    BhopData[id] = nil

    JumpImpulse[id] = nil

    AirControl[id] = nil

    AerialHistory[id] = nil

end)



-- ==========================================

-- 🎨 UI & VISUALS

-- ==========================================

local UI_Container = Instance.new("ScreenGui")

UI_Container.Name = "NathalyVisuals"

UI_Container.IgnoreGuiInset = true

pcall(function() UI_Container.Parent = (gethui and gethui()) or CoreGui end)

if not UI_Container.Parent then UI_Container.Parent = LocalPlayer:WaitForChild("PlayerGui") end



local CurrentPosBox = Instance.new("Frame")

CurrentPosBox.Size = UDim2.new(0, 20, 0, 20)

CurrentPosBox.AnchorPoint = Vector2.new(0.5, 0.5)

CurrentPosBox.BackgroundTransparency = 1

CurrentPosBox.BorderSizePixel = 2

CurrentPosBox.BorderColor3 = Color3.fromRGB(255, 255, 255)

CurrentPosBox.Visible = false

CurrentPosBox.Parent = UI_Container



local PredictionCrosshair = Instance.new("Frame")

PredictionCrosshair.Size = UDim2.new(0, 12, 0, 12)

PredictionCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)

PredictionCrosshair.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

PredictionCrosshair.BackgroundTransparency = 0.1

PredictionCrosshair.BorderSizePixel = 0

PredictionCrosshair.Visible = false

PredictionCrosshair.Parent = UI_Container



local UIStroke = Instance.new("UICorner")

UIStroke.CornerRadius = UDim.new(1, 0)

UIStroke.Parent = PredictionCrosshair



local rayParams = RaycastParams.new()

rayParams.FilterType = Enum.RaycastFilterType.Exclude

rayParams.IgnoreWater = true



local function IsVisible(predictedPos, targetChar)

    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")

    if not head then return false end

    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

    local origin = head.Position

    local result = Workspace:Raycast(origin, predictedPos - origin, rayParams)

    if not result or (result.Instance and result.Instance:IsDescendantOf(targetChar)) then return true end

    return false

end







local function GetPredictedPosition(targetChar)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tempRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChild("Humanoid")
    
    if not myRoot or not tempRoot or not humanoid then return nil, nil end

    -- Apuntar al Torso siempre da los tiros más consistentes
    local bestPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or tempRoot
    local origin = Camera.CFrame.Position
    local distance = (bestPart.Position - origin).Magnitude
    
    local velocity = tempRoot.AssemblyLinearVelocity
    
    -- CERO TEMBLORES: Ignoramos micro-movimientos
    if velocity.Magnitude < 3.5 then
        velocity = Vector3.zero
    end

    local mm2GunDelay = 0.12 
    local safePing = math.clamp(currentPing, 0.01, 0.10)
    
    -- 🛠️ FIX: Redujimos el impacto de la distancia en el cálculo porque en MM2 la bala viaja muy rápido
    local timeToHit = mm2GunDelay + safePing + (distance / 5000) 
    
    -- 🧠 AMORTIGUADOR DE LEJANÍA (Distance Falloff):
    -- Si el wey está a más de 50 studs de ti, bajamos la intensidad de la predicción 
    -- progresivamente (hasta un máximo de 65% de fuerza) para no apuntar demasiado lejos de él.
    local intensityMult = 1.0
    if distance > 50 then
        intensityMult = math.clamp(1 - ((distance - 50) / 250), 0.65, 1.0)
    end
    timeToHit = timeToHit * intensityMult

    -- Compensación horizontal
    local predX = velocity.X * timeToHit
    local predZ = velocity.Z * timeToHit
    local predY = 0

    -- 🎈 Compensación vertical solo si está en el aire
    local isAirborne = humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping
    if isAirborne then
        -- Cancelamos la caída natural sumando la gravedad (afectada por el amortiguador)
        local gravityDrop = 0.5 * Workspace.Gravity * (timeToHit ^ 2)
        predY = (velocity.Y * timeToHit) - gravityDrop
    else
        predY = velocity.Y * timeToHit
    end

    local predictionOffset = Vector3.new(predX, predY, predZ)
    local rawPred = bestPart.Position + predictionOffset

    -- 🧱 ANTI-PAREDES
    if not IsTrajectoryClear(origin, rawPred, targetChar) then
        local headPart = targetChar:FindFirstChild("Head")
        if headPart then
            local headPred = headPart.Position + predictionOffset
            if IsTrajectoryClear(origin, headPred, targetChar) then
                return headPred, headPart
            end
        end
    end

    return rawPred, bestPart
end


GetSmartShotPosition = function(targetChar)
    -- 1. Sacamos la predicción perfecta de nuestra matemática
    local predictedPos, bestPart = GetPredictedPosition(targetChar)

    if not bestPart or not predictedPos then return nil end

    -- 2. Mantenemos el rastreador de memoria de IA para que no se rompa el Genesis
    local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
    local bodyVisibleNow = IsVisible(bestPart.Position, targetChar)
    
    if targetPlayer then 
        UpdateVisibilityMemory(targetPlayer, bodyVisibleNow) 
    end
    
    -- 🔥 FIX: Le ordenamos al arma que regrese EXACTAMENTE la misma posición de la mira
    -- Ya no hay microLead, ni snapPos, ni desvíos pendejos.
    return predictedPos
end



-- ==========================================

-- ⏱️ CONVERGENCE QUALITY GATE 2.0 (FIX)

-- ==========================================

local lastShotTime = 0
local SHOT_COOLDOWN = 0.01 -- 🔥 Dispara en cuanto tiene la oportunidad



local function CalculateShotQuality(targetChar, predictedPos)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local bestPart = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not bestPart then return 0 end
    
    local plr = Players:GetPlayerFromCharacter(targetChar)
    local quality = 1.0

    if plr then
        local data = VelocityHistory[plr.UserId]
        if data and #data.samples >= 2 then
            local v1 = data.samples[#data.samples].vel
            local v0 = data.samples[#data.samples-1].vel
            local currentPos = bestPart.Position
            local lastPos = data.lastPos
            
            local timeDiff = tick() - data.lastTime
            
            -- 📡 1. RESOLVER ANTI-LAG (Stutter Catcher)
            -- Si se movió más rápido de lo que permite el juego (aprox 25 studs/sec en MM2), está lageado o teletransportándose.
            if timeDiff > 0.01 then
                local realSpeed = (currentPos - lastPos).Magnitude / timeDiff
                if realSpeed > 55 then 
                    return 0 -- Cancela el tiro, el wey es un fantasma por el lag
                end
            end

            if v1.Magnitude > 1 and v0.Magnitude > 1 then
                local dot = v1.Unit:Dot(v0.Unit)
                if dot < -0.2 then 
                    quality = 1.5 -- Sigue forzando el tiro en el punto muerto
                elseif dot < 0.5 then 
                    -- 🔥 FIX: Reducimos el castigo en el suelo. Ya no lo baja a 0.4, 
                    -- lo deja en 0.85 para que la IA dispare aunque haga zig-zag.
                    quality = quality * 0.85 
                end
            end
            
            -- Si su velocidad actual es casi cero pero hace un momento corría, está paralizado cambiando de lado. Tiro seguro.
            if v1.Magnitude < 3 and v0.Magnitude > 12 then
                quality = 2.0 -- Prioridad absoluta de disparo
            end
        end
        
        quality = quality * GetAirControlPenalty(plr.UserId)
    end
    
    return math.clamp(quality, 0, 1)
end



local function DispararEventoDirecto(forceShoot)
    local now = tick()
    if now - lastShotTime < SHOT_COOLDOWN then return end
    
    local targetChar = GetClosestTarget()
    if not targetChar then return end
    
    local predictedPos = GetSmartShotPosition(targetChar)
    if not predictedPos then return end

    -- 🧱 SEGURO ANTI-PAREDES
    local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    local origin = myHead and myHead.Position or Camera.CFrame.Position
    
    -- 🔥 MODIFICACIÓN AQUÍ: Si es Autoshoot (forceShoot = false) y no hay línea limpia, se bloquea.
    -- Si es el botón Manual (forceShoot = true), ignora el bloqueo del script y dispara aunque esté rojo.
    if not forceShoot and not IsTrajectoryClear(origin, predictedPos, targetChar) then
        return 
    end
    
    local quality = CalculateShotQuality(targetChar, predictedPos)

    local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    local myAir = myHum and (myHum.FloorMaterial == Enum.Material.Air) or false
    local tHum = targetChar:FindFirstChild("Humanoid")
    local tAir = tHum and (tHum.FloorMaterial == Enum.Material.Air) or false

    local minQuality = 0.05
    if myAir and tAir then minQuality = 0.02
    elseif myAir or tAir then minQuality = 0.03 end

    -- Las comprobaciones de calidad también se ignoran si el disparo es manual
    if not forceShoot and quality < minQuality then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local gun = char:FindFirstChild("Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
    
    if not forceShoot and gun and gun.Parent == LocalPlayer.Backpack then
        return
    end
    
    if gun then
        -- 1. EQUIPAR EL ARMA SIN ESPERAS
        if gun.Parent == LocalPlayer.Backpack then 
            char.Humanoid:EquipTool(gun) 
            -- 🔥 Usamos un micro-wait para que el server lo procese sin congelar tu cámara
            task.wait() 
        end
        
        -- 2. HACER EL FLICK (PARALELO, SIN CONGELAR EL TIRO)
        local cam = workspace.CurrentCamera
        local originalCFrame = cam.CFrame
        
        

        -- 3. DISPARAR (El servidor recibe el tiro instantáneamente)
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            local velocity = targetHRP.AssemblyLinearVelocity
            local moveDirection
            
            if velocity.Magnitude > 0.5 then
                moveDirection = velocity.Unit
            else
                moveDirection = targetHRP.CFrame.LookVector
            end
            
            if math.abs(moveDirection.Y) > 0.99 then
                moveDirection = (moveDirection + Vector3.new(0.001, 0, 0.001)).Unit
            end
            
            -- 🔥 FIX: Usamos el cañón de la pistola como origen, no la cabeza.
            local originPos = Camera.CFrame.Position
            if gun and gun:FindFirstChild("Handle") then
                originPos = gun.Handle.Position
            end
            local shootDirection = (predictedPos - originPos).Unit

            local fakeOriginPos = originPos
            -- Quitamos los 5 studs extra para que la bala estalle EXACTO en el centro del Murderer
            local fakeTargetPos = predictedPos

            local originCFrame = CFrame.new(fakeOriginPos, fakeTargetPos)
            local targetCFrame = CFrame.new(fakeTargetPos)

            -- Disparamos el evento de MM2
            pcall(function() gun.Shoot:FireServer(originCFrame, targetCFrame) end)
            
            -- Creamos el efecto visual
            pcall(function() gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, predictedPos, "Nath2") end)
            
            lastShotTime = tick()
            
            local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
            local partRef = targetChar:FindFirstChild("HumanoidRootPart")
            if targetPlayer and partRef then
                RegisterShot(targetPlayer, predictedPos, partRef)
                if RegistrarDisparoEfectuado then RegistrarDisparoEfectuado() end
            end
        end

        
    end
end



-- ==========================================

-- ⌨️ COMANDOS MANUALES (PERSISTENCIA)

-- ==========================================

UserInputService.InputBegan:Connect(function(input, gpe)

    if gpe then return end

    if input.KeyCode == Enum.KeyCode.F9 then

        SaveBrain()

    elseif input.KeyCode == Enum.KeyCode.F10 then

        if hasFileSystem and isfile(SAVE_FILE) then

            local ok = pcall(function() delfile(SAVE_FILE) end)

            if ok then print("[GENESIS] 🗑️ Cerebro reseteado. Reinicia el script.") end

        end

    end

end)



-- ==========================================
-- 🎨 VISUALS IN-GAME (CAJA Y MIRAS PERSONALIZABLES)
-- ==========================================
local CurrentPosBox = Instance.new("Frame")
CurrentPosBox.Size = UDim2.new(0, 20, 0, 20)
CurrentPosBox.AnchorPoint = Vector2.new(0.5, 0.5)
CurrentPosBox.BackgroundTransparency = 1
CurrentPosBox.BorderSizePixel = 2
CurrentPosBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
CurrentPosBox.Visible = false
CurrentPosBox.Parent = UI_Container

local PredictionCrosshair = Instance.new("Frame")
PredictionCrosshair.Size = UDim2.new(0, 40, 0, 40)
PredictionCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
PredictionCrosshair.BackgroundTransparency = 1
PredictionCrosshair.Visible = false
PredictionCrosshair.Parent = UI_Container

-- Estilo 1: Punto Clásico
local CrossDot = Instance.new("Frame", PredictionCrosshair)
CrossDot.Size = UDim2.new(0, 8, 0, 8)
CrossDot.AnchorPoint, CrossDot.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", CrossDot).CornerRadius = UDim.new(1, 0)

-- Estilo 2: Cruz
local CrossT2 = Instance.new("Frame", PredictionCrosshair)
CrossT2.Size = UDim2.new(1, 0, 1, 0)
CrossT2.BackgroundTransparency = 1
local cV = Instance.new("Frame", CrossT2)
cV.Size = UDim2.new(0, 2, 0, 20)
cV.AnchorPoint, cV.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
local cH = Instance.new("Frame", CrossT2)
cH.Size = UDim2.new(0, 20, 0, 2)
cH.AnchorPoint, cH.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)

-- Estilo 3: Anillo
local CrossT3 = Instance.new("Frame", PredictionCrosshair)
CrossT3.Size = UDim2.new(0, 16, 0, 16)
CrossT3.AnchorPoint, CrossT3.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
CrossT3.BackgroundTransparency = 1
Instance.new("UICorner", CrossT3).CornerRadius = UDim.new(1, 0)
local c3Stroke = Instance.new("UIStroke", CrossT3)
c3Stroke.Thickness = 2
local c3Dot = Instance.new("Frame", CrossT3)
c3Dot.Size = UDim2.new(0, 4, 0, 4)
c3Dot.AnchorPoint, c3Dot.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", c3Dot).CornerRadius = UDim.new(1, 0)

-- Variable global para recordar qué mira elegiste
_G.OnyxCrosshairType = 1 -- 1=Punto, 2=Cruz, 3=Anillo

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function IsVisible(predictedPos, targetChar)
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not head then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local origin = head.Position
    local result = Workspace:Raycast(origin, predictedPos - origin, rayParams)
    if not result or (result.Instance and result.Instance:IsDescendantOf(targetChar)) then return true end
    return false
end

-- ==========================================
-- 🎥 BUCLE VISUAL Y UI (SINCROMIZACIÓN PERFECTA)
-- ==========================================
-- BindToRenderStep con prioridad Camera + 1 asegura que el UI se dibuje 
-- EXACTAMENTE después de que el juego mueve a los personajes. Cero lag visual.
RunService:BindToRenderStep("NathalyAimbotVisuals", Enum.RenderPriority.Camera.Value + 1, function()
    UpdateSelfState()
    
    if not NathConfig.ShowVisuals then
        CurrentPosBox.Visible = false
        PredictionCrosshair.Visible = false
        return
    end

    local targetChar = GetClosestTarget()
    if targetChar then
        local predictedPos, bestPart = GetPredictedPosition(targetChar)
        if bestPart and predictedPos then
            local currentPos2D, onScreen1 = Camera:WorldToViewportPoint(bestPart.Position)
            local predictedPos2D, onScreen2 = Camera:WorldToViewportPoint(predictedPos)

            if onScreen1 and onScreen2 then
                CurrentPosBox.Position = UDim2.new(0, currentPos2D.X, 0, currentPos2D.Y)
                PredictionCrosshair.Position = UDim2.new(0, predictedPos2D.X, 0, predictedPos2D.Y)
                
                local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head.Position or Camera.CFrame.Position
                
                -- Cambia el color de la mira si el tiro está limpio
                local cColor = IsTrajectoryClear(origin, predictedPos, targetChar) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 0, 0)
                
                CrossDot.BackgroundColor3 = cColor
                cV.BackgroundColor3 = cColor
                cH.BackgroundColor3 = cColor
                c3Stroke.Color = cColor
                c3Dot.BackgroundColor3 = cColor
                
                CrossDot.Visible = (_G.OnyxCrosshairType == 1)
                CrossT2.Visible = (_G.OnyxCrosshairType == 2)
                CrossT3.Visible = (_G.OnyxCrosshairType == 3)

                CurrentPosBox.Visible = true
                PredictionCrosshair.Visible = showCrosshairEnabled -- Ahora respeta el botón

    
            else
                CurrentPosBox.Visible = false; PredictionCrosshair.Visible = false
            end
        else CurrentPosBox.Visible = false; PredictionCrosshair.Visible = false end
    else
        CurrentPosBox.Visible = false; PredictionCrosshair.Visible = false
    end
end)





-- ==========================================
-- 🔥 SISTEMA AUTOSHOOT INSTANTÁNEO (HEARTBEAT ZERO-DELAY)
-- ==========================================
local lastAutoShootTime = 0
RunService.Heartbeat:Connect(function()
    if NathConfig.AutoShoot then
        -- 🔥 Disparamos sin condición de tiempo si es válido, el cooldown real lo maneja DispararEventoDirecto
        local char = LocalPlayer.Character
        local hasGun = char and char:FindFirstChild("Gun")
        
        if hasGun then 
            DispararEventoDirecto(false) 
        end
    end
end)



pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Interceptamos "Shoot" (MM2) en lugar de "ShootStart"
        if not checkcaller() and method == "FireServer" and tostring(self) == "Shoot" then
            
            -- 🔥 EL FIX: Si el AutoShoot está apagado, dejamos que el disparo sea 100% manual y nativo
            if not NathConfig.AutoShoot then
                return oldNamecall(self, ...)
            end

            local targetChar = GetClosestTarget()
            if targetChar then
                local predictedPos = GetSmartShotPosition(targetChar)
                if predictedPos then
                    local tHrp = targetChar:FindFirstChild("HumanoidRootPart")
                    local moveDirection = Vector3.new(0,0,1)
                    
                    if tHrp and tHrp.AssemblyLinearVelocity.Magnitude > 0.5 then
                        moveDirection = tHrp.AssemblyLinearVelocity.Unit
                    elseif tHrp then
                        moveDirection = tHrp.CFrame.LookVector
                    end

                    -- 🔥 FIX: Lo mismo aquí, aseguramos que el tiro manual salga desde la mano
                    local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
                    local originPos = Camera.CFrame.Position
                    if gun and gun:FindFirstChild("Handle") then
                        originPos = gun.Handle.Position
                    end
                    local shootDirection = (predictedPos - originPos).Unit

                    local fakeOriginPos = originPos
                    local fakeTargetPos = predictedPos

                    -- Empaquetamos los argumentos como CFrames para MM2
                    args[1] = CFrame.new(fakeOriginPos, fakeTargetPos)
                    args[2] = CFrame.new(fakeTargetPos)

                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end))
end)





-- ============================================================

-- 👁️ SENSOR DE LECTURA DE RENDIMIENTO Y FÍSICA PARA GÉNESIS

-- ============================================================

local ShotTelemetry = {

    Shots = 0,

    Hits = 0

}



-- Esta función la conectas justo en la parte donde tu Aimbot dispara (FireServer)

function RegistrarDisparoEfectuado()

    ShotTelemetry.Shots = ShotTelemetry.Shots + 1

end



-- Esta función la conectas en tu detector de kills o cuando verifiques que bajó la vida del target

function RegistrarImpactoExitoso()

    ShotTelemetry.Hits = ShotTelemetry.Hits + 1

end












-- ============================================================

-- 🧠 FASE 1 + 5: GAME IDENTITY & CHAT LEARNING

-- ============================================================

local MarketplaceService = game:GetService("MarketplaceService")

local TextChatService = game:GetService("TextChatService")



-- ── FASE 1: Identidad del juego ──

local function GenerateFingerprint()

    local fp = {

        player_count = #Players:GetPlayers(),

        part_count = 0,

        has_terrain = Workspace:FindFirstChildOfClass("Terrain") ~= nil,

        has_vehicles = false,

        tools_keywords = {},

    }

    

    local count = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do

        count = count + 1

        if count > 5000 then break end

        if obj:IsA("BasePart") then fp.part_count = fp.part_count + 1

        elseif obj:IsA("VehicleSeat") then fp.has_vehicles = true end

    end

    

    local tools = {}

    for _, p in ipairs(Players:GetPlayers()) do

        if p.Character then

            for _, i in ipairs(p.Character:GetChildren()) do if i:IsA("Tool") then table.insert(tools, i.Name) end end

        end

        if p:FindFirstChild("Backpack") then

            for _, i in ipairs(p.Backpack:GetChildren()) do if i:IsA("Tool") then table.insert(tools, i.Name) end end

        end

    end

    fp.tools_keywords = tools

    return fp

end



task.spawn(function()

    task.wait(5)

    local gameName = "Unknown"

    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    

    SendToVPS("/game/register", {

        place_id = game.PlaceId,

        game_id = game.GameId,

        name = gameName,

        fingerprint = GenerateFingerprint(),

        category = "unknown"

    })

end)



-- ── FASE 5: Aprendizaje de Chat ──

local ChatBuffer = {}



local function BufferChatMessage(speaker, message)

    if not message or message == "" then return end

    table.insert(ChatBuffer, {

        place_id = game.PlaceId,

        speaker = speaker,

        message = message,

        context = { players = #Players:GetPlayers() },

        user_name = LocalPlayer.Name

    })

end



task.spawn(function()

    while task.wait(5) do

        if #ChatBuffer > 0 then

            local batch = ChatBuffer

            ChatBuffer = {}

            SendToVPS("/chat/batch", { messages = batch })

        end

    end

end)



pcall(function()

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then

        TextChatService.MessageReceived:Connect(function(msg)

            local speaker = "Unknown"

            if msg.TextSource then

                local p = Players:GetPlayerByUserId(msg.TextSource.UserId)

                if p then speaker = p.Name end

            end

            BufferChatMessage(speaker, msg.Text)

        end)

    end

end)



for _, p in ipairs(Players:GetPlayers()) do pcall(function() p.Chatted:Connect(function(msg) BufferChatMessage(p.Name, msg) end) end) end

Players.PlayerAdded:Connect(function(p) pcall(function() p.Chatted:Connect(function(msg) BufferChatMessage(p.Name, msg) end) end) end)







-- ============================================================

-- 🩸 FASE 3: REPORTAR DEATHS A GENESIS (Mood Engine)

-- ============================================================

local function hookCharacter(char)

    local hum = char:WaitForChild("Humanoid", 5)

    if hum then

        hum.Died:Connect(function()

            SendToVPS("/event/death", { place_id = game.PlaceId })

        end)

    end

end



if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end

LocalPlayer.CharacterAdded:Connect(hookCharacter)



-- NOTA: Para las Kills, mete esto donde tu aimbot confirme la kill:

-- SendToVPS("/event/kill", { place_id = game.PlaceId })



-- ==========================================
-- 🌐 EXPORTAR IA AL HUB PRINCIPAL
-- ==========================================
getgenv().NathConfig = NathConfig
getgenv().DispararEventoDirecto = DispararEventoDirecto
    
end)


