--[[
    NyzeRust v3.9 — Premium macOS Edition
    Premium dark UI • 4 themes • Fixed tabs • First-person aimbot
--]]

-- ============================================================
--  СЕРВИСЫ
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local Stats            = game:GetService("Stats")
local StarterGui       = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local isMobile    = UserInputService.TouchEnabled

-- ============================================================
--  DRAWING CHECK
-- ============================================================
local hasDrawing = pcall(function()
    local t = Drawing.new("Line"); t:Remove(); return true
end)

-- ============================================================
--  ТЕМЫ (4 шт.)
-- ============================================================
local Themes = {
    Midnight = {
        Accent=Color3.fromRGB(150,110,255), AccentHover=Color3.fromRGB(170,130,255), AccentSoft=Color3.fromRGB(80,60,140),
        Background=Color3.fromRGB(12,12,16), Sidebar=Color3.fromRGB(18,18,24), Panel=Color3.fromRGB(22,22,30),
        Card=Color3.fromRGB(28,28,38), CardHover=Color3.fromRGB(38,38,50),
        Text=Color3.fromRGB(240,240,248), TextDim=Color3.fromRGB(150,150,165), TextMuted=Color3.fromRGB(100,100,115),
        Border=Color3.fromRGB(38,38,50), BorderLight=Color3.fromRGB(50,50,66),
        Success=Color3.fromRGB(120,220,140), Danger=Color3.fromRGB(240,90,110), Warning=Color3.fromRGB(250,200,90)
    },
    Obsidian = {
        Accent=Color3.fromRGB(200,200,210), AccentHover=Color3.fromRGB(230,230,240), AccentSoft=Color3.fromRGB(80,80,90),
        Background=Color3.fromRGB(6,6,8), Sidebar=Color3.fromRGB(10,10,12), Panel=Color3.fromRGB(14,14,18),
        Card=Color3.fromRGB(20,20,24), CardHover=Color3.fromRGB(30,30,36),
        Text=Color3.fromRGB(235,235,240), TextDim=Color3.fromRGB(140,140,150), TextMuted=Color3.fromRGB(90,90,100),
        Border=Color3.fromRGB(28,28,34), BorderLight=Color3.fromRGB(42,42,50),
        Success=Color3.fromRGB(120,220,140), Danger=Color3.fromRGB(240,90,110), Warning=Color3.fromRGB(250,200,90)
    },
    RoseQuartz = {
        Accent=Color3.fromRGB(255,130,200), AccentHover=Color3.fromRGB(255,160,220), AccentSoft=Color3.fromRGB(120,60,100),
        Background=Color3.fromRGB(18,12,20), Sidebar=Color3.fromRGB(24,16,26), Panel=Color3.fromRGB(30,20,32),
        Card=Color3.fromRGB(38,26,42), CardHover=Color3.fromRGB(50,34,56),
        Text=Color3.fromRGB(248,235,245), TextDim=Color3.fromRGB(180,155,175), TextMuted=Color3.fromRGB(120,100,120),
        Border=Color3.fromRGB(50,34,56), BorderLight=Color3.fromRGB(68,46,74),
        Success=Color3.fromRGB(140,220,170), Danger=Color3.fromRGB(250,110,140), Warning=Color3.fromRGB(255,200,120)
    },
    Arctic = {
        Accent=Color3.fromRGB(90,180,255), AccentHover=Color3.fromRGB(120,200,255), AccentSoft=Color3.fromRGB(40,80,130),
        Background=Color3.fromRGB(8,12,20), Sidebar=Color3.fromRGB(12,18,28), Panel=Color3.fromRGB(16,24,36),
        Card=Color3.fromRGB(22,32,48), CardHover=Color3.fromRGB(32,46,66),
        Text=Color3.fromRGB(235,244,255), TextDim=Color3.fromRGB(150,170,195), TextMuted=Color3.fromRGB(100,120,145),
        Border=Color3.fromRGB(32,46,66), BorderLight=Color3.fromRGB(46,64,88),
        Success=Color3.fromRGB(120,220,160), Danger=Color3.fromRGB(240,100,120), Warning=Color3.fromRGB(250,210,100)
    }
}
local Colors = Themes.Midnight
local CurrentTheme = "Midnight"

-- ============================================================
--  СОСТОЯНИЕ
-- ============================================================
local State = {
    EspBoxes = false, EspNames = false, EspDist = false,
    EspHP = false, EspHPNum = false, EspInv = false,
    EspInvIcons = false, EspTracers = false, EspSkeleton = false, EspHead = false,
    PlayerEspMaxDist = 800,
    AimEnabled = false, TeamCheck = false, WallCheck = true,
    AimSmooth = 0.08, AimFOV = 120, NoBulletDrop = false,
    AutoShoot = false, AutoShootDelay = 0.05,
    LegitSpeed = false, SpeedMultiplier = 1.5,
    InfJump = false, FreecamEnabled = false, FreecamSpeed = 1,
    FullBright = false, SulfurEsp = false, IronEsp = false,
    StoneEsp = false, NpcEsp = false, CrateEsp = false,
    OreEspMaxDist = 400, NpcEspMaxDist = 600, CrateEspMaxDist = 500,
    XRay = false, LockAutoCode = false,
    ThirdPerson = false, ThirdPersonDist = 15,
    OptLowGFX = false, OptNoEffects = false, OptNoParticles = false,
    OptNoDecals = false, OptNoShadows = false, OptFarParts = false,
    OptLowTerrain = false, OptNoSounds = false, OptRenderDist = 1500,
    FreeMouse = true,
}
_G.NyzeState = State
_G.NyzeBinds = {}

-- ============================================================
--  BLUR
-- ============================================================
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size, Blur.Enabled = 0, true

-- ============================================================
--  GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "NyzeRust_" .. tostring(math.random(1000, 9999))
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent then SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================================
--  ХЕЛПЕРЫ
-- ============================================================
local function new(class, props, parent)
    local o = Instance.new(class)
    if parent then o.Parent = parent end
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    return o
end
local function corner(parent, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, parent)
end
local function stroke(parent, color, thick, trans)
    return new("UIStroke", {
        Color = color or Colors.Border, Thickness = thick or 1,
        Transparency = trans or 0.3,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end
local function padding(parent, px, py)
    local p = new("UIPadding", {}, parent)
    local ux, uy = UDim.new(0, px or 0), UDim.new(0, py or px or 0)
    p.PaddingLeft, p.PaddingRight = ux, ux
    p.PaddingTop, p.PaddingBottom = uy, uy
    return p
end

-- ============================================================
--  РЕЕСТР ДЛЯ СМЕНЫ ТЕМЫ
-- ============================================================
local Themed = {
    frames = {},      -- {inst, kind} — kind: "bg" | "sidebar" | "panel"
    labels = {},      -- {inst, kind} — kind: "text" | "dim" | "muted"
    strokes = {},     -- {inst}
    buttons = {},     -- {inst}
    accents = {},     -- {inst}
    fills = {},       -- fill слайдеров
    knobs = {},       -- knob тоглов
    markers = {},     -- полоски слева тогла
}

local function regFrame(inst, kind) table.insert(Themed.frames, {inst=inst, kind=kind or "panel"}) end
local function regLabel(inst, kind) table.insert(Themed.labels, {inst=inst, kind=kind or "text"}) end
local function regStroke(inst) table.insert(Themed.strokes, inst) end
local function regAccent(inst) table.insert(Themed.accents, inst) end

-- ============================================================
--  TOGGLE LOGIC
-- ============================================================
local function refreshToggleUI(prop, button, statusFrame)
    if not button or not statusFrame then return end
    local on = State[prop]
    pcall(function()
        TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = on and Colors.CardHover or Colors.Card
        }):Play()
        TweenService:Create(statusFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = on and Colors.Accent or Colors.BorderLight
        }):Play()
        local knob = statusFrame:FindFirstChild("Knob")
        if knob then
            TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            }):Play()
        end
    end)
end

local function toggleFeature(prop, button, statusFrame)
    State[prop] = not State[prop]
    refreshToggleUI(prop, button, statusFrame)
end

-- ============================================================
--  BIND BUTTON
-- ============================================================
local function createBindBtn(parent, prop, button, statusFrame)
    local bindBtn = new("TextButton", {
        Name = "Bind", Size = UDim2.new(0, 52, 0, 24),
        Position = UDim2.new(1, -100, 0.5, -12),
        BackgroundColor3 = Colors.Card, Text = "—",
        TextColor3 = Colors.TextMuted, Font = Enum.Font.GothamMedium,
        TextSize = 11, AutoButtonColor = false, ZIndex = 3
    }, parent)
    corner(bindBtn, 6)
    stroke(bindBtn, Colors.Border, 1, 0.5)

    local isWaiting = false
    bindBtn.MouseButton1Click:Connect(function()
        isWaiting = true
        bindBtn.Text = "…"
        bindBtn.TextColor3 = Colors.Accent
    end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if isWaiting and input.UserInputType == Enum.UserInputType.Keyboard then
            isWaiting = false
            if input.KeyCode == Enum.KeyCode.Escape then
                _G.NyzeBinds[prop] = nil
                bindBtn.Text = "—"
            else
                _G.NyzeBinds[prop] = input.KeyCode
                bindBtn.Text = input.KeyCode.Name
            end
            bindBtn.TextColor3 = Colors.TextMuted
        elseif not isWaiting and input.UserInputType == Enum.UserInputType.Keyboard then
            if _G.NyzeBinds[prop] and input.KeyCode == _G.NyzeBinds[prop] then
                toggleFeature(prop, button, statusFrame)
            end
        end
    end)
    bindBtn.MouseEnter:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.CardHover}):Play()
    end)
    bindBtn.MouseLeave:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Card}):Play()
    end)
end

-- ============================================================
--  ГЛАВНОЕ ОКНО
-- ============================================================
local M = new("Frame", {
    BackgroundColor3 = Colors.Background,
    Position = UDim2.new(0.5, -360, 0, -520),
    Size = UDim2.new(0, 720, 0, 500),
    BorderSizePixel = 0, Active = true, Draggable = true,
    Visible = false, ClipsDescendants = false
}, SG)
if isMobile then
    M.Size = UDim2.new(0, 540, 0, 400)
    M.Position = UDim2.new(0.5, -270, 0, -420)
end
corner(M, 14)
local MainStroke = stroke(M, Colors.BorderLight, 1, 0.3)
regFrame(M, "bg")
regStroke(MainStroke)

local topGlow = new("Frame", {
    BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.7,
    Size = UDim2.new(1, -40, 0, 1), Position = UDim2.new(0, 20, 0, 0),
    BorderSizePixel = 0, ZIndex = 5
}, M)
regAccent(topGlow)

-- ============================================================
--  TITLE BAR
-- ============================================================
local TitleBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Colors.Sidebar, BorderSizePixel = 0, ZIndex = 2
}, M)
corner(TitleBar, 14)
local fixCorner = new("Frame", {
    Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Colors.Sidebar, BorderSizePixel = 0, ZIndex = 2
}, TitleBar)
regFrame(TitleBar, "sidebar")
regFrame(fixCorner, "sidebar")

local tlContainer = new("Frame", {
    Size = UDim2.new(0, 60, 0, 12),
    Position = UDim2.new(0, 16, 0.5, -6),
    BackgroundTransparency = 1, ZIndex = 3
}, TitleBar)

local function mkDot(color, order)
    local dot = new("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, (order - 1) * 18, 0, 0),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 3
    }, tlContainer)
    corner(dot, 6)
    return dot
end
local dotClose = mkDot(Color3.fromRGB(255, 95, 87), 1)
mkDot(Color3.fromRGB(255, 189, 68), 2)
mkDot(Color3.fromRGB(40, 200, 65), 3)

local closeClick = new("TextButton", {
    Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1, Text = "", ZIndex = 4
}, dotClose)
closeClick.MouseButton1Click:Connect(function() toggleMenu() end)

local TitleLogo = new("TextLabel", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 92, 0.5, -13),
    BackgroundColor3 = Colors.Accent, Text = "N",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 15, ZIndex = 3
}, TitleBar)
corner(TitleLogo, 8)
regAccent(TitleLogo)

local Title = new("TextLabel", {
    Size = UDim2.new(1, -300, 1, 0), Position = UDim2.new(0, 126, 0, 0),
    BackgroundTransparency = 1, Text = "NyzeRust",
    TextColor3 = Colors.Text, Font = Enum.Font.GothamBold,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3
}, TitleBar)
regLabel(Title, "text")

local SubTitle = new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(1, -290, 0, 0),
    BackgroundTransparency = 1, Text = "v3.9  •  Premium",
    TextColor3 = Colors.TextMuted, Font = Enum.Font.Gotham,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3
}, TitleBar)
regLabel(SubTitle, "muted")

-- ============================================================
--  SIDEBAR
-- ============================================================
local Sidebar = new("Frame", {
    Size = UDim2.new(0, 168, 1, -60), Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Colors.Sidebar, BorderSizePixel = 0, ZIndex = 2
}, M)
corner(Sidebar, 12)
local SidebarStroke = stroke(Sidebar, Colors.Border, 1, 0.5)
regFrame(Sidebar, "sidebar")
regStroke(SidebarStroke)

new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Sidebar)
padding(Sidebar, 8, 10)

local sideHeader = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
    Text = "НАВИГАЦИЯ", TextColor3 = Colors.TextMuted,
    Font = Enum.Font.GothamMedium, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0
}, Sidebar)
padding(sideHeader, 8, 0)
regLabel(sideHeader, "muted")

-- ============================================================
--  CONTAINER
-- ============================================================
local Container = new("ScrollingFrame", {
    Position = UDim2.new(0, 188, 0, 50), Size = UDim2.new(1, -198, 1, -60),
    BackgroundColor3 = Colors.Panel, BorderSizePixel = 0,
    ScrollBarThickness = isMobile and 0 or 4,
    ScrollBarImageColor3 = Colors.Accent, ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 2
}, M)
corner(Container, 12)
local ContainerStroke = stroke(Container, Colors.Border, 1, 0.5)
regFrame(Container, "panel")
regStroke(ContainerStroke)
padding(Container, 14)

new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, Container)

-- ============================================================
--  UI ФУНКЦИИ (СОЗДАНИЕ)
-- ============================================================
local function createCategory(title, order)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = order
    }, Container)
    padding(f, 4, 0)
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = title, TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, f)
    regLabel(lbl, "dim")
    return f
end

local function createToggle(label, prop, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Colors.Card,
        Text = "", AutoButtonColor = false, LayoutOrder = order, ZIndex = 3
    }, Container)
    corner(b, 10)
    local bStroke = stroke(b, Colors.Border, 1, 0.5)
    regStroke(bStroke)
    table.insert(Themed.buttons, {inst=b, prop=prop})

    local marker = new("Frame", {
        Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = State[prop] and Colors.Accent or Colors.BorderLight,
        BorderSizePixel = 0, ZIndex = 4
    }, b)
    corner(marker, 2)
    table.insert(Themed.markers, {inst=marker, prop=prop})

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -170, 1, 0), Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = Colors.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
    }, b)
    regLabel(lbl, "text")

    local status = new("Frame", {
        Size = UDim2.new(0, 38, 0, 22), Position = UDim2.new(1, -50, 0.5, -11),
        BackgroundColor3 = State[prop] and Colors.Accent or Colors.BorderLight,
        BorderSizePixel = 0, ZIndex = 4
    }, b)
    corner(status, 11)
    table.insert(Themed.knobs, {inst=status, prop=prop})

    local knob = new("Frame", {
        Name = "Knob", Size = UDim2.new(0, 18, 0, 18),
        Position = State[prop] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, ZIndex = 5
    }, status)
    corner(knob, 9)
    local knobShadow = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.85,
        BorderSizePixel = 0, ZIndex = 4
    }, knob)
    corner(knobShadow, 9)

    b.MouseButton1Click:Connect(function()
        toggleFeature(prop, b, status)
        TweenService:Create(marker, TweenInfo.new(0.25), {
            BackgroundColor3 = State[prop] and Colors.Accent or Colors.BorderLight
        }):Play()
    end)
    b.MouseEnter:Connect(function()
        if not State[prop] then
            TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Colors.CardHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if not State[prop] then
            TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Colors.Card}):Play()
        end
    end)

    createBindBtn(b, prop, b, status)
    return b
end

local function createSlider(label, prop, min, max, order)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Colors.Card,
        LayoutOrder = order, BorderSizePixel = 0, ZIndex = 3
    }, Container)
    corner(f, 10)
    local fStroke = stroke(f, Colors.Border, 1, 0.5)
    regStroke(fStroke)
    table.insert(Themed.buttons, {inst=f, prop=prop})

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -110, 0, 18), Position = UDim2.new(0, 18, 0, 10),
        BackgroundTransparency = 1, Text = label, TextColor3 = Colors.Text,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
    }, f)
    regLabel(lbl, "text")

    local valLbl = new("TextLabel", {
        Size = UDim2.new(0, 90, 0, 18), Position = UDim2.new(1, -108, 0, 10),
        BackgroundTransparency = 1, Text = tostring(State[prop]),
        TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4
    }, f)
    regAccent(valLbl)

    local barBg = new("Frame", {
        Size = UDim2.new(1, -36, 0, 6), Position = UDim2.new(0, 18, 0, 38),
        BackgroundColor3 = Colors.BorderLight, BorderSizePixel = 0, ZIndex = 4
    }, f)
    corner(barBg, 3)

    local fill = new("Frame", {
        Size = UDim2.new((State[prop] - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Accent, BorderSizePixel = 0, ZIndex = 5
    }, barBg)
    corner(fill, 3)
    table.insert(Themed.fills, fill)

    local thumb = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((State[prop] - min) / (max - min), 0, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, ZIndex = 6
    }, barBg)
    corner(thumb, 7)
    local thumbShadow = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 5
    }, thumb)
    corner(thumbShadow, 7)

    local trigger = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 7
    }, barBg)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        val = (max > 5) and math.floor(val) or math.floor(val * 100) / 100
        State[prop] = val
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -7, 0.5, -7)
        valLbl.Text = tostring(val)
    end
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    return f
end

local function createActionBtn(label, callback, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Colors.Card,
        Text = "", AutoButtonColor = false, LayoutOrder = order, ZIndex = 3
    }, Container)
    corner(b, 10)
    local bStroke = stroke(b, Colors.Border, 1, 0.5)
    regStroke(bStroke)
    table.insert(Themed.buttons, {inst=b})

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = Colors.Text,
        Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
    }, b)
    regLabel(lbl, "text")

    local arrow = new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1, Text = "›", TextColor3 = Colors.TextMuted,
        Font = Enum.Font.GothamBold, TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4
    }, b)
    regLabel(arrow, "muted")

    b.MouseButton1Click:Connect(callback)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Colors.CardHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Colors.Card}):Play()
    end)
    return b
end

-- ============================================================
--  ВКЛАДКИ
-- ============================================================
local Tabs = {VISUALS = {}, AIM = {}, PLAYER = {}, WORLD = {}, SETTINGS = {}}
local tabButtons = {}

local function showTab(name)
    for tN, objs in pairs(Tabs) do
        for _, o in ipairs(objs) do
            o.Visible = (tN == name)
        end
    end
    for key, btn in pairs(tabButtons) do
        local active = (key == name)
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = active and Colors.CardHover or Colors.Sidebar,
        }):Play()
        local lbl = btn:FindFirstChildOfClass("TextLabel")
        if lbl then
            TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                TextColor3 = active and Colors.Accent or Colors.TextDim
            }):Play()
        end
        local bar = btn:FindFirstChild("ActiveBar")
        if bar then
            bar.BackgroundTransparency = active and 0 or 1
        end
    end
end

local function createTabBtn(name, label, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Colors.Sidebar,
        Text = "", AutoButtonColor = false, LayoutOrder = order, ZIndex = 3
    }, Sidebar)
    corner(b, 8)

    local activeBar = new("Frame", {
        Name = "ActiveBar", Size = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundColor3 = Colors.Accent, BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 4
    }, b)
    corner(activeBar, 2)
    regAccent(activeBar)

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
    }, b)
    regLabel(lbl, "dim")

    tabButtons[name] = b

    b.MouseButton1Click:Connect(function() showTab(name) end)
    b.MouseEnter:Connect(function()
        if lbl.TextColor3 ~= Colors.Accent then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Card}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if lbl.TextColor3 ~= Colors.Accent then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Sidebar}):Play()
        end
    end)
end

-- ============================================================
--  НАПОЛНЕНИЕ — КАЖДЫЙ ЭЛЕМЕНТ СРАЗУ В СВОЮ ВКЛАДКУ
-- ============================================================
local O = 0
local function nextO() O = O + 1; return O end

-- обёртки, которые добавляют объект в нужный Tabs после создания
local function addTo(tabName, obj)
    if obj then
        table.insert(Tabs[tabName], obj)
        obj.Visible = false
    end
end

-- Кнопки вкладок
createTabBtn("VISUALS",  "ESP",       1)
createTabBtn("AIM",      "Aimbot",    2)
createTabBtn("PLAYER",   "Player",    3)
createTabBtn("WORLD",    "World",     4)
createTabBtn("SETTINGS", "Settings",  5)

-- ============ VISUALS ============
addTo("VISUALS", createCategory("ESP ИГРОКОВ", nextO()))
addTo("VISUALS", createToggle("Рамки игроков",      "EspBoxes",   nextO()))
addTo("VISUALS", createToggle("Ники",               "EspNames",   nextO()))
addTo("VISUALS", createToggle("Дистанция",          "EspDist",    nextO()))
addTo("VISUALS", createToggle("Полоса здоровья",    "EspHP",      nextO()))
addTo("VISUALS", createToggle("Число HP",           "EspHPNum",   nextO()))
addTo("VISUALS", createToggle("Инвентарь",          "EspInv",     nextO()))
addTo("VISUALS", createToggle("Иконки предметов",   "EspInvIcons",nextO()))
addTo("VISUALS", createToggle("Трассеры",           "EspTracers", nextO()))
addTo("VISUALS", createToggle("Скелет",             "EspSkeleton",nextO()))
addTo("VISUALS", createToggle("Кружок головы",      "EspHead",    nextO()))
addTo("VISUALS", createSlider("Макс. дистанция",    "PlayerEspMaxDist", 100, 5000, nextO()))

-- ============ AIM ============
addTo("AIM", createCategory("АИМБОТ", nextO()))
addTo("AIM", createToggle("Включить Аимбот",    "AimEnabled",  nextO()))
addTo("AIM", createToggle("Проверка команды",   "TeamCheck",   nextO()))
addTo("AIM", createToggle("Проверка стен",      "WallCheck",   nextO()))
addTo("AIM", createToggle("Отключить падение пуль", "NoBulletDrop", nextO()))
addTo("AIM", createToggle("Авто-выстрел",       "AutoShoot",   nextO()))
addTo("AIM", createSlider("Задержка выстрела",  "AutoShootDelay", 0.01, 0.5, nextO()))
addTo("AIM", createSlider("Плавность",          "AimSmooth",   0.01, 1, nextO()))
addTo("AIM", createSlider("Радиус FOV",         "AimFOV",      20, 800, nextO()))

-- ============ PLAYER ============
addTo("PLAYER", createCategory("ИГРОК", nextO()))
addTo("PLAYER", createToggle("Скорость",           "LegitSpeed",     nextO()))
addTo("PLAYER", createSlider("Множитель скорости", "SpeedMultiplier", 1, 5, nextO()))
addTo("PLAYER", createToggle("Бесконечный прыжок", "InfJump",        nextO()))
addTo("PLAYER", createToggle("Свободная камера",   "FreecamEnabled", nextO()))
addTo("PLAYER", createSlider("Скорость полёта",    "FreecamSpeed",   0.1, 10, nextO()))

addTo("PLAYER", createCategory("КАМЕРА", nextO()))
addTo("PLAYER", createToggle("Третье лицо",        "ThirdPerson",     nextO()))
addTo("PLAYER", createSlider("Дистанция камеры",   "ThirdPersonDist", 3, 50, nextO()))

-- ============ WORLD ============
addTo("WORLD", createCategory("ВИЗУАЛ", nextO()))
addTo("WORLD", createToggle("X-Ray стен",         "XRay",       nextO()))
addTo("WORLD", createToggle("Полное освещение",   "FullBright", nextO()))

addTo("WORLD", createCategory("МИР", nextO()))
addTo("WORLD", createToggle("Сера",     "SulfurEsp", nextO()))
addTo("WORLD", createToggle("Железо",   "IronEsp",   nextO()))
addTo("WORLD", createToggle("Камень",   "StoneEsp",  nextO()))
addTo("WORLD", createToggle("NPC",      "NpcEsp",    nextO()))
addTo("WORLD", createToggle("Ящики",    "CrateEsp",  nextO()))
addTo("WORLD", createSlider("Дистанция руды",      "OreEspMaxDist",   50, 3000, nextO()))
addTo("WORLD", createSlider("Дистанция NPC",       "NpcEspMaxDist",   50, 3000, nextO()))
addTo("WORLD", createSlider("Дистанция ящиков",    "CrateEspMaxDist", 50, 3000, nextO()))

addTo("WORLD", createCategory("РАЗНОЕ", nextO()))
addTo("WORLD", createToggle("Автоввод кода на замках", "LockAutoCode", nextO()))
addTo("WORLD", createToggle("Свободная мышь в меню",   "FreeMouse",    nextO()))

addTo("WORLD", createCategory("ОПТИМИЗАЦИЯ", nextO()))
addTo("WORLD", createToggle("Low GFX (всё сразу)",    "OptLowGFX",       nextO()))
addTo("WORLD", createToggle("Убрать эффекты",         "OptNoEffects",    nextO()))
addTo("WORLD", createToggle("Убрать частицы",         "OptNoParticles",  nextO()))
addTo("WORLD", createToggle("Убрать Decals/Textures", "OptNoDecals",     nextO()))
addTo("WORLD", createToggle("Убрать тени",            "OptNoShadows",    nextO()))
addTo("WORLD", createToggle("Убрать дальние объекты", "OptFarParts",     nextO()))
addTo("WORLD", createToggle("Упростить террейн",      "OptLowTerrain",   nextO()))
addTo("WORLD", createToggle("Убрать звуки",           "OptNoSounds",     nextO()))
addTo("WORLD", createSlider("Дальность прорисовки",   "OptRenderDist",   100, 5000, nextO()))

-- ============ SETTINGS ============
addTo("SETTINGS", createCategory("ТЕМА ОФОРМЛЕНИЯ", nextO()))
addTo("SETTINGS", createActionBtn("Midnight — тёмный с фиолетовым",  function() ApplyTheme("Midnight") end,   nextO()))
addTo("SETTINGS", createActionBtn("Obsidian — глубокий чёрный",      function() ApplyTheme("Obsidian") end,   nextO()))
addTo("SETTINGS", createActionBtn("Rose Quartz — розово-фиолетовый", function() ApplyTheme("RoseQuartz") end, nextO()))
addTo("SETTINGS", createActionBtn("Arctic — тёмно-синий с голубым",  function() ApplyTheme("Arctic") end,     nextO()))

-- ============================================================
--  APPLY THEME
-- ============================================================
function ApplyTheme(themeName)
    local th = Themes[themeName]
    if not th then return end
    Colors = th
    CurrentTheme = themeName

    -- Фоны
    for _, item in ipairs(Themed.frames) do
        pcall(function()
            if item.kind == "bg" then item.inst.BackgroundColor3 = th.Background
            elseif item.kind == "sidebar" then item.inst.BackgroundColor3 = th.Sidebar
            elseif item.kind == "panel" then item.inst.BackgroundColor3 = th.Panel
            end
        end)
    end

    -- Лейблы
    for _, item in ipairs(Themed.labels) do
        pcall(function()
            if item.kind == "text" then item.inst.TextColor3 = th.Text
            elseif item.kind == "dim" then item.inst.TextColor3 = th.TextDim
            elseif item.kind == "muted" then item.inst.TextColor3 = th.TextMuted
            end
        end)
    end

    -- Обводки
    for _, s in ipairs(Themed.strokes) do
        pcall(function() s.Color = th.Border end)
    end

    -- Кнопки/карточки
    for _, item in ipairs(Themed.buttons) do
        pcall(function()
            if item.prop and State[item.prop] then
                item.inst.BackgroundColor3 = th.CardHover
            else
                item.inst.BackgroundColor3 = th.Card
            end
        end)
    end

    -- Акценты (полоски слева, логотип, topGlow, ActiveBar)
    for _, inst in ipairs(Themed.accents) do
        pcall(function() inst.BackgroundColor3 = th.Accent end)
    end

    -- Fill слайдеров
    for _, f in ipairs(Themed.fills) do
        pcall(function() f.BackgroundColor3 = th.Accent end)
    end

    -- Knob-ы тоглов (фон кружка)
    for _, item in ipairs(Themed.knobs) do
        pcall(function()
            item.inst.BackgroundColor3 = State[item.prop] and th.Accent or th.BorderLight
        end)
    end

    -- Маркеры слева тогла
    for _, item in ipairs(Themed.markers) do
        pcall(function()
            item.inst.BackgroundColor3 = State[item.prop] and th.Accent or th.BorderLight
        end)
    end

    -- TitleLogo всегда акцент
    pcall(function() TitleLogo.BackgroundColor3 = th.Accent end)

    -- Watermark
    if _G.WFrame then
        pcall(function()
            _G.WFrame.BackgroundColor3 = th.Background
            _G.WStroke.Color = th.Accent
        end)
    end

    showTab(CurrentTabShown or "VISUALS")
end

-- ============================================================
--  TOGGLE MENU
-- ============================================================
local menuToggled = false
local CurrentTabShown = "VISUALS"

local function setMouseFree(free)
    pcall(function()
        if free then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end
    end)
end

function toggleMenu()
    menuToggled = not menuToggled
    if menuToggled then
        M.Visible = true
        if not isMobile then
            if State.FreeMouse then setMouseFree(true)
            else UserInputService.MouseIconEnabled = true end
        end
        TweenService:Create(Blur, TweenInfo.new(0.35), {Size = 14}):Play()
        local target = isMobile
            and UDim2.new(0.5, -270, 0.5, -200)
            or  UDim2.new(0.5, -360, 0.5, -250)
        TweenService:Create(M, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = target}):Play()
    else
        if not isMobile then UserInputService.MouseIconEnabled = false end
        TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
        local target = isMobile
            and UDim2.new(0.5, -270, 0, -420)
            or  UDim2.new(0.5, -360, 0, -520)
        local tw = TweenService:Create(M, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = target})
        tw:Play()
        tw.Completed:Connect(function()
            if not menuToggled then M.Visible = false end
        end)
    end
end

-- Свободная мышь
RunService.RenderStepped:Connect(function()
    if menuToggled and State.FreeMouse and not isMobile then
        pcall(function()
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
            if not UserInputService.MouseIconEnabled then
                UserInputService.MouseIconEnabled = true
            end
        end)
    end
end)
UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
    if menuToggled and State.FreeMouse and not isMobile then
        pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
    end
end)

-- ============================================================
--  МОБИЛЬНАЯ КНОПКА
-- ============================================================
if isMobile then
    local OpenBtn = new("TextButton", {
        Size = UDim2.new(0, 52, 0, 52), Position = UDim2.new(0, 12, 0.42, 0),
        BackgroundColor3 = Colors.Sidebar, Text = "N",
        TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold,
        TextSize = 22, AutoButtonColor = false
    }, SG)
    corner(OpenBtn, 26)
    stroke(OpenBtn, Colors.Accent, 2, 0.3)
    OpenBtn.MouseButton1Click:Connect(toggleMenu)
end

-- ============================================================
--  WATERMARK
-- ============================================================
local WM = Instance.new("ScreenGui")
WM.Name = "NyzeRustWM"
WM.ResetOnSpawn = false
WM.IgnoreGuiInset = true
pcall(function() WM.Parent = CoreGui end)
if not WM.Parent then WM.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local WFrame = Instance.new("Frame")
WFrame.BackgroundColor3 = Colors.Background
WFrame.BackgroundTransparency = 0.05
WFrame.Position = UDim2.new(0.5, -250, 0, 8)
WFrame.Size = UDim2.new(0, 500, 0, 30)
WFrame.BorderSizePixel = 0
WFrame.Parent = WM
corner(WFrame, 15)
_G.WFrame = WFrame
local WStroke = stroke(WFrame, Colors.Accent, 1, 0.4)
_G.WStroke = WStroke

local WRow = Instance.new("Frame")
WRow.Size = UDim2.new(1, -20, 1, 0)
WRow.Position = UDim2.new(0, 10, 0, 0)
WRow.BackgroundTransparency = 1
WRow.Parent = WFrame

local WLayout = Instance.new("UIListLayout")
WLayout.FillDirection = Enum.FillDirection.Horizontal
WLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WLayout.Padding = UDim.new(0, 6)
WLayout.SortOrder = Enum.SortOrder.LayoutOrder
WLayout.Parent = WRow

local function makeSeg(text, color, order)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.AutomaticSize = Enum.AutomaticSize.X
    l.Size = UDim2.new(0, 0, 1, 0)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 12
    l.TextColor3 = color
    l.Text = text
    l.LayoutOrder = order
    l.Parent = WRow
    return l
end

local segFpsVal  = makeSeg("0", Colors.Accent, 5)
local segPingVal = makeSeg("0ms", Colors.Accent, 8)
makeSeg("NyzeRust", Colors.Text, 1)
makeSeg("v3.9", Colors.TextMuted, 2)
makeSeg("•", Colors.BorderLight, 3)
makeSeg("FPS:", Colors.TextDim, 4)
makeSeg("•", Colors.BorderLight, 6)
makeSeg("PING:", Colors.TextDim, 7)
makeSeg("•", Colors.BorderLight, 9)
makeSeg("RSHIFT", Colors.Accent, 10)

local lastT = tick(); local frames = 0; local fps = 0
RunService.RenderStepped:Connect(function()
    pcall(function()
        frames = frames + 1
        if tick() - lastT >= 1 then fps = frames; frames = 0; lastT = tick() end
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        segFpsVal.Text  = tostring(fps)
        segPingVal.Text = ping .. "ms"
    end)
end)

-- ============================================================
--  THIRD PERSON
-- ============================================================
local thirdPersonActive = false
local function applyThirdPerson()
    if State.ThirdPerson and not thirdPersonActive then
        thirdPersonActive = true
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = State.ThirdPersonDist
            LocalPlayer.CameraMinZoomDistance = State.ThirdPersonDist
        end)
    elseif not State.ThirdPerson and thirdPersonActive then
        thirdPersonActive = false
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = 128
            LocalPlayer.CameraMinZoomDistance = 0.5
        end)
    elseif State.ThirdPerson and thirdPersonActive then
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = State.ThirdPersonDist
            LocalPlayer.CameraMinZoomDistance = State.ThirdPersonDist
        end)
    end
end
task.spawn(function()
    while true do task.wait(0.2); pcall(applyThirdPerson) end
end)

-- ============================================================
--  GAME LOGIC
-- ============================================================
workspace.DescendantAdded:Connect(function(obj)
    if State.NoBulletDrop and obj:IsA("BasePart") and (obj.Name:find("Bullet") or obj.Name:find("Projectile")) then
        pcall(function()
            local bf = Instance.new("BodyForce")
            bf.Force = Vector3.new(0, obj:GetMass() * workspace.Gravity, 0)
            bf.Parent = obj
        end)
    end
end)

local function isVisible(targetPart, targetChar)
    if not State.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetChar}
    local ray = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), params)
    return ray == nil
end

-- X-RAY
local xrayOriginals = {}
local xrayApplied = false
local function isCharacterPart(part)
    local parent = part.Parent
    local grandparent = parent and parent.Parent
    if parent and parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then return true end
    if grandparent and grandparent:IsA("Model") and grandparent:FindFirstChildOfClass("Humanoid") then return true end
    return false
end
local function applyXRayWalls()
    if State.XRay and not xrayApplied then
        xrayApplied = true
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not isCharacterPart(obj) then
                xrayOriginals[obj] = {transparency = obj.Transparency, ltm = obj.LocalTransparencyModifier}
                obj.LocalTransparencyModifier = 0.85
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                local part = obj.Parent
                if part and not (part:IsA("BasePart") and isCharacterPart(part)) then
                    xrayOriginals[obj] = {transparency = obj.Transparency}
                    obj.Transparency = 0.85
                end
            end
        end
    elseif not State.XRay and xrayApplied then
        xrayApplied = false
        for obj, orig in pairs(xrayOriginals) do
            pcall(function()
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then obj.LocalTransparencyModifier = orig.ltm
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = orig.transparency end
                end
            end)
        end
        xrayOriginals = {}
    end
end
task.spawn(function()
    while true do
        task.wait(3)
        if State.XRay then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not isCharacterPart(obj) then
                    if xrayOriginals[obj] == nil then
                        xrayOriginals[obj] = {transparency = obj.Transparency, ltm = obj.LocalTransparencyModifier}
                        pcall(function() obj.LocalTransparencyModifier = 0.85 end)
                    end
                end
            end
        end
    end
end)

-- LOCK AUTO-CODE
local function isCodeLock(obj)
    local n = obj.Name:lower()
    return n:find("lock") or n:find("code") or n:find("keypad")
        or n:find("password") or n:find("pin") or n:find("codelock")
        or n:find("digital") or n:find("safe")
end
local function tryUnlockProximityPrompt(lockObj)
    pcall(function()
        local prompt = lockObj:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = lockObj:IsA("Model") and lockObj:GetModelCFrame().Position or lockObj.Position
                if (root.Position - pos).Magnitude <= prompt.MaxActivationDistance then fireproximityprompt(prompt) end
            end
        end
    end)
end
local function tryUnlockClickDetector(lockObj)
    pcall(function()
        local cd = lockObj:FindFirstChildOfClass("ClickDetector")
        if cd then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = lockObj:IsA("Model") and lockObj:GetModelCFrame().Position or lockObj.Position
                if (root.Position - pos).Magnitude <= cd.MaxActivationDistance then fireclickdetector(cd) end
            end
        end
    end)
end
local function tryUnlockRemote(lockObj)
    pcall(function()
        local parent = lockObj.Parent or lockObj
        for _, d in ipairs(parent:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                local n = d.Name:lower()
                if n:find("unlock") or n:find("code") or n:find("submit")
                or n:find("enter") or n:find("open") or n:find("key") then
                    local codes = {"0000", "1234", "1111", "9999", "2000", "7777", "12345", "00000"}
                    for _, code in ipairs(codes) do
                        if d:IsA("RemoteEvent") then
                            pcall(function() d:FireServer(code) end)
                            pcall(function() d:FireServer(tonumber(code)) end)
                        else
                            pcall(function() d:InvokeServer(code) end)
                            pcall(function() d:InvokeServer(tonumber(code)) end)
                        end
                    end
                end
            end
        end
    end)
end
local lockScanCooldown = 0
local function runLockAutoCode()
    if not State.LockAutoCode then return end
    local now = tick()
    if now - lockScanCooldown < 1 then return end
    lockScanCooldown = now
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isCodeLock(obj) then
            local ok, dist = pcall(function()
                local pos = obj:IsA("Model") and obj:GetModelCFrame().Position or obj.Position
                return (root.Position - pos).Magnitude
            end)
            if ok and dist and dist <= 30 then
                tryUnlockProximityPrompt(obj)
                tryUnlockClickDetector(obj)
                tryUnlockRemote(obj)
            end
        end
    end
end

-- WORLD ESP
local function applyCrateVisuals(obj, name, color)
    if not obj:FindFirstChild("CrateHighlight") then
        local h = Instance.new("Highlight", obj)
        h.Name = "CrateHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if not obj:FindFirstChild("CrateTag") then
        local bg = new("BillboardGui", {Name = "CrateTag", AlwaysOnTop = true,
            Size = UDim2.new(0, 120, 0, 40), ExtentsOffset = Vector3.new(0, 2, 0)}, obj)
        new("TextLabel", {Name = "Label", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextStrokeTransparency = 0}, bg)
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local pos = obj:IsA("Model") and obj:GetModelCFrame().Position or obj.Position
        local dist = math.floor((root.Position - pos).Magnitude)
        if dist <= State.CrateEspMaxDist then
            obj.CrateTag.Enabled, obj.CrateHighlight.Enabled = true, true
            obj.CrateTag.Label.Text = name:upper() .. "\n[" .. dist .. "m]"
            obj.CrateTag.Label.TextColor3 = color
            obj.CrateHighlight.FillColor = color
        else
            obj.CrateTag.Enabled, obj.CrateHighlight.Enabled = false, false
        end
    end
end
local function updateNpcEsp()
    local npcFolder = workspace:FindFirstChild("Npc")
    if not npcFolder then return end
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") then
            if not npc:FindFirstChild("NpcHighlight") then
                local h = Instance.new("Highlight", npc)
                h.Name = "NpcHighlight"
                h.FillColor = Color3.fromRGB(255, 80, 80)
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local ok, dist = pcall(function()
                    return (root.Position - npc:GetModelCFrame().Position).Magnitude
                end)
                npc.NpcHighlight.Enabled = State.NpcEsp and ok and dist <= State.NpcEspMaxDist
            else
                npc.NpcHighlight.Enabled = false
            end
        end
    end
end
local function applyOreVisuals(obj, name, color)
    if not obj:FindFirstChild("OreHighlight") then
        local h = Instance.new("Highlight", obj)
        h.Name = "OreHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if not obj:FindFirstChild("OreTag") then
        local bg = new("BillboardGui", {Name = "OreTag", AlwaysOnTop = true,
            Size = UDim2.new(0, 100, 0, 40), ExtentsOffset = Vector3.new(0, 2, 0)}, obj)
        new("TextLabel", {Name = "Label", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextStrokeTransparency = 0}, bg)
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = math.floor((root.Position - obj.Position).Magnitude)
        if dist <= State.OreEspMaxDist then
            obj.OreTag.Enabled, obj.OreHighlight.Enabled = true, true
            obj.OreTag.Label.Text = name:upper() .. "\n[" .. dist .. "m]"
            obj.OreTag.Label.TextColor3 = color
            obj.OreHighlight.FillColor = color
        else
            obj.OreTag.Enabled, obj.OreHighlight.Enabled = false, false
        end
    end
end

-- ОПТИМИЗАЦИЯ
local OptBackup = {effects = {}, particles = {}, decals = {}, shadows = {}, parts = {}, sounds = {}}
local function optRestoreAll()
    for e, v in pairs(OptBackup.effects) do pcall(function() if e and e.Parent then e.Enabled = v end end) end
    for p, v in pairs(OptBackup.particles) do pcall(function() if p and p.Parent then p.Enabled = v end end) end
    for d, v in pairs(OptBackup.decals) do pcall(function() if d and d.Parent then d.Transparency = v end end) end
    for s, v in pairs(OptBackup.shadows) do pcall(function() if s and s.Parent then s.CastShadow = v end end) end
    for pt, v in pairs(OptBackup.parts) do pcall(function() if pt and pt.Parent then pt.Transparency = v end end) end
    for sd, v in pairs(OptBackup.sounds) do pcall(function() if sd and sd.Parent then sd.Volume = v end end) end
    OptBackup = {effects = {}, particles = {}, decals = {}, shadows = {}, parts = {}, sounds = {}}
end
local function optApplyEffects()
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Atmosphere") or e:IsA("Sky") then
            if OptBackup.effects[e] == nil then OptBackup.effects[e] = e.Enabled; e.Enabled = false end
        end
    end
    pcall(function() Lighting.GlobalShadows = false end)
    pcall(function() Lighting.FogEnd = 500 end)
end
local function optApplyParticles()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
        or obj:IsA("PointLight") or obj:IsA("SpotLight") then
            if OptBackup.particles[obj] == nil then OptBackup.particles[obj] = obj.Enabled; obj.Enabled = false end
        end
    end
end
local function optApplyDecals()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if OptBackup.decals[obj] == nil then OptBackup.decals[obj] = obj.Transparency; obj.Transparency = 1 end
        end
    end
end
local function optApplyShadows()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CastShadow then
            if OptBackup.shadows[obj] == nil then OptBackup.shadows[obj] = obj.CastShadow; obj.CastShadow = false end
        end
    end
end
local function optApplyFarParts()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local maxDist = State.OptRenderDist
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 1 then
            local dist = 0
            pcall(function() dist = (root.Position - obj.Position).Magnitude end)
            if dist > maxDist then
                if OptBackup.parts[obj] == nil then OptBackup.parts[obj] = obj.Transparency; obj.Transparency = 1 end
            end
        end
    end
end
local function optApplyTerrain()
    pcall(function()
        local t = workspace.Terrain
        t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
        t.WaterReflectance = 0; t.WaterTransparency = 1
        t.Decoration = false
    end)
end
local function optApplySounds()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Sound") then
            if OptBackup.sounds[obj] == nil then OptBackup.sounds[obj] = obj.Volume; obj.Volume = 0 end
        end
    end
end
local function applyOptimizations()
    local anyOn = State.OptLowGFX or State.OptNoEffects or State.OptNoParticles
              or State.OptNoDecals or State.OptNoShadows or State.OptFarParts
              or State.OptLowTerrain or State.OptNoSounds
    if not anyOn then optRestoreAll(); return end
    if State.OptNoEffects or State.OptLowGFX then optApplyEffects() end
    if State.OptNoParticles or State.OptLowGFX then optApplyParticles() end
    if State.OptNoDecals or State.OptLowGFX then optApplyDecals() end
    if State.OptNoShadows or State.OptLowGFX then optApplyShadows() end
    if State.OptFarParts or State.OptLowGFX then optApplyFarParts() end
    if State.OptLowTerrain or State.OptLowGFX then optApplyTerrain() end
    if State.OptNoSounds or State.OptLowGFX then optApplySounds() end
    if State.OptLowGFX then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function() Lighting.GlobalShadows = false; Lighting.ShadowSoftness = 0 end)
    end
end
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            if State.OptNoEffects or State.OptNoParticles or State.OptNoDecals
            or State.OptNoShadows or State.OptFarParts or State.OptNoSounds
            or State.OptLowGFX then
                applyOptimizations()
            end
        end)
    end
end)

-- RENDER: мир
RunService.RenderStepped:Connect(function()
    pcall(function()
        updateNpcEsp()
        applyXRayWalls()
        runLockAutoCode()

        if State.LegitSpeed then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * (State.SpeedMultiplier / 10))
            end
        end

        local ores = workspace:FindFirstChild("ores")
        if ores then
            for _, ore in ipairs(ores:GetChildren()) do
                local en = (ore.Name == "sulfur" and State.SulfurEsp)
                        or (ore.Name == "iron" and State.IronEsp)
                        or (ore.Name == "stone" and State.StoneEsp)
                local col = (ore.Name == "sulfur" and Color3.new(1, 1, 0))
                         or (ore.Name == "iron" and Color3.fromRGB(180, 180, 180))
                         or Color3.fromRGB(220, 220, 220)
                if en then applyOreVisuals(ore, ore.Name, col)
                elseif ore:FindFirstChild("OreTag") then
                    ore.OreTag.Enabled, ore.OreHighlight.Enabled = false, false
                end
            end
        end

        local crates = workspace:FindFirstChild("Crates")
        if crates then
            for _, crate in ipairs(crates:GetChildren()) do
                local en, col = false, Color3.new(1, 1, 1)
                if crate.Name == "Crate" then en = State.CrateEsp; col = Color3.fromRGB(180, 130, 60)
                elseif crate.Name == "MilitaryCrate" then en = State.CrateEsp; col = Color3.fromRGB(0, 180, 0)
                elseif crate.Name == "EliteCrate" then en = State.CrateEsp; col = Color3.fromRGB(255, 60, 90)
                elseif crate.Name == "FoodBox" or crate.Name == "ToolBox" then en = State.CrateEsp; col = Color3.fromRGB(0, 200, 255)
                end
                if en then applyCrateVisuals(crate, crate.Name, col)
                elseif crate:FindFirstChild("CrateTag") then
                    crate.CrateTag.Enabled, crate.CrateHighlight.Enabled = false, false
                end
            end
        end

        if State.FullBright then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
        end
    end)
end)

-- ============================================================
--  AIMBOT (фикс для первого лица)
-- ============================================================
local function getClosest()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local target, mag = nil, math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            if not (State.TeamCheck and v.Team == LocalPlayer.Team) then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local head = v.Character.Head
                    local sp, on = Camera:WorldToViewportPoint(head.Position)
                    if on then
                        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if dist < mag and dist < State.AimFOV then
                            if isVisible(head, v.Character) then
                                mag, target = dist, head
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Жёсткая наводка в голову + тело (фикс 1-го лица)
local function aimAt(targetPart)
    if not targetPart then return end
    local aimPos = targetPart.Position
    local alpha = 1 - State.AimSmooth

    -- 1. Камера
    local newCFrame = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, alpha)

    -- 2. Humanoid (фикс первого лица)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum.AutoRotate = false
            local flatTarget = Vector3.new(aimPos.X, hrp.Position.Y, aimPos.Z)
            local look = CFrame.new(hrp.Position, flatTarget)
            local yaw = select(2, look:ToEulerAnglesYXZ())
            hrp.CFrame = hrp.CFrame:Lerp(
                CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0),
                alpha * 0.7
            )
        end
    end
end

local function restoreAutoRotate()
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end)
end

local lastShoot = 0
local function tryAutoShoot(target)
    if not State.AutoShoot then return end
    if not target then return end
    local now = tick()
    if now - lastShoot < State.AutoShootDelay then return end
    lastShoot = now
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

RunService.RenderStepped:Connect(function()
    if not State.AimEnabled then restoreAutoRotate(); return end
    local isAiming = (not isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
                   or (isMobile) or State.AutoShoot
    if not isAiming then restoreAutoRotate(); return end
    local target = getClosest()
    if not target then restoreAutoRotate(); return end
    aimAt(target)
    if State.AutoShoot then tryAutoShoot(target) end
end)

-- ИКОНКИ
local IconCache = {}
local IconLoading = {}
local function getItemIcon(itemName)
    if not itemName or itemName == "" then return nil end
    if IconCache[itemName] ~= nil then return IconCache[itemName] or nil end
    if IconLoading[itemName] then return nil end
    IconLoading[itemName] = true
    task.spawn(function()
        local ok, icon = pcall(function()
            local roots = {game:GetService("ReplicatedStorage"), game:GetService("StarterPack"), workspace}
            for _, root in ipairs(roots) do
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("Tool") and obj.Name == itemName then
                        if obj.TextureId and obj.TextureId ~= "" then return obj.TextureId end
                        for _, d in ipairs(obj:GetDescendants()) do
                            if d:IsA("Decal") or d:IsA("Texture") then return d.Texture end
                            if d:IsA("ImageLabel") and d.Image ~= "" then return d.Image end
                        end
                    end
                end
            end
            return nil
        end)
        if ok and icon and icon ~= "" then IconCache[itemName] = icon
        else IconCache[itemName] = false end
        IconLoading[itemName] = nil
    end)
    return nil
end
local function getPlayerInventoryItems(p)
    local items = {}
    local bp = p:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, {name = tool.Name, equipped = false, tool = tool})
            end
        end
    end
    if p.Character then
        for _, tool in ipairs(p.Character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, {name = tool.Name, equipped = true, tool = tool})
            end
        end
    end
    return items
end

-- ESP
local espElements = {}
local FOVring = nil
if hasDrawing then
    local function createESP(p)
        if p == LocalPlayer or espElements[p] then return end
        local ok, d = pcall(function()
            return {
                box={Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line"),Drawing.new("Line")},
                hpBg=Drawing.new("Line"), hpFill=Drawing.new("Line"), hpText=Drawing.new("Text"),
                name=Drawing.new("Text"), dist=Drawing.new("Text"), inv=Drawing.new("Text"),
                tracer=Drawing.new("Line"), head=Drawing.new("Circle"),
                bone1=Drawing.new("Line"), bone2=Drawing.new("Line"), bone3=Drawing.new("Line"), bone4=Drawing.new("Line"),
                icon1=Drawing.new("Image"), icon2=Drawing.new("Image"), icon3=Drawing.new("Image"),
                icon4=Drawing.new("Image"), icon5=Drawing.new("Image"), icon6=Drawing.new("Image"),
            }
        end)
        if not ok or not d then return end
        for _, l in ipairs(d.box) do l.Thickness, l.Color, l.Visible = 1, Colors.Accent, false end
        d.hpBg.Thickness, d.hpBg.Color, d.hpBg.Visible = 3, Color3.new(0, 0, 0), false
        d.hpFill.Thickness, d.hpFill.Visible = 3, false
        d.hpText.Size, d.hpText.Center, d.hpText.Outline = 12, true, true
        d.hpText.Font, d.hpText.Color = 2, Colors.Text
        d.name.Size, d.name.Center, d.name.Outline = 13, true, true
        d.name.Font, d.name.Color = 2, Colors.Text
        d.dist.Size, d.dist.Center, d.dist.Outline = 11, true, true
        d.dist.Font, d.dist.Color = 2, Colors.TextDim
        d.inv.Size, d.inv.Center, d.inv.Outline = 11, true, true
        d.inv.Font, d.inv.Color = 2, Colors.Accent
        d.tracer.Thickness, d.tracer.Color = 1, Colors.Accent
        d.head.Thickness, d.head.NumSides, d.head.Filled, d.head.Transparency = 2, 24, false, 1
        for _, b in ipairs({d.bone1,d.bone2,d.bone3,d.bone4}) do b.Thickness, b.Color = 1, Colors.Accent end
        for _, ic in ipairs({d.icon1,d.icon2,d.icon3,d.icon4,d.icon5,d.icon6}) do
            ic.Visible = false; ic.Size = Vector2.new(20, 20); ic.Transparency = 1; ic.Rounding = 3
        end
        espElements[p] = d
    end
    pcall(function()
        FOVring = Drawing.new("Circle")
        FOVring.Thickness, FOVring.Color, FOVring.Transparency, FOVring.NumSides = 1, Colors.Accent, 1, 64
        FOVring.Visible = false
    end)
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if FOVring then
                FOVring.Visible = State.AimEnabled
                if State.AimEnabled then
                    FOVring.Radius = State.AimFOV
                    FOVring.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    FOVring.Color = Colors.Accent
                end
            end
            for p, d in pairs(espElements) do
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local head = c and c:FindFirstChild("Head")
                local shouldDraw = false
                if c and r and h and h.Health > 0 then
                    local ps, on = Camera:WorldToViewportPoint(r.Position)
                    local realDist = ps.Z
                    if on and realDist <= State.PlayerEspMaxDist then
                        shouldDraw = true
                        local sy = 4500/realDist
                        local sx = 2800/realDist
                        local x, y = ps.X - sx/2, ps.Y - sy/2
                        for i, l in ipairs(d.box) do
                            l.Visible = State.EspBoxes; l.Color = Colors.Accent
                            if i==1 then l.From,l.To=Vector2.new(x,y),Vector2.new(x+sx,y)
                            elseif i==2 then l.From,l.To=Vector2.new(x+sx,y),Vector2.new(x+sx,y+sy)
                            elseif i==3 then l.From,l.To=Vector2.new(x+sx,y+sy),Vector2.new(x,y+sy)
                            else l.From,l.To=Vector2.new(x,y+sy),Vector2.new(x,y) end
                        end
                        local hpRatio = math.clamp(h.Health/math.max(h.MaxHealth,1), 0, 1)
                        d.hpBg.Visible, d.hpFill.Visible = State.EspHP, State.EspHP
                        if State.EspHP then
                            d.hpBg.From=Vector2.new(x-8,y); d.hpBg.To=Vector2.new(x-8,y+sy)
                            d.hpFill.From=Vector2.new(x-8,y+sy); d.hpFill.To=Vector2.new(x-8,y+sy-sy*hpRatio)
                            d.hpFill.Color = Color3.fromRGB(255*(1-hpRatio), 255*hpRatio, 60)
                        end
                        d.hpText.Visible = State.EspHPNum
                        if State.EspHPNum then
                            d.hpText.Text = math.floor(h.Health).." / "..math.floor(h.MaxHealth)
                            d.hpText.Position = Vector2.new(ps.X, y+sy+4)
                            d.hpText.Color = Colors.Text
                        end
                        d.name.Visible = State.EspNames
                        if State.EspNames then
                            d.name.Text = p.DisplayName.." (@"..p.Name..")"
                            d.name.Position = Vector2.new(ps.X, y-34)
                            d.name.Color = Colors.Text
                        end
                        d.dist.Visible = State.EspDist
                        if State.EspDist then
                            d.dist.Text = "["..math.floor(realDist).."m]"
                            d.dist.Position = Vector2.new(ps.X, y-18)
                            d.dist.Color = Colors.TextDim
                        end
                        local invVisible = State.EspInv
                        local iconsVisible = State.EspInvIcons
                        d.inv.Visible = invVisible
                        local invY = y+sy+22
                        if invVisible then
                            local items = getPlayerInventoryItems(p)
                            if #items>0 then
                                local lines={}
                                for _,it in ipairs(items) do table.insert(lines,(it.equipped and "[E] " or "• ")..it.name) end
                                d.inv.Text = "INV:\n"..table.concat(lines,"\n")
                                d.inv.Position = Vector2.new(ps.X+30, invY)
                                d.inv.Color = Colors.Accent
                            else
                                d.inv.Text = "INV: пусто"
                                d.inv.Position = Vector2.new(ps.X+30, invY)
                                d.inv.Color = Colors.TextDim
                            end
                        end
                        local icons = {d.icon1,d.icon2,d.icon3,d.icon4,d.icon5,d.icon6}
                        for _, ic in ipairs(icons) do ic.Visible = false end
                        if iconsVisible then
                            local items = getPlayerInventoryItems(p)
                            for idx, it in ipairs(items) do
                                if idx > #icons then break end
                                local ic = icons[idx]
                                local icon = getItemIcon(it.name)
                                if icon then
                                    ic.Image = icon
                                    ic.Position = Vector2.new(ps.X+8, invY+6+(idx-1)*18)
                                    ic.Visible = true
                                end
                            end
                        end
                        d.tracer.Visible = State.EspTracers
                        if State.EspTracers then
                            d.tracer.Color = Colors.Accent
                            d.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            d.tracer.To = Vector2.new(ps.X, ps.Y)
                        end
                        d.head.Visible = State.EspHead
                        if State.EspHead and head then
                            local hps, hon = Camera:WorldToViewportPoint(head.Position)
                            if hon then
                                d.head.Position = Vector2.new(hps.X, hps.Y); d.head.Radius = 10; d.head.Color = Colors.Accent
                            else d.head.Visible = false end
                        end
                        local skelVisible = State.EspSkeleton
                        d.bone1.Visible,d.bone2.Visible,d.bone3.Visible,d.bone4.Visible = skelVisible,skelVisible,skelVisible,skelVisible
                        if skelVisible then
                            local larm = c:FindFirstChild("Left Arm") or c:FindFirstChild("LeftHand")
                            local rarm = c:FindFirstChild("Right Arm") or c:FindFirstChild("RightHand")
                            local lleg = c:FindFirstChild("Left Leg") or c:FindFirstChild("LeftFoot")
                            local rleg = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightFoot")
                            local clr = Colors.Accent
                            d.bone1.Color,d.bone2.Color,d.bone3.Color,d.bone4.Color = clr,clr,clr,clr
                            local function to2d(part)
                                if not part then return nil end
                                local sp, on2 = Camera:WorldToViewportPoint(part.Position)
                                if on2 then return Vector2.new(sp.X, sp.Y) end
                                return nil
                            end
                            local hrp2d = to2d(r)
                            if larm and hrp2d then d.bone1.From,d.bone1.To = hrp2d,to2d(larm) or hrp2d end
                            if rarm and hrp2d then d.bone2.From,d.bone2.To = hrp2d,to2d(rarm) or hrp2d end
                            if lleg and hrp2d then d.bone3.From,d.bone3.To = hrp2d,to2d(lleg) or hrp2d end
                            if rleg and hrp2d then d.bone4.From,d.bone4.To = hrp2d,to2d(rleg) or hrp2d end
                        end
                    end
                end
                if not shouldDraw then
                    for _, l in ipairs(d.box) do l.Visible = false end
                    d.hpBg.Visible,d.hpFill.Visible,d.hpText.Visible = false,false,false
                    d.name.Visible,d.dist.Visible,d.inv.Visible = false,false,false
                    d.tracer.Visible,d.head.Visible = false,false
                    d.bone1.Visible,d.bone2.Visible,d.bone3.Visible,d.bone4.Visible = false,false,false,false
                    d.icon1.Visible,d.icon2.Visible,d.icon3.Visible,d.icon4.Visible,d.icon5.Visible,d.icon6.Visible = false,false,false,false,false,false
                end
            end
        end)
    end)
    Players.PlayerAdded:Connect(function(p) task.wait(1); createESP(p) end)
    Players.PlayerRemoving:Connect(function(p)
        local d = espElements[p]
        if d then
            pcall(function()
                for _, l in ipairs(d.box) do l:Remove() end
                d.hpBg:Remove(); d.hpFill:Remove(); d.hpText:Remove()
                d.name:Remove(); d.dist:Remove(); d.inv:Remove()
                d.tracer:Remove(); d.head:Remove()
                d.bone1:Remove(); d.bone2:Remove(); d.bone3:Remove(); d.bone4:Remove()
                d.icon1:Remove(); d.icon2:Remove(); d.icon3:Remove(); d.icon4:Remove(); d.icon5:Remove(); d.icon6:Remove()
            end)
            espElements[p] = nil
        end
    end)
    for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
end

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if State.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- HOTKEY
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
end)

-- Стартовая вкладка
showTab("VISUALS")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NyzeRust v3.9",
        Text = "Premium • RSHIFT",
        Duration = 4
    })
end)

print("[NyzeRust v3.9] Загружен. RSHIFT для открытия.")
