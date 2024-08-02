{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, exiftool
, nix-update-script
}:

buildGoModule rec {
  pname = "superfile";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-ajLlXySf/YLHrwwacV5yIF8qU5pKvEoOwpDoxh49qaU=";
  };

  vendorHash = "sha256-vybe4KNj6ZhvXRTiN7e5+IhOewfK5L2jKPrcdCYGc4k=";

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
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
