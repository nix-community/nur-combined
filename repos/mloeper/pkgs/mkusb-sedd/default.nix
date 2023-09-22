{ lib, stdenv, pkgs, fetchFromGitHub, callPackage, ... }:

let
  src = fetchFromGitHub
    {
      owner = "sudodus";
      repo = "tarballs";
      rev = "93b43c208e902d0f8064b3b0abf461765b273a53";
      sha256 = "sha256-FcI/GKLjhIN0YxXNxE6bagGyQ7o9SwtHfIonrXc4EkE=";
    };
  xorriso = (callPackage ./../xorriso {});
in
stdenv.mkDerivation {
    pname = "mkusb-sedd";
    version = "2.8.7";
    inherit src;

    nativeBuildInputs = with pkgs; [ makeWrapper ];

    unpackPhase = ":";
    installPhase = ''
      install -d $out/bin
      tar -xvzf $src/mkusb-plug-plus-tools.tar.gz
      cp plug-dir/mkusb-sedd $out/bin/.mkusb-sedd-wrapped
      runHook postInstall
    '';
    postInstall = ''
      substituteInPlace "$out/bin/.mkusb-sedd-wrapped" \
        --replace "/bin/echo" "echo" \
        --replace "/usr/bin/" "" \
        --replace "exitnr=\$?" "exitnr=0"

      makeWrapper "$out/bin/.mkusb-sedd-wrapped" "$out/bin/mkusb-sedd" \
        --inherit-argv0 \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.pv
          xorriso
          pkgs.exfatprogs
          pkgs.expect
          pkgs.util-linux
        ]}
    '';

    meta = with lib; {
      homepage = "https://help.ubuntu.com/community/mkusb/";
      description = "Create standard cloned live and installer drives and also persistent live drives";
      license = licenses.gpl3Only;
      platforms = [ "x86_64-linux" ];
      mainProgram = "mkusb-sedd";
    };
  }

