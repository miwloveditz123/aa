print("wait...")
task.wait(90)
local function ClickPlay()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return false end
    
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return false end
    
    local intro = PlayerGui:FindFirstChild("IntroUI")
    if not intro then
        return true
    end
    
    local playButton = nil
    
    for _, obj in pairs(intro:GetDescendants()) do
        if obj:IsA("ImageButton") and obj.Name == "Play" then
            playButton = obj
            break
        end
    end
    
    if not playButton then
        return false
    end
    
    pcall(function()
        playButton.MouseButton1Click:Fire()
    end)
    
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        if VIM then
            local pos = playButton.AbsolutePosition
            local size = playButton.AbsoluteSize
            if pos.X > 0 and pos.Y > 0 then
                VIM:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
            end
        end
    end)
    
    pcall(function()
        local conns = getconnections(playButton.MouseButton1Click)
        if conns then
            for _, conn in pairs(conns) do
                conn:Fire()
            end
        end
    end)
    
    task.wait(1)
    return true
end

-- ============================================================
-- 🔥 EXECUTE AUTO CLICK PLAY
-- ============================================================
local maxAttempts = 5
local attempts = 0
local clicked = false

while attempts < maxAttempts do
    local success = ClickPlay()
    if success then
        clicked = true
        break
    end
    attempts = attempts + 1
    task.wait(1)
end





local VirtualInputManager = game:GetService("VirtualInputManager")

task.spawn(function()
    while task.wait(120) do
        -- Kirim F15 pakai VirtualInputManager
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F15, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F15, false, game)
        
        print("bypassed -", os.date("%H:%M:%S"))
    end
end)-- ── Executor Check ───────────────────────────────────────────
do
    local ok, execName = pcall(function()
        local identify = identifyexecutor or getexecutorname or get_executor_name
        if identify then return identify() end
        return nil
    end)
    if ok and execName and type(execName) == "string" then
        if execName:lower():find("xeno") then
            local plr = game:GetService("Players").LocalPlayer
            if plr then
                plr:Kick("Xeno executor is not supported. Please use a different executor.")
            end
            return
        end
    end
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
while not Players.LocalPlayer do task.wait(0.1) end
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 💀 AUTO EXECUTE URL KALAU KARAKTER MATI
-- (TANPA REJOIN - cuma execute 1x)
-- ==========================================
local AF_CONFIG = {
    -- ⬇️⬇️⬇️ URL YANG DI-EXECUTE KALAU KARAKTER MATI (GANTI SENDIRI) ⬇️⬇️⬇️
    ScriptUrl = "https://pastefy.app/4wUG01E6/raw",

    -- Menunggu berapa detik setelah mati sebelum execute
    ExecuteDelay = 2,

    -- Maksimal berapa kali execute (1 = cuma sekali)
    MaxExecute = 1,

    -- Aktif / tidak
    Enabled = true,
}


-- ==========================================
-- 💀 AUTO EXECUTE URL KALAU KARAKTER MATI
-- ==========================================
local AF_ExecuteCount = 0
local AF_DeathTeleport = false

-- Tandai death teleport yang SENGAJA -> jangan auto execute
function _G.MarkDeathTeleport()
    AF_DeathTeleport = true
end

local function AF_ExecuteUrl()
    if not AF_CONFIG.Enabled then return end
    if AF_ExecuteCount >= (AF_CONFIG.MaxExecute or 1) then return end
    AF_ExecuteCount = AF_ExecuteCount + 1

    print("💀 [AUTO] Karakter mati -> execute URL (" .. AF_ExecuteCount .. "/" .. (AF_CONFIG.MaxExecute or 1) .. ")")
    pcall(function()
        local s = getgenv()._AF_StatusLbl
        if s then s.Text = "Mati -> execute URL..." end
    end)

    task.wait(AF_CONFIG.ExecuteDelay or 2)

    pcall(function()
        local src = game:HttpGet(AF_CONFIG.ScriptUrl)
        local fn = loadstring(src)
        if fn then fn() end
    end)
end

_G.ExecuteOnDeath = AF_ExecuteUrl

local function AF_WatchDeath(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end

    hum.Died:Connect(function()
        if AF_DeathTeleport then
            AF_DeathTeleport = false
            print("💀 [AUTO] Death teleport -> skip execute")
            return
        end
        task.spawn(AF_ExecuteUrl)
    end)
end

-- Karakter sekarang
if LocalPlayer.Character then
    task.spawn(function() AF_WatchDeath(LocalPlayer.Character) end)
end
-- Karakter berikutnya (respawn)
LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function() AF_WatchDeath(char) end)
end)


-- ============================================================
-- BYPASS HYPHON
-- ============================================================
if not filtergc then
    filtergc = function(ftype, filters, returnSingle)
        local results = {}
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "function" then
                local ok, info = pcall(debug.getinfo, obj)
                if ok and info then
                    local match = true
                    if filters.StartLine and info.linedefined ~= filters.StartLine then match = false end
                    if filters.Source and info.source ~= filters.Source then match = false end
                    if match then
                        if returnSingle then return obj end; table.insert(results, obj)
                    end
                end
            end
        end
        if returnSingle then return nil end; return results
    end
end
if not getnilinstances then getnilinstances = function() return {} end end
if not bit32 then bit32 = {} end
if not bit32.bxor then
    bit32.bxor = function(a, b)
        local result, bit = 0, 1
        while a > 0 or b > 0 do
            if (a % 2) ~= (b % 2) then result = result + bit end
            a, b, bit = math.floor(a / 2), math.floor(b / 2), bit * 2
        end
        return result
    end
end

local emOk, emErr = pcall(function()
    local gv = getgenv()
    local function tryFind(name, ln)
        local fn = filtergc("function", { StartLine = ln }, true)
        if type(fn) ~= "function" then fn = (type(fn) == "table" and #fn > 0 and fn[1]) or nil end
        if not fn then local all = filtergc("function", { StartLine = ln })
            if type(all) == "table" and #all > 0 then fn = all[1] end end
        if fn then gv[name] = fn end; return fn
    end
    gv.Hyphon_2102 = tryFind("Hyphon_2102", 2102)
    gv.Hyphon_2247 = tryFind("Hyphon_2247", 2247)
    gv.Hyphon_2846 = tryFind("Hyphon_2846", 2846)
    gv.Hyphon_fake_dec = tryFind("Hyphon_fake_dec", 1097)
    if gv.Hyphon_2102 then
        gv.Hyphon_Encode = debug.getupvalue(gv.Hyphon_2102, 1)
        gv.Hyphon_Decode = debug.getupvalue(gv.Hyphon_2102, 21)
    end
    gv.Hyphon_Script = nil
    pcall(function()
        for _, o in pairs(getnilinstances()) do
            if o:IsA("Script") and o.Name:len() == 32 then gv.Hyphon_Script = o; break end end
    end)
    if gv.Hyphon_2102 and gv.Hyphon_2247 and gv.Hyphon_2846 and gv.Hyphon_fake_dec then
        pcall(function()
            local HC = cloneref(game:GetService("MemoryStoreService")):FindFirstChild("Hyphon_Check")
            local RF = debug.getupvalue(gv.Hyphon_2247, 6)

            -- Helper AMAN: pasang hook tanpa risiko "C stack overflow".
            -- Kalau hookfunction me-return hook yang SAMA dengan yang kita pasang,
            -- berarti "original" tidak didapat -> JANGAN dipakai (bisa rekursi).
            local function safeHook(target, hookFn)
                if type(target) ~= "function" or type(hookfunction) ~= "function" then return nil end
                local ok, ret = pcall(hookfunction, target, hookFn)
                if not ok or ret == nil or ret == hookFn then
                    return nil
                end
                return ret
            end

            if HC then
                local real
                real = safeHook(HC.FireServer, function(s, ...)
                    if real then return real(s, ...) end
                end)
            end

            if RF then
                local real
                real = safeHook(RF.InvokeServer, function(s, ...)
                    local a = table.pack(...)
                    if type(a[1]) == "table" and a[1][1] then gv.T1 = a[1][1]; gv.T2 = a[1][2]; gv.T3 = a[1][6]; gv.T4 = a[1][11] end
                    if real then return real(s, ...) end
                end)
            end
        end)
        if bit32 and bit32.bxor and gv.Hyphon_Script and checkcaller and getcallingscript then
            pcall(function()
                local real
                local hookFn = function(a, b)
                    if not checkcaller() and getcallingscript() == gv.Hyphon_Script then return task.wait(9e9) end
                    if real then return real(a, b) end
                end
                local ok, ret = pcall(hookfunction, bit32.bxor, hookFn)
                if ok and ret ~= nil and ret ~= hookFn then
                    real = ret
                end
            end)
        end
    end
    pcall(function()
        for _, Object in pairs(getgc(true)) do
            if typeof(Object) == "table" and typeof(rawget(Object, "Homeless")) == "table" then
                if rawget(Object.Homeless, "MaxDistance") then Object.Homeless.MaxDistance = 9e9 end
            end
        end
    end)
end)
getgenv().HyphonReady = true
getgenv().Emulator_Set = true

-- ==========================================
-- CAMERA NOCLIP
-- ==========================================
pcall(function()
    LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
end)
if getgenv().FULL_AUTO then return end
getgenv().FULL_AUTO = true

getgenv().BUY_PACKAGES = getgenv().BUY_PACKAGES or 11
getgenv().STOP_ALL = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LogService = game:GetService("LogService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local LocalPlayer = Player

-- ============================================================
-- BELI APARTEMEN DENGAN FALLBACK (FIX - CEK OCCUPATION BENAR)
-- ============================================================

local VirtualInputManager = game:GetService("VirtualInputManager")

local APARTMENTS = {
    { name = "Apartemen 1", pos = Vector3.new(898.506, 12.039, 71.566), cookPos = Vector3.new(898.4859619140625, 8.297018051147461, 36.767578125) },
    { name = "Apartemen 2", pos = Vector3.new(926.929, 12.039, 71.674), cookPos = Vector3.new(924.9859619140625, 8.297018051147461, 36.767578125) },
    { name = "Apartemen 3", pos = Vector3.new(1017.220, 12.039, 217.983), cookPos = Vector3.new(982.3956298828125, 8.297018051147461, 218.69473266601562) },
    { name = "Apartemen 4", pos = Vector3.new(1017.220, 12.039, 246.483), cookPos = Vector3.new(982.3956298828125, 8.297018051147461, 247.19473266601562) }
}

local selectedApartmentData = nil
local apartmentBought = false

local function getBoardOccupation(board)
    if not board or not board:IsA("BasePart") then return nil end
    local gui = board:FindFirstChild("SurfaceGui")
    if not gui then return nil end
    local occ = gui:FindFirstChild("Occupation")
    return occ and occ.Text or nil
end

local function findBoardAtPosition(targetPos)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Board" and obj:IsA("BasePart") then
            local dist = (obj.Position - targetPos).Magnitude
            if dist < 5 then
                return obj
            end
        end
    end
    return nil
end

local function isBoardAvailable(board)
    if not board then return false end
    
    local occ = getBoardOccupation(board)
    if not occ then 
        return true
    end
    
    local lowerOcc = occ:lower()
    
    if lowerOcc:find("for sale") or 
       lowerOcc:find("vacant") or 
       lowerOcc == "" or 
       lowerOcc == "none" or
       lowerOcc:find("available") then
        return true
    end
    
    if occ == LocalPlayer.Name then
        return false
    end
    
    return false
end

local function instantRespawnTP(targetPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(999999, 999999, 999999)

    local newChar = LocalPlayer.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    local hum = newChar:WaitForChild("Humanoid", 10)
    if not newHrp or not hum then return end

    task.wait(0.8)

    local targetCF = CFrame.new(targetPos)
    for _ = 1, 4 do
        newHrp.CFrame = targetCF
        task.wait(0.15)
    end
end

local function buyApartment()
    task.wait(0.5)
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and (prompt.Parent and prompt.Parent:IsA("BasePart")) then
                if (prompt.Parent.Position - hrp.Position).Magnitude < 12 then
                    pcall(function()
                        prompt.RequiresLineOfSight = false
                        fireproximityprompt(prompt)
                    end)
                end
            end
        end
    end

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

    task.wait(0.5)

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                        local txt = (btn:IsA("TextButton") and btn.Text or btn.Name):lower()
                        if txt:find("buy") or txt:find("purchase") or txt:find("ya") or txt:find("yes") or txt:find("sewa") then
                            pcall(function()
                                local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, true, game, 1)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 1)
                            end)
                        end
                    end
                end
            end
        end
    end
end

local autoKicked = false

-- ============================================================
-- KICK KALAU SEMUA BOARD/APART SUDAH DIBELI (pindah server)
-- ============================================================
local function kickApartFull()
    if autoKicked then return end
    autoKicked = true

    pcall(function() statusLbl.Text = "Apartemen penuh - pindah server..." end)
    warn("[AutoFully] semua board/apart sudah dibeli -> kick (apart full)")

    pcall(function() LocalPlayer:Kick("apart full") end)

    -- fallback: kalau kick gagal / servernya nggak auto-rejoin, teleport sendiri
    task.spawn(function()
        task.wait(3)
        pcall(function() TeleportService:Teleport(10179538382) end)
    end)
end

local function findAvailableApartment()
    local boardsFound = 0
    selectedApartmentData = nil

    for _, apt in ipairs(APARTMENTS) do
        local board = findBoardAtPosition(apt.pos)

        if board then
            boardsFound = boardsFound + 1
            if isBoardAvailable(board) then
                selectedApartmentData = apt
                return boardsFound
            end
        end
    end

    return boardsFound
end

local function checkAndBuyApartment()
    if apartmentBought then return true end

    local boardsFound = findAvailableApartment()

    -- board belum kebaca (server baru join) -> tunggu sebentar & cek ulang
    local tries = 0
    while not selectedApartmentData and boardsFound < #APARTMENTS and tries < 6 do
        tries = tries + 1
        task.wait(1)
        if getgenv().STOP_ALL then return false end
        boardsFound = findAvailableApartment()
    end

    if selectedApartmentData then
        instantRespawnTP(selectedApartmentData.pos + Vector3.new(0, 0, 3))
        task.wait(0.5)
        
        buyApartment()
        
        apartmentBought = true
        return true
    else
        -- semua board ketemu tapi nggak ada yang kosong -> apartemen di server ini penuh
        if boardsFound >= #APARTMENTS then
            kickApartFull()
        end
        return false
    end
end

-- ============================================================

local APARTMENT_POS = Vector3.new(1142.970, 9.963, 453.780)
local LAMONT_POS = Vector3.new(510.673, 4.619, 599.356)

local function deleteApartmentJunk()
    local keepNames = {
        ["cooking pot"] = true,
        ["cookpot"] = true,
        ["cook pot"] = true,
    }
    local aptFolders = {
        "CompactWalkupAPT1", "CompactWalkupAPT2", "CompactWalkupAPT3",
        "CompactWalkupAPT4", "CompactWalkupAPT5", "CompactWalkupAPT6",
    }
    for _, folderName in ipairs(aptFolders) do
        local folder = workspace:FindFirstChild(folderName)
        if not folder then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == folderName then
                    folder = obj
                    break
                end
            end
        end
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or Instance.new("Model")) then
                    local n = obj.Name:lower()
                    if not keepNames[n] then
                        if n == "housed.0052" then
                            pcall(function()
                                local origSize = obj.Size
                                obj.Size = Vector3.new(origSize.X, origSize.Y * 0.05, origSize.Z)
                                obj.CFrame = obj.CFrame * CFrame.new(0, -origSize.Y * 0.475, 0)
                            end)
                        else
                            pcall(function()
                                obj.Transparency = 1
                                obj.CanCollide = false
                            end)
                        end
                    end
                end
            end
        end
    end
end


local function PreMaskTeleport(dirP, useHighTp)
    if not LocalPlayer.Character then return false end
    local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return false end
    if useHighTp then
        RootPart.CFrame = CFrame.new(0, 9e9, 0)
        task.wait(2)
        if not LocalPlayer.Character then return false end
        local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then return false end
        RootPart.CFrame = CFrame.new(dirP)
        task.wait(0.5)
        return true
    else
        RootPart.CFrame = CFrame.new(dirP)
        task.wait(0.5)
        return true
    end
end

local UndergroundBaseplates = {}

local function __swnBP()
    local pos = {
        Vector3.new(0, -8.2, 0),
        Vector3.new(1321, -8.2, 660),
        Vector3.new(-919, -8.2, 659),
        Vector3.new(-898, -8.2, -652),
        Vector3.new(1364, -8.2, -639)
    }
    local size = Vector3.new(1e9, 5, 1e9)
    for _, position in ipairs(pos) do
        local partName = "UndergroundBP_" .. tostring(position)
        local baseplate = Workspace:FindFirstChild(partName)
        if not baseplate then
            baseplate = Instance.new("Part")
            baseplate.Name = partName
            baseplate.Size = size
            baseplate.Position = position
            baseplate.Anchored = true
            baseplate.CanCollide = true
            baseplate.Color = Color3.fromRGB(170, 220, 255)
            baseplate.Material = Enum.Material.Glass
            baseplate.Transparency = 0.25
            baseplate.Reflectance = 0.4
            baseplate.Parent = Workspace
        end
        UndergroundBaseplates[baseplate] = true
    end
end

local function GetLiveCharacter(timeout)
    local deadline = os.clock() + (timeout or 0)
    repeat
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        if Character and Character.Parent and Humanoid and Humanoid.Health > 0 and RootPart and RootPart.Parent then
            return Character, Humanoid, RootPart
        end
        if not timeout or timeout <= 0 then break end
        task.wait(0.05)
    until os.clock() >= deadline
    return nil, nil, nil
end

local function moveToPosition(character, targetPosition, customStep, customWait)
    local _, _, humanoidRootPart = GetLiveCharacter(3)
    if not humanoidRootPart then return false end
    local moveStep = customStep or 1.5
    local moveWait = customWait or 0.08
    local distance = (targetPosition - humanoidRootPart.Position).Magnitude
    while distance > moveStep do
        _, _, humanoidRootPart = GetLiveCharacter(3)
        if not humanoidRootPart then return false end
        local currentPosition = humanoidRootPart.Position
        distance = (targetPosition - currentPosition).Magnitude
        if distance <= moveStep then break end
        local direction = (targetPosition - currentPosition).Unit
        humanoidRootPart.CFrame = CFrame.new(currentPosition + direction * moveStep)
        task.wait(moveWait)
    end
    _, _, humanoidRootPart = GetLiveCharacter(3)
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    else
        return false
    end
    return true
end

local function handleMovement(dirP)
    local Character, _, RootPart = GetLiveCharacter(3)
    if not Character or not RootPart then return false end
    local startPos = RootPart.Position
    local undergroundStart = Vector3.new(startPos.X, -2.4, startPos.Z)
    -- Turun pelan pakai tween agar tidak gagal turun / nyangkut
    if startPos.Y > undergroundStart.Y + 0.5 then
        local descendDist = startPos.Y - undergroundStart.Y
        local descendTime = math.clamp(descendDist / 12, 0.6, 2.5)
        local wasAnchored = RootPart.Anchored
        pcall(function()
            RootPart.Anchored = true
            local tw = TweenService:Create(
                RootPart,
                TweenInfo.new(descendTime, Enum.EasingStyle.Linear),
                { CFrame = CFrame.new(undergroundStart) }
            )
            tw:Play()
            tw.Completed:Wait()
        end)
        if not RootPart or not RootPart.Parent then return false end
        RootPart.CFrame = CFrame.new(undergroundStart)
        RootPart.Anchored = wasAnchored
    else
        RootPart.CFrame = CFrame.new(undergroundStart)
    end
    task.wait(0.5)
    local undergroundTarget = Vector3.new(dirP.X, -2.4, dirP.Z)
    local success = moveToPosition(Character, undergroundTarget)
    if success then
        _, _, RootPart = GetLiveCharacter(3)
        if not RootPart then return false end
        RootPart.CFrame = CFrame.new(dirP)
        task.wait(0.5)
    end
    return success
end

local function antiAfkTick()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        VirtualUser:Button2Down(Vector2.new())
        task.wait(0.05)
        VirtualUser:Button2Up(Vector2.new())
        VirtualUser:Button1Down(0)
        task.wait(0.05)
        VirtualUser:Button1Up(0)
    end)
end

local function nudgeCharacter()
    local _, _, hrp = GetLiveCharacter(3)
    if not hrp then return end
    pcall(function()
        local cf = hrp.CFrame
        hrp.CFrame = cf * CFrame.new(0.25, 0, 0)
        task.wait(0.1)
        hrp.CFrame = cf
    end)
end

task.spawn(function()
    while getgenv().FULL_AUTO and not getgenv().STOP_ALL do
        antiAfkTick()
        nudgeCharacter()
        task.wait(math.random(12, 18))
    end
end)

local logConn
logConn = LogService.MessageOut:Connect(function(msg, mtype)
    if mtype == Enum.MessageType.MessageError then
        if msg:find("Kicked") or msg:find("kicked") or msg:find("Disconnected") or msg:find("Idle") or msg:find("apart full") then
            if logConn then logConn:Disconnect() end
            if not getgenv().STOP_ALL then
                task.spawn(function()
                    task.wait(2)
                    pcall(function() TeleportService:Teleport(10179538382) end)
                end)
            end
        end
    end
end)

local function findClearSpot(target, radius)
    radius = radius or 4
    local candidates = {
        Vector3.new(0, 0, 0),
        Vector3.new(3, 0, 0),
        Vector3.new(-3, 0, 0),
        Vector3.new(0, 0, 3),
        Vector3.new(0, 0, -3),
        Vector3.new(6, 0, 0),
        Vector3.new(-6, 0, 0),
        Vector3.new(0, 0, 6),
        Vector3.new(0, 0, -6),
        Vector3.new(8, 0, 0),
        Vector3.new(-8, 0, 0),
        Vector3.new(0, 0, 8),
        Vector3.new(0, 0, -8),
    }
    for _, off in ipairs(candidates) do
        local cand = target + off
        local blocked = false
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player then
                local c = p.Character
                if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid") then
                    if (c.HumanoidRootPart.Position - cand).Magnitude < radius then
                        blocked = true
                        break
                    end
                end
            end
        end
        if not blocked then return cand end
    end
    return target
end

local function TeleportToLamontBuy()
    local targetPos = findClearSpot(LAMONT_POS, 5)
    local success = PreMaskTeleport(targetPos, true)
    return success
end

local function TeleportToLamontSell()
    __swnBP()
    task.wait(0.5)
    local targetPos = findClearSpot(LAMONT_POS, 5)
    local success = handleMovement(targetPos)
    return success
end

local function TeleportToApartDefault()
    __swnBP()
    task.wait(0.5)
    local targetPos = findClearSpot(APARTMENT_POS, 5)
    local success = handleMovement(targetPos)
    return success
end

local function TeleportToApart()
    if selectedApartmentData and selectedApartmentData.cookPos then
        __swnBP()
        task.wait(0.5)
        local targetPos = findClearSpot(selectedApartmentData.cookPos, 5)
        local success = handleMovement(targetPos)
        return success
    else
        return TeleportToApartDefault()
    end
end

local function findNearestRemoteEvent(searchRadius)
    searchRadius = searchRadius or 50
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest = nil
    local nearestDist = math.huge
    local containers = { workspace, game:GetService("ReplicatedStorage") }
    for _, container in pairs(containers) do
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local part = obj:FindFirstChildWhichIsA("BasePart") or obj.Parent:FindFirstChildWhichIsA("BasePart")
                if not part then
                    local parent = obj.Parent
                    while parent do
                        if parent:IsA("BasePart") then
                            part = parent
                            break
                        end
                        parent = parent.Parent
                    end
                end
                if part then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist < nearestDist and dist < searchRadius then
                        nearestDist = dist
                        nearest = { Remote = obj, Part = part, Distance = dist }
                    end
                end
            end
        end
    end
    return nearest
end

local function findStoveWithRemote()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    local nearestStove = nil
    local nearestDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower() == "stove" or obj.Name:lower() == "cooking pot" or obj.Name:lower() == "cookpot" or obj.Name:lower() == "cook pot") then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist < nearestDist and dist < 30 then
                nearestDist = dist
                nearestStove = obj
            end
        end
    end
    if not nearestStove then return nil, nil end
    local remoteData = findNearestRemoteEvent(15)
    if remoteData then return nearestStove, remoteData.Remote end
    local prompt = nearestStove:FindFirstChild("Attachment")
    if prompt then prompt = prompt:FindFirstChildWhichIsA("ProximityPrompt") end
    if not prompt then prompt = nearestStove:FindFirstChildWhichIsA("ProximityPrompt") end
    return nearestStove, prompt
end

local function fireRemoteEvent(remote, ...)
    if not remote then return false end
    local args = {...}
    local success, err = pcall(function()
        if remote.FireServer then
            remote:FireServer(unpack(args))
            return true
        end
    end)
    if success then return true end
    success, err = pcall(function()
        if remote.OnServerEvent then
            remote.OnServerEvent:Connect(function(plr, ...) end)
            return true
        end
    end)
    return success
end

local VIM = cloneref(game:GetService("VirtualInputManager"))

local function ClickButton(btn)
    if not btn then return false end
    local ok = pcall(function()
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        local center = pos + size / 2
        VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
    end)
    if ok then task.wait(0.2) end
    return ok
end

local function ClickDialogOption(o1)
    if not o1 then return end
    local done = false
    local c = getconnections(o1.MouseButton1Click)
    if #c > 0 then
        pcall(function() c[1].Function(o1); done = true end)
        if not done then pcall(function() c[1]:Fire(); done = true end) end
    else
        local c2 = getconnections(o1.Activated)
        if #c2 > 0 then
            pcall(function() c2[1].Function(o1); done = true end)
            if not done then pcall(function() c2[1]:Fire(); done = true end) end
        end
    end
    if not done then ClickButton(o1) end
end

local function CountInv(name)
    local n = 0
    for _, o in pairs(Player:GetDescendants()) do
        if o:IsA("Tool") and o.Name == name then n = n + 1 end
    end
    return n
end

local function ScrollToShow(sf, obj)
    if not sf or not obj then return end
    local relY = obj.AbsolutePosition.Y - sf.AbsolutePosition.Y
    sf.CanvasPosition = Vector2.new(0, math.max(0, sf.CanvasPosition.Y + relY - sf.AbsoluteSize.Y / 2))
    task.wait(0.1)
end

local function ClickGui(target)
    if not target then return false end
    local done = false
    if target:IsA("GuiButton") then
        local c = getconnections(target.MouseButton1Click)
        if #c > 0 then
            pcall(function() c[1].Function(target); done = true end)
            if not done then pcall(function() c[1]:Fire(); done = true end) end
        end
    end
    if not done then ClickButton(target) end
    return true
end

local function findLamont()
    local folders = Workspace:FindFirstChild("Folders")
    if folders then
        local npcs = folders:FindFirstChild("NPCs")
        if npcs then
            return npcs:FindFirstChild("Lamont Bell")
        end
    end
    return nil
end

local function FindShopItem(itemName)
    local pg = Player:WaitForChild("PlayerGui")
    local shop = pg:FindFirstChild("Shop")
    if not shop then return nil, nil end
    local main = shop:FindFirstChild("Main")
    if not main then return nil, nil end
    local sf = main:FindFirstChild("ScrollingFrame")
    if not sf then return nil, nil end
    for _, item in ipairs(sf:GetChildren()) do
        for _, d in pairs(item:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local ok, v = pcall(function() return d.Text end)
                if ok and v and tostring(v):lower():find(itemName:lower(), 1, true) then
                    return item, sf
                end
            end
        end
    end
    return nil, sf
end

local function BuyFromShop(itemName)
    local item, sf = FindShopItem(itemName)
    if not item then return false end
    ScrollToShow(sf, item)
    task.wait(0.1)
    local target = item
    for _, d in pairs(item:GetDescendants()) do
        if (d:IsA("TextButton") or d:IsA("ImageButton")) then
            local t = ""
            pcall(function() t = d.Text end)
            local lt = tostring(t):lower()
            if lt:find("buy") or lt:find("purchase") or lt:find("beli") then
                target = d
                break
            end
        end
    end
    ClickGui(target)
    task.wait(0.2)
    local pg = Player:WaitForChild("PlayerGui")
    local shop = pg:FindFirstChild("Shop")
    if shop then
        for _, d in pairs(shop:GetDescendants()) do
            if d:IsA("GuiButton") and d.Visible then
                local t = ""
                pcall(function() t = d.Text end)
                local lt = tostring(t):lower()
                if lt:find("buy") or lt:find("confirm") or lt:find("yes") then
                    ClickGui(d)
                    task.wait(0.2)
                    break
                end
            end
        end
    end
    local t0 = os.clock()
    repeat task.wait(0.1) until CountInv(itemName) >= 1 or (os.clock() - t0) > 2.5
    return CountInv(itemName) >= 1
end

local function ClickShopExit()
    local pg = Player:WaitForChild("PlayerGui")
    local shop = pg:FindFirstChild("Shop")
    if not shop then return false end
    local main = shop:FindFirstChild("Main") or shop
    local found = false
    for _, d in pairs(main:GetDescendants()) do
        if d:IsA("GuiButton") then
            local t = ""
            pcall(function() t = d.Text end)
            local lt = tostring(t):lower()
            if lt:find("exit") or lt:find("close") or d.Name:lower():find("exit") or d.Name:lower():find("close") then
                ClickGui(d)
                found = true
                break
            end
        end
    end
    if not found then
        for _, d in pairs(main:GetDescendants()) do
            if d:IsA("TextLabel") and tostring(d.Text):lower():find("exit") then
                local parent = d.Parent
                ClickGui(parent)
                found = true
                break
            end
        end
    end
    return found
end

local function openLamontShop()
    local pg = Player:WaitForChild("PlayerGui")
    if pg:FindFirstChild("Shop") and pg.Shop:FindFirstChild("Main") and pg.Shop.Main.Visible then
        return true
    end
    local lamont = findLamont()
    if not lamont then return false end
    local lamontPrompt = lamont:FindFirstChild("UpperTorso") and lamont.UpperTorso:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not lamontPrompt then lamontPrompt = lamont:FindFirstChildWhichIsA("ProximityPrompt", true) end
    if not lamontPrompt then return false end
    lamontPrompt.MaxActivationDistance = 9e9
    lamontPrompt.HoldDuration = 0
    lamontPrompt.RequiresLineOfSight = false
    fireproximityprompt(lamontPrompt)
    for _ = 1, 100 do
        if pg:FindFirstChild("Shop") and pg.Shop:FindFirstChild("Main") and pg.Shop.Main.Visible then
            return true
        end
        local dui = pg:FindFirstChild("DialogueUI")
        if dui and dui.Enabled and dui.MainFrame and dui.MainFrame.ResponseFrame then
            local list = dui.MainFrame.ResponseFrame:FindFirstChild("List")
            if list then
                for _, b in ipairs(list:GetChildren()) do
                    if b:IsA("GuiButton") then
                        local t = b:FindFirstChild("Dialogue", true)
                        if b.Visible and t and tostring(t.Text):lower():find("buy") then
                            ClickDialogOption(b)
                            break
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
    return false
end

local statusLbl = nil

local BuyRemote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ReliableRemoteEvent")
local BUY_ITEM_CODES = {
    ["Gelatin"] = "\024\019\001",
    ["Sugar Block Bag"] = "\024\019\002",
    ["Water"] = "\024\019\003",
}

local function fireBuyItem(code)
    return pcall(function()
        BuyRemote:FireServer(buffer.fromstring(code))
    end)
end

local function buyIngredients(packages)
    packages = packages or 11
    if packages < 1 then packages = 1 end
    if packages > 200 then packages = 200 end
    if getgenv().STOP_ALL then return false end
    for _, itemName in ipairs({ "Water", "Gelatin", "Sugar Block Bag" }) do
        if getgenv().STOP_ALL then break end
        statusLbl.Text = "Membeli " .. itemName .. " (remote)..."
        local code = BUY_ITEM_CODES[itemName]
        local got = CountInv(itemName)
        while got < packages do
            local before = got
            fireBuyItem(code)
            local t0 = os.clock()
            repeat
                task.wait(0.15)
                got = CountInv(itemName)
            until got > before or (os.clock() - t0) > 3
            if got <= before then break end
        end
        statusLbl.Text = itemName .. ": " .. got .. "/" .. packages
        task.wait(0.1)
    end
    return true
end

local function equipTool(item)
    if item then
        local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h:EquipTool(item)
            return true
        end
    end
    return false
end

local function unequipTools()
    local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if h then
        h:UnequipTools()
        return true
    end
    return false
end

local function firePrompt(p)
    if p then
        p.HoldDuration = 0
        p.RequiresLineOfSight = false
        p.MaxActivationDistance = 9e9
        fireproximityprompt(p)
        return true
    end
    return false
end

local function checkInv(name)
    local bp = Player:FindFirstChild("Backpack")
    if not bp then return 0 end
    local count = 0
    for _, obj in pairs(bp:GetChildren()) do
        if obj.Name == name then count = count + 1 end
    end
    return count
end

-- ===== Dance saat loop (Brazil dance) =====
local danceTrack
local DANCE_ANIM_ID = 6869766175 -- Samba (katalog Roblox, gratis)

local function startDance()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        unequipTools()
        if danceTrack then
            danceTrack:Stop(0.2)
            danceTrack = nil
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(DANCE_ANIM_ID)
        danceTrack = animator:LoadAnimation(anim)
        danceTrack.Looped = true
        danceTrack.Priority = Enum.AnimationPriority.Idle
        danceTrack:Play(0.3)
    end)
end

local function stopDance()
    pcall(function()
        if danceTrack then
            danceTrack:Stop(0.2)
            danceTrack = nil
        end
    end)
end

local function startTimer(seconds)
    startDance()
    for i = seconds, 0, -1 do
        if getgenv().STOP_ALL then break end
        task.wait(1)
    end
    stopDance()
end

local totalCooked = 0

local function findNearestPrompt()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local targetNames = {["cooking pot"] = true, ["cookpot"] = true, ["cook pot"] = true, ["stove"] = true}
    local nearest, nearDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj:FindFirstAncestorWhichIsA("BasePart")
            if part and targetNames[part.Name:lower()] then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < nearDist and dist < 30 then
                    nearDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local function cookOneBatchRemote()
    if checkInv("Water") == 0 then return false end
    statusLbl.Text = "Memasak: Menambah air..."
    local w = Player.Backpack:FindFirstChild("Water") or Player.Character:FindFirstChild("Water")
    if w then 
        equipTool(w)
        task.wait(0.3)
        local p = findNearestPrompt()
        if p then firePrompt(p) end
        task.wait(0.5)
        unequipTools()
    end
    if getgenv().STOP_ALL then return false end
    statusLbl.Text = "Memasak: Menunggu air (20s)..."
    startTimer(20)
    if getgenv().STOP_ALL then return false end
    if checkInv("Sugar Block Bag") == 0 then return false end
    statusLbl.Text = "Memasak: Menambah gula..."
    local s = Player.Backpack:FindFirstChild("Sugar Block Bag") or Player.Character:FindFirstChild("Sugar Block Bag")
    if s then 
        equipTool(s)
        task.wait(0.3)
        local p = findNearestPrompt()
        if p then firePrompt(p) end
        task.wait(0.5)
        unequipTools()
    end
    if getgenv().STOP_ALL then return false end
    task.wait(0.2)
    if getgenv().STOP_ALL then return false end
    if checkInv("Gelatin") == 0 then return false end
    statusLbl.Text = "Memasak: Menambah gelatin..."
    local g = Player.Backpack:FindFirstChild("Gelatin") or Player.Character:FindFirstChild("Gelatin")
    if g then 
        equipTool(g)
        task.wait(0.3)
        local p = findNearestPrompt()
        if p then firePrompt(p) end
        task.wait(0.5)
        unequipTools()
    end
    if getgenv().STOP_ALL then return false end
    statusLbl.Text = "Memasak: Menunggu adonan (45s)..."
    startTimer(45)
    if getgenv().STOP_ALL then return false end
    statusLbl.Text = "Memasak: Mengambil marshmallow..."
    local bag = nil
    for _ = 1, 15 do
        if getgenv().STOP_ALL then return false end
        bag = Player.Backpack:FindFirstChild("Empty Bag") or Player.Character:FindFirstChild("Empty Bag")
        if bag then break end
        task.wait(0.5)
    end
    if not bag then return false end
    equipTool(bag)
    task.wait(0.3)
    local p = findNearestPrompt()
    if p then firePrompt(p) end
    task.wait(0.5)
    unequipTools()
    return true
end

local function stepAutoCookRemote()
    totalCooked = 0
    while not getgenv().STOP_ALL do
        if checkInv("Water") == 0 then break end
        if checkInv("Sugar Block Bag") == 0 then break end
        if checkInv("Gelatin") == 0 then break end
        statusLbl.Text = "Memasak batch #" .. (totalCooked + 1) .. "..."
        local success = cookOneBatchRemote()
        if not success then break end
        totalCooked = totalCooked + 1
        if getgenv().STOP_ALL then break end
        task.wait(0.5)
    end
end

local function countMarshmallows()
    local count = 0
    for _, obj in pairs(Player.Backpack:GetChildren()) do
        if tostring(obj.Name):find("Marshmallow") then count = count + 1 end
    end
    local char = Player.Character
    if char then
        for _, obj in pairs(char:GetChildren()) do
            if tostring(obj.Name):find("Marshmallow") then count = count + 1 end
        end
    end
    return count
end

local function stepSell()
    local lamont
    for _ = 1, 20 do
        lamont = findLamont()
        if lamont then break end
        task.wait(0.3)
    end
    if not lamont then return false end
    local upper = lamont:FindFirstChild("UpperTorso")
    if not upper then return false end
    local prompt = upper:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then return false end

    -- snapshot dulu agar iterator tidak kacau saat equip/unequip
    local marshItems = {}
    for _, obj in pairs(Player.Backpack:GetChildren()) do
        if tostring(obj.Name):find("Marshmallow") then
            table.insert(marshItems, obj)
        end
    end

    local sold = 0
    for _, obj in ipairs(marshItems) do
        if getgenv().STOP_ALL then break end
        -- pastikan obj masih valid (belum terjual/dihapus server)
        if obj and obj.Parent then
            sold = sold + 1
            statusLbl.Text = "Menjual #" .. sold .. "/" .. #marshItems .. "..."
            equipTool(obj)
            task.wait(0.4)
            firePrompt(prompt)
            task.wait(0.6)
            unequipTools()
            task.wait(0.4)
        end
    end
    task.wait(0.5)
    local remaining = countMarshmallows()
    if remaining > 0 then
        statusLbl.Text = "Sisa " .. remaining .. ", jual ulang..."
        return stepSell() -- re-sell sisa yang tertinggal
    end
    return sold > 0
end

local function fullAutoCycle()
    if getgenv().STOP_ALL then return end
    
    if not apartmentBought then
        statusLbl.Text = "Membeli apartemen..."
        checkAndBuyApartment()
        task.wait(0.5)
    end
    
    statusLbl.Text = "Teleport ke Lamont (beli bahan)..."
    if not TeleportToLamontBuy() then return false end
    task.wait(0.3)
    statusLbl.Text = "Membeli bahan..."
    if not buyIngredients(getgenv().BUY_PACKAGES or 11) then return false end
    task.wait(0.3)
    statusLbl.Text = "Teleport ke apartemen..."
    if not TeleportToApart() then return false end
    task.wait(0.3)
    statusLbl.Text = "Membersihkan apartemen..."
    deleteApartmentJunk()
    task.wait(0.5)
    statusLbl.Text = "Memasak marshmallow..."
    stepAutoCookRemote()
    if getgenv().STOP_ALL then return false end
    local marshCount = countMarshmallows()
    if marshCount == 0 then return false end
    statusLbl.Text = "Teleport ke Lamont (jual)..."
    if not TeleportToLamontSell() then return false end
    task.wait(0.3)
    statusLbl.Text = "Menjual marshmallow..."
    stepSell()
    task.wait(0.2)
    statusLbl.Text = "Selesai! Mengulang..."
    return true
end

local function fullAutoLoop()
    local cycleCount = 0
    while not getgenv().STOP_ALL do
        cycleCount = cycleCount + 1
        statusLbl.Text = "Cycle #" .. cycleCount .. " dimulai..."
        local success = fullAutoCycle()
        if not success then
            statusLbl.Text = "Gagal, retry dalam 2 detik..."
            startTimer(2)
        end
        if getgenv().STOP_ALL then break end
        startTimer(0.5)
    end
    stopDance()
    statusLbl.Text = "Dihentikan."
end

if CoreGui:FindFirstChild("FullAuto") then
    CoreGui:FindFirstChild("FullAuto"):Destroy()
end

-- ==========================================
-- UI LDS13
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/sametlibs/refs/heads/main/lds13/Library.lua"))()

local Window = Library:Window({
    Name = "Auto Fully Script",
    SubTitle = 'ZEROPRODUCTION',
    TimeRemaining = "∞"
})
-- Timer hitung maju live untuk "Time remaining" (mulai dari 0)
task.spawn(function()
    local elapsed = 0
    local lblItem = Window.Items and Window.Items["TimeRemaining"]
    if not lblItem then return end
    local lbl = lblItem.Instance
    while lbl and lbl.Parent do
        local m = math.floor(elapsed / 60)
        local s = elapsed % 60
        lbl.Text = "Time running: " .. string.format("%02d:%02d", m, s)
        elapsed = elapsed + 1
        task.wait(1)
    end
end)
local Pages = {}

Pages[1] = Window:Page({
    Icon = "99737276303036",
    Columns = 2
})

local SettingsPage = Library:CreateSettingsPage(Window)

local FarmSection = Pages[1]:Section({
    Name = "Auto Farm",
    Icon = "11830984173",
    Side = 1
})

local ExtraSection = Pages[1]:Section({
    Name = "Ekstra",
    Icon = "11830984173",
    Side = 2
})

local StatusSection = Pages[1]:Section({
    Name = "Status",
    Icon = "11830984173",
    Side = 2
})

-- ==========================================
-- STATUS PROXY -> lds13 Label
-- (logika farm menulis statusLbl.Text)
-- ==========================================
local StatusLabel = StatusSection:Label("Menunggu...")
local statusProxy = {}
setmetatable(statusProxy, {
    __newindex = function(t, k, v)
        if k == "Text" and StatusLabel and StatusLabel.Instance then
            pcall(function() StatusLabel.Instance.Text = tostring(v) end)
        else
            rawset(t, k, v)
        end
    end,
    __index = function(t, k)
        if k == "Text" and StatusLabel and StatusLabel.Instance then
            return StatusLabel.Instance.Text
        end
        return rawget(t, k)
    end
})
statusLbl = statusProxy
getgenv()._AF_StatusLbl = statusProxy

-- ==========================================
-- FARM CONTROL
-- ==========================================
local farmRunning = false

local function stopFarm()
    getgenv().STOP_ALL = true
    if logConn then pcall(function() logConn:Disconnect() end); logConn = nil end
    getgenv().FULL_AUTO = false
end

FarmSection:Toggle({
    Name = "Auto Farm Full",
    Flag = "AutoFarm",
    Default = true,   -- VERSI INI: langsung ON / auto start
    Callback = function(Value)
        if Value then
            if getgenv().STOP_ALL then getgenv().STOP_ALL = false end
            getgenv().FULL_AUTO = true
            farmRunning = true
            task.spawn(function()
                fullAutoLoop()
                farmRunning = false
            end)
        else
            stopFarm()
        end
    end
})

FarmSection:Slider({
    Name = "Jumlah Paket",
    Flag = "BuyPackages",
    Default = math.clamp(tonumber(getgenv().BUY_PACKAGES) or 11, 1, 50),
    Min = 1,
    Max = 50,
    Suffix = "x",
    Callback = function(Value)
        getgenv().BUY_PACKAGES = math.floor(Value)
    end
})

-- ==========================================
-- FPS BOOST BACKEND
-- ==========================================
do
    local FPSLighting = game:GetService("Lighting")
    local FPSWorkspace = game:GetService("Workspace")
    local MaterialService = game:GetService("MaterialService")
    local deleteNames = {
        "Trash", "trash", "Garbage", "garbage", "Rubbish", "rubbish",
        "Can", "can", "Bottle", "bottle", "Plastic", "plastic",
        "Bag", "bag", "Cup", "cup",
        "Grass", "grass", "Bush", "bush", "Leaf", "leaf",
        "Flower", "flower", "Plant", "plant", "Weed", "weed",
        "Foliage", "foliage", "Vine", "vine",
        "Prop", "prop", "Deco", "deco", "Decor", "decor",
        "Barrel", "barrel", "Crate", "crate", "Box", "box",
        "Chair", "chair", "Table", "table", "Bench", "bench",
        "Lamp", "lamp", "Sign", "sign", "Poster", "poster",
        "Fence", "fence", "Pole", "pole", "Post", "post",
        "Stone", "stone", "Pebble", "pebble", "Rock", "rock",
    }
    local protectNames = {
        "Wall", "wall", "Floor", "floor", "Ceiling", "ceiling",
        "Roof", "roof", "Door", "door", "Window", "window",
        "Stair", "stair", "Step", "step", "Ramp", "ramp",
        "Bridge", "bridge", "Road", "road", "Sidewalk", "sidewalk",
        "Building", "building", "House", "house", "Apartment", "apartment",
        "Baseplate", "baseplate", "Ground", "ground", "Terrain", "terrain",
        "Collision", "collision", "Barrier", "barrier",
        "Pillar", "pillar", "Column", "column", "Beam", "beam",
        "Rail", "rail", "Railing", "railing", "Guard", "guard",
        "Spawn", "spawn", "Platform", "platform",
        "Vehicle", "vehicle", "Car", "car", "Bike", "bike",
    }
    local function isPartOfCharacter(part)
        if not part then return false end
        local char = LocalPlayer.Character
        if char and part:IsDescendantOf(char) then return true end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local c = player.Character
                if c and part:IsDescendantOf(c) then return true end
            end
        end
        return false
    end
    local function shouldDelete(part)
        if not part or not part:IsA("BasePart") then return false end
        local name = part.Name:lower()
        local parentName = part.Parent and part.Parent.Name:lower() or ""
        for _, protect in ipairs(protectNames) do
            if name:find(protect:lower()) or parentName:find(protect:lower()) then return false end
        end
        if part.Size.X > 5 or part.Size.Z > 5 then return false end
        if parentName:find("building") or parentName:find("house") or parentName:find("map") then
            if part.Size.X < 3 and part.Size.Z < 3 then else return false end
        end
        for _, deleteName in ipairs(deleteNames) do
            if name:find(deleteName:lower()) then return true end
        end
        if part.Parent and part.Parent:IsA("Model") then
            if parentName:find("decor") or parentName:find("prop") or
               parentName:find("foliage") or parentName:find("trash") or
               parentName:find("rubbish") or parentName:find("garbage") then return true end
        end
        return false
    end
    local fpsBoostEnabled = false
    local fpsBoostRunning = false
    local function applyFPSBoost()
        if fpsBoostRunning then return end
        fpsBoostRunning = true
        fpsBoostEnabled = true
        pcall(function()
            FPSLighting.Sky = false
            FPSLighting.Clouds = false
            for _, v in pairs(FPSLighting:GetChildren()) do
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end
            end
            FPSLighting.Ambient = Color3.fromRGB(0, 0, 0)
            FPSLighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            FPSLighting.Brightness = 0
            FPSLighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            FPSLighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        end)
        task.wait(0.05)
        pcall(function()
            FPSLighting.GlobalShadows = false
            FPSLighting.FogEnd = 9e9
            FPSLighting.ShadowSoftness = 0
        end)
        task.wait(0.05)
        pcall(function()
            local terrain = FPSWorkspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end
        end)
        task.wait(0.05)
        pcall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
        task.wait(0.05)
        pcall(function()
            if setfpscap then setfpscap(1e6) end
        end)
        task.wait(0.05)
        pcall(function()
            for i, v in pairs(MaterialService:GetChildren()) do v:Destroy() end
            MaterialService.Use2019Materials = false
        end)
        task.wait(0.05)
        local parts = FPSWorkspace:GetDescendants()
        local total = #parts
        for i = 1, total, 500 do
            if not fpsBoostEnabled then break end
            local endIdx = math.min(i + 499, total)
            for j = i, endIdx do
                local v = parts[j]
                if not isPartOfCharacter(v) then
                    if shouldDelete(v) then
                        pcall(function() v:Destroy() end)
                    end
                    if v and v.Parent then
                        pcall(function()
                            if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
                            if v:IsA("MeshPart") then
                                v.TextureID = ""
                                v.RenderFidelity = 2
                                v.Reflectance = 0
                                v.Material = Enum.Material.Plastic
                            end
                            if v:IsA("SpecialMesh") then v.TextureId = ""; v.MeshId = "" end
                            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                                v.Material = Enum.Material.Plastic
                                v.Reflectance = 0
                            end
                            if v:IsA("Model") then v.LevelOfDetail = 1 end
                            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                                v.Enabled = false
                            end
                            if v:IsA("Explosion") then v.BlastPressure = 1; v.BlastRadius = 1 end
                            if v:IsA("TextLabel") and v:IsDescendantOf(FPSWorkspace) then v.Visible = false end
                            if v:IsA("ShirtGraphic") then v.Graphic = "" end
                            if v:IsA("FaceInstance") then v.Transparency = 1; v.Shiny = 1 end
                        end)
                    end
                end
            end
            task.wait(0.05)
        end
        fpsBoostRunning = false
    end
    local function resetFPSBoost()
        fpsBoostEnabled = false
        fpsBoostRunning = false
        pcall(function()
            FPSLighting.GlobalShadows = true
            FPSLighting.FogEnd = 100000
            FPSLighting.ShadowSoftness = 1
            FPSLighting.Ambient = Color3.fromRGB(0, 0, 0)
            FPSLighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
            FPSLighting.Brightness = 2
            FPSLighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            FPSLighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            if setfpscap then setfpscap(60) end
            settings().Rendering.QualityLevel = 3
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        end)
    end
    ExtraSection:Toggle({
        Name = "FPS Boost",
        Flag = "FPSBoost",
        Default = false,
        Callback = function(state)
            if fpsBoostRunning then return end
            if state then
                task.spawn(applyFPSBoost)
            else
                resetFPSBoost()
            end
        end
    })
end

-- ==========================================
-- HIDE NAME BACKEND
-- ==========================================
do
    local hideNameOn = false
    local HIDE_TAG_TEXT = "👑 DYYYKZZ.SCRIPT"
    local HIDE_TAG_COLOR = Color3.fromRGB(0, 255, 255)
    local savedNameColor = nil
    local function applyHideName(state)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("RankTag") then
            local rankTag = char.Head.RankTag
            if rankTag and rankTag.MainFrame and rankTag.MainFrame.NameLabel then
                local lbl = rankTag.MainFrame.NameLabel
                if state then
                    if savedNameColor == nil then savedNameColor = lbl.TextColor3 end
                    lbl.Text = HIDE_TAG_TEXT
                    lbl.TextColor3 = HIDE_TAG_COLOR
                    if lbl:IsA("TextLabel") and lbl.RichText then lbl.RichText = false end
                else
                    lbl.Text = LocalPlayer.Name
                    if savedNameColor then lbl.TextColor3 = savedNameColor end
                end
            end
        end
    end
    ExtraSection:Toggle({
        Name = "Hide Name",
        Flag = "HideName",
        Default = false,
        Callback = function(state)
            hideNameOn = state
            applyHideName(state)
        end
    })
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if hideNameOn then
            applyHideName(true)
        end
    end)
end

statusLbl.Text = "Siap. UI lds13 aktif."
