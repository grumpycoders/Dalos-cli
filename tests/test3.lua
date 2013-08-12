function test3()
    local x = BigInt.new "1234"
    local y = BigInt.new "5678"
    local z = x + y
    if tostring(z) ~= "6912" then error "bigint1" end
    -- unlike PHP, Lua is smarter. An object and a number aren't the same things, thus aren't equal.
    if z == 6912 then error "bigint2" end
    -- this is the proper comparison.
    if z ~= BigInt.new(6912) then error "bigint3" end
end
