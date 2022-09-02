{ lib, fetchFromSourcehut, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "qute-gemini";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~sotirisp";
    repo = "qute-gemini";
    rev = "v${version}";
    hash = "sha256-0e0DvnhPtdtA2ZSGTaWuMNgVlP6fA1P0cuze7AFG3bM=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    install -Dm755 qute-gemini{,-tab} -t $out/share/qutebrowser/userscripts
  '';

  meta = with lib; {
    description = "A qutebrowser userscripts that allows viewing Gemini pages";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
