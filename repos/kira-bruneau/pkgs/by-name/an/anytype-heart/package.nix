{
  lib,
  buildGoModule,
  fetchFromGitHub,
  protobuf,
  protoc-gen-grpc-web,
  protoc-gen-js,
  tantivy-go,
}:

buildGoModule rec {
  pname = "anytype-heart";
  version = "0.44.1";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    tag = "v${version}";
    hash = "sha256-Kb5Z484zeKJT8oBmfqbHszcxYPwnx7mvssseNyRDMWE=";
  };

  proxyVendor = true;

  vendorHash = "sha256-T7CPD6mbxkN1x53oe9jsS2XMqluqWv8VPPd1pnXZvlc=";

  subPackages = [ "cmd/grpcserver" ];

  nativeBuildInputs = [
    protobuf
    protoc-gen-grpc-web
    protoc-gen-js
  ];

  buildInputs = [ tantivy-go ];

  # https://github.com/anyproto/anytype-heart/blob/v0.43.0-rc02/makefiles/ci-cross-compile-library.mk#L1
  # https://github.com/anyproto/anytype-heart/blob/v0.43.0-rc02/makefiles/ci-cross-compile-library.mk#L37
  tags = [
    "envproduction"
    "nographviz"
    "nowatchdog"
    "nosigar"
    "nomutexdeadlockdetector"
    "noheic"
  ];

  preBuild = ''
    mkdir deps/libs
    make write-tantivy-version
    expected_tantivy_version=$(cat deps/libs/.verified)
    actual_tantivy_version=${lib.escapeShellArg "v${tantivy-go.version}"}
    if [ "$expected_tantivy_version" != "$actual_tantivy_version" ]; then
      echo "error: expected tantivy-go $expected_tantivy_version, but got $actual_tantivy_version"
      exit 1
    fi
  '';

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

  meta = with lib; {
    description = "Shared library for Anytype clients";
    homepage = "https://github.com/anyproto/anytype-heart";
    changelog = "https://github.com/anyproto/anytype-heart/releases/tag/${src.tag}";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "anytypeHelper";
  };
}
