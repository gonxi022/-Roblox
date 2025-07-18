--[[ 
  Fly + Mod Menu para KRNL en Android 
  ---------------------------------------------------
  - Botón UI para activar/desactivar vuelo
  - Toque en pantalla para dirigir el vuelo
  - Toggle adicional con salto
--]]

-- Comprobar entorno exploit (KRNL)
assert(type(syn)=="table" or type(KRNL)=="table" or type(identifyexecutor)=="function", 
       "Este script debe ejecutarse en un exploit como KRNL o Synapse.")

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Referencias
local Player = Players.LocalPlayer
local Gui = Player:WaitForChild("PlayerGui")

-- Variables de vuelo
local FlySpeed = 50
local isFlying = false
local moveVector = Vector3.new()
local BodyVelocity, BodyGyro

-- Crear UI
local ScreenGui = Instance.new("ScreenGui", Gui)
ScreenGui.Name = "FlyModMenu"

local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 0, 0, 40)
Button.Size = UDim2.new(0, 120, 0, 40)
Button.Position = UDim2.new(0, 0, 0, 10)
Button.BackgroundTransparency = 0.3
Button.BackgroundColor3 = Color3.new(0,0,0)
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.Text = "Vuelo: OFF"

-- Funciones de vuelo
local function startFly()
    if isFlying then return end
    isFlying = true
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum  = char:WaitForChild("Humanoid")

    -- Crea BodyVelocity
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    BodyVelocity.Velocity = Vector3.new()
    BodyVelocity.Parent = root

    -- Crea BodyGyro
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    BodyGyro.CFrame = workspace.CurrentCamera.CFrame
    BodyGyro.Parent = root

    hum.PlatformStand = true
    Button.Text = "Vuelo: ON"
end

local function stopFly()
    if not isFlying then return end
    isFlying = false
    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro    then BodyGyro:Destroy()    end
    local char = Player.Character or Player.CharacterAdded:Wait()
    char:FindFirstChildOfClass("Humanoid").PlatformStand = false
    moveVector = Vector3.new()
    Button.Text = "Vuelo: OFF"
end

-- Actualiza cada frame
RunService.Heartbeat:Connect(function()
    if isFlying and BodyVelocity and BodyGyro then
        BodyGyro.CFrame = workspace.CurrentCamera.CFrame
        BodyVelocity.Velocity = moveVector * FlySpeed
    end
end)

-- Toque para dirección
UserInputService.TouchBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local size= workspace.CurrentCamera.ViewportSize
        local cam = workspace.CurrentCamera.CFrame
        local dir = Vector3.new()

        if pos.X < size.X/2 then dir = dir - cam.RightVector else dir = dir + cam.RightVector end
        if pos.Y < size.Y/2 then dir = dir + cam.LookVector else dir = dir - cam.LookVector end

        if dir.Magnitude>0 then moveVector = dir.Unit else moveVector = Vector3.new() end
    end
end)

UserInputService.TouchEnded:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType==Enum.UserInputType.Touch then
        moveVector = Vector3.new()
    end
end)

-- Botón UI toggle
Button.MouseButton1Click:Connect(function()
    if isFlying then stopFly() else startFly() end
end)

-- Toggle con salto
UserInputService.JumpRequest:Connect(function()
    if isFlying then stopFly() else startFly() end
end)
