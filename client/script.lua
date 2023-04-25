local imgui = require('mimgui')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8

local ffi = require('ffi')
local window = imgui.new.bool(true)

local GameState = {
    WAIT_FOR_PLAYERS = 0,
    WAIT_FOR_READY = 1,
    IN_PROGRESS = 2,
    ENDING = 3
}

local Game = {
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
            { 'c1', 'c2' },
            { 'c2' }
        },
        state = GameState.WAIT_FOR_PLAYERS
    },
    myCards = { 'h10', 'h11', 'h12', 'h13' }
}

local dolbaeb = require('lib.dolbaeb')
local net = require('lib.dolbaeb').net
local resources = require('lib.dolbaeb.resource')

imgui.OnInitialize(function() 
    imgui.GetIO().IniFilename = nil
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    resources.init()
end)


-- Trump (Козырь)
-- Hearts (Черви / Сердца)
-- Diamonds (Бубы / Алмазы)
-- Clubs (Трефы / Клубы)
-- Spades (Пики / Лопаты)



-- net.setupPacketHandler()
net.SNetClient:add_event_handler('onReceivePacket', function(id, bs)
    if id >= 0 and id <= 10 then
        print('packet received', id)
        local data, JSON = net.readPacket(id, bs)
        print(id, JSON)

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
                --for k, v in next, c do print(k, v) end
                sampAddChatMessage(c, -1)
                -- sampAddChatMessage('JoinRoomResponse', -1)
                Game.window[0] = true
            else
                sampAddChatMessage('error', -1)
            end
        elseif id == net.Packet.ChatMessage then
            sampAddChatMessage(data.message, -1)
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
        local size, res = imgui.ImVec2(300, 300), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        if imgui.Begin('DOLBAEB ONLINE: ROOM SELECTION', Game.roomSelection) then
            if imgui.Button('+') then
                net.send(net.Packet.CreateRoom, { usernameLen = #ffi.string(Game.username), username = ffi.string(Game.username) })
            end
            if imgui.Button('U') then
                net.send(net.Packet.getRooms, {})
            end
            for _, room in ipairs(Game.roomsList) do
                if imgui.Button(tostring(room.id)) then
                    net.send(net.Packet.JoinRoom, {
                        usernameLen = #ffi.string(Game.username),
                        username = ffi.string(Game.username),
                        roomId = room.id
                    })
                end
            end
            imgui.End()
        end
    end
)

Game.window[0] = true
imgui.OnFrame(
    function() return Game.window[0] end,
    function(this)
        local size, res = imgui.ImVec2(800, 600), imgui.ImVec2(getScreenResolution())
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        if imgui.Begin('Dolbaeb Online | Room: '..Game.roomId, Game.window) then
            local size = imgui.GetWindowSize()
            if imgui.Button('request update') then
                net.send(net.Packet.RequestRoomUpdate, { roomId = Game.roomId })
            end
            if Game.match.state == GameState.WAIT_FOR_PLAYERS then
                imgui.Text('Dolbaeb Online\nWaiting for players...')
                imgui.Text(tostring(#Game.match.players))
                for k, v in pairs(Game.match.players) do
                    imgui.Text(tostring(v.name)..':')
                    imgui.SameLine()
                    imgui.TextColored(v.ready and imgui.ImVec4(0, 1, 0, 1) or imgui.ImVec4(1, 0, 0, 1), v.ready and 'READY' or 'NOT READY')
                end
                if imgui.Button('ready') then
                    net.send(net.Packet.Ready, { roomId = Game.roomId, usernameLen = #ffi.string(Game.username), username = ffi.string(Game.username) })
                end

            elseif Game.match.state == GameState.WAIT_FOR_PLAYERS and false then
                if imgui.BeginChild('gameField', imgui.ImVec2(size.x - 10, size.y / 1.5), true) then
                    
                    -- resources.card('c2', imgui.ImVec2(130, 175))
                    --imgui.Image(resources.img, imgui.ImVec2(130, 175), resources.getCardUV('d14'))

                    -- if imgui.BeginChild('queue', imgui.ImVec2(130, 175), true) then

                    -- end
                    -- imgui.EndChild()

                    -- imgui.SetCursorPosX(100)
                    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
                    for slotIndex = 1, 6 do
                        if imgui.BeginChild('tableCardSlot'..slotIndex, imgui.ImVec2(130, 175), true, imgui.WindowFlags.NoScrollbar) then
                            local thisCards = Game.match.table[slotIndex]
                            local __start = imgui.GetCursorPos()
                            if thisCards then
                                if thisCards[1] then
                                    resources.card((thisCards and thisCards[1] or '_') ..'##tableCard'..tostring(slotIndex), imgui.ImVec2(130, 175))
                                end
                                local __end = imgui.GetCursorPos()
                                if thisCards[2] then
                                    imgui.SetCursorPos(imgui.ImVec2(__start.x + 10, __start.y + 10))
                                    imgui.Button((thisCards and thisCards[2] or '_') ..'##tableCard'..tostring(slotIndex), imgui.ImVec2(130, 175))
                                end
                            end

                            imgui.SetCursorPos(__start)
                            imgui.InvisibleButton('tableCardSlotClickZone_'..tostring(slotIndex), imgui.ImVec2(130, 175))
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

                                        Game.match.table[slotIndex][ key ] = card
                                        table.remove(Game.myCards, myIndex)
                                        net.send(net.Packet.ThrowCard, { roomId = Game.roomId, slotId = slotIndex, card = card})
                                        -- if  then
                                        -- Game.match.table[slotIndex] = { Game.match.table[slotIndex][1] }
                                    else
                                        sampAddChatMessage('undefined card', -1)
                                    end
                                end
                            end
                        end
                        imgui.EndChild()
                        if slotIndex ~= 3 then
                            imgui.SameLine()
                        end
                    end
                    imgui.PopStyleVar()
                end
                imgui.EndChild()

                if imgui.BeginChild('myField', imgui.ImVec2(size.x - 10, size.y - 40 - size.y / 1.5), true) then
                    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
                    for slotIndex = 1, 6 do
                        if imgui.BeginChild('myCardSlot'..slotIndex, imgui.ImVec2(130 / 1.16, 175 / 1.16), true) then
                            imgui.InvisibleButton(tostring(slotIndex)..'##myCard', imgui.ImVec2(130 / 1.16, 175 / 1.16))
                            if imgui.BeginDragDropSource() then
                                imgui.SetDragDropPayload('##payload', ffi.new('int[1]', slotIndex), 23)
                                --dl:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 35 + 35, p.y + 35 + 35), imgui.GetColorU32Vec4(imgui.ImVec4(1,1,1,0.3)))
                                imgui.EndDragDropSource()
                            end
                        end
                        imgui.EndChild()
                        imgui.SameLine()
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

function imgui.DrawCard()

end
