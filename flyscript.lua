local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local button = nil
local enabled = false
local bypassConnection
local lastPos = HumanoidRootPart.Position

-- Desactivar colisiones excepto RootPart
local function setCollision(state)
    for _, part in Character:GetDescendants() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not state
        end
    end
end

local function forcePosition(newPos)
    -- Lerp para suavizar la posición y evitar detección brusca
    local currentCFrame = HumanoidRootPart.CFrame
    local targetCFrame = CFrame.new(newPos)
    HumanoidRootPart.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
end

local function toggleBypass()
    enabled = not enabled

    if enabled then
        Humanoid.PlatformStand = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics) -- Mantiene control local
        
        bypassConnection = RunService.Stepped:Connect(function()
            pcall(function()
                setCollision(true)
                -- Desactivar colisiones en todas las partes excepto rootpart
                for _, part in Character:GetDescendants() do
                    if part:IsA("BasePart") and part ~= HumanoidRootPart then
                        part.CanCollide = false
                    end
                end

                local currentPos = HumanoidRootPart.Position
                local distanceMoved = (currentPos - lastPos).Magnitude

                if distanceMoved > 3 then
                    -- Detectamos que el servidor te empujó o reposicionó
                    -- Forzamos la posición suavemente para evitar salto brusco
                    forcePosition(lastPos)
                else
                    -- Seguimos guardando posición estable
                    lastPos = currentPos
                end
            end)
        end)

        button.Text = "❌ Atravesar OFF"
    else
        if bypassConnection then bypassConnection:Disconnect() end
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        setCollision(false)
        button.Text = "🧱 Atravesar ON"
    end
end

-- Crear botón táctil
local function createButton()
    local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SafeZoneBypassUI")
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    gui.Name = "SafeZoneBypassUI"
    gui.ResetOnSpawn = false

    button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 50)
    button.Position = UDim2.new(0.05, 0, 0.8, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = "🧱 Atravesar ON"
    button.TextScaled = true
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.2
    button.Parent = gui

    button.MouseButton1Click:Connect(toggleBypass)
end

-- Soporte para respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    wait(1)
    createButton()
end)

-- Iniciar
createButton()
