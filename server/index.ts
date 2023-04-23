import { SNetServer, BitStream, SNET_PRIORITES } from './snet';
import { Packet, PacketStruct, readPacket, writePacket } from './packets';
const server = new SNetServer({ port: 11321 });
server.on('ready', () => {
    console.log('@server: started');
});

const cards: string[] = [ 
    'd6', 'd7', 'd8', 'd9', 'd10', 'd11', 'd12', 'd13', 'd14',
    'h6', 'h7', 'h8', 'h9', 'h10', 'h11', 'h12', 'h13', 'h14',
    'c6', 'c7', 'c8', 'c9', 'c10', 'c11', 'c12', 'c13', 'c14',
    's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14'
];



enum GameState {
    WAIT_FOR_PLAYERS,
    IN_PROGRESS
};

interface Player {
    ip: string,
    port: number,
    name: string,
    cardsCount: number
};

interface Room {
    id: number,
    players: Player[],
    trumpCard: string,
    cardsQueue: string[],
    activePlayer?: Player,
    activePlayerTime?: number
};


server.on('onReceivePacket', async (id, bs, ip, port) => {
    const data = readPacket(id, bs);
    console.log(`[RECV] IP: ${ip}:${port}, DATA:`);
    console.log(data);

    if (id == Packet.CreateRoom) {
        
    };
});
server.listen();

const shuffle = (array: Array<any>): Array<any> => {
    let currentIndex = array.length,  randomIndex;
    while (currentIndex != 0) {
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;
        [array[currentIndex], array[randomIndex]] = [
        array[randomIndex], array[currentIndex]];
    }
    return array;
}