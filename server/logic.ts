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
    beatPlayer?: Player,
    activePlayerTime?: number,
    table: Array<Array<string>>,
    state: GameState
};

import { ThrowCard } from "./packets";

export const cards: string[] = [ 
    'd06', 'd07', 'd08', 'd09', 'd10', 'd11', 'd12', 'd13', 'd14',
    'h06', 'h07', 'h08', 'h09', 'h10', 'h11', 'h12', 'h13', 'h14',
    'c06', 'c07', 'c08', 'c09', 'c10', 'c11', 'c12', 'c13', 'c14',
    's06', 's07', 's08', 's09', 's10', 's11', 's12', 's13', 's14'
];

export const getCard = (code: string): [string, number] => {
    const cardData = code.match(/(\a)(\d+)/);
    if (!cardData) return ['_', -1];
    return [cardData?.[1] || '_', +cardData?.[2] || -1];
};

// python is shit
export const isCardAllowed = (tableSlot: Array<string>, card: string, slot: number, trumpCard: string): [boolean, string] => {
    if (!tableSlot?.[1]) return [true, 'OK_FIRST_CARD'];
    const [ trumpType ] = getCard(trumpCard);
    const [ targetType, targetNumber ] = getCard(tableSlot[1]);
    const [ cardType, cardNumber ] = getCard(card);
    if ( (cardType == targetType && cardNumber > targetNumber) || (cardType == trumpType) ) return [true, 'OK_POWER_CONFIRMED'];
    return [false, 'UNKNOWN'];
};

export const processCardThrow = (room: Room, card: ThrowCard) => {
    console.log(`isTableClear ${isTableClear(room.table)}`)
    const table = room.table;
    if (room.activePlayer?.name == card.username || card.username == 'chapo') {
        return isTableClear(table) || isCardOnTable(table, card.card);
    } else if (room.beatPlayer?.name == card.username) {

        

        // return isCardAllowed(table, card.card, card.slotId, room.trumpCard);
    };
    return false
};

export const isCardOnTable = (table: Array<Array<string>>, card: string): boolean => {
    const [ cardType, cardNumber ] = getCard(card);
    return table.every( (slot) => {
        slot.every( slotCard => {
            const [ tType, tNumber ] = getCard(slotCard);
            return cardNumber == tNumber;
        });
    });
};

export const isTableClear = (table: Array<Array<string>>): boolean => table.every(a => a.length === 0);
export const getReadyPlayers = (room: Room): number => {
    let count = 0;
    for (const player of room.players) if (player.ready) count ++;
    return count;
};