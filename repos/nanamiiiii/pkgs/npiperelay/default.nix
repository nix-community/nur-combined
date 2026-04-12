{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  nix-update-script,
}:
stdenv.mkDerivation rec {
  pname = "npiperelay";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "albertony";
    repo = "npiperelay";
    tag = "v${version}";
    hash = "sha256-3RXmYCtjbLHlo9FU0tIwfG6ma7mYZVERugJygDBBG18=";
  };

  nativeBuildInputs = [ go ];

  buildPhase = ''
    runHook preBuild
    export GOOS=windows
    export GOARCH=amd64
    export CGO_ENABLED=0
    export GOFLAGS="-mod=vendor"
    export GOCACHE="$TMPDIR/go-cache"
        local build_date
    build_date=$(date -u -d "@$SOURCE_DATE_EPOCH" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null \
              || date -u -r "$SOURCE_DATE_EPOCH" "+%Y-%m-%dT%H:%M:%SZ")

    go build \
      -ldflags=" \
        -s -w \
        -X main.version=${version} \
        -X main.date=$build_date \
        -X main.builtBy=nix" \
      -o npiperelay.exe .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 npiperelay.exe "$out/bin/npiperelay.exe"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Access Windows named pipes from WSL";
    homepage = "https://github.com/albertony/npiperelay";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
