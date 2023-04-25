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
    roomsList,
    RoomUpdate = 10,
    RequestRoomUpdate = 11,
    ThrowCard = 12,
    Ready = 13,
    ChatMessage = 14
};

export const PacketStruct = {
    [Packet.JSON]: [ 
        ['BS_UINT16', 'len' ],
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
        ['BS_UINT16', 'usernameLen'],
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
    ],
    [Packet.RoomUpdate]: [
        ['BS_INT16', 'jsonLen'],
        ['BS_STRING', 'json']
    ],
    [Packet.RequestRoomUpdate]: [
        [ 'BS_INT16', 'roomId' ]
    ],
    [Packet.ThrowCard]: [
        [ 'BS_INT16', 'roomId' ],
        [ 'BS_INT16', 'slotId' ],
        [ 'BS_STRING', 'card', 3]
    ],
    [Packet.Ready]: [
        [ 'BS_INT16', 'roomId' ],
        [ 'BS_INT16', 'usernameLen' ],
        [ 'BS_STRING', 'username' ]
    ],
    [Packet.ChatMessage]: [
        [ 'BS_INT16', 'messageLen' ],
        [ 'BS_STRING', 'message' ]
    ]
};



const bsTypes = {
    BS_INT16: { read: 'readInt16', write: 'writeInt16' },
    BS_UINT16: { read: 'readUInt16', write: 'writeUInt16' },
    BS_STRING: { read: 'readString', write: 'writeString' },
    BS_BOOLEAN: { read: 'readBoolean', write: 'writeBoolean' }
}

export interface JoinRoom {
    username: string,
    roomId: number
}

export interface CreateRoom {
    username: string
}

export interface ThrowCard {
    roomId: number,
    username: string,
    card: string,
    slot: number
}
export function readPacket(id: Packet.ThrowCard, bs: BitStream): ThrowCard; 
export function readPacket(id: Packet.JoinRoom, bs: BitStream): JoinRoom; 
export function readPacket(id: Packet.CreateRoom, bs: BitStream): CreateRoom; 

export function readPacket(id: Packet, bs: BitStream): unknown {
    
    const struct = PacketStruct[id];
    console.log(id, struct);
    const data: Object = {};

    let prevValue;
    for (const item of struct) {
        const val = bs[bsTypes[item[0]].read](item[0] == 'BS_STRING' ? prevValue : null);
        prevValue = val;
        data[item[1]] = val;
        // console.log(val, item);
    }

    return data;
};

export const writePacket = (id: Packet, data: Object): BitStream => {
    const struct = PacketStruct[id];
    const bs = new BitStream();
    
    let prevValue;
    for (const item of struct) {
        // console.log(`[BS] [WRITE] Writing id:${id} item ${item}, val: ${data[item[1]]}`)
        const type = item[0];
        const name = item[1];
        const bsType = bsTypes[type]
        bs[bsType.write](data[name]);
        
    }

    return bs;
};

