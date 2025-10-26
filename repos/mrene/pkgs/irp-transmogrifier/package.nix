{ lib
, fetchFromGitHub
, maven
, libxslt
, jre
, makeWrapper
}:

maven.buildMavenPackage rec {
  pname = "irp-transmogrifier";
  version = "1.2.14";

  src = fetchFromGitHub {
    owner = "bengtmartensson";
    repo = "IrpTransmogrifier";
    rev = "Version-${version}";
    hash = "sha256-nG5TMtdUoiJQ+SXlCbxfhU5WVpgLwV3vFDxj4yeGKYI=";
  };

  nativeBuildInputs = [ libxslt jre makeWrapper ];

  mvnHash = "sha256-kifaJzPCheWAoiv7XUT96v8xuid8gJqAD26RaaJEXs8=";
  mvnParameters = "-Dmaven.gitcommitid.skip=true -Dgit.commit.id=${src.rev}";

  makeFlags = [
    "INSTALLDIR=${placeholder "out"}/share/${pname}"
    "BINLINK=${placeholder "out"}/bin/${pname}"
    "BROWSELINK=${placeholder "out"}/bin/irpbrowse"
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : "${lib.makeBinPath [ jre ]}"
  '';

  meta = with lib; {
    description = "Parser for IRP notation protocols, with rendering, code generation, and decoding";
    homepage = "https://github.com/bengtmartensson/IrpTransmogrifier";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ mrene ];
    platforms = jre.meta.platforms;
  };
}