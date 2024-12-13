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
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-3zQDErfst0CAE9tdOUtPGtGWuOo/K8x/M+r6+RPrlCM=";
  };

  vendorHash = "sha256-DU0Twutepmk+8lkBM2nDChbsSHh4awt5m33ACUtH4AQ=";

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
