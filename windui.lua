loadstring([==[-- WindUI.lua
local WindUI = {}

-- 颜色配置
WindUI.Colors = {
    Background = Color3.fromRGB(25, 25, 35),
    Primary = Color3.fromRGB(0, 120, 215),
    Secondary = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
    Error = Color3.fromRGB(244, 67, 54),
    Border = Color3.fromRGB(60, 60, 70),
    Hover = Color3.fromRGB(35, 35, 45)
}

-- 基础元素类
function WindUI:CreateElement(type, properties)
    local element = Instance.new(type)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

-- 创建主窗口
function WindUI:CreateWindow(title, size)
    local screenGui = self:CreateElement("ScreenGui", {
        Name = "DeltaXUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local mainFrame = self:CreateElement("Frame", {
        Size = size or UDim2.new(0, 400, 0, 500),
        Position = UDim2.new(0.5, -200, 0.5, -250),
        BackgroundColor3 = self.Colors.Background,
        BorderColor3 = self.Colors.Border,
        BorderSizePixel = 1,
        ClipsDescendants = true
    })

    local titleBar = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Colors.Primary,
        BorderSizePixel = 0
    })

    local titleText = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "DeltaX Injector",
        TextColor3 = self.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })

    local closeButton = self:CreateElement("TextButton", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundColor3 = self.Colors.Error,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })

    local contentFrame = self:CreateElement("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Colors.Primary,
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
    local dragging = false
    local dragInput, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

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

-- 创建按钮
function WindUI:CreateButton(text, callback)
    local button = self:CreateElement("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Colors.Secondary,
        BorderColor3 = self.Colors.Border,
        BorderSizePixel = 1,
        Text = text,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        AutoButtonColor = false
    })

    local corner = self:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 4)
    })
    corner.Parent = button

    -- 悬停效果
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Colors.Hover
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Colors.Secondary
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

-- 创建标签
function WindUI:CreateLabel(text, size)
    local label = self:CreateElement("TextLabel", {
        Size = size or UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return label
end

-- 创建切换开关
function WindUI:CreateToggle(text, default, callback)
    local toggleFrame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })

    local label = self:CreateElement("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local toggleButton = self:CreateElement("TextButton", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = default and self.Colors.Success or self.Colors.Secondary,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })

    local toggleCircle = self:CreateElement("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = self.Colors.Text,
        BorderSizePixel = 0
    })

    local corner1 = self:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 10)
    })
    local corner2 = self:CreateElement("UICorner", {
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
        
        game:GetService("TweenService"):Create(toggleCircle, TweenInfo.new(0.2), {
            Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = isToggled and self.Colors.Success or self.Colors.Secondary
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
            toggleButton.BackgroundColor3 = state and self.Colors.Success or self.Colors.Secondary
        end,
        GetState = function()
            return isToggled
        end
    }
end

-- 创建滑块
function WindUI:CreateSlider(text, min, max, default, callback)
    local sliderFrame = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })

    local label = self:CreateElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = self:CreateElement("TextLabel", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local track = self:CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = self.Colors.Secondary,
        BorderSizePixel = 0
    })

    local fill = self:CreateElement("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Colors.Primary,
        BorderSizePixel = 0
    })

    local thumb = self:CreateElement("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = self.Colors.Text,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })

    local corner1 = self:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 2)
    })
    local corner2 = self:CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0)
    })

    corner1.Parent = track
    corner2.Parent = thumb

    fill.Parent = track
    thumb.Parent = track
    track.Parent = sliderFrame
    label.Parent = sliderFrame
    valueLabel.Parent = sliderFrame

    local isDragging = false
    local currentValue = default

    local function updateValue(value)
        currentValue = math.clamp(value, min, max)
        local ratio = (currentValue - min) / (max - min)
        
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, -8, 0.5, -8)
        valueLabel.Text = tostring(math.floor(currentValue))
        
        if callback then
            callback(currentValue)
        end
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)

    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local trackPos = track.AbsolutePosition
            local trackSize = track.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
            local value = min + (max - min) * relativeX
            updateValue(value)
        end
    end)

    return {
        Frame = sliderFrame,
        SetValue = updateValue,
        GetValue = function()
            return currentValue
        end
    }
end

-- 创建选项卡
function WindUI:CreateTab(text)
    local tabButton = self:CreateElement("TextButton", {
        Size = UDim2.new(0, 80, 0, 30),
        BackgroundColor3 = self.Colors.Secondary,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = self.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        AutoButtonColor = false
    })

    local tabContent = self:CreateElement("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Colors.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    })

    local layout = self:CreateElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    layout.Parent = tabContent

    return {
        Button = tabButton,
        Content = tabContent,
        Active = false
    }
end

return WindUI]==])()
