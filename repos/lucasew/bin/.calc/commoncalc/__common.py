commands = dict()


def define_command():
    """
    Decorator factory to register a function as a command.

    The decorated function is added to the global `commands` dictionary,
    making it available in the REPL environment.
    """

    def define_command_wrapped(func):
        commands[func.__name__] = func
        return func

    return define_command_wrapped


@define_command()
def repl(*args):
    """
    Starts the Read-Eval-Print Loop (REPL).

    If arguments are provided, they are executed as Python code using `exec()`
    before starting the interactive session.

    Enables tab completion and inherits the current globals and registered commands.
    """
    for arg in args:
        exec(arg)
    import readline
    from code import InteractiveConsole

    readline.parse_and_bind("tab: complete")
    InteractiveConsole({**globals(), **commands}).interact()


@define_command()
def cmds():
    """
    Lists all registered commands and their docstrings.

    Useful for discovering available functionality within the REPL.
    """
    commands_names = list(commands.keys())
    commands_names.sort()
    biggest_command_name = max(*[len(c) for c in commands_names])
    for command in commands_names:
        print(
            command.ljust(biggest_command_name + 2, " "),
            commands[command].__doc__ or "(no description)",
        )


define_command()(define_command)
