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
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-/MdcfZpYr7vvPIq0rqLrPRPPU+cyp2y0EyxQPf9znwQ=";
  };

  vendorHash = "sha256-8WGmksKH0rmfRH6Xxd0ACl1FS7YPphG7hsIB5/o38lQ=";

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
