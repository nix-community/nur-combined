{
  policies ? { },

  config,
  fetchzip,
  formats,
  lib,
  stdenv,
  writeScript,

  adwaita-icon-theme,
  alsa-lib,
  autoPatchelfHook,
  curl,
  gtk3,
  libva,
  patchelfUnstable,
  pciutils,
  pipewire,
  vulkan-loader,
  wrapGAppsHook3,
}:
let
  version = "0.1.63a";
  sources = {
    x86_64-linux = fetchzip {
      url = "https://github.com/glide-browser/glide/releases/download/${version}/glide.linux-x86_64.tar.xz";
      sha256 = "sha256-xB5xhmJ3gAlyxxhukQLUwPvgBjWSZktzRMJTblsU0lE=";
    };
    aarch64-linux = fetchzip {
      url = "https://github.com/glide-browser/glide/releases/download/${version}/glide.linux-aarch64.tar.xz";
      sha256 = "sha256-BgEqMObAFvIDNA2EmcuU6BlTJrOrbbZSxwV/toqHmI8=";
    };
  };

  libName = "glide-bin-${version}";
in
stdenv.mkDerivation {
  pname = "glide-bin-unwrapped";
  inherit version;
  src = sources.${stdenv.targetPlatform.system} or sources.x86_64-linux;

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable
    wrapGAppsHook3
  ];

  patchelfFlags = [ "--no-clobber-old-sections" ];

  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
    gtk3
    adwaita-icon-theme
  ];

  runtimeDependencies = [
    curl
    libva
    pciutils
    pipewire
    vulkan-loader
  ];

  buildPhase =
    let
      policies' = (formats.json { }).generate "glide-policies" {
        policies = (config.glide-browser.policies or { }) // policies;
      };
    in
    ''
      runHook preBuild

      mkdir -p $out/{lib/${libName},bin}
      cp -r * $out/lib/${libName}
      ln -s $out/lib/${libName}/glide $out/bin/glide

      mkdir -p $out/lib/${libName}/distribution
      ln -s ${policies'} $out/lib/${libName}/distribution/policies.json

      runHook postBuild
    '';

  passthru = sources // {
    applicationName = "Glide";
    binaryName = "glide";
    inherit libName;
    inherit gtk3;
    ffmpegSupport = true;
    gssSupport = true;
    pipewireSupport = true;

    updateScript = writeScript "update-glide-bin-unwrapped" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/glide-browser/glide/releases/latest | jq -r .name)"
      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Extensible and keyboard-focused web browser";
    homepage = "https://glide-browser.app";
    license = lib.licenses.mpl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "glide";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
