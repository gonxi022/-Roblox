-- Variables y referencias
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Esperar humanoide
local Humanoid = Character:WaitForChild("Humanoid")

local isNoclip = false

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0.8, 0)  -- Abajo centrado
ToggleButton.Text = "Atravesar Paredes OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = ScreenGui

-- Funciones noclip y clip
local function noclip()
    local char = Player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function clip()
    local char = Player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- Toggle noclip con botón táctil
ToggleButton.TouchTap:Connect(function()
    if isNoclip then
        isNoclip = false
        clip()
        ToggleButton.Text = "Atravesar Paredes OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    else
        isNoclip = true
        noclip()
        ToggleButton.Text = "Atravesar Paredes ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(35,180,70)
    end
end)

-- Asegurar noclip si respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    if isNoclip then
        noclip()
    end
end)
