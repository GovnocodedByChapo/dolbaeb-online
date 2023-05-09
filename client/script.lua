local imgui = require('mimgui')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8

local ffi = require('ffi')
local dolbaeb = require('lib.dolbaeb')
local net = require('lib.dolbaeb.net')
local language = require('lib.dolbaeb.language')
local resources = require('lib.dolbaeb.resource')

script.load(thisScript().directory)
script.load(thisScript().directory)

local window = imgui.new.bool(true)
local f = string.format
local GameState = {
    WAIT_FOR_PLAYERS = 0,
    WAIT_FOR_READY = 1,
    IN_PROGRESS = 2,
    ENDING = 3
}

local Game = {
    lastRoomUpdate = 0,
    roomSelection = imgui.new.bool(true),
    roomsList = {},
    username = imgui.new.char[24]('chapo'),
    window = imgui.new.bool(false),
    roomId = 0,
    match = {
        id = 0,
        players = {},
        trumpCard = 'c10',
        cardsQueue = {},
        activePlayer = {},
        activePlayerTime = 0,
        table = {
            { 'c06', 'c10' },
            { 'h14' }
        },
        state = GameState.WAIT_FOR_PLAYERS
    },
    myCards = { }
}



imgui.OnInitialize(function()
    resources.init()
    imgui.GetIO().IniFilename = nil
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    -- imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.7, 0.7, 0.7, 1)
end)


-- Trump (Козырь)
-- Hearts (Черви / Сердца)
-- Diamonds (Бубы / Алмазы)
-- Clubs (Трефы / Клубы)
-- Spades (Пики / Лопаты)



-- net.setupPacketHandler()
net.SNetClient:add_event_handler('onReceivePacket', function(id, bs)
    if id >= 0 and id <= 20 then
        print('packet received', id)
        local data, JSON = net.readPacket(id, bs)
        print('[RECV]', id)
        sampAddChatMessage('[DOLBAEB] [RECV] ID:'..id, -1)
        for k, v in next, data do print(k, v) end

        if id == net.Packet.RoomUpdate then
            -- Game.match.id = data.id
            -- Game.match.trumpCard = data.trumpCard
            -- Game.match.players = data.players
            -- for i = 1, 6 do
            --     Game.match.table[i] = {
            --         data['tableSlot'..i],
            --         data['tableSlotBeat'..i]
            --     }
            -- end
            Game.match = decodeJson(data.json)
        elseif id == net.Packet.roomsList then
            Game.roomsList = decodeJson(data.json)
        elseif id == net.Packet.CreateRoomResponse then
            if data.status then
                net.send(net.Packet.JoinRoom, {
                    usernameLen = #ffi.string(Game.username),
                    username = ffi.string(Game.username),
                    roomId = data.roomId
                })
            else
                sampAddChatMessage('Ошибка создания комнаты', -1)
            end
        elseif id == net.Packet.JoinRoomResponse then
            local status, res = pcall(net.json.decode, data.room)
            if status and res and res.id then
                Game.roomId = res.id
                Game.window[0] = true
                net.send(net.Packet.RequestRoomUpdate, { roomId = Game.roomId })
            else
                sampAddChatMessage('error', -1)
            end

        elseif id == net.Packet.ThrowCardResponse then
            sampAddChatMessage('net.Packet.ThrowCardResponse '..encodeJson(data), -1)
            net.send(net.Packet.RequestRoomUpdate, { roomId = Game.roomId })
            if data.status then
                data.slot = data.slot + 1
                Game.match.table[data.slot] = Game.match.table[data.slot] or { nil, nil }
                sampAddChatMessage('slot index '..data.slot..' lvl '..data.slotLevel, -1)
                Game.match.table[data.slot][data.slotLevel] = data.card
                if data.username == ffi.string(Game.username) then
                    for mySlot, cardCode in ipairs(Game.myCards) do
                        if cardCode == data.cardCode then
                            table.remove(Game.myCards, mySlot)
                            break
                        end 
                    end
                end
            else
                sampAddChatMessage('Card not allowed / not your turn', -1)
            end
        elseif id == net.Packet.ChatMessage then
            sampAddChatMessage('chatmsg', -1)
        end
    end
end)




function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('dolbaeb', function() window[0] = not window[0] end)
    while true do
        wait(0)
        net.loop()
    end
end



local frame = imgui.OnFrame(
    function() return Game.roomSelection[0] end,
    function(this)
        math.randomseed(os.time() * math.random(1, 9999))
        local size, res = imgui.ImVec2(300, 400), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowPos(imgui.ImVec2(math.random(1, 1900), math.random(1, 1000)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)

        if Game.lastRoomUpdate + 5 - os.clock() <= 0 then
            net.send(net.Packet.getRooms, {})
            Game.lastRoomUpdate = os.clock()
        end

        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.97, 0.96, 0.97, 1))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.28, 0.42, 0.56, 1))
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.28, 0.42, 0.56, 1))
        imgui.PushStyleColor(imgui.Col.TitleBg, imgui.ImVec4(0.28, 0.42, 0.56, 1))
        imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0.28, 0.42, 0.56, 1))
        imgui.PushStyleColor(imgui.Col.TitleBgCollapsed, imgui.ImVec4(0.28, 0.42, 0.56, 1))

        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 7)
        imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 7)
        if imgui.Begin('DOLBAEB ONLINE', Game.roomSelection, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
            local size = imgui.GetWindowSize()

            imgui.PushItemWidth(120)
            imgui.InputText('##username', Game.username, ffi.sizeof(Game.username))
            imgui.PopItemWidth()
            imgui.SameLine()

            if imgui.Button('Create room') then
                net.send(net.Packet.CreateRoom, { usernameLen = #ffi.string(Game.username), username = ffi.string(Game.username) })
            end
            imgui.SameLine()
            if imgui.Button('update list') then
                net.send(net.Packet.getRooms, {})
            end
            if imgui.BeginChild('roomsList', imgui.ImVec2(size.x - 10, size.y - imgui.GetCursorPosY() - 5), true) then
                for _, room in ipairs(Game.roomsList) do
                    imgui.SetCursorPosX(5)
                    if imgui.Button(f('Room #%s (%s / 3)', room.id, #room.players), imgui.ImVec2(size.x - 20, 30)) then
                        net.send(net.Packet.JoinRoom, {
                            usernameLen = #ffi.string(Game.username),
                            username = ffi.string(Game.username),
                            roomId = room.id
                        })
                    end
                    imgui.Separator()
                end
            end
            imgui.EndChild()
            
            imgui.End()
        end
        imgui.PopStyleColor(6)
        imgui.PopStyleVar(2)
    end
)

Game.window[0] = true
imgui.OnFrame(
    function() return Game.window[0] end,
    function(this)
        local size, res = imgui.ImVec2(800, 600), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        if imgui.Begin('Dolbaeb Online | Room #'..Game.roomId, Game.window) then
            local size = imgui.GetWindowSize()
            local cardSize = imgui.ImVec2(130 / 1.16, 175 / 1.16)
            
            

            if imgui.Button('request update') then
                net.send(net.Packet.RequestRoomUpdate, { roomId = Game.roomId })
            end
            
            if true then
                if imgui.BeginChild('gameField', imgui.ImVec2(size.x - 10, size.y / 1.5), true) then
                    --// PLAYERS
                    imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 10)
                    for playerIndex = 1, 3 do
                        local player = Game.match.players[playerIndex]
                        local x = size.x / 4 * playerIndex - 50
                        if Game.match.state == GameState.WAIT_FOR_READY then
                            local text = player and (player.ready and 'READY' or 'NOT READY') or 'Empty slot...'
                            imgui.SetCursorPos(imgui.ImVec2(x + 25 - imgui.CalcTextSize(text).x / 2, 10 + 50 + 5))
                            imgui.Text(text)
                        end
                        imgui.SetCursorPos(imgui.ImVec2(x, 10))
                        local pStart = imgui.GetCursorScreenPos()
                        imgui.GetWindowDrawList():AddRect(imgui.ImVec2(pStart.x - 2, pStart.y - 2), imgui.ImVec2(pStart.x + 50 + 2, pStart.y + 50 + 2), Game.match.state == GameState.WAIT_FOR_PLAYERS and 0xFFffffff or player and (player.ready and 0xFF00FF00 or 0xFF0000FF) or 0xFFffffff, 10, nil, 2)
                        imgui.Button(player and player.name..'##PLAYERNICKNAMEBUTTON' or '##emptyplayerslot', imgui.ImVec2(50, 50))
                    end
                    imgui.PopStyleVar()

                    if Game.match.state == GameState.IN_PROGRESS then
                        --// CARDS QUEUE
                        imgui.SetCursorPos(imgui.ImVec2(10, imgui.GetWindowHeight() / 2 - cardSize.y / 2))
                        if imgui.BeginChild('cardsQueue', imgui.ImVec2(cardSize.y, cardSize.y), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
                            ImRotateStart();
                            imgui.SetCursorPosX(17)
                            resources.cardButton(Game.match.trumpCard, cardSize)
                            ImRotateEnd(3.145);

                            imgui.SetCursorPos(imgui.ImVec2(0, 0))
                            imgui.Image(resources.cards.background, imgui.ImVec2(cardSize.x, cardSize.y - 1))

                            imgui.SetCursorPosY(0)
                            imgui.CenterText('Cards left: '..#Game.match.cardsQueue)
                        end
                        imgui.EndChild()

                        imgui.SetCursorPos(imgui.ImVec2(10, imgui.GetWindowHeight() / 2 - cardSize.y / 2 + cardSize.y + 13))
                        if imgui.BeginChild('myActivity', imgui.ImVec2(cardSize.y, 100), true) then
                            if Game.match.activePlayer.name == ffi.string(Game.username) then
                                if imgui.Button('TAKE', imgui.ImVec2(cardSize.y - 10, 30)) then end
                            else
                                if imgui.Button('DONE', imgui.ImVec2(cardSize.y - 10, 30)) then end
                            end
                            if not getPlayersReady()[ffi.string(Game.username)] then
                                if imgui.Button('READY', imgui.ImVec2(cardSize.y - 10, 30)) then
                                    net.send(net.Packet.Ready, { roomId = Game.roomId, usernameLen = #ffi.string(Game.username), username = ffi.string(Game.username) })
                                    net.send(net.Packet.RequestRoomUpdate, { roomId = Game.roomId })
                                end
                            end
                            imgui.Text('YOUR TURN')
                        end
                        imgui.EndChild()

                        local tableCardsFieldSize = imgui.ImVec2(cardSize.x * 3 + 10, cardSize.y * 2 + 5)
                        imgui.SetCursorPos(imgui.ImVec2(size.x / 2 - tableCardsFieldSize.x / 2, imgui.GetWindowHeight() / 2 - tableCardsFieldSize.y / 2 + 40))
                        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
                        if imgui.BeginChild('tableCardsField', tableCardsFieldSize, true) then

                            if #Game.match.players == 3 or true then
                                for slotIndex = 1, 6 do
                                    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
                                    if imgui.BeginChild('tableCardSlot'..slotIndex, cardSize, true, imgui.WindowFlags.NoScrollbar) then
                                        local thisCards = Game.match.table[slotIndex]
                                        local __start = imgui.GetCursorPos()
                                        if thisCards then
                                            if thisCards[1] then
                                                --resources.card((thisCards and thisCards[1] or '_') ..'##tableCard'..tostring(slotIndex), cardSize)
                                                resources.cardButton(thisCards[1], cardSize)
                                            end
                                            local __end = imgui.GetCursorPos()
                                            if thisCards[2] then
                                                imgui.SetCursorPos(imgui.ImVec2(__start.x + 10, __start.y + 10))
                                                --imgui.Button((thisCards and thisCards[2] or '_') ..'##tableCard'..tostring(slotIndex), cardSize)
                                                --imgui.ImageButton(resources.cards.img, cardSize, resources.getCardUV(thisCards[2]))
                                                resources.cardButton(thisCards[2], cardSize)
                                            end
                                        end

                                        imgui.SetCursorPos(__start)
                                        imgui.InvisibleButton('tableCardSlotClickZone_'..tostring(slotIndex), cardSize)
                                        if imgui.BeginDragDropTarget() then
                                            local Payload = imgui.AcceptDragDropPayload()
                                            if Payload ~= nil then
                                                local myIndex = ffi.cast("int*",Payload.Data)[0]
                                                local card = Game.myCards[myIndex]
                                                if card then
                                                    local key
                                                    if not Game.match.table[slotIndex] then
                                                        Game.match.table[slotIndex] = {}
                                                        key = 1
                                                    else
                                                        key = 2
                                                    end

                                                    
                                                    net.send(net.Packet.ThrowCard, { 
                                                        roomId = Game.roomId,
                                                        slotId = slotIndex - 1,
                                                        level = Game.match.table[slotIndex][1] == nil and 1 or 2,
                                                        card = card,
                                                        usernameLen = #ffi.string(Game.username),
                                                        username = ffi.string(Game.username)
                                                    })
                                                    -- Game.match.table[slotIndex][ key ] = card
                                                    -- table.remove(Game.myCards, myIndex)
                                                    sampAddChatMessage('sended throw card '..card..' to slot '..slotIndex..' slot lvl '..(Game.match.table[slotIndex][1] == nil and 1 or 2), -1)
                                                else
                                                    sampAddChatMessage('undefined card', -1)
                                                end
                                            end
                                        end
                                    end
                                    imgui.EndChild()
                                    imgui.PopStyleVar()
                                    if slotIndex ~= 3 then
                                        imgui.SameLine()
                                    end
                                end
                            else
                                imgui.CenterText('WAIT FOR PLAYERS')
                            end
                        end
                        imgui.EndChild()
                        imgui.PopStyleVar()
                    elseif Game.match.state == GameState.WAIT_FOR_PLAYERS then
                        imgui.CenterText('Wait for players...')
                    elseif Game.match.state == GameState.WAIT_FOR_READY then
                        imgui.CenterText('\n\nWait for players are ready...')
                        if not getPlayersReady()[ffi.string(Game.username)] then
                            imgui.SetCursorPos(imgui.ImVec2(size.x / 2 - 100, size.y / 3))
                            if imgui.Button('I\'m ready!', imgui.ImVec2(200, 75)) then
                                net.send(net.Packet.Ready, { roomId = Game.roomId, usernameLen = #ffi.string(Game.username), username = ffi.string(Game.username) })
                            end
                        end
                    end
                end
                imgui.EndChild()
                if imgui.BeginChild('myField', imgui.ImVec2(size.x - 10, size.y - 40 - size.y / 1.5), true) then
                    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
                    for slotIndex = 1, 6 do
                        if Game.myCards[slotIndex] then
                            if imgui.BeginChild('myCardSlot'..slotIndex, imgui.ImVec2(130 / 1.16, 175 / 1.16), true) then
                                resources.cardButton(Game.myCards[slotIndex], cardSize)
                                if imgui.BeginDragDropSource() then
                                    imgui.SetDragDropPayload('##payload', ffi.new('int[1]', slotIndex), 23)
                                    resources.cardButton(Game.myCards[slotIndex], cardSize)
                                    imgui.EndDragDropSource()
                                end
                            end
                            imgui.EndChild()
                            imgui.SameLine()
                        end
                    end
                    imgui.PopStyleVar()
                end
                imgui.EndChild()
                
                -- if imgui.Button('request update') then
                --     net.send(net.Packet.RequestRoomUpdate, { roomId = Game.roomId })
                -- end
                -- for _, player in ipairs(Game.match.players) do
                --     imgui.Text(player.name or 'UNDEFINED')
                -- end
            end
            imgui.End()
        end
    end
)

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

function getPlayersReady()
    local result = {}
    for k, v in pairs(Game.match.players) do
        result[v.name] = v.ready
    end
    return result
end


local rotation_start_index
function ImMin(lhs, rhs) return imgui.ImVec2(math.min(lhs.x, rhs.x), math.min(lhs.y, rhs.y)); end
function ImMax(lhs, rhs) return imgui.ImVec2(math.max(lhs.x, rhs.x), math.max(lhs.y, rhs.y)); end
function ImRotate(v, cos_a, sin_a) return imgui.ImVec2(v.x * cos_a - v.y * sin_a, v.x * sin_a + v.y * cos_a); end
function ImRotateStart()
   rotation_start_index = imgui.GetWindowDrawList().VtxBuffer.Size;
end
function ImRotationCenter()
   local l, u = imgui.ImVec2(imgui.FLT_MAX, imgui.FLT_MAX), imgui.ImVec2(-imgui.FLT_MAX, -imgui.FLT_MAX); -- bounds
   local buf = imgui.GetWindowDrawList().VtxBuffer
   for i = rotation_start_index, buf.Size - 1 do
      l, u = ImMin(l, buf.Data[i].pos), ImMax(u, buf.Data[i].pos);
   end
   return imgui.ImVec2((l.x+u.x)/2, (l.y+u.y)/2); -- or use _ClipRectStack?
end
function calcImVec2(l, r) return { x = l.x - r.x, y = l.y - r.y } end
function ImRotateEnd(rad, center)
   if center == nil then
      center = ImRotationCenter()
   end
   local s, c = math.sin(rad), math.cos(rad);
   center = calcImVec2(ImRotate(center, s, c), center);
   local buf = imgui.GetWindowDrawList().VtxBuffer;
   for i = rotation_start_index, buf.Size - 1 do
      buf.Data[i].pos = calcImVec2(ImRotate(buf.Data[i].pos, s, c), center);
   end
end


