{ fetchurl, stdenv }:

let
  version = "0.4.10";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/qier222/YesPlayMusic/releases/download/v0.4.10/YesPlayMusic-0.4.10.AppImage";
      hash = "sha256-Qj9ZQbHqzKX2QBlXWtey/j/4PqrCJCObdvOans79KW4=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw ("unsupported system " + stdenv.hostPlatform.system));
  src = fetchurl (
    source
    // {
      curlOptsList = [ "--compressed" ];
    }
  );
in
{
  inherit version src;
}
