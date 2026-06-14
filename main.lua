print("[ESP] Скрипт запущен, оптимизация теней...")

if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game:GetService("Players").LocalPlayer

-- Создаем папку для Highlights (Chams через стены)
local oldFolder = workspace:FindFirstChild("ESP_ChamsFolder")
if oldFolder then oldFolder:Destroy() end

local chamsFolder = Instance.new("Folder")
chamsFolder.Name = "ESP_ChamsFolder"
chamsFolder.Parent = workspace

-- Полная очистка предыдущих объектов Drawing и Индикаторов
if _G.ESP_Storage then
    for _, esp in pairs(_G.ESP_Storage) do
        if esp.boxOutline then esp.boxOutline:Remove() end
        if esp.boxFilled then esp.boxFilled:Remove() end
        if esp.boxOuter then esp.boxOuter:Remove() end
        if esp.boxShadow then esp.boxShadow:Remove() end
        if esp.cornerLines then for _, line in ipairs(esp.cornerLines) do if line then line:Remove() end end end
        if esp.cornerShadowLines then for _, line in ipairs(esp.cornerShadowLines) do if line then line:Remove() end end end
        if esp.box3dLines then for _, line in ipairs(esp.box3dLines) do if line then line:Remove() end end end
        if esp.box3dShadowLines then for _, line in ipairs(esp.box3dShadowLines) do if line then line:Remove() end end end
        if esp.nameText then esp.nameText:Remove() end
        if esp.hpText then esp.hpText:Remove() end
        if esp.distanceText then esp.distanceText:Remove() end
        if esp.stateText then esp.stateText:Remove() end
        if esp.tracer then esp.tracer:Remove() end
        if esp.skeletonLines then for _, line in ipairs(esp.skeletonLines) do if line then line:Remove() end end end
        if esp.healthBarOutline then esp.healthBarOutline:Remove() end
        if esp.healthBarFill then esp.healthBarFill:Remove() end
        if esp.headCircle then esp.headCircle:Remove() end
        if esp.highlight then esp.highlight:Destroy() end
        
        if esp.originalMats then
            for part, mat in pairs(esp.originalMats) do
                if part and part.Parent then part.Material = mat; part.Color = esp.originalColors[part] end
            end
        end
        if esp.originalTextures then
            for obj, tex in pairs(esp.originalTextures) do
                if obj and obj.Parent then
                    if obj:IsA("MeshPart") then obj.TextureID = tex
                    elseif obj:IsA("SpecialMesh") then obj.TextureId = tex
                    elseif obj:IsA("Decal") then obj.Texture = tex
                    elseif obj:IsA("Shirt") then obj.ShirtTemplate = tex
                    elseif obj:IsA("Pants") then obj.PantsTemplate = tex
                    elseif obj:IsA("ShirtGraphic") then obj.Graphic = tex end
                end
            end
        end
    end
    _G.ESP_Storage = {}
end

if _G.IndicatorStorage then
    for _, ind in ipairs(_G.IndicatorStorage) do
        if ind then ind:Remove() end
    end
end
_G.IndicatorStorage = {}

if _G.AimTargetLine then _G.AimTargetLine:Remove() end
_G.AimTargetLine = Drawing.new("Line")
_G.AimTargetLine.Visible = false
_G.AimTargetLine.Thickness = 1.5

-- Круг FOV для Аима
if _G.AimFOVCircle then _G.AimFOVCircle:Remove() end
_G.AimFOVCircle = Drawing.new("Circle")
_G.AimFOVCircle.Visible = false
_G.AimFOVCircle.Thickness = 1
_G.AimFOVCircle.NumSides = 64
_G.AimFOVCircle.Filled = false

-- Настройки по умолчанию
_G.ESP_Settings = _G.ESP_Settings or {}
local s = _G.ESP_Settings
if s.Enabled == nil then s.Enabled = false end
if s.ShowBox == nil then s.ShowBox = false end
if s.ShowShadow == nil then s.ShowShadow = false end
if s.ShowTracer == nil then s.ShowTracer = false end
if s.ShowName == nil then s.ShowName = false end
if s.ShowDistance == nil then s.ShowDistance = false end
if s.ShowState == nil then s.ShowState = false end
if s.ShowHealth == nil then s.ShowHealth = false end
if s.ShowSkeleton == nil then s.ShowSkeleton = false end
if s.ShowHealthBar == nil then s.ShowHealthBar = false end
if s.ShowHead == nil then s.ShowHead = false end
if s.ShowChams == nil then s.ShowChams = false end
if s.ChamsThroughWalls == nil then s.ChamsThroughWalls = false end
if s.ShowIndicators == nil then s.ShowIndicators = false end

-- Локал
if s.ShowLocalChams == nil then s.ShowLocalChams = false end
if s.OverrideFOV == nil then s.OverrideFOV = false end
if s.FOVValue == nil then s.FOVValue = 70 end

-- Аим
if s.AimLockEnabled == nil then s.AimLockEnabled = false end
if s.ShowAimTarget == nil then s.ShowAimTarget = false end
s.AimLockKey = s.AimLockKey or "RightClick"
s.AimSmoothness = s.AimSmoothness or 100
s.AimTargetColor = s.AimTargetColor or Color3.fromRGB(255, 0, 0)

-- Настройки FOV Аима
if s.AimFOVEnabled == nil then s.AimFOVEnabled = false end
if s.ShowAimFOV == nil then s.ShowAimFOV = false end
s.AimFOVRadius = s.AimFOVRadius or 100
s.AimFOVColor = s.AimFOVColor or Color3.fromRGB(255, 255, 255)

-- Размеры и Стили
if s.NameSize == nil then s.NameSize = 10 end
if s.DistanceSize == nil then s.DistanceSize = 10 end
if s.StateSize == nil then s.StateSize = 10 end

s.BoxStyle = s.BoxStyle or "Outline"
s.TextStyle = s.TextStyle or "Normal"
s.HealthBarPosition = s.HealthBarPosition or "Left"
s.TracerStyle = s.TracerStyle or "Bottom"
s.DistancePosition = s.DistancePosition or "Bottom"
s.StatePosition = s.StatePosition or "Right"
s.IndicatorPosition = s.IndicatorPosition or "Center Right"
s.IndicatorStyle = s.IndicatorStyle or "Normal"

-- Цвета
s.BoxColor = s.BoxColor or Color3.fromRGB(255, 255, 255)
s.TracerColor = s.TracerColor or Color3.fromRGB(255, 76, 76)
s.NameColor = s.NameColor or Color3.fromRGB(0, 0, 0)
s.HPTextColor = s.HPTextColor or Color3.fromRGB(0, 255, 0)
s.DistanceColor = s.DistanceColor or Color3.fromRGB(0, 0, 0) 
s.StateColor = s.StateColor or Color3.fromRGB(0, 0, 0) 
s.SkeletonColor = s.SkeletonColor or Color3.fromRGB(255, 255, 255)
s.HealthBarColor = s.HealthBarColor or Color3.fromRGB(0, 255, 0)
s.HeadColor = s.HeadColor or Color3.fromRGB(255, 255, 255)
s.IndicatorColor = s.IndicatorColor or Color3.fromRGB(0, 0, 0)

-- Chams Цвета
s.ChamsMaterial = s.ChamsMaterial or "Neon"
s.ChamsColor = s.ChamsColor or Color3.fromRGB(0, 0, 255)
s.LocalChamsMaterial = s.LocalChamsMaterial or "ForceField"
s.LocalChamsColor = s.LocalChamsColor or Color3.fromRGB(0, 255, 0)

-- RGB Modes
s.RGBMode = s.RGBMode or false
s.RGBModeTracer = s.RGBModeTracer or false
s.RGBModeSkeleton = s.RGBModeSkeleton or false
s.RGBModeHead = s.RGBModeHead or false
s.RGBModeChams = s.RGBModeChams or false
s.RGBModeLocalChams = s.RGBModeLocalChams or false
s.RGBModeIndicators = s.RGBModeIndicators or false
s.RGBModeName = s.RGBModeName or false
s.RGBModeHPText = s.RGBModeHPText or false
s.RGBModeDistance = s.RGBModeDistance or false
s.RGBModeState = s.RGBModeState or false
s.RGBModeHealthBar = s.RGBModeHealthBar or false

_G.ESP_Enabled = s.Enabled

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.ESP_Storage = {}

for i = 1, 15 do
    local ind = Drawing.new("Text")
    ind.Visible = false; ind.Size = 18; ind.Center = false; ind.Outline = true; ind.Color = Color3.new(1, 1, 1); ind.Font = 2
    _G.IndicatorStorage[i] = ind
end

local R15_Connections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6_Connections = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function revertChams(esp)
    if esp.originalMats then
        for part, mat in pairs(esp.originalMats) do
            if part and part.Parent then part.Material = mat; part.Color = esp.originalColors[part] end
        end
        table.clear(esp.originalMats)
        table.clear(esp.originalColors)
    end
    if esp.originalTextures then
        for obj, tex in pairs(esp.originalTextures) do
            if obj and obj.Parent then
                if obj:IsA("MeshPart") then obj.TextureID = tex
                elseif obj:IsA("SpecialMesh") then obj.TextureId = tex
                elseif obj:IsA("Decal") then obj.Texture = tex
                elseif obj:IsA("Shirt") then obj.ShirtTemplate = tex
                elseif obj:IsA("Pants") then obj.PantsTemplate = tex
                elseif obj:IsA("ShirtGraphic") then obj.Graphic = tex end
                if obj:IsA("Decal") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                    pcall(function() obj.Enabled = true end)
                end
            end
        end
        table.clear(esp.originalTextures)
    end
end

local function createESPForPlayer(player)
    local esp = { originalMats = {}, originalColors = {}, originalTextures = {} }
    local success, err = pcall(function()
        esp.boxOutline = Drawing.new("Square"); esp.boxOutline.Visible = false; esp.boxOutline.Thickness = 1; esp.boxOutline.Transparency = 0.8; esp.boxOutline.Filled = false
        esp.boxFilled = Drawing.new("Square"); esp.boxFilled.Visible = false; esp.boxFilled.Thickness = 0; esp.boxFilled.Transparency = 0.6; esp.boxFilled.Filled = true
        esp.boxOuter = Drawing.new("Square"); esp.boxOuter.Visible = false; esp.boxOuter.Thickness = 1; esp.boxOuter.Transparency = 0.5; esp.boxOuter.Filled = false
        esp.boxShadow = Drawing.new("Square"); esp.boxShadow.Visible = false; esp.boxShadow.Thickness = 1; esp.boxShadow.Transparency = 0.5; esp.boxShadow.Filled = false

        esp.cornerLines = {}
        for i = 1, 8 do local line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1; line.Transparency = 0.8; esp.cornerLines[i] = line end

        esp.cornerShadowLines = {}
        for i = 1, 8 do local line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1; line.Transparency = 0.6; line.Color = Color3.new(0, 0, 0); esp.cornerShadowLines[i] = line end

        esp.box3dLines = {}
        for i = 1, 12 do local line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1; line.Transparency = 0.8; esp.box3dLines[i] = line end

        esp.box3dShadowLines = {}
        for i = 1, 12 do local line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1; line.Transparency = 0.6; line.Color = Color3.new(0, 0, 0); esp.box3dShadowLines[i] = line end

        esp.nameText = Drawing.new("Text"); esp.nameText.Visible = false; esp.nameText.Center = true; esp.nameText.Outline = true; esp.nameText.Font = 0
        esp.hpText = Drawing.new("Text"); esp.hpText.Visible = false; esp.hpText.Center = true; esp.hpText.Outline = true; esp.hpText.Font = 0
        esp.distanceText = Drawing.new("Text"); esp.distanceText.Visible = false; esp.distanceText.Center = true; esp.distanceText.Outline = true; esp.distanceText.Font = 0
        esp.stateText = Drawing.new("Text"); esp.stateText.Visible = false; esp.stateText.Center = true; esp.stateText.Outline = true; esp.stateText.Font = 0
        esp.tracer = Drawing.new("Line"); esp.tracer.Visible = false; esp.tracer.Thickness = 1; esp.tracer.Transparency = 0.5

        esp.skeletonLines = {}
        for i = 1, 14 do local line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1; line.Transparency = 0.8; esp.skeletonLines[i] = line end

        esp.healthBarOutline = Drawing.new("Square"); esp.healthBarOutline.Visible = false; esp.healthBarOutline.Filled = true
        esp.healthBarFill = Drawing.new("Square"); esp.healthBarFill.Visible = false; esp.healthBarFill.Filled = true
        esp.headCircle = Drawing.new("Circle"); esp.headCircle.Visible = false; esp.headCircle.Thickness = 1; esp.headCircle.Filled = false
        
        esp.highlight = Instance.new("Highlight"); esp.highlight.Enabled = false; esp.highlight.Parent = chamsFolder
    end)
    if not success then warn("[ESP] Ошибка инициализации Drawing: " .. tostring(err)); return end
    _G.ESP_Storage[player.UserId] = esp
end

local function removeESPForPlayer(player)
    local esp = _G.ESP_Storage[player.UserId]
    if not esp then return end
    revertChams(esp)

    if esp.boxOutline then esp.boxOutline:Remove() end
    if esp.boxFilled then esp.boxFilled:Remove() end
    if esp.boxOuter then esp.boxOuter:Remove() end
    if esp.boxShadow then esp.boxShadow:Remove() end
    if esp.cornerLines then for _, line in ipairs(esp.cornerLines) do if line then line:Remove() end end end
    if esp.cornerShadowLines then for _, line in ipairs(esp.cornerShadowLines) do if line then line:Remove() end end end
    if esp.box3dLines then for _, line in ipairs(esp.box3dLines) do if line then line:Remove() end end end
    if esp.box3dShadowLines then for _, line in ipairs(esp.box3dShadowLines) do if line then line:Remove() end end end
    if esp.nameText then esp.nameText:Remove() end
    if esp.hpText then esp.hpText:Remove() end
    if esp.distanceText then esp.distanceText:Remove() end
    if esp.stateText then esp.stateText:Remove() end
    if esp.tracer then esp.tracer:Remove() end
    if esp.skeletonLines then for _, line in ipairs(esp.skeletonLines) do if line then line:Remove() end end end
    if esp.healthBarOutline then esp.healthBarOutline:Remove() end
    if esp.healthBarFill then esp.healthBarFill:Remove() end
    if esp.headCircle then esp.headCircle:Remove() end
    if esp.highlight then esp.highlight:Destroy() end

    _G.ESP_Storage[player.UserId] = nil
end

-- Создаем ESP для всех
for _, p in ipairs(Players:GetPlayers()) do createESPForPlayer(p) end
Players.PlayerAdded:Connect(createESPForPlayer)
Players.PlayerRemoving:Connect(removeESPForPlayer)

local function hideAllBoxStyles(esp)
    if esp.boxOutline then esp.boxOutline.Visible = false end
    if esp.boxFilled then esp.boxFilled.Visible = false end
    if esp.boxOuter then esp.boxOuter.Visible = false end
    if esp.boxShadow then esp.boxShadow.Visible = false end
    if esp.cornerLines then for _, line in ipairs(esp.cornerLines) do if line then line.Visible = false end end end
    if esp.cornerShadowLines then for _, line in ipairs(esp.cornerShadowLines) do if line then line.Visible = false end end end
    if esp.box3dLines then for _, line in ipairs(esp.box3dLines) do if line then line.Visible = false end end end
    if esp.box3dShadowLines then for _, line in ipairs(esp.box3dShadowLines) do if line then line.Visible = false end end end
end

local function draw3DBox(esp, root, camera, boxColor, showShadow)
    local size = Vector3.new(3, 5, 3) 
    local cf = root.CFrame
    local c = {
        cf * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2), cf * Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
        cf * Vector3.new(size.X/2, -size.Y/2, size.Z/2), cf * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
        cf * Vector3.new(-size.X/2, size.Y/2, -size.Z/2), cf * Vector3.new(size.X/2, size.Y/2, -size.Z/2),
        cf * Vector3.new(size.X/2, size.Y/2, size.Z/2), cf * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
    }
    local pts = {}
    for i=1, 8 do
        local pt = camera:WorldToViewportPoint(c[i])
        pts[i] = { Vector2.new(pt.X, pt.Y), pt.Z > 0 }
    end

    local edges = { {1,2}, {2,3}, {3,4}, {4,1}, {5,6}, {6,7}, {7,8}, {8,5}, {1,5}, {2,6}, {3,7}, {4,8} }
    for i, edge in ipairs(edges) do
        local p1, p2 = pts[edge[1]], pts[edge[2]]
        if p1[2] and p2[2] then
            if showShadow and esp.box3dShadowLines[i] then
                esp.box3dShadowLines[i].From = p1[1] + Vector2.new(1,1); esp.box3dShadowLines[i].To = p2[1] + Vector2.new(1,1)
                esp.box3dShadowLines[i].Visible = true
            elseif esp.box3dShadowLines[i] then esp.box3dShadowLines[i].Visible = false end
            esp.box3dLines[i].From = p1[1]; esp.box3dLines[i].To = p2[1]
            esp.box3dLines[i].Color = boxColor; esp.box3dLines[i].Visible = true
        else
            if esp.box3dShadowLines[i] then esp.box3dShadowLines[i].Visible = false end
            if esp.box3dLines[i] then esp.box3dLines[i].Visible = false end
        end
    end
end

local function drawBox(esp, style, boxColor, boxPosX, boxPosY, boxWidth, boxHeight)
    hideAllBoxStyles(esp)
    local showShadow = s.ShowShadow
    local success, err = pcall(function()
        if style == "Outline" then
            if showShadow and esp.boxShadow then
                esp.boxShadow.Color = Color3.new(0, 0, 0); esp.boxShadow.Size = Vector2.new(boxWidth, boxHeight)
                esp.boxShadow.Position = Vector2.new(boxPosX + 1, boxPosY + 1); esp.boxShadow.Visible = true
            end
            esp.boxOutline.Color = boxColor; esp.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
            esp.boxOutline.Position = Vector2.new(boxPosX, boxPosY); esp.boxOutline.Visible = true

        elseif style == "Filled" then
            if showShadow and esp.boxShadow then
                esp.boxShadow.Color = Color3.new(0, 0, 0); esp.boxShadow.Size = Vector2.new(boxWidth, boxHeight)
                esp.boxShadow.Position = Vector2.new(boxPosX + 1, boxPosY + 1); esp.boxShadow.Filled = true; esp.boxShadow.Visible = true
            end
            esp.boxFilled.Color = boxColor; esp.boxFilled.Size = Vector2.new(boxWidth, boxHeight)
            esp.boxFilled.Position = Vector2.new(boxPosX, boxPosY); esp.boxFilled.Visible = true
            esp.boxOutline.Color = Color3.new(1, 1, 1); esp.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
            esp.boxOutline.Position = Vector2.new(boxPosX, boxPosY); esp.boxOutline.Visible = true

        elseif style == "Corners" then
            local cornerLength = math.max(2, math.floor(math.min(boxWidth, boxHeight) * 0.3))
            local corners = {
                { From = Vector2.new(boxPosX, boxPosY), To = Vector2.new(boxPosX + cornerLength, boxPosY) },
                { From = Vector2.new(boxPosX, boxPosY), To = Vector2.new(boxPosX, boxPosY + cornerLength) },
                { From = Vector2.new(boxPosX + boxWidth, boxPosY), To = Vector2.new(boxPosX + boxWidth - cornerLength, boxPosY) },
                { From = Vector2.new(boxPosX + boxWidth, boxPosY), To = Vector2.new(boxPosX + boxWidth, boxPosY + cornerLength) },
                { From = Vector2.new(boxPosX, boxPosY + boxHeight), To = Vector2.new(boxPosX + cornerLength, boxPosY + boxHeight) },
                { From = Vector2.new(boxPosX, boxPosY + boxHeight), To = Vector2.new(boxPosX, boxPosY + boxHeight - cornerLength) },
                { From = Vector2.new(boxPosX + boxWidth, boxPosY + boxHeight), To = Vector2.new(boxPosX + boxWidth - cornerLength, boxPosY + boxHeight) },
                { From = Vector2.new(boxPosX + boxWidth, boxPosY + boxHeight), To = Vector2.new(boxPosX + boxWidth, boxPosY + boxHeight - cornerLength) }
            }
            if showShadow and esp.cornerShadowLines then
                for i, corner in ipairs(corners) do
                    if esp.cornerShadowLines[i] then
                        esp.cornerShadowLines[i].From = corner.From + Vector2.new(1, 1); esp.cornerShadowLines[i].To = corner.To + Vector2.new(1, 1); esp.cornerShadowLines[i].Visible = true
                    end
                end
            end
            for i, corner in ipairs(corners) do
                if esp.cornerLines[i] then
                    esp.cornerLines[i].Color = boxColor; esp.cornerLines[i].From = corner.From; esp.cornerLines[i].To = corner.To; esp.cornerLines[i].Visible = true
                end
            end
        end
    end)
end

local function updateESP()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local myCharacter = localPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    local viewportSize = camera.ViewportSize
    local settings = s

    -- Обновление RGB цветов
    local rgbColor = Color3.fromHSV((tick() % 3) / 3, 1, 1)
    if settings.RGBMode then settings.BoxColor = rgbColor end
    if settings.RGBModeTracer then settings.TracerColor = rgbColor end
    if settings.RGBModeSkeleton then settings.SkeletonColor = rgbColor end
    if settings.RGBModeHead then settings.HeadColor = rgbColor end
    if settings.RGBModeChams then settings.ChamsColor = rgbColor end
    if settings.RGBModeLocalChams then settings.LocalChamsColor = rgbColor end
    if settings.RGBModeIndicators then settings.IndicatorColor = rgbColor end
    if settings.RGBModeName then settings.NameColor = rgbColor end
    if settings.RGBModeHPText then settings.HPTextColor = rgbColor end
    if settings.RGBModeDistance then settings.DistanceColor = rgbColor end
    if settings.RGBModeState then settings.StateColor = rgbColor end
    if settings.RGBModeHealthBar then settings.HealthBarColor = rgbColor end

    -- Применение кастомного FOV
    if settings.OverrideFOV then camera.FieldOfView = settings.FOVValue end

    -- Обновление круга FOV Аима
    if settings.ShowAimFOV then
        _G.AimFOVCircle.Visible = true
        _G.AimFOVCircle.Radius = settings.AimFOVRadius
        _G.AimFOVCircle.Color = settings.AimFOVColor
        _G.AimFOVCircle.Position = UserInputService:GetMouseLocation()
    else
        _G.AimFOVCircle.Visible = false
    end

    local tFont = 0
    if settings.TextStyle == "Gamesense" then tFont = 2
    elseif settings.TextStyle == "Neverlose" then tFont = 3 end

    local function fmtText(str)
        if settings.TextStyle == "Gamesense" or settings.TextStyle == "Neverlose" then return string.lower(str) end
        return str
    end

    -- AIMBOT Переменные
    local mousePos = UserInputService:GetMouseLocation()
    local closestDist = settings.AimFOVEnabled and settings.AimFOVRadius or math.huge
    local currentAimTarget = nil

    for _, player in ipairs(Players:GetPlayers()) do
        local isLocal = (player == localPlayer)
        local esp = _G.ESP_Storage[player.UserId]
        if not esp then continue end

        hideAllBoxStyles(esp)
        if esp.nameText then esp.nameText.Visible = false end
        if esp.hpText then esp.hpText.Visible = false end
        if esp.distanceText then esp.distanceText.Visible = false end
        if esp.stateText then esp.stateText.Visible = false end
        if esp.tracer then esp.tracer.Visible = false end
        if esp.skeletonLines then for _, line in ipairs(esp.skeletonLines) do if line then line.Visible = false end end end
        if esp.healthBarOutline then esp.healthBarOutline.Visible = false end
        if esp.healthBarFill then esp.healthBarFill.Visible = false end
        if esp.headCircle then esp.headCircle.Visible = false end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChild("Humanoid")

        -- Логика Chams
        local shouldShowChams = (isLocal and settings.ShowLocalChams) or (not isLocal and settings.ShowChams)
        local matToUse = isLocal and Enum.Material[settings.LocalChamsMaterial] or Enum.Material[settings.ChamsMaterial] or Enum.Material.Neon
        local colToUse = isLocal and settings.LocalChamsColor or settings.ChamsColor

        if settings.Enabled and shouldShowChams and char and hum and hum.Health > 0 then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
                    if not esp.originalMats[part] then
                        esp.originalMats[part] = part.Material
                        esp.originalColors[part] = part.Color
                    end
                    part.Material = matToUse
                    part.Color = colToUse

                    if part:IsA("MeshPart") then
                        if esp.originalTextures[part] == nil then esp.originalTextures[part] = part.TextureID end
                        part.TextureID = ""
                    end
                elseif part:IsA("SpecialMesh") then
                    if esp.originalTextures[part] == nil then esp.originalTextures[part] = part.TextureId end
                    part.TextureId = ""
                elseif part:IsA("Decal") then
                    if esp.originalTextures[part] == nil then esp.originalTextures[part] = part.Texture end
                    part.Texture = ""
                elseif part:IsA("Shirt") then
                    if esp.originalTextures[part] == nil then esp.originalTextures[part] = part.ShirtTemplate end
                    part.ShirtTemplate = ""
                elseif part:IsA("Pants") then
                    if esp.originalTextures[part] == nil then esp.originalTextures[part] = part.PantsTemplate end
                    part.PantsTemplate = ""
                elseif part:IsA("ShirtGraphic") then
                    if esp.originalTextures[part] == nil then esp.originalTextures[part] = part.Graphic end
                    part.Graphic = ""
                end
                
                -- Отключаем видимость текстур полностью для чистого эффекта
                if part:IsA("Decal") or part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic") then
                    pcall(function() part.Enabled = false end)
                end
            end
            if esp.highlight then
                if settings.ChamsThroughWalls and not isLocal then
                    esp.highlight.Adornee = char; esp.highlight.FillColor = colToUse
                    esp.highlight.FillTransparency = 0.5; esp.highlight.OutlineTransparency = 1
                    esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; esp.highlight.Enabled = true
                else
                    esp.highlight.Enabled = false
                end
            end
        else
            revertChams(esp)
            if esp.highlight then esp.highlight.Enabled = false end
        end

        if not settings.Enabled then continue end
        if isLocal then continue end -- Дальше только логика для врагов

        if root and head and myRoot and hum and hum.Health > 0 then
            local rootScreenPos, onScreen = camera:WorldToViewportPoint(root.Position)
            local headScreenPos, headOnScreen = camera:WorldToViewportPoint(head.Position)

            -- ПРАВИЛЬНЫЙ ПОИСК ЦЕЛИ ПО FOV ДЛЯ AIMBOT
            if settings.AimLockEnabled and headOnScreen then
                local distToMouse = (Vector2.new(headScreenPos.X, headScreenPos.Y) - mousePos).Magnitude
                
                -- Проверяем попадает ли в радиус (если включен) и ближе ли он к мыши
                if distToMouse <= closestDist then
                    closestDist = distToMouse
                    currentAimTarget = head
                end
            end

            if onScreen and rootScreenPos.X > 0 and rootScreenPos.X < viewportSize.X and rootScreenPos.Y > 0 and rootScreenPos.Y < viewportSize.Y then
                local headScreenPosAdj = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legScreenPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                local boxHeight = math.max(4, math.floor(math.abs(headScreenPosAdj.Y - legScreenPos.Y)))
                local boxWidth = math.max(3, math.floor(boxHeight / 1.5))
                local boxPosX = math.floor(rootScreenPos.X - boxWidth / 2)
                local boxPosY = math.floor(headScreenPosAdj.Y)

                if settings.ShowBox then
                    if settings.BoxStyle == "3D Box" then
                        hideAllBoxStyles(esp)
                        draw3DBox(esp, root, camera, settings.BoxColor, settings.ShowShadow)
                    else
                        drawBox(esp, settings.BoxStyle, settings.BoxColor, boxPosX, boxPosY, boxWidth, boxHeight)
                    end
                end

                local offsets = { Top = 2, Bottom = 2, Left = 4, Right = 4 }
                local sideOffsets = { LeftY = 0, RightY = 0 }

                if settings.ShowHealthBar and esp.healthBarOutline and esp.healthBarFill then
                    local maxHealth = hum.MaxHealth
                    if maxHealth <= 0 then maxHealth = 100 end
                    local ratio = math.clamp(hum.Health / maxHealth, 0, 1)

                    local outlinePosX, outlinePosY, outlineWidth, outlineHeight
                    local fillPosX, fillPosY, fillWidth, fillHeight

                    if settings.HealthBarPosition == "Left" then
                        outlinePosX, outlinePosY = boxPosX - 6, boxPosY
                        outlineWidth, outlineHeight = 4, boxHeight
                        fillWidth = 2; fillHeight = math.floor((boxHeight - 2) * ratio)
                        fillPosX = outlinePosX + 1; fillPosY = outlinePosY + 1 + (boxHeight - 2 - fillHeight)
                        offsets.Left = offsets.Left + 6
                    elseif settings.HealthBarPosition == "Right" then
                        outlinePosX, outlinePosY = boxPosX + boxWidth + 2, boxPosY
                        outlineWidth, outlineHeight = 4, boxHeight
                        fillWidth = 2; fillHeight = math.floor((boxHeight - 2) * ratio)
                        fillPosX = outlinePosX + 1; fillPosY = outlinePosY + 1 + (boxHeight - 2 - fillHeight)
                        offsets.Right = offsets.Right + 6
                    elseif settings.HealthBarPosition == "Top" then
                        outlinePosX, outlinePosY = boxPosX, boxPosY - 6
                        outlineWidth, outlineHeight = boxWidth, 4
                        fillHeight = 2; fillWidth = math.floor((boxWidth - 2) * ratio)
                        fillPosX = outlinePosX + 1; fillPosY = outlinePosY + 1
                        offsets.Top = offsets.Top + 6
                    elseif settings.HealthBarPosition == "Bottom" then
                        outlinePosX, outlinePosY = boxPosX, boxPosY + boxHeight + 2
                        outlineWidth, outlineHeight = boxWidth, 4
                        fillHeight = 2; fillWidth = math.floor((boxWidth - 2) * ratio)
                        fillPosX = outlinePosX + 1; fillPosY = outlinePosY + 1
                        offsets.Bottom = offsets.Bottom + 6
                    end

                    esp.healthBarOutline.Size = Vector2.new(outlineWidth, outlineHeight)
                    esp.healthBarOutline.Position = Vector2.new(outlinePosX, outlinePosY)
                    esp.healthBarOutline.Color = Color3.new(0, 0, 0); esp.healthBarOutline.Visible = true

                    esp.healthBarFill.Size = Vector2.new(fillWidth, fillHeight)
                    esp.healthBarFill.Position = Vector2.new(fillPosX, fillPosY)
                    esp.healthBarFill.Color = settings.HealthBarColor; esp.healthBarFill.Visible = true
                end

                if settings.ShowName or settings.ShowHealth then
                    local nameStr = settings.ShowName and fmtText(player.Name) or ""
                    local hpStr = settings.ShowHealth and fmtText(string.format("[HP: %d]", math.floor(hum.Health))) or ""

                    esp.nameText.Text = nameStr; esp.nameText.Size = settings.NameSize; esp.nameText.Font = tFont
                    esp.hpText.Text = hpStr; esp.hpText.Size = settings.NameSize; esp.hpText.Font = tFont
                    esp.nameText.Center = true; esp.hpText.Center = true

                    if settings.ShowName and not settings.ShowHealth then
                        esp.nameText.Color = settings.NameColor
                        esp.nameText.Position = Vector2.new(boxPosX + boxWidth / 2, boxPosY - offsets.Top - settings.NameSize)
                        esp.nameText.Visible = true; esp.hpText.Visible = false
                        offsets.Top = offsets.Top + settings.NameSize + 2
                    elseif settings.ShowHealth and not settings.ShowName then
                        esp.hpText.Color = settings.HPTextColor
                        esp.hpText.Position = Vector2.new(boxPosX + boxWidth / 2, boxPosY - offsets.Top - settings.NameSize)
                        esp.hpText.Visible = true; esp.nameText.Visible = false
                        offsets.Top = offsets.Top + settings.NameSize + 2
                    else
                        local nWidth = esp.nameText.TextBounds.X
                        local hWidth = esp.hpText.TextBounds.X
                        local totalW = nWidth + hWidth + 4
                        local centerX = boxPosX + boxWidth / 2
                        local startX = centerX - (totalW / 2)
                        
                        esp.nameText.Color = settings.NameColor
                        esp.nameText.Position = Vector2.new(startX + nWidth / 2, boxPosY - offsets.Top - settings.NameSize)
                        esp.hpText.Color = settings.HPTextColor
                        esp.hpText.Position = Vector2.new(startX + nWidth + 4 + hWidth / 2, boxPosY - offsets.Top - settings.NameSize)
                        
                        esp.nameText.Visible = true; esp.hpText.Visible = true
                        offsets.Top = offsets.Top + settings.NameSize + 2
                    end
                end

                if settings.ShowTracer and esp.tracer then
                    esp.tracer.Color = settings.TracerColor
                    local tracerOrigin
                    if settings.TracerStyle == "Center" then tracerOrigin = Vector2.new(math.floor(viewportSize.X / 2), math.floor(viewportSize.Y / 2))
                    elseif settings.TracerStyle == "Mouse" then tracerOrigin = Vector2.new(math.floor(mousePos.X), math.floor(mousePos.Y))
                    else tracerOrigin = Vector2.new(math.floor(viewportSize.X / 2), math.floor(viewportSize.Y)) end
                    esp.tracer.From = tracerOrigin; esp.tracer.To = Vector2.new(math.floor(rootScreenPos.X), math.floor(rootScreenPos.Y)); esp.tracer.Visible = true
                end

                if settings.ShowHead and esp.headCircle then
                    if headScreenPos.Z > 0 then
                        esp.headCircle.Position = Vector2.new(math.floor(headScreenPos.X), math.floor(headScreenPos.Y))
                        esp.headCircle.Radius = math.max(2, math.floor(boxHeight / 10))
                        esp.headCircle.Color = settings.HeadColor; esp.headCircle.Visible = true
                    end
                end

                if settings.ShowDistance and esp.distanceText then
                    local distance = math.floor((myRoot.Position - root.Position).Magnitude)
                    esp.distanceText.Size = settings.DistanceSize; esp.distanceText.Text = fmtText(tostring(distance) .. "m")
                    esp.distanceText.Color = settings.DistanceColor; esp.distanceText.Font = tFont
                    
                    local posType = settings.DistancePosition
                    if posType == "Top" then
                        esp.distanceText.Center = true; esp.distanceText.Position = Vector2.new(boxPosX + boxWidth / 2, boxPosY - offsets.Top - settings.DistanceSize)
                        offsets.Top = offsets.Top + settings.DistanceSize + 2
                    elseif posType == "Bottom" then
                        esp.distanceText.Center = true; esp.distanceText.Position = Vector2.new(boxPosX + boxWidth / 2, boxPosY + boxHeight + offsets.Bottom)
                        offsets.Bottom = offsets.Bottom + settings.DistanceSize + 2
                    elseif posType == "Left" then
                        esp.distanceText.Center = false; esp.distanceText.Position = Vector2.new(boxPosX - offsets.Left - esp.distanceText.TextBounds.X, boxPosY + sideOffsets.LeftY)
                        sideOffsets.LeftY = sideOffsets.LeftY + settings.DistanceSize + 2
                    elseif posType == "Right" then
                        esp.distanceText.Center = false; esp.distanceText.Position = Vector2.new(boxPosX + boxWidth + offsets.Right, boxPosY + sideOffsets.RightY)
                        sideOffsets.RightY = sideOffsets.RightY + settings.DistanceSize + 2
                    end
                    esp.distanceText.Visible = true
                end

                if settings.ShowState and esp.stateText then
                    local state = "IDLE"
                    if hum.FloorMaterial == Enum.Material.Air then state = "AIR"
                    elseif hum.MoveDirection.Magnitude > 0 then state = (hum.WalkSpeed < 12) and "CROUCH" or "RUN" end
                    
                    esp.stateText.Size = settings.StateSize; esp.stateText.Text = fmtText(state)
                    esp.stateText.Color = settings.StateColor; esp.stateText.Font = tFont
                    
                    local posType = settings.StatePosition
                    if posType == "Top" then
                        esp.stateText.Center = true; esp.stateText.Position = Vector2.new(boxPosX + boxWidth / 2, boxPosY - offsets.Top - settings.StateSize)
                        offsets.Top = offsets.Top + settings.StateSize + 2
                    elseif posType == "Bottom" then
                        esp.stateText.Center = true; esp.stateText.Position = Vector2.new(boxPosX + boxWidth / 2, boxPosY + boxHeight + offsets.Bottom)
                        offsets.Bottom = offsets.Bottom + settings.StateSize + 2
                    elseif posType == "Left" then
                        esp.stateText.Center = false; esp.stateText.Position = Vector2.new(boxPosX - offsets.Left - esp.stateText.TextBounds.X, boxPosY + sideOffsets.LeftY)
                        sideOffsets.LeftY = sideOffsets.LeftY + settings.StateSize + 2
                    elseif posType == "Right" then
                        esp.stateText.Center = false; esp.stateText.Position = Vector2.new(boxPosX + boxWidth + offsets.Right, boxPosY + sideOffsets.RightY)
                        sideOffsets.RightY = sideOffsets.RightY + settings.StateSize + 2
                    end
                    esp.stateText.Visible = true
                end
            end 

            if settings.ShowSkeleton and esp.skeletonLines then
                local isR15 = hum.RigType == Enum.HumanoidRigType.R15
                local connections = isR15 and R15_Connections or R6_Connections
                for i, conn in ipairs(connections) do
                    local partA, partB = char:FindFirstChild(conn[1]), char:FindFirstChild(conn[2])
                    local line = esp.skeletonLines[i]
                    if partA and partB and line then
                        local posA, posB = camera:WorldToViewportPoint(partA.Position), camera:WorldToViewportPoint(partB.Position)
                        if posA.Z > 0 and posB.Z > 0 then
                            line.From = Vector2.new(math.floor(posA.X), math.floor(posA.Y))
                            line.To = Vector2.new(math.floor(posB.X), math.floor(posB.Y))
                            line.Color = settings.SkeletonColor; line.Visible = true
                        else line.Visible = false end
                    elseif line then line.Visible = false end
                end
            end
        end
    end

    -- ПРОВЕРКА НАЖАТИЯ КНОПКИ ДЛЯ АИМА (УПРАВЛЯЕТ CAMERA АИМОМ)
    local isAimKeyDown = false
    local k = settings.AimLockKey
    if k == "RightClick" then 
        isAimKeyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif k == "LeftClick" then 
        isAimKeyDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    else 
        pcall(function() isAimKeyDown = UserInputService:IsKeyDown(Enum.KeyCode[k]) end) 
    end

    -- ПРИМЕНЕНИЕ АИМБОТА ТОЛЬКО ПРИ ЗАЖАТИИ КНОПКИ
    if isAimKeyDown and currentAimTarget then

        -- Включаем Aim Lock (Прилипание камеры)
        if settings.AimLockEnabled then
            local smooth = settings.AimSmoothness / 100
            if smooth >= 1 then
                camera.CFrame = CFrame.new(camera.CFrame.Position, currentAimTarget.Position)
            else
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, currentAimTarget.Position), smooth)
            end
        end

        -- Показ линии на цель
        if settings.ShowAimTarget then
            local headPos = camera:WorldToViewportPoint(currentAimTarget.Position)
            _G.AimTargetLine.From = mousePos
            _G.AimTargetLine.To = Vector2.new(headPos.X, headPos.Y)
            _G.AimTargetLine.Color = settings.AimTargetColor
            _G.AimTargetLine.Visible = true
        else
            _G.AimTargetLine.Visible = false
        end
    else
        -- ЕСЛИ КНОПКА ОТПУЩЕНА ИЛИ НЕТ ЦЕЛИ -> ВЫКЛЮЧАЕМ АИМБОТЫ
        _G.AimTargetLine.Visible = false
    end

    -- Индикаторы
    local activeFeatures = {}
    if settings.ShowIndicators then
        if settings.Enabled then table.insert(activeFeatures, "ESP ACTIVE") end
        if settings.AimLockEnabled then table.insert(activeFeatures, "AIM LOCK") end
        if settings.ShowBox then table.insert(activeFeatures, "BOX") end
        if settings.ShowChams then table.insert(activeFeatures, "CHAMS") end
        if settings.ShowLocalChams then table.insert(activeFeatures, "LOCAL CHAMS") end
        if settings.ShowTracer then table.insert(activeFeatures, "TRACERS") end
        if settings.ShowSkeleton then table.insert(activeFeatures, "SKELETON") end
        if settings.ShowHead then table.insert(activeFeatures, "HEAD ESP") end
        if settings.ShowName then table.insert(activeFeatures, "NAME") end
        if settings.ShowHealth then table.insert(activeFeatures, "HP TEXT") end
        if settings.ShowDistance then table.insert(activeFeatures, "DISTANCE") end
        if settings.ShowState then table.insert(activeFeatures, "STATE") end
        if settings.ShowHealthBar then table.insert(activeFeatures, "HP BAR") end
        if settings.AimFOVEnabled then table.insert(activeFeatures, "FOV ACTIVE") end
        if settings.OverrideFOV then table.insert(activeFeatures, "FOV: " .. tostring(settings.FOVValue)) end
        if settings.RGBMode or settings.RGBModeChams or settings.RGBModeLocalChams or settings.RGBModeTracer or settings.RGBModeSkeleton or settings.RGBModeHead or settings.RGBModeIndicators or settings.RGBModeName or settings.RGBModeHPText or settings.RGBModeDistance or settings.RGBModeState or settings.RGBModeHealthBar then
            table.insert(activeFeatures, "RGB ACTIVE")
        end
    end

    local totalInd = #activeFeatures
    for i = 1, 15 do
        local indText = _G.IndicatorStorage[i]
        if not indText then continue end

        if i <= totalInd and settings.ShowIndicators then
            local feat = activeFeatures[i]
            if settings.IndicatorStyle == "Gamesense" then indText.Text = string.lower(feat); indText.Font = 2; indText.Size = 13
            elseif settings.IndicatorStyle == "Neverlose" then indText.Text = "nl ~ " .. string.lower(feat); indText.Font = 3; indText.Size = 16
            else indText.Text = feat; indText.Font = 2; indText.Size = 18 end

            indText.Color = settings.IndicatorColor
            indText.Outline = true
            local posX, posY = 20, 20
            local spacing = indText.Size + 2
            local padding = 15

            if string.find(settings.IndicatorPosition, "Top") then posY = padding + (i-1) * spacing
            elseif string.find(settings.IndicatorPosition, "Center") then posY = (viewportSize.Y / 2) - ((totalInd * spacing) / 2) + (i-1) * spacing
            elseif string.find(settings.IndicatorPosition, "Bottom") then posY = viewportSize.Y - padding - (totalInd * spacing) + (i-1) * spacing end

            if string.find(settings.IndicatorPosition, "Left") then posX = padding
            elseif string.find(settings.IndicatorPosition, "Right") then posX = viewportSize.X - padding - indText.TextBounds.X end
            
            indText.Position = Vector2.new(posX, posY); indText.Visible = true
        else
            indText.Visible = false
        end
    end
end

if _G.ESP_Connection then _G.ESP_Connection:Disconnect() end
_G.ESP_Connection = RunService.RenderStepped:Connect(updateESP)

-- ==================== ИНТЕРФЕЙС RAYFIELD ====================
local RayfieldLib, Rayfield = pcall(function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end)
if not RayfieldLib or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "ESP Hub (Solara Fixed)", LoadingTitle = "Loading...", LoadingSubtitle = "by Script Rewriter",
    ConfigurationSaving = { Enabled = false }, Discord = { Enabled = false }, KeySystem = false,
    Keybind = Enum.KeyCode.Insert
})

-- Вкладка 0: Aim
local AimTab = Window:CreateTab("Aim", 4483362458)
AimTab:CreateSection("Aimbot Modes")
AimTab:CreateToggle({ Name = "Enable Aim Lock", CurrentValue = s.AimLockEnabled, Callback = function(Value) s.AimLockEnabled = Value end })

AimTab:CreateSection("Target Settings")
AimTab:CreateDropdown({
    Name = "Aim Key", Options = {"RightClick", "LeftClick", "Q", "E", "C", "F", "LeftShift", "LeftAlt"}, Default = s.AimLockKey,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.AimLockKey = Value end
})
AimTab:CreateSlider({ Name = "Aim Smoothness (Lock Only)", Range = {1, 100}, Increment = 1, CurrentValue = s.AimSmoothness, Callback = function(Value) s.AimSmoothness = Value end })

AimTab:CreateSection("FOV Settings")
AimTab:CreateToggle({ Name = "Use FOV Mode", CurrentValue = s.AimFOVEnabled, Callback = function(Value) s.AimFOVEnabled = Value end })
AimTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = s.ShowAimFOV, Callback = function(Value) s.ShowAimFOV = Value end })
AimTab:CreateSlider({ Name = "FOV Radius", Range = {10, 800}, Increment = 1, CurrentValue = s.AimFOVRadius, Callback = function(Value) s.AimFOVRadius = Value end })
AimTab:CreateColorPicker({ Name = "FOV Circle Color", Color = s.AimFOVColor, Callback = function(Value) s.AimFOVColor = Value end })

AimTab:CreateSection("Visuals")
AimTab:CreateToggle({ Name = "Show Target Line", CurrentValue = s.ShowAimTarget, Callback = function(Value) s.ShowAimTarget = Value end })
AimTab:CreateColorPicker({ Name = "Target Line Color", Color = s.AimTargetColor, Callback = function(Value) s.AimTargetColor = Value end })

-- Вкладка 1: ESP Toggles
local ESPTab = Window:CreateTab("ESP Toggles", 4483362458)
ESPTab:CreateSection("Main ESP")
ESPTab:CreateToggle({ Name = "Enable ESP", CurrentValue = s.Enabled, Callback = function(Value) s.Enabled = Value; _G.ESP_Enabled = Value end })
ESPTab:CreateToggle({ Name = "Show Box", CurrentValue = s.ShowBox, Callback = function(Value) s.ShowBox = Value end })
ESPTab:CreateToggle({ Name = "Show Shadow", CurrentValue = s.ShowShadow, Callback = function(Value) s.ShowShadow = Value end })
ESPTab:CreateToggle({ Name = "Show Tracer", CurrentValue = s.ShowTracer, Callback = function(Value) s.ShowTracer = Value end })
ESPTab:CreateToggle({ Name = "Show Skeleton", CurrentValue = s.ShowSkeleton, Callback = function(Value) s.ShowSkeleton = Value end })
ESPTab:CreateToggle({ Name = "Show Head", CurrentValue = s.ShowHead, Callback = function(Value) s.ShowHead = Value end })

ESPTab:CreateSection("Info ESP")
ESPTab:CreateToggle({ Name = "Show Name", CurrentValue = s.ShowName, Callback = function(Value) s.ShowName = Value end })
ESPTab:CreateToggle({ Name = "Show HP Text", CurrentValue = s.ShowHealth, Callback = function(Value) s.ShowHealth = Value end })
ESPTab:CreateToggle({ Name = "Show Distance", CurrentValue = s.ShowDistance, Callback = function(Value) s.ShowDistance = Value end })
ESPTab:CreateToggle({ Name = "Show State (Air/Run/Crouch)", CurrentValue = s.ShowState, Callback = function(Value) s.ShowState = Value end })
ESPTab:CreateToggle({ Name = "Show Health Bar", CurrentValue = s.ShowHealthBar, Callback = function(Value) s.ShowHealthBar = Value end })

-- Вкладка 2: ESP Settings
local SettingsTab = Window:CreateTab("ESP Settings", 4483362458)
SettingsTab:CreateSection("Styles & Positions")
SettingsTab:CreateDropdown({
    Name = "Box Style", Options = {"Outline", "Filled", "Corners", "3D Box"}, Default = s.BoxStyle,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.BoxStyle = Value; for _, esp in pairs(_G.ESP_Storage) do hideAllBoxStyles(esp) end end
})
SettingsTab:CreateDropdown({
    Name = "ESP Text Style", Options = {"Normal", "Gamesense", "Neverlose"}, Default = s.TextStyle,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.TextStyle = Value end
})
SettingsTab:CreateDropdown({
    Name = "Tracer Style", Options = {"Bottom", "Center", "Mouse"}, Default = s.TracerStyle,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.TracerStyle = Value end
})
SettingsTab:CreateDropdown({
    Name = "Health Bar Position", Options = {"Left", "Right", "Top", "Bottom"}, Default = s.HealthBarPosition,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.HealthBarPosition = Value end
})
SettingsTab:CreateDropdown({
    Name = "Distance Position", Options = {"Top", "Bottom", "Left", "Right"}, Default = s.DistancePosition,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.DistancePosition = Value end
})
SettingsTab:CreateDropdown({
    Name = "State Position", Options = {"Top", "Bottom", "Left", "Right"}, Default = s.StatePosition,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.StatePosition = Value end
})

SettingsTab:CreateSection("Text Sizes")
SettingsTab:CreateSlider({ Name = "Name/HP Text Size", Range = {8, 30}, Increment = 1, CurrentValue = s.NameSize, Callback = function(Value) s.NameSize = Value end })
SettingsTab:CreateSlider({ Name = "Distance Size", Range = {8, 30}, Increment = 1, CurrentValue = s.DistanceSize, Callback = function(Value) s.DistanceSize = Value end })
SettingsTab:CreateSlider({ Name = "State Size", Range = {8, 30}, Increment = 1, CurrentValue = s.StateSize, Callback = function(Value) s.StateSize = Value end })

SettingsTab:CreateSection("RGB Modes")
SettingsTab:CreateToggle({ Name = "RGB Mode (Box)", CurrentValue = s.RGBMode, Callback = function(Value) s.RGBMode = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (Tracer)", CurrentValue = s.RGBModeTracer, Callback = function(Value) s.RGBModeTracer = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (Skeleton)", CurrentValue = s.RGBModeSkeleton, Callback = function(Value) s.RGBModeSkeleton = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (Head)", CurrentValue = s.RGBModeHead, Callback = function(Value) s.RGBModeHead = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (Health Bar)", CurrentValue = s.RGBModeHealthBar, Callback = function(Value) s.RGBModeHealthBar = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (Name Text)", CurrentValue = s.RGBModeName, Callback = function(Value) s.RGBModeName = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (HP Text)", CurrentValue = s.RGBModeHPText, Callback = function(Value) s.RGBModeHPText = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (Distance)", CurrentValue = s.RGBModeDistance, Callback = function(Value) s.RGBModeDistance = Value end })
SettingsTab:CreateToggle({ Name = "RGB Mode (State)", CurrentValue = s.RGBModeState, Callback = function(Value) s.RGBModeState = Value end })

SettingsTab:CreateSection("Colors")
SettingsTab:CreateColorPicker({ Name = "Box Color", Color = s.BoxColor, Callback = function(Value) s.BoxColor = Value end })
SettingsTab:CreateColorPicker({ Name = "Tracer Color", Color = s.TracerColor, Callback = function(Value) s.TracerColor = Value end })
SettingsTab:CreateColorPicker({ Name = "Skeleton Color", Color = s.SkeletonColor, Callback = function(Value) s.SkeletonColor = Value end })
SettingsTab:CreateColorPicker({ Name = "Head Color", Color = s.HeadColor, Callback = function(Value) s.HeadColor = Value end })
SettingsTab:CreateColorPicker({ Name = "Health Bar Color", Color = s.HealthBarColor, Callback = function(Value) s.HealthBarColor = Value end })
SettingsTab:CreateColorPicker({ Name = "Name Text Color", Color = s.NameColor, Callback = function(Value) s.NameColor = Value end })
SettingsTab:CreateColorPicker({ Name = "HP Text Color", Color = s.HPTextColor, Callback = function(Value) s.HPTextColor = Value end })
SettingsTab:CreateColorPicker({ Name = "Distance Color", Color = s.DistanceColor, Callback = function(Value) s.DistanceColor = Value end })
SettingsTab:CreateColorPicker({ Name = "State Color", Color = s.StateColor, Callback = function(Value) s.StateColor = Value end })

-- Вкладка 3: CHAMS
local ChamsTab = Window:CreateTab("Chams", 4483362458)
ChamsTab:CreateSection("Enemy Chams")
ChamsTab:CreateToggle({ Name = "Enable Enemy Chams", CurrentValue = s.ShowChams, Callback = function(Value) s.ShowChams = Value end })
ChamsTab:CreateToggle({ Name = "Chams Through Walls", CurrentValue = s.ChamsThroughWalls, Callback = function(Value) s.ChamsThroughWalls = Value end })
ChamsTab:CreateDropdown({
    Name = "Chams Material", Options = {"Neon", "ForceField", "Plastic", "Glass", "Ice", "Foil", "Wood", "Slate"}, Default = s.ChamsMaterial,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.ChamsMaterial = Value end
})
ChamsTab:CreateToggle({ Name = "RGB Mode (Chams)", CurrentValue = s.RGBModeChams, Callback = function(Value) s.RGBModeChams = Value end })
ChamsTab:CreateColorPicker({ Name = "Chams Color", Color = s.ChamsColor, Callback = function(Value) s.ChamsColor = Value end })

-- Вкладка 4: Indicators
local IndicatorsTab = Window:CreateTab("Indicators", 4483362458)
IndicatorsTab:CreateSection("Screen Indicators Settings")
IndicatorsTab:CreateToggle({ Name = "Show Active Indicators", CurrentValue = s.ShowIndicators, Callback = function(Value) s.ShowIndicators = Value end })

IndicatorsTab:CreateDropdown({
    Name = "Indicators Style", Options = {"Normal", "Gamesense", "Neverlose"}, Default = s.IndicatorStyle,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.IndicatorStyle = Value end
})

IndicatorsTab:CreateDropdown({
    Name = "Indicators Position", Options = {"Top Left", "Center Left", "Bottom Left", "Top Right", "Center Right", "Bottom Right"}, Default = s.IndicatorPosition,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.IndicatorPosition = Value end
})
IndicatorsTab:CreateToggle({ Name = "RGB Mode (Indicators)", CurrentValue = s.RGBModeIndicators, Callback = function(Value) s.RGBModeIndicators = Value end })
IndicatorsTab:CreateColorPicker({ Name = "Indicators Color", Color = s.IndicatorColor, Callback = function(Value) s.IndicatorColor = Value end })

-- Вкладка 5: Local
local LocalTab = Window:CreateTab("Local", 4483362458)
LocalTab:CreateSection("Local Player Chams")
LocalTab:CreateToggle({ Name = "Enable Local Chams", CurrentValue = s.ShowLocalChams, Callback = function(Value) s.ShowLocalChams = Value end })
LocalTab:CreateDropdown({
    Name = "Local Chams Material", Options = {"Neon", "ForceField", "Plastic", "Glass", "Ice", "Foil", "Wood", "Slate"}, Default = s.LocalChamsMaterial,
    Callback = function(Value) if type(Value) == "table" then Value = Value[1] end; s.LocalChamsMaterial = Value end
})
LocalTab:CreateToggle({ Name = "RGB Mode (Local Chams)", CurrentValue = s.RGBModeLocalChams, Callback = function(Value) s.RGBModeLocalChams = Value end })
LocalTab:CreateColorPicker({ Name = "Local Chams Color", Color = s.LocalChamsColor, Callback = function(Value) s.LocalChamsColor = Value end })

LocalTab:CreateSection("Camera View")
LocalTab:CreateToggle({ Name = "Override FOV", CurrentValue = s.OverrideFOV, Callback = function(Value) s.OverrideFOV = Value end })
LocalTab:CreateSlider({ Name = "Field of View (FOV)", Range = {30, 120}, Increment = 1, Suffix = "°", CurrentValue = s.FOVValue, Callback = function(Value) s.FOVValue = Value end })

-- Вкладка 6: WORLD
local WorldTab = Window:CreateTab("World", 4483362458)
WorldTab:CreateSection("Lighting & Shadows")
WorldTab:CreateSlider({ Name = "Time of Day", Range = {0, 24}, Increment = 1, Suffix = "h", CurrentValue = Lighting.ClockTime, Callback = function(Value) Lighting.ClockTime = Value end })
WorldTab:CreateSlider({ Name = "Brightness", Range = {0, 10}, Increment = 1, CurrentValue = Lighting.Brightness, Callback = function(Value) Lighting.Brightness = Value end })
WorldTab:CreateToggle({ Name = "Global Shadows", CurrentValue = Lighting.GlobalShadows, Callback = function(Value) Lighting.GlobalShadows = Value end })

WorldTab:CreateSection("Ambient Colors")
WorldTab:CreateColorPicker({ Name = "Ambient Color", Color = Lighting.Ambient, Callback = function(Value) Lighting.Ambient = Value end })
WorldTab:CreateColorPicker({ Name = "Outdoor Ambient Color", Color = Lighting.OutdoorAmbient, Callback = function(Value) Lighting.OutdoorAmbient = Value end })