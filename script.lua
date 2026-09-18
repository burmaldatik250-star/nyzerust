--[[
    NyzeRust v3.0 — "Void" Edition
    Ultra Dark • Item Icons in ESP • Auto-Shoot
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
local VirtualUser      = game:GetService("VirtualUser")
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
--  ЛОКАЛИЗАЦИЯ
-- ============================================================
local LANG = "RU"
local Loc = {
    RU = {
        title = "NyzeRust", subtitle = "Void • v3.0",
        menu_hint = "МЕНЮ: RSHIFT",
        online = "ОНЛАЙН", fps = "FPS", ping = "ПИНГ",
        binds = "БИНДЫ", no_binds = "нет биндов",
        tab_visuals = "ВИЗУАЛ", tab_aim = "АИМ", tab_player = "ИГРОК",
        tab_world = "МИР", tab_settings = "НАСТР",
        cat_esp = "ESP ИГРОКОВ", cat_aim = "АИМБОТ", cat_misc = "РАЗНОЕ",
        cat_world = "МИР", cat_settings = "НАСТРОЙКИ",
        esp_boxes = "Рамки игроков", esp_names = "Ники", esp_dist = "Дистанция",
        esp_hp = "Полоса здоровья", esp_hpnum = "Число HP", esp_inv = "Инвентарь",
        esp_inv_icons = "Иконки предметов",
        esp_tracers = "Трассеры", esp_skeleton = "Скелет", esp_head = "Кружок головы",
        esp_maxdist = "Макс. дистанция",
        aim_enabled = "Включить Аимбот", aim_team = "Проверка команды",
        aim_wall = "Проверка стен", aim_smooth = "Плавность",
        aim_fov = "Радиус FOV", aim_nodrop = "Отключить падение пуль",
        autoshoot = "Авто-выстрел",
        autoshoot_key = "Кнопка стрельбы",
        autoshoot_delay = "Задержка выстрела",
        ply_speed = "Скорость", ply_speedpow = "Множитель скорости",
        ply_infjump = "Бесконечный прыжок",
        ply_freecam = "Свободная камера", ply_flyspeed = "Скорость полёта",
        wld_fullbr = "Полное освещение",
        wld_sulfur = "Сера", wld_iron = "Железо", wld_stone = "Камень",
        wld_npc = "NPC", wld_crates = "Ящики",
        wld_ore_dist = "Дистанция руды", wld_npc_dist = "Дистанция NPC",
        wld_crate_dist = "Дистанция ящиков",
        set_lang = "Язык", set_reset = "Сброс настроек",
        autoshoot_btn_hint = "ПКМ / Пробел",
    },
    EN = {
        title = "NyzeRust", subtitle = "Void • v3.0",
        menu_hint = "MENU: RSHIFT",
        online = "ONLINE", fps = "FPS", ping = "PING",
        binds = "BINDS", no_binds = "no binds",
        tab_visuals = "VISUALS", tab_aim = "AIM", tab_player = "PLAYER",
        tab_world = "WORLD", tab_settings = "SETTINGS",
        cat_esp = "PLAYER ESP", cat_aim = "AIMBOT", cat_misc = "MISC",
        cat_world = "WORLD", cat_settings = "SETTINGS",
        esp_boxes = "Player Boxes", esp_names = "Name Tags", esp_dist = "Distance",
        esp_hp = "Health Bar", esp_hpnum = "HP Number", esp_inv = "Inventory",
        esp_inv_icons = "Item Icons",
        esp_tracers = "Tracers", esp_skeleton = "Skeleton", esp_head = "Head Circle",
        esp_maxdist = "Max Distance",
        aim_enabled = "Enable Aimbot", aim_team = "Team Check",
        aim_wall = "Wall Check", aim_smooth = "Smoothing",
        aim_fov = "FOV Radius", aim_nodrop = "No Bullet Drop",
        autoshoot = "Auto-Shoot",
        autoshoot_key = "Fire Key",
        autoshoot_delay = "Shoot Delay",
        ply_speed = "Legit Speed", ply_speedpow = "Speed Multiplier",
        ply_infjump = "Infinite Jump",
        ply_freecam = "Freecam", ply_flyspeed = "Fly Speed",
        wld_fullbr = "Full Bright",
        wld_sulfur = "Sulfur", wld_iron = "Iron", wld_stone = "Stone",
        wld_npc = "NPC", wld_crates = "Crates",
        wld_ore_dist = "Ore Distance", wld_npc_dist = "NPC Distance",
        wld_crate_dist = "Crate Distance",
        set_lang = "Language", set_reset = "Reset Settings",
        autoshoot_btn_hint = "RMB / Space",
    }
}
local function t(key)
    local l = Loc[LANG] or Loc.RU
    return l[key] or key
end

-- ============================================================
--  ЕДИНАЯ ТЁМНАЯ ТЕМА (Void)
-- ============================================================
local Colors = {
    Main         = Color3.fromRGB(150, 100, 255),   -- неоново-фиолетовый акцент
    Secondary    = Color3.fromRGB(90, 60, 160),
    Accent       = Color3.fromRGB(180, 140, 255),
    Background   = Color3.fromRGB(6, 5, 9),          -- почти чёрный с фиолетовым
    Panel        = Color3.fromRGB(12, 10, 18),
    SidePanel    = Color3.fromRGB(9, 8, 13),
    Element      = Color3.fromRGB(20, 17, 28),
    ElementHover = Color3.fromRGB(32, 26, 44),
    Text         = Color3.fromRGB(230, 225, 245),
    SubText      = Color3.fromRGB(130, 120, 155),
    Stroke       = Color3.fromRGB(40, 33, 58),
    Success      = Color3.fromRGB(110, 220, 130),
    Danger       = Color3.fromRGB(230, 70, 90)
}

-- ============================================================
--  СОСТОЯНИЕ
-- ============================================================
local State = {
    EspBoxes       = false, EspNames = false, EspDist = false,
    EspHP          = false, EspHPNum = false, EspInv = false,
    EspInvIcons    = false, EspTracers = false, EspSkeleton = false,
    EspHead        = false,
    PlayerEspMaxDist = 800,
    AimEnabled     = false, TeamCheck = false, WallCheck = true,
    AimSmooth      = 0.15, AimFOV = 120, NoBulletDrop = false,
    AutoShoot      = false, AutoShootDelay = 0.08,
    LegitSpeed     = false, SpeedMultiplier = 1.5,
    InfJump        = false, FreecamEnabled = false, FreecamSpeed = 1,
    FullBright     = false, SulfurEsp = false, IronEsp = false,
    StoneEsp       = false, NpcEsp = false, CrateEsp = false,
    OreEspMaxDist  = 400, NpcEspMaxDist = 600, CrateEspMaxDist = 500,
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
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(parent, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r or 4)}, parent)
end
local function stroke(parent, color, thick, trans)
    return new("UIStroke", {
        Color = color or Colors.Stroke, Thickness = thick or 1,
        Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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
            BackgroundColor3 = on and Colors.Main or Color3.fromRGB(40, 34, 54)
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
        bindBtn.TextColor3 = Colors.Main
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
    Position = UDim2.new(0.5, -360, 0, -500),
    Size = UDim2.new(0, 720, 0, 470),
    BorderSizePixel = 0, Active = true, Draggable = true,
    Visible = false, ClipsDescendants = true
}, SG)
if isMobile then
    M.Size = UDim2.new(0, 580, 0, 370)
    M.Position = UDim2.new(0.5, -290, 0, -400)
end
corner(M, 8)
local MainStroke = stroke(M, Colors.Main, 2, 0.4)

-- Верхняя тонкая полоска
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
    BackgroundColor3 = Colors.Main, BorderSizePixel = 0, ZIndex = 2
}, TitleBar)
corner(LogoBox, 6)
stroke(LogoBox, Colors.Accent, 2, 0.2)
new("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    Text = "N", TextColor3 = Colors.Text, Font = Enum.Font.Code,
    TextSize = 22, ZIndex = 3
}, LogoBox)

new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 22),
    Position = UDim2.new(0, 70, 0, 12),
    BackgroundTransparency = 1, Text = t("title"),
    TextColor3 = Colors.Text, Font = Enum.Font.Code,
    TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)
local SubTitle = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 16),
    Position = UDim2.new(0, 72, 0, 34),
    BackgroundTransparency = 1, Text = t("subtitle") .. "  •  " .. t("menu_hint"),
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
--  TAB BAR (сверху, а не сбоку!)
-- ============================================================
local TabBar = new("Frame", {
    Size = UDim2.new(1, -24, 0, 44),
    Position = UDim2.new(0, 12, 0, 68),
    BackgroundColor3 = Colors.SidePanel,
    BorderSizePixel = 0
}, M)
corner(TabBar, 6)
stroke(TabBar, Colors.Stroke, 1, 0.5)

local TabLayout = new("UIListLayout", {
    Padding = UDim.new(0, 6),
    FillDirection = Enum.FillDirection.Horizontal,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder
}, TabBar)
padding(TabBar, 6, 6)

-- ============================================================
--  CONTAINER (контент вкладок)
-- ============================================================
local Container = new("ScrollingFrame", {
    Position = UDim2.new(0, 12, 0, 122),
    Size = UDim2.new(1, -24, 1, -134),
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

local ContainerLayout = new("UIListLayout", {
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
    pixelFrame(f, Colors.Main, UDim2.new(0, 3, 0, 14), UDim2.new(0, 2, 0.5, -7))
    new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = Colors.Main, Font = Enum.Font.Code,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
    }, f)
    return f
end

local function createToggle(parentTab, label, prop, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, -6, 0, 40),
        BackgroundColor3 = State[prop] and Colors.ElementHover or Colors.Element,
        Text = "", AutoButtonColor = false,
        LayoutOrder = order, Visible = false
    }, Container)
    corner(b, 4)
    stroke(b, Colors.Stroke, 1, 0.5)
    table.insert(parentTab, b)

    local marker = pixelFrame(b, State[prop] and Colors.Main or Colors.Stroke,
        UDim2.new(0, 3, 0, 22), UDim2.new(0, 0, 0.5, -11))
    new("TextLabel", {
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = Colors.Text, Font = Enum.Font.Code,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
    }, b)

    local status = new("Frame", {
        Size = UDim2.new(0, 34, 0, 18),
        Position = UDim2.new(1, -48, 0.5, -9),
        BackgroundColor3 = State[prop] and Colors.Main or Color3.fromRGB(40, 34, 54),
        BorderSizePixel = 0
    }, b)
    corner(status, 3)
    new("Frame", {
        Name = "Knob", Size = UDim2.new(0, 14, 0, 14),
        Position = State[prop] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0
    }, status)
    corner(status:FindFirstChild("Knob"), 2)

    b.MouseButton1Click:Connect(function()
        toggleFeature(prop, b, status)
        TweenService:Create(marker, TweenInfo.new(0.15), {
            BackgroundColor3 = State[prop] and Colors.Main or Colors.Stroke
        }):Play()
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

local function createSlider(parentTab, label, prop, min, max, order)
    local f = new("Frame", {
        Size = UDim2.new(1, -6, 0, 54),
        BackgroundColor3 = Colors.Element,
        LayoutOrder = order, Visible = false, BorderSizePixel = 0
    }, Container)
    corner(f, 4)
    stroke(f, Colors.Stroke, 1, 0.5)
    table.insert(parentTab, f)

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
        TextColor3 = Colors.Main, Font = Enum.Font.Code,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
    }, f)

    local barBg = new("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 36),
        BackgroundColor3 = Color3.fromRGB(35, 30, 46),
        BorderSizePixel = 0
    }, f)
    corner(barBg, 2)
    local fill = new("Frame", {
        Size = UDim2.new((State[prop] - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Main, BorderSizePixel = 0
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

local function createButton(parentTab, label, callback, order)
    local b = new("TextButton", {
        Size = UDim2.new(1, -6, 0, 34),
        BackgroundColor3 = Colors.Element,
        Text = "  " .. label, TextColor3 = Colors.Text,
        Font = Enum.Font.Code, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false, LayoutOrder = order, Visible = false
    }, Container)
    corner(b, 4)
    stroke(b, Colors.Stroke, 1, 0.5)
    table.insert(parentTab, b)
    b.MouseButton1Click:Connect(callback)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.ElementHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Element}):Play()
    end)
end

-- ============================================================
--  ВКЛАДКИ (сверху)
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
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = (key == name) and Colors.ElementHover or Colors.Element,
            TextColor3 = (key == name) and Colors.Main or Colors.Text
        }):Play()
    end
end

local function createTabBtn(name, label, order)
    local b = new("TextButton", {
        Size = UDim2.new(0, 110, 0, 32),
        BackgroundColor3 = Colors.Element,
        Text = label, TextColor3 = Colors.Text,
        Font = Enum.Font.Code, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        AutoButtonColor = false, LayoutOrder = order
    }, TabBar)
    corner(b, 4)
    stroke(b, Colors.Stroke, 1, 0.4)
    tabButtons[name] = b
    b.MouseButton1Click:Connect(function() showTab(name) end)
    b.MouseEnter:Connect(function()
        if b.TextColor3 ~= Colors.Main then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.ElementHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if b.TextColor3 ~= Colors.Main then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Element}):Play()
        end
    end)
end

-- ============================================================
--  НАПОЛНЕНИЕ ВКЛАДОК
-- ============================================================
createTabBtn("VISUALS",  t("tab_visuals"),  1)
createTabBtn("AIM",      t("tab_aim"),      2)
createTabBtn("PLAYER",   t("tab_player"),   3)
createTabBtn("WORLD",    t("tab_world"),    4)
createTabBtn("SETTINGS", t("tab_settings"), 5)

-- VISUALS
createCategory(t("cat_esp"), 1)
createToggle(Tabs.VISUALS, t("esp_boxes"),     "EspBoxes",    2)
createToggle(Tabs.VISUALS, t("esp_names"),     "EspNames",    3)
createToggle(Tabs.VISUALS, t("esp_dist"),      "EspDist",     4)
createToggle(Tabs.VISUALS, t("esp_hp"),        "EspHP",       5)
createToggle(Tabs.VISUALS, t("esp_hpnum"),     "EspHPNum",    6)
createToggle(Tabs.VISUALS, t("esp_inv"),       "EspInv",      7)
createToggle(Tabs.VISUALS, t("esp_inv_icons"), "EspInvIcons", 8)
createToggle(Tabs.VISUALS, t("esp_tracers"),   "EspTracers",  9)
createToggle(Tabs.VISUALS, t("esp_skeleton"),  "EspSkeleton", 10)
createToggle(Tabs.VISUALS, t("esp_head"),      "EspHead",     11)
createSlider(Tabs.VISUALS, t("esp_maxdist"),   "PlayerEspMaxDist", 100, 5000, 12)

-- AIM
createCategory(t("cat_aim"), 20)
createToggle(Tabs.AIM, t("aim_enabled"),   "AimEnabled",   21)
createToggle(Tabs.AIM, t("aim_team"),      "TeamCheck",    22)
createToggle(Tabs.AIM, t("aim_wall"),      "WallCheck",    23)
createToggle(Tabs.AIM, t("aim_nodrop"),    "NoBulletDrop", 24)
createToggle(Tabs.AIM, t("autoshoot"),     "AutoShoot",    25)
createSlider(Tabs.AIM, t("autoshoot_delay"),"AutoShootDelay",0.01, 0.5, 26)
createSlider(Tabs.AIM, t("aim_smooth"),    "AimSmooth",    0.01, 1, 27)
createSlider(Tabs.AIM, t("aim_fov"),       "AimFOV",       20, 800, 28)

-- PLAYER
createCategory(t("cat_misc"), 30)
createToggle(Tabs.PLAYER, t("ply_speed"),    "LegitSpeed",     31)
createSlider(Tabs.PLAYER, t("ply_speedpow"), "SpeedMultiplier", 1, 5, 32)
createToggle(Tabs.PLAYER, t("ply_infjump"),  "InfJump",        33)
createToggle(Tabs.PLAYER, t("ply_freecam"),  "FreecamEnabled", 34)
createSlider(Tabs.PLAYER, t("ply_flyspeed"), "FreecamSpeed",   0.1, 10, 35)

-- WORLD
createCategory(t("cat_world"), 40)
createToggle(Tabs.WORLD, t("wld_fullbr"), "FullBright", 41)
createToggle(Tabs.WORLD, t("wld_sulfur"), "SulfurEsp",  42)
createToggle(Tabs.WORLD, t("wld_iron"),   "IronEsp",    43)
createToggle(Tabs.WORLD, t("wld_stone"),  "StoneEsp",   44)
createToggle(Tabs.WORLD, t("wld_npc"),    "NpcEsp",     45)
createToggle(Tabs.WORLD, t("wld_crates"), "CrateEsp",   46)
createSlider(Tabs.WORLD, t("wld_ore_dist"),   "OreEspMaxDist",  50, 3000, 47)
createSlider(Tabs.WORLD, t("wld_npc_dist"),   "NpcEspMaxDist",  50, 3000, 48)
createSlider(Tabs.WORLD, t("wld_crate_dist"), "CrateEspMaxDist",50, 3000, 49)

-- SETTINGS
createCategory(t("cat_settings"), 60)
createButton(Tabs.SETTINGS, "Русский (RU)", function() LANG = "RU"; RefreshLocalization() end, 61)
createButton(Tabs.SETTINGS, "English (EN)", function() LANG = "EN"; RefreshLocalization() end, 62)

-- ============================================================
--  REFRESH LOCALIZATION
-- ============================================================
function RefreshLocalization()
    SubTitle.Text = t("subtitle") .. "  •  " .. t("menu_hint")
end

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
            and UDim2.new(0.5, -290, 0.5, -185)
            or  UDim2.new(0.5, -360, 0.5, -235)
        TweenService:Create(M, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = target}):Play()
    else
        if not isMobile then UserInputService.MouseIconEnabled = false end
        TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
        local target = isMobile
            and UDim2.new(0.5, -290, 0, -400)
            or  UDim2.new(0.5, -360, 0, -500)
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
        TextColor3 = Colors.Main, Font = Enum.Font.Code,
        TextSize = 24, AutoButtonColor = false
    }, SG)
    corner(OpenBtn, 6)
    stroke(OpenBtn, Colors.Main, 2, 0.2)
    OpenBtn.MouseButton1Click:Connect(toggleMenu)
end

-- ============================================================
--  ИКОНКИ ПРЕДМЕТОВ (кэш)
-- ============================================================
local IconCache = {}       -- [itemName] = rbxassetid
local IconLoading = {}

local function getItemIcon(itemName)
    if not itemName or itemName == "" then return nil end
    if IconCache[itemName] then return IconCache[itemName] end
    if IconLoading[itemName] then return nil end
    IconLoading[itemName] = true

    task.spawn(function()
        local ok, icon = pcall(function()
            -- Пытаемся получить иконку через Marketplace / Avatar API
            -- Пробуем найти в ReplicatedStorage, StarterPack, Backpack и в тултипах
            -- Основной путь: ищем Tool с этим именем где-то и берём TextureId
            local searchRoots = {game:GetService("ReplicatedStorage"), game:GetService("StarterPack"), game:GetService("Workspace")}
            for _, root in ipairs(searchRoots) do
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("Tool") and obj.Name == itemName then
                        -- Tool.TextureId или ищем ImageLabel/Decal
                        if obj.TextureId and obj.TextureId ~= "" then
                            return obj.TextureId
                        end
                        for _, d in ipairs(obj:GetDescendants()) do
                            if d:IsA("Decal") or d:IsA("Texture") then
                                return d.Texture
                            end
                            if d:IsA("ImageLabel") and d.Image ~= "" then
                                return d.Image
                            end
                        end
                    end
                end
            end
            -- Если не нашли — пробуем через rbxthumb по assetId (не работает без ID)
            return nil
        end)

        if ok and icon and icon ~= "" then
            IconCache[itemName] = icon
        else
            IconCache[itemName] = false  -- помечаем как "нет иконки"
        end
        IconLoading[itemName] = nil
    end)
    return nil
end

-- ============================================================
--  INVENTORY (с иконками)
-- ============================================================
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
--  RENDER: мир
-- ============================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        updateNpcEsp()
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
                if en then
                    applyOreVisuals(ore, ore.Name, col)
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
                if en then
                    applyCrateVisuals(crate, crate.Name, col)
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
                            local visible = true
                            if State.WallCheck then
                                local char = LocalPlayer.Character
                                if char then
                                    local params = RaycastParams.new()
                                    params.FilterType = Enum.RaycastFilterType.Exclude
                                    params.FilterDescendantsInstances = {char, v.Character}
                                    local ray = workspace:Raycast(Camera.CFrame.Position,
                                        (head.Position - Camera.CFrame.Position), params)
                                    visible = (ray == nil)
                                end
                            end
                            if visible then
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

-- Авто-выстрел: виртуальный клик мышью
local lastShoot = 0
local function tryAutoShoot(target)
    if not State.AutoShoot then return end
    if not target then return end
    local now = tick()
    if now - lastShoot < State.AutoShootDelay then return end
    lastShoot = now
    pcall(function()
        -- Виртуальный клик ЛКМ (для оружия, которое стреляет на MouseButton1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
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
        d.tracer.Thickness, d.tracer.Color = 1, Colors.Main
        d.head.Thickness, d.head.NumSides, d.head.Filled, d.head.Transparency = 2, 24, false, 1
        for _, b in ipairs({d.bone1, d.bone2, d.bone3, d.bone4}) do
            b.Thickness, b.Color = 1, Colors.Accent
        end
        -- Иконки предметов
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
        FOVring.Thickness, FOVring.Color, FOVring.Transparency, FOVring.NumSides = 1, Colors.Main, 1, 64
        FOVring.Visible = false
    end)

    RunService.RenderStepped:Connect(function()
        pcall(function()
            -- FOV + AIM
            if FOVring then
                FOVring.Visible = State.AimEnabled
                if State.AimEnabled then
                    FOVring.Radius = State.AimFOV
                    FOVring.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    FOVring.Color = Colors.Main

                    local isAiming = (not isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
                                   or (isMobile and State.AutoShoot)
                    if State.AutoShoot then isAiming = true end  -- авто-шот сам стреляет

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

                        -- BOX
                        for i, l in ipairs(d.box) do
                            l.Visible = State.EspBoxes
                            l.Color = Colors.Accent
                            if i == 1 then l.From, l.To = Vector2.new(x, y),          Vector2.new(x + sx, y)
                            elseif i == 2 then l.From, l.To = Vector2.new(x + sx, y), Vector2.new(x + sx, y + sy)
                            elseif i == 3 then l.From, l.To = Vector2.new(x + sx, y + sy), Vector2.new(x, y + sy)
                            else               l.From, l.To = Vector2.new(x, y + sy), Vector2.new(x, y) end
                        end

                        -- HP
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

                        -- NAME
                        d.name.Visible = State.EspNames
                        if State.EspNames then
                            d.name.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                            d.name.Position = Vector2.new(ps.X, y - 34)
                            d.name.Color = Colors.Text
                        end

                        -- DIST
                        d.dist.Visible = State.EspDist
                        if State.EspDist then
                            d.dist.Text = "[" .. math.floor(realDist) .. "m]"
                            d.dist.Position = Vector2.new(ps.X, y - 18)
                            d.dist.Color = Colors.SubText
                        end

                        -- INVENTORY
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

                        -- ITEM ICONS (справа от ников инвентаря)
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

                        -- TRACER
                        d.tracer.Visible = State.EspTracers
                        if State.EspTracers then
                            d.tracer.Color = Colors.Main
                            d.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            d.tracer.To   = Vector2.new(ps.X, ps.Y)
                        end

                        -- HEAD
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

                        -- SKELETON
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

showTab("VISUALS")

-- ============================================================
--  WATERMARK
-- ============================================================
local onlineUsers = math.random(180, 240)
task.spawn(function()
    while true do task.wait(20); onlineUsers = onlineUsers + math.random(-2, 3) end
end)

local WM = new("ScreenGui", {
    Name = "NyzeRustWM", ResetOnSpawn = false, IgnoreGuiInset = true
}, SG)
pcall(function() WM.Parent = CoreGui end)
if not WM.Parent then WM.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local WFrame = new("Frame", {
    BackgroundColor3 = Colors.Background,
    BackgroundTransparency = 0.15,
    Position = UDim2.new(0, 12, 0, 12),
    Size = UDim2.new(0, 240, 0, 130),
    BorderSizePixel = 0
}, WM)
corner(WFrame, 4)
stroke(WFrame, Colors.Main, 1.5, 0.2)
pixelFrame(WFrame, Colors.Main, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0), 5)

local WLabel = new("TextLabel", {
    Size = UDim2.new(1, -20, 1, -16),
    Position = UDim2.new(0, 12, 0, 8),
    BackgroundTransparency = 1, TextColor3 = Colors.Text,
    Font = Enum.Font.Code, TextSize = 12, RichText = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, WFrame)

local lastT = tick(); local frames = 0; local fps = 0
RunService.RenderStepped:Connect(function()
    pcall(function()
        frames = frames + 1
        if tick() - lastT >= 1 then fps = frames; frames = 0; lastT = tick() end
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)

        local txt = "<font color='#" .. Colors.Main:ToHex() .. "'>NyzeRust</font> v3.0\n"
        txt = txt .. t("online") .. ": <font color='#" .. Colors.Accent:ToHex() .. "'>" .. onlineUsers .. "</font>\n"
        txt = txt .. t("fps") .. ": <font color='#" .. Colors.Accent:ToHex() .. "'>" .. fps ..
              "</font>  |  " .. t("ping") .. ": <font color='#" .. Colors.Accent:ToHex() .. "'>" .. ping .. "ms</font>\n"
        txt = txt .. t("menu_hint") .. "\n"
        txt = txt .. "<font color='#" .. Colors.Stroke:ToHex() .. "'>────────────────────</font>\n"

        local bindCount = 0
        for prop, key in pairs(_G.NyzeBinds) do
            if key then
                bindCount = bindCount + 1
                local stat = State[prop] and "<font color='#22DD66'>ON</font>"
                            or "<font color='#DD4466'>OFF</font>"
                txt = txt .. "• " .. prop .. " [" .. key.Name .. "] " .. stat .. "\n"
            end
        end
        if bindCount == 0 then txt = txt .. "<font color='#666666'>" .. t("no_binds") .. "</font>" end

        WLabel.Text = txt
        WFrame.Size = UDim2.new(0, 240, 0, bindCount == 0 and 118 or (110 - 15) + bindCount * 15)
    end)
end)

-- ============================================================
--  NOTIFICATION
-- ============================================================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NyzeRust v3.0",
        Text = LANG == "RU" and "Загружено • RSHIFT чтобы открыть" or "Loaded • RSHIFT to open",
        Duration = 4
    })
end)

print("[NyzeRust v3.0] Загружен. Нажми RSHIFT чтобы открыть меню.")
