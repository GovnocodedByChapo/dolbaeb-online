Language = {
    path = getWorkingDirectory()..'\\lib\\dolbaeb\\lang'
}

local utils = require('lib.dolbaeb.utils')

function Language.loadLanguage(code)
    local list = utils.getFilesInPath(Language.path, '*.json')
    local tags = {}
    for _, name in ipairs(list) do
        if name == code then
            local F = io.open(Language.path..'\\'..name, 'r')
            if F then
                local fileContent = F:read('*a')
                F:close()
                local status, json = pcall(decodeJson, fileContent)
                if status and json ~= nil then
                    tags = json
                end
            end
            break
        end
    end
    return function(tag)
        return tags[tag] or 'E:'..tag
    end
end

return Language