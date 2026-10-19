{ lib
, buildDotnetModule
, clangStdenv
, dotnetCorePackages
, fetchFromGitHub
, rustPlatform
, libicns
, librashader
, SDL2
, libGL
, libx11
, libxcursor
, libxext
, libxi
, libxrandr
}:

let
  # Shader support. Upstream's CI bundles librashader built from this fork's
  # Mesen branch (.github/actions/get-librashader-action): 0.12.0 plus a commit
  # that keeps shader parameters in the order the shaders declare them, which
  # the shader settings window lists them in. nixpkgs has 0.11.2.
  librashader' = librashader.overrideAttrs (finalAttrs: _: {
    version = "0.12.0-unstable-2026-09-05";

    src = fetchFromGitHub {
      owner = "SourMesen";
      repo = "librashader";
      rev = "01febce641d9e97ff99bfa266bcb17343609e296";
      hash = "sha256-Nv7y75Kc/Xw0kbf1ilyTj4WHDkt79DQcQXuMKEPWU60=";
    };

    # nixpkgs' fix-optional-dep-syntax.patch, rebased: cargo-auditable chokes
    # on the capi crate's implicit features for optional dependencies.
    patches = [ ./librashader-capi-dep-syntax.patch ];

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-NiNb3cdlPmnvr3PBoYjTs9Blv/CssSfPUnFv33vIPUM=";
    };
  });
in
buildDotnetModule (finalAttrs: {
  pname = "mesence";
  version = "2.2.1-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "nesdev-org";
    repo = "MesenCE";
    rev = "4b8a196e299b3de297b204fd1208d2981562c89b";
    hash = "sha256-jj3UcOfop8Ss+rSmlFhpqBzG15YbitDjLGsz9zxSMjM=";
  };

  patches = [
    # Upstream embeds the native libraries in the executable, extracts them to
    # the data folder on every start, and loads them from there. Leave them out
    # of the archive and load them from beside the executable, where they are
    # patched against the store. The rest of the archive (the NES game
    # database, Satellaview data) is still extracted.
    ./native-libraries-from-install-dir.patch
    # The shortcut written when associating ROMs points at the executable the
    # process runs from, which skips the wrapper.
    ./shortcut-exec-on-path.patch
  ];

  postPatch = ''
    # Shown and linked to in Help > About, as in upstream's CI builds.
    echo ${finalAttrs.src.rev} > UI/Dependencies/Internal/BuildSha.txt
  '';

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  projectFile = "UI/UI.csproj";
  nugetDeps = ./deps.json;

  dotnetFlags = [
    # UI.csproj defaults to win-x64.
    "-p:RuntimeIdentifier=${dotnetCorePackages.systemToDotnetRid clangStdenv.hostPlatform.system}"
    # What upstream's makefile passes for release builds; without it Release
    # is unoptimized and compiled with DEBUG defined.
    "-p:OptimizeUi=true"
  ];

  executables = [ "Mesen" ];

  nativeBuildInputs = [ libicns ];

  # All dlopen-ed: SDL2 (audio), libGL and libX11 (the core's OpenGL renderer)
  # and librashader by the core, the X11 libraries by Avalonia.
  runtimeDeps = [
    SDL2
    libGL
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    librashader'
  ];

  postInstall = ''
    ln -s ${finalAttrs.passthru.core}/lib/MesenCore.so $out/lib/${finalAttrs.pname}

    # Upstream's, from the AppImage. Installed under the name of the shortcut
    # Mesen writes when associating ROMs, which then takes its place rather
    # than showing up beside it.
    install -Dm644 Linux/appimage/Mesen.desktop $out/share/applications/mesen.desktop
    install -Dm644 Linux/appimage/Mesen.48x48.png $out/share/icons/hicolor/48x48/apps/Mesen.png
    # icns2png segfaults extracting every size at once, but not one at a time.
    for size in 32 128 256 512; do
      icns2png -x -s $size -d 32 UI/Assets/MesenIcon.icns
      install -Dm644 MesenIcon_''${size}x''${size}x32.png \
        $out/share/icons/hicolor/''${size}x$size/apps/Mesen.png
    done
  '';

  passthru = {
    librashader = librashader';

    # The emulation core, built with clang as upstream recommends for speed.
    core = clangStdenv.mkDerivation {
      pname = "mesence-core";
      inherit (finalAttrs) version src;

      enableParallelBuilding = true;
      strictDeps = true;

      # SDL2, libX11, libGL and librashader are all loaded at runtime; libevdev
      # is vendored.
      makeFlags = [
        "core"
        # Otherwise libstdc++ and libgcc are linked statically, for the AppImage.
        "STATICLINK=false"
      ];

      installPhase = ''
        runHook preInstall
        install -Dm755 InteropDLL/obj.*/MesenCore.so -t $out/lib
        runHook postInstall
      '';
    };
  };

  meta = {
    description = "Multi-system emulator for NES, SNES, Game Boy (Advance), PC Engine, SMS/Game Gear and WonderSwan";
    longDescription = ''
      MesenCE is the community edition of Mesen, maintained by nesdev.org, with
      an extensive debugger for every system it emulates. This builds the
      latest master; nixpkgs' `mesen` is the last release.
    '';
    homepage = "https://github.com/nesdev-org/MesenCE";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [
      {
        name = "arielherself";
        github = "arielherself";
        githubId = 107245128;
      }
    ];
    mainProgram = "Mesen";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})
