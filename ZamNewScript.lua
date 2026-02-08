--[[
    Zam New Script
    FITUR: TITAN ZONE (200 STUDS), SELECT TP, FLY
    TARGET: ROBLOX MOBILE (A14 OPTIMIZED)
]]

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- 1. BERSIHKAN GUI LAMA
if CoreGui:FindFirstChild("KelzzTitanGui") then
    CoreGui:FindFirstChild("KelzzTitanGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzTitanGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Kecil di Kiri)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0) -- Merah Marun
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Text = "Z"
OpenBtn.TextSize = 22
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", OpenBtn).Thickness = 2

-- MAIN FRAME (SCROLLABLE & COMPACT)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
MainFrame.Position = UDim2.new(0.2, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 320) -- Ukuran Pas
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 50, 50)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "TITAN v28"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- LOGIKA BUKA TUTUP
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === SCROLLING CONTAINER ===
local ScrollBox = Instance.new("ScrollingFrame")
ScrollBox.Parent = MainFrame
ScrollBox.Position = UDim2.new(0, 5, 0, 35)
ScrollBox.Size = UDim2.new(1, -10, 1, -40)
ScrollBox.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
ScrollBox.BackgroundTransparency = 1
ScrollBox.ScrollBarThickness = 3
ScrollBox.AutomaticCanvasSize = Enum.AutomaticSize.Y 
ScrollBox.CanvasSize = UDim2.new(0,0,0,0)

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollBox
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6) 

local UIPad = Instance.new("UIPadding")
UIPad.Parent = ScrollBox
UIPad.PaddingLeft = UDim.new(0, 5)
UIPad.PaddingRight = UDim.new(0, 5)
UIPad.PaddingTop = UDim.new(0, 5)
UIPad.PaddingBottom = UDim.new(0, 5)

-- === VARIABLES ===
local TargetPlayer = nil
local AreaActive = false
local AreaRange = 200 -- 200 STUDS (SANGAT LUAS)
local VisualZone = nil
local CenterPart = nil
local AreaConnection = nil

local Flying = false
local FlySpeed = 50
local FlyBodyVel = nil
local FlyConnection = nil

-- HELPER UI
local function CreateLabel(Text)
    local L = Instance.new("TextLabel")
    L.Parent = ScrollBox
    L.Text = Text
    L.Size = UDim2.new(1, 0, 0, 20)
    L.BackgroundTransparency = 1
    L.TextColor3 = Color3.fromRGB(150, 150, 150)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 12
end

local function CreateBtn(Text, Color, Callback)
    local B = Instance.new("TextButton")
    B.Parent = ScrollBox
    B.Text = Text
    B.Size = UDim2.new(1, 0, 0, 35)
    B.BackgroundColor3 = Color
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
    B.MouseButton1Click:Connect(Callback)
    return B
end

local function CreateSlider(Text, Min, Max, Default, Callback)
    local Container = Instance.new("Frame")
    Container.Parent = ScrollBox
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel")
    Label.Parent = Container
    Label.Text = Text .. ": " .. Default
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    local SliderBg = Instance.new("Frame")
    SliderBg.Parent = Container
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBg.Position = UDim2.new(0, 0, 0.5, 0)
    SliderBg.Size = UDim2.new(1, 0, 0, 10)
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBg
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    local Trigger = Instance.new("TextButton")
    Trigger.Parent = SliderBg
    Trigger.BackgroundTransparency = 1
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.Text = ""
    local Dragging = false
    Trigger.MouseButton1Down:Connect(function() Dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local MousePos = UserInputService:GetMouseLocation().X
            local SliderPos = SliderBg.AbsolutePosition.X
            local SliderSize = SliderBg.AbsoluteSize.X
            local RelPos = math.clamp((MousePos - SliderPos) / SliderSize, 0, 1)
            SliderFill.Size = UDim2.new(RelPos, 0, 1, 0)
            local Val = math.floor(Min + (RelPos * (Max - Min)))
            Label.Text = Text .. ": " .. Val
            Callback(Val)
        end
    end)
end

-- ====================================================
-- FITUR 1: TITAN ZONE (200 STUDS) - PENGGANTI STEALTH
-- ====================================================
CreateLabel("--- ZONA MAUT (200) ---")
local AreaBtn = CreateBtn("TITAN ZONE: OFF", Color3.fromRGB(50, 50, 50), function() end)

AreaBtn.MouseButton1Click:Connect(function()
    AreaActive = not AreaActive
    if AreaActive then
        AreaBtn.Text = "TITAN ZONE: ON (ACTIVE)"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Merah Maut
        
        -- 1. Matikan Fly jika aktif (Biar tidak bentrok)
        if Flying then 
             Flying = false; FlyBtn.Text = "FLY: OFF"; FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
             if FlyConnection then FlyConnection:Disconnect() end
             if FlyBodyVel then FlyBodyVel:Destroy() end
             if Plr.Character:FindFirstChild("Humanoid") then Plr.Character.Humanoid.PlatformStand = false end
        end

        -- 2. SETUP CENTER (Markas)
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
            
            -- Kunci Kamera ke Markas (Agar visual stabil)
            Workspace.CurrentCamera.CameraSubject = CenterPart 
        else 
            AreaActive = false 
            return 
        end

        -- 3. VISUAL ZONA (Lingkaran Merah Besar)
        if VisualZone then VisualZone:Destroy() end
        VisualZone = Instance.new("Part")
        VisualZone.Shape = Enum.PartType.Cylinder
        VisualZone.Size = Vector3.new(0.5, AreaRange * 2, AreaRange * 2)
        VisualZone.CFrame = CenterPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
        VisualZone.Color = Color3.fromRGB(255, 0, 0)
        VisualZone.Material = Enum.Material.ForceField
        VisualZone.Transparency = 0.8 -- Sangat transparan agar tidak mengganggu
        VisualZone.Anchored = true
        VisualZone.CanCollide = false
        VisualZone.Parent = Workspace
        
        -- 4. LOOP SERANGAN MULTI-TARGET
        local TargetIndex = 1
        AreaConnection = RunService.Heartbeat:Connect(function()
            local HRP = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            
            -- Cari SEMUA musuh dalam radius
            local Enemies = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local Dist = (CenterPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if Dist <= AreaRange then table.insert(Enemies, p.Character.HumanoidRootPart) end
                end
            end
            
            if #Enemies > 0 then
                -- Ganti target setiap frame (Sangat Cepat)
                TargetIndex = TargetIndex + 1
                if TargetIndex > #Enemies then TargetIndex = 1 end
                local TargetRoot = Enemies[TargetIndex]
                
                -- Teleport SERANG
                HRP.CFrame = TargetRoot.CFrame
                
                -- Fisika Fling
                HRP.Velocity = Vector3.new(0, 0, 0) 
                HRP.AssemblyAngularVelocity = Vector3.new(0, 30000, 0) -- Rotasi Ekstrem
                
                -- Noclip (Tembus Tembok)
                for _, part in pairs(Plr.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
            else
                -- Tidak ada musuh? Diam di tengah
                HRP.AssemblyAngularVelocity = Vector3.new(0,0,0)
                HRP.Velocity = Vector3.new(0,0,0)
                HRP.CFrame = CenterPart.CFrame
            end
        end)
    else
        -- MATIKAN FITUR
        AreaBtn.Text = "TITAN ZONE: OFF"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        if AreaConnection then AreaConnection:Disconnect() end
        if VisualZone then VisualZone:Destroy() end
        if CenterPart then CenterPart:Destroy() end
        
        -- Balikin Kamera ke Karakter
        if Plr.Character:FindFirstChild("Humanoid") then 
            Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid 
        end
        
        -- Reset Fisika
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
             Plr.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
             Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- ====================================================
-- FITUR 2: TELEPORT TARGET
-- ====================================================
CreateLabel("--- TP SELECTED ---")
local SelectBtn = CreateBtn("PILIH PLAYER [Klik]", Color3.fromRGB(40, 40, 40), function() end)

local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Parent = MainFrame
PlayerListFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
PlayerListFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
PlayerListFrame.Visible = false
PlayerListFrame.ZIndex = 20
PlayerListFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
PlayerListFrame.BorderSizePixel = 1
local PList = Instance.new("UIListLayout")
PList.Parent = PlayerListFrame
PList.SortOrder = Enum.SortOrder.LayoutOrder

SelectBtn.MouseButton1Click:Connect(function()
    PlayerListFrame.Visible = not PlayerListFrame.Visible
    if PlayerListFrame.Visible then
        for _, v in pairs(PlayerListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Plr then
                local b = Instance.new("TextButton")
                b.Parent = PlayerListFrame
                b.Size = UDim2.new(1, 0, 0, 30)
                b.Text = p.Name
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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

CreateBtn("TELEPORT KE TARGET >>", Color3.fromRGB(0, 100, 200), function()
    if AreaActive then 
        AreaActive=false; AreaBtn.Text="TITAN ZONE: OFF"; AreaBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
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
-- FITUR 3: FLY SYSTEM
-- ====================================================
CreateLabel("--- FLY CONTROL ---")
CreateSlider("Fly Speed", 10, 300, 50, function(val) FlySpeed = val end)
local FlyBtn = CreateBtn("FLY: OFF", Color3.fromRGB(50, 50, 50), function() end)

FlyBtn.MouseButton1Click:Connect(function()
    Flying = not Flying
    if Flying then
        FlyBtn.Text = "FLY: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        if AreaActive then 
             AreaActive=false; AreaBtn.Text="TITAN ZONE: OFF"; AreaBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
             if AreaConnection then AreaConnection:Disconnect() end
             if VisualZone then VisualZone:Destroy() end
             if CenterPart then CenterPart:Destroy() end
             if Plr.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = Plr.Character.Humanoid end
        end

        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = Plr.Character.HumanoidRootPart
            local Hum = Plr.Character:FindFirstChild("Humanoid")
            if FlyBodyVel then FlyBodyVel:Destroy() end
            FlyBodyVel = Instance.new("BodyVelocity")
            FlyBodyVel.Name = "KelzzFly"
            FlyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyVel.Velocity = Vector3.new(0,0,0)
            FlyBodyVel.Parent = HRP
            if Hum then Hum.PlatformStand = true end
            FlyConnection = RunService.RenderStepped:Connect(function()
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") and Plr.Character:FindFirstChild("Humanoid") then
                    local HRP = Plr.Character.HumanoidRootPart
                    local Cam = Workspace.CurrentCamera
                    local MoveDir = Plr.Character.Humanoid.MoveDirection
                    if MoveDir.Magnitude > 0 then FlyBodyVel.Velocity = Cam.CFrame.LookVector * FlySpeed
                    else FlyBodyVel.Velocity = Vector3.new(0,0,0) end
                    for _, p in pairs(Plr.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
                end
            end)
        end
    else
        FlyBtn.Text = "FLY: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if FlyConnection then FlyConnection:Disconnect() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then Plr.Character.Humanoid.PlatformStand = false end
    end
end)

CreateBtn("TUTUP MENU", Color3.fromRGB(150, 0, 0), function()
    ScreenGui:Destroy()
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Zam New Script";
    Text = "Made By Gemini Ai";
    Duration = 5;
})
