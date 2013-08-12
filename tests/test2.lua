function test2()
    local i = Input.new "tests/test1.lua"
    i:open()
    i:close()
    i:destroy()

    i = Input.new "tests/test1.lua"
    i:open()
    i = nil

    collectgarbage()

    i = Input.new "tests/file.bin"
    i:open()
    print(i:readU8())
    print(i:readU16())
    print(i:readU32())
    print(i:readU64())
    i:destroy()
end
