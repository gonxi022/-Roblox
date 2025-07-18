-- Advanced Wall Bypass - Atravesar zonas seguras sin ser empujado atrás (Steal a Brainrot) - Android OK

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local button = nil
local enabled = false
local bypassConnection
local lastPos

-- Desactivar colisiones excepto RootPart
local function setCollision(state)
    for _, part in Character:GetDescendants() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not state
        end
    end
end

-- Activar Wall + Bypass zonas seguras
local function toggleBypass()
    enabled = not enabled

    if enabled then
        Humanoid.PlatformStand = true -- desactiva movimiento físico estándar

        bypassConnection = RunService.Stepped:Connect(function()
            pcall(function()
                setCollision(true)
                for _, part in Character:GetDescendants() do
                    if part:IsA("BasePart") and part ~= HumanoidRootPart then
                        part.CanCollide = false
                    end
                end
                -- Forzar posición estable si el servidor intenta empujarte
                if lastPos and (HumanoidRootPart.Position - lastPos).magnitude > 5 then
                    HumanoidRootPart.CFrame = CFrame.new(lastPos)
                end
                lastPos = HumanoidRootPart.Position
            end)
        end)

        button.Text = "❌ Atravesar OFF"
    else
        if bypassConnection then bypassConnection:Disconnect() end
        Humanoid.PlatformStand = false
        setCollision(false)
        button.Text = "🧱 Atravesar ON"
    end
end

-- Crear botón táctil
local function createButton()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
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
