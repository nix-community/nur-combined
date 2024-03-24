from .__common import commands, cmds
from sys import argv

args = [*argv[1:]]
if len(args) == 0:
    args.append('repl')
cmd = args[0]
args = args[1:]

if cmd not in commands:
    cmds()
    exit(1)

print(commands[cmd](*args))
