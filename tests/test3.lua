function test3()
    local x = BigInt.new "1234"
    local y = BigInt.new "5678"
    local z = x + y
    if tostring(z) ~= "6912" then error "bigint1" end
    -- unlike PHP, Lua is smarter. An object and a number aren't the same things, thus aren't equal.
    if z == 6912 then error "bigint2" end
    -- this is the proper comparison.
    if z ~= BigInt.new(6912) then error "bigint3" end

    x = BigInt.new "2570928358736459287364501827645832746923875623845"
    y = BigInt.new "52934875203984750192837512983750192582348756"
    local m = BigInt.new "6971908475092834619032845610238976458374561729345017823461297384"
    z = x:modpow(y, m)
    if tostring(z) ~= "2205750725547192694097770347478670564947020421824213327486286017" then error "bigint4" end
end
