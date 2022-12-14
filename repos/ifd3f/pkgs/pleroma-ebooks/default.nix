# https://docs.akkoma.dev/stable/installation/otp_en/#installing-akkoma
{ lib, poetry2nix, fetchFromGitHub
, version ? "94949289f07e7f915f640b71179b193356fc1d5b", stdenvNoCC }:
let
  python = (poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    preferWheels = true;
    overrides = poetry2nix.overrides.withDefaults (final: prev: {
      markovify = prev.markovify.overridePythonAttrs (old: {
        propagatedBuildInputs = [ final.setuptools final.unidecode ];
      });
    });
  });
in stdenvNoCC.mkDerivation {
  pname = "pleroma-ebooks";
  inherit version;

  src = fetchFromGitHub {
    owner = "ioistired";
    repo = "pleroma-ebooks";
    rev = version;
    sha256 = "sha256-TyyyuRvu8vTpVtMBjooWQh97QxuAaaolBmxWBcDK14A";
  };

  buildInputs = [ python ];

  installPhase = ''
    mkdir -p $out
    cp -r "$src" "$out/bin"

    bins=($out/bin/fetch_posts.py $out/bin/gen.py $out/bin/reply.py)
  '';

  meta = with lib; {
    description = "pleroma-ebooks";
    homepage = "https://github.com/ioistired/pleroma-ebooks";
    license = licenses.agpl3Only;
  };
}
