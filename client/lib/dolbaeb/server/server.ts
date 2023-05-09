import { SNetServer, BitStream, SNET_PRIORITES } from './snet';
const server = new SNetServer({ port: 11321 });
server.on('ready', () => {
    console.log('@server: started');
});

enum Packet {
    JSON,
    Ping,
    Pong
};

const cards: string[] = [ 
    'd6', 'd7', 'd8', 'd9', 'd10', 'd11', 'd12', 'd13', 'd14',
    'h6', 'h7', 'h8', 'h9', 'h10', 'h11', 'h12', 'h13', 'h14',
    'c6', 'c7', 'c8', 'c9', 'c10', 'c11', 'c12', 'c13', 'c14',
    's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14'
]

interface User {
    ip: string,
    port: number,
    cards?: string[] | null,
    name: string
}

interface Room {
    id: number,
    maxPlayers: number,
    players: User[],
    cardQueue: string[],
    table: string[],
    trump: string,
    activePlayer?: string
}
const rooms: Room[] = [

];

console.log(`
DolbaebOnline (TypeScript) server started!
Author: chapo
Made with node-snet
`)

const sendJson = (id: Packet | number, data: Object, ip: string, port: number): void => {
    const json = JSON.stringify(data);
    const bs = new BitStream();
    bs.writeInt16(json.length);
    bs.writeString(json);
    server.send(id, bs, SNET_PRIORITES.HIGH, ip, port);
    console.log(`[SEND] IP: ${ip}:${port}, DATA: ${json}`);
};

server.on('onReceivePacket', async (id, bs, ip, port) => {
    if (id === Packet.JSON) {
        const data = JSON.parse(bs.readString(bs.readInt16()));
        console.log(`[RECEIVE] ID: ${id}, ADDRESS: ${ip}:${port}, data:`)
        console.log(data);
        
        if (data.name == 'getRooms') {
            return sendJson(Packet.JSON, { name: 'roomsList', list: rooms }, ip, port);
        } else if (data.name == 'createRoom') {
            rooms.push({
                id: rooms.length,
                maxPlayers: 3,
                players: [
                    { ip: ip, port: port, name: data.username }
                ],
                cardQueue: [''],
                table: [''],
                trump: 'c'
            });
            return sendJson(Packet.JSON, { name: 'createRoomResponse', status: true, id: rooms.length - 1}, ip, port);
        } else if (data.name == 'joinRoom') {
            console.log(rooms)
            if (!rooms[data.roomId] || rooms[data.roomId].players.length >= rooms[data.roomId].maxPlayers) return sendJson(Packet.JSON, { name: 'joinRoomResponse', ok: false, message: !rooms[data.roomId] ? 'room with this id not found' : 'room is full' }, ip, port);
            if (!data.username) return sendJson(Packet.JSON, { name: 'joinRoomResponse', ok: false, message: 'nickname is required' }, ip, port);
            
            rooms[data.roomId].players.push({
                ip: ip,
                port: port,
                name: data.username
            });
            if (rooms[data.roomId].players.length == rooms[data.roomId].maxPlayers) {
                rooms[data.roomId].cardQueue = cards;
                rooms[data.roomId].trump = rooms[data.roomId].cardQueue[getRandomInt(35)];
                for (const player of rooms[data.roomId].players) {
                    sendJson(Packet.JSON, {
                        name: 'matchStart',
                        cards: rooms[data.roomId].cardQueue,
                        trump: rooms[data.roomId].trump,
                        activePlayer: rooms[data.roomId].players[0]
                    }, player.ip, player.port);
                }
            }
            
            const roomFormatted = rooms[data.roomId];
            console.log(roomFormatted.players)
            roomFormatted.players = roomFormatted.players.map( (player) => player.name );
            sendJson(Packet.JSON, { name: 'joinRoomResponse', status: true, message: 'ok', room: roomFormatted }, ip, port);
        } else if (data.name == 'throwCard') {
            if (rooms[data.roomId]?.activePlayer == data.username) {
                
            }
        };
    };
});

server.listen();

function getRandomInt(max) {
    return Math.floor(Math.random() * max);
}

