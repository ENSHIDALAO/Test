local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- 显示通知函数
local function showNotification(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "物品收集脚本",
        Text = message,
        Duration = 5,
        Icon = "rbxassetid://0" -- 可以替换为其他图标ID
    })
    print(message) -- 同时在输出窗口打印
end

-- 初始化变量
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local forbiddenZoneCenter = Vector3.new(352.884155, 13.0287256, -1353.05396)
local forbiddenRadius = 80

-- 目标物品列表
local targetItems = { 
    "Money Printer",
    "Blue Candy Cane",
    "Bunny Balloon",
    "Ghost Balloon",
    "Clover Balloon",
    "Bat Balloon",
    "Gold Clover Balloon",
    "Golden Rose",
    "Black Rose",
    "Heart Balloon",
    "Dafy Money Printor",
}

-- 显示脚本启动通知
showNotification("物品收集脚本已开启！")

-- 模拟E键按下
local function pressEKey()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
    wait(0.01)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
end

-- 物品检测功能
local function FindTargetItems()
    local foundItems = {}
    local startTime = os.clock()
    
    for _, itemFolder in pairs(game:GetService("Workspace").Game.Entities.ItemPickup:GetChildren()) do
        for _, item in pairs(itemFolder:GetChildren()) do
            if (item:IsA("MeshPart") or item:IsA("Part")) and os.clock() - startTime < 0.5 then
                local itemPos = item.Position
                local distance = (itemPos - forbiddenZoneCenter).Magnitude
                
                if distance > forbiddenRadius then
                    local prompt = item:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and table.find(targetItems, prompt.ObjectText) then
                        table.insert(foundItems, {
                            item = item,
                            prompt = prompt,
                            distance = (itemPos - HumanoidRootPart.Position).Magnitude
                        })
                    end
                end
            end
        end
    end
    
    -- 按距离排序
    table.sort(foundItems, function(a, b)
        return a.distance < b.distance
    end)
    
    return foundItems
end

-- 物品收集功能
local function PickItem(item, prompt)
    local startTime = tick()
    local timeout = 15
    local itemCollected = false
    
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not item or not item.Parent then
            itemCollected = true
            connection:Disconnect()
            return
        end
        
        if tick() - startTime >= timeout then
            connection:Disconnect()
            return
        end
        
        -- 移动到物品位置
        HumanoidRootPart.CFrame = item.CFrame * CFrame.new(0, 2, 0)
        
        -- 检测到物品时模拟E键
        pressEKey()
        
        fireproximityprompt(prompt)
    end)
    
    repeat 
        task.wait(0.1) 
    until itemCollected or not item or not item.Parent or tick() - startTime >= timeout
    
    if connection then
        connection:Disconnect()
    end
    
    return itemCollected
end

-- 主循环
while true do
    character = player.Character or player.CharacterAdded:Wait()
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    local items = FindTargetItems()
    if #items > 0 then
        for _, itemData in ipairs(items) do
            if PickItem(itemData.item, itemData.prompt) then
                break
            end
        end
    end
    
    task.wait(0.5) -- 每0.5秒检查一次
end
