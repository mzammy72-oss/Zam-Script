--[[
    KELZZ-AI v12.0: GHOST LAG EDITION
    FITUR: FAKE LAG (VISUAL STUTTER), AUTO FLING, SAFE ZONE
    TARGET: ROBLOX MOBILE (A14 OPTIMIZED)
]]

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 1. BERSIHKAN GUI LAMA
if CoreGui:FindFirstChild("KelzzLagGui") then
    CoreGui:FindFirstChild("KelzzLagGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzLagGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Huruf K)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Magenta
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
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 480) -- Diperpanjang
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 0, 255)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "KELZZ GHOST v12"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 100, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- LOGIKA BUKA TUTUP
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === VARIABLES ===
local TargetPlayer = nil
local IsFlinging = false
local FlingConnection = nil
local SavedCFrame = nil
local BubblePart = nil
-- Variable Fake Lag
local FakeLagActive = false

-- ====================================================
-- BAGIAN 1: FAKE LAG (FITUR BARU)
-- ====================================================

local LagLabel = Instance.new("TextLabel")
LagLabel.Parent = MainFrame
LagLabel.Text = "--- GHOST MODE ---"
LagLabel.Size = UDim2.new(1, 0, 0, 20)
LagLabel.Position = UDim2.new(0, 0, 0.08, 0)
LagLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
LagLabel.BackgroundTransparency = 1
LagLabel.Font = Enum.Font.SourceSansBold

local LagBtn = Instance.new("TextButton")
LagBtn.Parent = MainFrame
LagBtn.Text = "FAKE LAG: OFF"
LagBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LagBtn.Position = UDim2.new(0.1, 0, 0.14, 0)
LagBtn.Size = UDim2.new(0.8, 0, 0, 40)
LagBtn.TextColor3 = Color3.new(1,1,1)
LagBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", LagBtn).CornerRadius = UDim.new(0, 6)

LagBtn.MouseButton1Click:Connect(function()
    FakeLagActive = not FakeLagActive
    
    if FakeLagActive then
        LagBtn.Text = "FAKE LAG: ON (BLINK)"
        LagBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 170) -- Ungu
        
        -- LOOP LAG (Gunakan coroutine agar tidak freeze GUI)
        task.spawn(function()
            while FakeLagActive do
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                    local HRP = Plr.Character.HumanoidRootPart
                    
                    -- FASE 1: FREEZE (Simulasi Lag)
                    -- Kita kunci sebentar agar server mengira kita diam
                    HRP.Anchored = true
                    task.wait(0.1) -- 100ms lag (Cukup untuk bikin patah-patah)
                    
                    -- FASE 2: RELEASE (Teleport Visual)
                    -- Kita lepas agar posisi kita update mendadak di server
                    HRP.Anchored = false
                    task.wait(0.05) -- Waktu gerak singkat
                    
                    -- NOTE: Di layar Tuan akan terasa sedikit "stutter" (getar)
                    -- Itu normal karena kita memanipulasi fisika real-time.
                else
                    task.wait(1) -- Tunggu respawn jika mati
                end
            end
            
            -- Cleanup saat OFF
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
-- BAGIAN 2: AUTO FLING (TARGET SYSTEM)
-- ====================================================

local PLabel = Instance.new("TextLabel")
PLabel.Parent = MainFrame
PLabel.Text = "--- TARGET SYSTEM ---"
PLabel.Size = UDim2.new(1, 0, 0, 20)
PLabel.Position = UDim2.new(0, 0, 0.25, 0)
PLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
PLabel.BackgroundTransparency = 1
PLabel.Font = Enum.Font.SourceSansBold

local SelectBtn = Instance.new("TextButton")
SelectBtn.Parent = MainFrame
SelectBtn.Text = "PILIH PLAYER [Klik]"
SelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SelectBtn.Position = UDim2.new(0.1, 0, 0.31, 0)
SelectBtn.Size = UDim2.new(0.8, 0, 0, 35)
SelectBtn.TextColor3 = Color3.new(1,1,1)
SelectBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 6)

-- LIST PLAYER
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = MainFrame
PlayerList.Position = UDim2.new(0.1, 0, 0.40, 0)
PlayerList.Size = UDim2.new(0.8, 0, 0, 100)
PlayerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerList.Visible = false 
PlayerList.ScrollBarThickness = 4
PlayerList.ZIndex = 10

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

local FlingBtn = Instance.new("TextButton")
FlingBtn.Parent = MainFrame
FlingBtn.Text = "MULAI AUTO FLING"
FlingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0) 
FlingBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
FlingBtn.Size = UDim2.new(0.8, 0, 0, 45)
FlingBtn.TextColor3 = Color3.new(1,1,1)
FlingBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", FlingBtn).CornerRadius = UDim.new(0, 6)

FlingBtn.MouseButton1Click:Connect(function()
    if not TargetPlayer then
        SelectBtn.Text = "PILIH TARGET DULU!"
        wait(1)
        SelectBtn.Text = "PILIH PLAYER [Klik]"
        return
    end

    IsFlinging = not IsFlinging

    if IsFlinging then
        FlingBtn.Text = "STOP FLING (ON)"
        FlingBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) 
        
        -- MATIKAN FAKE LAG JIKA FLING AKTIF (Biar gak bentrok)
        if FakeLagActive then
            FakeLagActive = false
            LagBtn.Text = "FAKE LAG: OFF (AUTO)"
            LagBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        
        FlingConnection = RunService.Heartbeat:Connect(function()
            local MyChar = Plr.Character
            local TargChar = TargetPlayer.Character
            if MyChar and TargChar and MyChar:FindFirstChild("HumanoidRootPart") and TargChar:FindFirstChild("HumanoidRootPart") then
                local MyRoot = MyChar.HumanoidRootPart
                local TargRoot = TargChar.HumanoidRootPart
                
                MyRoot.CFrame = TargRoot.CFrame
                MyRoot.Velocity = Vector3.new(0, 0, 0)
                MyRoot.AssemblyAngularVelocity = Vector3.new(0, 20000, 0) 
                
                for _, part in pairs(MyChar:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            else
                IsFlinging = false
                FlingBtn.Text = "TARGET HILANG"
                if FlingConnection then FlingConnection:Disconnect() end
                wait(1)
                FlingBtn.Text = "MULAI AUTO FLING"
                FlingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            end
        end)
    else
        FlingBtn.Text = "MULAI AUTO FLING"
        FlingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        if FlingConnection then FlingConnection:Disconnect() end
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
            Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- ====================================================
-- BAGIAN 3: SAVE & PROTECT
-- ====================================================

local SLabel = Instance.new("TextLabel")
SLabel.Parent = MainFrame
SLabel.Text = "--- SAFE ZONE ---"
SLabel.Size = UDim2.new(1, 0, 0, 20)
SLabel.Position = UDim2.new(0, 0, 0.55, 0)
SLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SLabel.BackgroundTransparency = 1
SLabel.Font = Enum.Font.SourceSansBold

local SaveBtn = Instance.new("TextButton")
SaveBtn.Parent = MainFrame
SaveBtn.Text = "SIMPAN LOKASI AMAN"
SaveBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
SaveBtn.Position = UDim2.new(0.1, 0, 0.61, 0)
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
TpProtectBtn.Position = UDim2.new(0.1, 0, 0.72, 0)
TpProtectBtn.Size = UDim2.new(0.8, 0, 0, 40)
TpProtectBtn.TextColor3 = Color3.new(1,1,1)
TpProtectBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TpProtectBtn).CornerRadius = UDim.new(0, 6)

TpProtectBtn.MouseButton1Click:Connect(function()
    if SavedCFrame and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Plr.Character.HumanoidRootPart
        
        -- Matikan fitur lain biar aman
        if IsFlinging then IsFlinging = false; if FlingConnection then FlingConnection:Disconnect() end; FlingBtn.Text = "MULAI AUTO FLING" end
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
        BubblePart.Parent = workspace
        
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
FreeBtn.Position = UDim2.new(0.1, 0, 0.83, 0)
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
CloseBtn.Position = UDim2.new(0.1, 0, 0.92, 0)
CloseBtn.Size = UDim2.new(0.8, 0, 0, 25)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- NOTIFIKASI
game.StarterGui:SetCore("SendNotification", {
    Title = "Kelzz-AI v12.0";
    Text = "Ghost Lag Added!";
    Duration = 5;
})
