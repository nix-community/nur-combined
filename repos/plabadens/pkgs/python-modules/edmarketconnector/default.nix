{ stdenv, lib, buildPythonApplication, fetchFromGitHub, python }:

buildPythonApplication rec {
  pname = "EDMarketConnector";
  version = "4.2.7";
  
  format="other";

  src = fetchFromGitHub {
    owner = "EDCD";
    repo = pname;
    rev = "Release/${version}";
    sha256 = "sha256-YAA06yf2/IDrzOzXV5uMMf1kPhB/RpkK7B2qoK5bNd8=";
  };

  doCheck = false;

  propagatedBuildInputs = with python.pkgs; [
    certifi
    requests
    watchdog
    semantic-version
    tkinter
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r * $out/share

    mkdir -p $out/bin
    makeWrapper $out/share/EDMarketConnector.py $out/bin/EDMarketConnector \
        --prefix PATH ':' "$program_PATH" \
        --set PYTHONPATH "$PYTHONPATH"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/EDCD/EDMarketConnector";
    description = "Downloads commodity market and other station data from the game Elite: Dangerous for use with all popular online and offline trading tools.";
    license = licenses.gpl2Only;
  };
}
