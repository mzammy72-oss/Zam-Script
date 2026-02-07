--[[
    KELZZ-AI v16.0: SCROLLABLE EDITION
    FITUR: SCROLL MENU, CLICK TP, TORNADO, SELECT TP
    TARGET: ROBLOX MOBILE (A14 OPTIMIZED)
]]

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- 1. BERSIHKAN GUI LAMA
if CoreGui:FindFirstChild("KelzzScrollGui") then
    CoreGui:FindFirstChild("KelzzScrollGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzScrollGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Huruf K)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 255) -- Biru Tech
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Text = "Z"
OpenBtn.TextSize = 25
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.new(1,1,1)
Instance.new("UIStroke", OpenBtn).Thickness = 2

-- MAIN FRAME (FIXED SIZE)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
-- UKURAN KECIL AGAR TIDAK PENUH LAYAR (350px Tinggi)
MainFrame.Size = UDim2.new(0, 240, 0, 350) 
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 80, 255)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "Zam New V3"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
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
local SavedCFrame = nil
local BubblePart = nil

-- === SCROLLING CONTAINER (WADAH UTAMA) ===
local ScrollBox = Instance.new("ScrollingFrame")
ScrollBox.Parent = MainFrame
ScrollBox.Position = UDim2.new(0, 5, 0, 35)
ScrollBox.Size = UDim2.new(1, -10, 1, -40) -- Mengisi sisa frame
ScrollBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ScrollBox.BackgroundTransparency = 1
ScrollBox.ScrollBarThickness = 4
ScrollBox.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Auto Scroll Length
ScrollBox.CanvasSize = UDim2.new(0,0,0,0)

-- LAYOUT OTOMATIS (List)
local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollBox
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8) -- Jarak antar tombol

local UIPad = Instance.new("UIPadding")
UIPad.Parent = ScrollBox
UIPad.PaddingLeft = UDim.new(0, 5)
UIPad.PaddingRight = UDim.new(0, 5)
UIPad.PaddingTop = UDim.new(0, 5)
UIPad.PaddingBottom = UDim.new(0, 5)

-- ====================================================
-- FUNGSI PEMBUAT UI (HELPER)
-- ====================================================
local function CreateLabel(Text)
    local L = Instance.new("TextLabel")
    L.Parent = ScrollBox
    L.Text = Text
    L.Size = UDim2.new(1, 0, 0, 20)
    L.BackgroundTransparency = 1
    L.TextColor3 = Color3.fromRGB(150, 150, 150)
    L.Font = Enum.Font.SourceSansBold
end

local function CreateBtn(Text, Color, Callback)
    local B = Instance.new("TextButton")
    B.Parent = ScrollBox
    B.Text = Text
    B.Size = UDim2.new(1, 0, 0, 40)
    B.BackgroundColor3 = Color
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(Callback)
    return B
end

-- ====================================================
-- BAGIAN 1: TARGET TELEPORT
-- ====================================================

CreateLabel("--- TARGET TELEPORT ---")

local SelectBtn = CreateBtn("PILIH PLAYER [Klik]", Color3.fromRGB(60, 60, 60), function() end)

-- DROPDOWN LIST (Di Luar ScrollBox agar mengambang di atas)
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Parent = MainFrame
PlayerListFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
PlayerListFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PlayerListFrame.Visible = false
PlayerListFrame.ZIndex = 20
PlayerListFrame.BorderColor3 = Color3.fromRGB(0, 80, 255)
PlayerListFrame.BorderSizePixel = 2
local PList = Instance.new("UIListLayout")
PList.Parent = PlayerListFrame
PList.SortOrder = Enum.SortOrder.LayoutOrder

SelectBtn.MouseButton1Click:Connect(function()
    PlayerListFrame.Visible = not PlayerListFrame.Visible
    if PlayerListFrame.Visible then
        -- Refresh List
        for _, v in pairs(PlayerListFrame:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Plr then
                local b = Instance.new("TextButton")
                b.Parent = PlayerListFrame
                b.Size = UDim2.new(1, 0, 0, 35)
                b.Text = p.Name
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                b.TextColor3 = Color3.new(1,1,1)
                b.ZIndex = 21
                b.MouseButton1Click:Connect(function()
                    TargetPlayer = p
                    SelectBtn.Text = "Target: " .. p.Name
                    PlayerListFrame.Visible = false
                end)
            end
        end
        PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PList.AbsoluteContentSize.Y)
    end
end)

CreateBtn("TELEPORT KE TARGET >>", Color3.fromRGB(0, 150, 0), function()
    -- Matikan fitur Zona dulu biar aman
    if AreaActive then 
        AreaActive = false
        if AreaConnection then AreaConnection:Disconnect() end
        if VisualZone then VisualZone:Destroy() end
        if CenterPart then CenterPart:Destroy() end
        if Plr.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid end
    end

    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    else
        SelectBtn.Text = "PILIH TARGET DULU!"
        wait(1)
        if TargetPlayer then SelectBtn.Text = "Target: " .. TargetPlayer.Name else SelectBtn.Text = "PILIH PLAYER [Klik]" end
    end
end)

-- ====================================================
-- BAGIAN 2: CLICK TELEPORT TOOL (FITUR BARU)
-- ====================================================

CreateLabel("--- CLICK TP ---")

local GetTpBtn = CreateBtn("AMBIL CLICK TP TOOL", Color3.fromRGB(150, 0, 150), function() end)

GetTpBtn.MouseButton1Click:Connect(function()
    if Plr.Backpack:FindFirstChild("Click TP") or (Plr.Character and Plr.Character:FindFirstChild("Click TP")) then
        GetTpBtn.Text = "SUDAH PUNYA!"
        wait(1)
        GetTpBtn.Text = "AMBIL CLICK TP TOOL"
        return
    end

    local Tool = Instance.new("Tool")
    Tool.Name = "Click TP"
    Tool.RequiresHandle = false -- Tidak perlu handle fisik
    Tool.Parent = Plr.Backpack
    
    -- Icon (Opsional)
    Tool.TextureId = "rbxassetid://494306309" -- Gambar Mouse
    
    Tool.Activated:Connect(function()
        local Char = Plr.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            local Pos = Mouse.Hit.p -- Posisi Tap/Klik
            -- Teleport + 3 studs ke atas biar gak nyangkut tanah
            Char.HumanoidRootPart.CFrame = CFrame.new(Pos + Vector3.new(0, 4, 0))
        end
    end)

    GetTpBtn.Text = "ALAT DITERIMA!"
    wait(1)
    GetTpBtn.Text = "AMBIL CLICK TP TOOL"
end)

-- ====================================================
-- BAGIAN 3: TORNADO ZONE
-- ====================================================

CreateLabel("--- TORNADO ZONE ---")

local AreaBtn = CreateBtn("ZONA MAUT: OFF", Color3.fromRGB(60, 60, 60), function() end)

AreaBtn.MouseButton1Click:Connect(function()
    AreaActive = not AreaActive
    
    if AreaActive then
        AreaBtn.Text = "ZONA MAUT: ON"
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
            AreaActive = false return
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
        
        local TargetIndex = 1
        AreaConnection = RunService.Heartbeat:Connect(function()
            local HRP = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            
            local Enemies = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local Dist = (CenterPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if Dist <= AreaRange then table.insert(Enemies, p.Character.HumanoidRootPart) end
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
-- BAGIAN 4: SAFE ZONE
-- ====================================================

CreateLabel("--- SAFE ZONE ---")

local SaveBtn = CreateBtn("SIMPAN LOKASI", Color3.fromRGB(200, 130, 0), function()
    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        SavedCFrame = Plr.Character.HumanoidRootPart.CFrame
    end
end)

local ProtectBtn = CreateBtn("TP SAVE + PROTECT", Color3.fromRGB(0, 100, 255), function()
    if SavedCFrame and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Plr.Character.HumanoidRootPart
        
        -- Auto Turn Off Zona
        if AreaActive then
            AreaActive = false
            if AreaConnection then AreaConnection:Disconnect() end
            if VisualZone then VisualZone:Destroy() end
            if CenterPart then CenterPart:Destroy() end
            if Plr.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid end
            AreaBtn.Text = "ZONA MAUT: OFF"
            AreaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end

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
    end
end)

CreateBtn("LEPAS PROTEKSI", Color3.fromRGB(0, 200, 100), function()
    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        Plr.Character.HumanoidRootPart.Anchored = false
        if BubblePart then BubblePart:Destroy() end
    end
end)

CreateBtn("TUTUP GUI", Color3.fromRGB(200, 0, 0), function()
    ScreenGui:Destroy()
end)

-- NOTIFIKASI
game.StarterGui:SetCore("SendNotification", {
    Title = "Kelzz-AI v16.0";
    Text = "Scrollable UI Active!";
    Duration = 5;
})
