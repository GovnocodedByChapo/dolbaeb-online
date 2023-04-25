export enum CardThrowError {
    NO_SPACE,
    NOT_YOUR_TURN,
    CARD_TOO_LOW
}

export enum GameState {
    WAIT_FOR_PLAYERS,
    WAIT_FOR_READY,
    IN_PROGRESS,
    ENDING
};

export interface Player {
    ip: string,
    port: number,
    name: string,
    cardsCount: number,
    ready: boolean
};

export interface Room {
    id: number,
    players: Player[],
    trumpCard: string,
    cardsQueue: string[],
    activePlayer?: Player,
    activePlayerTime?: number,
    table: Array<Array<string>>,
    state: GameState
};

export const cards: string[] = [ 
    'd6', 'd7', 'd8', 'd9', 'd10', 'd11', 'd12', 'd13', 'd14',
    'h6', 'h7', 'h8', 'h9', 'h10', 'h11', 'h12', 'h13', 'h14',
    'c6', 'c7', 'c8', 'c9', 'c10', 'c11', 'c12', 'c13', 'c14',
    's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14'
];

export const getCard = (code: string): [string, number] => {
    const cardData = code.match(/(\a)(\d+)/);
    if (!cardData) return ['_', -1];
    return [cardData?.[1] || '_', +cardData?.[2] || -1];
};

// python is shit
export const isCardAllowed = (tableSlot: Array<string>, card: string, slot: number, trumpCard: string): [boolean, string] => {
    if (!tableSlot[1]) return [true, 'OK_FIRST_CARD'];
    const [ trumpType ] = getCard(trumpCard);
    const [ targetType, targetNumber ] = getCard(tableSlot[1]);
    const [ cardType, cardNumber ] = getCard(card);
    if ( (cardType == targetType && cardNumber > targetNumber) || (cardType == trumpType) ) return [true, 'OK_POWER_CONFIRMED'];
    return [false, 'UNKNOWN'];
};

export const getReadyPlayers = (room: Room): number => {
    let count = 0;
    for (const player of room.players) if (player.ready) count ++;
    return count;
};