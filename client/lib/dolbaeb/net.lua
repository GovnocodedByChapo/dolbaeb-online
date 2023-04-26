local json = require('lib.dolbaeb.json')
local snet = require('snet');
local SNetClient, bstream = snet.client('127.0.0.1', 11321), snet.bstream;



Net = {
    json = json,
    snet = snet,
    SNetClient = SNetClient,
    bstream = bstream,
    room = {},
    match = {},
    server = {
        ip = '127.0.0.1',
        port = 11321
    },
}

---@alias BS_INT8 any
---@alias BS_INT16 any
---@alias BS_INT32 any
---@alias BS_UINT8 any
---@alias BS_UINT16 any
---@alias BS_UINT32 any
---@alias BS_FLOAT any
---@alias BS_BOOLEAN any
---@alias BS_STRING any

---@class Net.Packet
Net.Packet = {
    JSON = 0,
    CreateRoom = 1,
    CreateRoomResponse = 2,
    JoinRoom = 3,
    JoinRoomResponse = 4,
    LeaveRoom = 5,
    LeaveRoomResponse = 6,
    getRooms = 7,
    roomsList = 8,
    RoomUpdate = 10,
    RequestRoomUpdate = 11,
    ThrowCard = 12,
    ThrowCardResponse = 13,
    Ready = 14,
    ChatMessage = 15,
    SendEmoji = 16
}

Net.PacketStruct = {
    [Net.Packet.JSON] = { 
        { BS_INT16, 'len' },
        { BS_STRING, 'jsonData' }
    },
    [Net.Packet.CreateRoom] = {
        { BS_INT16, 'usernameLen' },
        { BS_STRING, 'username' },
    },
    [Net.Packet.CreateRoomResponse] = {
        { BS_BOOLEAN, 'status' },
        { BS_UINT16, 'roomId' }
    },
    [Net.Packet.JoinRoom] = {
        { BS_INT16, 'usernameLen' },
        { BS_STRING, 'username' },
        { BS_UINT16, 'roomId' }
    },
    [Net.Packet.JoinRoomResponse] = {
        { BS_BOOLEAN, 'status' },
        { BS_INT16, 'messageLen' },
        { BS_STRING, 'message' },
        { BS_INT16, 'roomLen' },
        { BS_STRING, 'room' }
    },
    [Net.Packet.getRooms] = {},
    [Net.Packet.roomsList] = {
        { BS_INT16, 'jsonLen' },
        { BS_STRING, 'json' }
    },
    [Net.Packet.RoomUpdate] = {
        { BS_INT16, 'jsonLen' },
        { BS_STRING, 'json' }
    },
    [Net.Packet.RequestRoomUpdate] = {
        { BS_INT16, 'roomId' }
    },
    [Net.Packet.ThrowCard] = {
        { BS_INT16, 'roomId' },
        { BS_INT16, 'slotId' },
        { BS_INT16, 'level' },
        { BS_INT16, 'usernameLen' },
        { BS_STRING, 'username' },
        { BS_STRING, 'card', 3}
    },
    [Net.Packet.ThrowCardResponse] = {
        { BS_BOOLEAN, 'status' },
        { BS_INT16, 'roomId' },
        { BS_INT16, 'usernameLen' },
        { BS_STRING, 'username' },
        { BS_INT16, 'slot' },
        { BS_INT16, 'slotLevel' },
        { BS_STRING, 'cardCode', 3 },
    },
    [Net.Packet.Ready] = {
        { BS_INT16, 'roomId' },
        { BS_INT16, 'usernameLen' },
        { BS_STRING, 'username' },
    },
    [Net.Packet.ChatMessage] = {
        { BS_INT16, 'messageLen' },
        { BS_STRING, 'message' },
    },
}

function Net.readPacket(id, bs)
    local previousValue, struct = 0, Net.PacketStruct[id]
    local data = {}
    for index, item in ipairs(struct) do
        local valueType, name = item[1], item[2]
        print('reading', name, 'size', valueType == BS_STRING and item[3] or previousValue)
        local value = bs:read(item[1], valueType == BS_STRING and item[3] or previousValue) 
        data[name] = value
        previousValue = value
        print('read', index, value)
        --data[item[2]] = bs:read(item[1], item[1] == 'BS_STRING' and bs:read(struct[index-1]) or nil)
    end
    return data, json.encode(data)
end

function Net.writePacket(id, bs)
    local struct = Net.PacketStruct[id]
    local bs = bstream.new()
    for index, item in ipairs(struct) do
        bs:write(item[1], item[2])
    end
    return bs
end



function Net.sendJSON(id, data)
    local J = json.encode(data)
    local bs = bstream.new();
    bs:write(BS_INT16, #J)
    bs:write(BS_STRING, J)
    SNetClient:send(Net.Packet.JSON, bs, SNET_SYSTEM_PRIORITY)
end

---@param id Net.Packet
---@param data table
function Net.send(id, data)
    sampAddChatMessage('123', -1)
    local struct = Net.PacketStruct[id]
    assert(struct, 'Struct for this packet not found')
    local bs = bstream.new()
    for index, item in ipairs(struct) do
        bs:write(item[1], data[item[2]])
    end
    print(SNetClient.connected)
    SNetClient:send(id, bs, SNET_SYSTEM_PRIORITY)
end

function Net.loop()
    SNetClient:process()
end

return Net