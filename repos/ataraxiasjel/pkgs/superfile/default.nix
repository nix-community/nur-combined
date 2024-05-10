{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, exiftool
}:

buildGoModule rec {
  pname = "superfile";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-Cn03oPGT+vCZQcC62p7COx8N8BGgra+qQaZyF+osVsA=";
  } + "/src";

  vendorHash = "sha256-gWrhy3qzlXG072u5mW971N2Y4Vmt0KbZkB8SFsFgSzo=";

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
