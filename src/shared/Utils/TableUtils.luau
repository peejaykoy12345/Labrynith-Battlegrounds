local TableUtils = {}

function TableUtils:ArrayFindIndexOfValue(table, value): number?
    local index: number?
    for i, v in ipairs(table) do
        if v == value then
            index = i
            break
        end
    end
    return index
end

function TableUtils:ArrayRemove(array, value)
    local index_to_remove = self:ArrayFindIndexOfValue(array, value)
    if index_to_remove then
        table.remove(array, index_to_remove)
    end
end

return TableUtils