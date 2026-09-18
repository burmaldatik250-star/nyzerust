--[[
    NyzeRust v3.6 — "Pure Black" Edition
    Pure Black UI • Wall X-Ray • 3rd Person • FPS Booster
    ESP + INV + Icons • Aimbot + Auto-Shoot • Lock Auto-Code
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
--  ЕДИНАЯ ЧЁРНАЯ ТЕМА
-- ============================================================
local Colors = {
    Main         = Color3.fromRGB(200, 200, 200),
    Secondary    = Color3.fromRGB(120, 120, 120),
    Accent       = Color3.fromRGB(255, 255, 255),
    Background   = Color3.fromRGB(0, 0, 0),
    Panel        = Color3.fromRGB(8, 8, 8),
    SidePanel    = Color3.fromRGB(4, 4, 4),
    Element      = Color3.fromRGB(18, 18, 18),
    ElementHover = Color3.fromRGB(30, 30, 30),
    Text         = Color3.fromRGB(240, 240, 240),
    SubText      = Color3.fromRGB(140, 140, 140),
    Stroke       = Color3.fromRGB(45, 45, 45),
    Success      = Color3.fromRGB(110, 220, 130),
    Danger       = Color3.fromRGB(230, 70, 90)
}

-- ============================================================
--  СОСТОЯНИЕ
-- ============================================================
local State = {
    EspBoxes = false, EspNames = false, EspDist = false,
    EspHP = false, EspHPNum = false, EspInv = false,
    EspInvIcons = false, EspTracers = false, EspSkeleton = false,
    EspHead = false,
    PlayerEspMaxDist = 800,
    AimEnabled = false, TeamCheck = false, WallCheck = true,
    AimSmooth = 0.15, AimFOV = 120, NoBulletDrop = false,
    AutoShoot = false, AutoShootDelay = 0.08,
    LegitSpeed = false, SpeedMultiplier = 1.5,
    InfJump = false, FreecamEnabled = false, FreecamSpeed = 1,
    FullBright = false, SulfurEsp = false, IronEsp = false,
    StoneEsp = false, NpcEsp = false, CrateEsp = false,
    OreEspMaxDist = 400, NpcEspMaxDist = 600, CrateEspMaxDist = 500,
    XRay = false,
    LockAutoCode = false,
    ThirdPerson      = false,
    ThirdPersonDist  = 15,
    OptLowGFX      = false,
    OptNoEffects   = false,
    OptNoParticles = false,
    OptNoDecals    = false,
    OptNoShadows   = false,
    OptFarParts    = false,
    OptLowTerrain  = false,
    OptNoSounds    = false,
    OptRenderDist  = 1500,
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
    return new("UICorner", {CornerRadius = UDim.new(0, r or 4)}, parent)
end

local function stroke(parent, color, thick, trans)
    return new("UIStroke", {
        Color = color or Colors.Stroke, Thickness = thick or 1,
        Transparency = trans or 0,
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

local function pixelFrame(parent, color, size, pos, zindex)
    return new("Frame", {
        BackgroundColor3 = color, BorderSizePixel = 0,
        Size = size, Position = pos or UDim2.new(), ZIndex = zindex or 1
    }, parent)
end

-- ============================================================
--  TOGGLE LOGIC
-- ============================================================
local function refreshToggleUI(prop, button, statusFrame)
    if not button or not statusFrame then return end
    local on = State[prop]
    pcall(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Colors.ElementHover or Colors.Element
        }):Play()
        TweenService:Create(statusFrame, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Colors.Accent or Color3.fromRGB(40, 40, 40)
        }):Play()
        local knob = statusFrame:FindFirstChild("Knob")
        if knob then
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
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
        Name = "Bind", Size = UDim2.new(0, 56, 0, 22),
        Position = UDim2.new(1, -102, 0.5, -11),
        BackgroundColor3 = Colors.Element, Text = "—",
        TextColor3 = Colors.SubText, Font = Enum.Font.Code,
        TextSize = 12, AutoButtonColor = false, ZIndex = 3
    }, parent)
    corner(bindBtn, 3)
    stroke(bindBtn, Colors.Stroke, 1, 0.4)

    local isWaiting = false
    bindBtn.MouseButton1Click:Connect(function()
        isWaiting = true
        bindBtn.Text = "..."
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
            bindBtn.TextColor3 = Colors.SubText
        elseif not isWaiting and input.UserInputType == Enum.UserInputType.Keyboard then
            if _G.NyzeBinds[prop] and input.KeyCode == _G.NyzeBinds[prop] then
                toggleFeature(prop, button, statusFrame)
            end
        end
    end)
end

-- ============================================================
--  ГЛАВНОЕ ОКНО
-- ============================================================
local M = new("Frame", {
    BackgroundColor3 = Colors.Background,
    Position = UDim2.new(0.5, -320, 0, -500),
    Size = UDim2.new(0, 640, 0, 480),
    BorderSizePixel = 0, Active = true, Draggable = true,
    Visible = false, ClipsDescendants = true
}, SG)
if isMobile then
    M.Size = UDim2.new(0, 500, 0, 380)
    M.Position = UDim2.new(0.5, -250, 0, -400)
end
corner(M, 8)
local MainStroke = stroke(M, Colors.Main, 1.5, 0.4)

pixelFrame(M, Colors.Main, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0), 5)

-- ============================================================
--  TITLE BAR
-- ============================================================
local TitleBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 58), Position = UDim2.new(0, 0, 0, 2),
    BackgroundColor3 = Colors.SidePanel, BorderSizePixel = 0
}, M)

local LogoBox = new("Frame", {
    Size = UDim2.new(0, 42, 0, 42),
    Position = UDim2.new(0, 16, 0.5, -21),
    BackgroundColor3 = Colors.Background, BorderSizePixel = 0, ZIndex = 2
}, TitleBar)
corner(LogoBox, 6)
stroke(LogoBox, Colors.Accent, 2, 0.2)
new("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    Text = "N", TextColor3 = Colors.Accent, Font = Enum.Font.Code,
    TextSize = 22, ZIndex = 3
}, LogoBox)

new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 22),
    Position = UDim2.new(0, 70, 0, 12),
    BackgroundTransparency = 1, Text = "NyzeRust",
    TextColor3 = Colors.Text, Font = Enum.Font.Code,
    TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)
new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 16),
    Position = UDim2.new(0, 72, 0, 34),
    BackgroundTransparency = 1, Text = "Pure Black • v3.6  •  RSHIFT",
    TextColor3 = Colors.SubText, Font = Enum.Font.Code,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)

local CloseBtn = new("TextButton", {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -44, 0.5, -16),
    BackgroundColor3 = Colors.Element, Text = "×",
    TextColor3 = Colors.Text, Font = Enum.Font.Code,
    TextSize = 20, AutoButtonColor = false, ZIndex = 2
}, TitleBar)
corner(CloseBtn, 4)
CloseBtn.MouseButton1Click:Connect(function() toggleMenu() end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Danger}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Element}):Play()
end)

-- ============================================================
--  CONTAINER
-- ============================================================
local Container = new("ScrollingFrame", {
    Position = UDim2.new(0, 12, 0, 68),
    Size = UDim2.new(1, -24, 1, -80),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0,
    ScrollBarThickness = isMobile and 0 or 3,
    ScrollBarImageColor3 = Colors.Main,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, M)
corner(Container, 6)
stroke(Container, Colors.Stroke, 1, 0.5)
padding(Container, 12)

new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Container)

-- ============================================================
--  UI ФУНКЦИИ
-- ============================================================
local function createCategory(title, order)
    local f = new("Frame", {
        Size = UDim2.new(1, -6, 0, 28),
        BackgroundTransparency = 1, LayoutOrder = order
    }, Container)
    pixelFrame(f, Colors.Accent, UDim2.new(0, 2, 0, 14), UDim2.new(0, 2, 0.5, -7))
    new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = Colors.Accent, Font = Enum.Font.Code,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
    }, f)
    return f
end

local function createToggle(label, prop, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, -6, 0, 40),
        BackgroundColor3 = State[prop] and Colors.ElementHover or Colors.Element,
        Text = "", AutoButtonColor = false, LayoutOrder = order
    }, Container)
    corner(b, 4)
    stroke(b, Colors.Stroke, 1, 0.5)

    pixelFrame(b, State[prop] and Colors.Accent or Colors.Stroke,
        UDim2.new(0, 2, 0, 22), UDim2.new(0, 0, 0.5, -11))

    new("TextLabel", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = Colors.Text, Font = Enum.Font.Code,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
    }, b)

    local status = new("Frame", {
        Size = UDim2.new(0, 34, 0, 18),
        Position = UDim2.new(1, -48, 0.5, -9),
        BackgroundColor3 = State[prop] and Colors.Accent or Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0
    }, b)
    corner(status, 3)

    local knob = new("Frame", {
        Name = "Knob", Size = UDim2.new(0, 14, 0, 14),
        Position = State[prop] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = State[prop] and Colors.Background or Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, status)
    corner(knob, 2)

    b.MouseButton1Click:Connect(function()
        toggleFeature(prop, b, status)
        local marker = b:FindFirstChildOfClass("Frame")
        if marker and marker ~= status then
            TweenService:Create(marker, TweenInfo.new(0.15), {
                BackgroundColor3 = State[prop] and Colors.Accent or Colors.Stroke
            }):Play()
        end
    end)
    b.MouseEnter:Connect(function()
        if not State[prop] then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.ElementHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if not State[prop] then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Element}):Play()
        end
    end)
    createBindBtn(b, prop, b, status)
end

local function createSlider(label, prop, min, max, order)
    local f = new("Frame", {
        Size = UDim2.new(1, -6, 0, 54),
        BackgroundColor3 = Colors.Element,
        LayoutOrder = order, BorderSizePixel = 0
    }, Container)
    corner(f, 4)
    stroke(f, Colors.Stroke, 1, 0.5)

    new("TextLabel", {
        Size = UDim2.new(1, -110, 0, 18),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = Colors.Text, Font = Enum.Font.Code,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
    }, f)

    local valLbl = new("TextLabel", {
        Size = UDim2.new(0, 90, 0, 18),
        Position = UDim2.new(1, -104, 0, 8),
        BackgroundTransparency = 1, Text = tostring(State[prop]),
        TextColor3 = Colors.Accent, Font = Enum.Font.Code,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
    }, f)

    local barBg = new("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 36),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0
    }, f)
    corner(barBg, 2)

    local fill = new("Frame", {
        Size = UDim2.new((State[prop] - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Accent, BorderSizePixel = 0
    }, barBg)
    corner(fill, 2)

    local trigger = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Text = ""
    }, barBg)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        val = (max > 5) and math.floor(val) or math.floor(val * 100) / 100
        State[prop] = val
        fill.Size = UDim2.new(pos, 0, 1, 0)
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
end

-- ============================================================
--  НАПОЛНЕНИЕ
-- ============================================================
local O = 0
local function nextO() O = O + 1; return O end

createCategory("ESP ИГРОКОВ", nextO())
createToggle("Рамки игроков",      "EspBoxes",   nextO())
createToggle("Ники",               "EspNames",   nextO())
createToggle("Дистанция",          "EspDist",    nextO())
createToggle("Полоса здоровья",    "EspHP",      nextO())
createToggle("Число HP",           "EspHPNum",   nextO())
createToggle("Инвентарь",          "EspInv",     nextO())
createToggle("Иконки предметов",   "EspInvIcons",nextO())
createToggle("Трассеры",           "EspTracers", nextO())
createToggle("Скелет",             "EspSkeleton",nextO())
createToggle("Кружок головы",      "EspHead",    nextO())
createSlider("Макс. дистанция",    "PlayerEspMaxDist", 100, 5000, nextO())

createCategory("АИМБОТ", nextO())
createToggle("Включить Аимбот",    "AimEnabled",  nextO())
createToggle("Проверка команды",   "TeamCheck",   nextO())
createToggle("Проверка стен",      "WallCheck",   nextO())
createToggle("Отключить падение пуль", "NoBulletDrop", nextO())
createToggle("Авто-выстрел",       "AutoShoot",   nextO())
createSlider("Задержка выстрела",  "AutoShootDelay", 0.01, 0.5, nextO())
createSlider("Плавность",          "AimSmooth",   0.01, 1, nextO())
createSlider("Радиус FOV",         "AimFOV",      20, 800, nextO())

createCategory("ИГРОК", nextO())
createToggle("Скорость",           "LegitSpeed",     nextO())
createSlider("Множитель скорости", "SpeedMultiplier", 1, 5, nextO())
createToggle("Бесконечный прыжок", "InfJump",        nextO())
createToggle("Свободная камера",   "FreecamEnabled", nextO())
createSlider("Скорость полёта",    "FreecamSpeed",   0.1, 10, nextO())

createCategory("КАМЕРА", nextO())
createToggle("Третье лицо",        "ThirdPerson",     nextO())
createSlider("Дистанция камеры",   "ThirdPersonDist", 3, 50, nextO())

createCategory("ВИЗУАЛ", nextO())
createToggle("X-Ray стен",         "XRay",       nextO())
createToggle("Полное освещение",   "FullBright", nextO())

createCategory("МИР", nextO())
createToggle("Сера",     "SulfurEsp", nextO())
createToggle("Железо",   "IronEsp",   nextO())
createToggle("Камень",   "StoneEsp",  nextO())
createToggle("NPC",      "NpcEsp",    nextO())
createToggle("Ящики",    "CrateEsp",  nextO())
createSlider("Дистанция руды",      "OreEspMaxDist",   50, 3000, nextO())
createSlider("Дистанция NPC",       "NpcEspMaxDist",   50, 3000, nextO())
createSlider("Дистанция ящиков",    "CrateEspMaxDist", 50, 3000, nextO())

createCategory("РАЗНОЕ", nextO())
createToggle("Автоввод кода на замках", "LockAutoCode", nextO())

createCategory("ОПТИМИЗАЦИЯ", nextO())
createToggle("Low GFX (всё сразу)",    "OptLowGFX",       nextO())
createToggle("Убрать эффекты",         "OptNoEffects",    nextO())
createToggle("Убрать частицы",         "OptNoParticles",  nextO())
createToggle("Убрать Decals/Textures", "OptNoDecals",     nextO())
createToggle("Убрать тени",            "OptNoShadows",    nextO())
createToggle("Убрать дальние объекты", "OptFarParts",     nextO())
createToggle("Упростить террейн",      "OptLowTerrain",   nextO())
createToggle("Убрать звуки",           "OptNoSounds",     nextO())
createSlider("Дальность прорисовки",   "OptRenderDist",   100, 5000, nextO())

-- ============================================================
--  TOGGLE MENU
-- ============================================================
local menuToggled = false
function toggleMenu()
    menuToggled = not menuToggled
    if menuToggled then
        M.Visible = true
        if not isMobile then UserInputService.MouseIconEnabled = true end
        TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 12}):Play()
        local target = isMobile
            and UDim2.new(0.5, -250, 0.5, -190)
            or  UDim2.new(0.5, -320, 0.5, -240)
        TweenService:Create(M, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = target}):Play()
    else
        if not isMobile then UserInputService.MouseIconEnabled = false end
        TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
        local target = isMobile
            and UDim2.new(0.5, -250, 0, -400)
            or  UDim2.new(0.5, -320, 0, -500)
        local tw = TweenService:Create(M, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = target})
        tw:Play()
        tw.Completed:Connect(function()
            if not menuToggled then M.Visible = false end
        end)
    end
end

-- ============================================================
--  МОБИЛЬНАЯ КНОПКА
-- ============================================================
if isMobile then
    local OpenBtn = new("TextButton", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0, 12, 0.42, 0),
        BackgroundColor3 = Colors.SidePanel, Text = "N",
        TextColor3 = Colors.Accent, Font = Enum.Font.Code,
        TextSize = 24, AutoButtonColor = false
    }, SG)
    corner(OpenBtn, 6)
    stroke(OpenBtn, Colors.Accent, 2, 0.2)
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
stroke(WFrame, Colors.Accent, 1, 0.5)

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
    l.Font = Enum.Font.Code
    l.TextSize = 12
    l.TextColor3 = color
    l.Text = text
    l.LayoutOrder = order
    l.Parent = WRow
    return l
end

local segFpsVal  = makeSeg("0", Colors.Accent, 5)
local segPingVal = makeSeg("0ms", Colors.Accent, 8)
makeSeg("NyzeRust", Colors.Accent, 1)
makeSeg("v3.6", Colors.SubText, 2)
makeSeg("|", Colors.Stroke, 3)
makeSeg("FPS:", Colors.SubText, 4)
makeSeg("|", Colors.Stroke, 6)
makeSeg("PING:", Colors.SubText, 7)
makeSeg("|", Colors.Stroke, 9)
makeSeg("MENU:", Colors.SubText, 10)
makeSeg("RSHIFT", Colors.Accent, 11)

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
--  THIRD PERSON CAMERA
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
    while true do
        task.wait(0.2)
        pcall(applyThirdPerson)
    end
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

-- ============================================================
--  X-RAY WALLS (прозрачные стены — видно игроков сквозь них)
-- ============================================================
local xrayWallOriginals = {}
local xrayApplied = false

local function isCharacterPart(part)
    local parent = part.Parent
    local grandparent = parent and parent.Parent
    if parent and parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
        return true
    end
    if grandparent and grandparent:IsA("Model") and grandparent:FindFirstChildOfClass("Humanoid") then
        return true
    end
    return false
end

local function applyXRayWalls()
    if State.XRay and not xrayApplied then
        xrayApplied = true
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not isCharacterPart(obj) then
                xrayWallOriginals[obj] = {
                    transparency = obj.Transparency,
                    ltm = obj.LocalTransparencyModifier
                }
                obj.LocalTransparencyModifier = 0.85
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                local part = obj.Parent
                if part and not (part:IsA("BasePart") and isCharacterPart(part)) then
                    xrayWallOriginals[obj] = {transparency = obj.Transparency}
                    obj.Transparency = 0.85
                end
            end
        end
    elseif not State.XRay and xrayApplied then
        xrayApplied = false
        for obj, orig in pairs(xrayWallOriginals) do
            pcall(function()
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then
                        obj.LocalTransparencyModifier = orig.ltm
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Transparency = orig.transparency
                    end
                end
            end)
        end
        xrayWallOriginals = {}
    end
end

-- Цикл обновления X-Ray (если карта подгружается — новые стены тоже становятся прозрачными)
task.spawn(function()
    while true do
        task.wait(3)
        if State.XRay then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not isCharacterPart(obj) then
                    if xrayWallOriginals[obj] == nil then
                        xrayWallOriginals[obj] = {
                            transparency = obj.Transparency,
                            ltm = obj.LocalTransparencyModifier
                        }
                        pcall(function() obj.LocalTransparencyModifier = 0.85 end)
                    end
                end
            end
        end
    end
end)

-- ============================================================
--  LOCK AUTO-CODE
-- ============================================================
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
                local dist = (root.Position - pos).Magnitude
                if dist <= prompt.MaxActivationDistance then
                    fireproximityprompt(prompt)
                end
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
                local dist = (root.Position - pos).Magnitude
                if dist <= cd.MaxActivationDistance then
                    fireclickdetector(cd)
                end
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

-- ============================================================
--  WORLD ESP
-- ============================================================
local function applyCrateVisuals(obj, name, color)
    if not obj:FindFirstChild("CrateHighlight") then
        local h = Instance.new("Highlight", obj)
        h.Name = "CrateHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if not obj:FindFirstChild("CrateTag") then
        local bg = new("BillboardGui", {
            Name = "CrateTag", AlwaysOnTop = true,
            Size = UDim2.new(0, 120, 0, 40),
            ExtentsOffset = Vector3.new(0, 2, 0)
        }, obj)
        new("TextLabel", {
            Name = "Label", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), TextSize = 13,
            TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code,
            TextStrokeTransparency = 0
        }, bg)
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
        local bg = new("BillboardGui", {
            Name = "OreTag", AlwaysOnTop = true,
            Size = UDim2.new(0, 100, 0, 40),
            ExtentsOffset = Vector3.new(0, 2, 0)
        }, obj)
        new("TextLabel", {
            Name = "Label", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), TextSize = 13,
            TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code,
            TextStrokeTransparency = 0
        }, bg)
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

-- ============================================================
--  ЛОГИКА ОПТИМИЗАЦИИ
-- ============================================================
local OptBackup = {
    effects = {}, particles = {}, decals = {}, shadows = {}, parts = {}, sounds = {},
}

local function optRestoreAll()
    for e, v in pairs(OptBackup.effects) do
        pcall(function() if e and e.Parent then e.Enabled = v end end)
    end
    for p, v in pairs(OptBackup.particles) do
        pcall(function() if p and p.Parent then p.Enabled = v end end)
    end
    for d, v in pairs(OptBackup.decals) do
        pcall(function() if d and d.Parent then d.Transparency = v end end)
    end
    for s, v in pairs(OptBackup.shadows) do
        pcall(function() if s and s.Parent then s.CastShadow = v end end)
    end
    for pt, v in pairs(OptBackup.parts) do
        pcall(function() if pt and pt.Parent then pt.Transparency = v end end)
    end
    for sd, v in pairs(OptBackup.sounds) do
        pcall(function() if sd and sd.Parent then sd.Volume = v end end)
    end
    OptBackup.effects = {}; OptBackup.particles = {}; OptBackup.decals = {}
    OptBackup.shadows = {}; OptBackup.parts = {}; OptBackup.sounds = {}
end

local function optApplyEffects()
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Atmosphere") or e:IsA("Sky") then
            if OptBackup.effects[e] == nil then
                OptBackup.effects[e] = e.Enabled
                e.Enabled = false
            end
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
            if OptBackup.particles[obj] == nil then
                OptBackup.particles[obj] = obj.Enabled
                obj.Enabled = false
            end
        end
    end
end

local function optApplyDecals()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if OptBackup.decals[obj] == nil then
                OptBackup.decals[obj] = obj.Transparency
                obj.Transparency = 1
            end
        end
    end
end

local function optApplyShadows()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CastShadow then
            if OptBackup.shadows[obj] == nil then
                OptBackup.shadows[obj] = obj.CastShadow
                obj.CastShadow = false
            end
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
                if OptBackup.parts[obj] == nil then
                    OptBackup.parts[obj] = obj.Transparency
                    obj.Transparency = 1
                end
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
            if OptBackup.sounds[obj] == nil then
                OptBackup.sounds[obj] = obj.Volume
                obj.Volume = 0
            end
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
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.ShadowSoftness = 0
        end)
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

-- ============================================================
--  RENDER: мир
-- ============================================================
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
--  AIMBOT + AUTO-SHOOT
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

-- ============================================================
--  ИКОНКИ ПРЕДМЕТОВ
-- ============================================================
local IconCache = {}
local IconLoading = {}

local function getItemIcon(itemName)
    if not itemName or itemName == "" then return nil end
    if IconCache[itemName] ~= nil then
        return IconCache[itemName] or nil
    end
    if IconLoading[itemName] then return nil end
    IconLoading[itemName] = true

    task.spawn(function()
        local ok, icon = pcall(function()
            local searchRoots = {
                game:GetService("ReplicatedStorage"),
                game:GetService("StarterPack"),
                workspace
            }
            for _, root in ipairs(searchRoots) do
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

-- ============================================================
--  ESP (Drawing)
-- ============================================================
local espElements = {}
local FOVring = nil

if hasDrawing then
    local function createESP(p)
        if p == LocalPlayer or espElements[p] then return end
        local ok, d = pcall(function()
            return {
                box     = {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
                hpBg    = Drawing.new("Line"),
                hpFill  = Drawing.new("Line"),
                hpText  = Drawing.new("Text"),
                name    = Drawing.new("Text"),
                dist    = Drawing.new("Text"),
                inv     = Drawing.new("Text"),
                tracer  = Drawing.new("Line"),
                head    = Drawing.new("Circle"),
                bone1   = Drawing.new("Line"),
                bone2   = Drawing.new("Line"),
                bone3   = Drawing.new("Line"),
                bone4   = Drawing.new("Line"),
                icon1   = Drawing.new("Image"),
                icon2   = Drawing.new("Image"),
                icon3   = Drawing.new("Image"),
                icon4   = Drawing.new("Image"),
                icon5   = Drawing.new("Image"),
                icon6   = Drawing.new("Image"),
            }
        end)
        if not ok or not d then return end

        for _, l in ipairs(d.box) do
            l.Thickness, l.Color, l.Visible = 1, Colors.Accent, false
        end
        d.hpBg.Thickness, d.hpBg.Color, d.hpBg.Visible = 3, Color3.new(0, 0, 0), false
        d.hpFill.Thickness, d.hpFill.Visible = 3, false
        d.hpText.Size, d.hpText.Center, d.hpText.Outline = 12, true, true
        d.hpText.Font, d.hpText.Color = 2, Colors.Text
        d.name.Size, d.name.Center, d.name.Outline = 13, true, true
        d.name.Font, d.name.Color = 2, Colors.Text
        d.dist.Size, d.dist.Center, d.dist.Outline = 11, true, true
        d.dist.Font, d.dist.Color = 2, Colors.SubText
        d.inv.Size, d.inv.Center, d.inv.Outline = 11, true, true
        d.inv.Font, d.inv.Color = 2, Colors.Accent
        d.tracer.Thickness, d.tracer.Color = 1, Colors.Accent
        d.head.Thickness, d.head.NumSides, d.head.Filled, d.head.Transparency = 2, 24, false, 1
        for _, b in ipairs({d.bone1, d.bone2, d.bone3, d.bone4}) do
            b.Thickness, b.Color = 1, Colors.Accent
        end
        for _, ic in ipairs({d.icon1, d.icon2, d.icon3, d.icon4, d.icon5, d.icon6}) do
            ic.Visible = false
            ic.Size = Vector2.new(20, 20)
            ic.Transparency = 1
            ic.Rounding = 3
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
                    FOVring.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    FOVring.Color = Colors.Accent

                    local isAiming = (not isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
                                   or (isMobile and State.AutoShoot)
                    if State.AutoShoot then isAiming = true end

                    if isAiming then
                        local tgt = getClosest()
                        if tgt then
                            Camera.CFrame = Camera.CFrame:Lerp(
                                CFrame.new(Camera.CFrame.Position, tgt.Position),
                                State.AimSmooth)
                            if State.AutoShoot then tryAutoShoot(tgt) end
                        end
                    end
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
                        local sy = 4500 / realDist
                        local sx = 2800 / realDist
                        local x, y = ps.X - sx / 2, ps.Y - sy / 2

                        for i, l in ipairs(d.box) do
                            l.Visible = State.EspBoxes
                            l.Color = Colors.Accent
                            if i == 1 then l.From, l.To = Vector2.new(x, y),          Vector2.new(x + sx, y)
                            elseif i == 2 then l.From, l.To = Vector2.new(x + sx, y), Vector2.new(x + sx, y + sy)
                            elseif i == 3 then l.From, l.To = Vector2.new(x + sx, y + sy), Vector2.new(x, y + sy)
                            else               l.From, l.To = Vector2.new(x, y + sy), Vector2.new(x, y) end
                        end

                        local hpRatio = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
                        d.hpBg.Visible, d.hpFill.Visible = State.EspHP, State.EspHP
                        if State.EspHP then
                            d.hpBg.From   = Vector2.new(x - 8, y)
                            d.hpBg.To     = Vector2.new(x - 8, y + sy)
                            d.hpFill.From = Vector2.new(x - 8, y + sy)
                            d.hpFill.To   = Vector2.new(x - 8, y + sy - sy * hpRatio)
                            d.hpFill.Color = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 60)
                        end
                        d.hpText.Visible = State.EspHPNum
                        if State.EspHPNum then
                            d.hpText.Text = math.floor(h.Health) .. " / " .. math.floor(h.MaxHealth)
                            d.hpText.Position = Vector2.new(ps.X, y + sy + 4)
                            d.hpText.Color = Colors.Text
                        end

                        d.name.Visible = State.EspNames
                        if State.EspNames then
                            d.name.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                            d.name.Position = Vector2.new(ps.X, y - 34)
                            d.name.Color = Colors.Text
                        end

                        d.dist.Visible = State.EspDist
                        if State.EspDist then
                            d.dist.Text = "[" .. math.floor(realDist) .. "m]"
                            d.dist.Position = Vector2.new(ps.X, y - 18)
                            d.dist.Color = Colors.SubText
                        end

                        local invVisible = State.EspInv
                        local iconsVisible = State.EspInvIcons
                        d.inv.Visible = invVisible
                        local invY = y + sy + 22
                        if invVisible then
                            local items = getPlayerInventoryItems(p)
                            if #items > 0 then
                                local lines = {}
                                for _, it in ipairs(items) do
                                    table.insert(lines, (it.equipped and "[E] " or "• ") .. it.name)
                                end
                                d.inv.Text = "INV:\n" .. table.concat(lines, "\n")
                                d.inv.Position = Vector2.new(ps.X + 30, invY)
                                d.inv.Color = Colors.Accent
                            else
                                d.inv.Text = "INV: пусто"
                                d.inv.Position = Vector2.new(ps.X + 30, invY)
                                d.inv.Color = Colors.SubText
                            end
                        end
                        local icons = {d.icon1, d.icon2, d.icon3, d.icon4, d.icon5, d.icon6}
                        for _, ic in ipairs(icons) do ic.Visible = false end
                        if iconsVisible then
                            local items = getPlayerInventoryItems(p)
                            for idx, it in ipairs(items) do
                                if idx > #icons then break end
                                local ic = icons[idx]
                                local icon = getItemIcon(it.name)
                                if icon then
                                    ic.Image = icon
                                    ic.Position = Vector2.new(ps.X + 8, invY + 6 + (idx - 1) * 18)
                                    ic.Visible = true
                                end
                            end
                        end

                        d.tracer.Visible = State.EspTracers
                        if State.EspTracers then
                            d.tracer.Color = Colors.Accent
                            d.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            d.tracer.To   = Vector2.new(ps.X, ps.Y)
                        end

                        d.head.Visible = State.EspHead
                        if State.EspHead and head then
                            local hps, hon = Camera:WorldToViewportPoint(head.Position)
                            if hon then
                                d.head.Position = Vector2.new(hps.X, hps.Y)
                                d.head.Radius = 10
                                d.head.Color = Colors.Accent
                            else
                                d.head.Visible = false
                            end
                        end

                        local skelVisible = State.EspSkeleton
                        d.bone1.Visible, d.bone2.Visible, d.bone3.Visible, d.bone4.Visible =
                            skelVisible, skelVisible, skelVisible, skelVisible
                        if skelVisible then
                            local larm = c:FindFirstChild("Left Arm") or c:FindFirstChild("LeftHand")
                            local rarm = c:FindFirstChild("Right Arm") or c:FindFirstChild("RightHand")
                            local lleg = c:FindFirstChild("Left Leg") or c:FindFirstChild("LeftFoot")
                            local rleg = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightFoot")
                            local clr = Colors.Accent
                            d.bone1.Color, d.bone2.Color, d.bone3.Color, d.bone4.Color = clr, clr, clr, clr
                            local function to2d(part)
                                if not part then return nil end
                                local sp, on2 = Camera:WorldToViewportPoint(part.Position)
                                if on2 then return Vector2.new(sp.X, sp.Y) end
                                return nil
                            end
                            local hrp2d = to2d(r)
                            if larm and hrp2d then d.bone1.From, d.bone1.To = hrp2d, to2d(larm) or hrp2d end
                            if rarm and hrp2d then d.bone2.From, d.bone2.To = hrp2d, to2d(rarm) or hrp2d end
                            if lleg and hrp2d then d.bone3.From, d.bone3.To = hrp2d, to2d(lleg) or hrp2d end
                            if rleg and hrp2d then d.bone4.From, d.bone4.To = hrp2d, to2d(rleg) or hrp2d end
                        end
                    end
                end

                if not shouldDraw then
                    for _, l in ipairs(d.box) do l.Visible = false end
                    d.hpBg.Visible, d.hpFill.Visible, d.hpText.Visible = false, false, false
                    d.name.Visible, d.dist.Visible, d.inv.Visible = false, false, false
                    d.tracer.Visible, d.head.Visible = false, false
                    d.bone1.Visible, d.bone2.Visible, d.bone3.Visible, d.bone4.Visible = false, false, false, false
                    d.icon1.Visible, d.icon2.Visible, d.icon3.Visible, d.icon4.Visible, d.icon5.Visible, d.icon6.Visible = false, false, false, false, false, false
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

-- ============================================================
--  INFINITE JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if State.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
--  HOTKEY
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
end)

-- ============================================================
--  NOTIFICATION
-- ============================================================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NyzeRust v3.6",
        Text = "Pure Black • Wall X-Ray • RSHIFT",
        Duration = 4
    })
end)

print("[NyzeRust v3.6] Загружен. RSHIFT для открытия.")
