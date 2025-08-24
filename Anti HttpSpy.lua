loalocal Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local MemoryStoreService = game:GetService("MemoryStoreService")

local player = Players.LocalPlayer
local currentJobId = game.JobId

-- 全局防护标志
local SECURITY_ENABLED = true
local DETECTION_COUNT = 0
local MAX_DETECTIONS = 3

-- 加密密钥（动态生成）
local SECURITY_KEY = game:GetService("HashService"):GenerateGUID(false)

-- 反调试检测
local function antiDebug()
    -- 检测常见的调试器特征
    local debuggers = {
        "dex", "ida", "ollydbg", "x64dbg", "cheatengine",
        "processhacker", "systemexplorer", "wireshark"
    }
    
    -- 模拟环境检查（在实际环境中需要更复杂的检测）
    if getfenv(0).debug or getfenv(0).hook or getfenv(0).metatable then
        return true
    end
    
    return false
end

-- 检测HTTP Spy工具
local function detectHttpSpy()
    local spyTools = {
        "fiddler", "charles", "mitmproxy", "burpsuite", 
        "proxyman", "httpdebugger", "wireshark", "tcpdump"
    }
    
    -- 尝试检测代理设置
    pcall(function()
        local testResponse = HttpService:GetAsync("https://httpbin.org/headers", true)
        if testResponse then
            for _, tool in ipairs(spyTools) do
                if testResponse:lower():find(tool) then
                    return true
                end
            end
            
            -- 检测代理头
            if testResponse:find("X-Forwarded") or testResponse:find("Via") then
                return true
            end
        end
    end)
    
    return false
end

-- 检测内存修改
local function detectMemoryTampering()
    -- 检查关键函数是否被hook
    local criticalFunctions = {
        game.GetService,
        Instance.new,
        getfenv,
        setfenv,
        getmetatable,
        setmetatable
    }
    
    for _, func in ipairs(criticalFunctions) do
        if debug.info(func, "s") ~= "[C]" then
            return true
        end
    end
    
    return false
end

-- 检测注入的脚本
local function detectInjectedScripts()
    -- 检查CoreGui中的异常对象
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child:IsA("ScreenGui") and child.Name:find("Inject") then
            return true
        end
    end
    
    -- 检查玩家背包中的异常脚本
    if player:FindFirstChild("Backpack") then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item:IsA("LocalScript") and item.Name:find("Cheat") then
                return true
            end
        end
    end
    
    return false
end

-- 检测速度黑客
local function detectSpeedHack()
    local lastTime = tick()
    local consistentTime = 0
    
    for i = 1, 10 do
        local currentTime = tick()
        local delta = currentTime - lastTime
        
        -- 如果时间增量异常（加速或减速）
        if delta < 0.09 or delta > 0.11 then -- 正常应该在0.1秒左右
            consistentTime = consistentTime + 1
        end
        
        lastTime = currentTime
        wait(0.1)
    end
    
    return consistentTime > 5
end

-- 安全服务器通信
local function secureServerCommunication()
    local timestamp = os.time()
    local signature = game:GetService("HashService"):ComputeSHA256(SECURITY_KEY .. timestamp)
    
    -- 加密的服务器验证
    pcall(function()
        local response = HttpService:GetAsync(
            "https://httpbin.org/get?_t=" .. timestamp .. "&_s=" .. signature,
            true
        )
        
        -- 验证响应完整性
        if response and not response:find("sha256") then
            return false
        end
    end)
    
    return true
end

-- 立即踢出玩家
local function kickPlayer(reason)
    if not SECURITY_ENABLED then return end
    
    print("🚨 安全警报：", reason, "玩家将被踢出！")
    
    -- 方案1：通过TeleportService踢出
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, "KICK_" .. player.UserId)
    end)
    
    -- 方案2：断开连接
    pcall(function()
        game:Shutdown()
    end)
    
    -- 方案3：强制错误
    pcall(function()
        while true do end
    end)
end

-- 行为分析系统
local function behaviorAnalysis()
    local suspiciousActions = 0
    local lastActionTime = tick()
    
    -- 监控异常行为模式
    local function monitorActions()
        local currentTime = tick()
        local timeDiff = currentTime - lastActionTime
        
        -- 检测异常快速的操作
        if timeDiff < 0.01 then
            suspiciousActions = suspiciousActions + 1
        end
        
        lastActionTime = currentTime
        
        if suspiciousActions > 10 then
            kickPlayer("行为异常检测：操作频率过高")
        end
    end
    
    -- Hook关键函数进行监控
    local originalNamecall
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        monitorActions()
        return originalNamecall(self, ...)
    end)
end

-- 反Hook保护
local function antiHookProtection()
    -- 保护关键元方法
    local protectedMetaMethods = {
        "__index", "__newindex", "__namecall", "__call"
    }
    
    for _, method in ipairs(protectedMetaMethods) do
        local original = getrawmetatable(game)[method]
        setreadonly(getrawmetatable(game), false)
        
        getrawmetatable(game)[method] = function(...)
            -- 检测非法调用
            if debug.info(2, "f") ~= "[C]" then
                kickPlayer("检测到元方法Hook尝试")
                return nil
            end
            return original(...)
        end
    end
    setreadonly(getrawmetatable(game), true)
end

-- 完整性检查
local function integrityCheck()
    -- 检查核心函数是否被修改
    local coreFunctions = {
        "loadstring", "require", "getfenv", "setfenv",
        "getmetatable", "setmetatable", "hookfunction"
    }
    
    for _, funcName in ipairs(coreFunctions) do
        if _G[funcName] and debug.info(_G[funcName], "s") ~= "[C]" then
            kickPlayer("核心函数被修改: " .. funcName)
            return false
        end
    end
    
    return true
}

-- 主安全监控循环
local function securityMonitor()
    if not SECURITY_ENABLED then return end
    
    -- 启动行为分析
    behaviorAnalysis()
    
    -- 启动反Hook保护
    pcall(antiHookProtection)
    
    while SECURITY_ENABLED and task.wait(5) do
        -- 执行各种检测
        local detections = {
            {func = antiDebug, reason = "反调试检测"},
            {func = detectHttpSpy, reason = "HTTP Spy检测"},
            {func = detectMemoryTampering, reason = "内存篡改检测"},
            {func = detectInjectedScripts, reason = "注入脚本检测"},
            {func = detectSpeedHack, reason = "速度黑客检测"},
            {func = secureServerCommunication, reason = "通信验证失败"},
            {func = integrityCheck, reason = "完整性检查失败"}
        }
        
        for _, detection in ipairs(detections) do
            local success, result = pcall(detection.func)
            if success and result then
                DETECTION_COUNT = DETECTION_COUNT + 1
                print("⚠️ 安全警告 (" .. DETECTION_COUNT .. "/" .. MAX_DETECTIONS .. "): " .. detection.reason)
                
                if DETECTION_COUNT >= MAX_DETECTIONS then
                    kickPlayer("多次安全违规: " .. detection.reason)
                    return
                end
            end
        end
        
        -- 定期重置计数（防止误报积累）
        if DETECTION_COUNT > 0 and tick() % 60 < 5 then
            DETECTION_COUNT = math.max(0, DETECTION_COUNT - 1)
        end
    end
end

-- 初始化安全系统
local function initializeSecurity()
    print("🛡️ 初始化高级安全防护系统...")
    
    -- 设置全局保护
    setidentity(2) -- 降低权限防止被修改
    
    -- 防止脚本被禁用
    if not SECURITY_ENABLED then
        SECURITY_ENABLED = true
    end
    
    -- 启动安全监控
    spawn(securityMonitor)
    
    -- 添加关闭保护的命令（仅用于调试）
    player.Chatted:Connect(function(message)
        if message == "/disablesecurity" and player.UserId == 你的用户ID then -- 替换为你的用户ID
            SECURITY_ENABLED = false
            print("安全系统已手动禁用")
        end
    end)
    
    print("✅ 安全系统初始化完成，开始监控...")
end

-- 立即启动安全系统
initializeSecurity()

-- 防止多次执行
if _G.ANTI_CHEAT_LOADED then
    kickPlayer("重复执行防护脚本")
    return
end
_G.ANTI_CHEAT_LOADED = true

-- 清理函数（防止内存泄漏）
game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        SECURITY_ENABLED = false
        _G.ANTI_CHEAT_LOADED = nil
    end
end)

return {
    EnableSecurity = function() SECURITY_ENABLED = true end,
    DisableSecurity = function() SECURITY_ENABLED = false end,
    GetDetectionCount = function() return DETECTION_COUNT end
}
