--====================================================
-- WH01 UI — Mobile + PC Friendly
--====================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local PlayerGui   = localPlayer:WaitForChild("PlayerGui")

--====================================================
-- MOBILE DETECTION
--====================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Tamaños adaptados
local UI_W      = isMobile and 340 or 500
local UI_H      = isMobile and 280 or 390
local SIDEBAR_W = isMobile and 90  or 118
local FONT_MAIN = isMobile and 10  or 12
local FONT_SUB  = isMobile and 9   or 10
local ROW_H     = isMobile and 32  or 38
local SLIDER_H  = isMobile and 46  or 54
local TAB_H     = isMobile and 38  or 44
local TAB_GAP   = isMobile and 44  or 54

--====================================================
-- GAME LOCK (obfuscated)
--====================================================
local _a = {"96","03","03","38","81"}
local _b = tonumber(_a[1].._a[2].._a[3].._a[4].._a[5])
if game.PlaceId ~= _b then
    local _err = Instance.new("ScreenGui")
    _err.Name = "e"; _err.IgnoreGuiInset = true
    _err.Parent = PlayerGui
    local _f = Instance.new("TextLabel", _err)
    _f.Size = UDim2.fromScale(1,1)
    _f.BackgroundColor3 = Color3.fromRGB(8,8,8)
    _f.Text = "❌  Wrong game."
    _f.Font = Enum.Font.GothamBold
    _f.TextSize = 24
    _f.TextColor3 = Color3.fromRGB(220,60,60)
    task.delay(3, function() _err:Destroy() end)
    return
end

--====================================================
-- SECURITY MEASURES
--====================================================

local function randomStr(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local s = ""
    for i = 1, len do
        local r = math.random(1, #chars)
        s = s .. chars:sub(r, r)
    end
    return s
end
local UI_NAME = randomStr(12)

local function rWait(base)
    local jitterPct = math.random(5, 15) / 100
    local sign = math.random(0, 1) == 0 and -1 or 1
    local extraMs = math.random(10, 60) / 1000
    task.wait(base + (base * jitterPct * sign) + extraMs)
end

local function safeFireServer(event)
    pcall(function() event:FireServer() end)
end

--====================================================
-- CONFIG
--====================================================
local defaultConfig = { theme="Default", fontStyle="Modern", bgImageId="108458500083995" }
local CONFIG_FILE = "MultiToolConfig_v6.json"
local CONFIG_ATTR = "WH01Config_v6"

local function saveConfig(cfg)
    local encoded = HttpService:JSONEncode(cfg)
    local ok = pcall(function()
        if writefile then writefile(CONFIG_FILE, encoded) end
    end)
    pcall(function()
        PlayerGui:SetAttribute(CONFIG_ATTR, encoded)
    end)
end

local function loadConfig()
    local data = nil

    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        end
    end)

    if not data then
        pcall(function()
            local attr = PlayerGui:GetAttribute(CONFIG_ATTR)
            if attr then data = HttpService:JSONDecode(attr) end
        end)
    end

    if type(data) == "table" then
        for k,v in pairs(defaultConfig) do
            if data[k] == nil then data[k] = v end
        end
        return data
    end
    return table.clone(defaultConfig)
end

local config = loadConfig()

--====================================================
-- THEMES
--====================================================
local themes = {
    Default = {
        primary=Color3.fromRGB(8,8,8), secondary=Color3.fromRGB(15,15,15),
        accent=Color3.fromRGB(255,255,255), text=Color3.fromRGB(255,255,255),
        subtext=Color3.fromRGB(150,150,150), sidebar=Color3.fromRGB(12,12,12),
        row=Color3.fromRGB(18,18,18), stroke=Color3.fromRGB(255,255,255),
        snow=false, valentine=false, logoId="121057068601747",
        mainTabIcon="97378928892774",
        teleportTabIcon="124656414586890",
        settingsTabIcon="84417015405492",
        micsTabIcon="129896879015985",
        bgId="108458500083995",
    },
    Valentine = {
        primary=Color3.fromRGB(18,5,10), secondary=Color3.fromRGB(35,10,18),
        accent=Color3.fromRGB(220,60,100), text=Color3.fromRGB(255,200,215),
        subtext=Color3.fromRGB(180,100,130), sidebar=Color3.fromRGB(25,5,12),
        row=Color3.fromRGB(30,8,18), stroke=Color3.fromRGB(220,60,100),
        snow=false, valentine=true, logoId="128713599886538",
        mainTabIcon="118293451431629",
        teleportTabIcon="93867203416430",
        settingsTabIcon="92027932993173",
        micsTabIcon="81212960677084",
        bgId="86406538802929",
    },
    Snow = {
        primary=Color3.fromRGB(8,10,18), secondary=Color3.fromRGB(14,18,30),
        accent=Color3.fromRGB(200,220,255), text=Color3.fromRGB(220,235,255),
        subtext=Color3.fromRGB(140,160,200), sidebar=Color3.fromRGB(10,13,22),
        row=Color3.fromRGB(16,20,35), stroke=Color3.fromRGB(180,210,255),
        snow=true, valentine=false, logoId="105877636667273",
        mainTabIcon="86228203034983",
        teleportTabIcon="99769954902270",
        settingsTabIcon="98653576343548",
        micsTabIcon="96765613903347",
        bgId="103508032104468",
    },
}
local fonts = {
    Modern=Enum.Font.GothamBold, Arcade=Enum.Font.Arcade,
    Rounded=Enum.Font.Gotham, Bold=Enum.Font.GothamBlack,
}

--====================================================
-- CLEANUP & GUI
--====================================================
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v:GetAttribute("__mt") == true then v:Destroy() end
end
local gui = Instance.new("ScreenGui")
gui.Name=UI_NAME; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false
gui:SetAttribute("__mt", true)
gui.Parent=PlayerGui

local T_FAST   = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local T_SMOOTH = TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local function tw(o,i,p) TweenService:Create(o,i,p):Play() end

--====================================================
-- OBJECT REGISTRIES
--====================================================
local rows        = {}
local textMain    = {}
local textSub     = {}
local fontObjs    = {}
local checkBoxes  = {}
local dropRows    = {}
local dropLists   = {}
local strokeObjs  = {}
local sliderObjs  = {}
local tabBtns     = {}
local tabData     = {}
local gameName    = nil
local root, rootStroke, bgImage
local header, headerBottom, headerDivider
local sidebar, sidebarTopCover, sideDiv
local titleLabel, subtitleLabel, statusLabel, logo
local minimize, minimizeStroke, close, closeStroke
local contentArea, body
local bgSection, bgSectionStroke, bgPrefixLbl, bgInput, applyBgBtn

--====================================================
-- SLIDER GLOBAL — separado para Mouse y Touch
--====================================================
local activeSlider = nil

-- Función que actualiza el slider dado un X de pantalla
local function updateSliderFromX(screenX)
    if not activeSlider then return end
    local trackAbsPos  = activeSlider.track.AbsolutePosition
    local trackAbsSize = activeSlider.track.AbsoluteSize
    local r = math.clamp((screenX - trackAbsPos.X) / trackAbsSize.X, 0, 1)
    local newVal = activeSlider.minVal + r * (activeSlider.maxVal - activeSlider.minVal)
    activeSlider.update(newVal, false)
    statusLabel.Text = "● " .. activeSlider.label .. ": " .. tostring(math.floor(newVal))
end

-- Mouse
UserInputService.InputChanged:Connect(function(inp)
    if activeSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
        updateSliderFromX(inp.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        activeSlider = nil
    end
end)

-- Touch (global, para que funcione aunque el dedo salga del slider)
UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
    if activeSlider then
        updateSliderFromX(touch.Position.X)
    end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
    if activeSlider then
        activeSlider = nil
    end
end)

--====================================================
-- DRAG — Mouse Y Touch, con prioridad a sliders
--====================================================
local function setupDrag()
    local dragging   = false
    local dragStart  = nil
    local startPos   = nil

    -- Detecta si un punto de pantalla está sobre algún slider
    local function isOverSlider(screenPos)
        for _, s in ipairs(sliderObjs) do
            if s.track and s.track.Parent then
                local ap = s.track.AbsolutePosition
                local as = s.track.AbsoluteSize
                -- zona generosa alrededor del track
                if screenPos.X >= ap.X - 10 and screenPos.X <= ap.X + as.X + 10 and
                   screenPos.Y >= ap.Y - 24  and screenPos.Y <= ap.Y + as.Y + 24 then
                    return true
                end
            end
        end
        return false
    end

    -- MOUSE drag
    root.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if activeSlider then return end
            if isOverSlider(inp.Position) then return end
            dragging  = true
            dragStart = inp.Position
            startPos  = root.Position
            local c; c = inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    -- TOUCH drag
    local touchDragId = nil

    root.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            -- Si hay un slider activo, no iniciar drag
            if activeSlider then return end
            if isOverSlider(inp.Position) then return end

            touchDragId = inp
            dragging    = true
            dragStart   = inp.Position
            startPos    = root.Position
        end
    end)

    root.InputChanged:Connect(function(inp)
        if dragging and inp == touchDragId and inp.UserInputType == Enum.UserInputType.Touch then
            if activeSlider then
                -- si mientras draggeas activaste un slider, cancela el drag
                dragging    = false
                touchDragId = nil
                return
            end
            local d = inp.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    root.InputEnded:Connect(function(inp)
        if inp == touchDragId then
            dragging    = false
            touchDragId = nil
        end
    end)
end

--====================================================
-- PARTICLES
--====================================================
local pFlakes, pConn, pContainer = {}, nil, nil

local function clearParticles()
    if pConn then pConn:Disconnect(); pConn = nil end
    for _,f in ipairs(pFlakes) do
        if f and f.Parent then
            TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=1}):Play()
            task.delay(0.3, function() if f and f.Parent then f:Destroy() end end)
        end
    end
    pFlakes = {}
    local containerToDestroy = pContainer
    if containerToDestroy and containerToDestroy.Parent then
        task.delay(0.3, function()
            if containerToDestroy and containerToDestroy.Parent then containerToDestroy:Destroy() end
        end)
    end
    pContainer = nil
end

local function makeParticleContainer()
    local c = Instance.new("Frame")
    c.Parent = root
    c.Size = UDim2.new(1, -6, 1, -6)
    c.Position = UDim2.new(0, 3, 0, 3)
    c.BackgroundTransparency = 1
    c.ZIndex = 2
    c.ClipsDescendants = true
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 24); cc.Parent = c
    return c
end

local function startSnow()
    pContainer = makeParticleContainer()
    local MAX=20; local active=0; local timer=0
    local function spawn()
        if active>=MAX then return end; active=active+1
        local f=Instance.new("TextLabel"); f.Parent=pContainer
        f.BackgroundTransparency=1; f.Text="❄"; f.Font=Enum.Font.Gotham
        f.TextSize=math.random(8,15); f.TextColor3=Color3.fromRGB(200,220,255)
        f.TextTransparency=math.random(15,45)/100; f.ZIndex=3
        local x=math.random(2,95)/100; f.Size=UDim2.new(0,30,0,30)
        f.Position = UDim2.new(x, 0, -0.02, 0)
        local dur=math.random(7,12); local drift=math.random(-5,5)/100
        tw(f, TweenInfo.new(dur, Enum.EasingStyle.Sine), {Position = UDim2.new(x+drift, 0, 1.02, 0), TextTransparency=0.8})
        table.insert(pFlakes,f)
        task.delay(dur,function() active=active-1; if f and f.Parent then f:Destroy() end end)
    end
    pConn=RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=0.9 then timer=0;spawn() end end)
    for i=1,6 do task.delay(i*0.6,spawn) end
end

local function startValentine()
    pContainer = makeParticleContainer()
    local syms={"🌹","❤️","💕","💗","💖","🌸"}
    local MAX=15; local active=0; local timer=0
    local function spawn()
        if active>=MAX then return end; active=active+1
        local f=Instance.new("TextLabel"); f.Parent=pContainer
        f.BackgroundTransparency=1; f.Text=syms[math.random(1,#syms)]; f.Font=Enum.Font.Gotham
        f.TextSize=math.random(11,18); f.TextTransparency=math.random(10,35)/100; f.ZIndex=3
        local x=math.random(2,95)/100; f.Size=UDim2.new(0,30,0,30)
        f.Position = UDim2.new(x, 0, -0.02, 0)
        local dur=math.random(7,12); local drift=math.random(-5,5)/100
        tw(f, TweenInfo.new(dur, Enum.EasingStyle.Sine), {Position = UDim2.new(x+drift, 0, 1.02, 0), TextTransparency=0.8})
        table.insert(pFlakes,f)
        task.delay(dur,function() active=active-1; if f and f.Parent then f:Destroy() end end)
    end
    pConn=RunService.Heartbeat:Connect(function(dt) timer=timer+dt; if timer>=1.6 then timer=0;spawn() end end)
    for i=1,5 do task.delay(i*1.4,spawn) end
end

--====================================================
-- APPLY THEME
--====================================================
local function applyTheme(name)
    config.theme=name; saveConfig(config)
    local t=themes[name]; if not t then return end

    tw(root,T_SMOOTH,{BackgroundColor3=t.primary})
    rootStroke.Color=t.stroke
    tw(header,T_SMOOTH,{BackgroundColor3=t.secondary})
    tw(headerDivider,T_SMOOTH,{BackgroundColor3=t.stroke})
    tw(sidebar,T_SMOOTH,{BackgroundColor3=t.sidebar})
    tw(sidebarTopCover,T_SMOOTH,{BackgroundColor3=t.sidebar})
    tw(sideDiv,T_SMOOTH,{BackgroundColor3=t.stroke})

    if logo and t.logoId then logo.Image = "rbxassetid://" .. t.logoId end
    if bgImage and t.bgId then
        bgImage.Image = "rbxassetid://" .. t.bgId
        config.bgImageId = t.bgId
        saveConfig(config)
        if bgInput then bgInput.Text = t.bgId end
    end
    tw(titleLabel,T_SMOOTH,{TextColor3=t.text})
    tw(subtitleLabel,T_SMOOTH,{TextColor3=t.subtext})
    tw(statusLabel,T_SMOOTH,{TextColor3=t.subtext})
    tw(minimize,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text})
    minimizeStroke.Color=t.stroke
    tw(close,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text})
    closeStroke.Color=t.stroke

    contentArea.ScrollBarImageColor3=t.accent

    for _,r in ipairs(rows) do
        if r.frame and r.frame.Parent then
            tw(r.frame,T_SMOOTH,{BackgroundColor3=t.row})
            if r.stroke then r.stroke.Color=t.stroke end
        end
    end
    for _,o in ipairs(textMain) do if o and o.Parent then tw(o,T_SMOOTH,{TextColor3=t.text}) end end
    for _,o in ipairs(textSub)  do if o and o.Parent then tw(o,T_SMOOTH,{TextColor3=t.subtext}) end end

    for _,cb in ipairs(checkBoxes) do
        if cb.box and cb.box.Parent then
            local checked=cb.getState()
            tw(cb.box,T_SMOOTH,{BackgroundColor3=checked and t.accent or t.row})
            if cb.chk   then cb.chk.TextColor3 =t.primary end
            if cb.stroke then cb.stroke.Color  =t.stroke end
        end
    end

    for _,d in ipairs(dropRows) do
        if d.frame and d.frame.Parent then
            tw(d.frame,T_SMOOTH,{BackgroundColor3=t.row})
            if d.stroke then d.stroke.Color=t.stroke end
        end
    end
    for _,d in ipairs(dropLists) do
        if d.frame and d.frame.Parent then
            tw(d.frame,T_SMOOTH,{BackgroundColor3=t.secondary})
            if d.stroke then d.stroke.Color=t.stroke end
            for _,child in ipairs(d.frame:GetChildren()) do
                if child:IsA("TextButton") then
                    tw(child,T_SMOOTH,{BackgroundColor3=t.row,TextColor3=t.text})
                end
            end
        end
    end

    for _,s in ipairs(sliderObjs) do
        if s.track and s.track.Parent then
            tw(s.track, T_SMOOTH, {BackgroundColor3=t.row})
            if s.stroke then s.stroke.Color=t.stroke end
            tw(s.fill,  T_SMOOTH, {BackgroundColor3=t.accent})
            tw(s.knob,  T_SMOOTH, {BackgroundColor3=t.accent})
            if s.valLbl  then tw(s.valLbl,  T_SMOOTH, {TextColor3=t.accent}) end
            if s.nameLbl then tw(s.nameLbl, T_SMOOTH, {TextColor3=t.text}) end
        end
    end

    if bgSection       then tw(bgSection,T_SMOOTH,{BackgroundColor3=t.row}) end
    if bgSectionStroke then bgSectionStroke.Color=t.stroke end
    if bgPrefixLbl     then tw(bgPrefixLbl,T_SMOOTH,{TextColor3=t.subtext}) end
    if bgInput         then
        tw(bgInput,T_SMOOTH,{BackgroundColor3=t.primary,TextColor3=t.text})
        bgInput.PlaceholderColor3=t.subtext
    end
    if applyBgBtn then tw(applyBgBtn,T_SMOOTH,{BackgroundColor3=t.accent,TextColor3=t.primary}) end

    for i, tb in ipairs(tabBtns) do
        local on = (i == activeTabIdx)
        tw(tb.bg, T_SMOOTH, {BackgroundColor3 = on and t.accent or t.row, BackgroundTransparency = on and 0 or 0.55})
        tw(tb.lbl, T_SMOOTH, {TextColor3 = on and t.primary or t.text})
        if tb.isImage then
            tw(tb.ico, T_SMOOTH, {ImageColor3 = on and t.primary or t.subtext})
            if tabData[i].name == "Main"      and t.mainTabIcon      then tb.ico.Image = "rbxassetid://" .. t.mainTabIcon end
            if tabData[i].name == "Mics"      and t.micsTabIcon      then tb.ico.Image = "rbxassetid://" .. t.micsTabIcon end
            if tabData[i].name == "Teleports" and t.teleportTabIcon  then tb.ico.Image = "rbxassetid://" .. t.teleportTabIcon end
            if tabData[i].name == "Settings"  and t.settingsTabIcon  then tb.ico.Image = "rbxassetid://" .. t.settingsTabIcon end
        else
            tw(tb.ico, T_SMOOTH, {TextColor3 = on and t.primary or t.subtext})
        end
    end

    clearParticles()
    if not minimized then
        task.delay(0.35, function()
            local t2 = themes[config.theme]
            if t2.snow then startSnow() elseif t2.valentine then startValentine() end
        end)
    end
end

local function applyFont(name)
    config.fontStyle=name; saveConfig(config)
    local f=fonts[name] or Enum.Font.GothamBold
    for _,o in ipairs(fontObjs) do if o and o.Parent then o.Font=f end end
end

--====================================================
-- BUILD ROOT
--====================================================
root=Instance.new("Frame"); root.Parent=gui
root.Size=UDim2.new(0, UI_W, 0, UI_H)
root.Position=UDim2.fromScale(0.5,0.5)
root.AnchorPoint=Vector2.new(0.5,0.5)
root.BackgroundColor3=themes[config.theme].primary
root.BackgroundTransparency=0.02; root.ClipsDescendants=true; root.ZIndex=1
local rc=Instance.new("UICorner",root); rc.CornerRadius=UDim.new(0,24)
rootStroke=Instance.new("UIStroke",root); rootStroke.Color=themes[config.theme].stroke
rootStroke.Transparency=0.88; rootStroke.Thickness=1.2

bgImage = Instance.new("ImageLabel")
bgImage.Parent = root
bgImage.Size = UDim2.new(1, -2, 1, -2)
bgImage.Position = UDim2.new(0, 1, 0, 1)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://" .. (config.bgImageId or "108458500083995")
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ImageTransparency = 0.82
bgImage.ZIndex = 1
bgImage.ClipsDescendants = true
local bic = Instance.new("UICorner"); bic.CornerRadius = UDim.new(0, 24); bic.Parent = bgImage

setupDrag()

--====================================================
-- HEADER
--====================================================
header = Instance.new("Frame")
header.Parent = root
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = themes[config.theme].secondary
header.BackgroundTransparency = 0.25
header.BorderSizePixel = 0; header.ZIndex = 3
local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 24); hc.Parent = header
header.ClipsDescendants = true

headerDivider=Instance.new("Frame"); headerDivider.Parent=root
headerDivider.Size=UDim2.new(1,-40,0,1); headerDivider.Position=UDim2.new(0,20,0,58)
headerDivider.BackgroundColor3=themes[config.theme].stroke
headerDivider.BackgroundTransparency=0.9; headerDivider.BorderSizePixel=0; headerDivider.ZIndex=4

logo=Instance.new("ImageLabel"); logo.Parent=root
logo.Size=UDim2.new(0,34,0,34); logo.Position=UDim2.new(0,16,0,12)
logo.BackgroundTransparency=1; logo.Image="rbxassetid://128713599886538"
logo.ScaleType=Enum.ScaleType.Fit; logo.ZIndex=5
local lgc=Instance.new("UICorner",logo); lgc.CornerRadius=UDim.new(0.3,0)

titleLabel=Instance.new("TextLabel"); titleLabel.Parent=root
titleLabel.Size=UDim2.new(0,200,0,20); titleLabel.Position=UDim2.new(0,58,0,12)
titleLabel.BackgroundTransparency=1; titleLabel.Text="WH01"
titleLabel.Font=fonts[config.fontStyle] or Enum.Font.GothamBold
titleLabel.TextSize=11; titleLabel.TextColor3=themes[config.theme].text
titleLabel.TextXAlignment=Enum.TextXAlignment.Left; titleLabel.ZIndex=5
table.insert(fontObjs,titleLabel)

task.spawn(function()
    local ok, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if ok and info and info.Name then
        gameName = info.Name
        titleLabel.Text = "WH01  ·  " .. gameName
    end
end)

subtitleLabel=Instance.new("TextLabel"); subtitleLabel.Parent=root
subtitleLabel.Size=UDim2.new(0,200,0,14); subtitleLabel.Position=UDim2.new(0,58,0,32)
subtitleLabel.BackgroundTransparency=1; subtitleLabel.Text="made by wh01am"
subtitleLabel.Font=Enum.Font.Gotham; subtitleLabel.TextSize=10
subtitleLabel.TextColor3=themes[config.theme].subtext
subtitleLabel.TextXAlignment=Enum.TextXAlignment.Left; subtitleLabel.ZIndex=5

statusLabel=Instance.new("TextLabel"); statusLabel.Parent=root
statusLabel.Size=UDim2.new(0,260,0,22); statusLabel.Position=UDim2.new(0,16,1,-28)
statusLabel.BackgroundTransparency=1; statusLabel.Text="● System Ready"
statusLabel.Font=Enum.Font.GothamMedium; statusLabel.TextSize=10
statusLabel.TextColor3=themes[config.theme].subtext
statusLabel.TextXAlignment=Enum.TextXAlignment.Left; statusLabel.ZIndex=10

--====================================================
-- MINIMIZE & CLOSE
--====================================================
minimize=Instance.new("TextButton"); minimize.Parent=root
minimize.Size=UDim2.new(0,26,0,26); minimize.Position=UDim2.new(1,-62,0,16)
minimize.Text="—"; minimize.Font=Enum.Font.GothamBold; minimize.TextSize=12
minimize.TextColor3=themes[config.theme].text; minimize.BackgroundColor3=themes[config.theme].row
minimize.AutoButtonColor=false; minimize.ZIndex=6
local mc=Instance.new("UICorner",minimize); mc.CornerRadius=UDim.new(1,0)
minimizeStroke=Instance.new("UIStroke",minimize); minimizeStroke.Color=themes[config.theme].stroke; minimizeStroke.Transparency=0.88

close=Instance.new("TextButton"); close.Parent=root
close.Size=UDim2.new(0,26,0,26); close.Position=UDim2.new(1,-32,0,16)
close.Text="X"; close.Font=Enum.Font.GothamBold; close.TextSize=12
close.TextColor3=themes[config.theme].text; close.BackgroundColor3=themes[config.theme].row
close.AutoButtonColor=false; close.ZIndex=6
local clc=Instance.new("UICorner",close); clc.CornerRadius=UDim.new(1,0)
closeStroke=Instance.new("UIStroke",close); closeStroke.Color=themes[config.theme].stroke; closeStroke.Transparency=0.88

minimize.MouseEnter:Connect(function() tw(minimize,T_FAST,{BackgroundColor3=themes[config.theme].accent,TextColor3=themes[config.theme].primary}) end)
minimize.MouseLeave:Connect(function() tw(minimize,T_FAST,{BackgroundColor3=themes[config.theme].row,TextColor3=themes[config.theme].text}) end)
close.MouseEnter:Connect(function()   tw(close,T_FAST,{BackgroundColor3=themes[config.theme].accent,TextColor3=themes[config.theme].primary}) end)
close.MouseLeave:Connect(function()   tw(close,T_FAST,{BackgroundColor3=themes[config.theme].row,TextColor3=themes[config.theme].text}) end)

close.MouseButton1Click:Connect(function()
    clearParticles()
    tw(root,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0)})
    task.delay(0.35,function() gui:Destroy() end)
end)

-- Minimizar también funciona con Activated (mouse + touch)
local minimized=false
local function doMinimize()
    minimized = not minimized
    if minimized then
        clearParticles()
        task.delay(0.02, function()
            if body then body.Visible = false end
            statusLabel.Visible = false
            bgImage.Visible = false
        end)
        tw(root, T_SMOOTH, {Size = UDim2.new(0, isMobile and 220 or 280, 0, 58)})
        minimize.Text = "▢"
        if gameName then titleLabel.Text = gameName end
    else
        tw(root, T_SMOOTH, {Size = UDim2.new(0, UI_W, 0, UI_H)})
        if gameName then titleLabel.Text = "WH01  ·  " .. gameName end
        task.delay(0.35, function()
            if body then body.Visible = true end
            statusLabel.Visible = true
            bgImage.Visible = true
            minimize.Text = "—"
            local t = themes[config.theme]
            if t.snow then startSnow() elseif t.valentine then startValentine() end
        end)
    end
end

minimize.MouseButton1Click:Connect(doMinimize)
-- Touch support para minimize
minimize.Activated:Connect(function()
    if isMobile then doMinimize() end
end)
close.Activated:Connect(function()
    if isMobile then
        clearParticles()
        tw(root,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0)})
        task.delay(0.35,function() gui:Destroy() end)
    end
end)

--====================================================
-- BODY
--====================================================
body=Instance.new("Frame"); body.Parent=root
body.Size=UDim2.new(1,0,1,-60); body.Position=UDim2.new(0,0,0,60)
body.BackgroundTransparency=1; body.ZIndex=2

--====================================================
-- SIDEBAR
--====================================================
sidebar=Instance.new("Frame"); sidebar.Parent=body
sidebar.Size=UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.BackgroundColor3=themes[config.theme].sidebar
sidebar.BackgroundTransparency=0.15; sidebar.BorderSizePixel=0; sidebar.ZIndex=3
local sdc=Instance.new("UICorner",sidebar); sdc.CornerRadius=UDim.new(0,20)

sidebarTopCover=Instance.new("Frame"); sidebarTopCover.Parent=sidebar
sidebarTopCover.Size=UDim2.new(1,0,0,22)
sidebarTopCover.BackgroundColor3=themes[config.theme].sidebar
sidebarTopCover.BackgroundTransparency=0.15; sidebarTopCover.BorderSizePixel=0; sidebarTopCover.ZIndex=3

sideDiv=Instance.new("Frame"); sideDiv.Parent=body
sideDiv.Size=UDim2.new(0,1,1,0); sideDiv.Position=UDim2.new(0, SIDEBAR_W, 0, 0)
sideDiv.BackgroundColor3=themes[config.theme].stroke
sideDiv.BackgroundTransparency=0.9; sideDiv.BorderSizePixel=0; sideDiv.ZIndex=4

--====================================================
-- CONTENT AREA
--====================================================
local CONTENT_LEFT = SIDEBAR_W + 8
contentArea=Instance.new("ScrollingFrame"); contentArea.Parent=body
contentArea.Size=UDim2.new(1, -CONTENT_LEFT - 4, 1, -16)
contentArea.Position=UDim2.new(0, CONTENT_LEFT, 0, 8)
contentArea.BackgroundTransparency=1; contentArea.ZIndex=3
contentArea.ScrollBarThickness=3; contentArea.ScrollBarImageColor3=themes[config.theme].accent
contentArea.ScrollBarImageTransparency=0.3
contentArea.CanvasSize=UDim2.new(0,0,0,0)
contentArea.ClipsDescendants=true; contentArea.BorderSizePixel=0
contentArea.TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
contentArea.MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
contentArea.BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png"
-- En móvil, deshabilitar scrolling si un slider está activo
if isMobile then
    contentArea.ScrollingEnabled = true
end

--====================================================
-- PAGES
--====================================================
local mainPage=Instance.new("Frame"); mainPage.Parent=contentArea
mainPage.Size=UDim2.fromScale(1,0); mainPage.AutomaticSize=Enum.AutomaticSize.Y
mainPage.BackgroundTransparency=1; mainPage.Visible=true; mainPage.ZIndex=4
local mainPagePad=Instance.new("UIPadding",mainPage)
mainPagePad.PaddingLeft=UDim.new(0,8); mainPagePad.PaddingRight=UDim.new(0,8)

local micsPage=Instance.new("Frame"); micsPage.Parent=contentArea
micsPage.Size=UDim2.fromScale(1,0); micsPage.AutomaticSize=Enum.AutomaticSize.Y
micsPage.BackgroundTransparency=1; micsPage.Visible=false; micsPage.ZIndex=4
local micsPagePad=Instance.new("UIPadding",micsPage)
micsPagePad.PaddingLeft=UDim.new(0,8); micsPagePad.PaddingRight=UDim.new(0,8)

local settingsPage=Instance.new("Frame"); settingsPage.Parent=contentArea
settingsPage.Size=UDim2.fromScale(1,0); settingsPage.AutomaticSize=Enum.AutomaticSize.Y
settingsPage.BackgroundTransparency=1; settingsPage.Visible=false; settingsPage.ZIndex=4
local settingsPagePad=Instance.new("UIPadding",settingsPage)
settingsPagePad.PaddingLeft=UDim.new(0,8); settingsPagePad.PaddingRight=UDim.new(0,8)

local teleportsPage=Instance.new("Frame"); teleportsPage.Parent=contentArea
teleportsPage.Size=UDim2.fromScale(1,0); teleportsPage.AutomaticSize=Enum.AutomaticSize.Y
teleportsPage.BackgroundTransparency=1; teleportsPage.Visible=false; teleportsPage.ZIndex=4
local teleportsPagePad=Instance.new("UIPadding",teleportsPage)
teleportsPagePad.PaddingLeft=UDim.new(0,8); teleportsPagePad.PaddingRight=UDim.new(0,8)

local function updateCanvasSize(page)
    local maxY = 0
    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("GuiObject") then
            local bottom = child.Position.Y.Offset + child.Size.Y.Offset
            if bottom > maxY then maxY = bottom end
        end
    end
    contentArea.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
end

mainPage:GetPropertyChangedSignal("Visible"):Connect(function() if mainPage.Visible then updateCanvasSize(mainPage) end end)
micsPage:GetPropertyChangedSignal("Visible"):Connect(function() if micsPage.Visible then updateCanvasSize(micsPage) end end)
settingsPage:GetPropertyChangedSignal("Visible"):Connect(function() if settingsPage.Visible then updateCanvasSize(settingsPage) end end)
teleportsPage:GetPropertyChangedSignal("Visible"):Connect(function() if teleportsPage.Visible then updateCanvasSize(teleportsPage) end end)

--====================================================
-- WIDGET HELPERS
--====================================================
local function secLabel(parent,text,yp)
    local l=Instance.new("TextLabel"); l.Parent=parent
    l.Size=UDim2.new(1,0,0,18); l.Position=UDim2.new(0,2,0,yp)
    l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamBold
    l.TextSize=FONT_SUB; l.TextColor3=themes[config.theme].subtext
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
    table.insert(textSub,l); table.insert(fontObjs,l); return l
end

local function checkbox(parent,text,yp,defaultOn)
    local t=themes[config.theme]; local state=defaultOn or false
    local row=Instance.new("Frame"); row.Parent=parent
    row.Size=UDim2.new(1,0,0,ROW_H); row.Position=UDim2.new(0,0,0,yp)
    row.BackgroundColor3=t.row; row.BackgroundTransparency=0.2
    row.BorderSizePixel=0; row.ZIndex=5
    local rc2=Instance.new("UICorner",row); rc2.CornerRadius=UDim.new(0,14)
    local rs=Instance.new("UIStroke",row); rs.Color=t.stroke; rs.Transparency=0.93
    table.insert(rows,{frame=row,stroke=rs})

    local lbl=Instance.new("TextLabel"); lbl.Parent=row
    lbl.Size=UDim2.new(1,-55,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; lbl.TextSize=FONT_MAIN
    lbl.TextColor3=t.text; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    table.insert(textMain,lbl); table.insert(fontObjs,lbl)

    local box=Instance.new("Frame"); box.Parent=row
    box.Size=UDim2.new(0,22,0,22); box.Position=UDim2.new(1,-34,0.5,-11)
    box.BackgroundColor3=state and t.accent or t.row; box.BorderSizePixel=0; box.ZIndex=6
    local bc2=Instance.new("UICorner",box); bc2.CornerRadius=UDim.new(0,7)
    local bs=Instance.new("UIStroke",box); bs.Color=t.stroke; bs.Transparency=0.7

    local chk=Instance.new("TextLabel"); chk.Parent=box
    chk.Size=UDim2.fromScale(1,1); chk.BackgroundTransparency=1
    chk.Text="✓"; chk.Font=Enum.Font.GothamBold; chk.TextSize=13
    chk.TextColor3=t.primary; chk.Visible=state; chk.ZIndex=7
    table.insert(checkBoxes,{box=box,chk=chk,stroke=bs,getState=function() return state end})

    local overridden = false
    local btn=Instance.new("TextButton"); btn.Parent=row
    btn.Size=UDim2.fromScale(1,1); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=8
    btn.MouseEnter:Connect(function()
        tw(row,T_FAST,{BackgroundColor3=themes[config.theme].accent, BackgroundTransparency=0.4})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].primary})
    end)
    btn.MouseLeave:Connect(function()
        tw(row,T_FAST,{BackgroundColor3=themes[config.theme].row, BackgroundTransparency=0.2})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].text})
    end)
    local function toggleCheckbox()
        if overridden then overridden=false; return end
        state=not state; chk.Visible=state
        tw(box,T_FAST,{BackgroundColor3=state and themes[config.theme].accent or themes[config.theme].row})
        statusLabel.Text="● "..text..": "..(state and "ON" or "OFF")
    end
    btn.MouseButton1Click:Connect(toggleCheckbox)
    btn.Activated:Connect(function() if isMobile then toggleCheckbox() end end)

    local function forceOff()
        if state then overridden = true end
        state = false; chk.Visible = false
        tw(box, T_FAST, {BackgroundColor3 = themes[config.theme].row})
    end
    return btn, function() return state end, forceOff
end

--====================================================
-- SLIDER WIDGET — con soporte Touch
--====================================================
local function slider(parent, labelText, yp, minVal, maxVal, defaultVal, onChange)
    local t = themes[config.theme]
    local currentVal = defaultVal or minVal

    local row = Instance.new("Frame"); row.Parent = parent
    row.Size = UDim2.new(1, 0, 0, SLIDER_H); row.Position = UDim2.new(0, 0, 0, yp)
    row.BackgroundColor3 = t.row; row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0; row.ZIndex = 5
    local rowc = Instance.new("UICorner", row); rowc.CornerRadius = UDim.new(0, 14)
    local rows2 = Instance.new("UIStroke", row); rows2.Color = t.stroke; rows2.Transparency = 0.93
    table.insert(rows, {frame=row, stroke=rows2})

    local nameLbl = Instance.new("TextLabel"); nameLbl.Parent = row
    nameLbl.Size = UDim2.new(1, -70, 0, 18); nameLbl.Position = UDim2.new(0, 14, 0, 7)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = labelText
    nameLbl.Font = fonts[config.fontStyle] or Enum.Font.GothamBold; nameLbl.TextSize = FONT_MAIN
    nameLbl.TextColor3 = t.text; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 6
    table.insert(textMain, nameLbl); table.insert(fontObjs, nameLbl)

    local valLbl = Instance.new("TextLabel"); valLbl.Parent = row
    valLbl.Size = UDim2.new(0, 52, 0, 18); valLbl.Position = UDim2.new(1, -62, 0, 7)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(math.floor(currentVal))
    valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = FONT_MAIN
    valLbl.TextColor3 = t.accent; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 6
    table.insert(textMain, valLbl)

    local TRACK_Y = isMobile and 30 or 36
    local track = Instance.new("Frame"); track.Parent = row
    track.Size = UDim2.new(1, -28, 0, 6); track.Position = UDim2.new(0, 14, 0, TRACK_Y)
    track.BackgroundColor3 = t.row; track.BackgroundTransparency = 0; track.BorderSizePixel = 0; track.ZIndex = 6
    local trackc = Instance.new("UICorner", track); trackc.CornerRadius = UDim.new(1, 0)
    local trackStroke = Instance.new("UIStroke", track); trackStroke.Color = t.stroke; trackStroke.Transparency = 0.85
    table.insert(rows, {frame=track, stroke=trackStroke})

    local ratio = (currentVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame"); fill.Parent = track
    fill.Size = UDim2.new(ratio, 0, 1, 0); fill.BackgroundColor3 = t.accent
    fill.BorderSizePixel = 0; fill.ZIndex = 7
    local fillc = Instance.new("UICorner", fill); fillc.CornerRadius = UDim.new(1, 0)

    local KNOB_SIZE = isMobile and 20 or 16
    local knob = Instance.new("Frame"); knob.Parent = track
    knob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE); knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    knob.BackgroundColor3 = t.accent; knob.BorderSizePixel = 0; knob.ZIndex = 8
    local knobC = Instance.new("UICorner", knob); knobC.CornerRadius = UDim.new(1, 0)
    local knobDot = Instance.new("Frame"); knobDot.Parent = knob
    knobDot.Size = UDim2.new(0, 6, 0, 6); knobDot.AnchorPoint = Vector2.new(0.5, 0.5)
    knobDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knobDot.BackgroundTransparency = 0.4
    knobDot.BorderSizePixel = 0; knobDot.ZIndex = 9
    local kdC = Instance.new("UICorner", knobDot); kdC.CornerRadius = UDim.new(1, 0)

    table.insert(sliderObjs, {
        track = track, fill = fill, knob = knob,
        stroke = trackStroke, valLbl = valLbl, nameLbl = nameLbl
    })

    local function updateSlider(newVal, smooth)
        newVal = math.clamp(newVal, minVal, maxVal)
        currentVal = newVal
        local r = (newVal - minVal) / (maxVal - minVal)
        local ti = smooth and TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or TweenInfo.new(0)
        tw(fill, ti, {Size = UDim2.new(r, 0, 1, 0)})
        tw(knob, ti, {Position = UDim2.new(r, 0, 0.5, 0)})
        valLbl.Text = tostring(math.floor(newVal))
        if onChange then onChange(newVal) end
    end

    -- Zona clickeable / tactil más grande (mejor para dedos)
    local TOUCH_PAD = isMobile and 32 or 28
    local trackBtn = Instance.new("TextButton"); trackBtn.Parent = track
    trackBtn.Size = UDim2.new(1, 0, 0, TOUCH_PAD); trackBtn.Position = UDim2.new(0, 0, 0.5, -TOUCH_PAD/2)
    trackBtn.BackgroundTransparency = 1; trackBtn.Text = ""; trackBtn.ZIndex = 10

    -- Mouse
    trackBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            activeSlider = {track=track, minVal=minVal, maxVal=maxVal, label=labelText, update=updateSlider}
            local r = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateSlider(minVal + r * (maxVal - minVal), true)
            statusLabel.Text = "● " .. labelText .. ": " .. tostring(math.floor(currentVal))
        end
    end)

    -- Touch: activar slider y bloquear drag/scroll
    trackBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            -- Cancelar cualquier drag activo
            dragging    = false
            touchDragId = nil
            -- Activar slider
            activeSlider = {track=track, minVal=minVal, maxVal=maxVal, label=labelText, update=updateSlider}
            if isMobile then contentArea.ScrollingEnabled = false end
            local r = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateSlider(minVal + r * (maxVal - minVal), true)
            statusLabel.Text = "● " .. labelText .. ": " .. tostring(math.floor(currentVal))
        end
    end)

    -- Al soltar touch sobre el slider
    trackBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            activeSlider = nil
            if isMobile then contentArea.ScrollingEnabled = true end
        end
    end)

    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false; touchDragId = nil
            activeSlider = {track=track, minVal=minVal, maxVal=maxVal, label=labelText, update=updateSlider}
            if isMobile then contentArea.ScrollingEnabled = false end
        end
    end)

    trackBtn.MouseEnter:Connect(function()
        tw(knob, T_FAST, {Size = UDim2.new(0, KNOB_SIZE+2, 0, KNOB_SIZE+2)})
        tw(row, T_FAST, {BackgroundColor3=themes[config.theme].accent, BackgroundTransparency=0.4})
        tw(nameLbl, T_FAST, {TextColor3=themes[config.theme].primary})
        tw(valLbl, T_FAST, {TextColor3=themes[config.theme].primary})
    end)
    trackBtn.MouseLeave:Connect(function()
        if not activeSlider then
            tw(knob, T_FAST, {Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)})
            tw(row, T_FAST, {BackgroundColor3=themes[config.theme].row, BackgroundTransparency=0.2})
            tw(nameLbl, T_FAST, {TextColor3=themes[config.theme].text})
            tw(valLbl, T_FAST, {TextColor3=themes[config.theme].accent})
        end
    end)

    return row, function() return currentVal end, updateSlider
end

local function actionButton(parent,text,yp)
    local t=themes[config.theme]
    local btn=Instance.new("TextButton"); btn.Parent=parent
    btn.Size=UDim2.new(1,0,0,ROW_H); btn.Position=UDim2.new(0,0,0,yp)
    btn.Text=""; btn.BackgroundColor3=t.row; btn.BackgroundTransparency=0.2
    btn.AutoButtonColor=false; btn.ZIndex=5
    local bc2=Instance.new("UICorner",btn); bc2.CornerRadius=UDim.new(0,14)
    local bs=Instance.new("UIStroke",btn); bs.Color=t.stroke; bs.Transparency=0.93
    table.insert(rows,{frame=btn,stroke=bs})

    local lbl=Instance.new("TextLabel"); lbl.Parent=btn
    lbl.Size=UDim2.new(1,-30,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; lbl.TextSize=FONT_MAIN
    lbl.TextColor3=t.text; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    table.insert(textMain,lbl); table.insert(fontObjs,lbl)

    local arr=Instance.new("TextLabel"); arr.Parent=btn
    arr.Size=UDim2.new(0,20,0,20); arr.Position=UDim2.new(1,-28,0.5,-10)
    arr.BackgroundTransparency=1; arr.Text="→"; arr.Font=Enum.Font.GothamBold
    arr.TextSize=14; arr.TextColor3=t.subtext; arr.ZIndex=6
    table.insert(textSub,arr)

    btn.MouseEnter:Connect(function()
        tw(btn,T_FAST,{BackgroundColor3=themes[config.theme].accent, BackgroundTransparency=0.4})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].primary})
        tw(arr,T_FAST,{TextColor3=themes[config.theme].primary,Position=UDim2.new(1,-23,0.5,-10)})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn,T_FAST,{BackgroundColor3=themes[config.theme].row, BackgroundTransparency=0.2})
        tw(lbl,T_FAST,{TextColor3=themes[config.theme].text})
        tw(arr,T_FAST,{TextColor3=themes[config.theme].subtext,Position=UDim2.new(1,-28,0.5,-10)})
    end)
    btn.MouseButton1Down:Connect(function() tw(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,-4,0,ROW_H-2)}) end)
    btn.MouseButton1Up:Connect(function()   tw(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,0,0,ROW_H)}) end)
    -- Touch feedback
    btn.TouchLongPress:Connect(function() tw(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,-4,0,ROW_H-2)}) end)
    return btn
end

local activeDD=nil
local function dropdown(parent,labelText,options,currentVal,yp,onChange)
    local t=themes[config.theme]
    local cont=Instance.new("Frame"); cont.Parent=parent
    cont.Size=UDim2.new(1,0,0,42); cont.Position=UDim2.new(0,0,0,yp)
    cont.BackgroundTransparency=1; cont.ZIndex=8; cont.ClipsDescendants=false

    local mr=Instance.new("Frame"); mr.Parent=cont
    mr.Size=UDim2.new(1,0,0,42); mr.BackgroundColor3=t.row
    mr.BackgroundTransparency=0.25; mr.BorderSizePixel=0; mr.ZIndex=8
    local mrc=Instance.new("UICorner",mr); mrc.CornerRadius=UDim.new(0,14)
    local mrs=Instance.new("UIStroke",mr); mrs.Color=t.stroke; mrs.Transparency=0.88
    table.insert(dropRows,{frame=mr,stroke=mrs})

    local pl=Instance.new("TextLabel"); pl.Parent=mr
    pl.Size=UDim2.new(0,90,1,0); pl.Position=UDim2.new(0,14,0,0)
    pl.BackgroundTransparency=1; pl.Text=labelText..":"
    pl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; pl.TextSize=11
    pl.TextColor3=t.subtext; pl.TextXAlignment=Enum.TextXAlignment.Left; pl.ZIndex=9
    table.insert(textSub,pl); table.insert(fontObjs,pl)

    local vl=Instance.new("TextLabel"); vl.Parent=mr
    vl.Size=UDim2.new(1,-130,1,0); vl.Position=UDim2.new(0,104,0,0)
    vl.BackgroundTransparency=1; vl.Text=currentVal
    vl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; vl.TextSize=12
    vl.TextColor3=t.text; vl.TextXAlignment=Enum.TextXAlignment.Left; vl.ZIndex=9
    table.insert(textMain,vl); table.insert(fontObjs,vl)

    local al=Instance.new("TextLabel"); al.Parent=mr
    al.Size=UDim2.new(0,24,1,0); al.Position=UDim2.new(1,-30,0,0)
    al.BackgroundTransparency=1; al.Text="▼"; al.Font=Enum.Font.GothamBold
    al.TextSize=10; al.TextColor3=t.subtext; al.ZIndex=9
    table.insert(textSub,al)

    local dl=Instance.new("Frame"); dl.Parent=cont
    dl.Size=UDim2.new(1,0,0,#options*36+8); dl.Position=UDim2.new(0,0,0,46)
    dl.BackgroundColor3=t.secondary; dl.BackgroundTransparency=0.05
    dl.BorderSizePixel=0; dl.Visible=false; dl.ZIndex=20
    local dlc=Instance.new("UICorner",dl); dlc.CornerRadius=UDim.new(0,14)
    local dls=Instance.new("UIStroke",dl); dls.Color=t.stroke; dls.Transparency=0.85
    table.insert(dropLists,{frame=dl,stroke=dls})

    for i,opt in ipairs(options) do
        local ob=Instance.new("TextButton"); ob.Parent=dl
        ob.Size=UDim2.new(1,-8,0,30); ob.Position=UDim2.new(0,4,0,4+(i-1)*34)
        ob.Text=opt; ob.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; ob.TextSize=12
        ob.TextColor3=(opt==currentVal) and t.accent or t.text
        ob.BackgroundColor3=t.row; ob.BackgroundTransparency=(opt==currentVal) and 0.4 or 0.85
        ob.AutoButtonColor=false; ob.ZIndex=21
        local obc=Instance.new("UICorner",ob); obc.CornerRadius=UDim.new(0,10)
        table.insert(fontObjs,ob)
        ob.MouseEnter:Connect(function() tw(ob,T_FAST,{BackgroundTransparency=0.3}) end)
        ob.MouseLeave:Connect(function() tw(ob,T_FAST,{BackgroundTransparency=(ob.Text==vl.Text) and 0.4 or 0.85}) end)
        local function selectOpt()
            vl.Text=opt; dl.Visible=false; activeDD=nil; tw(al,T_FAST,{Rotation=0})
            onChange(opt); statusLabel.Text="● "..labelText..": "..opt
        end
        ob.MouseButton1Click:Connect(selectOpt)
        ob.Activated:Connect(function() if isMobile then selectOpt() end end)
    end

    local tb=Instance.new("TextButton"); tb.Parent=mr
    tb.Size=UDim2.fromScale(1,1); tb.BackgroundTransparency=1; tb.Text=""; tb.ZIndex=10
    local function toggleDD()
        if activeDD and activeDD~=dl then activeDD.Visible=false; activeDD=nil end
        dl.Visible=not dl.Visible; activeDD=dl.Visible and dl or nil
        tw(al,T_FAST,{Rotation=dl.Visible and 180 or 0})
    end
    tb.MouseButton1Click:Connect(toggleDD)
    tb.Activated:Connect(function() if isMobile then toggleDD() end end)
    return cont
end

--====================================================
-- POPULATE PAGES
--====================================================
secLabel(mainPage,"OPTIONS",0)

local gemsActive       = false
local gemsSpamDelay    = 1/10
local popupBlockerConn = nil

local function startPopupBlocker()
    popupBlockerConn = RunService.Heartbeat:Connect(function()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui.Name == "FTUEAuctionPrompt" then gui:Destroy() end
        end
    end)
end
local function stopPopupBlocker()
    task.delay(4, function()
        if popupBlockerConn then popupBlockerConn:Disconnect(); popupBlockerConn = nil end
    end)
end

local gemsBtn, getGemsState = checkbox(mainPage,"Gems", 22, false)
gemsBtn.MouseButton1Click:Connect(function()
    gemsActive = not gemsActive
    if gemsActive then
        statusLabel.Text = "● Gems: FARMING..."
        startPopupBlocker()
        task.spawn(function()
            while gemsActive do
                pcall(function()
                    local evt = game:GetService("ReplicatedStorage").Events.Tutorial.EndTutorial
                    safeFireServer(evt)
                end)
                rWait(gemsSpamDelay)
            end
        end)
    else
        stopPopupBlocker()
        statusLabel.Text = "● Gems: OFF"
    end
end)
-- Touch
gemsBtn.Activated:Connect(function()
    if isMobile then gemsBtn.MouseButton1Click:Fire() end
end)

local function showNotif(title, message, isError, checkboxRef)
    local t = themes[config.theme]
    local notif = Instance.new("Frame"); notif.Parent = gui
    notif.Size = UDim2.new(0, 260, 0, 70)
    notif.Position = UDim2.new(0, -270, 0, 120)
    notif.BackgroundColor3 = t.primary; notif.BackgroundTransparency = 0.08
    notif.BorderSizePixel = 0; notif.ZIndex = 100; notif.ClipsDescendants = true
    local nc = Instance.new("UICorner", notif); nc.CornerRadius = UDim.new(0, 16)
    local ns = Instance.new("UIStroke", notif)
    ns.Color = isError and Color3.fromRGB(220,60,60) or t.stroke
    ns.Transparency = 0.5; ns.Thickness = 1.2

    local nbg = Instance.new("ImageLabel"); nbg.Parent = notif
    nbg.Size = UDim2.new(1,0,1,0); nbg.BackgroundTransparency = 1
    nbg.Image = bgImage and bgImage.Image or ""; nbg.ScaleType = Enum.ScaleType.Crop
    nbg.ImageTransparency = 0.82; nbg.ZIndex = 100
    local nbgc = Instance.new("UICorner", nbg); nbgc.CornerRadius = UDim.new(0, 16)

    local titleLbl = Instance.new("TextLabel"); titleLbl.Parent = notif
    titleLbl.Size = UDim2.new(1, -16, 0, 22); titleLbl.Position = UDim2.new(0, 12, 0, 8)
    titleLbl.BackgroundTransparency = 1; titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 13
    titleLbl.TextColor3 = isError and Color3.fromRGB(220,60,60) or t.accent
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 102

    local msgLbl = Instance.new("TextLabel"); msgLbl.Parent = notif
    msgLbl.Size = UDim2.new(1, -16, 0, 28); msgLbl.Position = UDim2.new(0, 12, 0, 32)
    msgLbl.BackgroundTransparency = 1; msgLbl.Text = message
    msgLbl.Font = Enum.Font.GothamMedium; msgLbl.TextSize = 11
    msgLbl.TextColor3 = t.text; msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left; msgLbl.ZIndex = 102

    tw(notif, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 12, 0, 120)})
    task.delay(3.5, function()
        tw(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, -270, 0, 120)})
        task.delay(0.35, function() notif:Destroy() end)
    end)
end

local heartsActive  = false
local savedPosition = nil
local heartsChkBox  = nil

local heartsBtn, getHeartsState, heartsForceOff = checkbox(mainPage,"Collect Hearts", 64, false)
heartsChkBox = checkBoxes[#checkBoxes]

local function doHeartsToggle()
    if heartsActive then
        heartsActive = false; heartsForceOff()
        statusLabel.Text = "● Collect Hearts: OFF"; return
    end
    local snowflakesFolder = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Snowflakes")
    local count = snowflakesFolder and #snowflakesFolder:GetChildren() or 0
    if count == 0 then
        heartsForceOff()
        showNotif("Collect Hearts", "No snowflakes active in the map!", true)
        statusLabel.Text = "● Collect Hearts: Nothing found"; return
    end
    heartsActive = true
    local char = Players.LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then savedPosition = hrp.CFrame end
    showNotif("Collect Hearts", "Found " .. count .. " snowflakes! Teleporting...", false)
    statusLabel.Text = "● Collecting " .. count .. " snowflakes..."
    task.spawn(function()
        local flakes = snowflakesFolder:GetChildren()
        for _, flake in ipairs(flakes) do
            if not heartsActive then break end
            if flake and flake.Parent then
                local c = Players.LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then h.CFrame = flake.CFrame + Vector3.new(0, 3, 0); task.wait(0.15) end
            end
        end
        task.wait(0.2)
        local c2 = Players.LocalPlayer.Character
        local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        if h2 and savedPosition then h2.CFrame = savedPosition end
        heartsActive = false; heartsForceOff()
        statusLabel.Text = "● Collect Hearts: Done!"
    end)
end

heartsBtn.MouseButton1Click:Connect(doHeartsToggle)
heartsBtn.Activated:Connect(function() if isMobile then doHeartsToggle() end end)

secLabel(mainPage,"ACTIONS",106)

local sliderRow, getSliderVal = slider(mainPage, "Gems Speed", 128, 10, 200, 10, function(val)
    gemsSpamDelay = 1 / val
    statusLabel.Text = "● Gems Speed: " .. tostring(math.floor(val)) .. "spam"
end)
gemsSpamDelay = 1 / 10

--====================================================
-- MICS PAGE
--====================================================
secLabel(micsPage,"MICS",0)

local cflyActive   = false
local cflySpeed    = 50
local cflyConn     = nil
local cflyBodyVel  = nil
local cflyBodyGyro = nil

local cflyBtn, getCflyState, cflyForceOff = checkbox(micsPage, "Fly", 22, false)

local function stopCfly()
    cflyActive = false
    if cflyConn then cflyConn:Disconnect(); cflyConn = nil end
    pcall(function()
        if cflyBodyVel  then cflyBodyVel:Destroy();  cflyBodyVel  = nil end
        if cflyBodyGyro then cflyBodyGyro:Destroy(); cflyBodyGyro = nil end
    end)
    local char = localPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function doCflyToggle()
    cflyActive = not cflyActive
    if cflyActive then
        statusLabel.Text = "● CFly: ON"
        local char = localPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then
            cflyForceOff(); cflyActive = false
            statusLabel.Text = "● CFly: No character"; return
        end
        hum.PlatformStand = true
        cflyBodyVel = Instance.new("BodyVelocity"); cflyBodyVel.Parent = hrp
        cflyBodyVel.Velocity = Vector3.zero; cflyBodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
        cflyBodyGyro = Instance.new("BodyGyro"); cflyBodyGyro.Parent = hrp
        cflyBodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5); cflyBodyGyro.P = 1e4
        cflyConn = RunService.Heartbeat:Connect(function()
            local c2 = localPlayer.Character
            local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
            if not h2 then stopCfly(); cflyForceOff(); return end
            local cam = workspace.CurrentCamera
            local cf  = cam.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
               UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                dir = dir - Vector3.new(0,1,0)
            end
            if dir.Magnitude > 0 then cflyBodyVel.Velocity = dir.Unit * cflySpeed
            else cflyBodyVel.Velocity = Vector3.zero end
            cflyBodyGyro.CFrame = cf
        end)
    else
        stopCfly(); statusLabel.Text = "● CFly: OFF"
    end
end

cflyBtn.MouseButton1Click:Connect(doCflyToggle)
cflyBtn.Activated:Connect(function() if isMobile then doCflyToggle() end end)

slider(micsPage, "Fly Speed", 64, 10, 300, 50, function(val)
    cflySpeed = val; statusLabel.Text = "● Fly Speed: " .. tostring(math.floor(val))
end)

local cwalkActive = false
local cwalkSpeed  = 32
local cwalkConn   = nil

local cwalkBtn, getCwalkState, cwalkForceOff = checkbox(micsPage, "Walk", 122, false)

local function stopCwalk()
    cwalkActive = false
    if cwalkConn then cwalkConn:Disconnect(); cwalkConn = nil end
    local char = localPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end

local function doCwalkToggle()
    cwalkActive = not cwalkActive
    if cwalkActive then
        statusLabel.Text = "● CWalk: ON"
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then
            cwalkForceOff(); cwalkActive = false
            statusLabel.Text = "● CWalk: No character"; return
        end
        hum.WalkSpeed = cwalkSpeed
        cwalkConn = RunService.Heartbeat:Connect(function()
            local c2 = localPlayer.Character
            local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
            if not h2 then stopCwalk(); cwalkForceOff(); return end
            h2.WalkSpeed = cwalkSpeed
        end)
    else
        stopCwalk(); statusLabel.Text = "● CWalk: OFF"
    end
end

cwalkBtn.MouseButton1Click:Connect(doCwalkToggle)
cwalkBtn.Activated:Connect(function() if isMobile then doCwalkToggle() end end)

slider(micsPage, "Walk Speed", 164, 8, 150, 32, function(val)
    cwalkSpeed = val
    if cwalkActive then
        local char = localPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = cwalkSpeed end
    end
    statusLabel.Text = "● Walk Speed: " .. tostring(math.floor(val))
end)

secLabel(micsPage,"ABILITIES",222)

local infJumpActive = false
local infJumpConn   = nil

local infJumpBtn, getInfJumpState, infJumpForceOff = checkbox(micsPage, "Inf Jump", 244, false)

local function doInfJumpToggle()
    infJumpActive = not infJumpActive
    if infJumpActive then
        statusLabel.Text = "● Inf Jump: ON"
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = localPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
        statusLabel.Text = "● Inf Jump: OFF"
    end
end

infJumpBtn.MouseButton1Click:Connect(doInfJumpToggle)
infJumpBtn.Activated:Connect(function() if isMobile then doInfJumpToggle() end end)

--====================================================
-- SETTINGS PAGE
--====================================================
secLabel(settingsPage,"APPEARANCE",0)
dropdown(settingsPage,"Theme",{"Default","Valentine","Snow"},config.theme,22,function(v) applyTheme(v) end)
dropdown(settingsPage,"Font Style",{"Modern","Arcade","Rounded","Bold"},config.fontStyle,72,function(v) applyFont(v) end)
secLabel(settingsPage,"BACKGROUND",128)

bgSection=Instance.new("Frame"); bgSection.Parent=settingsPage
bgSection.Size=UDim2.new(1,0,0,50); bgSection.Position=UDim2.new(0,0,0,150)
bgSection.BackgroundColor3=themes[config.theme].row; bgSection.BackgroundTransparency=0.25
bgSection.BorderSizePixel=0; bgSection.ZIndex=5
local bgsc=Instance.new("UICorner",bgSection); bgsc.CornerRadius=UDim.new(0,14)
bgSectionStroke=Instance.new("UIStroke",bgSection); bgSectionStroke.Color=themes[config.theme].stroke; bgSectionStroke.Transparency=0.88

bgPrefixLbl=Instance.new("TextLabel"); bgPrefixLbl.Parent=bgSection
bgPrefixLbl.Size=UDim2.new(0,80,1,0); bgPrefixLbl.Position=UDim2.new(0,14,0,0)
bgPrefixLbl.BackgroundTransparency=1; bgPrefixLbl.Text="Image ID:"
bgPrefixLbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; bgPrefixLbl.TextSize=11
bgPrefixLbl.TextColor3=themes[config.theme].subtext; bgPrefixLbl.TextXAlignment=Enum.TextXAlignment.Left; bgPrefixLbl.ZIndex=6
table.insert(fontObjs,bgPrefixLbl)

bgInput=Instance.new("TextBox"); bgInput.Parent=bgSection
bgInput.Size=UDim2.new(1,-185,0,30); bgInput.Position=UDim2.new(0,96,0.5,-15)
bgInput.BackgroundColor3=themes[config.theme].primary; bgInput.BackgroundTransparency=0.3
bgInput.BorderSizePixel=0; bgInput.Text=config.bgImageId or "108458500083995"
bgInput.PlaceholderText="Enter image ID..."; bgInput.Font=Enum.Font.GothamMedium; bgInput.TextSize=11
bgInput.TextColor3=themes[config.theme].text; bgInput.PlaceholderColor3=themes[config.theme].subtext
bgInput.ZIndex=6; bgInput.ClearTextOnFocus=false
local bic2=Instance.new("UICorner",bgInput); bic2.CornerRadius=UDim.new(0,10)

applyBgBtn=Instance.new("TextButton"); applyBgBtn.Parent=bgSection
applyBgBtn.Size=UDim2.new(0,72,0,30); applyBgBtn.Position=UDim2.new(1,-82,0.5,-15)
applyBgBtn.Text="Apply"; applyBgBtn.Font=Enum.Font.GothamBold; applyBgBtn.TextSize=12
applyBgBtn.TextColor3=themes[config.theme].primary; applyBgBtn.BackgroundColor3=themes[config.theme].accent
applyBgBtn.AutoButtonColor=false; applyBgBtn.ZIndex=6
local abc=Instance.new("UICorner",applyBgBtn); abc.CornerRadius=UDim.new(0,10)
applyBgBtn.Activated:Connect(function()
    local id=bgInput.Text:match("%d+") or "108458500083995"
    bgImage.Image="rbxassetid://"..id; config.bgImageId=id; saveConfig(config)
    statusLabel.Text="● Background updated!"
    tw(applyBgBtn,T_FAST,{BackgroundTransparency=0.4})
    task.delay(0.15,function() tw(applyBgBtn,T_FAST,{BackgroundTransparency=0}) end)
end)

local removeBg=actionButton(settingsPage,"Remove Background",210)
removeBg.Activated:Connect(function()
    bgImage.Image=""; config.bgImageId=""; saveConfig(config); statusLabel.Text="● Background removed"
end)

--====================================================
-- TELEPORTS PAGE
--====================================================
local teleportSpots = {
    { name="Item Grading",      pos=Vector3.new(-425.40, 214.89, 1969.09) },
    { name="Warehouse",         pos=Vector3.new(-320.06, 213.16, 1967.06) },
    { name="Exchange",          pos=Vector3.new(-219.10, 211.40, 2104.88) },
    { name="Hall Of Fame",      pos=Vector3.new(-201.87, 216.69, 2010.82) },
    { name="Journal",           pos=Vector3.new(-206.76, 216.16, 1957.98) },
    { name="Sky Plaza",         pos=Vector3.new(-309.26, 211.81, 1888.81) },
    { name="Airport",           pos=Vector3.new(-230.22, 211.29, 1754.55) },
    { name="Repairs",           pos=Vector3.new(-441.28, 211.40, 1893.31) },
    { name="Sky Cafe",          pos=Vector3.new(-409.62, 214.11, 2104.76) },
    { name="Prices",            pos=Vector3.new(-612.05, 212.91, 2105.42) },
    { name="Hank's",            pos=Vector3.new(-440.32, 211.41, 2269.83) },
    { name="Discovery",         pos=Vector3.new(-370.00, 211.41, 2231.77) },
    { name="Shelves",           pos=Vector3.new(-217.01, 214.47, 2181.48) },
    { name="Business Center",   pos=Vector3.new(-324.90, 214.48, 2315.68) },
}
secLabel(teleportsPage,"TELEPORTS",0)

for i, spot in ipairs(teleportSpots) do
    local yp = 22 + (i-1)*(ROW_H+6)
    local btn = actionButton(teleportsPage, spot.name, yp)
    btn.Activated:Connect(function()
        local char = Players.LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(spot.pos)
            statusLabel.Text = "● Teleported to: " .. spot.name
        else
            statusLabel.Text = "● Error: Character not found"
        end
    end)
end

--====================================================
-- TABS
--====================================================
tabData={
    {name="Main",      icon="⬡", page=mainPage,      isImage=true},
    {name="Mics",      icon="👤", page=micsPage,      isImage=true},
    {name="Teleports", icon="✈", page=teleportsPage, isImage=true},
    {name="Settings",  icon="⚙", page=settingsPage,  isImage=true},
}
tabBtns={}
local activeTabIdx=nil

local function switchTab(idx)
    if activeTabIdx == idx then return end
    local t = themes[config.theme]
    local pages = {mainPage, micsPage, teleportsPage, settingsPage}

    if activeTabIdx then
        local out = pages[activeTabIdx]
        local dir = (idx > activeTabIdx) and -1 or 1
        tw(out, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Position = UDim2.new(dir * 0.07, 0, 0, 0)})
        task.delay(0.2, function()
            out.Visible = false; out.Position = UDim2.new(0, 0, 0, 0)
        end)
    end

    task.delay(activeTabIdx and 0.14 or 0, function()
        local inp = pages[idx]
        local d2 = (activeTabIdx and idx > activeTabIdx) and 1 or -1
        inp.Position = UDim2.new(d2 * 0.07, 0, 0, 0)
        inp.Visible = true
        tw(inp, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 0, 0, 0)})
    end)

    for i, tb in ipairs(tabBtns) do
        local on = (i == idx)
        tw(tb.bg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {BackgroundColor3 = on and t.accent or t.row,
             BackgroundTransparency = on and 0 or 0.55,
             Size = on and UDim2.new(1,-10,0,TAB_H) or UDim2.new(1,-16,0,TAB_H)})
        tw(tb.lbl, T_FAST, {TextColor3 = on and t.primary or t.text})
        if tb.isImage then
            tw(tb.ico, T_FAST, {ImageColor3 = on and t.primary or t.subtext})
        else
            tw(tb.ico, T_FAST, {TextColor3 = on and t.primary or t.subtext})
        end
    end
    activeTabIdx = idx
end

for i,data in ipairs(tabData) do
    local yp = 14 + (i-1)*TAB_GAP
    local tbg=Instance.new("Frame"); tbg.Parent=sidebar
    tbg.Size=UDim2.new(1,-16,0,TAB_H); tbg.Position=UDim2.new(0,8,0,yp)
    tbg.BackgroundColor3=themes[config.theme].row; tbg.BackgroundTransparency=0.55
    tbg.BorderSizePixel=0; tbg.ZIndex=5
    local tc=Instance.new("UICorner",tbg); tc.CornerRadius=UDim.new(0,14)
    local ts=Instance.new("UIStroke",tbg); ts.Color=themes[config.theme].stroke; ts.Transparency=0.94
    table.insert(rows,{frame=tbg,stroke=ts})

    local tico
    if data.isImage then
        tico = Instance.new("ImageLabel"); tico.Name = data.name.."Icon"; tico.Parent = tbg
        tico.Size = UDim2.new(0, isMobile and 14 or 16, 0, isMobile and 14 or 16)
        tico.Position = UDim2.new(0, 10, 0.5, isMobile and -7 or -8)
        tico.BackgroundTransparency = 1; tico.ScaleType = Enum.ScaleType.Fit
        tico.ImageColor3 = themes[config.theme].subtext; tico.ZIndex = 6
        if data.name == "Main"      then tico.Image = "rbxassetid://" .. themes[config.theme].mainTabIcon end
        if data.name == "Mics"      then tico.Image = "rbxassetid://" .. themes[config.theme].micsTabIcon end
        if data.name == "Teleports" then tico.Image = "rbxassetid://" .. themes[config.theme].teleportTabIcon end
        if data.name == "Settings"  then tico.Image = "rbxassetid://" .. themes[config.theme].settingsTabIcon end
    else
        tico = Instance.new("TextLabel"); tico.Parent = tbg
        tico.Size = UDim2.new(0, 22, 1, 0); tico.Position = UDim2.new(0, 8, 0, 0)
        tico.BackgroundTransparency = 1; tico.Text = data.icon
        tico.Font = Enum.Font.GothamBold; tico.TextSize = isMobile and 12 or 14
        tico.TextColor3 = themes[config.theme].subtext; tico.ZIndex = 6
        table.insert(textSub, tico)
    end

    local tlbl=Instance.new("TextLabel"); tlbl.Parent=tbg
    tlbl.Size=UDim2.new(1,-30,1,0); tlbl.Position=UDim2.new(0, isMobile and 28 or 32, 0,0)
    tlbl.BackgroundTransparency=1; tlbl.Text=data.name
    tlbl.Font=fonts[config.fontStyle] or Enum.Font.GothamBold; tlbl.TextSize=FONT_MAIN
    tlbl.TextColor3=themes[config.theme].text; tlbl.TextXAlignment=Enum.TextXAlignment.Left; tlbl.ZIndex=6
    table.insert(textMain,tlbl); table.insert(fontObjs,tlbl)

    local tbtn=Instance.new("TextButton"); tbtn.Parent=tbg
    tbtn.Size=UDim2.fromScale(1,1); tbtn.BackgroundTransparency=1; tbtn.Text=""; tbtn.ZIndex=7
    tabBtns[i]={bg=tbg,lbl=tlbl,ico=tico,isImage=data.isImage}

    tbtn.MouseEnter:Connect(function() if activeTabIdx~=i then tw(tbg,T_FAST,{BackgroundTransparency=0.25}) end end)
    tbtn.MouseLeave:Connect(function() if activeTabIdx~=i then tw(tbg,T_FAST,{BackgroundTransparency=0.55}) end end)
    tbtn.Activated:Connect(function() switchTab(i) end)
end

--====================================================
-- INIT
--====================================================
switchTab(1)
applyTheme(config.theme)
applyFont(config.fontStyle)
if config.bgImageId and config.bgImageId~="" then
    bgImage.Image="rbxassetid://"..config.bgImageId
end
updateCanvasSize(mainPage)

--====================================================
-- ENTRANCE
--====================================================
root.Size=UDim2.new(0,0,0,0)
tw(root,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,UI_W,0,UI_H)})
print("MultiTool UI v6.0 loaded! Mobile:", isMobile)
