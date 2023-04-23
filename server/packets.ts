import { SNetServer, BitStream, SNET_PRIORITES } from './snet';
export enum Packet {
    JSON,
    CreateRoom,
    CreateRoomResponse,
    JoinRoom,
    JoinRoomResponse,
    LeaveRoom,
    LeaveRoomResponse,
    getRooms,
    roomsList
};

export const PacketStruct = {
    [Packet.JSON]: [ 
        ['BS_INT16', 'len' ],
        ['BS_STRING', 'jsonData']
    ],
    [Packet.CreateRoom]: [
        ['BS_INT16', 'usernameLen'],
        ['BS_STRING', 'username']
    ],
    [Packet.CreateRoomResponse]: [
        ['BS_BOOLEAN', 'status'],
        ['BS_UINT16', 'roomId']
    ],
    [Packet.JoinRoom]: [
        ['BS_INT16', 'usernameLen'],
        ['BS_STRING', 'username'],
        ['BS_UINT16', 'roomId']
    ],
    [Packet.JoinRoomResponse]: [
        ['BS_BOOLEAN', 'status'],
        ['BS_INT16', 'messageLen'],
        ['BS_STRING', 'message'],
        ['BS_INT16', 'roomLen'],
        ['BS_STRING', 'room']
    ],
    [Packet.getRooms]: [],
    [Packet.roomsList]: [
        ['BS_INT16', 'jsonLen'],
        ['BS_STRING', 'json']
    ]
};

export const readPacket = (id: Packet, bs: BitStream): Object => {
    const data: Object = {};
    return data;
};

export const writePacket = (id: Packet, data: Object): void => {

};
