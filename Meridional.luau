--[[
    Meridional UI Library
    Version: 1.0.0
    Style: Primordial-inspired dark UI framework for Luau/Roblox scripts
]]

--────────────────────────────────────────────────────────────────────────────────
-- SERVICES
--────────────────────────────────────────────────────────────────────────────────
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer        = Players.LocalPlayer
local Mouse              = LocalPlayer:GetMouse()

--────────────────────────────────────────────────────────────────────────────────
-- UTILITY
--────────────────────────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function New(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = obj
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function MakeCorner(radius, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function MakePadding(top, bottom, left, right, parent)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, top),
        PaddingBottom = UDim.new(0, bottom),
        PaddingLeft   = UDim.new(0, left),
        PaddingRight  = UDim.new(0, right),
        Parent        = parent,
    })
end

local function MakeStroke(color, thickness, transparency, parent)
    return New("UIStroke", {
        Color        = color,
        Thickness    = thickness,
        Transparency = transparency or 0,
        Parent       = parent,
    })
end

local function MakeGradient(color0, color1, rotation, parent)
    return New("UIGradient", {
        Color    = ColorSequence.new(color0, color1),
        Rotation = rotation or 0,
        Parent   = parent,
    })
end

--────────────────────────────────────────────────────────────────────────────────
-- THEME (1:1 Primordial Theme Match)
--────────────────────────────────────────────────────────────────────────────────
local Theme = {
    WindowBG          = Color3.fromRGB(18, 18, 22),
    WindowBorder      = Color3.fromRGB(38, 32, 36),
    TitleBar          = Color3.fromRGB(22, 22, 26),
    TitleText         = Color3.fromRGB(240, 225, 230),

    NavBG             = Color3.fromRGB(15, 15, 19),
    NavItem           = Color3.fromRGB(160, 150, 155),
    NavItemActive     = Color3.fromRGB(255, 255, 255),
    NavItemHover      = Color3.fromRGB(210, 195, 200),
    NavSub            = Color3.fromRGB(110, 100, 105),
    NavIndicator      = Color3.fromRGB(215, 140, 160), -- Primordial Rose Pink

    TabBG             = Color3.fromRGB(20, 20, 24),
    TabActive         = Color3.fromRGB(255, 255, 255),
    TabInactive       = Color3.fromRGB(110, 100, 105),
    TabUnderline      = Color3.fromRGB(215, 140, 160),

    SectionBG         = Color3.fromRGB(24, 24, 29),
    SectionHeader     = Color3.fromRGB(220, 220, 225),
    SectionBorder     = Color3.fromRGB(48, 40, 45), -- Rose-tinted dark border

    TextPrimary       = Color3.fromRGB(220, 215, 220),
    TextSecondary     = Color3.fromRGB(120, 110, 115),

    Accent            = Color3.fromRGB(215, 140, 160),
    AccentHover       = Color3.fromRGB(230, 155, 175),

    -- Checkbox / Toggle Style matching Primordial checkboxes
    CheckboxOff       = Color3.fromRGB(30, 30, 36),
    CheckboxOn        = Color3.fromRGB(215, 140, 160),
    CheckmarkColor    = Color3.fromRGB(255, 255, 255),

    SliderBG          = Color3.fromRGB(32, 32, 38),
    SliderFill        = Color3.fromRGB(215, 140, 160),
    SliderKnob        = Color3.fromRGB(255, 255, 255),

    DropdownBG        = Color3.fromRGB(28, 28, 35),
    DropdownBorder    = Color3.fromRGB(50, 42, 48),
    DropdownHover     = Color3.fromRGB(36, 36, 44),
    DropdownIcon      = Color3.fromRGB(140, 120, 130),

    ButtonBG          = Color3.fromRGB(32, 32, 40),
    ButtonHover       = Color3.fromRGB(55, 42, 48),
    ButtonActive      = Color3.fromRGB(215, 140, 160),
    ButtonText        = Color3.fromRGB(225, 220, 225),

    InputBG           = Color3.fromRGB(28, 28, 35),
    InputBorder       = Color3.fromRGB(50, 42, 48),
    InputText         = Color3.fromRGB(230, 225, 230),
    InputPlaceholder  = Color3.fromRGB(90, 80, 85),

    Divider           = Color3.fromRGB(44, 36, 42),

    CornerWindow      = 4,
    CornerSection     = 3,
    CornerControl     = 3,
    ControlHeight     = 26,
    FontSize          = 12,
    FontSizeSmall     = 10,
    FontSizeLarge     = 14,
}

local function ApplyTheme(overrides)
    for k, v in pairs(overrides) do
        Theme[k] = v
    end
end

--────────────────────────────────────────────────────────────────────────────────
-- DRAG HANDLER
--────────────────────────────────────────────────────────────────────────────────
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--────────────────────────────────────────────────────────────────────────────────
-- ICONS & NOTIFICATIONS
--────────────────────────────────────────────────────────────────────────────────
local Icons = {
    Logo     = "rbxassetid://7733960981",
    Check    = "rbxassetid://7743878602",
    Chevron  = "rbxassetid://7743871405",
    Settings = "rbxassetid://7734053495",
    Close    = "rbxassetid://7743875544",
    Drag     = "rbxassetid://7734002254",
}

local NotifContainer

local function Notify(title, message, duration)
    if not NotifContainer then return end
    duration = duration or 4

    local notif = New("Frame", {
        BackgroundColor3 = Theme.SectionBG,
        Size             = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent           = NotifContainer,
    })
    MakeCorner(Theme.CornerSection, notif)
    MakeStroke(Theme.Accent, 1, 0.4, notif)

    local accent = New("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size             = UDim2.new(0, 3, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        Parent           = notif,
    })
    MakeCorner(2, accent)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 12, 0, 5),
        Size                   = UDim2.new(1, -16, 0, 16),
        Font                   = Enum.Font.GothamBold,
        Text                   = title,
        TextColor3             = Theme.TextPrimary,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = notif,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 12, 0, 22),
        Size                   = UDim2.new(1, -16, 0, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = message,
        TextColor3             = Theme.TextSecondary,
        TextSize               = Theme.FontSizeSmall,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y,
        Parent                 = notif,
    })

    Tween(notif, { Size = UDim2.new(1, 0, 0, 58) }, 0.2)

    task.delay(duration, function()
        Tween(notif, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.35)
        notif:Destroy()
    end)
end

--────────────────────────────────────────────────────────────────────────────────
-- WIDGET BUILDERS
--────────────────────────────────────────────────────────────────────────────────
local function MakeRow(parent, height)
    local row = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, height or Theme.ControlHeight),
        Parent                 = parent,
    })
    local inner = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -8, 1, 0),
        Position               = UDim2.new(0, 4, 0, 0),
        Parent                 = row,
    })
    return row, inner
end

local function MakeToggle(parent, config)
    local state = config.Default or false
    local row, inner = MakeRow(parent, Theme.ControlHeight)

    local label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -44, 1, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = config.Label,
        TextColor3             = Theme.TextPrimary,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = inner,
    })

    local track = New("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
        Position         = UDim2.new(1, 0, 0.5, 0),
        Size             = UDim2.new(0, 36, 0, 20),
        Parent           = inner,
    })
    MakeCorner(Theme.CornerToggle, track)

    local knob = New("Frame", {
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.ToggleKnob,
        Position         = UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, 0),
        Size             = UDim2.new(0, 14, 0, 14),
        Parent           = track,
    })
    MakeCorner(7, knob)

    local function setState(val)
        state = val
        Tween(track, { BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
        Tween(knob, { Position = UDim2.new(val and 1 or 0, val and -17 or 3, 0.5, 0) }, 0.18)
        if config.Callback then config.Callback(val) end
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state)
        end
    end)

    row.MouseEnter:Connect(function() Tween(label, { TextColor3 = Theme.NavItemHover }, 0.1) end)
    row.MouseLeave:Connect(function() Tween(label, { TextColor3 = Theme.TextPrimary }, 0.1) end)

    return {
        Value    = state,
        SetValue = function(v) setState(v) end,
        Destroy  = function() row:Destroy() end,
    }
end

local function MakeSlider(parent, config)
    local step    = config.Step or 1
    local current = config.Default or config.Min
    local suffix  = config.Suffix or ""

    local function snap(v)
        return math.clamp(math.round(v / step) * step, config.Min, config.Max)
    end

    local container = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 46),
        Parent                 = parent,
    })
    MakePadding(4, 4, 4, 4, container)

    local header = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 16),
        Parent                 = container,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.65, 0, 1, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = config.Label,
        TextColor3             = Theme.TextPrimary,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = header,
    })

    local valLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint            = Vector2.new(1, 0),
        Position               = UDim2.new(1, 0, 0, 0),
        Size                   = UDim2.new(0.35, 0, 1, 0),
        Font                   = Enum.Font.GothamBold,
        Text                   = tostring(current) .. suffix,
        TextColor3             = Theme.Accent,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Right,
        Parent                 = header,
    })

    local trackBG = New("Frame", {
        BackgroundColor3 = Theme.SliderBG,
        Position         = UDim2.new(0, 0, 0, 22),
        Size             = UDim2.new(1, 0, 0, 6),
        Parent           = container,
    })
    MakeCorner(3, trackBG)

    local pct = (current - config.Min) / (config.Max - config.Min)

    local fill = New("Frame", {
        BackgroundColor3 = Theme.SliderFill,
        Size             = UDim2.new(pct, 0, 1, 0),
        Parent           = trackBG,
    })
    MakeCorner(3, fill)

    local knob = New("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.SliderKnob,
        Position         = UDim2.new(pct, 0, 0.5, 0),
        Size             = UDim2.new(0, 12, 0, 12),
        ZIndex           = 2,
        Parent           = trackBG,
    })
    MakeCorner(6, knob)

    local dragging = false

    local function update(x)
        local abs    = trackBG.AbsolutePosition.X
        local w      = trackBG.AbsoluteSize.X
        local t      = math.clamp((x - abs) / w, 0, 1)
        local val    = snap(config.Min + t * (config.Max - config.Min))
        current      = val
        local newPct = (val - config.Min) / (config.Max - config.Min)
        fill.Size     = UDim2.new(newPct, 0, 1, 0)
        knob.Position = UDim2.new(newPct, 0, 0.5, 0)
        valLabel.Text = tostring(val) .. suffix
        if config.Callback then config.Callback(val) end
    end

    trackBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Value    = current,
        SetValue = function(v)
            current = snap(v)
            local p = (current - config.Min) / (config.Max - config.Min)
            fill.Size     = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            valLabel.Text = tostring(current) .. suffix
            if config.Callback then config.Callback(current) end
        end,
        Destroy = function() container:Destroy() end,
    }
end

local function MakeDropdown(parent, config)
    local selected = config.Default or config.Options[1] or ""
    local open     = false

    local container = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, Theme.ControlHeight + 8),
        ClipsDescendants       = false,
        Parent                 = parent,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -8, 0, 16),
        Position               = UDim2.new(0, 4, 0, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = config.Label,
        TextColor3             = Theme.TextSecondary,
        TextSize               = Theme.FontSizeSmall,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = container,
    })

    local button = New("Frame", {
        BackgroundColor3 = Theme.DropdownBG,
        Position         = UDim2.new(0, 4, 0, 18),
        Size             = UDim2.new(1, -8, 0, Theme.ControlHeight),
        ClipsDescendants = false,
        Parent           = container,
    })
    MakeCorner(Theme.CornerControl, button)
    MakeStroke(Theme.DropdownBorder, 1, 0, button)

    local selectedLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 8, 0, 0),
        Size                   = UDim2.new(1, -28, 1, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = selected,
        TextColor3             = Theme.InputText,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = button,
    })

    local chevron = New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -8, 0.5, 0),
        Size                   = UDim2.new(0, 14, 0, 14),
        Font                   = Enum.Font.GothamBold,
        Text                   = "▼",
        TextColor3             = Theme.DropdownIcon,
        TextSize               = 10,
        Parent                 = button,
    })

    local menu = New("Frame", {
        BackgroundColor3 = Theme.DropdownBG,
        Position         = UDim2.new(0, 0, 1, 2),
        Size             = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 10,
        Parent           = button,
    })
    MakeCorner(Theme.CornerControl, menu)
    MakeStroke(Theme.DropdownBorder, 1, 0, menu)

    local menuList = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 1),
        Parent    = menu,
    })
    MakePadding(3, 3, 0, 0, menu)

    local function buildMenu()
        for _, c in ipairs(menu:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
        end
        for _, opt in ipairs(config.Options) do
            local item = New("TextButton", {
                BackgroundColor3       = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Size                   = UDim2.new(1, 0, 0, 26),
                Font                   = Enum.Font.Gotham,
                Text                   = opt,
                TextColor3             = opt == selected and Theme.Accent or Theme.TextPrimary,
                TextSize               = Theme.FontSize,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 11,
                Parent                 = menu,
            })
            MakePadding(0, 0, 8, 8, item)

            item.MouseEnter:Connect(function() Tween(item, { BackgroundTransparency = 0, BackgroundColor3 = Theme.DropdownHover }, 0.08) end)
            item.MouseLeave:Connect(function() Tween(item, { BackgroundTransparency = 1 }, 0.08) end)

            item.MouseButton1Click:Connect(function()
                selected = opt
                selectedLabel.Text = opt
                for _, child in ipairs(menu:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.TextColor3 = child.Text == selected and Theme.Accent or Theme.TextPrimary
                    end
                end
                Tween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                task.wait(0.15)
                menu.Visible = false
                open = false
                Tween(chevron, { Rotation = 0 }, 0.15)
                if config.Callback then config.Callback(opt) end
            end)
        end
        return math.min(#config.Options * 26 + 6, 200)
    end

    buildMenu()

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                local h = buildMenu()
                menu.Visible = true
                menu.Size    = UDim2.new(1, 0, 0, 0)
                Tween(menu, { Size = UDim2.new(1, 0, 0, h) }, 0.18)
                Tween(chevron, { Rotation = 180 }, 0.15)
            else
                Tween(menu, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                task.delay(0.15, function() menu.Visible = false end)
                Tween(chevron, { Rotation = 0 }, 0.15)
            end
        end
    end)

    return {
        Value      = selected,
        SetOptions = function(opts) config.Options = opts; buildMenu() end,
        Destroy    = function() container:Destroy() end,
    }
end

local function MakeKeybind(parent, config)
    local current  = config.Default or Enum.KeyCode.Unknown
    local binding  = false
    local row, inner = MakeRow(parent, Theme.ControlHeight)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.55, 0, 1, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = config.Label,
        TextColor3             = Theme.TextPrimary,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = inner,
    })

    local keyBox = New("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.ButtonBG,
        Position         = UDim2.new(1, 0, 0.5, 0),
        Size             = UDim2.new(0, 90, 0, 20),
        Parent           = inner,
    })
    MakeCorner(Theme.CornerControl, keyBox)
    MakeStroke(Theme.SectionBorder, 1, 0, keyBox)

    local keyLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        Font                   = Enum.Font.GothamBold,
        Text                   = "Key: " .. current.Name,
        TextColor3             = Theme.Accent,
        TextSize               = Theme.FontSizeSmall,
        Parent                 = keyBox,
    })

    keyBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            binding = true
            keyLabel.Text       = "Press a key..."
            keyLabel.TextColor3 = Theme.TextSecondary
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            current = input.KeyCode
            keyLabel.Text       = "Key: " .. current.Name
            keyLabel.TextColor3 = Theme.Accent
            if config.Callback then config.Callback(current) end
        end
    end)

    return {
        Value   = current,
        Destroy = function() row:Destroy() end,
    }
end

local function MakeButton(parent, config)
    local btn = New("TextButton", {
        BackgroundColor3 = Theme.ButtonBG,
        Size             = UDim2.new(1, -8, 0, Theme.ControlHeight),
        Position         = UDim2.new(0, 4, 0, 0),
        Font             = Enum.Font.GothamBold,
        Text             = config.Label,
        TextColor3       = Theme.ButtonText,
        TextSize         = Theme.FontSize,
        AutoButtonColor  = false,
        Parent           = parent,
    })
    MakeCorner(Theme.CornerControl, btn)
    MakeStroke(Theme.SectionBorder, 1, 0.3, btn)

    local spacer = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4), Parent = parent })

    btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1) end)
    btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = Theme.ButtonBG }, 0.1) end)
    btn.MouseButton1Down:Connect(function() Tween(btn, { BackgroundColor3 = Theme.ButtonActive }, 0.05) end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
        if config.Callback then config.Callback() end
    end)

    return { Destroy = function() btn:Destroy() spacer:Destroy() end }
end

local function MakeInput(parent, config)
    local container = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = parent })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -8, 0, 16),
        Position               = UDim2.new(0, 4, 0, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = config.Label,
        TextColor3             = Theme.TextSecondary,
        TextSize               = Theme.FontSizeSmall,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = container,
    })

    local inputFrame = New("Frame", {
        BackgroundColor3 = Theme.InputBG,
        Position         = UDim2.new(0, 4, 0, 18),
        Size             = UDim2.new(1, -8, 0, Theme.ControlHeight),
        Parent           = container,
    })
    MakeCorner(Theme.CornerControl, inputFrame)
    MakeStroke(Theme.InputBorder, 1, 0, inputFrame)

    local box = New("TextBox", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 8, 0, 0),
        Size                   = UDim2.new(1, -16, 1, 0),
        Font                   = Enum.Font.Gotham,
        PlaceholderText        = config.Placeholder or "",
        PlaceholderColor3      = Theme.InputPlaceholder,
        Text                   = config.Default or "",
        TextColor3             = Theme.InputText,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ClearTextOnFocus       = false,
        Parent                 = inputFrame,
    })

    box.Focused:Connect(function()
        Tween(inputFrame, { BackgroundColor3 = Theme.DropdownHover }, 0.1)
        MakeStroke(Theme.Accent, 1, 0, inputFrame)
    end)

    box.FocusLost:Connect(function(enterPressed)
        Tween(inputFrame, { BackgroundColor3 = Theme.InputBG }, 0.1)
        if config.Callback then config.Callback(box.Text) end
    end)

    return {
        Value   = box.Text,
        Destroy = function() container:Destroy() end,
    }
end

local function MakeLabel(parent, config)
    local lbl = New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, -8, 0, 0),
        Position               = UDim2.new(0, 4, 0, 0),
        Font                   = config.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        Text                   = config.Text,
        TextColor3             = config.Secondary and Theme.TextSecondary or Theme.TextPrimary,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y,
        Parent                 = parent,
    })
    local spacer = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4), Parent = parent })
    return {
        SetText = function(t) lbl.Text = t end,
        Destroy = function() lbl:Destroy() spacer:Destroy() end,
    }
end

local function MakeDivider(parent)
    local frame = New("Frame", { BackgroundColor3 = Theme.Divider, Size = UDim2.new(1, -8, 0, 1), Position = UDim2.new(0, 4, 0, 0), BorderSizePixel = 0, Parent = parent })
    local spacer = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), Parent = parent })
    return { Destroy = function() frame:Destroy() spacer:Destroy() end }
end

local function MakeColorPicker(parent, config)
    local current = config.Default or Color3.fromRGB(255, 255, 255)
    local open     = false

    local container = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Theme.ControlHeight), ClipsDescendants = false, Parent = parent })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0.6, 0, 1, 0),
        Position               = UDim2.new(0, 4, 0, 0),
        Font                   = Enum.Font.Gotham,
        Text                   = config.Label,
        TextColor3             = Theme.TextPrimary,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = container,
    })

    local swatch = New("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = current,
        Position         = UDim2.new(1, -4, 0.5, 0),
        Size             = UDim2.new(0, 60, 0, 18),
        Parent           = container,
    })
    MakeCorner(Theme.CornerControl, swatch)
    MakeStroke(Theme.InputBorder, 1, 0, swatch)

    local picker = New("Frame", {
        BackgroundColor3 = Theme.DropdownBG,
        Position         = UDim2.new(0, 4, 1, 4),
        Size             = UDim2.new(1, -8, 0, 0),
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 10,
        Parent           = container,
    })
    MakeCorner(Theme.CornerSection, picker)
    MakeStroke(Theme.DropdownBorder, 1, 0, picker)

    local hueGrad = New("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position         = UDim2.new(0, 8, 0, 8),
        Size             = UDim2.new(1, -16, 0, 14),
        ZIndex           = 11,
        Parent           = picker,
    })
    MakeCorner(3, hueGrad)
    New("UIGradient", {
        Color  = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0,   0)),
            ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,   255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,   255, 255)),
            ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,   0,   255)),
            ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255, 0,   255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 0,   0)),
        }),
        Parent = hueGrad,
    })

    local hueKnob = New("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        Size             = UDim2.new(0, 8, 0, 8),
        ZIndex           = 12,
        Parent           = hueGrad,
    })
    MakeCorner(4, hueKnob)
    MakeStroke(Color3.new(0, 0, 0), 1, 0, hueKnob)

    local hexInput = New("TextBox", {
        BackgroundColor3  = Theme.InputBG,
        Position          = UDim2.new(0, 8, 0, 28),
        Size              = UDim2.new(1, -16, 0, 22),
        Font              = Enum.Font.Code,
        PlaceholderText   = "#RRGGBB",
        PlaceholderColor3 = Theme.InputPlaceholder,
        Text              = string.format("#%02X%02X%02X", math.floor(current.R*255), math.floor(current.G*255), math.floor(current.B*255)),
        TextColor3        = Theme.InputText,
        TextSize          = Theme.FontSizeSmall,
        ZIndex            = 11,
        Parent            = picker,
    })
    MakeCorner(3, hexInput)
    MakePadding(0, 0, 6, 0, hexInput)

    local function applyColor(c)
        current       = c
        swatch.BackgroundColor3 = c
        hexInput.Text = string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
        if config.Callback then config.Callback(c) end
    end

    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:match("#?(%x%x%x%x%x%x)")
        if hex then
            local r = tonumber(hex:sub(1,2), 16) / 255
            local g = tonumber(hex:sub(3,4), 16) / 255
            local b = tonumber(hex:sub(5,6), 16) / 255
            applyColor(Color3.new(r, g, b))
        end
    end)

    local hueDragging = false
    local function updateHue(x)
        local abs = hueGrad.AbsolutePosition.X
        local w   = hueGrad.AbsoluteSize.X
        local t   = math.clamp((x - abs) / w, 0, 1)
        hueKnob.Position = UDim2.new(t, 0, 0.5, 0)
        local h, s, v = current:ToHSV()
        applyColor(Color3.fromHSV(t, s, v))
    end

    hueGrad.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            updateHue(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateHue(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)

    swatch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                picker.Visible = true
                Tween(picker, { Size = UDim2.new(1, -8, 0, 58) }, 0.18)
            else
                Tween(picker, { Size = UDim2.new(1, -8, 0, 0) }, 0.15)
                task.delay(0.15, function() picker.Visible = false end)
            end
        end
    end)

    return {
        Value   = current,
        Destroy = function() container:Destroy() end,
    }
end

--────────────────────────────────────────────────────────────────────────────────
-- SECTION BUILDER
--────────────────────────────────────────────────────────────────────────────────
local Section = {}
Section.__index = Section

function Section.new(parent, title)
    local self = setmetatable({}, Section)

    local frame = New("Frame", {
        BackgroundColor3 = Theme.SectionBG,
        Size             = UDim2.new(1, -8, 0, 0),
        Position         = UDim2.new(0, 4, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Parent           = parent,
    })
    MakeCorner(Theme.CornerSection, frame)
    MakeStroke(Theme.SectionBorder, 1, 0, frame)

    local content = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        Parent                 = frame,
    })
    MakePadding(8, 8, 6, 6, content)

    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 4),
        Parent    = content,
    })

    if title then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 18),
            Font                   = Enum.Font.GothamBold,
            Text                   = title,
            TextColor3             = Theme.SectionHeader,
            TextSize               = Theme.FontSizeSmall,
            TextXAlignment         = Enum.TextXAlignment.Left,
            LayoutOrder            = -1,
            Parent                 = content,
        })
        New("Frame", { BackgroundColor3 = Theme.Divider, Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 0, Parent = content })
    end

    self._content = content
    self._frame   = frame
    return self
end

function Section:Toggle(config)      return MakeToggle(self._content, config) end
function Section:Slider(config)      return MakeSlider(self._content, config) end
function Section:Dropdown(config)    return MakeDropdown(self._content, config) end
function Section:Keybind(config)     return MakeKeybind(self._content, config) end
function Section:Button(config)      return MakeButton(self._content, config) end
function Section:Input(config)       return MakeInput(self._content, config) end
function Section:Label(config)       return MakeLabel(self._content, config) end
function Section:Divider()           return MakeDivider(self._content) end
function Section:ColorPicker(config) return MakeColorPicker(self._content, config) end
function Section:Destroy()           self._frame:Destroy() end

--────────────────────────────────────────────────────────────────────────────────
-- TAB PAGE BUILDER
--────────────────────────────────────────────────────────────────────────────────
local TabPage = {}
TabPage.__index = TabPage

function TabPage.new(parent)
    local self = setmetatable({}, TabPage)

    local scroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        BorderSizePixel        = 0,
        Parent                 = parent,
    })

    local inner = New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        Parent                 = scroll,
    })
    MakePadding(8, 12, 0, 0, inner)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = inner })

    self._inner  = inner
    self._scroll = scroll
    self._frame  = parent
    return self
end

function TabPage:Section(title)
    return Section.new(self._inner, title)
end

function TabPage:Column(leftTitle, rightTitle)
    local cols = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self._inner })
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = cols })

    local leftFrame = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -3, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = cols })
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = leftFrame })

    local rightFrame = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -3, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = cols })
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = rightFrame })

    return Section.new(leftFrame, leftTitle), Section.new(rightFrame, rightTitle)
end

local function MakeNavItem(parent, label, subtitle, icon)
    local item = New("Frame", { BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), Parent = parent })
    MakeCorner(6, item)

    local bar = New("Frame", { BackgroundColor3 = Theme.NavIndicator, BackgroundTransparency = 1, Size = UDim2.new(0, 2, 0.7, 0), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Parent = item })
    MakeCorner(1, bar)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 12, 0, 6),
        Size                   = UDim2.new(1, -16, 0, 18),
        Font                   = Enum.Font.GothamBold,
        Text                   = label,
        TextColor3             = Theme.NavItem,
        TextSize               = Theme.FontSize,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Name                   = "MainLabel",
        Parent                 = item,
    })

    if subtitle then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 12, 0, 25),
            Size                   = UDim2.new(1, -16, 0, 14),
            Font                   = Enum.Font.Gotham,
            Text                   = subtitle,
            TextColor3             = Theme.NavSub,
            TextSize               = Theme.FontSizeSmall,
            TextXAlignment         = Enum.TextXAlignment.Left,
            Parent                 = item,
        })
    end

    return item
end

--────────────────────────────────────────────────────────────────────────────────
-- WINDOW
--────────────────────────────────────────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)

    local title     = config.Title     or "Meridional"
    local iconId    = config.Icon      or Icons.Logo
    local width     = config.Width     or 820
    local height    = config.Height    or 520
    local pos       = config.Position  or UDim2.new(0.5, -width/2, 0.5, -height/2)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    self._pages      = {}
    self._navItems   = {}
    self._activePage = nil
    self._activeNav  = nil
    self._visible    = true

    local gui = New("ScreenGui", { Name = "MeridionalUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = CoreGui })
    self._gui = gui

    local win = New("Frame", { BackgroundColor3 = Theme.WindowBG, Position = pos, Size = UDim2.new(0, width, 0, height), Parent = gui })
    MakeCorner(Theme.CornerWindow, win)
    MakeStroke(Theme.WindowBorder, 1, 0, win)
    self._win = win

    New("ImageLabel", {
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 40, 1, 40),
        ZIndex                 = -1,
        Image                  = "rbxassetid://7912134082",
        ImageColor3            = Color3.new(0, 0, 0),
        ImageTransparency      = 0.5,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(40, 40, 120, 120),
        Parent                 = win,
    })

    local titleBar = New("Frame", { BackgroundColor3 = Theme.TitleBar, Size = UDim2.new(1, 0, 0, 42), Parent = win })
    New("UICorner", { CornerRadius = UDim.new(0, Theme.CornerWindow), Parent = titleBar })
    New("Frame", { BackgroundColor3 = Theme.TitleBar, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0.5, 0), BorderSizePixel = 0, Parent = titleBar })

    local iconImg = New("ImageLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = iconId, Parent = titleBar })
    self._iconImg = iconImg

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 34, 0, 0),
        Size                   = UDim2.new(0.6, 0, 1, 0),
        Font                   = Enum.Font.GothamBold,
        Text                   = title,
        TextColor3             = Theme.TitleText,
        TextSize               = Theme.FontSizeLarge,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = titleBar,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint            = Vector2.new(1, 0.5),
        Position               = UDim2.new(1, -12, 0.5, 0),
        Size                   = UDim2.new(0, 120, 0, 14),
        Font                   = Enum.Font.Gotham,
        Text                   = "[" .. toggleKey.Name .. "] to toggle",
        TextColor3             = Theme.TextSecondary,
        TextSize               = Theme.FontSizeSmall,
        TextXAlignment         = Enum.TextXAlignment.Right,
        Parent                 = titleBar,
    })

    MakeDraggable(win, titleBar)

    local body = New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 1, -42), Parent = win })

    local nav = New("Frame", { BackgroundColor3 = Theme.NavBG, Size = UDim2.new(0, 148, 1, 0), BorderSizePixel = 0, Parent = body })
    New("UICorner", { CornerRadius = UDim.new(0, Theme.CornerWindow), Parent = nav })
    New("Frame", { BackgroundColor3 = Theme.NavBG, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), BorderSizePixel = 0, Parent = nav })
    New("Frame", { BackgroundColor3 = Theme.NavBG, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 20), BorderSizePixel = 0, Parent = nav })

    local navList = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = nav })
    MakePadding(10, 10, 6, 6, navList)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = navList })
    self._navList = navList

    New("Frame", { BackgroundColor3 = Theme.WindowBorder, Position = UDim2.new(0, 148, 0, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, Parent = body })

    local contentArea = New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 149, 0, 0), Size = UDim2.new(1, -149, 1, 0), Parent = body })
    self._contentArea = contentArea

    local notifFrame = New("Frame", { AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1, Position = UDim2.new(1, -12, 1, -12), Size = UDim2.new(0, 280, 1, -60), Parent = gui })
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 6), Parent = notifFrame })
    NotifContainer = notifFrame
    self._notifFrame = notifFrame

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            self._visible = not self._visible
            Tween(win, { BackgroundTransparency = self._visible and 0 or 1, Size = self._visible and UDim2.new(0, width, 0, height) or UDim2.new(0, width, 0, 0) }, 0.2)
            win.Visible = self._visible
        end
    end)

    return self
end

function Window:Nav(label, subtitle)
    local NavEntry = {}
    NavEntry.__index = NavEntry

    local navItem = MakeNavItem(self._navList, label, subtitle)
    local entryFrame = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, Parent = self._contentArea })

    table.insert(self._pages, entryFrame)
    table.insert(self._navItems, navItem)

    local tabs = {}
    local tabPages = {}
    local activeTab = nil

    local tabBar = New("Frame", { BackgroundColor3 = Theme.TabBG, Size = UDim2.new(1, 0, 0, 36), BorderSizePixel = 0, Parent = entryFrame })
    local tabList = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -1), Parent = tabBar })
    MakePadding(0, 0, 8, 8, tabList)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2), Parent = tabList })
    New("Frame", { BackgroundColor3 = Theme.WindowBorder, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, Parent = tabBar })

    local pageHost = New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 1, -36), Parent = entryFrame })

    local function activateTab(idx)
        if activeTab == idx then return end
        activeTab = idx
        for i, tab in ipairs(tabs) do
            local isActive = i == idx
            Tween(tab._label, { TextColor3 = isActive and Theme.TabActive or Theme.TabInactive }, 0.1)
            Tween(tab._bar, { BackgroundTransparency = isActive and 0 or 1 }, 0.1)
            tabPages[i]._scroll.Visible = isActive
        end
    end

    local function activateNav()
        for i, item in ipairs(self._navItems) do
            if item ~= navItem then
                local bar = item:FindFirstChild("Frame")
                if bar then Tween(bar, { BackgroundTransparency = 1 }, 0.1) end
                local mainLabel = item:FindFirstChild("MainLabel")
                if mainLabel then Tween(mainLabel, { TextColor3 = Theme.NavItem }, 0.1) end
                item.BackgroundTransparency = 1
            end
        end

        for _, page in ipairs(self._pages) do
            page.Visible = false
        end

        entryFrame.Visible = true
        Tween(navItem, { BackgroundTransparency = 0, BackgroundColor3 = Theme.DropdownHover }, 0.12)
        local bar = navItem:FindFirstChildWhichIsA("Frame")
        if bar then Tween(bar, { BackgroundTransparency = 0 }, 0.12) end
        local mainLabel = navItem:FindFirstChild("MainLabel")
        if mainLabel then Tween(mainLabel, { TextColor3 = Theme.NavItemActive }, 0.12) end
        self._activeNav = navItem

        if not activeTab and #tabs > 0 then
            activateTab(1)
        end
    end

    navItem.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then activateNav() end
    end)
    navItem.MouseEnter:Connect(function()
        if self._activeNav ~= navItem then Tween(navItem, { BackgroundTransparency = 0.7, BackgroundColor3 = Theme.DropdownHover }, 0.08) end
    end)
    navItem.MouseLeave:Connect(function()
        if self._activeNav ~= navItem then Tween(navItem, { BackgroundTransparency = 1 }, 0.08) end
    end)

    if #self._pages == 1 then activateNav() end

    function NavEntry:Tab(tabLabel)
        local idx = #tabs + 1

        local tabBtn = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = tabList })
        local tabLbl = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, -2), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.GothamBold, Text = tabLabel, TextColor3 = idx == 1 and Theme.TabActive or Theme.TabInactive, TextSize = Theme.FontSize, Name = "MainLabel", Parent = tabBtn })
        MakePadding(0, 0, 10, 10, tabLbl)

        local underBar = New("Frame", { AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.TabUnderline, BackgroundTransparency = idx == 1 and 0 or 1, Position = UDim2.new(0, 0, 1, 1), Size = UDim2.new(1, 0, 0, 2), Parent = tabBtn })

        table.insert(tabs, { _label = tabLbl, _bar = underBar })

        local pageFrame = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = idx == 1, Parent = pageHost })
        local page = TabPage.new(pageFrame)
        table.insert(tabPages, page)

        tabBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                activateNav()
                activateTab(idx)
            end
        end)

        tabLbl.MouseEnter:Connect(function() if activeTab ~= idx then Tween(tabLbl, { TextColor3 = Theme.NavItemHover }, 0.08) end end)
        tabLbl.MouseLeave:Connect(function() if activeTab ~= idx then Tween(tabLbl, { TextColor3 = Theme.TabInactive }, 0.08) end end)

        if idx == 1 and not activeTab then activeTab = 1 end
        return page
    end

    return setmetatable({}, NavEntry)
end

function Window:SetIcon(assetId)
    if self._iconImg then self._iconImg.Image = assetId end
end

function Window:SetTheme(overrides)
    ApplyTheme(overrides)
end

function Window:Notify(title, message, duration)
    Notify(title, message, duration)
end

function Window:Destroy()
    self._gui:Destroy()
end

local Meridional = {}
Meridional.__index = Meridional

function Meridional.new(config)
    return Window.new(config)
end

Meridional.Theme  = Theme
Meridional.Icons  = Icons
Meridional.Notify = Notify

return Meridional
