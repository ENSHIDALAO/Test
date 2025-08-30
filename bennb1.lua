local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- 显示通知函数
local function showNotification(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "自动抢银行脚本",
        Text = message,
        Duration = 5,
        Icon = "rbxassetid://92410166181133"
    })
    print(message) -- 同时在输出窗口打印
end

-- 显示脚本启动通知
showNotification("自动抢银行脚本已开启！")

local function AutoFarmBank()
    local BankDoor = workspace.BankRobbery.VaultDoor
    local BankCashs = workspace.BankRobbery.BankCash

    showNotification("开始抢劫银行...")
    
    while task.wait(0.1) do
        if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true and BankCashs.Cash:FindFirstChild("Bundle") then
            showNotification("正在开启银行门...")
            HumanoidRootPart.CFrame = CFrame.new(1078.08093, 6.24685, -343.95758)
            BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            fireproximityprompt(BankDoor.Door.Attachment.ProximityPrompt)
            task.wait(0.5)
        elseif not BankDoor.Door.Attachment.ProximityPrompt.Enabled and BankCashs.Cash:FindFirstChild("Bundle") then
            showNotification("正在拾取银行现金...")
            local targetPos = BankCashs.Cash:FindFirstChild("Bundle"):GetPivot().Position
            local basePosition = Vector3.new(targetPos.X, targetPos.Y - 5, targetPos.Z)
            local lookVector = (targetPos - basePosition).Unit
            HumanoidRootPart.CFrame = CFrame.new(basePosition, basePosition + lookVector)
            BankCashs.Main.Attachment.ProximityPrompt.RequiresLineOfSight = false
            BankCashs.Main.Attachment.ProximityPrompt.HoldDuration = 0
            fireproximityprompt(BankCashs.Main.Attachment.ProximityPrompt)
            task.wait(1)
        else
            showNotification("银行抢劫完成，等待下一次执行...")
            break
        end
    end
end

-- 循环执行抢银行函数
while true do
    -- 确保角色存在
    character = player.Character or player.CharacterAdded:Wait()
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    -- 执行抢银行
    AutoFarmBank()
    
    -- 等待一段时间再重新执行
    task.wait(5) -- 等待5秒后再次执行
end
