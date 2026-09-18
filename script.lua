--[[
    ███╗   ██╗██╗   ██╗███████╗███████╗██████╗ ██╗   ██╗███████╗████████╗
    ████╗  ██║╚██╗ ██╔╝╚══███╔╝██╔════╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝
    ██╔██╗ ██║ ╚████╔╝   ███╔╝ █████╗  ██████╔╝██║   ██║███████╗   ██║   
    ██║╚██╗██║  ╚██╔╝   ███╔╝  ██╔══╝  ██╔══██╗██║   ██║╚════██║   ██║   
    ██║ ╚████║   ██║   ███████╗███████╗██║  ██║╚██████╔╝███████║   ██║   
    ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   
                    NyzeRust v1.0 — Xeno Edition
--]]

-- ============ СЕРВИСЫ ============
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local Stats            = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local isMobile    = UserInputService.TouchEnabled

-- ============ ПРОВЕРКА DRAWING ============
local hasDrawing = pcall(function()
    local t = Drawing.new("Line")
    t:Remove()
    return true
end)

if not hasDrawing then
    warn("[NyzeRust] Твой Xeno не поддерживает Drawing. ESP работать не будет, но меню откроется.")
end

-- ============ ТЕМЫ ============
local Themes = {
    NyzeDark = {
        Main         = Color3.fromRGB(0, 170, 255),
        Secondary    = Color3.fromRGB(120, 90, 255),
        Accent       = Color3.fromRGB(0, 255, 200),
        Background   = Color3.fromRGB(14, 15, 20),
        Panel        = Color3.fromRGB(20, 22, 30),
        SidePanel    = Color3.fromRGB(17, 18, 25),
        Element      = Color3.fromRGB(28, 30, 40),
        ElementHover = Color3.fromRGB(38, 41, 55),
        Text         = Color3.fromRGB(235, 238, 245),
        SubText      = Color3.fromRGB(140, 145, 160),
        Stroke       = Color3.fromRGB(45, 48, 62)
    },
    Carbon = {
        Main         = Color3.fromRGB(230, 230, 235),
        Secondary    = Color3.fromRGB(150, 150, 160),
        Accent       = Color3.fromRGB(255, 90, 90),
        Background   = Color3.fromRGB(10, 10, 12),
        Panel        = Color3.fromRGB(18, 18, 22),
        SidePanel    = Color3.fromRGB(14, 14, 18),
        Element      = Color3.fromRGB(26, 26, 32),
        ElementHover = Color3.fromRGB(36, 36, 44),
        Text         = Color3.fromRGB(240, 240, 245),
        SubText      = Color3.fromRGB(130, 130, 140),
        Stroke       = Color3.fromRGB(42, 42, 50)
    },
    Violet = {
        Main         = Color3.fromRGB(160, 100, 255),
        Secondary    = Color3.fromRGB(90, 60, 200),
        Accent       = Color3.fromRGB(255, 100, 200),
        Background   = Color3.fromRGB(13, 10, 20),
        Panel        = Color3.fromRGB(20, 16, 30),
        SidePanel    = Color3.fromRGB(17, 13, 26),
        Element      = Color3.fromRGB(30, 24, 44),
        ElementHover = Color3.fromRGB(42, 34, 60),
        Text         = Color3.fromRGB(238, 232, 250),
        SubText      = Color3.fromRGB(150, 140, 175),
        Stroke       = Color3.fromRGB(52, 42, 72)
    }
}

local Colors = Themes.NyzeDark

-- ============ СОСТОЯНИЕ ============
_G.NyzeBinds        = {}
_G.AimEnabled       = false
_G.AimFOV           = 150
_G.AimSmooth        = 0.1
_G.WallCheck        = true
_G.TeamCheck        = false
_G.NoBulletDrop     = false
_G.EspBoxes         = false
_G.EspNames         = false
_G.EspDist          = false
_G.EspHP            = false
_G.EspTracers       = false
_G.PlayerEspMaxDist = 1000
_G.FullBright       = false
_G.FreecamEnabled   = false
_G.FreecamSpeed     = 1
_G.InfJump          = false
_G.SulfurEsp        = false
_G.IronEsp          = false
_G.StoneEsp         = false
_G.OreEspMaxDist    = 500
_G.NpcEsp           = false
_G.NpcEspMaxDist    = 1000
_G.CrateEsp         = false
_G.MilitaryEsp      = false
_G.EliteEsp         = false
_G.FoodEsp          = false
_G.CrateEspMaxDist  = 1000
_G.LegitSpeed       = false
_G.SpeedMultiplier  = 1.5

-- ============ BLUR ============
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size, Blur.Enabled = 0, true

-- ============ SCREEN GUI ============
local SG = Instance.new("ScreenGui")
SG.Name = "NyzeRust"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiOk = pcall(function() SG.Parent = CoreGui end)
if not guiOk or not SG.Parent then
    SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ============ ХЕЛПЕРЫ ============
local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Colors.Stroke
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function padding(parent, px)
    local p = Instance.new("UIPadding", parent)
    local u = UDim.new(0, px)
    p.PaddingTop, p.PaddingBottom, p.PaddingLeft, p.PaddingRight = u, u, u, u
    return p
end

-- ============ ПЕРЕМЕННАЯ TOGGLE (объявлена заранее) ============
local toggleFeature

-- ============ BIND BUTTON ============
local function createBindBtn(parent, prop, button, statusFrame)
    local bindBtn = Instance.new("TextButton", parent)
    bindBtn.Name = "Bind"
    bindBtn.Size = UDim2.new(0, 60, 0, 22)
    bindBtn.Position = UDim2.new(1, -108, 0.5, -11)
    bindBtn.BackgroundColor3 = Colors.Element
    bindBtn.Text = "—"
    bindBtn.TextColor3 = Colors.SubText
    bindBtn.Font = Enum.Font.GothamMedium
    bindBtn.TextSize = 11
    bindBtn.AutoButtonColor = false
    corner(bindBtn, 6)
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
                if toggleFeature then toggleFeature(prop, button, statusFrame) end
            end
        end
    end)
end

-- ============ TOGGLE LOGIC ============
toggleFeature = function(prop, button, statusFrame)
    _G[prop] = not _G[prop]
    if button and statusFrame then
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.25), {
                BackgroundColor3 = _G[prop] and Colors.ElementHover or Colors.Element
            }):Play()
            TweenService:Create(statusFrame, TweenInfo.new(0.25), {
                BackgroundColor3 = _G[prop] and Colors.Main or Color3.fromRGB(70, 72, 85)
            }):Play()
            local knob = statusFrame:FindFirstChild("Knob")
            if knob then
                TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                    Position = _G[prop] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }):Play()
            end
        end)
    end
end

-- ============ МОБИЛЬНАЯ КНОПКА ============
if isMobile then
    local OpenBtn = Instance.new("TextButton", SG)
    OpenBtn.Size = UDim2.new(0, 52, 0, 52)
    OpenBtn.Position = UDim2.new(0, 12, 0.42, 0)
    OpenBtn.BackgroundColor3 = Colors.Panel
    OpenBtn.Text = "N"
    OpenBtn.TextColor3 = Colors.Main
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextSize = 22
    OpenBtn.AutoButtonColor = false
    corner(OpenBtn, 26)
    stroke(OpenBtn, Colors.Main, 1.5, 0.2)
    OpenBtn.MouseButton1Click:Connect(function()
        if toggleMenu then toggleMenu() end
    end)
end

-- ============ ГЛАВНОЕ ОКНО ============
local M = Instance.new("Frame", SG)
M.BackgroundColor3 = Colors.Background
M.Position = UDim2.new(0.5, -310, 0, -450)
M.Size = UDim2.new(0, 620, 0, 440)
M.BorderSizePixel = 0
M.Active = true
M.Draggable = true
M.Visible = false
M.ClipsDescendants = true

if isMobile then
    M.Size = UDim2.new(0, 520, 0, 330)
    M.Position = UDim2.new(0.5, -260, 0, -350)
end

corner(M, 14)
local MainStroke = stroke(M, Colors.Stroke, 1.5, 0.2)

local MainGradient = Instance.new("UIGradient", M)
MainGradient.Rotation = 45
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Background),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 28))
})

-- ============ ЗАГОЛОВОК ============
local TitleBar = Instance.new("Frame", M)
TitleBar.Size = UDim2.new(1, 0, 0, 54)
TitleBar.BackgroundColor3 = Colors.SidePanel
TitleBar.BorderSizePixel = 0
corner(TitleBar, 14)

local FixCorner = Instance.new("Frame", TitleBar)
FixCorner.Size = UDim2.new(1, 0, 0, 14)
FixCorner.Position = UDim2.new(0, 0, 1, -14)
FixCorner.BackgroundColor3 = Colors.SidePanel
FixCorner.BorderSizePixel = 0

local TitleLogo = Instance.new("TextLabel", TitleBar)
TitleLogo.Size = UDim2.new(0, 40, 0, 40)
TitleLogo.Position = UDim2.new(0, 12, 0.5, -20)
TitleLogo.BackgroundTransparency = 1
TitleLogo.Text = "N"
TitleLogo.TextColor3 = Colors.Main
TitleLogo.Font = Enum.Font.GothamBlack
TitleLogo.TextSize = 22

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NyzeRust"
Title.TextColor3 = Colors.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", TitleBar)
SubTitle.Size = UDim2.new(1, -120, 0, 14)
SubTitle.Position = UDim2.new(0, 62, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "xeno edition • v1.0"
SubTitle.TextColor3 = Colors.SubText
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -15)
CloseBtn.BackgroundColor3 = Colors.Element
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function()
    if toggleMenu then toggleMenu() end
end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 60, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
end)

-- ============ CANVAS ============
local Canvas = Instance.new("Frame", M)
Canvas.Size = UDim2.new(1, 0, 1, -54)
Canvas.Position = UDim2.new(0, 0, 0, 54)
Canvas.BackgroundTransparency = 1

-- ============ SIDEBAR ============
local Side = Instance.new("Frame", Canvas)
Side.Position = UDim2.new(0, 12, 0, 12)
Side.Size = UDim2.new(0, 130, 1, -24)
Side.BackgroundColor3 = Colors.SidePanel
Side.BorderSizePixel = 0
corner(Side, 10)
stroke(Side, Colors.Stroke, 1, 0.5)

local SideLayout = Instance.new("UIListLayout", Side)
SideLayout.Padding = UDim.new(0, 6)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
padding(Side, 8)

-- ============ КОНТЕЙНЕР ============
local Container = Instance.new("ScrollingFrame", Canvas)
Container.Position = UDim2.new(0, 154, 0, 12)
Container.Size = UDim2.new(1, -166, 1, -24)
Container.BackgroundColor3 = Colors.Panel
Container.BorderSizePixel = 0
Container.ScrollBarThickness = isMobile and 0 or 3
Container.ScrollBarImageColor3 = Colors.Main
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
corner(Container, 10)
stroke(Container, Colors.Stroke, 1, 0.5)
padding(Container, 10)

local ContainerLayout = Instance.new("UIListLayout", Container)
ContainerLayout.Padding = UDim.new(0, 8)
ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ============ APPLY THEME ============
local function ApplyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    Colors = theme

    pcall(function()
        MainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Background),
            ColorSequenceKeypoint.new(1, theme.Panel)
        })
        M.BackgroundColor3 = theme.Background
        MainStroke.Color = theme.Stroke
        TitleBar.BackgroundColor3 = theme.SidePanel
        FixCorner.BackgroundColor3 = theme.SidePanel
        Side.BackgroundColor3 = theme.SidePanel
        Container.BackgroundColor3 = theme.Panel

        TitleLogo.TextColor3 = theme.Main
        Title.TextColor3 = theme.Text
        SubTitle.TextColor3 = theme.SubText

        CloseBtn.BackgroundColor3 = theme.Element
        CloseBtn.TextColor3 = theme.Text

        if _G.WFrame then
            _G.WFrame.BackgroundColor3 = theme.Background
            _G.WStroke.Color = theme.Stroke
        end

        for _, obj in ipairs(Container:GetDescendants()) do
            if obj:IsA("TextLabel") then
                if obj.Name == "SubLabel" then obj.TextColor3 = theme.SubText
                elseif obj.Name == "Label" then obj.TextColor3 = theme.Text end
            elseif obj:IsA("TextButton") then
                if obj.Name ~= "Bind" then obj.TextColor3 = theme.Text end
            end
        end
    end)
end

-- ============ TOGGLE MENU ============
local menuToggled = false
function toggleMenu()
    menuToggled = not menuToggled
    if menuToggled then
        M.Visible = true
        if not isMobile then UserInputService.MouseIconEnabled = true end
        TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 14}):Play()
        local targetPos = isMobile and UDim2.new(0.5, -260, 0.5, -165) or UDim2.new(0.5, -310, 0.5, -220)
        TweenService:Create(M, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    else
        if not isMobile then UserInputService.MouseIconEnabled = false end
        TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
        local targetPos = isMobile and UDim2.new(0.5, -260, 0, -350) or UDim2.new(0.5, -310, 0, -450)
        local t = TweenService:Create(M, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = targetPos})
        t:Play()
        t.Completed:Connect(function() if not menuToggled then M.Visible = false end end)
    end
end

-- ============ ВКЛАДКИ ============
local Tabs = { ESP = {}, AIM = {}, VIS = {}, PLR = {}, CFG = {} }

local function showTab(name)
    for tN, objs in pairs(Tabs) do
        for _, o in ipairs(objs) do
            o.Visible = (tN == name)
        end
    end
end

-- ============ TOGGLE CREATOR ============
local function createToggle(tab, name, prop, order)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -6, 0, 40)
    b.BackgroundColor3 = _G[prop] and Colors.ElementHover or Colors.Element
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Visible = false
    corner(b, 8)
    stroke(b, Colors.Stroke, 1, 0.5)

    local lbl = Instance.new("TextLabel", b)
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Colors.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local status = Instance.new("Frame", b)
    status.Size = UDim2.new(0, 36, 0, 18)
    status.Position = UDim2.new(1, -50, 0.5, -9)
    status.BackgroundColor3 = _G[prop] and Colors.Main or Color3.fromRGB(70, 72, 85)
    status.BorderSizePixel = 0
    corner(status, 9)

    local knob = Instance.new("Frame", status)
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = _G[prop] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    corner(knob, 7)

    table.insert(Tabs[tab], b)

    b.MouseButton1Click:Connect(function()
        toggleFeature(prop, b, status)
    end)

    b.MouseEnter:Connect(function()
        if not _G[prop] then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if not _G[prop] then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
        end
    end)

    createBindBtn(b, prop, b, status)
end

-- ============ SLIDER CREATOR ============
local function createSlider(tab, name, prop, min, max, order)
    local frame = Instance.new("Frame", Container)
    frame.Size = UDim2.new(1, -6, 0, 56)
    frame.BackgroundColor3 = Colors.Element
    frame.LayoutOrder = order
    frame.Visible = false
    frame.BorderSizePixel = 0
    corner(frame, 8)
    stroke(frame, Colors.Stroke, 1, 0.5)
    table.insert(Tabs[tab], frame)

    local label = Instance.new("TextLabel", frame)
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 14, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLbl = Instance.new("TextLabel", frame)
    valueLbl.Name = "SubLabel"
    valueLbl.Size = UDim2.new(0, 80, 0, 18)
    valueLbl.Position = UDim2.new(1, -94, 0, 8)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(_G[prop])
    valueLbl.TextColor3 = Colors.Main
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 12
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, -28, 0, 6)
    bg.Position = UDim2.new(0, 14, 0, 38)
    bg.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
    bg.BorderSizePixel = 0
    corner(bg, 3)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((_G[prop] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Main
    fill.BorderSizePixel = 0
    corner(fill, 3)

    local trigger = Instance.new("TextButton", bg)
    trigger.Size = UDim2.new(1, 0, 1, 0)
    trigger.BackgroundTransparency = 1
    trigger.Text = ""

    local dragging = false
    local function update(input)
        local inputPos = input.Position.X
        local pos = math.clamp((inputPos - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        val = (max > 5) and math.floor(val) or math.floor(val * 100) / 100
        _G[prop] = val
        fill.Size = UDim2.new(pos, 0, 1, 0)
        valueLbl.Text = tostring(val)
    end

    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- ============ THEME BUTTON ============
local function createThemeBtn(name, themeKey, order)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -6, 0, 36)
    b.BackgroundColor3 = Colors.Element
    b.Text = "   " .. name
    b.TextColor3 = Colors.Text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Visible = false
    corner(b, 8)
    stroke(b, Colors.Stroke, 1, 0.5)
    table.insert(Tabs.VIS, b)

    b.MouseButton1Click:Connect(function() ApplyTheme(themeKey) end)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
    end)
end

-- ============ TAB BUTTON ============
local tabButtons = {}
local function createTabBtn(n, label, order)
    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
    b.Text = "  " .. label
    b.TextColor3 = Colors.Text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = order
    corner(b, 8)

    tabButtons[n] = b

    b.MouseButton1Click:Connect(function()
        for key, btn in pairs(tabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.25), {
                BackgroundColor3 = (key == n) and Color3.fromRGB(35, 38, 50) or Color3.fromRGB(28, 30, 40),
                TextColor3 = (key == n) and Colors.Main or Colors.Text
            }):Play()
        end
        showTab(n)
    end)

    b.MouseEnter:Connect(function()
        if not (b.BackgroundColor3 == Color3.fromRGB(35, 38, 50)) then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if b.TextColor3 ~= Colors.Main then
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 30, 40)}):Play()
        end
    end)
end

-- ============ НАПОЛНЕНИЕ ============
createTabBtn("ESP", "ESP", 1)
createTabBtn("AIM", "AIMBOT", 2)
createTabBtn("VIS", "VISUALS", 3)
createTabBtn("PLR", "PLAYER", 4)
createTabBtn("CFG", "CONFIG", 5)

-- ESP
createToggle("ESP", "Player Boxes",     "EspBoxes",     1)
createToggle("ESP", "Name Tags",        "EspNames",     2)
createToggle("ESP", "Distance Info",    "EspDist",      3)
createToggle("ESP", "Health Bar",       "EspHP",        4)
createToggle("ESP", "Tracers",          "EspTracers",   5)
createToggle("ESP", "NPC ESP",          "NpcEsp",       6)
createSlider("ESP", "Player Max Dist",  "PlayerEspMaxDist", 100, 5000, 7)

-- AIM
createToggle("AIM", "Enable Aimbot",    "AimEnabled",   1)
createToggle("AIM", "Team Check",       "TeamCheck",    2)
createToggle("AIM", "Wall Check",       "WallCheck",    3)
createToggle("AIM", "No Bullet Drop",   "NoBulletDrop", 4)
createSlider("AIM", "Smoothing",        "AimSmooth",    0.01, 1, 5)
createSlider("AIM", "FOV Radius",       "AimFOV",       10, 800, 6)

-- VIS
createToggle("VIS", "Full Bright",      "FullBright",   1)
createToggle("VIS", "Sulfur Ore",       "SulfurEsp",    2)
createToggle("VIS", "Iron Ore",         "IronEsp",      3)
createToggle("VIS", "Stone Ore",        "StoneEsp",     4)
createSlider("VIS", "Ore Distance",     "OreEspMaxDist", 50, 3000, 5)
createSlider("VIS", "NPC Distance",     "NpcEspMaxDist", 50, 3000, 6)
createToggle("VIS", "Common Crate",     "CrateEsp",     7)
createToggle("VIS", "Military Crate",   "MilitaryEsp",  8)
createToggle("VIS", "Elite Crate",      "EliteEsp",     9)
createToggle("VIS", "Food Box",         "FoodEsp",      10)
createSlider("VIS", "Crate Distance",   "CrateEspMaxDist", 50, 3000, 11)
createThemeBtn("Nyze Dark",  "NyzeDark", 20)
createThemeBtn("Carbon",     "Carbon",   21)
createThemeBtn("Violet",     "Violet",   22)

-- PLR
createToggle("PLR", "Freecam",          "FreecamEnabled", 1)
createSlider("PLR", "Fly Speed",        "FreecamSpeed",   0.1, 10, 2)
createToggle("PLR", "Infinite Jump",    "InfJump",        3)
createToggle("PLR", "Legit Speed",      "LegitSpeed",     4)
createSlider("PLR", "Speed Power",      "SpeedMultiplier",1, 5, 5)

-- CFG
local cfgInfo = Instance.new("TextLabel", Container)
cfgInfo.Size = UDim2.new(1, -6, 0, 130)
cfgInfo.BackgroundColor3 = Colors.Element
cfgInfo.LayoutOrder = 1
cfgInfo.Visible = false
cfgInfo.Text = "  NyzeRust v1.0 — Xeno Edition\n\n  Menu toggle:  RSHIFT\n  Bind: click on [—] → press key\n  Unbind: click bind → ESC\n\n  Made for study purposes"
cfgInfo.TextColor3 = Colors.SubText
cfgInfo.Font = Enum.Font.GothamMedium
cfgInfo.TextSize = 12
cfgInfo.TextXAlignment = Enum.TextXAlignment.Left
cfgInfo.TextYAlignment = Enum.TextYAlignment.Top
cfgInfo.TextWrapped = true
corner(cfgInfo, 8)
stroke(cfgInfo, Colors.Stroke, 1, 0.5)
padding(cfgInfo, 12)
table.insert(Tabs.CFG, cfgInfo)

-- ============ GAME LOGIC ============

-- AntiBulletDrop
workspace.DescendantAdded:Connect(function(obj)
    if _G.NoBulletDrop and obj:IsA("BasePart") and (obj.Name:find("Bullet") or obj.Name:find("Projectile")) then
        pcall(function()
            local bf = Instance.new("BodyForce")
            bf.Force = Vector3.new(0, obj:GetMass() * workspace.Gravity, 0)
            bf.Parent = obj
        end)
    end
end)

-- isVisible
local function isVisible(targetPart)
    if not _G.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    local ray = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), params)
    return ray == nil
end

-- CRATE VISUALS
local function applyCrateVisuals(obj, name, color)
    if not obj:FindFirstChild("CrateHighlight") then
        local h = Instance.new("Highlight", obj)
        h.Name = "CrateHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if not obj:FindFirstChild("CrateTag") then
        local bg = Instance.new("BillboardGui", obj)
        bg.Name, bg.AlwaysOnTop, bg.Size = "CrateTag", true, UDim2.new(0, 100, 0, 40)
        bg.ExtentsOffset = Vector3.new(0, 2, 0)
        local lbl = Instance.new("TextLabel", bg)
        lbl.Name = "Label"
        lbl.BackgroundTransparency, lbl.Size, lbl.TextSize = 1, UDim2.new(1, 0, 1, 0), 13
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextStrokeTransparency = 0
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local pos = (obj:IsA("Model") and obj:GetModelCFrame().Position or obj.Position)
        local dist = math.floor((root.Position - pos).Magnitude)
        if dist <= _G.CrateEspMaxDist then
            obj.CrateTag.Enabled, obj.CrateHighlight.Enabled = true, true
            obj.CrateTag.Label.Text = name:upper() .. "\n[" .. dist .. "m]"
            obj.CrateTag.Label.TextColor3 = color
            obj.CrateHighlight.FillColor = color
        else
            obj.CrateTag.Enabled, obj.CrateHighlight.Enabled = false, false
        end
    end
end

-- NPC ESP
local function updateNpcEsp()
    local npcFolder = workspace:FindFirstChild("Npc")
    if not npcFolder then return end
    for _, npc in pairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") then
            if not npc:FindFirstChild("NpcHighlight") then
                local h = Instance.new("Highlight", npc)
                h.Name = "NpcHighlight"
                h.FillColor = Color3.new(1, 0, 0)
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local ok, dist = pcall(function()
                    return (root.Position - npc:GetModelCFrame().Position).Magnitude
                end)
                npc.NpcHighlight.Enabled = _G.NpcEsp and ok and dist <= _G.NpcEspMaxDist
            else
                npc.NpcHighlight.Enabled = false
            end
        end
    end
end

-- ORE VISUALS
local function applyOreVisuals(obj, name, color)
    if not obj:FindFirstChild("OreHighlight") then
        local h = Instance.new("Highlight", obj)
        h.Name = "OreHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if not obj:FindFirstChild("OreTag") then
        local bg = Instance.new("BillboardGui", obj)
        bg.Name, bg.AlwaysOnTop, bg.Size = "OreTag", true, UDim2.new(0, 100, 0, 40)
        bg.ExtentsOffset = Vector3.new(0, 2, 0)
        local lbl = Instance.new("TextLabel", bg)
        lbl.Name = "Label"
        lbl.BackgroundTransparency, lbl.Size, lbl.TextSize = 1, UDim2.new(1, 0, 1, 0), 13
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextStrokeTransparency = 0
    end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = math.floor((root.Position - obj.Position).Magnitude)
        if dist <= _G.OreEspMaxDist then
            obj.OreTag.Enabled, obj.OreHighlight.Enabled = true, true
            obj.OreTag.Label.Text = name:upper() .. "\n[" .. dist .. "m]"
            obj.OreTag.Label.TextColor3 = color
            obj.OreHighlight.FillColor = color
        else
            obj.OreTag.Enabled, obj.OreHighlight.Enabled = false, false
        end
    end
end

-- ============ RENDER: WORLD OBJECTS ============
RunService.RenderStepped:Connect(function()
    pcall(function()
        updateNpcEsp()

        -- Legit Speed
        if _G.LegitSpeed then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * (_G.SpeedMultiplier / 10))
            end
        end

        -- Ores
        local ores = workspace:FindFirstChild("ores")
        if ores then
            for _, ore in pairs(ores:GetChildren()) do
                local en = (ore.Name == "sulfur" and _G.SulfurEsp)
                        or (ore.Name == "iron" and _G.IronEsp)
                        or (ore.Name == "stone" and _G.StoneEsp)
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

        -- Crates
        local crates = workspace:FindFirstChild("Crates")
        if crates then
            for _, crate in pairs(crates:GetChildren()) do
                local en, col = false, Color3.new(1, 1, 1)
                if crate.Name == "Crate" then en = _G.CrateEsp; col = Color3.fromRGB(180, 130, 60)
                elseif crate.Name == "MilitaryCrate" then en = _G.MilitaryEsp; col = Color3.fromRGB(0, 180, 0)
                elseif crate.Name == "EliteCrate" then en = _G.EliteEsp; col = Color3.fromRGB(255, 60, 90)
                elseif crate.Name == "FoodBox" or crate.Name == "ToolBox" then en = _G.FoodEsp; col = Color3.fromRGB(0, 200, 255)
                end
                if en then
                    applyCrateVisuals(crate, crate.Name, col)
                elseif crate:FindFirstChild("CrateTag") then
                    crate.CrateTag.Enabled, crate.CrateHighlight.Enabled = false, false
                end
            end
        end

        -- FullBright
        if _G.FullBright then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
        end
    end)
end)

-- ============ AIMBOT ============
local function getClosest()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local target, mag = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") and v ~= LocalPlayer then
            if _G.TeamCheck and v.Team == LocalPlayer.Team then
                -- skip
            else
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local head = v.Character.Head
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < mag and dist < _G.AimFOV then
                            if isVisible(head) then
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

-- ============ ESP DRAWING ============
local espElements = {}
local FOVring = nil

if hasDrawing then
    local function createESP(p)
        if p == LocalPlayer then return end
        if espElements[p] then return end
        local ok, d = pcall(function()
            return {
                box = {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
                hp  = {Drawing.new("Line"), Drawing.new("Line")},
                tracer = Drawing.new("Line"),
                text   = Drawing.new("Text")
            }
        end)
        if not ok or not d then return end
        for _, l in pairs(d.box) do
            l.Thickness, l.Color, l.Visible = 1, Colors.Accent, false
        end
        d.tracer.Thickness, d.tracer.Color = 1, Colors.Main
        d.hp[1].Thickness, d.hp[1].Color = 2, Color3.new(0, 0, 0)
        d.hp[2].Thickness = 2
        d.text.Size, d.text.Center, d.text.Outline = 14, true, true
        d.text.Color = Colors.Text
        espElements[p] = d
    end

    pcall(function()
        FOVring = Drawing.new("Circle")
        FOVring.Thickness, FOVring.Color, FOVring.Transparency, FOVring.NumSides = 1, Colors.Main, 1, 60
        FOVring.Visible = false
    end)

    -- Render loop ESP + aimbot
    RunService.RenderStepped:Connect(function()
        pcall(function()
            -- FOV ring
            if FOVring then
                FOVring.Visible = _G.AimEnabled
                if _G.AimEnabled then
                    FOVring.Radius = _G.AimFOV
                    FOVring.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    FOVring.Color = Colors.Main

                    local isAiming = (not isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or isMobile
                    if isAiming then
                        local t = getClosest()
                        if t then
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), _G.AimSmooth)
                        end
                    end
                end
            end

            -- Player ESP
            for p, d in pairs(espElements) do
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChildOfClass("Humanoid")

                local shouldDraw = false

                if c and r and h and h.Health > 0 then
                    local ps, v = Camera:WorldToViewportPoint(r.Position)
                    local realDist = ps.Z
                    if v and realDist <= _G.PlayerEspMaxDist then
                        shouldDraw = true
                        local sy = 4500 / realDist
                        local sx = 2800 / realDist
                        local x, y = ps.X - sx / 2, ps.Y - sy / 2

                        for i, l in pairs(d.box) do
                            l.Visible = _G.EspBoxes
                            l.Color = Colors.Accent
                            if i == 1 then
                                l.From, l.To = Vector2.new(x, y), Vector2.new(x + sx, y)
                            elseif i == 2 then
                                l.From, l.To = Vector2.new(x + sx, y), Vector2.new(x + sx, y + sy)
                            elseif i == 3 then
                                l.From, l.To = Vector2.new(x + sx, y + sy), Vector2.new(x, y + sy)
                            else
                                l.From, l.To = Vector2.new(x, y + sy), Vector2.new(x, y)
                            end
                        end

                        d.tracer.Visible = _G.EspTracers
                        d.tracer.Color = Colors.Main
                        if _G.EspTracers then
                            d.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            d.tracer.To = Vector2.new(ps.X, ps.Y)
                        end

                        d.text.Visible = (_G.EspNames or _G.EspDist)
                        d.text.Color = Colors.Text
                        d.text.Text = (_G.EspNames and p.Name or "") .. (_G.EspDist and (" [" .. math.floor(realDist) .. "m]") or "")
                        d.text.Position = Vector2.new(ps.X, y - 15)

                        d.hp[1].Visible, d.hp[2].Visible = _G.EspHP, _G.EspHP
                        if _G.EspHP then
                            local hp_val = h.Health / h.MaxHealth
                            d.hp[1].From, d.hp[1].To = Vector2.new(x - 5, y + sy), Vector2.new(x - 5, y)
                            d.hp[2].From, d.hp[2].To = Vector2.new(x - 5, y + sy), Vector2.new(x - 5, y + sy - (sy * hp_val))
                            d.hp[2].Color = Color3.fromHSV(hp_val * 0.3, 1, 1)
                        end
                    end
                end

                if not shouldDraw then
                    for _, l in pairs(d.box) do l.Visible = false end
                    d.tracer.Visible, d.text.Visible, d.hp[1].Visible, d.hp[2].Visible = false, false, false, false
                end
            end
        end)
    end)

    -- Player add/remove
    Players.PlayerAdded:Connect(function(p)
        task.wait(1)
        createESP(p)
    end)
    Players.PlayerRemoving:Connect(function(p)
        if espElements[p] then
            pcall(function()
                for _, l in pairs(espElements[p].box) do l:Remove() end
                espElements[p].tracer:Remove()
                espElements[p].text:Remove()
                espElements[p].hp[1]:Remove()
                espElements[p].hp[2]:Remove()
            end)
            espElements[p] = nil
        end
    end)
    for _, p in pairs(Players:GetPlayers()) do createESP(p) end
end

-- ============ INFINITE JUMP ============
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============ OPEN HOTKEY ============
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu()
    end
end)

-- ============ СТАРТОВАЯ ВКЛАДКА ============
showTab("ESP")
if tabButtons.ESP then
    tabButtons.ESP.TextColor3 = Colors.Main
    tabButtons.ESP.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
end

-- ============ WATERMARK ============
local onlineUsers = math.random(140, 180)
task.spawn(function()
    while true do
        task.wait(20)
        onlineUsers = onlineUsers + math.random(-2, 3)
    end
end)

local Watermark = Instance.new("ScreenGui")
Watermark.Name = "NyzeRustWatermark"
Watermark.ResetOnSpawn = false
Watermark.IgnoreGuiInset = true
local wmOk = pcall(function() Watermark.Parent = CoreGui end)
if not wmOk or not Watermark.Parent then
    Watermark.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local WFrame = Instance.new("Frame", Watermark)
_G.WFrame = WFrame
WFrame.BackgroundColor3 = Colors.Background
WFrame.BackgroundTransparency = 0.15
WFrame.Position = UDim2.new(0, 12, 0, 12)
WFrame.Size = UDim2.new(0, 230, 0, 120)
WFrame.BorderSizePixel = 0
corner(WFrame, 10)

local WStroke = Instance.new("UIStroke", WFrame)
_G.WStroke = WStroke
WStroke.Color = Colors.Stroke
WStroke.Thickness = 1.5
WStroke.Transparency = 0.2

local WLabel = Instance.new("TextLabel", WFrame)
WLabel.Size = UDim2.new(1, -20, 1, -16)
WLabel.Position = UDim2.new(0, 12, 0, 8)
WLabel.BackgroundTransparency = 1
WLabel.TextColor3 = Colors.Text
WLabel.Font = Enum.Font.GothamMedium
WLabel.TextSize = 12
WLabel.RichText = true
WLabel.TextXAlignment = Enum.TextXAlignment.Left
WLabel.TextYAlignment = Enum.TextYAlignment.Top

local lastIteration = tick()
local frameCount = 0
local fps = 0

RunService.RenderStepped:Connect(function()
    pcall(function()
        frameCount = frameCount + 1
        if tick() - lastIteration >= 1 then
            fps = frameCount
            frameCount = 0
            lastIteration = tick()
        end

        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)

        local text = "<font color='#" .. Colors.Main:ToHex() .. "'>NyzeRust</font> v1.0\n"
        text = text .. "ONLINE: <font color='#" .. Colors.Accent:ToHex() .. "'>" .. onlineUsers .. "</font>\n"
        text = text .. "FPS: <font color='#" .. Colors.Accent:ToHex() .. "'>" .. fps .. "</font>  |  PING: <font color='#" .. Colors.Accent:ToHex() .. "'>" .. ping .. "ms</font>\n"
        text = text .. "MENU: [<font color='#" .. Colors.Secondary:ToHex() .. "'>RSHIFT</font>]\n"
        text = text .. "<font color='#" .. Colors.Stroke:ToHex() .. "'>----------------------------</font>\n"

        local bindCount = 0
        for prop, key in pairs(_G.NyzeBinds) do
            if key then
                bindCount = bindCount + 1
                local status = _G[prop] and "<font color='#22DD66'>ON</font>" or "<font color='#DD4466'>OFF</font>"
                text = text .. "• " .. prop .. " [" .. key.Name .. "] " .. status .. "\n"
            end
        end
        if bindCount == 0 then
            text = text .. "<font color='#666666'>no binds</font>"
        end

        WLabel.Text = text

        local base = 110
        WFrame.Size = UDim2.new(0, 230, 0, bindCount == 0 and base or (base - 15) + (bindCount * 15))
    end)
end)

-- ============ УВЕДОМЛЕНИЕ ============
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NyzeRust",
        Text = "Loaded successfully • RSHIFT to open",
        Duration = 4
    })
end)

print("[NyzeRust] Загружен успешно. Нажми RSHIFT чтобы открыть меню.")
