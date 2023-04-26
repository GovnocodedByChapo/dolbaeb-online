Resource = { 
    cards = {
        img = nil,
        file = getWorkingDirectory()..'\\lib\\dolbaeb\\cards.png',
        base85 = '',
        useCustomImage = false,
        background = nil,
        backgroundFile = getWorkingDirectory()..'\\lib\\dolbaeb\\cardBack.png'
    },
    emoji = {
        img = nil,
        file = getWorkingDirectory()..'\\lib\\dolbaeb\\emoji.png',
        base85 = '',
        useCustomImage = false
    }
}
local imgui = require('mimgui')
local oneCard = imgui.ImVec2(1 / 9, 1 / 4)

function Resource.init()
    --// Cards
    Resource.cards.useCustomImage = doesFileExist(Resource.cards.file)
    Resource.cards.img = imgui.CreateTextureFromFile(Resource.cards.file)--Resource.useCustomImage and imgui.CreateTextureFromFile(Resource.cards.file) or imgui.CreateTextureFromFileInMemory(imgui.new('const char*', Resource.cards.base85), #Resource.cards.base85)

    Resource.cards.background = imgui.CreateTextureFromFile(Resource.cards.backgroundFile)

    --// Emojis
    Resource.emoji.useCustomImage = doesFileExist(Resource.emoji.file)
    Resource.emoji.img =  imgui.CreateTextureFromFile(Resource.emoji.file)-- Resource.useCustomImage and imgui.CreateTextureFromFile(Resource.emoji.file) or imgui.CreateTextureFromFileInMemory(imgui.new('const char*', Resource.emoji.base85), #Resource.emoji.base85)
end

function Resource.getEmojiUV(index)
    local one = 1 / 25
    return imgui.ImVec2(one * index, 0), imgui.ImVec2(one * index + one, 1)
end

function Resource.getCardUV(code)
    local cardType, cardNumber = code:match('(%a)(%d+)')
    local lines = {
        h = 1, -- Hearts (Черви / Сердца)
        s = 2, -- Diamonds (Бубы / Алмазы)
        d = 3, -- Clubs (Трефы / Клубы)
        c = 4  -- Spades (Пики / Лопаты)
    }
    cardType = lines[tonumber(cardType) or 1] or 1
    cardNumber = (tonumber(cardNumber) or 1) - 6
    return imgui.ImVec2(oneCard.x * cardNumber, oneCard.y * cardType - oneCard.y), imgui.ImVec2(oneCard.x * cardNumber + oneCard.x, oneCard.y * cardType)
end

function Resource.card(code, size, ...)
    return imgui.ImageButton(Resource.cards.img, size, imgui.ImVec2(0, 0), Resource.getCardUV(code), ...)
end



function Resource.cardButton(code, size, ...)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(0, 0))
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0))
    local button = imgui.ImageButton(Resource.cards.img, size, Resource.getCardUV(code))
    imgui.PopStyleVar(2)
    imgui.PopStyleColor(3)
    return button
end

return Resource
