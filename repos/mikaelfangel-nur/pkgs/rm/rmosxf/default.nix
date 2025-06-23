{ stdenv, bash, fetchFromGitHub, lib, makeWrapper, findutils, coreutils }:

stdenv.mkDerivation rec {
  pname = "rmosxf";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "MikaelFangel";
    repo = "AwesomeScripts";
    rev = "87c3a9d04699b151c5d08547f77cbece1f923590";
    hash = "sha256-uvEHHikhMlF4OxaonQjWobfIXf+1E/z4gG/OazxLCCM=";
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
