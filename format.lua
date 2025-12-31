function conky_space_units(arg)
    if arg == nil or arg == '' then return '' end
    local val = conky_parse('${' .. arg .. '}')
    if val == nil or val == '' then return '' end
    return string.gsub(val, '([%d,%.]+)([KMGTPEkmgtpe]i?[Bb])', '%1 %2')
end
