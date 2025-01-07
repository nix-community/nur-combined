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
  version = "1.1.7.1";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-v7EfMgOsc6FSGIjYkF+44t0wl34WFmokOtzNOAOneBc=";
  };

  vendorHash = "sha256-MdOdQQZhiuOJtnj5n1uVbJV6KIs0aa1HLZpFmvxxsWY=";

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
