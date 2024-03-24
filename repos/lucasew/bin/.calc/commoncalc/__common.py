commands = dict()

def define_command():
    "Defines a function as a new cmd"
    def define_command_wrapped(func):
        commands[func.__name__] = func
        return func
    return define_command_wrapped

@define_command()
def repl(*args):
    "Read eval print loop, standard stuff"
    for arg in args:
        exec(arg)
    import readline, rlcompleter
    from code import InteractiveConsole
    readline.parse_and_bind("tab: complete")
    InteractiveConsole({
        **globals(),
        **commands
    }).interact()

@define_command()
def cmds():
    "List the cmds defined"
    commands_names = list(commands.keys())
    commands_names.sort()
    biggest_command_name = max(*[len(c) for c in commands_names])
    for command in commands_names:
        print(command.ljust(biggest_command_name + 2, ' '), commands[command].__doc__ or "(no description)")

define_command()(define_command)

