local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local FlySpeed = 50  -- Ajusta la velocidad de vuelo aquí
local isFlying = false

local function fly()
    print("Iniciando vuelo...")
    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    BodyVelocity.Parent = Character

    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    BodyGyro.Parent = Character

    local UserInputService = game:GetService("UserInputService")
    local function onTouchBegan(input, gameProcessed)
        if not gameProcessed then
            print("Toque detectado en la pantalla")
            local touchPos = input.Position
            local screenSize = workspace.CurrentCamera.ViewportSize
            local moveVector = Vector3.new(0, 0, 0)

            if touchPos.X < screenSize.X / 2 then
                moveVector = moveVector - (workspace.CurrentCamera.CoordinateFrame.RightVector * FlySpeed)
            else
                moveVector = moveVector + (workspace.CurrentCamera.CoordinateFrame.RightVector * FlySpeed)
            end

            if touchPos.Y < screenSize.Y / 2 then
                moveVector = moveVector + (workspace.CurrentCamera.CoordinateFrame.LookVector * FlySpeed)
            else
                moveVector = moveVector - (workspace.CurrentCamera.CoordinateFrame.LookVector * FlySpeed)
            end

            BodyVelocity.Velocity = moveVector
            print("Vector de movimiento: ", moveVector)
        end
    end

    UserInputService.TouchBegan:Connect(onTouchBegan)
end

local function stopFly()
    print("Deteniendo vuelo...")
    for _, child in pairs(Character:GetChildren()) do
        if child:IsA("BodyVelocity") or child:IsA("BodyGyro") then
            child:Destroy()
        end
    end
end

local function onJumpRequest(input, gameProcessed)
    if not gameProcessed then
        isFlying = not isFlying
        if isFlying then
            fly()
        else
            stopFly()
        end
    end
end

local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(onJumpRequest)
