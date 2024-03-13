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
  version = "0.32.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    rev = "refs/tags/v${version}";
    hash = "sha256-ZxiE3qc7Xudrz0/YjvC1oHVQpXrARzBPBzCtvn0nfpM=";
  };

  proxyVendor = true;

  vendorHash = "sha256-DNvggVdwZSI6wyA6hsEFbvSvAty4hDvQCDnurHg1xsY=";

  subPackages = [ "cmd/grpcserver" ];

  nativeBuildInputs = [
    protobuf
    protoc-gen-grpc-web
    protoc-gen-js
  ];

  # https://github.com/anyproto/anytype-heart/blob/v0.32.1/.github/workflows/build.yml#L366
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
    changelog = "https://github.com/anyproto/anytype-heart/releases/tag/v${version}";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
