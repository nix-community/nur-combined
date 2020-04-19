{ stdenv
, darwin
, sources }:

let
  inherit (stdenv.lib) substring;
  src = sources.yabai;
in

stdenv.mkDerivation rec {
  pname   = "yabai";
  version = substring 0 7 src.rev;

  inherit src;

  buildInputs = with darwin.apple_sdk.frameworks; [
    Carbon Cocoa CoreServices IOKit ScriptingBridge
  ];

  installPhase = ''
    install -d $out/bin
    cp bin/yabai $out/bin
  '';

  meta = with stdenv.lib; {
    inherit (src) description;
    homepage  = https://github.com/koekeishiya/yabai;
    platforms = platforms.darwin;
    license   = licenses.mit;
  };
}
