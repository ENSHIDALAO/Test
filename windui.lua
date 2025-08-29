loadstring([==[-- WindUI.lua
--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    by .ftgs#0 (Discord)
    
    This script is NOT intended to be modified.
    To view the source code, see the 'Src' folder on the official GitHub repository.
    
    Author: .ftgs#0 (Discord User)
    Github: https://github.com/Footagesus/WindUI
    Discord: https://discord.gg/84CNGY5wAV
]]

local WindUI = {cache = {}}

function WindUI.load(b)
    if not WindUI.cache[b] then
        WindUI.cache[b] = {c = WindUI[b]()}
    end
    return WindUI.cache[b].c
end

-- 核心UI组件
function WindUI.a()
    local b = game:GetService("RunService")
    local d = b.Heartbeat
    local e = game:GetService("UserInputService")
    local f = game:GetService("TweenService")
    
    local j = {
        Font = "rbxassetid://12187365364",
        CanDraggable = true,
        Signals = {},
        Objects = {},
        DefaultProperties = {
            ScreenGui = {
                ResetOnSpawn = false,
                ZIndexBehavior = "Sibling",
            },
            Frame = {
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.new(1, 1, 1),
            },
            TextLabel = {
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Text = "",
                RichText = true,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 14,
            },
            TextButton = {
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 14,
            }
        },
        Colors = {
            Red = "#e53935",
            Orange = "#f57c00",
            Green = "#43a047",
            Blue = "#039be5",
            White = "#ffffff",
            Grey = "#484848",
        },
    }

    -- 主题配置
    j.Themes = {
        Dark = {
            Name = "Dark",
            Accent = "#18181b",
            Dialog = "#161616",
            Outline = "#FFFFFF",
            Text = "#FFFFFF",
            Placeholder = "#999999",
            Background = "#101010",
            Button = "#52525b",
            Icon = "#a1a1aa",
        }
    }
    
    j.Theme = j.Themes.Dark

    function j.Init(l)
        -- 初始化函数
    end

    function j.New(l, m, p)
        local r = Instance.new(l)
        for u, v in next, j.DefaultProperties[l] or {} do
            r[u] = v
        end
        for x, z in next, m or {} do
            r[x] = z
        end
        for A, B in next, p or {} do
            B.Parent = r
        end
        return r
    end

    function j.Tween(l, m, p, ...)
        return f:Create(l, TweenInfo.new(m, ...), p)
    end

    function j.NewRoundFrame(l, m, p, r, x)
        local z = j.New(x and "ImageButton" or "ImageLabel", {
            Image = m == "Squircle" and "rbxassetid://80999662900595" or
                     m == "SquircleOutline" and "rbxassetid://117788349049947",
            ScaleType = "Slice",
            SliceCenter = Rect.new(256, 256, 256, 256),
            SliceScale = 1,
            BackgroundTransparency = 1,
        }, r)

        for A, B in pairs(p or {}) do
            z[A] = B
        end
        return z
    end

    function j.Drag(p, r, x)
        local z, A, B, C, F
        local G = {CanDraggable = true}
        
        if not r or type(r) ~= "table" then
            r = {p}
        end
        
        for H, J in pairs(r) do
            J.InputBegan:Connect(function(L)
                if (L.UserInputType == Enum.UserInputType.MouseButton1 or L.UserInputType == Enum.UserInputType.Touch) and G.CanDraggable then
                    z = J
                    A = true
                    C = L.Position
                    F = p.Position
                    
                    L.Changed:Connect(function()
                        if L.UserInputState == Enum.UserInputState.End then
                            A = false
                            z = nil
                        end
                    end)
                end
            end)
            
            J.InputChanged:Connect(function(L)
                if z == J and A then
                    if L.UserInputType == Enum.UserInputType.MouseMovement or L.UserInputType == Enum.UserInputType.Touch then
                        B = L
                    end
                end
            end)
        end
        
        e.InputChanged:Connect(function(L)
            if L == B and A and z ~= nil then
                if G.CanDraggable then
                    local J = L.Position - C
                    j.Tween(p, 0.02, {
                        Position = UDim2.new(F.X.Scale, F.X.Offset + J.X, F.Y.Scale, F.Y.Offset + J.Y)
                    }):Play()
                end
            end
        end)
        
        return G
    end

    return j
end

-- 窗口创建
function WindUI.b()
    local b = WindUI.load("a")
    
    function b:CreateWindow(title, size)
        local screenGui = b.New("ScreenGui", {
            Name = "DeltaXUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        
        local mainFrame = b.New("Frame", {
            Size = size or UDim2.new(0, 400, 0, 500),
            Position = UDim2.new(0.5, -200, 0.5, -250),
            BackgroundColor3 = Color3.fromHex(b.Theme.Background),
            BorderColor3 = Color3.fromHex(b.Theme.Outline),
            BorderSizePixel = 1,
            ClipsDescendants = true
        })
        
        local titleBar = b.New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromHex(b.Theme.Accent),
            BorderSizePixel = 0
        })
        
        local titleText = b.New("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = title or "DeltaX Injector",
            TextColor3 = Color3.fromHex(b.Theme.Text),
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 14
        })
        
        local closeButton = b.New("TextButton", {
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundColor3 = Color3.fromHex(b.Colors.Red),
            BorderSizePixel = 0,
            Text = "X",
            TextColor3 = Color3.fromHex(b.Theme.Text),
            Font = Enum.Font.GothamBold,
            TextSize = 14
        })
        
        local contentFrame = b.New("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -50),
            Position = UDim2.new(0, 10, 0, 40),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromHex(b.Theme.Accent),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        -- 组装元素
        titleBar.Parent = mainFrame
        titleText.Parent = titleBar
        closeButton.Parent = titleBar
        contentFrame.Parent = mainFrame
        mainFrame.Parent = screenGui
        
        -- 拖拽功能
        b.Drag(mainFrame, {titleBar})
        
        -- 关闭按钮功能
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
        
        return {
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            ContentFrame = contentFrame,
            Close = function()
                screenGui:Destroy()
            end
        }
    end
    
    return b
end

-- 按钮组件
function WindUI.c()
    local b = WindUI.load("a")
    
    function b:CreateButton(text, callback)
        local button = b.New("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Color3.fromHex(b.Theme.Button),
            BorderColor3 = Color3.fromHex(b.Theme.Outline),
            BorderSizePixel = 1,
            Text = text,
            TextColor3 = Color3.fromHex(b.Theme.Text),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            AutoButtonColor = false
        })
        
        local corner = b.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
        corner.Parent = button
        
        -- 悬停效果
        button.MouseEnter:Connect(function()
            b.Tween(button, 0.2, {
                BackgroundColor3 = Color3.fromHex(b.Theme.Accent)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            b.Tween(button, 0.2, {
                BackgroundColor3 = Color3.fromHex(b.Theme.Button)
            }):Play()
        end)
        
        -- 点击效果
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        return button
    end
    
    return b
end

-- 标签组件
function WindUI.d()
    local b = WindUI.load("a")
    
    function b:CreateLabel(text, size)
        local label = b.New("TextLabel", {
            Size = size or UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromHex(b.Theme.Text),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        return label
    end
    
    return b
end

-- 切换开关组件
function WindUI.e()
    local b = WindUI.load("a")
    
    function b:CreateToggle(text, default, callback)
        local toggleFrame = b.New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1
        })
        
        local label = b.New("TextLabel", {
            Size = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromHex(b.Theme.Text),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local toggleButton = b.New("TextButton", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = default and Color3.fromHex(b.Colors.Green) or Color3.fromHex(b.Theme.Button),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        
        local toggleCircle = b.New("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.fromHex(b.Theme.Text),
            BorderSizePixel = 0
        })
        
        local corner1 = b.New("UICorner", {
            CornerRadius = UDim.new(0, 10)
        })
        local corner2 = b.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
        
        corner1.Parent = toggleButton
        corner2.Parent = toggleCircle
        
        label.Parent = toggleFrame
        toggleButton.Parent = toggleFrame
        toggleCircle.Parent = toggleButton
        
        local isToggled = default or false
        
        toggleButton.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            
            b.Tween(toggleCircle, 0.2, {
                Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            b.Tween(toggleButton, 0.2, {
                BackgroundColor3 = isToggled and Color3.fromHex(b.Colors.Green) or Color3.fromHex(b.Theme.Button)
            }):Play()
            
            if callback then
                callback(isToggled)
            end
        end)
        
        return {
            Frame = toggleFrame,
            SetState = function(state)
                isToggled = state
                toggleCircle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                toggleButton.BackgroundColor3 = state and Color3.fromHex(b.Colors.Green) or Color3.fromHex(b.Theme.Button)
            end,
            GetState = function()
                return isToggled
            end
        }
    end
    
    return b
end

-- 初始化WindUI
function WindUI.Init()
    WindUI.Core = WindUI.load("a")
    WindUI.Window = WindUI.load("b")
    WindUI.Button = WindUI.load("c")
    WindUI.Label = WindUI.load("d")
    WindUI.Toggle = WindUI.load("e")
    
    return WindUI
end

return WindUI]==])()
