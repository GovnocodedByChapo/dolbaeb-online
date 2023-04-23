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
    }
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
    roomsList = 8
}

Net.PacketStruct = {
    [Net.Packet.JSON] = { 
        { 'BS_INT16', 'len' },
        { 'BS_STRING', 'jsonData' }
    },
    [Net.Packet.CreateRoom] = {
        { 'BS_INT16', 'usernameLen' },
        { 'BS_STRING', 'username' },
    },
    [Net.Packet.CreateRoomResponse] = {
        { 'BS_BOOLEAN', 'status' },
        { 'BS_UINT16', 'roomId' }
    },
    [Net.Packet.JoinRoom] = {
        { 'BS_INT16', 'usernameLen' },
        { 'BS_STRING', 'username' },
        { 'BS_UINT16', 'roomId' }
    },
    [Net.Packet.JoinRoomResponse] = {
        { 'BS_BOOLEAN', 'status' },
        { 'BS_INT16', 'messageLen' },
        { 'BS_STRING', 'message' },
        { 'BS_INT16', 'roomLen' },
        { 'BS_STRING', 'room' }
    },
    getRooms = {},
    roomsList = {
        { 'BS_INT16', 'jsonLen' },
        { 'BS_STRING', 'json' }
    }
}

function Net.readPacket(id, bs)
    local struct = Net.PacketStruct[id]
    local data = {}
    for index, item in ipairs(struct) do
        data[item[2]] = bs:read(item[1], item[1] == 'BS_STRING' and bs:read(struct[index-1]) or nil)
    end
    return data
end

function Net.writePacket(id, bs)
    local struct = Net.PacketStruct[id]
    local bs = bstream.new()
    for index, item in ipairs(struct) do
        bs:write(item[1], item[2])
    end
    return bs
end

function Net.setupPacketHandler()
    
end

function Net.loop()
    SNetClient:process();
end

function Net.sendJSON(id, data)
    local J = json.encode(data)
    local bs = bstream.new();
    bs:write(BS_INT16, #J)
    bs:write(BS_STRING, J)
    SNetClient:send(Net.Packet.JSON, bs, SNET_SYSTEM_PRIORITY)
end

---@param id Net.Packet
function Net.send(id, data)

end

function Net.room.create()

end

function Net.room.join()

end

function Net.room.leave()

end






return Net