Resource = {}

Resource.card = {
    d = {
        [1] = { img = nil, base85 = ''},
        [2] = { img = nil, base85 = ''},
        [3] = { img = nil, base85 = ''},
        [4] = { img = nil, base85 = ''},
        [5] = { img = nil, base85 = ''},
        [6] = { img = nil, base85 = ''},
        [7] = { img = nil, base85 = ''},
        [8] = { img = nil, base85 = ''},
        [9] = { img = nil, base85 = ''},
        [10] = { img = nil, base85 = ''},
        [11] = { img = nil, base85 = ''},
        [12] = { img = nil, base85 = ''},
        [13] = { img = nil, base85 = ''},
        [14] = { img = nil, base85 = ''}
    },
    h = {
        [1] = { img = nil, base85 = ''},
        [2] = { img = nil, base85 = ''},
        [3] = { img = nil, base85 = ''},
        [4] = { img = nil, base85 = ''},
        [5] = { img = nil, base85 = ''},
        [6] = { img = nil, base85 = ''},
        [7] = { img = nil, base85 = ''},
        [8] = { img = nil, base85 = ''},
        [9] = { img = nil, base85 = ''},
        [10] = { img = nil, base85 = ''},
        [11] = { img = nil, base85 = ''},
        [12] = { img = nil, base85 = ''},
        [13] = { img = nil, base85 = ''},
        [14] = { img = nil, base85 = ''}
    },
    s = {
        [1] = { img = nil, base85 = ''},
        [2] = { img = nil, base85 = ''},
        [3] = { img = nil, base85 = ''},
        [4] = { img = nil, base85 = ''},
        [5] = { img = nil, base85 = ''},
        [6] = { img = nil, base85 = ''},
        [7] = { img = nil, base85 = ''},
        [8] = { img = nil, base85 = ''},
        [9] = { img = nil, base85 = ''},
        [10] = { img = nil, base85 = ''},
        [11] = { img = nil, base85 = ''},
        [12] = { img = nil, base85 = ''},
        [13] = { img = nil, base85 = ''},
        [14] = { img = nil, base85 = ''}
    },
    c = {
        [1] = { img = nil, base85 = ''},
        [2] = { img = nil, base85 = ''},
        [3] = { img = nil, base85 = ''},
        [4] = { img = nil, base85 = ''},
        [5] = { img = nil, base85 = ''},
        [6] = { img = nil, base85 = ''},
        [7] = { img = nil, base85 = ''},
        [8] = { img = nil, base85 = ''},
        [9] = { img = nil, base85 = ''},
        [10] = { img = nil, base85 = ''},
        [11] = { img = nil, base85 = ''},
        [12] = { img = nil, base85 = ''},
        [13] = { img = nil, base85 = ''},
        [14] = { img = nil, base85 = ''}
    }
}

function Resource.loadCards()
    for type, list in ipairs(Resource) do
        for index, data in pairs(list) do
            Resource[type][index].img = 'createfrom(data.base85)'
        end
    end
end

return Resource