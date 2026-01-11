{ lib
, stdenv
, fetchFromGitHub
, python3
, makeWrapper
}:

let
  py = python3.withPackages (ps: with ps; [
    pillow
    pyserial
    tkinter
  ]);
in
stdenv.mkDerivation rec {
  pname = "open-battery-information";
  version = "unstable-2025-11-07";

  src = fetchFromGitHub {
    owner = "mnh-jansson";
    repo = "open-battery-information";
    rev = "f05da07d4e60c591083a348fe06e8c171e525019";
    hash = "sha256-lFANSoJ6vzFN0+5NHl4mSSbtISkWBUcpFui9/hmB0zo=";
  };

  sourceRoot = "${src.name}/OpenBatteryInformation";

  nativeBuildInputs = [ makeWrapper ];

  # Not strictly required, but fine to keep closure explicit:
  propagatedBuildInputs = [ py ];

  installPhase = ''
    runHook preInstall

    site="$out/${python3.sitePackages}"
    mkdir -p "$site"
    cp -r . "$site/OpenBatteryInformation"

    mkdir -p $out/bin

    makeWrapper ${py}/bin/python $out/bin/open-battery-information \
      --run "cd $site/OpenBatteryInformation" \
      --add-flags "$site/OpenBatteryInformation/main.py" \
      --set PYTHONPATH "$site"

    runHook postInstall
  '';

  meta = {
    description = "";
    homepage = "https://github.com/mnh-jansson/open-battery-information";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "open-battery-information";
    platforms = lib.platforms.all;
  };
}
