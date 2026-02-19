local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- HELPERS
local function getHRP()
    return (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- CONFIG
local MAX_POSES = 5
local poseCount = 0
local positions = {}
local flySpeed = 50  -- Default flight speed
local beams = {}

-- CREATE VISUAL PLATFORM UNDER FEET (about 3 studs below HRP)
local function createVisualPlatform()
    local hrp = getHRP()

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(8, 1, 8)  -- hover platform size
    platform.Anchored = true
    platform.CanCollide = false  -- visual only
    platform.Material = Enum.Material.Neon
    platform.Color = Color3.fromRGB(135, 206, 250)
    platform.Name = "FlyPlatform"
    platform.Transparency = 0.3
    platform.Parent = workspace

    local angle = 0
    RunService.RenderStepped:Connect(function()
        if hrp.Parent and platform.Parent then
            angle = angle + math.rad(3)
            -- Position platform about 3 studs below HumanoidRootPart, so under feet
            local targetPos = hrp.Position - Vector3.new(0, 3, 0)
            platform.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, angle, 0)
        end
    end)
end

createVisualPlatform()

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- Logo Button
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0,75,0,75)
logo.Position = UDim2.new(0,18,0,18)
logo.Text = "UNI"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 30
logo.TextColor3 = Color3.fromRGB(135, 206, 250)
logo.BackgroundColor3 = Color3.fromRGB(18,18,18)
logo.Parent = gui
Instance.new("UICorner", logo).CornerRadius = UDim.new(0,16)

local logoGlow = Instance.new("UIStroke", logo)
logoGlow.Thickness = 4
logoGlow.Transparency = 0.5
logoGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
logoGlow.Color = Color3.fromRGB(135, 206, 250)

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0,300,0,300)
main.Position = UDim2.new(0.5,-150,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(22,22,22)
main.Visible = false
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local uiGlow = Instance.new("UIStroke", main)
uiGlow.Thickness = 6
uiGlow.Transparency = 0.5
uiGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiGlow.Color = Color3.fromRGB(135, 206, 250)

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,0,0,25)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.Text = "Skizzen's Universal"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.fromRGB(135, 206, 250)
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = main

-- Content Frame
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,10,0,55)
content.Size = UDim2.new(1,-20,1,-75)
content.BackgroundTransparency = 1

local tpFrame = Instance.new("Frame", content)
tpFrame.Size = UDim2.new(1,0,1,0)
tpFrame.BackgroundTransparency = 1

local tpLayout = Instance.new("UIListLayout", tpFrame)
tpLayout.Padding = UDim.new(0,4)

-- Speed Slider
local speedLabel = Instance.new("TextLabel", main)
speedLabel.Position = UDim2.new(0,10,1,-40)
speedLabel.Size = UDim2.new(0.5,0,0,25)
speedLabel.Text = "Speed: "..flySpeed
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 12
speedLabel.TextColor3 = Color3.fromRGB(135,206,250)
speedLabel.BackgroundTransparency = 1

local speedSlider = Instance.new("TextButton", main)
speedSlider.Size = UDim2.new(0,120,0,20)
speedSlider.Position = UDim2.new(0,10,1,-20)
speedSlider.Text = "Adjust Speed"
speedSlider.Font = Enum.Font.GothamBold
speedSlider.TextSize = 12
speedSlider.BackgroundColor3 = Color3.fromRGB(45,0,70)
speedSlider.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0,6)

speedSlider.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 10
    if flySpeed > 200 then flySpeed = 20 end
    speedLabel.Text = "Speed: "..flySpeed
end)

-- CREATE POSITION BOX FUNCTION WITH ORB AND BEAM
local function createPositionBox(i)
    local box = Instance.new("Frame", tpFrame)
    box.Size = UDim2.new(1,0,0,35)
    box.BackgroundColor3 = Color3.fromRGB(28,28,28)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.new(0.5,0,1,0)
    label.Position = UDim2.new(0.05,0,0,0)
    label.Text = "Position "..i
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextColor3 = Color3.fromRGB(135,206,250)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local orb = Instance.new("Part")
    orb.Size = Vector3.new(2, 2, 2)
    orb.Shape = Enum.PartType.Ball
    orb.Anchored = true
    orb.CanCollide = false
    orb.Material = Enum.Material.Neon
    orb.Color = Color3.fromRGB(135, 206, 250)
    orb.Parent = workspace

    local function makeBtn(txt, x)
        local b = Instance.new("TextButton", box)
        b.Size = UDim2.new(0,40,0,20)
        b.Position = UDim2.new(x,0,0.5,-10)
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9
        b.BackgroundColor3 = Color3.fromRGB(45,0,70)
        b.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end

    local save = makeBtn("Save",0.6)
    local fly = makeBtn("Fly",0.78)

    save.MouseButton1Click:Connect(function()
        positions[i] = getHRP().CFrame
        orb.Position = positions[i].Position

        -- CREATE BEAM FROM PLAYER TO THIS ORB
        if beams[i] then beams[i]:Destroy() end
        local attach0 = Instance.new("Attachment", getHRP())
        local attach1 = Instance.new("Attachment", orb)
        local beam = Instance.new("Beam")
        beam.Attachment0 = attach0
        beam.Attachment1 = attach1
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Color = ColorSequence.new(Color3.fromRGB(135,206,250))
        beam.Parent = workspace
        beams[i] = beam
    end)

    fly.MouseButton1Click:Connect(function()
        local hrp = getHRP()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end

        humanoid.PlatformStand = true

        local startPos = hrp.Position
        local targetPos = positions[i] and positions[i].Position or startPos
        targetPos = Vector3.new(targetPos.X, startPos.Y, targetPos.Z)

        -- TELEPORT 120 UP first
        hrp.CFrame = hrp.CFrame + Vector3.new(0,120,0)

        -- Trail effect
        local trailAttachment0 = Instance.new("Attachment", hrp)
        local trailAttachment1 = Instance.new("Attachment", hrp)
        local trail = Instance.new("Trail")
        trail.Attachment0 = trailAttachment0
        trail.Attachment1 = trailAttachment1
        trail.Color = ColorSequence.new(Color3.fromRGB(135,206,250), Color3.fromRGB(255,255,255))
        trail.Lifetime = 0.5
        trail.Parent = hrp
        Debris:AddItem(trail, 3)

        -- Fly toward target position
        task.spawn(function()
            while (Vector3.new(hrp.Position.X, startPos.Y, hrp.Position.Z) - targetPos).Magnitude > 1 do
                local dir = (targetPos - Vector3.new(hrp.Position.X, startPos.Y, hrp.Position.Z)).Unit
                hrp.Velocity = Vector3.new(dir.X,0,dir.Z) * flySpeed
                hrp.RotVelocity = Vector3.new(0,15,0)
                task.wait()
            end

            -- TELEPORT DOWN to original Y after arriving
            hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, startPos.Y, hrp.Position.Z))
            hrp.Velocity = Vector3.new(0,0,0)
            humanoid.PlatformStand = false
        end)
    end)
end

-- Initialize first position
poseCount = 1
createPositionBox(poseCount)

-- Add Button
local addBtn = Instance.new("TextButton", tpFrame)
addBtn.Size = UDim2.new(0,26,0,26)
addBtn.Text = "+"
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 14
addBtn.BackgroundColor3 = Color3.fromRGB(55,0,80)
addBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(1,0)

addBtn.MouseButton1Click:Connect(function()
    if poseCount >= MAX_POSES then return end
    poseCount += 1
    createPositionBox(poseCount)
    if poseCount >= MAX_POSES then addBtn.Visible = false end
end)

-- GUI Open/Close
logo.MouseButton1Click:Connect(function()
    logo.Visible = false
    main.Visible = true
end)

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,22,0,22)
minBtn.Position = UDim2.new(1,-55,0,8)
minBtn.Text = "_"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    logo.Visible = true
end)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,22,0,22)
closeBtn.Position = UDim2.new(1,-28,0,8)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BackgroundColor3 = Color3.fromRGB(45,0,70)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
