{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "cert-chain-resolver";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "zakjan";
    repo = "cert-chain-resolver";
    rev = version;
    hash = "sha256-nFJ7V2VG7NyYhWgTDdE5ZPnugu1scIjzZxn5onl84Os=";
  };

  vendorHash = "sha256-OBoQMp05S3t6zLVEBbfp8FB0b9GwR222OQD+ZGjIHso=";

  ldflags = [ "-s" "-w" ];

  # tests require network access
  doCheck = false;

  # https://github.com/zakjan/cert-chain-resolver/issues/27
  postInstall = ''
    rm $out/bin/tests
  '';

  meta = with lib; {
    description = "SSL certificate chain resolver";
    homepage = "https://github.com/zakjan/cert-chain-resolver";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "cert-chain-resolver";
  };
}
