#include <Main.h>
#include <TaskMan.h>
#include <LuaTask.h>

using namespace Balau;

void MainTask::Do() {
    Printer::log(M_STATUS, "Dalos-cli starting");

    LuaMainTask * luaMainTask = createTask(new LuaMainTask);
    LuaExecString luaExecString("print 'foo'");
    luaExecString.exec(luaMainTask);
}
