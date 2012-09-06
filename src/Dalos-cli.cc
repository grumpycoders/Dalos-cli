#include <getopt.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <Main.h>
#include <TaskMan.h>
#include <LuaTask.h>
#include <Input.h>

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

void MainTask::Do() {
    std::vector<String> execs;
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

    while (optind < argc) {
        todo = true;
        IO<Input> file(new Input(argv[optind++]));
        LuaExecFile luaExecFile(file);
        luaExecFile.exec(luaMainTask);
        if (luaExecFile.gotError())
            return;
    }

    for (auto & exec : execs) {
        todo = true;
        LuaExecString luaExecString(exec);
        luaExecString.exec(luaMainTask);
        if (luaExecString.gotError())
            return;
    }

    if (!todo && !interactive)
        showhelp(argv[0], false);

    if (!interactive)
        return;

    char prompt[3] = "> ", * line_read = NULL;

    for (;;) {
        if (line_read)
            free(line_read);

        line_read = readline(prompt);

        if (!line_read) {
            Printer::print("\n");
            break;
        }

        if (*line_read)
            add_history(line_read);

        String line = line_read;

        LuaExecString luaExecString(line);
        luaExecString.exec(luaMainTask);
    }
}
