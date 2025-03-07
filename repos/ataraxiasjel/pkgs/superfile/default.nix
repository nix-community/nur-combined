{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  exiftool,
  nix-update-script,
}:

buildGoModule rec {
  pname = "superfile";
  version = "1.2.0.0";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-ByCKpNUWwVzO6A8Ad9V0P0lsquYgVqDS3eCta5iOfXI=";
  };

  vendorHash = "sha256-5mjy6Mu/p7UJCxn2XRbgtfGmrS+9bEt4+EVheYZcDpY=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/superfile \
      --prefix PATH : ${lib.makeBinPath [ exiftool ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/MHNightCat/superfile";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "superfile";
  };
}
