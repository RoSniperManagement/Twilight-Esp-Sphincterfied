-- Twilight ESP Modded v2.1 - Unified Single Script
-- Compatible with Sphincter UI


local TwilightESP = {}

-- Services (cloneref for safety)
local cloneref = cloneref or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Camera = cloneref(workspace.CurrentCamera)
local LocalPlayer = Players.LocalPlayer

-- Core Tables
TwilightESP.Settings = {
    Enabled = false,
    MaxDistance = 2000,
    RefreshRate = 1 / 60,  -- Inverse FPS for rate limiting
    Checks = {
        Team = {Enabled = false},
        Visible = {Enabled = false, OnlyVisible = false, Recolor = true},  -- Recolor for chams through/not through walls
    },
    Box = {
        Enabled = false,
        Style = 1,  -- 1: Corners (with 2 strokes), 2: Full Box (with 2 strokes + optional fill)
        InnerThickness = 2,  -- Inner fill stroke thickness
        OutlineThickness = 1,  -- Outer border stroke thickness
        Filled = {Enabled = false, Transparency = 0.5},  -- Only for full box
    },
    Tracer = {
        Enabled = {enemy = false, friendly = false, generic = false},
        Thickness = 1,
        Origin = 2,  -- 1: Local pos, 2: Bottom center, 3: Top center, 4: Screen center, 5: Mouse
    },
    Name = {
        Enabled = {enemy = false, friendly = false, generic = false},
        Style = 1,  -- 1: DisplayName, 2: Username
    },
    HealthBar = {
        Enabled = {enemy = false, friendly = false, generic = false},
        Bar = true,
        Text = false,
        Suffix = " HP",
        Padding = 1,  -- Space inside outline
    },
    Skeleton = {
        Enabled = {enemy = false, friendly = false, generic = false},
        InnerThickness = 1,
        OutlineThickness = 1,
        Transparency = 1,
    },
    Chams = {
        Enabled = {enemy = false, friendly = false, generic = false},
        Fill = {Enabled = true, Transparency = 0.5},
        Outline = {Enabled = true, Transparency = 0},
        Occlusion = false,  -- false: AlwaysOnTop (show through walls), true: Occluded (hide behind walls)
    },
    Radar = {
        Enabled = true,
        Scale = 1,
        Radius = 100,
        Position = Vector2.new(50, 50),  -- Default top-left, draggable with right-click hold
    },
    TextSize = 14,
}

TwilightESP.currentColors = {
    enemy = {
        Box = {
            Outline = {Visible = Color3.fromRGB(255, 0, 0), Invisible = Color3.fromRGB(255, 50, 50)},
            Fill = Color3.fromRGB(255, 0, 0),  -- New: Fill color for box (alpha via transparency)
        },
        Tracer = {Visible = Color3.fromRGB(255, 0, 0), Invisible = Color3.fromRGB(255, 50, 50)},
        Text = Color3.fromRGB(255, 255, 255),
        Skeleton = {
            Visible = Color3.fromRGB(255, 0, 0),
            Fill = Color3.fromRGB(255, 0, 0),  -- New: Inner fill for bones
            Outline = Color3.fromRGB(255, 255, 255),  -- New: Outer border for bones
        },
        HealthBar = {
            Outline = Color3.fromRGB(0, 0, 0),
            Fills = {High = Color3.fromRGB(0, 255, 0), Medium = Color3.fromRGB(255, 255, 0), Low = Color3.fromRGB(255, 0, 0)},
        },
        Chams = {
            Fill = {Visible = Color3.fromRGB(0, 255, 0), Invisible = Color3.fromRGB(255, 0, 0)},  -- Green when visible, Red through walls
            Outline = {Visible = Color3.fromRGB(0, 200, 0), Invisible = Color3.fromRGB(200, 0, 0)},  -- Dark green outline visible, dark red through walls
        },
    },
    friendly = {
        Box = {
            Outline = {Visible = Color3.fromRGB(0, 255, 0), Invisible = Color3.fromRGB(50, 255, 50)},
            Fill = Color3.fromRGB(0, 255, 0),
        },
        Tracer = {Visible = Color3.fromRGB(0, 255, 0), Invisible = Color3.fromRGB(50, 255, 50)},
        Text = Color3.fromRGB(255, 255, 255),
        Skeleton = {
            Visible = Color3.fromRGB(0, 255, 0),
            Fill = Color3.fromRGB(0, 255, 0),
            Outline = Color3.fromRGB(255, 255, 255),
        },
        HealthBar = {
            Outline = Color3.fromRGB(0, 0, 0),
            Fills = {High = Color3.fromRGB(0, 255, 0), Medium = Color3.fromRGB(255, 255, 0), Low = Color3.fromRGB(255, 0, 0)},
        },
        Chams = {
            Fill = {Visible = Color3.fromRGB(0, 255, 0), Invisible = Color3.fromRGB(0, 100, 0)},  -- Bright green visible, dimmer through walls
            Outline = {Visible = Color3.fromRGB(0, 200, 0), Invisible = Color3.fromRGB(0, 100, 0)},
        },
    },
    generic = {
        Box = {
            Outline = {Visible = Color3.fromRGB(255, 255, 255), Invisible = Color3.fromRGB(200, 200, 200)},
            Fill = Color3.fromRGB(255, 255, 255),
        },
        Tracer = {Visible = Color3.fromRGB(255, 255, 255), Invisible = Color3.fromRGB(200, 200, 200)},
        Text = Color3.fromRGB(255, 255, 255),
        Skeleton = {
            Visible = Color3.fromRGB(255, 255, 255),
            Fill = Color3.fromRGB(255, 255, 255),
            Outline = Color3.fromRGB(0, 0, 0),
        },
        HealthBar = {
            Outline = Color3.fromRGB(0, 0, 0),
            Fills = {High = Color3.fromRGB(0, 255, 0), Medium = Color3.fromRGB(255, 255, 0), Low = Color3.fromRGB(255, 0, 0)},
        },
        Chams = {
            Fill = {Visible = Color3.fromRGB(255, 255, 255), Invisible = Color3.fromRGB(100, 100, 100)},  -- White visible, gray through walls
            Outline = {Visible = Color3.fromRGB(200, 200, 200), Invisible = Color3.fromRGB(100, 100, 100)},
        },
    },
    Radar = {
        Background = Color3.fromRGB(5, 5, 5),
        Border = Color3.fromRGB(35, 35, 35),
    },
}

-- Internal Tables
local connections = {}
local Drawings = {ESP = {}, Skeleton = {}, Radar = {}, Object = {}}
TwilightESP.Highlights = {}  -- Now {los=Highlight, occ=Highlight} per player
TwilightESP.ChamsModels = {}  -- player -> Model
TwilightESP.ObjectESPs = {ESPs = {}, Highlights = {}}

-- Utilities
local utilities = {}

function utilities.GetTracerOrigin(library)
    local origin = library.Settings.Tracer.Origin
    local viewSize = Camera.ViewportSize
    if origin == 1 then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local v3 = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            return Vector2.new(v3.X, v3.Y)
        end
    elseif origin == 2 then
        return Vector2.new(viewSize.X / 2, viewSize.Y)
    elseif origin == 3 then
        return Vector2.new(viewSize.X / 2, 0)
    elseif origin == 4 then
        return Vector2.new(viewSize.X / 2, viewSize.Y / 2)
    elseif origin == 5 then
        return UserInputService:GetMouseLocation()
    end
    return Vector2.new(viewSize.X / 2, viewSize.Y / 2)  -- Default
end

function utilities.GetPlayerType(player)
    if player.Neutral then return "generic" end
    if player == LocalPlayer then return "friendly" end  -- Treat local as friendly for colors
    if player.Team and LocalPlayer.Team and player.TeamColor == LocalPlayer.TeamColor then return "friendly" end
    return "enemy"
end

function utilities.GetPlayerColor(library, player, isVisible, part, additional)
    local teamType = utilities.GetPlayerType(player)
    local colors = library.currentColors[teamType]
    local recolor = library.Settings.Checks.Visible.Enabled and not isVisible and library.Settings.Checks.Visible.Recolor
    local visKey = recolor and "Invisible" or "Visible"

    if part == "Box" then
        if additional == "Outline" then
            return colors.Box.Outline[visKey]
        elseif additional == "Fill" then
            return colors.Box.Fill
        end
    elseif part == "Skeleton" then
        if additional == "Fill" then
            return colors.Skeleton.Fill
        elseif additional == "Outline" then
            return colors.Skeleton.Outline
        else
            return colors.Skeleton[visKey]
        end
    elseif part == "Tracer" or part == "Text" then
        return colors[part][visKey]
    elseif part == "HealthBar" then
        if additional == "Outline" then
            return colors.HealthBar.Outline
        elseif additional == "Fill" then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local percent = hum.Health / hum.MaxHealth
                    local status = percent > 0.6 and "High" or (percent > 0.2 and "Medium" or "Low")
                    return colors.HealthBar.Fills[status]
                end
            end
            return colors.HealthBar.Fills.High  -- Default full
        end
    elseif part == "Chams" then
        if additional == "Fill" or additional == "Outline" then
            local sub = additional == "Fill" and colors.Chams.Fill or colors.Chams.Outline
            return sub[visKey]
        end
    end
    return Color3.fromRGB(255, 255, 255)  -- Fallback
end

-- Thick Line Drawing Helper (returns {fillLine, outLine1, outLine2})
local function createThickLine()
    local fill = Drawing.new("Line")
    fill.Transparency = 1
    local out1 = Drawing.new("Line")
    out1.Transparency = 1
    local out2 = Drawing.new("Line")
    out2.Transparency = 1
    return {fill = fill, out1 = out1, out2 = out2}
end

local function updateThickLine(segment, from, to, fillCol, outCol, innerThick, outThick)
    if not from or not to then
        segment.fill.Visible = false
        segment.out1.Visible = false
        segment.out2.Visible = false
        return
    end
    local dir = (to - from).Unit
    local perp = Vector2.new(-dir.Y, dir.X)
    local offset = (innerThick / 2) + (outThick / 2)

    -- Fill
    segment.fill.From = from
    segment.fill.To = to
    segment.fill.Color = fillCol
    segment.fill.Thickness = innerThick
    segment.fill.Visible = true

    -- Outlines
    local o1From = from + perp * offset
    local o1To = to + perp * offset
    segment.out1.From = o1From
    segment.out1.To = o1To
    segment.out1.Color = outCol
    segment.out1.Thickness = outThick
    segment.out1.Visible = true

    local o2From = from - perp * offset
    local o2To = to - perp * offset
    segment.out2.From = o2From
    segment.out2.To = o2To
    segment.out2.Color = outCol
    segment.out2.Thickness = outThick
    segment.out2.Visible = true
end

local function removeThickLine(segment)
    pcall(function()
        segment.fill:Remove()
        segment.out1:Remove()
        segment.out2:Remove()
    end)
end

-- Chams Setup
local function setupChams(library, player, char)
    -- Cleanup old
    local oldModel = library.ChamsModels[player]
    if oldModel then
        oldModel:Destroy()
    end
    local oldHighlights = library.Highlights[player]
    if oldHighlights then
        if oldHighlights.los then oldHighlights.los:Destroy() end
        if oldHighlights.occ then oldHighlights.occ:Destroy() end
    end

    -- Create cloned model
    local chamsChr = Instance.new("Model")
    chamsChr.Parent = workspace
    chamsChr.Name = player.Name .. "_Chams"
    library.ChamsModels[player] = chamsChr

    for _, child in pairs(char:GetChildren()) do
        if not child:IsA("BasePart") then continue end
        local cloned = child:Clone()
        cloned.Parent = chamsChr
        cloned:ClearAllChildren()
        cloned.CanCollide = false
        if cloned:IsA("MeshPart") then cloned.TextureID = "" end
        cloned.Size = cloned.Size * 0.99  -- Anti z-fighting
        local weld = Instance.new("WeldConstraint")
        weld.Parent = cloned
        weld.Part0 = cloned
        weld.Part1 = child
    end

    -- LOS Highlight (on original char)
    local losHighlight = Instance.new("Highlight")
    losHighlight.Parent = char
    losHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    losHighlight.OutlineTransparency = 1  -- As per example

    -- OCC Highlight (on clone)
    local occHighlight = Instance.new("Highlight")
    occHighlight.Parent = chamsChr
    occHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    library.Highlights[player] = {los = losHighlight, occ = occHighlight}
end

-- Player ESP Module
local playerEsp = {}

function playerEsp.CreateESP(library, player)
    local esp = {}

    -- Box Segments (8 for corners, 4 for full)
    esp.Box = {Segments = {}}
    for i = 1, 8 do  -- Max for corners
        table.insert(esp.Box.Segments, createThickLine())
    end
    esp.Box.FilledQuad = nil  -- For full box fill

    -- Tracer
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Transparency = 1
    esp.Tracer.Thickness = library.Settings.Tracer.Thickness

    -- HealthBar
    esp.HealthBar = {
        Outline = Drawing.new("Square"),
        Fill = Drawing.new("Square"),
        Text = Drawing.new("Text"),
    }
    esp.HealthBar.Outline.Filled = false
    esp.HealthBar.Outline.Thickness = 1
    esp.HealthBar.Outline.Transparency = 1
    esp.HealthBar.Fill.Filled = true
    esp.HealthBar.Fill.Transparency = 1
    esp.HealthBar.Text.Center = true
    esp.HealthBar.Text.Size = library.Settings.TextSize
    esp.HealthBar.Text.Font = 2
    esp.HealthBar.Text.Outline = true
    esp.HealthBar.Text.Transparency = 1

    -- Info
    esp.Info = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
    }
    for _, text in pairs(esp.Info) do
        text.Center = true
        text.Size = library.Settings.TextSize
        text.Font = 2
        text.Outline = true
        text.Transparency = 1
    end

    -- Snapline (simple, no thick)
    esp.Snapline = Drawing.new("Line")
    esp.Snapline.Transparency = 1
    esp.Snapline.Thickness = 1

    -- Skeleton Segments (~20 bones)
    esp.Skeleton = {}
    local boneNames = {"Head", "Neck", "UpperSpine", "LowerSpine", "LeftShoulder", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightShoulder", "RightUpperArm", "RightLowerArm", "RightHand", "LeftHip", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightHip", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    for _, bone in ipairs(boneNames) do
        esp.Skeleton[bone] = createThickLine()
    end

    library.Drawings.ESP[player] = esp
end

function playerEsp.RemoveESP(library, player)
    local esp = library.Drawings.ESP[player]
    if not esp then return end

    -- Box
    for _, seg in ipairs(esp.Box.Segments) do
        removeThickLine(seg)
    end
    if esp.Box.FilledQuad then
        pcall(esp.Box.FilledQuad.Remove, esp.Box.FilledQuad)
    end

    -- Other drawings
    pcall(esp.Tracer.Remove, esp.Tracer)
    for _, obj in pairs(esp.HealthBar) do
        pcall(obj.Remove, obj)
    end
    for _, text in pairs(esp.Info) do
        pcall(text.Remove, text)
    end
    pcall(esp.Snapline.Remove, esp.Snapline)

    -- Skeleton
    for _, seg in pairs(esp.Skeleton) do
        removeThickLine(seg)
    end

    library.Drawings.ESP[player] = nil

    -- Chams cleanup
    local chamsModel = library.ChamsModels[player]
    if chamsModel then
        chamsModel:Destroy()
        library.ChamsModels[player] = nil
    end
    local highlights = library.Highlights[player]
    if highlights then
        if highlights.los then highlights.los:Destroy() end
        if highlights.occ then highlights.occ:Destroy() end
        library.Highlights[player] = nil
    end
end

function playerEsp.UpdateESP(library, player)
    local esp = library.Drawings.ESP[player]
    if not esp then return end

    if not library.Settings.Enabled then
        -- Hide all
        for _, seg in ipairs(esp.Box.Segments) do
            seg.fill.Visible = false
            seg.out1.Visible = false
            seg.out2.Visible = false
        end
        esp.Tracer.Visible = false
        for _, obj in pairs(esp.HealthBar) do
            obj.Visible = false
        end
        for _, text in pairs(esp.Info) do
            text.Visible = false
        end
        esp.Snapline.Visible = false
        for _, seg in pairs(esp.Skeleton) do
            seg.fill.Visible = false
            seg.out1.Visible = false
            seg.out2.Visible = false
        end
        -- Chams disable
        local highlights = library.Highlights[player]
        if highlights then
            highlights.los.Enabled = false
            highlights.occ.Enabled = false
        end
        return
    end

    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid or humanoid.Health <= 0 then return end

    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > library.Settings.MaxDistance or not onScreen then return end

    local teamType = utilities.GetPlayerType(player)
    local isVisible = true
    if library.Settings.Checks.Visible.Enabled then
        isVisible = #Camera:GetPartsObscuringTarget({Camera.CFrame.Position, rootPart.Position}, {rootPart}) == 0
        if library.Settings.Checks.Visible.OnlyVisible and not isVisible then return end
    end

    if library.Settings.Checks.Team.Enabled and library.Settings.Checks.Team[teamType] ~= true then return end

    -- Box Calculation
    local head = character:FindFirstChild("Head")
    if not head then return end
    local headPos = Camera:WorldToViewportPoint(head.Position)
    local footPos = Camera:WorldToViewportPoint(rootPart.Position)
    local boxHeight = math.abs(footPos.Y - headPos.Y)
    local boxWidth = boxHeight * 0.5
    local boxPosition = Vector2.new(pos.X - boxWidth / 2, headPos.Y)
    local boxSize = Vector2.new(boxWidth, boxHeight)

    local boxFillCol = utilities.GetPlayerColor(library, player, isVisible, "Box", "Fill")
    local boxOutCol = utilities.GetPlayerColor(library, player, isVisible, "Box", "Outline")
    local innerThick = library.Settings.Box.InnerThickness
    local outThick = library.Settings.Box.OutlineThickness
    local cornerSize = math.min(boxWidth, boxHeight) * 0.2

    if library.Settings.Box.Enabled then
        local segments = esp.Box.Segments
        if library.Settings.Box.Style == 1 then  -- Corners
            -- Top Left H/V
            updateThickLine(segments[1], boxPosition, boxPosition + Vector2.new(cornerSize, 0), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[2], boxPosition, boxPosition + Vector2.new(0, cornerSize), boxFillCol, boxOutCol, innerThick, outThick)
            -- Top Right H/V
            updateThickLine(segments[3], boxPosition + Vector2.new(boxWidth, 0), boxPosition + Vector2.new(boxWidth - cornerSize, 0), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[4], boxPosition + Vector2.new(boxWidth, 0), boxPosition + Vector2.new(boxWidth, cornerSize), boxFillCol, boxOutCol, innerThick, outThick)
            -- Bottom Left H/V
            updateThickLine(segments[5], boxPosition + Vector2.new(0, boxHeight), boxPosition + Vector2.new(cornerSize, boxHeight), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[6], boxPosition + Vector2.new(0, boxHeight), boxPosition + Vector2.new(0, boxHeight - cornerSize), boxFillCol, boxOutCol, innerThick, outThick)
            -- Bottom Right H/V
            updateThickLine(segments[7], boxPosition + Vector2.new(boxWidth, boxHeight), boxPosition + Vector2.new(boxWidth - cornerSize, boxHeight), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[8], boxPosition + Vector2.new(boxWidth, boxHeight), boxPosition + Vector2.new(boxWidth, boxHeight - cornerSize), boxFillCol, boxOutCol, innerThick, outThick)
        else  -- Full Box
            -- Left/Right/Top/Bottom
            updateThickLine(segments[1], boxPosition, boxPosition + Vector2.new(0, boxHeight), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[2], boxPosition + Vector2.new(boxWidth, 0), boxPosition + Vector2.new(boxWidth, boxHeight), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[3], boxPosition, boxPosition + Vector2.new(boxWidth, 0), boxFillCol, boxOutCol, innerThick, outThick)
            updateThickLine(segments[4], boxPosition + Vector2.new(0, boxHeight), boxPosition + Vector2.new(boxWidth, boxHeight), boxFillCol, boxOutCol, innerThick, outThick)

            -- Fill
            if library.Settings.Box.Filled.Enabled and not esp.Box.FilledQuad then
                esp.Box.FilledQuad = Drawing.new("Quad")
                esp.Box.FilledQuad.Filled = true
            end
            if esp.Box.FilledQuad then
                esp.Box.FilledQuad.Color = boxFillCol
                esp.Box.FilledQuad.Transparency = library.Settings.Box.Filled.Transparency
                esp.Box.FilledQuad.PointA = boxPosition
                esp.Box.FilledQuad.PointB = boxPosition + Vector2.new(boxWidth, 0)
                esp.Box.FilledQuad.PointC = boxPosition + boxSize
                esp.Box.FilledQuad.PointD = boxPosition + Vector2.new(0, boxHeight)
                esp.Box.FilledQuad.Visible = true
            end
        end
    else
        for _, seg in ipairs(esp.Box.Segments) do
            seg.fill.Visible = false
            seg.out1.Visible = false
            seg.out2.Visible = false
        end
        if esp.Box.FilledQuad then esp.Box.FilledQuad.Visible = false end
    end

    -- Tracer
    if library.Settings.Tracer.Enabled[teamType] then
        esp.Tracer.From = utilities.GetTracerOrigin(library)
        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp.Tracer.Color = utilities.GetPlayerColor(library, player, isVisible, "Tracer")
        esp.Tracer.Transparency = 1
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    -- HealthBar
    if library.Settings.HealthBar.Enabled[teamType] then
        local barWidth = 4
        local barHeight = boxHeight
        local barPos = Vector2.new(boxPosition.X - barWidth - 6, boxPosition.Y)
        local pad = library.Settings.HealthBar.Padding
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local fillHeight = (barHeight - 2 * pad) * healthPercent
        local fillCol = utilities.GetPlayerColor(library, player, isVisible, "HealthBar", "Fill")
        local outlineCol = utilities.GetPlayerColor(library, player, isVisible, "HealthBar", "Outline")

        if library.Settings.HealthBar.Bar then
            esp.HealthBar.Outline.Size = Vector2.new(barWidth, barHeight)
            esp.HealthBar.Outline.Position = barPos
            esp.HealthBar.Outline.Color = outlineCol
            esp.HealthBar.Outline.Visible = true

            esp.HealthBar.Fill.Size = Vector2.new(barWidth - 2 * pad, fillHeight)
            esp.HealthBar.Fill.Position = Vector2.new(barPos.X + pad, barPos.Y + barHeight - pad - fillHeight)
            esp.HealthBar.Fill.Color = fillCol
            esp.HealthBar.Fill.Visible = true
        else
            esp.HealthBar.Outline.Visible = false
            esp.HealthBar.Fill.Visible = false
        end

        if library.Settings.HealthBar.Text then
            esp.HealthBar.Text.Text = math.floor(humanoid.Health) .. library.Settings.HealthBar.Suffix
            esp.HealthBar.Text.Position = Vector2.new(barPos.X + barWidth + 4, barPos.Y + barHeight / 2)
            esp.HealthBar.Text.Color = fillCol
            esp.HealthBar.Text.Visible = true
        else
            esp.HealthBar.Text.Visible = false
        end
    else
        for _, obj in pairs(esp.HealthBar) do
            obj.Visible = false
        end
    end

    -- Name
    if library.Settings.Name.Enabled[teamType] then
        esp.Info.Name.Text = library.Settings.Name.Style == 1 and player.DisplayName or player.Name
        esp.Info.Name.Position = Vector2.new(boxPosition.X + boxWidth / 2, boxPosition.Y - 20)
        esp.Info.Name.Color = utilities.GetPlayerColor(library, player, isVisible, "Text")
        esp.Info.Name.Visible = true
    else
        esp.Info.Name.Visible = false
    end

    -- Distance
    local distText = math.floor(distance) .. " studs"
    esp.Info.Distance.Text = distText
    esp.Info.Distance.Position = Vector2.new(boxPosition.X + boxWidth / 2, boxPosition.Y + boxHeight + 2)
    esp.Info.Distance.Color = utilities.GetPlayerColor(library, player, isVisible, "Text")
    esp.Info.Distance.Visible = library.Settings.Name.Enabled[teamType]

    -- Chams
    local highlights = library.Highlights[player]
    if highlights and library.Settings.Chams.Enabled[teamType] then
        -- LOS (Occluded, visible colors)
        local losFillCol = utilities.GetPlayerColor(library, player, true, "Chams", "Fill")
        local losOutCol = utilities.GetPlayerColor(library, player, true, "Chams", "Outline")
        highlights.los.FillColor = losFillCol
        highlights.los.OutlineColor = losOutCol
        highlights.los.FillTransparency = library.Settings.Chams.Fill.Enabled and library.Settings.Chams.Fill.Transparency or 1
        highlights.los.OutlineTransparency = library.Settings.Chams.Outline.Enabled and library.Settings.Chams.Outline.Transparency or 1
        highlights.los.Enabled = true

        -- OCC (AlwaysOnTop, through-wall colors)
        local occFillCol = utilities.GetPlayerColor(library, player, false, "Chams", "Fill")
        local occOutCol = utilities.GetPlayerColor(library, player, false, "Chams", "Outline")
        highlights.occ.FillColor = occFillCol
        highlights.occ.OutlineColor = occOutCol
        highlights.occ.FillTransparency = library.Settings.Chams.Fill.Enabled and library.Settings.Chams.Fill.Transparency or 1
        highlights.occ.OutlineTransparency = library.Settings.Chams.Outline.Enabled and library.Settings.Chams.Outline.Transparency or 1
        highlights.occ.Enabled = not library.Settings.Chams.Occlusion
    elseif highlights then
        highlights.los.Enabled = false
        highlights.occ.Enabled = false
    end

    -- Skeleton
    if library.Settings.Skeleton.Enabled[teamType] then
        local bones = {
            Head = character:FindFirstChild("Head"),
            UpperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
            LowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
            LeftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
            LeftLowerArm = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Forearm"),
            LeftHand = character:FindFirstChild("LeftHand"),
            RightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
            RightLowerArm = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Forearm"),
            RightHand = character:FindFirstChild("RightHand"),
            LeftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
            LeftLowerLeg = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Lower Leg"),
            LeftFoot = character:FindFirstChild("LeftFoot"),
            RightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
            RightLowerLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Lower Leg"),
            RightFoot = character:FindFirstChild("RightFoot"),
        }

        local skelInnerThick = library.Settings.Skeleton.InnerThickness
        local skelOutThick = library.Settings.Skeleton.OutlineThickness
        local skelFillCol = utilities.GetPlayerColor(library, player, isVisible, "Skeleton", "Fill")
        local skelOutCol = utilities.GetPlayerColor(library, player, isVisible, "Skeleton", "Outline")

        local function updateBone(boneFrom, boneTo, seg)
            if not boneFrom or not boneTo then
                seg.fill.Visible = false
                return
            end
            local fromPos3 = boneFrom.CFrame.Position
            local toPos3 = boneTo.CFrame.Position
            local fromScreen, fromVis = Camera:WorldToViewportPoint(fromPos3)
            local toScreen, toVis = Camera:WorldToViewportPoint(toPos3)
            if not (fromVis and toVis) or fromScreen.Z < 0 or toScreen.Z < 0 then
                seg.fill.Visible = false
                return
            end
            local screenBounds = Camera.ViewportSize
            if fromScreen.X < 0 or fromScreen.X > screenBounds.X or fromScreen.Y < 0 or fromScreen.Y > screenBounds.Y or
               toScreen.X < 0 or toScreen.X > screenBounds.X or toScreen.Y < 0 or toScreen.Y > screenBounds.Y then
                seg.fill.Visible = false
                return
            end
            updateThickLine(seg, Vector2.new(fromScreen.X, fromScreen.Y), Vector2.new(toScreen.X, toScreen.Y), skelFillCol, skelOutCol, skelInnerThick, skelOutThick)
            seg.fill.Transparency = library.Settings.Skeleton.Transparency
            seg.out1.Transparency = library.Settings.Skeleton.Transparency
            seg.out2.Transparency = library.Settings.Skeleton.Transparency
        end

        -- Draw bones
        updateBone(bones.Head, bones.UpperTorso, esp.Skeleton.Head)
        updateBone(bones.UpperTorso, bones.LowerTorso, esp.Skeleton.UpperSpine)
        updateBone(bones.LowerTorso, bones.UpperTorso, esp.Skeleton.Neck)
        updateBone(bones.UpperTorso, bones.LeftUpperArm, esp.Skeleton.LeftShoulder)
        updateBone(bones.LeftUpperArm, bones.LeftLowerArm, esp.Skeleton.LeftUpperArm)
        updateBone(bones.LeftLowerArm, bones.LeftHand, esp.Skeleton.LeftLowerArm)
        updateBone(bones.UpperTorso, bones.RightUpperArm, esp.Skeleton.RightShoulder)
        updateBone(bones.RightUpperArm, bones.RightLowerArm, esp.Skeleton.RightUpperArm)
        updateBone(bones.RightLowerArm, bones.RightHand, esp.Skeleton.RightLowerArm)
        updateBone(bones.LowerTorso, bones.LeftUpperLeg, esp.Skeleton.LeftHip)
        updateBone(bones.LeftUpperLeg, bones.LeftLowerLeg, esp.Skeleton.LeftUpperLeg)
        updateBone(bones.LeftLowerLeg, bones.LeftFoot, esp.Skeleton.LeftLowerLeg)
        updateBone(bones.LowerTorso, bones.RightUpperLeg, esp.Skeleton.RightHip)
        updateBone(bones.RightUpperLeg, bones.RightLowerLeg, esp.Skeleton.RightUpperLeg)
        updateBone(bones.RightLowerLeg, bones.RightFoot, esp.Skeleton.RightLowerLeg)
    else
        for _, seg in pairs(esp.Skeleton) do
            seg.fill.Visible = false
            seg.out1.Visible = false
            seg.out2.Visible = false
        end
    end
end

-- Object ESP (simplified, no chams/skeleton for now)
local objectEsp = {}

function objectEsp.CreateESP(library, object)
    local esp = playerEsp.CreateESP(library, {Neutral = true})  -- Reuse player esp structure, no chams
    esp.object = object
    library.ObjectESPs.ESPs[object] = esp
end

function objectEsp.UpdateESP(library, esp)
    local object = esp.object
    if not object or not object.Parent then return end
    -- Reuse player update logic with fake player
    playerEsp.UpdateESP(library, {Character = object, Neutral = true})
end

function objectEsp.RemoveESP(library, object)
    local esp = library.ObjectESPs.ESPs[object]
    if esp then
        -- Reuse remove without chams
        for _, seg in ipairs(esp.Box.Segments) do removeThickLine(seg) end
        if esp.Box.FilledQuad then pcall(esp.Box.FilledQuad.Remove, esp.Box.FilledQuad) end
        pcall(esp.Tracer.Remove, esp.Tracer)
        for _, obj in pairs(esp.HealthBar) do pcall(obj.Remove, obj) end
        for _, text in pairs(esp.Info) do pcall(text.Remove, text) end
        pcall(esp.Snapline.Remove, esp.Snapline)
        for _, seg in pairs(esp.Skeleton) do removeThickLine(seg) end
        library.ObjectESPs.ESPs[object] = nil
    end
end

-- Radar Module
local radar = {}

function radar.Init(library)
    local function DrawCircle(trans, col, rad, filled, thick)
        local circ = Drawing.new("Circle")
        circ.Transparency = trans
        circ.Color = col
        circ.Radius = rad
        circ.NumSides = math.clamp(rad * 55 / 100, 10, 75)
        circ.Filled = filled
        circ.Thickness = thick
        circ.Visible = false
        return circ
    end

    local radarBg = DrawCircle(0.9, library.Settings.currentColors.Radar.Background, library.Settings.Radar.Radius, true, 1)
    local radarBorder = DrawCircle(0.75, library.Settings.currentColors.Radar.Border, library.Settings.Radar.Radius, false, 3)
    local radarDots = {}
    local localDot = nil
    local dragging = false
    local dragStart, mouseStart = Vector2.new(), Vector2.new()

    -- Draggable Radar
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and library.Settings.Radar.Enabled then
            local mousePos = UserInputService:GetMouseLocation()
            local dist = (mousePos - library.Settings.Radar.Position).Magnitude
            if dist < library.Settings.Radar.Radius then
                dragging = true
                dragStart = library.Settings.Radar.Position
                mouseStart = mousePos
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - mouseStart
            library.Settings.Radar.Position = dragStart + delta
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then dragging = false end
    end)

    local function getRelative(pos)
        local char = LocalPlayer.Character
        if char and char.PrimaryPart then
            local camPos = Vector3.new(Camera.CFrame.Position.X, char.PrimaryPart.Position.Y, Camera.CFrame.Position.Z)
            local cf = CFrame.lookAt(char.PrimaryPart.Position, camPos)
            local r = cf:PointToObjectSpace(pos)
            return r.X, r.Z
        end
        return 0, 0
    end

    local function placeDot(plr)
        local dot = DrawCircle(1, Color3.new(1,1,1), 3, true, 1)
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not plr.Parent or not plr.Character or not plr.Character.PrimaryPart or (plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health <= 0) then
                dot.Visible = false
                conn:Disconnect()
                pcall(dot.Remove, dot)
                return
            end
            if not library.Settings.Radar.Enabled then
                dot.Visible = false
                return
            end
            local _, isVis = Camera:WorldToViewportPoint(plr.Character.PrimaryPart.Position)
            local scale = library.Settings.Radar.Scale
            local relX, relZ = getRelative(plr.Character.PrimaryPart.Position)
            local newPos = library.Settings.Radar.Position + Vector2.new(relX * scale, -relZ * scale)
            local center = library.Settings.Radar.Position
            local distToCenter = (newPos - center).Magnitude
            if distToCenter < library.Settings.Radar.Radius - 3 then
                dot.Position = newPos
                dot.Radius = 3
            else
                local dirToCenter = (center - newPos).Unit
                local clampedPos = newPos + dirToCenter * (distToCenter - library.Settings.Radar.Radius + 2)
                dot.Position = clampedPos
                dot.Radius = 2
            end
            dot.Color = utilities.GetPlayerColor(library, plr, isVis, "Box", "Outline")
            dot.Visible = true
        end)
        table.insert(radarDots, {dot = dot, conn = conn, plr = plr})
    end

    local function newLocalDot()
        local tri = Drawing.new("Triangle")
        tri.Filled = true
        tri.Thickness = 1
        tri.Color = Color3.new(1,1,1)
        tri.PointA = library.Settings.Radar.Position + Vector2.new(0, -6)
        tri.PointB = library.Settings.Radar.Position + Vector2.new(-3, 6)
        tri.PointC = library.Settings.Radar.Position + Vector2.new(3, 6)
        tri.Visible = false
        return tri
    end
    localDot = newLocalDot()

    -- Init players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then placeDot(plr) end
    end

    -- Events
    connections.PlayerAdded2 = Players.PlayerAdded:Connect(function(plr)
        if plr ~= LocalPlayer then placeDot(plr) end
        pcall(localDot.Remove, localDot)
        localDot = newLocalDot()
    end)
    connections.PlayerRemoving2 = Players.PlayerRemoving:Connect(function(plr)
        for i = #radarDots, 1, -1 do
            local d = radarDots[i]
            if d.plr == plr then
                d.conn:Disconnect()
                pcall(d.dot.Remove, d.dot)
                table.remove(radarDots, i)
            end
        end
    end)

    -- Radar loop
    connections.RadarLoop = RunService.RenderStepped:Connect(function()
        if not library.Settings.Radar.Enabled then
            radarBg.Visible = false
            radarBorder.Visible = false
            if localDot then localDot.Visible = false end
            for _, d in ipairs(radarDots) do d.dot.Visible = false end
            return
        end
        radarBg.Position = library.Settings.Radar.Position
        radarBg.Radius = library.Settings.Radar.Radius
        radarBg.Color = library.Settings.currentColors.Radar.Background
        radarBg.Visible = true

        radarBorder.Position = library.Settings.Radar.Position
        radarBorder.Radius = library.Settings.Radar.Radius
        radarBorder.Color = library.Settings.currentColors.Radar.Border
        radarBorder.Visible = true

        if localDot then
            localDot.PointA = library.Settings.Radar.Position + Vector2.new(0, -6)
            localDot.PointB = library.Settings.Radar.Position + Vector2.new(-3, 6)
            localDot.PointC = library.Settings.Radar.Position + Vector2.new(3, 6)
            localDot.Color = utilities.GetPlayerColor(library, LocalPlayer, true, "Box", "Outline")
            localDot.Visible = true
        end
    end)

    Drawings.Radar = {radarBg, radarBorder, localDot}
    for _, d in ipairs(radarDots) do table.insert(Drawings.Radar, d.dot) end
end

-- Object Support
function TwilightESP:AddObject(obj)
    objectEsp.CreateESP(self, obj)
end

function TwilightESP:RemoveObject(obj)
    objectEsp.RemoveESP(self, obj)
end

-- Main Init
task.spawn(function()
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character.PrimaryPart

    -- Player setup
    local function initPlayer(player)
        if player == LocalPlayer then return end
        playerEsp.CreateESP(TwilightESP, player)
        player.CharacterAdded:Connect(function(char)
            setupChams(TwilightESP, player, char)
        end)
        if player.Character then
            setupChams(TwilightESP, player, player.Character)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        initPlayer(player)
    end
    connections.PlayerAdded = Players.PlayerAdded:Connect(initPlayer)
    connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        playerEsp.RemoveESP(TwilightESP, player)
    end)

    -- Main loop
    local lastUpdate = 0
    connections.MainLoop = RunService.RenderStepped:Connect(function()
        local now = tick()
        if now - lastUpdate < TwilightESP.Settings.RefreshRate then return end
        lastUpdate = now

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                playerEsp.UpdateESP(TwilightESP, player)
            end
        end

        -- Objects
        for obj, _ in pairs(TwilightESP.ObjectESPs.ESPs) do
            if obj.Parent then
                objectEsp.UpdateESP(TwilightESP, TwilightESP.ObjectESPs.ESPs[obj])
            else
                objectEsp.RemoveESP(TwilightESP, obj)
            end
        end
    end)

    -- Radar
    radar.Init(TwilightESP)
end)

-- Unload
function TwilightESP:Unload()
    for _, conn in pairs(connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    for player, _ in pairs(TwilightESP.Drawings.ESP) do
        playerEsp.RemoveESP(TwilightESP, player)
    end
    for obj, _ in pairs(TwilightESP.ObjectESPs.ESPs) do
        objectEsp.RemoveESP(TwilightESP, obj)
    end
    for _, drawings in pairs(Drawings) do
        for _, d in ipairs(drawings) do
            pcall(d.Remove, d)
        end
    end
    TwilightESP = nil
end

return TwilightESP
