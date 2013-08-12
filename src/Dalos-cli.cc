#include <getopt.h>
#include <Main.h>
#include <TaskMan.h>
#include <LuaTask.h>
#include <Input.h>
#include <BStdIO.h>
#include <LuaBigInt.h>
#include <LuaHandle.h>
#include "BReadline.h"
#include "LuaLoad.h"

using namespace Balau;

int getopt_flag = 0;

struct option long_options[] = {
    { "help",           0, NULL, 'h' },
    { "verbose",        0, NULL, 'v' },
    { "exec",           1, NULL, 'e' },
    { "interactive",    0, NULL, 'i' },
    { NULL,             0, NULL,  0  },
};

static void showhelp(const char * binname, bool longhelp) {
    Printer::print(
"Usage:\n"
"%s [options] [lua-script-1] [lua-script-2] ...\n"
"\n"
"Options:\n"
"  -v           for verbose mode\n"
"  -e <command> executes that command\n"
"  -i           interactive mode\n"
"  -h           help page\n"
, binname);

    if (longhelp)
        Printer::print(
"\n"
);
}

namespace {

class DalosInit : public LuaExecCell {
    virtual void run(Lua & L) override {
        registerLuaLoad(L);
        registerLuaBigInt(L);
        registerLuaHandle(L);
    }
};

};

void MainTask::Do() {
    std::list<String> execs;
    bool interactive = false;
    bool todo = false;
    bool error = false;
    char c;

    Printer::log(M_STATUS, "Dalos-cli starting");

    LuaMainTask * luaMainTask = TaskMan::registerTask(new LuaMainTask);

    while ((c = getopt_long(argc, argv, "Hhve:i", long_options, NULL)) != EOF) {
        switch (c) {
        case 'h':
        case 'H':
        case '?':
            showhelp(argv[0], true);
            return;
        case 'v':
            Printer::enable(M_ALL);
            break;
        case 'e':
            execs.push_back(optarg);
            break;
        case 'i':
            interactive = true;
            break;
        default:
            showhelp(argv[0], false);
            return;
        }
    }

    {
        DalosInit dalosInit;
        dalosInit.exec(luaMainTask);
        dalosInit.throwError();
    }

    while (optind < argc) {
        todo = true;
        IO<Input> file(new Input(argv[optind++]));
        file->open();
        LuaExecFile luaExecFile(file);
        luaExecFile.exec(luaMainTask);
        luaExecFile.throwError();
    }

    for (auto & exec : execs) {
        todo = true;
        LuaExecString luaExecString(exec);
        luaExecString.exec(luaMainTask);
        luaExecString.throwError();
    }

    if (!todo && !interactive)
        showhelp(argv[0], false);

    if (!interactive)
        return;

    String line_read;
    Readline rl("Dalos-cli", new StdIN());

    for (;;) {
        line_read = rl.gets();

        if (rl.gotEOF()) {
            Printer::print("\n");
            break;
        }

        LuaExecString luaExecString(line_read);
        luaExecString.exec(luaMainTask);
        try {
            luaExecString.throwError();
        }
        catch (GeneralException & e) {
            const char * details = e.getDetails();
            if (details)
                Printer::log(M_WARNING, "  %s", details);
            auto trace = e.getTrace();
            for (String & str : trace)
                Printer::log(M_DEBUG, "%s", str.to_charp());
        }
    }
}
