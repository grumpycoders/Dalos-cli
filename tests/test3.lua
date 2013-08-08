function test3()
    print "testing rsa"
    local bits = 2048
    local e = 65537
    local key = rsa:gen_key(bits, 65537)
    --for k, v in pairs(key) do print(k.."=lcrypt.bigint(lcrypt.fromhex('"..lcrypt.tohex(tostring(v)).."'))") end

    msg = lcrypt.random(bits/8 - 1)
    s = rsa:sign_oaep(msg, 'jello', key)
    if rsa:verify_oaep(s, msg, 'jello', key) then
        print "ok"
    else
        --for k, v in pairs(key) do print(k.."=lcrypt.bigint(lcrypt.fromhex('"..lcrypt.tohex(tostring(v)).."'))") end
        error "rsa failure"
    end
end
    