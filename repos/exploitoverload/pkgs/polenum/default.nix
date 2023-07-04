{ lib, fetchFromGitHub, makeWrapper, python3 }:

let 
  pyenv = python3.withPackages (pp: with pp;[
    impacket
  ]);

in

  python3.pkgs.buildPythonApplication rec {
    pname = "polenum";
    version = "1.6.1";
    format = "other";

    src = fetchFromGitHub {
      owner = "Wh1t3Fox";
      repo = "polenum";
      rev = "refs/tags/${version}";
      hash = "sha256-zBgBcPokvXGC1UeLFlAK5OEbjjcPPWRrFzjydWkSLz8=";
    };
    nativeBuildInputs = [
      makeWrapper
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/bin $out/share/${pname}

      cp -R . $out/share/${pname}

      makeWrapper ${pyenv.interpreter} $out/bin/polenum \
        --add-flags "$out/share/${pname}/polenum.py"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Uses Core's Impacket Library to get the password policy from a windows machine ";
      homepage = "https://github.com/Wh1t3Fox/polenum";
      mainProgram = "polenum";
      license = licenses.gpl3Only;
      platforms = platforms.unix;
    };
  }
