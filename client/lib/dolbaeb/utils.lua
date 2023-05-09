Utils = {}

local imgui = require('mimgui')

---@param path string directory
---@param ftype string|string[] file extension
---@return string[] files names
function Utils.getFilesInPath(path, ftype)
    assert(path, '"path" is required');
    assert(type(ftype) == 'table' or type(ftype) == 'string', '"ftyp" must be a string or array of strings');
    local result = {};
    for _, thisType in ipairs(type(ftype) == 'table' and ftype or { ftype }) do
        local searchHandle, file = findFirstFile(path.."\""..thisType);
        table.insert(result, file)
        while file do file = findNextFile(searchHandle) table.insert(result, file) end
    end
    return result;
end

function Utils.ItemSelector(name, items, selected, fixedSize, dontDrawBorders)
    assert(items and #items > 1, 'items must be array of strings');
    assert(selected[0], 'Wrong argument #3. Selected must be "imgui.new.int"');
    local DL = imgui.GetWindowDrawList();
    local style = {
        rounding = imgui.GetStyle().FrameRounding,
        padding = imgui.GetStyle().FramePadding,
        col = {
            default = imgui.GetStyle().Colors[imgui.Col.Button],
            hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered],
            active = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
            text = imgui.GetStyle().Colors[imgui.Col.Text]
        }
    };
    local pos = imgui.GetCursorScreenPos();
    local start = pos;
    local maxSize = 0;
    for index, item in ipairs(items) do
        local textSize = imgui.CalcTextSize(item);
        local sizeX = (fixedSize or textSize.x) + style.padding.x * 2;
        imgui.SetCursorScreenPos(pos);
        if imgui.InvisibleButton('##imguiSelector_'..item..'_'..tostring(index), imgui.ImVec2(sizeX, textSize.y + style.padding.y * 2)) then
            local old = selected[0];
            selected[0] = index;
            return selected[0], old;
        end
        DL:AddRectFilled(
            pos,
            imgui.ImVec2(pos.x + sizeX, pos.y + textSize.y + style.padding.y * 2),
            imgui.GetColorU32Vec4((selected[0] == index or imgui.IsItemActive()) and style.col.active or (imgui.IsItemHovered() and style.col.hovered or style.col.default)),
            style.rounding,
            (index == 1 and 5 or (index == #items and 10 or 0))
        );
        if index > 1 and not dontDrawBorders then DL:AddLine(imgui.ImVec2(pos.x, pos.y + style.padding.y), imgui.ImVec2(pos.x, pos.y + textSize.y + style.padding.y), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Border]), 1) end
        DL:AddText(imgui.ImVec2(pos.x + sizeX / 2 - textSize.x / 2, pos.y + style.padding.y), imgui.GetColorU32Vec4(style.col.text), item);
        pos = imgui.ImVec2(pos.x + sizeX, pos.y);
    end
    DL:AddRect(start, imgui.ImVec2(pos.x, pos.y + imgui.CalcTextSize('A').y + style.padding.y * 2), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.Border]), imgui.GetStyle().FrameRounding, nil, imgui.GetStyle().FrameBorderSize);
    DL:AddText(imgui.ImVec2(pos.x + style.padding.x, pos.y + (imgui.CalcTextSize(name).y + style.padding.y * 2) / 2 - imgui.CalcTextSize(name).y / 2), imgui.GetColorU32Vec4(style.col.text), name);
end

return Utils