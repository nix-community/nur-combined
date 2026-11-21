{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  makeWrapper,
  nix-update-script,
}:

buildGoModule rec {
  pname = "open-code-review";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    rev = "v${version}";
    hash = "sha256-lQMAo1R+I6S2+eOW1APqZc2JVmezK+e6mqZuso0ku+k=";
  };

  vendorHash = "sha256-7/cO+9a/jdN4WuYPdwOUKgT3NFDOSM9Byt4AyjSrJfE=";

  subPackages = [ "cmd/opencodereview" ];

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = [ git ];

  # Replace go version directive with a version compatible with the current nixpkgs Go compiler
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.10" "go 1.26.0"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
  ];

  postInstall = ''
    ln -s opencodereview $out/bin/ocr
    wrapProgram $out/bin/opencodereview \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AI-powered code review CLI tool originated from Alibaba";
    homepage = "https://github.com/alibaba/open-code-review";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    mainProgram = "ocr";
  };
}
