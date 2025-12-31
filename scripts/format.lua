-- Add space before unit suffix (GiB, MiB, KiB, B, G, M, K)
function conky_space_unit(val)
    if val == nil then return '' end
    return string.gsub(val, '([%d%.%,])([A-Za-z])', '%1 %2')
end
