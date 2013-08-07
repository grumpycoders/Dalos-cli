function test2()
    local i = Input.new "tests/test1.lua"
    i:open()
    i:close()
    i:destroy()

    i = Input.new "tests/test1.lua"
    i:open()
    i = nil

    collectgarbage()

    i = Input.new "tests/test1.lua"
    i:open()
    print(i:readU8())
    i:destroy()
end
