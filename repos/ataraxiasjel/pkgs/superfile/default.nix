{ lib
, buildGoModule
, fetchFromGitHub
, makeWrapper
, exiftool
, nix-update-script
}:

buildGoModule rec {
  pname = "superfile";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "MHNightCat";
    repo = "superfile";
    rev = "v${version}";
    hash = "sha256-z1jcRzID20s7tEDUaEcnOYBfv/BPZtcXz9fy3V5iPPg=";
  };

  vendorHash = "sha256-OzPH7dNu/V4HDGSxrvYxu3s+hw36NiulFZs0BJ44Pjk=";

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
