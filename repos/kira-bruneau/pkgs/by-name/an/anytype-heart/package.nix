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
  version = "0.39.11";

  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    tag = "v${version}";
    hash = "sha256-+H63bc4aJPERfclzKh4E3uYEEwNycLfe0BCPSlilqCc=";
  };

  proxyVendor = true;

  vendorHash = "sha256-fbZ1DiRcD9dnS8e7BMrKPYApqZmQbaH6DsSSO1knDmo=";

  subPackages = [ "cmd/grpcserver" ];

  nativeBuildInputs = [
    protobuf
    protoc-gen-grpc-web
    protoc-gen-js
  ];

  buildInputs = [ tantivy-go ];

  # https://github.com/anyproto/anytype-heart/blob/v0.39.11/.github/workflows/build.yml#L117
  tags = [
    "envproduction"
    "nographviz"
    "noheic"
    "nomutexdeadlockdetector"
    "nosigar"
    "nowatchdog"
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
    changelog = "https://github.com/anyproto/anytype-heart/releases/tag/${src.version}";
    license = licenses.unfree; # Any Source Available License 1.0
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
    mainProgram = "anytypeHelper";
  };
}
