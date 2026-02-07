--[[
    KELZZ-AI v14.0: TORNADO ZONE
    FITUR: MULTI-TARGET FLING, CAMERA LOCK, GHOST MODE
    TARGET: ROBLOX MOBILE (A14 OPTIMIZED)
]]

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- 1. BERSIHKAN GUI LAMA
if CoreGui:FindFirstChild("KelzzTornadoGui") then
    CoreGui:FindFirstChild("KelzzTornadoGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzTornadoGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Huruf K)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Merah Darah
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Text = "K"
OpenBtn.TextSize = 25
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 480)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "KELZZ TORNADO v14"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- LOGIKA BUKA TUTUP
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === VARIABLES ===
local AreaActive = false
local AreaRange = 50
local VisualZone = nil
local CenterPart = nil -- Part dummy untuk kamera
local AreaConnection = nil

local FakeLagActive = false
local SavedCFrame = nil
local BubblePart = nil

-- ====================================================
-- BAGIAN 1: MULTI-TARGET FLING ZONE
-- ====================================================

local AreaLabel = Instance.new("TextLabel")
AreaLabel.Parent = MainFrame
AreaLabel.Text = "--- MULTI-TARGET ZONE ---"
AreaLabel.Size = UDim2.new(1, 0, 0, 20)
AreaLabel.Position = UDim2.new(0, 0, 0.08, 0)
AreaLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
AreaLabel.BackgroundTransparency = 1
AreaLabel.Font = Enum.Font.SourceSansBold

local AreaBtn = Instance.new("TextButton")
AreaBtn.Parent = MainFrame
AreaBtn.Text = "ZONA MAUT: OFF"
AreaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AreaBtn.Position = UDim2.new(0.1, 0, 0.14, 0)
AreaBtn.Size = UDim2.new(0.8, 0, 0, 50)
AreaBtn.TextColor3 = Color3.new(1,1,1)
AreaBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

AreaBtn.MouseButton1Click:Connect(function()
    AreaActive = not AreaActive
    
    if AreaActive then
        AreaBtn.Text = "ZONA MAUT: ON (MULTI)"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        
        -- 1. SETUP CENTER & CAMERA LOCK
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            -- Buat part dummy agar kamera diam di tempat
            if CenterPart then CenterPart:Destroy() end
            CenterPart = Instance.new("Part")
            CenterPart.Name = "KelzzCenter"
            CenterPart.Size = Vector3.new(1,1,1)
            CenterPart.Anchored = true
            CenterPart.CanCollide = false
            CenterPart.Transparency = 1
            CenterPart.CFrame = Plr.Character.HumanoidRootPart.CFrame
            CenterPart.Parent = Workspace
            
            -- Kunci Kamera ke CenterPart
            Workspace.CurrentCamera.CameraSubject = CenterPart
        else
            AreaActive = false
            return
        end

        -- 2. VISUAL ZONE
        if VisualZone then VisualZone:Destroy() end
        VisualZone = Instance.new("Part")
        VisualZone.Name = "KelzzZoneVisual"
        VisualZone.Shape = Enum.PartType.Cylinder
        VisualZone.Size = Vector3.new(0.5, AreaRange * 2, AreaRange * 2)
        VisualZone.CFrame = CenterPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
        VisualZone.Color = Color3.fromRGB(255, 0, 0)
        VisualZone.Material = Enum.Material.ForceField
        VisualZone.Transparency = 0.7
        VisualZone.Anchored = true
        VisualZone.CanCollide = false
        VisualZone.Parent = Workspace
        
        -- Matikan Fake Lag biar smooth
        if FakeLagActive then FakeLagActive = false end

        -- 3. LOOP SERANGAN (TORNADO MODE)
        -- Menggunakan variable index untuk menggilir target
        local TargetIndex = 1
        
        AreaConnection = RunService.Heartbeat:Connect(function()
            local HRP = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            
            -- Cari SEMUA musuh dalam radius
            local Enemies = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local Dist = (CenterPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if Dist <= AreaRange then
                        table.insert(Enemies, p.Character.HumanoidRootPart)
                    end
                end
            end
            
            if #Enemies > 0 then
                -- LOGIKA TORNADO: Pindah target setiap frame
                TargetIndex = TargetIndex + 1
                if TargetIndex > #Enemies then TargetIndex = 1 end
                
                local TargetRoot = Enemies[TargetIndex]
                
                -- Teleport SERANG
                HRP.CFrame = TargetRoot.CFrame
                
                -- Fisika Maut (Rotasi Tinggi)
                HRP.Velocity = Vector3.new(0, 0, 0) 
                HRP.AssemblyAngularVelocity = Vector3.new(0, 25000, 0)
                
                -- Noclip
                for _, part in pairs(Plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            else
                -- TIDAK ADA MUSUH: Balik ke Center (Sembunyi di dalam part dummy)
                HRP.AssemblyAngularVelocity = Vector3.new(0,0,0)
                HRP.Velocity = Vector3.new(0,0,0)
                HRP.CFrame = CenterPart.CFrame
            end
        end)
        
    else
        -- MATIKAN
        AreaBtn.Text = "ZONA MAUT: OFF"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        if AreaConnection then AreaConnection:Disconnect() end
        if VisualZone then VisualZone:Destroy() end
        
        -- Kembalikan Kamera ke Player Asli
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid
        end
        if CenterPart then CenterPart:Destroy() end
        
        -- Reset Fisika
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
            Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- ====================================================
-- BAGIAN 2: GHOST MODE (FAKE LAG)
-- ====================================================

local LagLabel = Instance.new("TextLabel")
LagLabel.Parent = MainFrame
LagLabel.Text = "--- GHOST MODE ---"
LagLabel.Size = UDim2.new(1, 0, 0, 20)
LagLabel.Position = UDim2.new(0, 0, 0.28, 0)
LagLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
LagLabel.BackgroundTransparency = 1
LagLabel.Font = Enum.Font.SourceSansBold

local LagBtn = Instance.new("TextButton")
LagBtn.Parent = MainFrame
LagBtn.Text = "FAKE LAG: OFF"
LagBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LagBtn.Position = UDim2.new(0.1, 0, 0.34, 0)
LagBtn.Size = UDim2.new(0.8, 0, 0, 40)
LagBtn.TextColor3 = Color3.new(1,1,1)
LagBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", LagBtn).CornerRadius = UDim.new(0, 6)

LagBtn.MouseButton1Click:Connect(function()
    if AreaActive then
        LagBtn.Text = "MATIKAN ZONA DULU!"
        wait(1)
        LagBtn.Text = "FAKE LAG: OFF"
        return
    end

    FakeLagActive = not FakeLagActive
    
    if FakeLagActive then
        LagBtn.Text = "FAKE LAG: ON (BLINK)"
        LagBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 170)
        
        task.spawn(function()
            while FakeLagActive do
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                    local HRP = Plr.Character.HumanoidRootPart
                    HRP.Anchored = true
                    task.wait(0.1)
                    HRP.Anchored = false
                    task.wait(0.05)
                else
                    task.wait(1)
                end
            end
            if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                Plr.Character.HumanoidRootPart.Anchored = false
            end
        end)
    else
        LagBtn.Text = "FAKE LAG: OFF"
        LagBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

-- ====================================================
-- BAGIAN 3: SAFE ZONE
-- ====================================================

local SLabel = Instance.new("TextLabel")
SLabel.Parent = MainFrame
SLabel.Text = "--- SAFE ZONE ---"
SLabel.Size = UDim2.new(1, 0, 0, 20)
SLabel.Position = UDim2.new(0, 0, 0.45, 0)
SLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SLabel.BackgroundTransparency = 1
SLabel.Font = Enum.Font.SourceSansBold

local SaveBtn = Instance.new("TextButton")
SaveBtn.Parent = MainFrame
SaveBtn.Text = "SIMPAN LOKASI AMAN"
SaveBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
SaveBtn.Position = UDim2.new(0.1, 0, 0.51, 0)
SaveBtn.Size = UDim2.new(0.8, 0, 0, 40)
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

SaveBtn.MouseButton1Click:Connect(function()
    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        SavedCFrame = Plr.Character.HumanoidRootPart.CFrame
        SaveBtn.Text = "LOKASI TERSIMPAN!"
        wait(1)
        SaveBtn.Text = "SIMPAN LOKASI AMAN"
    end
end)

local TpProtectBtn = Instance.new("TextButton")
TpProtectBtn.Parent = MainFrame
TpProtectBtn.Text = "TP SAVE + PROTECT"
TpProtectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
TpProtectBtn.Position = UDim2.new(0.1, 0, 0.62, 0)
TpProtectBtn.Size = UDim2.new(0.8, 0, 0, 40)
TpProtectBtn.TextColor3 = Color3.new(1,1,1)
TpProtectBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TpProtectBtn).CornerRadius = UDim.new(0, 6)

TpProtectBtn.MouseButton1Click:Connect(function()
    if SavedCFrame and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Plr.Character.HumanoidRootPart
        
        -- Matikan Zona Maut jika aktif
        if AreaActive then
            AreaActive = false
            if AreaConnection then AreaConnection:Disconnect() end
            if VisualZone then VisualZone:Destroy() end
            if CenterPart then CenterPart:Destroy() end
            if Plr.Character:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid
            end
            AreaBtn.Text = "ZONA MAUT: OFF"
            AreaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        if FakeLagActive then FakeLagActive = false; LagBtn.Text = "FAKE LAG: OFF"; end

        HRP.CFrame = SavedCFrame
        
        if BubblePart then BubblePart:Destroy() end
        BubblePart = Instance.new("Part")
        BubblePart.Shape = Enum.PartType.Ball
        BubblePart.Size = Vector3.new(14, 14, 14)
        BubblePart.Color = Color3.fromRGB(0, 170, 255)
        BubblePart.Material = Enum.Material.ForceField
        BubblePart.Transparency = 0.6
        BubblePart.CanCollide = false 
        BubblePart.Anchored = true
        BubblePart.CFrame = HRP.CFrame
        BubblePart.Parent = Workspace
        
        HRP.Anchored = true
        TpProtectBtn.Text = "TERLINDUNGI"
    else
        TpProtectBtn.Text = "BELUM SIMPAN!"
        wait(1)
        TpProtectBtn.Text = "TP SAVE + PROTECT"
    end
end)

local FreeBtn = Instance.new("TextButton")
FreeBtn.Parent = MainFrame
FreeBtn.Text = "LEPAS PROTEKSI"
FreeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
FreeBtn.Position = UDim2.new(0.1, 0, 0.73, 0)
FreeBtn.Size = UDim2.new(0.8, 0, 0, 35)
FreeBtn.TextColor3 = Color3.new(1,1,1)
FreeBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", FreeBtn).CornerRadius = UDim.new(0, 6)

FreeBtn.MouseButton1Click:Connect(function()
    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        Plr.Character.HumanoidRootPart.Anchored = false
        if BubblePart then BubblePart:Destroy() end
        TpProtectBtn.Text = "TP SAVE + PROTECT"
    end
end)

-- TOMBOL TUTUP
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Text = "TUTUP GUI"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Position = UDim2.new(0.1, 0, 0.85, 0)
CloseBtn.Size = UDim2.new(0.8, 0, 0, 30)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- NOTIFIKASI
game.StarterGui:SetCore("SendNotification", {
    Title = "Kelzz-AI v14.0";
    Text = "Multi-Target Zone Active!";
    Duration = 5;
})
