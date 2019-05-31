{ lib, buildGoPackage, fetchFromGitHub, makeWrapper, kubernetes-helm, ... }:

let version = "0.68.1"; in

buildGoPackage {
  name = "helmfile-${version}";

  src = fetchFromGitHub {
    owner = "roboll";
    repo = "helmfile";
    rev = "v${version}";
    sha256 = "13s1lzn3qflxp0pgigz4nk72iyq55q4r6ws3pamhhbbcsja5p38y";
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
