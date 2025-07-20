# see comments in update.nix
import sys, pathlib
nixpkgsPath = sys.argv.pop(1)
realUpdate = sys.argv.pop(1)
with open(realUpdate, 'r') as f:
	realUpdateCode = f.read()
shellPath = pathlib.Path(nixpkgsPath).resolve()/'shell.nix'
updateCode = realUpdateCode.replace('nixpkgs_root + "/shell.nix"', repr(str(shellPath)))
updateCompiled = compile(updateCode, realUpdate, 'exec')
exec(updateCompiled)
