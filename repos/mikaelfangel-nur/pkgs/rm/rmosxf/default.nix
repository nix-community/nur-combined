{ stdenv, bash, fetchFromGitHub, lib, makeWrapper, findutils, coreutils }:

stdenv.mkDerivation rec {
  pname = "rmosxf";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "MikaelFangel";
    repo = "AwesomeScripts";
    rev = "be0a3f5554a3449b9a0975cdf8c321589f8d35cd";
    hash = "sha256-7X6KA3i7V0iIrK4UPwx90tKCyzBR/w2RkZiP030Hda0=";
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ findutils coreutils ];

  installPhase = ''
    runHook preInstall
    
    install -Dm 755 rmosxf.sh $out/bin/rmosxf

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/rmosxf" \
      --prefix PATH : ${lib.makeBinPath buildInputs};
  '';

  meta = with lib; {
    description = "A tool to remove osx file from the system";
    homepage = "https://github.com/MikaelFangel/AwesomeScripts";
    maintainers = with maintainers; [ mikaelfangel ];
    license = licenses.mit;
    mainProgram = "rmosxf";
  };
}
