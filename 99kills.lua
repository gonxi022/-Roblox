--[[  
    H2K Mod Menu - 99 Noches en el Bosque
    Opciones: Kill Aura + God Mode
    Estilo: Minimizable / Limpio / Android Ready
--]]

-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Variables
local killAuraActivo = false
local godModeActivo = false
local menuVisible = true

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "H2K_Menu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "⚡ H2K Forest Menu ⚡"
Title.TextColor3 = Color3.fromRGB(0,255,100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Botón minimizar
local MinButton = Instance.new("TextButton", MainFrame)
MinButton.Size = UDim2.new(0,30,0,30)
MinButton.Position = UDim2.new(1,-35,0,0)
MinButton.Text = "-"
MinButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
MinButton.TextColor3 = Color3.fromRGB(255,255,255)
local UICornerBtn = Instance.new("UICorner", MinButton)
UICornerBtn.CornerRadius = UDim.new(0,8)

MinButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    for _,v in pairs(MainFrame:GetChildren()) do
        if v:IsA("TextButton") and v ~= MinButton then
            v.Visible = menuVisible
        end
    end
end)

-- Funciones
function activarKillAura()
    killAuraActivo = not killAuraActivo
    while killAuraActivo do
        task.wait(0.2)
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                -- Daño directo (ajusta según remote del juego)
                player.Character:FindFirstChild("Humanoid"):TakeDamage(10)
            end
        end
    end
end

function activarGodMode()
    godModeActivo = not godModeActivo
    if godModeActivo and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChild("Humanoid").Health = math.huge
        LocalPlayer.Character:FindFirstChild("Humanoid").HealthChanged:Connect(function()
            if godModeActivo then
                LocalPlayer.Character:FindFirstChild("Humanoid").Health = math.huge
            end
        end)
    end
end

-- Botón Kill Aura
local BtnKill = Instance.new("TextButton", MainFrame)
BtnKill.Size = UDim2.new(1,-20,0,40)
BtnKill.Position = UDim2.new(0,10,0,40)
BtnKill.Text = "⚔ Kill Aura"
BtnKill.BackgroundColor3 = Color3.fromRGB(50,50,50)
BtnKill.TextColor3 = Color3.fromRGB(255,255,255)
BtnKill.Font = Enum.Font.Gotham
BtnKill.TextSize = 14
local corner1 = Instance.new("UICorner", BtnKill)
corner1.CornerRadius = UDim.new(0,10)
BtnKill.MouseButton1Click:Connect(activarKillAura)

-- Botón God Mode
local BtnGod = Instance.new("TextButton", MainFrame)
BtnGod.Size = UDim2.new(1,-20,0,40)
BtnGod.Position = UDim2.new(0,10,0,90)
BtnGod.Text = "💎 God Mode"
BtnGod.BackgroundColor3 = Color3.fromRGB(50,50,50)
BtnGod.TextColor3 = Color3.fromRGB(255,255,255)
BtnGod.Font = Enum.Font.Gotham
BtnGod.TextSize = 14
local corner2 = Instance.new("UICorner", BtnGod)
corner2.CornerRadius = UDim.new(0,10)
BtnGod.MouseButton1Click:Connect(activarGodMode)