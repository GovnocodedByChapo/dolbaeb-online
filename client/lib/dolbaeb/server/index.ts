import { SNetServer, BitStream, SNET_PRIORITES } from './snet';
import { Packet, PacketStruct, readPacket, writePacket } from './packets';
import { shuffle, getRandomInt } from './utils';
import { Player, Room, cards, isCardAllowed, GameState, getReadyPlayers, processCardThrow, startGame } from './logic';
const server = new SNetServer({ port: 11321 });
server.on('ready', () => {
    console.log('@server: started');
});



const rooms: Room[] = [];

server.on('onReceivePacket', async (id, bs, ip, port) => {
    if (!Packet[id]) return console.log('Unknown packet received: ' + id);
    const data = readPacket(id, bs);
    console.log(`[RECV] IP: ${ip}:${port}, DATA:`);
    console.log(data);
    
    switch (id) {
        case Packet.CreateRoom:
            if (!data.username) return send(Packet.CreateRoomResponse, { status: false, roomId: -1}, ip, port);
            let roomsCards = shuffle(cards);
            const roomId = rooms.length;
            rooms.push({
                id: roomId,
                players: [],
                trumpCard: roomsCards[roomsCards.length - 1],
                cardsQueue: roomsCards,
                table: [ [], [], [], [], [], [] ],
                state: GameState.WAIT_FOR_PLAYERS
            });
            console.log('sended CreateRoomResponse')
            return send(Packet.CreateRoomResponse, { status: true, roomId: roomId }, ip, port);
        
        case Packet.JoinRoom:
            //console.log(rooms);
            if (!data.roomId || !rooms[data.roomId]) {
                console.log(`unknown room id ${data.roomId}, rooms len: ${rooms.length}`);
                console.log(rooms[data.roomId]);
                return send(Packet.JoinRoomResponse, {status: false, messageLen: 1, message: 'unknown_room_id', roomLen: ('unknown_room_id').length, room: ''}, ip, port);
            }

            if (rooms[data.roomId].players.findIndex(p => p.name === data.username) != -1) {
                return send(Packet.JoinRoomResponse, {status: false, messageLen: 1, message: 'nickname_taken', roomLen: ('nickname_taken').length, room: ''}, ip, port);
            }

            
            rooms[data.roomId].players.push({
                name: data.username,
                ip: ip,
                port: port,
                cards: [],
                ready: false
            });
            rooms[data.roomId].activePlayer = rooms[data.roomId].players[0]
            rooms[data.roomId].state = rooms[data.roomId].players.length == 3 ? GameState.WAIT_FOR_READY : GameState.WAIT_FOR_PLAYERS; //GameState.IN_PROGRESS;//

            const roomJson = JSON.stringify(rooms[data.roomId]);
            return send(Packet.JoinRoomResponse, {status: true, messageLen: 2, message: 'ok', roomLen: roomJson.length, room: roomJson}, ip, port);

        case Packet.getRooms:
            const roomsJson = JSON.stringify(rooms);
            return send(Packet.roomsList, { jsonLen: roomsJson.length, json: roomsJson}, ip, port);

        case Packet.RequestRoomUpdate:
            const roomData = JSON.stringify(rooms[data.roomId]);
            console.log(`room update requested, id: ${data.roomId}, room:`)
            console.log(rooms[data.roomId])
            return send(Packet.RoomUpdate, { jsonLen: roomData.length, json: roomData }, ip, port);

        case Packet.ThrowCard:
            if (!rooms[data.roomId]) return
            const processResult = processCardThrow(rooms[data.roomId], data);
            console.log(`processCardThrow ${processResult}`);



            // const [ok] = isCardAllowed(rooms[data.roomId].table[data.slotId], data.card, data.slotId, rooms[data.roomId].trumpCard);
            if (processResult) rooms[data.roomId].table[data.slotId][data.level - 1] = data.card
            return send(Packet.ThrowCardResponse, {
                status: processResult, 
                roomId: data.roomId,
                usernameLen: data.usernameLen,
                username: data.username,
                slot: data.slotId,
                slotLevel: data.level,
                cardCode: data.card
                
            }, ip, port);

        case Packet.Ready:
            const index = rooms[data.roomId].players.findIndex(p => p.name === data.username)
            rooms[data.roomId].players[index].ready = true;

            const readyPlayersCount = getReadyPlayers(rooms[data.roomId]);
            const message = `[Ready] ${readyPlayersCount} / 3`
            sendToRoom(Packet.ChatMessage, { messageLen: message.length, message: message }, rooms[data.roomId]);
            if (readyPlayersCount == 3) {
                rooms[data.roomId].activePlayer = rooms[data.roomId].players[getRandomInt(3)];
                startGame(rooms[data.roomId]);
            };
        default:
            break;
    };
});
server.listen();

const send = (id: Packet, data: Object, ip: string, port: number): void => {
    const bs = writePacket(id, data);
    server.send(id, bs, SNET_PRIORITES.HIGH, ip, port);
    console.log(`[SEND] ID: ${id}, DATA:`);
    console.log(data);
};

const sendToRoom = (id: Packet, data: Object, room: Room): void => {
    for (const player of room.players) {
        if (player.ip && player.port) {
            send(id, data, player.ip, player.port);
            console.log(`[ROOM-RESEND] PLAYER: ${player.name}, IP: ${player.ip}, PACKET: ${id}`);
        };
    };
};