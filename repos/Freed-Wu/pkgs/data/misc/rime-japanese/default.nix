{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "rime-japanese";

  src = fetchFromGitHub {
    owner = "gkovacs";
    repo = "rime-japanese";
    rev = "4c1e65135459175136f380e90ba52acb40fdfb2d";
    sha256 = "sha256-/mIIyCu8V95ArKo/vIS3qAiD8InUmk8fAF/wejxRxGw=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src/*.yaml -t $out/share/rime-data
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/gkovacs/rime-japanese";
    description = "Input method for typing Japanese with RIME";
    # https://github.com/gkovacs/rime-japanese/issues/6
    license = licenses.unlicense;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
