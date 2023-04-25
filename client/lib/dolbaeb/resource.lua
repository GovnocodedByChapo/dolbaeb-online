Resource = { 
    img = nil
}
local imgui = require('mimgui')
local oneCard = imgui.ImVec2(1 / 9, 1 / 4)

function Resource.init()
    Resource.img = imgui.CreateTextureFromFile(getWorkingDirectory()..'\\lib\\dolbaeb\\cards.png')
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
    return imgui.ImageButton(Resource.img, size, imgui.ImVec2(0, 0), Resource.getCardUV(code), ...)
end

return Resource
