{ lib, fetchFromGitHub }:
let
  rev = "e7ca28026bc4576b2dd30aa2ab71c2d07dfc7197";
  srcHash = "sha256-vtttb+tRi3uDFn8liFgZcAqWLENfpTY7lWsNCoTFzEM=";
  vendorHash = "sha256-u7HT8+LeqS7mCNbUhrvSW0xd/uduL2Kw7A0mUUpW2w4=";
  yarnHash = "sha256-h+he2VxvZlStIoLb1PPxqKSmTfFNGgJmUXptjtc5xD8=";
  version = "next-${lib.substring 0 8 rev}";
in
{
  inherit version yarnHash vendorHash;

  src = fetchFromGitHub {
    owner = "woodpecker-ci";
    repo = "woodpecker";
    inherit rev;
    hash = srcHash;
  };

  postInstall = ''
    cd $out/bin
    for f in *; do
      mv -- "$f" "woodpecker-$f"
    done
    cd -
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/woodpecker-ci/woodpecker/version.Version=${version}"
  ];

  meta = with lib; {
    homepage = "https://woodpecker-ci.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ambroisie techknowlogick ];
  };
}
