--[[
    KELZZ-AI v17.0: SKY WARLORD
    FITUR: MOBILE FLY + SLIDER, CLICK TP, TORNADO, SELECT TP
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
if CoreGui:FindFirstChild("KelzzSkyGui") then
    CoreGui:FindFirstChild("KelzzSkyGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzSkyGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Huruf K)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255) -- Cyan Langit
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
MainFrame.Size = UDim2.new(0, 250, 0, 380) 
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 200, 255)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "Zam New V3"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
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

-- FLY VARIABLES
local Flying = false
local FlySpeed = 50
local FlyBodyVel = nil
local FlyConnection = nil

-- === SCROLLING CONTAINER ===
local ScrollBox = Instance.new("ScrollingFrame")
ScrollBox.Parent = MainFrame
ScrollBox.Position = UDim2.new(0, 5, 0, 35)
ScrollBox.Size = UDim2.new(1, -10, 1, -40)
ScrollBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ScrollBox.BackgroundTransparency = 1
ScrollBox.ScrollBarThickness = 4
ScrollBox.AutomaticCanvasSize = Enum.AutomaticSize.Y 
ScrollBox.CanvasSize = UDim2.new(0,0,0,0)

-- LAYOUT OTOMATIS
local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollBox
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8) 

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

-- FUNGSI SLIDER (BARU)
local function CreateSlider(Text, Min, Max, Default, Callback)
    local Container = Instance.new("Frame")
    Container.Parent = ScrollBox
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Container
    Label.Text = Text .. ": " .. Default
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.SourceSansBold
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Parent = Container
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBg.Position = UDim2.new(0, 0, 0.5, 0)
    SliderBg.Size = UDim2.new(1, 0, 0, 15)
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBg
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Hijau
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
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
-- BAGIAN 1: FLY SYSTEM (FITUR BARU)
-- ====================================================

CreateLabel("--- FLY CONTROL ---")

-- Slider Kecepatan
CreateSlider("Fly Speed", 10, 300, 50, function(val)
    FlySpeed = val
end)

local FlyBtn = CreateBtn("FLY: OFF", Color3.fromRGB(60, 60, 60), function() end)

FlyBtn.MouseButton1Click:Connect(function()
    Flying = not Flying
    
    if Flying then
        FlyBtn.Text = "FLY: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        
        -- Setup BodyVelocity
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = Plr.Character.HumanoidRootPart
            local Hum = Plr.Character:FindFirstChild("Humanoid")
            
            if FlyBodyVel then FlyBodyVel:Destroy() end
            FlyBodyVel = Instance.new("BodyVelocity")
            FlyBodyVel.Name = "KelzzFly"
            FlyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyVel.Velocity = Vector3.new(0,0,0)
            FlyBodyVel.Parent = HRP
            
            -- Set PlatformStand (Biar animasi jalan tidak aneh)
            if Hum then Hum.PlatformStand = true end
            
            -- Loop Terbang
            FlyConnection = RunService.RenderStepped:Connect(function()
                if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") and Plr.Character:FindFirstChild("Humanoid") then
                    local HRP = Plr.Character.HumanoidRootPart
                    local Cam = Workspace.CurrentCamera
                    local MoveDir = Plr.Character.Humanoid.MoveDirection
                    
                    if MoveDir.Magnitude > 0 then
                        -- Terbang ke arah kamera melihat
                        FlyBodyVel.Velocity = Cam.CFrame.LookVector * FlySpeed
                    else
                        -- Hover (Diam)
                        FlyBodyVel.Velocity = Vector3.new(0,0,0)
                    end
                    
                    -- Noclip saat terbang
                    for _, p in pairs(Plr.Character:GetChildren()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        FlyBtn.Text = "FLY: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        if FlyConnection then FlyConnection:Disconnect() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Plr.Character.Humanoid.PlatformStand = false -- Balik normal
        end
    end
end)

-- ====================================================
-- BAGIAN 2: TARGET TELEPORT (LAMA)
-- ====================================================

CreateLabel("--- TARGET TELEPORT ---")

local SelectBtn = CreateBtn("PILIH PLAYER [Klik]", Color3.fromRGB(60, 60, 60), function() end)

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
    -- Matikan Fly saat TP
    if Flying then 
        FlyBtn.Text = "FLY: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Flying = false
        if FlyConnection then FlyConnection:Disconnect() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        if Plr.Character:FindFirstChild("Humanoid") then Plr.Character.Humanoid.PlatformStand = false end
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
-- BAGIAN 3: CLICK TELEPORT
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
    Tool.RequiresHandle = false
    Tool.Parent = Plr.Backpack
    Tool.TextureId = "rbxassetid://494306309"
    Tool.Activated:Connect(function()
        local Char = Plr.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            local Pos = Mouse.Hit.p
            Char.HumanoidRootPart.CFrame = CFrame.new(Pos + Vector3.new(0, 4, 0))
        end
    end)
    GetTpBtn.Text = "ALAT DITERIMA!"
    wait(1)
    GetTpBtn.Text = "AMBIL CLICK TP TOOL"
end)

-- ====================================================
-- BAGIAN 4: TORNADO ZONE (LAMA)
-- ====================================================

CreateLabel("--- TORNADO ZONE ---")
local AreaBtn = CreateBtn("ZONA MAUT: OFF", Color3.fromRGB(60, 60, 60), function() end)

AreaBtn.MouseButton1Click:Connect(function()
    AreaActive = not AreaActive
    if AreaActive then
        AreaBtn.Text = "ZONA MAUT: ON"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        -- Matikan Fly jika aktif
        if Flying then 
             Flying = false; FlyBtn.Text = "FLY: OFF"; FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
             if FlyConnection then FlyConnection:Disconnect() end
             if FlyBodyVel then FlyBodyVel:Destroy() end
             if Plr.Character:FindFirstChild("Humanoid") then Plr.Character.Humanoid.PlatformStand = false end
        end

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
        else AreaActive = false return end

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
                for _, part in pairs(Plr.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
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
    end
end)

CreateBtn("TUTUP GUI", Color3.fromRGB(200, 0, 0), function()
    ScreenGui:Destroy()
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Zam New V3";
    Text = "Gui Loaded!";
    Duration = 5;
})
