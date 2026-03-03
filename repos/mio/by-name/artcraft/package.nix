{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  git,
  runCommand,
  cargo-tauri,
  cmake,
  go,
  ninja,
  nodejs_22,
  npmHooks,
  perl,
  pkg-config,
  sqlite,
  wrapGAppsHook4,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  gtk3,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  librsvg,
  dbus,
  libayatana-appindicator,
}:
let
  version = "0.11.0";
  src = fetchFromGitHub {
    owner = "storytold";
    repo = "artcraft";
    tag = "artcraft-v${version}";
    hash = "sha256-ZNw2hbT1lDoOJtQpp7L26S+oCCdcp5bwVMg5OBfUbGk=";
  };
  frontendSrc = runCommand "artcraft-frontend-src-${version}" { } ''
    cp -r ${src}/frontend $out
    chmod -R +w $out

    substituteInPlace $out/package.json $out/apps/artcraft/package.json \
      --replace-fail "@fortawesome/pro-solid-svg-icons" "@fortawesome/free-solid-svg-icons" \
      --replace-fail "@fortawesome/pro-regular-svg-icons" "@fortawesome/free-solid-svg-icons"

    substituteInPlace $out/apps/artcraft/package.json \
      --replace-fail '"update:icons": "npm update @awesome.me/kit-fde2be5eb0",' "" \
      --replace-fail '"@awesome.me/kit-fde2be5eb0": "^1.0.7",' "" \
      --replace-fail '"prepare": "husky",' ""

    cp ${./frontend-package-lock.json} $out/package-lock.json
    : > $out/.npmrc
    : > $out/apps/artcraft/.npmrc
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "artcraft";
  inherit version src;

  npmRoot = "frontend";
  npmDeps = fetchNpmDeps {
    src = frontendSrc;
    hash = "sha256-hzH2Q62V6J5CD1Ho/ISFE5uh6HCqV2+gzUNTi25819E=";
  };
  npmDepsFetcherVersion = 2;
  makeCacheWritable = true;
  npmFlags = [
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];

  buildAndTestSubdir = "crates/desktop/artcraft";
  cargoHash = "sha256-Q/+zJJypBoUfWqsE9l0bKIX7FAAHjgdCCA4Wo8CHeIo=";

  nativeBuildInputs = [
    cargo-tauri.hook
    cmake
    git
    go
    ninja
    npmHooks.npmConfigHook
    nodejs_22
    perl
    pkg-config
    rustPlatform.bindgenHook
    sqlite
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
    gtk3
    glib
    cairo
    pango
    gdk-pixbuf
    librsvg
    dbus
    libayatana-appindicator
  ];

  postPatch = ''
    substituteInPlace frontend/package.json frontend/apps/artcraft/package.json \
      --replace-fail "@fortawesome/pro-solid-svg-icons" "@fortawesome/free-solid-svg-icons" \
      --replace-fail "@fortawesome/pro-regular-svg-icons" "@fortawesome/free-solid-svg-icons"

    substituteInPlace frontend/apps/artcraft/package.json \
      --replace-fail '"update:icons": "npm update @awesome.me/kit-fde2be5eb0",' "" \
      --replace-fail '"@awesome.me/kit-fde2be5eb0": "^1.0.7",' "" \
      --replace-fail '"prepare": "husky",' ""

    cp ${./frontend-package-lock.json} frontend/package-lock.json
    : > frontend/.npmrc
    : > frontend/apps/artcraft/.npmrc

    find frontend -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) \
      -exec sed -i \
      -e 's/@fortawesome\/pro-solid-svg-icons/@fortawesome\/free-solid-svg-icons/g' \
      -e 's/@fortawesome\/pro-regular-svg-icons/@fortawesome\/free-solid-svg-icons/g' \
      -e 's/faArrowDownToLine/faArrowDown/g' \
      -e 's/faDownToLine/faArrowDown/g' \
      -e 's/faUpFromLine/faArrowUp/g' \
      -e 's/faSpinnerThird/faSpinner/g' \
      -e 's/faSparkles/faWandMagicSparkles/g' \
      -e 's/faGrid2/faRectangleList/g' \
      -e 's/faTableCellsLarge/faRectangleList/g' \
      -e 's/faTrashXmark/faTrashCan/g' \
      -e 's/faBlindsRaised/faWindowMaximize/g' \
      -e 's/faBlinds/faWindowMinimize/g' \
      -e 's/faCameraViewfinder/faCamera/g' \
      -e 's/faDash/faMinus/g' \
      -e 's/faMinus/faWindowMinimize/g' \
      -e 's/faEmptySet/faBan/g' \
      -e 's/faFilterList/faFilter/g' \
      -e 's/faFrame/faSquare/g' \
      -e 's/faHighDefinition/faH/g' \
      -e 's/faStandardDefinition/faS/g' \
      -e 's/faListTree/faList/g' \
      -e 's/faMessageCheck/faMessage/g' \
      -e 's/faMessageXmark/faMessage/g' \
      -e 's/faPresentationScreen/faDisplay/g' \
      -e 's/faRabbitRunning/faPersonRunning/g' \
      -e 's/faRectangleWide/faRectangleList/g' \
      -e 's/faRectangleVertical/faRectangleList/g' \
      -e 's/faRectangle/faSquare/g' \
      -e 's/faSendBack/faArrowLeft/g' \
      -e 's/faTriangle/faPlay/g' \
      -e 's/faWaveformLines/faWaveSquare/g' \
      -e 's/faXmark/faCircleXmark/g' \
      -e 's/faAlienMonster/faRobot/g' \
      -e 's/faPlayExclamation/faTriangleExclamation/g' \
      -e 's/faSquareList/faRectangleList/g' \
      -e 's/faCircleInfo/faCircle/g' \
      {} +

    substituteInPlace crates/desktop/artcraft/tauri.conf.json \
      --replace-fail '"beforeBuildCommand": "nx run artcraft:build"' '"beforeBuildCommand": "true"'
  '';

  preBuild = ''
    cat > /tmp/tasks-schema.sql <<'EOF'
    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT NOT NULL PRIMARY KEY,
      task_status TEXT NOT NULL,
      task_type TEXT NOT NULL,
      model_type TEXT,
      provider TEXT,
      provider_job_id TEXT,
      frontend_caller TEXT,
      frontend_subscriber_id TEXT,
      frontend_subscriber_payload TEXT,
      is_dismissed_by_user INTEGER NOT NULL DEFAULT 0,
      on_complete_primary_media_file_token TEXT,
      on_complete_primary_media_file_class TEXT,
      on_complete_batch_token TEXT,
      on_complete_primary_media_file_cdn_url TEXT,
      on_complete_primary_media_file_thumbnail_url_template TEXT,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      completed_at DATETIME
    );
    EOF
    sqlite3 /tmp/tasks.sqlite < /tmp/tasks-schema.sql

    vendorDir="$(find /build -maxdepth 1 -type d -name '*-vendor' | head -n1)"
    cqFile="$vendorDir/concurrent-queue-2.3.0/src/lib.rs"

    perl -0pi -e 's#\n    /// Attempts to pop an item from the queue\.\n#\n    /// Forcefully pushes an item into the queue.\n    ///\n    /// If the queue is full, this method removes and returns an existing item.\n    /// If the queue is closed, the pushed item is returned as an error.\n    pub fn force_push(&self, value: T) -> Result<Option<T>, ForcePushError<T>> {\n        match self.push(value) {\n            Ok(()) => Ok(None),\n            Err(PushError::Closed(value)) => Err(ForcePushError(value)),\n            Err(PushError::Full(value)) => match self.pop() {\n                Ok(oldest) => match self.push(value) {\n                    Ok(()) => Ok(Some(oldest)),\n                    Err(PushError::Closed(value)) | Err(PushError::Full(value)) => {\n                        Err(ForcePushError(value))\n                    }\n                },\n                Err(PopError::Empty) | Err(PopError::Closed) => Err(ForcePushError(value)),\n            },\n        }\n    }\n\n    /// Attempts to pop an item from the queue.\n#s' "$cqFile"

    perl -0pi -e 's#\n/// Error which occurs when popping from an empty queue\.\n#\n/// Error returned by [`ConcurrentQueue::force_push`].\npub struct ForcePushError<T>(pub T);\n\n/// Error which occurs when popping from an empty queue.\n#s' "$cqFile"

    patchShebangs frontend/node_modules
    patchShebangs frontend/apps/artcraft/node_modules

    pushd frontend
    export CI=true
    export NX_DAEMON=false
    export NX_TUI=false
    npx nx run artcraft:build --outputStyle=static
    popd
  '';

  doCheck = false;

  meta = {
    description = "IDE for interactive AI image and video creation";
    homepage = "https://github.com/storytold/artcraft";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "artcraft";
    maintainers = [ ];
  };
})
