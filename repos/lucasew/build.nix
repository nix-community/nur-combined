with builtins;
with (getFlake (toString ./.)).outputs;
with packages;
[
  python3Packages.scikitlearn
  stremio
  cisco-packet-tracer
  minecraft
  peazip
  pinball
  stremio
  ets2
]
