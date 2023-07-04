{ lib, fetchFromGitHub, makeWrapper, python3, stdenv }:

python3.pkgs.buildPythonApplication rec {
  pname = "psudohash";
  version = "2d586dec8b5836546ae54b924eb59952a7ee393c";
  format = "other";

  src = fetchFromGitHub {
    owner = "t3l3machus";
    repo = "psudohash";
    rev = "2d586dec8b5836546ae54b924eb59952a7ee393c";
    hash = "sha256-l/Rp9405Wf6vh85PFrRTtTLJE7GPODowseNqEw42J18=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share/${pname}

    cp -r . $out/share/${pname}

    makeWrapper ${python3.interpreter} $out/bin/psudohash --add-flags "$out/share/${pname}/psudohash.py"

    substituteInPlace $out/share/${pname}/psudohash.py --replace "common_padding_values.txt" "$out/share/${pname}/common_padding_values.txt"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Psudohash is a password list generator for orchestrating brute force attacks and cracking hashes.";
    homepage = "https://github.com/t3l3machus/psudohash";
    mainProgram = "psudohash";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
