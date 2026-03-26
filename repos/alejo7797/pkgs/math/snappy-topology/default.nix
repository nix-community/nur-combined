{
  sage,
  lib,
  writeShellScriptBin,
}:

writeShellScriptBin "SnapPy" ''
  exec ${lib.getExe sage} --python -c 'import sys; from snappy.app import main; sys.exit(main())'
''
