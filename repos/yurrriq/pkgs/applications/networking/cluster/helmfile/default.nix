{ lib, buildGoPackage, fetchFromGitHub, makeWrapper, kubernetes-helm, ... }:

let version = "0.69.0"; in

buildGoPackage {
  name = "helmfile-${version}";

  src = fetchFromGitHub {
    owner = "roboll";
    repo = "helmfile";
    rev = "v${version}";
    sha256 = "0jaf6rf5mxv8hh9skxw1q8h80b0ib222qm5nbkqwb1al8k0nmndi";
  };

  goDeps = ./deps.nix;

  goPackagePath = "github.com/roboll/helmfile";

  nativeBuildInputs = [ makeWrapper ];

  buildFlagsArray = ''
    -ldflags=
    -X main.Version=${version}
  '';

  postInstall = ''
    wrapProgram $bin/bin/helmfile \
      --prefix PATH : ${lib.makeBinPath [ kubernetes-helm ]}
  '';

  meta = {
    description = "Deploy Kubernetes Helm charts";
    homepage = https://github.com/roboll/helmfile;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pneumaticat yurrriq ];
    platforms = lib.platforms.unix;
  };
}
