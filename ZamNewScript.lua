--[[
    KELZZ-AI v19.0: THE VOID BLIND
    FITUR: VOID TOOL (FE BLIND), TITAN ZONE 200, FLY
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
if CoreGui:FindFirstChild("KelzzVoidGui") then
    CoreGui:FindFirstChild("KelzzVoidGui"):Destroy()
end

-- 2. GUI BASE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KelzzVoidGui"
ScreenGui.Parent = CoreGui

-- TOMBOL TOGGLE (Huruf K)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Hitam Pekat
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

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 420) 
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(100, 100, 100)
Instance.new("UIStroke", MainFrame).Thickness = 2

-- JUDUL
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "Zam New V5"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- LOGIKA BUKA TUTUP
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === VARIABLES ===
local TargetPlayer = nil
local AreaActive = false
local AreaRange = 200
local VisualZone = nil
local CenterPart = nil
local AreaConnection = nil

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
-- FUNGSI PEMBUAT UI
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
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
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
-- BAGIAN 1: VOID BLIND (FITUR BARU)
-- ====================================================
CreateLabel("--- VOID BLIND (FE) ---")
local VoidBtn = CreateBtn("GET VOID TOOL (HITAM)", Color3.fromRGB(20, 20, 20), function() end)

VoidBtn.MouseButton1Click:Connect(function()
    if Plr.Backpack:FindFirstChild("THE VOID") or (Plr.Character and Plr.Character:FindFirstChild("THE VOID")) then
        VoidBtn.Text = "SUDAH ADA DI INVENTORY!"
        wait(1)
        VoidBtn.Text = "GET VOID TOOL (HITAM)"
        return
    end

    local Tool = Instance.new("Tool")
    Tool.Name = "THE VOID"
    Tool.RequiresHandle = true
    Tool.Parent = Plr.Backpack
    
    -- Handle Raksasa
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    -- Ukuran 50x50x50 cukup besar untuk menutupi layar tanpa dihapus server
    Handle.Size = Vector3.new(50, 50, 50) 
    Handle.Shape = Enum.PartType.Block
    Handle.Color = Color3.fromRGB(0, 0, 0) -- Hitam Pekat
    Handle.Material = Enum.Material.SmoothPlastic
    Handle.TopSurface = Enum.SurfaceType.Smooth
    Handle.BottomSurface = Enum.SurfaceType.Smooth
    Handle.Massless = true -- Agar tidak berat
    Handle.CanCollide = false -- Agar tidak nabrak tembok
    Handle.Parent = Tool
    
    -- Sound Effect (Optional, biar seram)
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://130768399" -- Horror drone sound
    Sound.Volume = 2
    Sound.Parent = Handle
    
    Tool.Equipped:Connect(function()
        Sound:Play()
    end)
    Tool.Unequipped:Connect(function()
        Sound:Stop()
    end)

    VoidBtn.Text = "VOID DITERIMA!"
    wait(1)
    VoidBtn.Text = "GET VOID TOOL (HITAM)"
end)

-- ====================================================
-- BAGIAN 2: FLY SYSTEM
-- ====================================================
CreateLabel("--- FLY CONTROL ---")
CreateSlider("Fly Speed", 10, 300, 50, function(val) FlySpeed = val end)
local FlyBtn = CreateBtn("FLY: OFF", Color3.fromRGB(60, 60, 60), function() end)

FlyBtn.MouseButton1Click:Connect(function()
    Flying = not Flying
    if Flying then
        FlyBtn.Text = "FLY: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
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
        FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if FlyConnection then FlyConnection:Disconnect() end
        if FlyBodyVel then FlyBodyVel:Destroy() end
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then Plr.Character.Humanoid.PlatformStand = false end
    end
end)

-- ====================================================
-- BAGIAN 3: TITAN ZONE (200 STUDS)
-- ====================================================
CreateLabel("--- TITAN ZONE (200) ---")
local AreaBtn = CreateBtn("ZONA TITAN: OFF", Color3.fromRGB(60, 60, 60), function() end)

AreaBtn.MouseButton1Click:Connect(function()
    AreaActive = not AreaActive
    if AreaActive then
        AreaBtn.Text = "ZONA TITAN: ON"
        AreaBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
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
        VisualZone.Transparency = 0.8
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
        AreaBtn.Text = "ZONA TITAN: OFF"
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
-- BAGIAN 4: CLICK TP
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

CreateBtn("TUTUP GUI", Color3.fromRGB(200, 0, 0), function()
    ScreenGui:Destroy()
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Zam New V5";
    Text = "Made By Gemini Ai!";
    Duration = 5;
})
