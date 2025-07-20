local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Lista de mundos conocidos (puedes agregar/quitar)
local worlds = {
    {name="City", pos=Vector3.new(104, 20, -101)},
    {name="Desert", pos=Vector3.new(1301, 20, -1739)},
    {name="Magma", pos=Vector3.new(2490, 20, -3480)},
    {name="Electro", pos=Vector3.new(4139, 20, -5617)},
    {name="Legends Highway", pos=Vector3.new(-2572, 20, 3012)},
    {name="Space", pos=Vector3.new(7966, 525, -9930)},
    -- Agrega aquí más mundos si sabes sus posiciones
}

-- AutoFarm Flag
local farming = false

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function tpTo(obj)
    local char = getChar()
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    if HRP and obj and obj:IsA("BasePart") then
        HRP.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
    end
end

local function isFarmable(obj)
    local farmWords = {"Step", "Orb", "Gem", "Diamond", "Crystal", "Reward"}
    for _, word in ipairs(farmWords) do
        if obj.Name:lower():find(word:lower()) then
            return true
        end
    end
    if obj.Name:match("%+%d+ Step") or obj.Name:match("%+%d+ steps") then
        return true
    end
    return false
end

-- AutoFarm loop
spawn(function()
    while true do
        task.wait(0.06)
        if farming then
            local char = getChar()
            local HRP = char:FindFirstChild("HumanoidRootPart")
            if HRP then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and isFarmable(obj) then
                        tpTo(obj)
                        task.wait(0.065)
                    end
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

-- GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "AutoFarmGui"
gui.ResetOnSpawn = false

-- Botón AutoFarm
local farmBtn = Instance.new("TextButton", gui)
farmBtn.Size = UDim2.new(0, 220, 0, 80)
farmBtn.Position = UDim2.new(0, 30, 0, 30)
farmBtn.BackgroundColor3 = Color3.fromRGB(30,130,255)
farmBtn.TextColor3 = Color3.new(1, 1, 1)
farmBtn.Text = "Auto Farm OFF"
farmBtn.TextScaled = true
farmBtn.Font = Enum.Font.SourceSansBold

farmBtn.MouseButton1Click:Connect(function()
    farming = not farming
    farmBtn.Text = "Auto Farm " .. (farming and "ON" or "OFF")
end)

-- Marco del menú (scrolling frame)
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 250, 0, 320)
menuFrame.Position = UDim2.new(0, 30, 0, 130)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BorderSizePixel = 2
menuFrame.Visible = true

local title = Instance.new("TextLabel", menuFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.TextColor3 = Color3.new(1, 1, 0.1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Text = "TP a Mundo"
title.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", menuFrame)
scroll.Size = UDim2.new(1, 0, 1, -45)
scroll.Position = UDim2.new(0, 0, 0, 45)
scroll.CanvasSize = UDim2.new(0,0,0, #worlds*60)
scroll.ScrollBarThickness = 8
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0

for i, world in ipairs(worlds) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -12, 0, 54)
    btn.Position = UDim2.new(0, 6, 0, (i-1)*60)
    btn.BackgroundColor3 = Color3.fromRGB(65,65,120)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = "Ir a: " .. world.name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.BorderSizePixel = 2
    btn.MouseButton1Click:Connect(function()
        local char = getChar()
        local HRP = char and char:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.CFrame = CFrame.new(world.pos + Vector3.new(0,4,0))
        end
    end)
end

print("Auto-farm y TP por menú listos. ¡Disfruta!")