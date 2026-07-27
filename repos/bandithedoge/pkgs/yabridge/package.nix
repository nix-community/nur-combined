{
  sources,

  lib,
  stdenv,
  rustPlatform,
  symlinkJoin,

  meson,
  ninja,
  pkg-config,
  wineWow64Packages,
  libxcb,
  asio,
  dbus,
  ghc_filesystem,
  tomlplusplus,
  breakpointHook,
  fetchpatch,
  replaceVars,
  makeWrapper,
}:
let
  wine = wineWow64Packages.staging;

  yabridge = stdenv.mkDerivation {
    inherit (sources.yabridge) pname src;
    version = sources.yabridge.date;

    patches = [
      (fetchpatch {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/pkgs/by-name/ya/yabridge/libyabridge-from-nix-profiles.patch";
        hash = "sha256-Ial9AkHvOfd1zR2uFBNPEKwpv/qgYxycZufEn9dXHl0=";
      })
      (replaceVars
        (fetchpatch {
          url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/pkgs/by-name/ya/yabridge/hardcode-dependencies.patch";
          hash = "sha256-oe9tfQgAuwFrNXROcCRZxXapWXwCdHYrbudl2Aro5zk=";
        })
        {
          libdbus = dbus.lib;
          inherit wine;
        }
      )
    ];

    nativeBuildInputs = [
      meson
      ninja
      pkg-config
      wine
    ];

    buildInputs = [
      libxcb
      dbus
      tomlplusplus
      asio
    ];

    mesonFlags = [
      "--cross-file"
      "cross-wine.conf"
      "-Dbitbridge=false"
    ];

    postPatch = ''
      cp -r --no-preserve=mode,ownership ${sources.bitsery.src} subprojects/bitsery
      cp subprojects/packagefiles/bitsery/* subprojects/bitsery/

      cp -r --no-preserve=mode,ownership ${sources.function2.src} subprojects/function2
      cp subprojects/packagefiles/function2/* subprojects/function2/

      cp -r --no-preserve=mode,ownership ${ghc_filesystem.src} subprojects/ghc_filesystem
      cp subprojects/packagefiles/ghc_filesystem/* subprojects/ghc_filesystem/

      cp -r --no-preserve=mode,ownership ${sources.clap.src} subprojects/clap
      cp subprojects/packagefiles/clap/* subprojects/clap/

      cp -r --no-preserve=mode,ownership ${sources.vst3.src} subprojects/vst3

      patchShebangs .
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,lib}
      cp yabridge-host.exe yabridge-host.exe.so $out/bin
      cp libyabridge-*.so $out/lib

      runHook postInstall
    '';

    postFixup = ''
      substituteInPlace $out/bin/yabridge-host.exe \
        --replace-fail 'WINELOADER="wine"' 'WINELOADER="${lib.getExe wine}"'
    '';
  };

  yabridgectl = rustPlatform.buildRustPackage {
    pname = "yabridgectl";
    version = sources.yabridge.date;
    inherit (sources.yabridge) src;
    sourceRoot = "${sources.yabridge.src.name}/tools/yabridgectl";

    patches = [
      (fetchpatch {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/pkgs/by-name/ya/yabridgectl/chainloader-from-nix-profiles.patch";
        hash = "sha256-Pbc1qN8dfSwGMA+r85YQhqoQEaNKcfHakpEl3AsFLic=";
      })
      (fetchpatch {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/pkgs/by-name/ya/yabridgectl/remove-dependency-verification.patch";
        hash = "sha256-we7OataFPW+3L/t3Atrl8hDV7QaSd12gWqOYuB2qfrw=";
      })
    ];

    patchFlags = [ "-p3" ];

    cargoLock = sources.yabridge.cargoLock."tools/yabridgectl/Cargo.lock";

    nativeBuildInputs = [ makeWrapper ];

    postFixup = ''
      wrapProgram $out/bin/yabridgectl --prefix PATH : ${lib.makeBinPath [ wine ]}
    '';
  };
in
symlinkJoin {
  name = with sources.yabridge; "${pname}-${date}";

  paths = [
    yabridge
    yabridgectl
  ];

  passthru = {
    inherit yabridge yabridgectl wine;
    _ignoreDupe = true;
  };

  meta = {
    description = "Modern and transparent way to use Windows VST2, VST3 and CLAP plugins on Linux";
    homepage = "https://github.com/robbert-vdh/yabridge";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "yabridgectl";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
