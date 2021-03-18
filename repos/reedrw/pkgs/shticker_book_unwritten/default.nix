{ alsaLib, buildFHSUserEnv, fetchFromGitHub, lib, libX11, libXext, libglvnd, openssl, pkg-config, rustPlatform, stdenvNoCC }:
let
  version = "1.0.3";

  shticker-book-unwritten-unwrapped = rustPlatform.buildRustPackage rec {
    pname = "shticker_book_unwritten";
    inherit version;

    src = fetchFromGitHub (lib.importJSON ./source.json);

    cargoPatches = [ ./cargo-lock.patch ];
    cargoSha256 = "1lcz96fixa0m39y64cjkf2ipzv4qxf000hji3mf536scr3wsxdib";

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [ openssl ];
  };

  env = buildFHSUserEnv {
    name = "shticker-book-unwriten-env-${version}";
    targetPkgs = _: [
      alsaLib
      libX11
      libXext
      libglvnd
      shticker-book-unwritten-unwrapped
    ];
    runScript = "shticker_book_unwritten";
  };

in stdenvNoCC.mkDerivation rec {
  pname = "shticker_book_unwritten";
  inherit version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${env}/bin/* $out/bin/shticker_book_unwritten
  '';

  meta = with lib; {
    description = "Minimal CLI launcher for the Toontown Rewritten MMORPG";
    homepage = "https://github.com/JonathanHelianthicusDoe/shticker_book_unwritten";
    license = licenses.gpl3Plus;
  };
}
