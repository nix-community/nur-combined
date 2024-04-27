{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, exiftool
}:

buildGoModule rec {
  pname = "superfile";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-oWkL+jvuut/cy44zghbVmbv6Cq+b49E/J7y/LDsS3+A=";
  } + "/src";

  vendorHash = "sha256-mF/YMNPJpkc8QHF7VeATfOCuHgtnS5BILnnU7A+c80U=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/superfile \
      --prefix PATH : ${lib.makeBinPath [ exiftool ]}
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/MHNightCat/superfile";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
