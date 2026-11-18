{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  imagemagick,
  libicns,
  oniguruma,
  pkg-config,
  python3,
  # Darwin
  sqlite,
  # Linux
  cmake,
  openssl,
  fcitx5,
  nlohmann_json,
  libxkbcommon,
  wayland,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  dejavu_fonts,
  noto-fonts-cjk-sans,
  noto-fonts-color-emoji,
}:

let
  # Product data release pinned by tools/release/data.lock at the source tag.
  dataTag = "data-v10";
  dataHash = "sha256-Ys8rQ+tJyGBlVEogCLISGwZcDTDkfBLQiTLIrDD1OrY=";

  inherit (stdenv.hostPlatform) isDarwin isLinux;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qingjian";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "qingjian-team";
    repo = "qingjian";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rsWvg/aAD8oIKQEh+4IFP7lNQBRiLGofHPEKUhXJtLc=";
  };

  data = fetchurl {
    url = "https://github.com/qingjian-team/qingjian/releases/download/${dataTag}/qingjian-data.tar.gz";
    hash = dataHash;
  };

  cargoHash = "sha256-czZijlOPaP9Kahq90dRkuRnkcwvXQbIaNpxPFMq2i/8=";

  nativeBuildInputs = [
    pkg-config
    python3
  ]
  ++ lib.optionals isDarwin [
    imagemagick
    libicns
  ]
  ++ lib.optionals isLinux [
    cmake
  ];

  # nixpkgs sets RUSTONIG_SYSTEM_LIBONIG, so onig_sys links the system library
  buildInputs = [
    oniguruma
  ]
  # The clipboard app's rusqlite; nixpkgs sets LIBSQLITE3_SYS_USE_PKG_CONFIG
  ++ lib.optionals isDarwin [
    sqlite
  ]
  ++ lib.optionals isLinux [
    openssl
    fcitx5
    nlohmann_json
  ];

  # The fcitx5 addon is built by hand after cargo, not as the top-level project.
  dontUseCmakeConfigure = true;

  cargoBuildFlags = [
    "-p"
    "qingjian-settings"
  ]
  ++ (
    if isDarwin then
      [
        "-p"
        "qingjian-macos"
        "-p"
        "qingjian-clipboard-app"
      ]
    else
      [
        "-p"
        "qingjian-linux-server"
      ]
  );

  env.QINGJIAN_BUILD = "nix · ${finalAttrs.version}";

  # bamboo-slip loads fonts from a fixed list of FHS paths (no fontconfig);
  # append store fonts so the FHS ones still win where they exist.
  postPatch = lib.optionalString isLinux ''
    substituteInPlace crates/bamboo-slip/src/fonts/linux.rs \
      --replace-fail '"/usr/local/share/fonts/dejavu/DejaVuSans.ttf",' \
        '"/usr/local/share/fonts/dejavu/DejaVuSans.ttf", "${dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf",' \
      --replace-fail '"/usr/local/share/fonts/noto/NotoSans-Bold.ttf",' \
        '"/usr/local/share/fonts/noto/NotoSans-Bold.ttf", "${dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf",' \
      --replace-fail '"/usr/local/share/fonts/noto/NotoSansCJKsc-Regular.otf",' \
        '"/usr/local/share/fonts/noto/NotoSansCJKsc-Regular.otf", "${noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc",' \
      --replace-fail '"/usr/local/share/fonts/noto/NotoColorEmoji.ttf",' \
        '"/usr/local/share/fonts/noto/NotoColorEmoji.ttf", "${noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf",'
  '';

  # Not postUnpack: the cargo vendor derivation inherits it but not `data`.
  # macOS bundles only data/generated; Linux also ships the sentence model.
  preBuild =
    if isDarwin then
      ''
        tar -xzf ${finalAttrs.data} data/generated
      ''
    else
      ''
        tar -xzf ${finalAttrs.data} --exclude='._*'
        # files.py checks the extracted data against the archive pinned in data.lock
        mkdir -p target/release-data
        ln -s ${finalAttrs.data} target/release-data/qingjian-data.tar.gz
      '';

  postBuild = lib.optionalString isLinux ''
    cmake -S apps/linux/fcitx5 -B build-fcitx5 \
      -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=$out
    cmake --build build-fcitx5 --parallel $NIX_BUILD_CORES
  '';

  doCheck = false;

  installPhase =
    if isDarwin then
      ''
        runHook preInstall

        # Mirrors apps/macos/scripts/bundle.sh, minus PlistBuddy/sips/iconutil/codesign.
        bin=target/${stdenv.hostPlatform.rust.cargoShortTarget}/release
        app="$out/Library/Input Methods/Qingjian.app"
        res="$app/Contents/Resources"
        settings="$app/Contents/Applications/QingjianSettings.app"
        clipboard="$app/Contents/Applications/QingjianClipboard.app"
        mkdir -p "$app/Contents/MacOS" "$res" "$settings/Contents/MacOS" "$settings/Contents/Resources" \
          "$clipboard/Contents/MacOS" "$clipboard/Contents/Resources"

        # Short version from each app's crate; the build number must grow across releases.
        writePlist() {
          local version
          version=$(sed -n 's/^version = "\(.*\)"/\1/p' "$2" | head -1)
          sed -e "/CFBundleShortVersionString/{n;s|>.*<|>$version<|;}" \
            -e '/CFBundleVersion</{n;s|>.*<|>${finalAttrs.version}<|;}' "$1" > "$3"
        }
        install -m755 $bin/qingjian-macos "$app/Contents/MacOS/"
        install -m755 $bin/qingjian-settings "$settings/Contents/MacOS/"
        install -m755 $bin/qingjian-clipboard "$clipboard/Contents/MacOS/"
        writePlist apps/macos/Info.plist apps/macos/Cargo.toml "$app/Contents/Info.plist"
        writePlist apps/settings/macos/Info.plist apps/settings/Cargo.toml "$settings/Contents/Info.plist"
        writePlist apps/clipboard/macos/Info.plist apps/clipboard/Cargo.toml "$clipboard/Contents/Info.plist"
        for a in "$app" "$settings" "$clipboard"; do printf 'APPL????' > "$a/Contents/PkgInfo"; done

        cp -R apps/macos/resources/*.lproj "$res/"
        cp assets/sample/*.tsv assets/emoji/*.tsv assets/levels/levels-*.tsv "$res/"
        for scheme in assets/schemes/*/; do
          mkdir -p "$res/schemes/$(basename $scheme)"
          cp $scheme/scheme.toml $scheme/table.tsv "$res/schemes/$(basename $scheme)/"
        done
        cp data/generated/dict.qj data/generated/lm.qj data/generated/glossary-*.qj "$res/"
        mkdir -p "$res/dicts" "$res/codes"
        cp data/generated/dicts/*.qj "$res/dicts/"
        cp data/generated/codes/*.qj assets/stroke/LICENSE-CNS11643.txt "$res/codes/"
        for f in assets/lexicon/english.tsv data/generated/english.tsv; do
          if [ -f $f ]; then cp $f "$res/"; fi
        done
        python3 tools/corpus/vietnamese_words.py assets/glossary/glossary-vi.tsv \
          "$res/vietnamese.tsv" "$res/vietnamese-zh.tsv"
        cp assets/icon/menu.pdf "$res/qingjian-menu.pdf"

        for size in 16 32 128 256 512; do
          magick assets/icon/macos/app.png -resize ''${size}x$size icon_$size.png
        done
        png2icns "$res/Qingjian.icns" icon_{16,32,128,256,512}.png
        cp "$res/Qingjian.icns" "$settings/Contents/Resources/"
        cp "$res/Qingjian.icns" "$clipboard/Contents/Resources/"

        # No bin/ symlink: --register registers NSBundle.mainBundle, which a symlink resolves to bin/.
        # Install the bundle into ~/Library/Input Methods and run --register from there.

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        # Mirrors apps/linux/scripts/install.sh + files.py, at a store prefix.
        bin=target/${stdenv.hostPlatform.rust.cargoShortTarget}/release
        install -Dm755 -t $out/bin $bin/qingjian-linux-server $bin/qingjian-settings
        # lib/fcitx5/qingjian.so and share/fcitx5/{addon,inputmethod}/qingjian.conf
        cmake --install build-fcitx5

        # The server looks for <exe>/../share/qingjian/resources
        python3 apps/linux/scripts/files.py resources $out/share/qingjian/resources --root "$PWD"

        mkdir -p $out/lib/systemd/user $out/share/applications
        sed "s|@EXEC@|$out/bin/qingjian-linux-server|" apps/linux/scripts/qingjian-server.service.in \
          > $out/lib/systemd/user/qingjian-server.service
        sed "s|^Exec=qingjian-settings$|Exec=$out/bin/qingjian-settings|" apps/settings/linux/qingjian-settings.desktop \
          > $out/share/applications/qingjian-settings.desktop
        for size in 16 22 24 32 48 64 128 256; do
          install -Dm644 assets/icon/linux/hicolor/''${size}x$size/apps/qingjian.png \
            $out/share/icons/hicolor/''${size}x$size/apps/qingjian.png
        done
        install -Dm644 -t $out/share/licenses/qingjian LICENSE assets/stroke/LICENSE-CNS11643.txt

        runHook postInstall
      '';

  # winit / softbuffer / arboard dlopen the windowing libraries.
  postFixup = lib.optionalString isLinux ''
    patchelf --add-rpath ${
      lib.makeLibraryPath [
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxi
        libxrandr
      ]
    } $out/bin/qingjian-settings
  '';

  meta = {
    description = "Pinyin input method that shows a translation of each candidate in the language you are learning";
    longDescription = ''
      On macOS this is the input method bundle. On Linux it is the engine
      server (a systemd user service), the fcitx5 addon that talks to it,
      and the settings app.
    '';
    homepage = "https://qingjian.app";
    changelog = "https://github.com/qingjian-team/qingjian/releases/tag/v${finalAttrs.version}";
    # Code is GPL-3.0+; the rest covers the bundled dictionaries, glossaries and code tables.
    license = with lib.licenses; [
      gpl3Plus
      mit
      unicode-30
      cc-by-sa-40
      cc-by-40
      ofl
      asl20
    ];
    maintainers = with lib.maintainers; [ congee ];
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  }
  // lib.optionalAttrs isLinux { mainProgram = "qingjian-linux-server"; };
})
