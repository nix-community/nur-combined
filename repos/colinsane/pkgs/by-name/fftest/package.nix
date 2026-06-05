{
  linkBinIntoOwnPackage,
  linuxConsoleTools,
}: linkBinIntoOwnPackage linuxConsoleTools "fftest"
#
# XXX(2025-03-24): upstream `linuxConsoleTools` depends on SDL, which doesn't cross compile.
# but `fftest` component doesn't use SDL, so if we build only that then it can cross compile:
# linuxConsoleTools.overrideAttrs (upstream: {
#   buildInputs = [ ];  #< disable SDL
#   buildFlags = (upstream.buildFlags or []) ++ [
#     "-C" "utils" "fftest"
#   ];

#   installPhase = ''
#     install -Dm755 utils/fftest $out/bin/fftest
#     install -Dm644 docs/fftest.1 $out/share/man/man1/fftest.1
#   '';
# })
