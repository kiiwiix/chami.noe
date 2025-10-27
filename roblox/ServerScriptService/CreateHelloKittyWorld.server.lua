local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

print("🌸 Création du monde Hello Kitty Cozy Farm...")

local worldFolder = Workspace:FindFirstChild("World")
if not worldFolder then
    worldFolder = Instance.new("Folder")
    worldFolder.Name = "World"
    worldFolder.Parent = Workspace
end

Workspace.Terrain:Clear()
for _, child in ipairs(worldFolder:GetChildren()) do
    child:Destroy()
end

Lighting.Ambient = Color3.fromRGB(255, 225, 240)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 220, 235)
Lighting.Brightness = 0.85
Lighting.ColorShift_Top = Color3.fromRGB(255, 210, 225)
Lighting.EnvironmentDiffuseScale = 0.6
Lighting.EnvironmentSpecularScale = 0.3
Lighting.FogEnd = 620
Lighting.FogColor = Color3.fromRGB(252, 244, 250)
Lighting.ClockTime = 10

local function ensureEffect(className, props)
    local existing = Lighting:FindFirstChildOfClass(className)
    if not existing then
        existing = Instance.new(className)
        existing.Parent = Lighting
    end
    for property, value in pairs(props or {}) do
        existing[property] = value
    end
    return existing
end

ensureEffect("BloomEffect", {Intensity = 0.08, Size = 45})
ensureEffect("ColorCorrectionEffect", {TintColor = Color3.fromRGB(255, 236, 246), Saturation = -0.05, Contrast = -0.08, Brightness = -0.02})
ensureEffect("SunRaysEffect", {Intensity = 0.12, Spread = 0.85})
ensureEffect("DepthOfFieldEffect", {FarIntensity = 0.12, FocusDistance = 95, InFocusRadius = 40})

local sky = Lighting:FindFirstChildOfClass("Sky")
if not sky then
    sky = Instance.new("Sky")
    sky.Parent = Lighting
end
sky.SkyboxBk = "rbxassetid://1095708"
sky.SkyboxDn = "rbxassetid://1095709"
sky.SkyboxFt = "rbxassetid://1095710"
sky.SkyboxLf = "rbxassetid://1095711"
sky.SkyboxRt = "rbxassetid://1095712"
sky.SkyboxUp = "rbxassetid://1095713"
sky.StarCount = 0
sky.SunAngularSize = 15

local ground = Instance.new("Part")
ground.Name = "Ground"
ground.Size = Vector3.new(400, 1, 400)
ground.Position = Vector3.new(0, 0, 0)
ground.Anchored = true
ground.Color = Color3.fromRGB(255, 240, 250)
ground.Material = Enum.Material.Grass
ground.TopSurface = Enum.SurfaceType.Smooth
ground.Parent = worldFolder

local function createTree(position)
    local trunk = Instance.new("Part")
    trunk.Name = "TreeTrunk"
    trunk.Size = Vector3.new(1.5, 6, 1.5)
    trunk.Position = position + Vector3.new(0, 3, 0)
    trunk.Anchored = true
    trunk.Color = Color3.fromRGB(212, 177, 145)
    trunk.Material = Enum.Material.Wood
    trunk.Parent = worldFolder

    local leaves = Instance.new("Part")
    leaves.Name = "TreeLeaves"
    leaves.Shape = Enum.PartType.Ball
    leaves.Size = Vector3.new(6, 6, 6)
    leaves.Position = trunk.Position + Vector3.new(0, 5, 0)
    leaves.Color = Color3.fromRGB(255, 205, 235)
    leaves.Material = Enum.Material.SmoothPlastic
    leaves.Anchored = true
    leaves.Parent = worldFolder

    local sparkles = Instance.new("ParticleEmitter")
    sparkles.Name = "LeafSparkles"
    sparkles.Rate = 2
    sparkles.Lifetime = NumberRange.new(4, 6)
    sparkles.Speed = NumberRange.new(0.1, 0.25)
    sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 230, 245))
    sparkles.LightEmission = 0.4
    sparkles.Parent = leaves
end

for i = 1, 10 do
    local position = Vector3.new(math.random(-100, 100), 0, math.random(-100, 100))
    createTree(position)
end

local function createPastelCloud(position)
    local cloud = Instance.new("Part")
    cloud.Name = "PastelCloud"
    cloud.Size = Vector3.new(12, 3, 8)
    cloud.CFrame = CFrame.new(position)
    cloud.Color = Color3.fromRGB(255, 246, 255)
    cloud.Transparency = 0.45
    cloud.Material = Enum.Material.SmoothPlastic
    cloud.Anchored = true
    cloud.CanCollide = false
    cloud.Parent = worldFolder

    local puff = Instance.new("ParticleEmitter")
    puff.Name = "CloudMist"
    puff.Texture = "rbxassetid://6511952523"
    puff.Color = ColorSequence.new(
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 210, 235))
    )
    puff.Lifetime = NumberRange.new(4, 6)
    puff.Rate = 4
    puff.Speed = NumberRange.new(0.3, 0.8)
    puff.SpreadAngle = Vector2.new(25, 25)
    puff.Parent = cloud

    local floatTween = TweenService:Create(
        cloud,
        TweenInfo.new(18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {CFrame = cloud.CFrame * CFrame.new(0, 3, 0)}
    )
    floatTween:Play()
end

for i = 1, 6 do
    local angle = (i / 6) * math.pi * 2
    local radius = 55
    local height = 32 + math.random(-3, 3)
    local position = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
    createPastelCloud(position)
end

local function createHelloKittyBow(position, rotation)
    local bow = Instance.new("Model")
    bow.Name = "HelloKittyBow"

    local center = Instance.new("Part")
    center.Name = "Center"
    center.Size = Vector3.new(2, 2, 1.2)
    center.Color = Color3.fromRGB(255, 165, 205)
    center.Material = Enum.Material.SmoothPlastic
    center.Anchored = true
    center.CanCollide = false
    center.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)
    center.Parent = bow

    local function createWing(offset)
        local wing = Instance.new("Part")
        wing.Name = "Wing"
        wing.Size = Vector3.new(3.2, 2.6, 1)
        wing.Color = Color3.fromRGB(255, 210, 225)
        wing.Material = Enum.Material.SmoothPlastic
        wing.Anchored = true
        wing.CanCollide = false
        wing.CFrame = CFrame.new(position + offset) * CFrame.Angles(0, math.rad(rotation), 0)
        wing.Parent = bow
        local ribbon = Instance.new("Decal")
        ribbon.Texture = "rbxassetid://10210388650"
        ribbon.Color3 = Color3.fromRGB(255, 255, 255)
        ribbon.Face = Enum.NormalId.Front
        ribbon.Parent = wing
        return wing
    end

    createWing(Vector3.new(-2.4, 0, 0))
    createWing(Vector3.new(2.4, 0, 0))

    bow.Parent = worldFolder
    return bow
end

createHelloKittyBow(Vector3.new(0, 4, -35), 0)
createHelloKittyBow(Vector3.new(-30, 4, 20), 30)
createHelloKittyBow(Vector3.new(30, 4, 25), -30)

local function createPicnicSpot(position)
    local blanket = Instance.new("Part")
    blanket.Name = "PicnicBlanket"
    blanket.Size = Vector3.new(12, 0.1, 8)
    blanket.Position = position + Vector3.new(0, 0.05, 0)
    blanket.Color = Color3.fromRGB(255, 218, 235)
    blanket.Material = Enum.Material.Fabric
    blanket.Anchored = true
    blanket.CanCollide = false
    blanket.Parent = worldFolder

    local pattern = Instance.new("SurfaceGui")
    pattern.Name = "BlanketPattern"
    pattern.Face = Enum.NormalId.Top
    pattern.CanvasSize = Vector2.new(400, 300)
    pattern.Adornee = blanket
    pattern.Parent = blanket

    local stripes = Instance.new("Frame")
    stripes.Size = UDim2.fromScale(1, 1)
    stripes.BackgroundColor3 = Color3.fromRGB(255, 225, 245)
    stripes.BorderSizePixel = 0
    stripes.Parent = pattern

    for i = 0, 5 do
        local stripe = Instance.new("Frame")
        stripe.Size = UDim2.new(1, 0, 0, 12)
        stripe.Position = UDim2.new(0, 0, i * 0.2, 0)
        stripe.BackgroundColor3 = Color3.fromRGB(255, 205, 235)
        stripe.BackgroundTransparency = 0.45
        stripe.BorderSizePixel = 0
        stripe.Parent = stripes
    end

    local basket = Instance.new("Part")
    basket.Name = "FruitBasket"
    basket.Size = Vector3.new(1.6, 1.6, 1.6)
    basket.Position = blanket.Position + Vector3.new(0, 1, 1.2)
    basket.Color = Color3.fromRGB(223, 187, 150)
    basket.Material = Enum.Material.Wood
    basket.Anchored = true
    basket.CanCollide = false
    basket.Parent = worldFolder

    local hearts = Instance.new("ParticleEmitter")
    hearts.Name = "FloatingHearts"
    hearts.Texture = "rbxassetid://1297566045"
    hearts.Color = ColorSequence.new(Color3.fromRGB(255, 190, 225))
    hearts.Speed = NumberRange.new(0.25, 0.4)
    hearts.Lifetime = NumberRange.new(4, 5)
    hearts.Rate = 3
    hearts.SpreadAngle = Vector2.new(12, 12)
    hearts.Parent = basket
end

createPicnicSpot(Vector3.new(0, 0.1, -15))

local function createFlowerPatch(position)
    local patchFolder = Instance.new("Folder")
    patchFolder.Name = "FlowerPatch"
    patchFolder.Parent = worldFolder

    for i = 1, 6 do
        local angle = (i / 6) * math.pi * 2
        local offset = Vector3.new(math.cos(angle) * 2.2, 0, math.sin(angle) * 2.2)
        local flower = Instance.new("Part")
        flower.Name = "PastelFlower"
        flower.Size = Vector3.new(0.6, 0.8, 0.6)
        flower.Position = position + offset + Vector3.new(0, 0.4, 0)
        flower.Anchored = true
        flower.CanCollide = false
        flower.Color = Color3.fromRGB(255, 215, 240)
        flower.Material = Enum.Material.SmoothPlastic
        flower.Shape = Enum.PartType.Ball
        flower.Parent = patchFolder

        local stem = Instance.new("Part")
        stem.Name = "Stem"
        stem.Size = Vector3.new(0.2, 0.8, 0.2)
        stem.Position = position + offset + Vector3.new(0, 0.1, 0)
        stem.Color = Color3.fromRGB(195, 238, 205)
        stem.Material = Enum.Material.SmoothPlastic
        stem.Anchored = true
        stem.CanCollide = false
        stem.Parent = patchFolder
    end

    local centerFlower = Instance.new("Part")
    centerFlower.Name = "CenterFlower"
    centerFlower.Size = Vector3.new(0.9, 1.2, 0.9)
    centerFlower.Position = position + Vector3.new(0, 0.5, 0)
    centerFlower.Color = Color3.fromRGB(255, 210, 235)
    centerFlower.Material = Enum.Material.SmoothPlastic
    centerFlower.Shape = Enum.PartType.Ball
    centerFlower.Anchored = true
    centerFlower.CanCollide = false
    centerFlower.Parent = patchFolder

    local glow = Instance.new("PointLight")
    glow.Color = Color3.fromRGB(255, 200, 230)
    glow.Range = 8
    glow.Brightness = 0.18
    glow.Parent = centerFlower

    local petals = Instance.new("ParticleEmitter")
    petals.Texture = "rbxassetid://5167133327"
    petals.Color = ColorSequence.new(Color3.fromRGB(255, 220, 240))
    petals.Speed = NumberRange.new(0.2, 0.5)
    petals.Lifetime = NumberRange.new(2.5, 3.5)
    petals.Rate = 2
    petals.SpreadAngle = Vector2.new(12, 12)
    petals.Parent = centerFlower
end

createFlowerPatch(Vector3.new(-12, 0.3, -10))
createFlowerPatch(Vector3.new(14, 0.3, -8))

local ambienceFolder = Instance.new("Folder")
ambienceFolder.Name = "AmbientSparkles"
ambienceFolder.Parent = worldFolder

for i = 1, 14 do
    local sparkle = Instance.new("Part")
    sparkle.Name = "SparkleEmitter"
    sparkle.Size = Vector3.new(1, 1, 1)
    sparkle.CFrame = CFrame.new(math.random(-35, 35), 1.8 + math.random() * 1.5, math.random(-35, 35))
    sparkle.Anchored = true
    sparkle.CanCollide = false
    sparkle.Transparency = 1
    sparkle.Parent = ambienceFolder

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://241876338"
    emitter.Rate = 4
    emitter.Lifetime = NumberRange.new(3.2, 4.5)
    emitter.Speed = NumberRange.new(0.1, 0.3)
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 245))
    emitter.SpreadAngle = Vector2.new(10, 10)
    emitter.Parent = sparkle
end

local bgm = SoundService:FindFirstChild("HelloKittyBGM")
if not bgm then
    bgm = Instance.new("Sound")
    bgm.Name = "HelloKittyBGM"
    bgm.SoundId = "rbxassetid://1843761401"
    bgm.Volume = 0.4
    bgm.Looped = true
    bgm.Parent = SoundService
end

if not bgm.IsPlaying then
    bgm:Play()
end

print("✅ Hello Kitty World ready (sparkly and safe).")
