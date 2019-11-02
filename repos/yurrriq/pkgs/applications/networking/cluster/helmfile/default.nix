{ stdenv, lib, buildGoModule, fetchFromGitHub, makeWrapper, kubernetes-helm, ... }:

buildGoModule {
  pname = "helmfile";
  version = "0.87.0";

  src = fetchFromGitHub {
    owner = "roboll";
    repo = "helmfile";
    rev = "v${version}";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  goPackagePath = "github.com/roboll/helmfile";

  modSha256 = "0000000000000000000000000000000000000000000000000000";

  nativeBuildInputs = [ makeWrapper ];

  buildFlagsArray = ''
    -ldflags=
    -X main.Version=${version}
  '';

  postInstall = ''
    wrapProgram $out/bin/helmfile \
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
