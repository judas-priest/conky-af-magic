--[[
    Conky AF-Magic - Format utilities
    Colors units (B, KiB, MiB, GiB, etc.) with color6 (gray)
]]

function conky_color_units(arg)
    if arg == nil or arg == '' then return '' end
    local val = conky_parse('${' .. arg .. '}')
    if val == nil or val == '' then return '' end
    return string.gsub(val, '([%d,%.]+)([KMGTPEkmgtpe]?i?[Bb]/?s?)', '%1${color6}%2${color}')
end
