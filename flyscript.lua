local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local FlySpeed = 50
local isFlying = false

local BodyVelocity
local BodyGyro

local moveVector = Vector3.new(0, 0, 0)

-- Crear UI Mod Menu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyModMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 120, 0, 40)
Button.Position = UDim2.new(0, 20, 0, 20)
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Text = "Vuelo: OFF"
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20
Button.Parent = ScreenGui
Button.AutoButtonColor = true
Button.BorderSizePixel = 2
Button.BorderColor3 = Color3.new(1, 1, 1)

-- Funciones para activar/desactivar vuelo
local function startFly()
    if isFlying then return end
    isFlying = true

    print("Iniciando vuelo...")

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = HumanoidRootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    BodyGyro.CFrame = workspace.CurrentCamera.CFrame
    BodyGyro.Parent = HumanoidRootPart

    Humanoid.PlatformStand = true
    Button.Text = "Vuelo: ON"
end

local function stopFly()
    if not isFlying then return end
    isFlying = false

    print("Deteniendo vuelo...")

    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end

    Humanoid.PlatformStand = false
    moveVector = Vector3.new(0, 0, 0)
    Button.Text = "Vuelo: OFF"
end

-- Actualizar vuelo cada frame
local function updateFly()
    if isFlying and BodyVelocity and BodyGyro then
        BodyGyro.CFrame = workspace.CurrentCamera.CFrame
        BodyVelocity.Velocity = moveVector * FlySpeed
    end
end

-- Detectar toque para movimiento
local function onTouchBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local touchPos = input.Position
        local screenSize = workspace.CurrentCamera.ViewportSize
        local cam = workspace.CurrentCamera

        local dir = Vector3.new(0, 0, 0)

        if touchPos.X < screenSize.X / 2 then
            dir = dir - cam.CFrame.RightVector
        else
            dir = dir + cam.CFrame.RightVector
        end

        if touchPos.Y < screenSize.Y / 2 then
            dir = dir + cam.CFrame.LookVector
        else
            dir = dir - cam.CFrame.LookVector
        end

        if dir.Magnitude > 0 then
            moveVector = dir.Unit
        else
            moveVector = Vector3.new(0, 0, 0)
        end
    end
end

local function onTouchEnded(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        moveVector = Vector3.new(0, 0, 0)
    end
end

-- Toggle vuelo al presionar el botón UI
Button.MouseButton1Click:Connect(function()
    if isFlying then
        stopFly()
    else
        startFly()
    end
end)

-- También toggle con salto (opcional, coméntalo si no quieres)
UserInputService.JumpRequest:Connect(function()
    if isFlying then
        stopFly()
    else
        startFly()
    end
end)

UserInputService.TouchBegan:Connect(onTouchBegan)
UserInputService.TouchEnded:Connect(onTouchEnded)
RunService.Heartbeat:Connect(updateFly)
