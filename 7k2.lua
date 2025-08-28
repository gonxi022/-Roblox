-- H2K 99 Nights in the Forest Mod Menu Android KRNL
-- By H2K, Profesional y Seguro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Variables toggles
local AuraActivo = true
local AutoCofres = true
local SpeedActivo = true
local InfiniteJump = true

local RangoAtaque = 80
local RangoCofres = 10
local SpeedValue = 70

-- Helper para identificar NPCs hostiles
local function EsHostil(npc)
    if not npc:FindFirstChild("Humanoid") then return false end
    if npc:FindFirstChild("IsEnemy") and npc.IsEnemy.Value then return true end
    local enemigos = {"Lobo","Alfa","Oso","Zorro","Ciervo","Cultista","Juggernaut"}
    for _, n in pairs(enemigos) do
        if string.find(npc.Name, n) then return true end
    end
    return false
end

-- Kill Aura seguro
RunService.Heartbeat:Connect(function()
    if AuraActivo then
        for _, npc in pairs(Workspace:GetChildren()) do
            if EsHostil(npc) and npc:FindFirstChild("HumanoidRootPart") then
                local distancia = (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distancia <= RangoAtaque then
                    if ReplicatedStorage:FindFirstChild("MeleeEvent") then
                        ReplicatedStorage.MeleeEvent:FireServer(npc.Humanoid)
                    elseif ReplicatedStorage:FindFirstChild("DamageEvent") then
                        ReplicatedStorage.DamageEvent:FireServer(npc.Humanoid,50)
                    end
                end
            end
        end
    end
end)

-- Instante abrir cofres
RunService.Heartbeat:Connect(function()
    if AutoCofres then
        for _, chest in pairs(Workspace.Chests:GetChildren()) do
            if chest:FindFirstChild("ProximityPrompt") then
                local distancia = (chest.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distancia <= RangoCofres then
                    chest.ProximityPrompt:InputHoldBegin()
                    wait(0.05)
                    chest.ProximityPrompt:InputHoldEnd()
                end
            end
        end
    end
end)

-- Speed x70
RunService.Heartbeat:Connect(function()
    if SpeedActivo then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hrp and humanoid then
            humanoid.WalkSpeed = SpeedValue
        end
    end
end)

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- TP to Camp
function TeleportToCamp()
    local camp = Workspace:FindFirstChild("Camp")
    if camp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = camp.CFrame + Vector3.new(0,5,0)
    end
end

-- Menú flotante minimizable
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,220,0,180)
Frame.Position = UDim2.new(0,20,0.4,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0

-- Toggle button helper
local function crearBoton(texto, variable)
    local boton = Instance.new("TextButton", Frame)
    boton.Size = UDim2.new(1,-10,0,30)
    boton.Position = UDim2.new(0,5,#Frame:GetChildren()*35)
    boton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    boton.TextColor3 = Color3.fromRGB(255,255,255)
    boton.Text = texto.." : "..tostring(_G[variable])
    boton.MouseButton1Click:Connect(function()
        _G[variable] = not _G[variable]
        boton.Text = texto.." : "..tostring(_G[variable])
    end)
end

-- Crear botones
_G.AuraActivo = AuraActivo
_G.AutoCofres = AutoCofres
_G.SpeedActivo = SpeedActivo
_G.InfiniteJump = InfiniteJump

crearBoton("Kill Aura", "AuraActivo")
crearBoton("Auto Cofres", "AutoCofres")
crearBoton("Speed x70", "SpeedActivo")
crearBoton("Infinite Jump", "InfiniteJump")

-- Botón TP Camp
local tpButton = Instance.new("TextButton", Frame)
tpButton.Size = UDim2.new(1,-10,0,30)
tpButton.Position = UDim2.new(0,5,#Frame:GetChildren()*35)
tpButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
tpButton.TextColor3 = Color3.fromRGB(255,255,255)
tpButton.Text = "TP to Camp"
tpButton.MouseButton1Click:Connect(TeleportToCamp)

-- Minimizar menú
local minimizar = Instance.new("TextButton", Frame)
minimizar.Size = UDim2.new(1,0,0,20)
minimizar.Position = UDim2.new(0,0,0,0)
minimizar.BackgroundColor3 = Color3.fromRGB(15,15,15)
minimizar.TextColor3 = Color3.fromRGB(255,255,255)
minimizar.Text = "≡"
minimizar.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)