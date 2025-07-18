local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local FlySpeed = 50  -- Ajusta la velocidad de vuelo aquí

local function fly()
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
        end
    end

    UserInputService.TouchBegan:Connect(onTouchBegan)
end

-- Crear un menú simple
local ScreenGui = Instance.new("ScreenGui")
local TextButton = Instance.new("TextButton")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.Position = UDim2.new(0.5, -100, 0.5, -25)
TextButton.Text = "Volar"
TextButton.Parent = ScreenGui

TextButton.MouseButton1Click:Connect(function()
    fly()
end)
