-- 🌆 DA HOOD MOD MENU - Android KRNL
-- Mod Menu básico con Kill All loop
-- Compatible Android KRNL

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local RemoteEvents = ReplicatedStorage:WaitForChild("Remotes")
local MeleeEvent = RemoteEvents:WaitForChild("MeleeEvent")

-- Mod state
local ModState = {
    killAll = false,
    isOpen = false
}

-- Crear icono flotante
local function createFloatingIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HoodIcon"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 50, 0, 50)
    iconFrame.Position = UDim2.new(0.9, 0, 0.1, 0)
    iconFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = screenGui

    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1,0,1,0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "DH"
    iconText.TextColor3 = Color3.fromRGB(255,255,255)
    iconText.TextScaled = true
    iconText.Font = Enum.Font.GothamBold
    iconText.Parent = iconFrame

    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1,0,1,0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Parent = iconFrame

    return { gui = screenGui, frame = iconFrame, button = iconButton }
end

-- Crear mod menu
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HoodModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 150)
    mainFrame.Position = UDim2.new(0.5,-100,0.5,-75)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame

    -- Kill All Toggle
    local killButton = Instance.new("TextButton")
    killButton.Size = UDim2.new(0, 180, 0, 40)
    killButton.Position = UDim2.new(0, 10, 0, 10)
    killButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    killButton.Text = "Kill All: OFF"
    killButton.TextColor3 = Color3.fromRGB(255,255,255)
    killButton.Font = Enum.Font.GothamBold
    killButton.TextSize = 14
    killButton.Parent = mainFrame

    return { gui = screenGui, mainFrame = mainFrame, killButton = killButton }
end

-- Función Kill All Loop
local function startKillAll()
    spawn(function()
        while ModState.killAll do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = player.Character.HumanoidRootPart.Position
                    pcall(function()
                        -- Spoof: atacar sin mover
                        MeleeEvent:FireServer(CFrame.new(targetPos))
                    end)
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- Inicializar menu e icono
local icon = createFloatingIcon()
local menu = createModMenu()

-- Toggle menu
icon.button.MouseButton1Click:Connect(function()
    ModState.isOpen = not ModState.isOpen
    menu.mainFrame.Visible = ModState.isOpen
end)

-- Toggle Kill All
menu.killButton.MouseButton1Click:Connect(function()
    ModState.killAll = not ModState.killAll
    menu.killButton.Text = ModState.killAll and "Kill All: ON" or "Kill All: OFF"
    if ModState.killAll then
        startKillAll()
    end
end)

-- Auto reconectar character al respawnear
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if ModState.killAll then
        startKillAll()
    end
end)

print("🌆 Da Hood Mod Menu Loaded - Android KRNL")