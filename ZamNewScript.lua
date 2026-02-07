--[[
    KELZZ-AI v15.0: ULTIMATE WARLORD
    FITUR: SELECT TP, TORNADO ZONE, GHOST LAG, SAFE ZONE
    TARGET: ROBLOX MOBILE (A14 OPTIMIZED)
]]

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- 1. BERSIHKAN GUI LAMA
if CoreGui:FindFirstChild("KelzzFinalGui") then
    CoreGui:FindFirstChild("KelzzFinalGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzFinalGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Huruf K)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Hitam
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Text = "Z"
OpenBtn.TextSize = 25
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0) -- Merah
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", OpenBtn).Thickness = 2

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 500) -- Ukuran pas untuk semua fitur
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "Zam New V2"
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
local TargetPlayer = nil
local AreaActive = false
local AreaRange = 50
local VisualZone = nil
local CenterPart = nil
local AreaConnection = nil
local FakeLagActive = false
local SavedCFrame = nil
local BubblePart = nil

-- ====================================================
-- BAGIAN 1: PLAYER TELEPORT (FITUR YANG DIMINTA)
-- ====================================================

local TpLabel = Instance.new("TextLabel")
TpLabel.Parent = MainFrame
TpLabel.Text = "--- TARGET TELEPORT ---"
TpLabel.Size = UDim2.new(1, 0, 0, 20)
TpLabel.Position = UDim2.new(0, 0, 0.07, 0)
TpLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TpLabel.BackgroundTransparency = 1
TpLabel.Font = Enum.Font.SourceSansBold

local SelectBtn = Instance.new("TextButton")
SelectBtn.Parent = MainFrame
SelectBtn.Text = "PILIH PLAYER [Klik]"
SelectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SelectBtn.Position = UDim2.new(0.1, 0, 0.12, 0)
SelectBtn.Size = UDim2.new(0.8, 0, 0, 35)
SelectBtn.TextColor3 = Color3.new(1,1,1)
SelectBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 6)

-- LIST PLAYER (POPUP)
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = MainFrame
PlayerList.Position = UDim2.new(0.1, 0, 0.20, 0)
PlayerList.Size = UDim2.new(0.8, 0, 0, 150) -- Tinggi list
PlayerList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PlayerList.Visible = false 
PlayerList.ScrollBarThickness = 4
PlayerList.ZIndex = 10 -- Di atas tombol lain

local UIList = Instance.new("UIListLayout")
UIList.Parent = PlayerList
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local function RefreshPlayers()
    for _, v in pairs(PlayerList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Plr then 
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerList
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.ZIndex = 11
            btn.MouseButton1Click:Connect(function()
                TargetPlayer = p
                SelectBtn.Text = "Target: " .. p.Name
                PlayerList.Visible = false 
            end)
        end
    end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end

SelectBtn.MouseButton1Click:Connect(function()
    PlayerList.Visible = not PlayerList.Visible
    if PlayerList.Visible then RefreshPlayers() end
end)

local TpBtn = Instance.new("TextButton")
TpBtn.Parent = MainFrame
TpBtn.Text = "TELEPORT KE TARGET >>"
TpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Hijau
TpBtn.Position = UDim2.new(0.1, 0, 0.21, 0)
TpBtn.Size = UDim2.new(0.8, 0, 0, 35)
TpBtn.TextColor3 = Color3.new(1,1,1)
TpBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 6)

TpBtn.MouseButton1Click:Connect(function()
    -- Matikan fitur Zona/Lag dulu biar aman saat TP
    if AreaActive then 
        -- Copied Logic Off Area
        AreaActive = false
        if AreaConnection then AreaConnection:Disconnect() end
        if VisualZone then VisualZone:Destroy() end
        if CenterPart then CenterPart:Destroy() end
        if Plr.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid end
    end
    if FakeLagActive then FakeLagActive = false end

    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport 3 stud di belakang target
            Plr.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    else
        SelectBtn.Text = "PILIH DULU!"
        wait(1)
        if TargetPlayer then SelectBtn.Text = "Target: " .. TargetPlayer.Name else SelectBtn.Text = "PILIH PLAYER [Klik]" end
    end
end)

-- ====================================================
-- BAGIAN 2: TORNADO ZONE (MULTI-TARGET)
-- ====================================================

local AreaLabel = Instance.new("TextLabel")
AreaLabel.Parent = MainFrame
AreaLabel.Text = "--- TORNADO ZONE ---"
AreaLabel.Size = UDim2.new(1, 0, 0, 20)
AreaLabel.Position = UDim2.new(0, 0, 0.30, 0)
AreaLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
AreaLabel.BackgroundTransparency = 1
AreaLabel.Font = Enum.Font.SourceSansBold

local AreaBtn = Instance.new("TextButton")
AreaBtn.Parent = MainFrame
AreaBtn.Text = "ZONA MAUT: OFF"
AreaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AreaBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
AreaBtn.Size = UDim2.new(0.8, 0, 0, 45)
AreaBtn.TextColor3 = Color3.new(1,1,1)
AreaBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

AreaBtn.MouseButton1Click:Connect(function()
    AreaActive = not AreaActive
    
    if AreaActive then
        AreaBtn.Text = "ZONA MAUT: ON (MULTI)"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            if CenterPart then CenterPart:Destroy() end
            CenterPart = Instance.new("Part")
            CenterPart.Name = "KelzzCenter"
            CenterPart.Size = Vector3.new(1,1,1)
            CenterPart.Anchored = true
            CenterPart.CanCollide = false
            CenterPart.Transparency = 1
            CenterPart.CFrame = Plr.Character.HumanoidRootPart.CFrame
            CenterPart.Parent = Workspace
            Workspace.CurrentCamera.CameraSubject = CenterPart
        else
            AreaActive = false
            return
        end

        if VisualZone then VisualZone:Destroy() end
        VisualZone = Instance.new("Part")
        VisualZone.Shape = Enum.PartType.Cylinder
        VisualZone.Size = Vector3.new(0.5, AreaRange * 2, AreaRange * 2)
        VisualZone.CFrame = CenterPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
        VisualZone.Color = Color3.fromRGB(255, 0, 0)
        VisualZone.Material = Enum.Material.ForceField
        VisualZone.Transparency = 0.7
        VisualZone.Anchored = true
        VisualZone.CanCollide = false
        VisualZone.Parent = Workspace
        
        if FakeLagActive then FakeLagActive = false end

        local TargetIndex = 1
        AreaConnection = RunService.Heartbeat:Connect(function()
            local HRP = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            
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
                TargetIndex = TargetIndex + 1
                if TargetIndex > #Enemies then TargetIndex = 1 end
                local TargetRoot = Enemies[TargetIndex]
                
                HRP.CFrame = TargetRoot.CFrame
                HRP.Velocity = Vector3.new(0, 0, 0) 
                HRP.AssemblyAngularVelocity = Vector3.new(0, 25000, 0)
                
                for _, part in pairs(Plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            else
                HRP.AssemblyAngularVelocity = Vector3.new(0,0,0)
                HRP.Velocity = Vector3.new(0,0,0)
                HRP.CFrame = CenterPart.CFrame
            end
        end)
    else
        AreaBtn.Text = "ZONA MAUT: OFF"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if AreaConnection then AreaConnection:Disconnect() end
        if VisualZone then VisualZone:Destroy() end
        if Plr.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid end
        if CenterPart then CenterPart:Destroy() end
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
            Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- ====================================================
-- BAGIAN 3: GHOST MODE (VISUAL LAG)
-- ====================================================

local LagLabel = Instance.new("TextLabel")
LagLabel.Parent = MainFrame
LagLabel.Text = "--- GHOST MODE ---"
LagLabel.Size = UDim2.new(1, 0, 0, 20)
LagLabel.Position = UDim2.new(0, 0, 0.46, 0)
LagLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
LagLabel.BackgroundTransparency = 1
LagLabel.Font = Enum.Font.SourceSansBold

local LagBtn = Instance.new("TextButton")
LagBtn.Parent = MainFrame
LagBtn.Text = "FAKE LAG: OFF"
LagBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LagBtn.Position = UDim2.new(0.1, 0, 0.51, 0)
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
        LagBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
        
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
-- BAGIAN 4: SAFE ZONE
-- ====================================================

local SLabel = Instance.new("TextLabel")
SLabel.Parent = MainFrame
SLabel.Text = "--- SAFE ZONE ---"
SLabel.Size = UDim2.new(1, 0, 0, 20)
SLabel.Position = UDim2.new(0, 0, 0.61, 0)
SLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SLabel.BackgroundTransparency = 1
SLabel.Font = Enum.Font.SourceSansBold

local SaveBtn = Instance.new("TextButton")
SaveBtn.Parent = MainFrame
SaveBtn.Text = "SIMPAN LOKASI AMAN"
SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 130, 0)
SaveBtn.Position = UDim2.new(0.1, 0, 0.66, 0)
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
TpProtectBtn.Position = UDim2.new(0.1, 0, 0.76, 0)
TpProtectBtn.Size = UDim2.new(0.8, 0, 0, 40)
TpProtectBtn.TextColor3 = Color3.new(1,1,1)
TpProtectBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TpProtectBtn).CornerRadius = UDim.new(0, 6)

TpProtectBtn.MouseButton1Click:Connect(function()
    if SavedCFrame and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Plr.Character.HumanoidRootPart
        
        -- Auto Turn Off Features
        if AreaActive then
            AreaActive = false
            if AreaConnection then AreaConnection:Disconnect() end
            if VisualZone then VisualZone:Destroy() end
            if CenterPart then CenterPart:Destroy() end
            if Plr.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid end
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
FreeBtn.Position = UDim2.new(0.1, 0, 0.86, 0)
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

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Text = "TUTUP GUI"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Position = UDim2.new(0.1, 0, 0.94, 0)
CloseBtn.Size = UDim2.new(0.8, 0, 0, 20)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Kelzz-AI v15.0";
    Text = "All Features Loaded!";
    Duration = 5;
})
