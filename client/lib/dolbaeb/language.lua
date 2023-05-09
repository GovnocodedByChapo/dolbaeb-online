Language = {
    path = getWorkingDirectory()..'\\lib\\dolbaeb\\lang'
}

local utils = require('lib.dolbaeb.utils')

function Language.getList()
    return utils.getFilesInPath(Language.path, '*.json')
end

function Language.loadLanguage(code)
    assert(code, 'Language code not provided')
    local langPath, tags = Language.path..'\\'..code..'.json', nil
    if doesFileExist(langPath) then
        local file = io.open(langPath, 'r')
        if file then
            local json = file:read('*a')
            file:close()

            local status, decoded = pcall(decodeJson, json)
            if status and decoded then
                tags = decoded
            end
        end
    end
    return function(tag)
        return tags and tags[tag] or tag
    end
end

return Language