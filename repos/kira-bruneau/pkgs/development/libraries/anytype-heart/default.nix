{
  lib,
  buildGoModule,
  fetchFromGitHub,
  protobuf,
  protoc-gen-grpc-web,
  protoc-gen-js,
  nix-update-script,
}:

buildGoModule rec {
  pname = "anytype-heart";
  version = "0.35.3";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    rev = "refs/tags/v${version}";
    hash = "sha256-AihQrjy9SfWZaYiScb4U2gR4yyWRAE4QqfmYf21rYd8=";
  };

  proxyVendor = true;

  vendorHash = "sha256-F9LMKZfK0ciYj9f53YvGG+cFAhVi1MB8CX2uqC+LApE=";

  subPackages = [ "cmd/grpcserver" ];

  nativeBuildInputs = [
    protobuf
    protoc-gen-grpc-web
    protoc-gen-js
  ];

  # https://github.com/anyproto/anytype-heart/blob/v0.35.3/.github/workflows/build.yml#L361
  tags = [
    "envproduction"
    "nographviz"
    "nomutexdeadlockdetector"
    "nosigar"
    "nowatchdog"
  ];

  postBuild = ''
    make protos-js
  '';

  doCheck = false; # no test files

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp "$GOPATH/bin/grpcserver" "$out/bin/anytypeHelper"

    mkdir -p "$out/include/anytype/protobuf/protos"
    cp pb/protos/*.proto pb/protos/service/*.proto pkg/lib/pb/model/protos/*.proto "$out/include/anytype/protobuf/protos"
    cp -r dist/js/pb/* "$out/include/anytype/protobuf"

    mkdir -p "$out/share/anytype/json"
    cp pkg/lib/bundle/system*.json "$out/share/anytype/json"
    cp pkg/lib/bundle/internal*.json "$out/share/anytype/json"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      ''^v(\d+\.\d+\.\d+)$''
    ];
  };

  meta = with lib; {
    description = "Shared library for Anytype clients";
    homepage = "https://github.com/anyproto/anytype-heart";
    changelog = "https://github.com/anyproto/anytype-heart/releases/tag/v${version}";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "anytypeHelper";
  };
}
