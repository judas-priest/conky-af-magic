--[[
    Conky AF-Magic - Format utilities
]]

-- Battery bar color based on status
-- Discharging = green, Full = gray, Charging = orange
function conky_battery_color()
    local status = conky_parse('${battery_status}')
    if status == nil then status = '' end
    status = status:gsub('%s+', '')  -- trim whitespace
    if status == "Full" or status == "Not charging" then
        return "${color6}"
    elseif status == "Discharging" then
        return "${color2}"
    else
        return "${color3}"
    end
end

-- Returns only the number, strips unit
function conky_val(arg)
    if arg == nil or arg == '' then return '' end
    -- Replace : with space for multi-arg vars like top_mem:mem_res:1
    arg = string.gsub(arg, ':', ' ')
    local val = conky_parse('${' .. arg .. '}')
    if val == nil or val == '' then return '' end
    return string.gsub(val, '([%d,%.]+)[KMGTPEkmgtpe]?i?[Bb]/?s?', '%1')
end

-- Returns number + space + short unit (G, M, K)
function conky_unit(arg)
    if arg == nil or arg == '' then return '' end
    -- Replace : with space for multi-arg vars like top_mem:mem_res:1
    arg = string.gsub(arg, ':', ' ')
    local val = conky_parse('${' .. arg .. '}')
    if val == nil or val == '' then return '' end
    -- Extract number and unit, shorten unit
    local num, unit = string.match(val, '([%d,%.]+)([KMGTPEkmgtpe]?i?[Bb]/?s?)')
    if num == nil then return val end
    if unit == nil or unit == '' then return num end
    -- Shorten: GiB -> G, MiB -> M, KiB -> K, B -> B
    local short = string.upper(string.sub(unit, 1, 1))
    if short == 'B' then short = 'B' end
    -- Keep /s for speeds
    if string.match(unit, '/s') then short = short .. '/s' end
    return num .. ' ' .. short
end
