-- PRISON LIFE ULTIMATE KILL ALL - H2K
-- Melee Event Exploit con TP Spoof
-- Optimizado para Android KRNL - Sin errores visuales

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
    meleeSpam = true,
    attacksPerPlayer = 50,
    isMinimized = false
}

local connections = {}
local meleeEvent = nil

-- Buscar meleeEvent en ReplicatedStorage
local function findMeleeEvent()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("melee") or name:find("punch") or name:find("hit") or name:find("swing") or name:find("attack") then
                meleeEvent = obj
                print("MeleeEvent encontrado: " .. obj.Name)
                return obj
            end
        end
    end
    
    -- Si no encuentra específico, usar primer RemoteEvent
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            meleeEvent = obj
            print("Usando RemoteEvent: " .. obj.Name)
            return obj
        end
    end
    
    return nil
end

-- Función de Kill All con TP Spoof
local function executeUltimateKillAll()
    if not ScriptState.killAllActive then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPosition = character.HumanoidRootPart.CFrame
    
    -- Buscar meleeEvent si no existe
    if not meleeEvent then
        findMeleeEvent()
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local targetHuman = targetPlayer.Character:FindFirstChild("Humanoid")
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHuman and targetRoot and targetHuman.Health > 0 then
                spawn(function()
                    pcall(function()
                        -- TP Spoof al target
                        if ScriptState.tpSpoof then
                            character.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
                            wait(0.05)
                        end
                        
                        -- Spam masivo de meleeEvent
                        for i = 1, ScriptState.attacksPerPlayer do
                            if targetHuman.Health > 0 and meleeEvent then
                                -- Múltiples variaciones del meleeEvent
                                spawn(function()
                                    meleeEvent:FireServer(targetPlayer)
                                    meleeEvent:FireServer(targetPlayer.Character)
                                    meleeEvent:FireServer(targetHuman)
                                    meleeEvent:FireServer(targetRoot)
                                    meleeEvent:FireServer(targetPlayer.Character.Head)
                                end)
                            end
                            wait(0.001) -- Delay mínimo para evitar rate limit
                        end
                        
                        -- TP de vuelta después del ataque
                        if ScriptState.tpSpoof then
                            wait(0.1)
                            character.HumanoidRootPart.CFrame = myPosition
                        end
                    end)
                end)
            end
        end
    end
end

-- Crear GUI estética sin errores visuales
local function createKillAllGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_PrisonKillAll"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    -- Borde brillante
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 50, 50)
    mainStroke.Thickness = 3
    mainStroke.Parent = mainFrame
    
    -- Sombra
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Size = UDim2.new(1, 10, 1, 10)
    shadowFrame.Position = UDim2.new(0, -5, 0, -5)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = 0.7
    shadowFrame.ZIndex = mainFrame.ZIndex - 1
    shadowFrame.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 20)
    shadowCorner.Parent = shadowFrame
    
    -- Header con gradiente
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 25, 25))
    }
    headerGradient.Rotation = 90
    headerGradient.Parent = header
    
    -- Logo H2K destacado
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 70, 0, 35)
    logo.Position = UDim2.new(0, 15, 0, 10)
    logo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 50, 50)
    logo.TextSize = 20
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    logo.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logo
    
    -- Título principal
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -180, 1, 0)
    title.Position = UDim2.new(0, 95, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PRISON KILL ALL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Parent = header
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 17)
    minimizeCorner.Parent = minimizeBtn
    
    -- Contenido principal
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -75)
    content.Position = UDim2.new(0, 10, 0, 65)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Función para crear botones estéticos
    local function createStyledButton(text, pos, size, color, parent)
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
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(255, 255, 255)
        btnStroke.Thickness = 1
        btnStroke.Parent = btn
        
        -- Gradiente del botón
        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(
                math.max(color.R * 255 - 30, 0),
                math.max(color.G * 255 - 30, 0),
                math.max(color.B * 255 - 30, 0)
            ))
        }
        btnGradient.Rotation = 45
        btnGradient.Parent = btn
        
        return btn
    end
    
    -- Botón principal de Kill All
    local killAllBtn = createStyledButton("💀 ULTIMATE KILL ALL 💀", 
        UDim2.new(0, 10, 0, 10), UDim2.new(1, -20, 0, 50), Color3.fromRGB(200, 0, 0), content)
    
    -- Botón de configuración
    local configBtn = createStyledButton("⚙️ CONFIGURACIÓN", 
        UDim2.new(0, 10, 0, 70), UDim2.new(0.48, -5, 0, 35), Color3.fromRGB(100, 100, 150), content)
    
    -- Indicador de estado
    local statusBtn = createStyledButton("📊 ESTADO: OFF", 
        UDim2.new(0.52, 5, 0, 70), UDim2.new(0.48, -5, 0, 35), Color3.fromRGB(150, 100, 0), content)
    
    -- Info panel
    local infoPanel = Instance.new("Frame")
    infoPanel.Size = UDim2.new(1, -20, 0, 60)
    infoPanel.Position = UDim2.new(0, 10, 0, 115)
    infoPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    infoPanel.BorderSizePixel = 0
    infoPanel.Parent = content
    
    local infoPanelCorner = Instance.new("UICorner")
    infoPanelCorner.CornerRadius = UDim.new(0, 10)
    infoPanelCorner.Parent = infoPanel
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 1, -20)
    infoText.Position = UDim2.new(0, 10, 0, 10)
    infoText.BackgroundTransparency = 1
    infoText.Text = "• TP Spoof: Activado\n• Ataques por jugador: 50\n• MeleeEvent: Detectado"
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.TextSize = 12
    infoText.Font = Enum.Font.Gotham
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = infoPanel
    
    -- Créditos H2K
    local creditsFrame = Instance.new("Frame")
    creditsFrame.Size = UDim2.new(1, -20, 0, 25)
    creditsFrame.Position = UDim2.new(0, 10, 1, -35)
    creditsFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    creditsFrame.BorderSizePixel = 0
    creditsFrame.Parent = content
    
    local creditsCorner = Instance.new("UICorner")
    creditsCorner.CornerRadius = UDim.new(0, 12)
    creditsCorner.Parent = creditsFrame
    
    local creditsText = Instance.new("TextLabel")
    creditsText.Size = UDim2.new(1, 0, 1, 0)
    creditsText.BackgroundTransparency = 1
    creditsText.Text = "CREATED BY H2K - ULTIMATE PRISON LIFE EXPLOIT"
    creditsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditsText.TextSize = 11
    creditsText.Font = Enum.Font.GothamBold
    creditsText.TextStrokeTransparency = 0.5
    creditsText.Parent = creditsFrame
    
    -- Ícono minimizado
    local miniIcon = Instance.new("Frame")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(0, 70, 0, 70)
    miniIcon.Position = UDim2.new(0, 30, 0, 100)
    miniIcon.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    miniIcon.BorderSizePixel = 0
    miniIcon.Active = true
    miniIcon.Draggable = true
    miniIcon.Visible = false
    miniIcon.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 35)
    miniCorner.Parent = miniIcon
    
    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = Color3.fromRGB(255, 255, 255)
    miniStroke.Thickness = 2
    miniStroke.Parent = miniIcon
    
    local miniText = Instance.new("TextLabel")
    miniText.Size = UDim2.new(1, 0, 1, 0)
    miniText.BackgroundTransparency = 1
    miniText.Text = "H2K"
    miniText.TextColor3 = Color3.fromRGB(255, 255, 255)
    miniText.TextSize = 16
    miniText.Font = Enum.Font.GothamBold
    miniText.TextStrokeTransparency = 0
    miniText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    miniText.Parent = miniIcon
    
    local miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.new(1, 0, 1, 0)
    miniButton.BackgroundTransparency = 1
    miniButton.Text = ""
    miniButton.Parent = miniIcon
    
    -- Efecto de pulsación en ícono
    spawn(function()
        while miniIcon.Parent do
            TweenService:Create(miniStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
                {Thickness = 4}):Play()
            wait(1)
        end
    end)
    
    -- EVENTOS FUNCIONALES
    
    -- Kill All principal
    killAllBtn.MouseButton1Click:Connect(function()
        ScriptState.killAllActive = not ScriptState.killAllActive
        
        if ScriptState.killAllActive then
            killAllBtn.Text = "🔥 KILLING ALL PLAYERS 🔥"
            killAllBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            statusBtn.Text = "📊 ESTADO: ACTIVE"
            statusBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            
            -- Ejecutar kill all
            spawn(function()
                while ScriptState.killAllActive do
                    executeUltimateKillAll()
                    wait(0.5) -- Pausa entre ciclos
                end
            end)
        else
            killAllBtn.Text = "💀 ULTIMATE KILL ALL 💀"
            killAllBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            statusBtn.Text = "📊 ESTADO: OFF"
            statusBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
        end
    end)
    
    -- Configuración
    configBtn.MouseButton1Click:Connect(function()
        ScriptState.attacksPerPlayer = ScriptState.attacksPerPlayer == 50 and 100 or 50
        infoText.Text = "• TP Spoof: Activado\n• Ataques por jugador: " .. ScriptState.attacksPerPlayer .. "\n• MeleeEvent: Detectado"
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

-- Buscar meleeEvent al iniciar
findMeleeEvent()

-- Crear GUI
local gui = createKillAllGUI()

-- Hotkey para toggle (Android compatible)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.P then -- P para Prison
        ScriptState.killAllActive = not ScriptState.killAllActive
        print("Kill All " .. (ScriptState.killAllActive and "ACTIVADO" or "DESACTIVADO"))
    end
end)

-- Doble tap para minimizar (Android)
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

-- Limpiar al cerrar
game:BindToClose(function()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
end)

print("H2K PRISON LIFE ULTIMATE KILL ALL CARGADO!")
print("• Uso: Presiona el botón principal para activar/desactivar")
print("• Hotkey: P para toggle rápido")
print("• TP Spoof habilitado para máxima efectividad")
print("• 50-100 ataques por jugador usando MeleeEvent")