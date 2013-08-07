function test2()
    local i = Input.new "tests/test1.lua"
    i:open()
    i:close()
    i:destroy()

    i = Input.new "tests/test1.lua"
    i = nil

    collectgarbage()
end
