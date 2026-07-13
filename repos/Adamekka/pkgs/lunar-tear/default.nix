{ buildGoModule
, coreutils
, fetchFromGitHub
, gitUpdater
, gnumake
, goose
, lib
, makeWrapper
, maintainer
, protobuf
, protoc-gen-go
, protoc-gen-go-grpc
, runtimeShell
,
}:

buildGoModule rec {
  pname = "lunar-tear";
  version = "1.0.2";

  src = fetchFromGitHub {
    hash = "sha256-5EDOMc1yvOCrVIeXJyZaB8UZ5lDQCOk2FBCltgGs/ZI=";
    owner = "Walter-Sparrow";
    repo = "lunar-tear";
    rev = "v${version}";
  };

  patches = [
    ./package-bin-dir.patch
  ];

  vendorHash = "sha256-kR0dMZhO8S3AS8NWa2ul97b2QjnCnq9SJbSfS2slgTg=";

  modRoot = "server";

  nativeBuildInputs = [
    gnumake
    makeWrapper
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
  ];

  subPackages = [
    "cmd/auth-server"
    "cmd/claim-account"
    "cmd/dev"
    "cmd/import-snapshot"
    "cmd/lunar-tear"
    "cmd/octo-cdn"
    "cmd/register-account"
    "cmd/wizard"
    "cmd/wizard-restore"
  ];

  preBuild = ''
    make proto
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    for binary in auth-server claim-account dev import-snapshot lunar-tear lunar-tear-start octo-cdn register-account wizard; do
      "$out/bin/$binary" --help >/dev/null 2>&1
    done

    tmpDb="$(mktemp -d)"
    ${goose}/bin/goose -dir "$out/share/lunar-tear/migrations" -allow-missing sqlite3 "$tmpDb/game.db" up >/dev/null 2>&1

    tmpData="$(mktemp -d)"
    set +e
    missingAssetsOutput="$($out/bin/lunar-tear-start --data-dir "$tmpData" 2>&1)"
    missingAssetsStatus=$?
    set -e
    if [ "$missingAssetsStatus" -eq 0 ]; then
      echo "lunar-tear-start unexpectedly succeeded without assets" >&2
      exit 1
    fi
    case "$missingAssetsOutput" in
      *"Missing required asset:"*) ;;
      *)
        echo "lunar-tear-start did not explain the missing assets" >&2
        echo "$missingAssetsOutput" >&2
        exit 1
        ;;
    esac

    runHook postInstallCheck
  '';

  postInstall = ''
    install -d "$out/share/lunar-tear"
    cp -R migrations "$out/share/lunar-tear/migrations"

    substitute ${./lunar-tear-start.sh} "$out/bin/lunar-tear-start" \
      --subst-var-by goose "${goose}/bin/goose" \
      --subst-var-by migrationsDir "$out/share/lunar-tear/migrations" \
      --subst-var-by packageBinDir "$out/bin" \
      --subst-var-by runtimeShell "${runtimeShell}"
    chmod +x "$out/bin/lunar-tear-start"

    wrapProgram "$out/bin/dev" \
      --set LUNAR_TEAR_BIN_DIR "$out/bin"
    wrapProgram "$out/bin/lunar-tear-start" \
      --prefix PATH : ${lib.makeBinPath [ coreutils ]}
    wrapProgram "$out/bin/wizard" \
      --set LUNAR_TEAR_BIN_DIR "$out/bin"
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Private server research project for a discontinued mobile game";
    homepage = "https://github.com/Walter-Sparrow/lunar-tear";
    license = lib.licenses.mit;
    mainProgram = "lunar-tear-start";
    maintainers = [ maintainer ];
    platforms = lib.platforms.unix;
  };
}
