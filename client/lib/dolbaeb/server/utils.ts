export const getRandomInt = (max: number): number => Math.floor(Math.random() * max);
export const shuffle = (array: Array<any>): Array<any> => {
    let currentIndex = array.length,  randomIndex;
    while (currentIndex != 0) {
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex--;
        [array[currentIndex], array[randomIndex]] = [
        array[randomIndex], array[currentIndex]];
    }
    return array;
};