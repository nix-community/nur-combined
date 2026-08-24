{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  stdenv,
  symlinkJoin,

  asio,
  dbus,
  fetchpatch,
  ghc_filesystem,
  libxcb,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  replaceVars,
  tomlplusplus,
  wineWow64Packages,
}:
let
  wine = wineWow64Packages.staging;

  version = "5.1.1-unstable-2026-08-02";
  src = fetchFromGitHub {
    owner = "robbert-vdh";
    repo = "yabridge";
    rev = "b580a9f7fc46509767ca156d4f92872552b9e571";
    hash = "sha256-TiKiyE3GZYCX1+vooHdD03fAhNQPAA1IzTfkG++I7TY=";
  };

  yabridge = stdenv.mkDerivation {
    pname = "yabridge";
    inherit version src;

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
      cp -r --no-preserve=mode,ownership ${
        fetchFromGitHub {
          owner = "fraillt";
          repo = "bitsery";
          rev = "v5.2.5";
          hash = "sha256-f+qMhyUfQIqJC1r/rwtFV0+Sd04vCoOa7AkfgusDyG8=";
        }
      } subprojects/bitsery
      cp subprojects/packagefiles/bitsery/* subprojects/bitsery/

      cp -r --no-preserve=mode,ownership ${
        fetchFromGitHub {
          owner = "Naios";
          repo = "function2";
          rev = "4.2.5";
          hash = "sha256-+a8+HHFmAUJouRlmoQyvluZcj3Ebpx2EWw6mMz8wx2o=";
        }
      } subprojects/function2
      cp subprojects/packagefiles/function2/* subprojects/function2/

      cp -r --no-preserve=mode,ownership ${ghc_filesystem.src} subprojects/ghc_filesystem
      cp subprojects/packagefiles/ghc_filesystem/* subprojects/ghc_filesystem/

      cp -r --no-preserve=mode,ownership ${
        fetchFromGitHub {
          owner = "free-audio";
          repo = "clap";
          rev = "1.1.9";
          hash = "sha256-z2P0U2NkDK1/5oDV35jn/pTXCcspuM1y2RgZyYVVO3w=";
        }
      } subprojects/clap
      cp subprojects/packagefiles/clap/* subprojects/clap/

      cp -r --no-preserve=mode,ownership ${
        fetchFromGitHub {
          owner = "robbert-vdh";
          repo = "vst3sdk";
          rev = "v3.7.7_build_19-patched";
          hash = "sha256-LsPHPoAL21XOKmF1Wl/tvLJGzjaCLjaDAcUtDvXdXSU=";
          fetchSubmodules = true;
        }
      } subprojects/vst3

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
    inherit version src;
    sourceRoot = "source/tools/yabridgectl";

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

    cargoHash = "sha256-VcBQxKjjs9ESJrE4F1kxEp4ah3j9jiNPq/Kdz/qPvro=";

    patchFlags = [ "-p3" ];

    nativeBuildInputs = [ makeWrapper ];

    postFixup = ''
      wrapProgram $out/bin/yabridgectl --prefix PATH : ${lib.makeBinPath [ wine ]}
    '';
  };
in
symlinkJoin {
  pname = "yabridge";
  inherit version src;

  paths = [
    yabridge
    yabridgectl
  ];

  passthru = {
    inherit yabridge yabridgectl wine;
    _ignoreDupe = true;

    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
        "--subpackage"
        "yabridge"
        "--subpackage"
        "yabridgectl"
      ];
    };
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
