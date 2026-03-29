{
  __snappy-topology,
  lib,
  writeShellScriptBin,
  sage,
}:

(writeShellScriptBin "SnapPy" ''
  exec ${lib.getExe sage} --python -c 'import sys; from snappy.app import main; sys.exit(main())'
'')
// {
  inherit (__snappy-topology) meta;
}
