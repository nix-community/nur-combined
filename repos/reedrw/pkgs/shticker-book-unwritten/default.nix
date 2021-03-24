{ buildFHSUserEnv, fetchFromGitHub, lib, openssl, pkg-config, rustPlatform, stdenvNoCC }:
let
  pname = "shticker-book-unwritten";
  version = "1.0.3";

  shticker-book-unwritten-unwrapped = rustPlatform.buildRustPackage rec {
    inherit pname version;

    src = fetchFromGitHub (lib.importJSON ./source.json);

    cargoPatches = [ ./cargo-lock.patch ];
    cargoSha256 = "1lnhdr8mri1ns9lxj6aks4vs2v4fvg7mcriwzwj78inpi1l0xqk5";

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [ openssl ];
  };

  env = buildFHSUserEnv {
    name = "${pname}-env-${version}";
    targetPkgs = pkgs: with pkgs; [
      alsaLib
      xorg.libX11
      xorg.libXext
      libglvnd
      shticker-book-unwritten-unwrapped
    ];
    runScript = "shticker_book_unwritten";
  };

in stdenvNoCC.mkDerivation rec {
  inherit pname version;

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
