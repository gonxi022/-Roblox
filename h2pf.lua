-- H2K PRISON LIFE ULTIMATE KILL ALL - VERSIÓN CORREGIDA
-- Sin fallas técnicas, optimizado para Android KRNL
-- BY H2K

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Limpiar GUIs anteriores
for _, gui in pairs(PlayerGui:GetChildren()) do
    if gui.Name:find("H2K") or gui.Name:find("Kill") then
        gui:Destroy()
    end
end

-- Variables del script
local ScriptState = {
    killAllActive = false,
    tpSpoof = true,
    attacksPerPlayer = 25,
    isMinimized = false,
    killedPlayers = {}, -- Tracking de jugadores ya eliminados
    lastKillTime = {}   -- Cooldown por jugador
}

local connections = {}
local meleeEvent = nil

-- Buscar meleeEvent optimizado
local function findMeleeEvent()
    local possibleEvents = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("melee") or name:find("punch") or name:find("hit") or 
               name:find("swing") or name:find("attack") or name:find("damage") then
                table.insert(possibleEvents, obj)
            end
        end
    end
    
    -- Usar el primer evento encontrado
    if #possibleEvents > 0 then
        meleeEvent = possibleEvents[1]
        print("MeleeEvent encontrado: " .. meleeEvent.Name)
        return meleeEvent
    end
    
    -- Fallback: usar cualquier RemoteEvent
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            meleeEvent = obj
            print("Usando RemoteEvent fallback: " .. obj.Name)
            return obj
        end
    end
    
    return nil
end

-- Verificar si el jugador puede ser atacado
local function canAttackPlayer(targetPlayer)
    if not targetPlayer.Character then return false end
    
    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    if humanoid.Health <= 0 then return false end
    
    -- Verificar si está en cooldown
    local currentTime = tick()
    if ScriptState.lastKillTime[targetPlayer.UserId] then
        if currentTime - ScriptState.lastKillTime[targetPlayer.UserId] < 3 then
            return false -- Cooldown de 3 segundos
        end
    end
    
    -- Verificar si no está en spawn protection
    if humanoid:GetAttribute("SpawnProtected") then return false end
    
    return true
end

-- Kill All función corregida
local function executeSmartKillAll()
    if not ScriptState.killAllActive then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPosition = character.HumanoidRootPart.CFrame
    
    -- Buscar meleeEvent si no existe
    if not meleeEvent then
        findMeleeEvent()
        if not meleeEvent then
            print("Error: No se encontró MeleeEvent")
            return
        end
    end
    
    local playersToAttack = {}
    
    -- Filtrar jugadores atacables
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and canAttackPlayer(targetPlayer) then
            table.insert(playersToAttack, targetPlayer)
        end
    end
    
    -- Atacar solo jugadores válidos
    for _, targetPlayer in pairs(playersToAttack) do
        spawn(function()
            pcall(function()
                local targetHuman = targetPlayer.Character:FindFirstChild("Humanoid")
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if not targetHuman or not targetRoot or targetHuman.Health <= 0 then
                    return
                end
                
                -- TP Spoof al target
                if ScriptState.tpSpoof then
                    character.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -2)
                    wait(0.1)
                end
                
                -- Ataque optimizado
                local initialHealth = targetHuman.Health
                
                for i = 1, ScriptState.attacksPerPlayer do
                    if targetHuman.Health <= 0 then
                        break -- Dejar de atacar si ya murió
                    end
                    
                    -- Múltiples variaciones del ataque
                    meleeEvent:FireServer(targetPlayer)
                    meleeEvent:FireServer(targetPlayer.Character)
                    meleeEvent:FireServer(targetHuman)
                    meleeEvent:FireServer(targetRoot)
                    
                    wait(0.05) -- Delay para evitar rate limiting
                end
                
                -- Marcar tiempo de último ataque
                ScriptState.lastKillTime[targetPlayer.UserId] = tick()
                
                -- TP de vuelta
                if ScriptState.tpSpoof then
                    wait(0.1)
                    character.HumanoidRootPart.CFrame = myPosition
                end
            end)
        end)
    end
end

-- Crear GUI mejorada sin errores visuales
local function createEnhancedGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_PrisonKillAll_Enhanced"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Frame principal con mejor diseño
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Esquinas suavizadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- Borde estético
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(220, 20, 60)
    mainStroke.Thickness = 3
    mainStroke.Parent = mainFrame
    
    -- Gradiente de fondo elegante
    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 40, 50))
    }
    backgroundGradient.Rotation = 45
    backgroundGradient.Parent = mainFrame
    
    -- Header premium
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    -- Gradiente del header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 15, 45))
    }
    headerGradient.Rotation = 90
    headerGradient.Parent = header
    
    -- Logo H2K mejorado y más estético
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 85, 0, 40)
    logoFrame.Position = UDim2.new(0, 15, 0, 10)
    logoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 10)
    logoCorner.Parent = logoFrame
    
    local logoStroke = Instance.new("UIStroke")
    logoStroke.Color = Color3.fromRGB(255, 215, 0)
    logoStroke.Thickness = 2
    logoStroke.Parent = logoFrame
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(220, 20, 60)
    logo.TextSize = 22
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(255, 215, 0)
    logo.Parent = logoFrame
    
    -- Título con mejor tipografía
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -220, 1, 0)
    title.Position = UDim2.new(0, 110, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PRISON KILL ALL ULTIMATE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.2
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Parent = header
    
    -- Botón minimizar estético
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
    minimizeBtn.Position = UDim2.new(1, -50, 0, 10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 20)
    minimizeCorner.Parent = minimizeBtn
    
    local minimizeStroke = Instance.new("UIStroke")
    minimizeStroke.Color = Color3.fromRGB(255, 255, 255)
    minimizeStroke.Thickness = 2
    minimizeStroke.Parent = minimizeBtn
    
    -- Contenido principal
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -30, 1, -90)
    content.Position = UDim2.new(0, 15, 0, 75)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Función para crear botones premium
    local function createPremiumButton(text, pos, size, color, parent)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(255, 255, 255)
        btnStroke.Thickness = 2
        btnStroke.Transparency = 0.3
        btnStroke.Parent = btn
        
        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(
                math.max(color.R * 255 - 40, 0),
                math.max(color.G * 255 - 40, 0),
                math.max(color.B * 255 - 40, 0)
            ))
        }
        btnGradient.Rotation = 45
        btnGradient.Parent = btn
        
        return btn
    end
    
    -- Botón principal mejorado
    local killAllBtn = createPremiumButton("ULTIMATE KILL ALL", 
        UDim2.new(0, 10, 0, 10), UDim2.new(1, -20, 0, 55), Color3.fromRGB(180, 0, 0), content)
    
    -- Botones de configuración
    local configBtn = createPremiumButton("CONFIGURAR", 
        UDim2.new(0, 10, 0, 75), UDim2.new(0.48, -5, 0, 40), Color3.fromRGB(70, 130, 180), content)
    
    local statusBtn = createPremiumButton("ESTADO: INACTIVO", 
        UDim2.new(0.52, 5, 0, 75), UDim2.new(0.48, -5, 0, 40), Color3.fromRGB(128, 128, 128), content)
    
    -- Panel de información mejorado
    local infoPanel = Instance.new("Frame")
    infoPanel.Size = UDim2.new(1, -20, 0, 70)
    infoPanel.Position = UDim2.new(0, 10, 0, 125)
    infoPanel.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
    infoPanel.BorderSizePixel = 0
    infoPanel.Parent = content
    
    local infoPanelCorner = Instance.new("UICorner")
    infoPanelCorner.CornerRadius = UDim.new(0, 12)
    infoPanelCorner.Parent = infoPanel
    
    local infoPanelStroke = Instance.new("UIStroke")
    infoPanelStroke.Color = Color3.fromRGB(100, 100, 120)
    infoPanelStroke.Thickness = 1
    infoPanelStroke.Parent = infoPanel
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 1, -20)
    infoText.Position = UDim2.new(0, 10, 0, 10)
    infoText.BackgroundTransparency = 1
    infoText.Text = "TP Spoof: Activado\nAtaques por jugador: 25\nMeleeEvent: Detectado\nCooldown inteligente: 3s"
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.TextSize = 12
    infoText.Font = Enum.Font.Gotham
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = infoPanel
    
    -- Créditos H2K estilizados
    local creditsFrame = Instance.new("Frame")
    creditsFrame.Size = UDim2.new(1, -20, 0, 30)
    creditsFrame.Position = UDim2.new(0, 10, 1, -40)
    creditsFrame.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    creditsFrame.BorderSizePixel = 0
    creditsFrame.Parent = content
    
    local creditsCorner = Instance.new("UICorner")
    creditsCorner.CornerRadius = UDim.new(0, 15)
    creditsCorner.Parent = creditsFrame
    
    local creditsGradient = Instance.new("UIGradient")
    creditsGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
    }
    creditsGradient.Rotation = 45
    creditsGradient.Parent = creditsFrame
    
    local creditsText = Instance.new("TextLabel")
    creditsText.Size = UDim2.new(1, 0, 1, 0)
    creditsText.BackgroundTransparency = 1
    creditsText.Text = "CREATED BY H2K - ULTIMATE PRISON EXPLOIT"
    creditsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditsText.TextSize = 12
    creditsText.Font = Enum.Font.GothamBold
    creditsText.TextStrokeTransparency = 0.3
    creditsText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    creditsText.Parent = creditsFrame
    
    -- Ícono minimizado premium
    local miniIcon = Instance.new("Frame")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(0, 80, 0, 80)
    miniIcon.Position = UDim2.new(0, 30, 0, 100)
    miniIcon.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    miniIcon.BorderSizePixel = 0
    miniIcon.Active = true
    miniIcon.Draggable = true
    miniIcon.Visible = false
    miniIcon.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 40)
    miniCorner.Parent = miniIcon
    
    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = Color3.fromRGB(255, 215, 0)
    miniStroke.Thickness = 3
    miniStroke.Parent = miniIcon
    
    local miniGradient = Instance.new("UIGradient")
    miniGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 15, 45))
    }
    miniGradient.Rotation = 45
    miniGradient.Parent = miniIcon
    
    local miniText = Instance.new("TextLabel")
    miniText.Size = UDim2.new(1, 0, 1, 0)
    miniText.BackgroundTransparency = 1
    miniText.Text = "H2K"
    miniText.TextColor3 = Color3.fromRGB(255, 255, 255)
    miniText.TextSize = 18
    miniText.Font = Enum.Font.GothamBold
    miniText.TextStrokeTransparency = 0
    miniText.TextStrokeColor3 = Color3.fromRGB(255, 215, 0)
    miniText.Parent = miniIcon
    
    local miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.new(1, 0, 1, 0)
    miniButton.BackgroundTransparency = 1
    miniButton.Text = ""
    miniButton.Parent = miniIcon
    
    -- Efecto de brillo en el ícono
    spawn(function()
        while miniIcon.Parent do
            TweenService:Create(miniStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
                {Thickness = 5, Color = Color3.fromRGB(255, 255, 255)}):Play()
            wait(2)
        end
    end)
    
    -- EVENTOS CORREGIDOS
    
    -- Kill All con lógica mejorada
    killAllBtn.MouseButton1Click:Connect(function()
        ScriptState.killAllActive = not ScriptState.killAllActive
        
        if ScriptState.killAllActive then
            killAllBtn.Text = "ELIMINANDO JUGADORES"
            killAllBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            statusBtn.Text = "ESTADO: ACTIVO"
            statusBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            
            -- Ejecutar kill all inteligente
            connections.killLoop = RunService.Heartbeat:Connect(function()
                wait(0.8) -- Cooldown entre ciclos
                executeSmartKillAll()
            end)
        else
            killAllBtn.Text = "ULTIMATE KILL ALL"
            killAllBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            statusBtn.Text = "ESTADO: INACTIVO"
            statusBtn.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
            
            if connections.killLoop then
                connections.killLoop:Disconnect()
                connections.killLoop = nil
            end
        end
    end)
    
    -- Configuración mejorada
    configBtn.MouseButton1Click:Connect(function()
        ScriptState.attacksPerPlayer = ScriptState.attacksPerPlayer == 25 and 50 or 25
        infoText.Text = "TP Spoof: Activado\nAtaques por jugador: " .. ScriptState.attacksPerPlayer .. "\nMeleeEvent: Detectado\nCooldown inteligente: 3s"
    end)
    
    -- Minimizar/Maximizar
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
        ScriptState.isMinimized = true
    end)
    
    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
        ScriptState.isMinimized = false
    end)
    
    return screenGui
end

-- Limpiar datos de jugadores que salen
Players.PlayerRemoving:Connect(function(player)
    ScriptState.killedPlayers[player.UserId] = nil
    ScriptState.lastKillTime[player.UserId] = nil
end)

-- Inicializar
findMeleeEvent()
local gui = createEnhancedGUI()

-- Hotkeys Android
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        ScriptState.killAllActive = not ScriptState.killAllActive
        print("Kill All " .. (ScriptState.killAllActive and "ACTIVADO" or "DESACTIVADO"))
    end
end)

-- Doble tap Android
local lastTapTime = 0
UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
    if not processedByUI then
        local currentTime = tick()
        if currentTime - lastTapTime < 0.5 then
            if gui and gui.Parent then
                if ScriptState.isMinimized then
                    gui.MainFrame.Visible = true
                    gui.MiniIcon.Visible = false
                    ScriptState.isMinimized = false
                else
                    gui.MainFrame.Visible = false
                    gui.MiniIcon.Visible = true
                    ScriptState.isMinimized = true
                end
            end
        end
        lastTapTime = currentTime
    end
end)

print("H2K PRISON LIFE KILL ALL ENHANCED CARGADO!")
print("Correcciones aplicadas:")
print("- Detección inteligente de jugadores vulnerables")
print("- Cooldown de 3 segundos por jugador")
print("- Verificación de muerte antes de atacar")
print("- Reducción de spam innecesario")
print("- GUI mejorada sin errores visuales")