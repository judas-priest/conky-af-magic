function conky_space_unit(arg)
    local val = conky_parse(arg)
    if val == nil or val == '' then
        return ''
    end
    return string.gsub(val, '([%d%.%,])([A-Za-z])', '%1 %2')
end
