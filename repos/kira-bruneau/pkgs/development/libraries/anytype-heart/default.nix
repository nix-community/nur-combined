{ lib
, buildGoModule
, fetchFromGitHub
, protobuf
, protoc-gen-grpc-web
, protoc-gen-js
, nix-update-script
}:

buildGoModule rec {
  pname = "anytype-heart";
  version = "0.29.16";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    rev = "refs/tags/v${version}";
    hash = "sha256-PHpQ13SNtfOA1kn2hTYu54ua4txvdbW6+YtwWuVKTes=";
  };

  proxyVendor = true;

  vendorHash = "sha256-Is5InDGZ/qU3kZJIxfMLWSyejmlr3NjZNWwRaQSHFSA=";

  subPackages = [ "cmd/grpcserver" ];

  nativeBuildInputs = [
    protobuf
    protoc-gen-grpc-web
    protoc-gen-js
  ];

  # https://github.com/anyproto/anytype-heart/blob/v0.29.16/.github/workflows/build.yml#L313
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

    mkdir -p "$out/libexec/anytype"
    cp "$GOPATH/bin/grpcserver" "$out/libexec/anytype"

    mkdir -p "$out/include/anytype/protobuf/protos"
    cp pb/protos/*.proto pb/protos/service/*.proto pkg/lib/pb/model/protos/*.proto "$out/include/anytype/protobuf/protos"
    cp -r dist/js/pb/* "$out/include/anytype/protobuf"

    mkdir -p "$out/share/anytype/json"
    cp pkg/lib/bundle/system*.json "$out/share/anytype/json"
    cp pkg/lib/bundle/internal*.json "$out/share/anytype/json"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Shared library for Anytype clients";
    homepage = "https://github.com/anyproto/anytype-heart";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
