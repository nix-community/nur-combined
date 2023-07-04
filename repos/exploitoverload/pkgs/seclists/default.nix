{ lib, stdenv, makeWrapper, fetchFromGitHub, python3 }:

stdenv.mkDerivation rec {
    pname = "seclists";
    version = "2023.2";

    src = fetchFromGitHub {
      owner = "danielmiessler";
      repo = "SecLists";
      rev = "refs/tags/${version}";
      hash = "sha256-yVxb5GaQDuCsyjIV+oZzNUEFoq6gMPeaIeQviwGdAgY=";
    };

    dontBuild = true;

    nativeBuildInputs = [
      makeWrapper
      python3
    ];

    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/bin $out/share/${pname}

      cp -r . $out/share/${pname}

      cp --no-preserve=mode,ownership,timestamps ${./seclists.py} $out/share/${pname}/seclists.py

      substituteInPlace $out/share/${pname}/seclists.py --replace "<PATH>" "$out/share/${pname}"

      tar -xvzf $out/share/${pname}/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C $out/share/${pname}/Passwords/Leaked-Databases

      rm $out/share/${pname}/Passwords/Leaked-Databases/rockyou.txt.tar.gz

      makeWrapper ${python3.interpreter} $out/bin/seclists --add-flags "$out/share/${pname}/seclists.py"

      runHook postInstall
    '';

    meta = with lib; {
      description = "SecLists is the security tester's companion. It's a collection of multiple types of lists used during security assessments, collected in one place. List types include usernames, passwords, URLs, sensitive data patterns, fuzzing payloads, web shells, and many more.";
      homepage = "https://github.com/danielmiessler/SecLists";
      platforms = platforms.unix;
      license = licenses.mit;
    };
  }
