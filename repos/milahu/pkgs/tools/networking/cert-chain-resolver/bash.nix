# this builds 1000x faster than the go version
# and gives the same result

{ lib
, stdenvNoCC
, fetchFromGitHub
, gawk
, curl
, openssl
}:

stdenvNoCC.mkDerivation rec {
  pname = "cert-chain-resolver-bash";
  version = "2019-07-05";

  src = fetchFromGitHub {
    owner = "zakjan";
    repo = "cert-chain-resolver";
    # https://github.com/zakjan/cert-chain-resolver/tree/shell
    rev = "71f90f1f6b850b2a540d71b0f5258241c4e5451b";
    hash = "sha256-0DUfWzAoFF0kWr3mvFlKAt6TIHZvANKjFzhrNUhtqO0=";
  };

  buildPhase = ''
    {
      echo "#!/usr/bin/env bash"
      echo "export PATH='${gawk}/bin:${curl}/bin:${openssl}/bin'"
      echo
      cat src/cert-chain-resolver.sh
    } > cert-chain-resolver
    chmod +x cert-chain-resolver
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp cert-chain-resolver $out/bin
  '';

  meta = with lib; {
    description = "SSL certificate chain resolver. Bash version";
    homepage = "https://github.com/zakjan/cert-chain-resolver/tree/shell";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "cert-chain-resolver";
  };
}
