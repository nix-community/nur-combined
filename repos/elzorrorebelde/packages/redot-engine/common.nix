##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  alsa-lib,
  dbus,
  dotnetCorePackages,
  embree,
  enet,
  fetchFromGitHub,
  fontconfig,
  freetype,
  gettext,
  glib,
  glslang,
  graphite2,
  harfbuzz,
  icu,
  installShellFiles,
  lib,
  libdecor,
  libGL,
  libjpeg_turbo,
  libpulseaudio,
  libtheora,
  libwebp,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  makeWrapper,
  mbedtls,
  openxr-loader,
  pcre2,
  perl,
  pkg-config,
  recastnavigation,
  scons,
  sdl3,
  speechd-minimal,
  stdenv,
  udev,
  vulkan-loader,
  wayland,
  wayland-scanner,
  wslay,
  zstd,

  version,
  tag,
  hash,
  withMono ? true,
  nugetDeps ? null,
}:

let
  mkSconsFlagsFromAttrSet = lib.mapAttrsToList (
    k: v: if builtins.isString v then "${k}=${v}" else "${k}=${builtins.toJSON v}"
  );

  arch = stdenv.hostPlatform.linuxArch;

  dotnet-sdk = if withMono then dotnetCorePackages.sdk_8_0-source else null;

  dottedVersion = lib.replaceStrings [ "-" ] [ "." ] version + lib.optionalString withMono ".mono";

  shortName = "redot";

  mkTarget =
    target:
    let
      editor = target == "editor";
      suffix = lib.optionalString withMono "-mono" + lib.optionalString (!editor) "-template";
      binary = lib.concatStringsSep "." (
        [
          shortName
          "linuxbsd"
          target
        ]
        ++ [ arch ]
        ++ lib.optional withMono "mono"
      );

      attrs = finalAttrs: {
        __structuredAttrs = true;

        pname = "${shortName}${suffix}";
        inherit version;

        src = fetchFromGitHub {
          owner = "Redot-Engine";
          repo = "redot-engine";
          rev = tag;
          inherit hash;
          fetchSubmodules = false;
        };

        outputs = [
          "out"
        ]
        ++ lib.optional editor "man";
        separateDebugInfo = true;

        env = {
          BUILD_NAME = "nur";
        };

        nativeBuildInputs = [
          gettext
          installShellFiles
          perl
          pkg-config
          scons
        ]
        ++ lib.optionals withWayland [ wayland-scanner ]
        ++ lib.optionals (editor && withMono) [
          makeWrapper
          dotnet-sdk
        ];

        buildInputs =
          [
            embree
            enet
            freetype
            glslang
            graphite2
            harfbuzz
            icu
            libjpeg_turbo
            libtheora
            libwebp
            mbedtls
            openxr-loader
            pcre2
            recastnavigation
            sdl3
            wslay
            zstd
          ]
          ++ lib.optionals (editor && withMono) dotnet-sdk.packages
          ++ lib.optional withAlsa alsa-lib
          ++ lib.optional (withX11 || withWayland) libxkbcommon
          ++ lib.optionals withX11 [
            libx11
            libxcursor
            libxext
            libxfixes
            libxi
            libxinerama
            libxrandr
            libxrender
          ]
          ++ lib.optionals withWayland [
            libdecor
            wayland
          ]
          ++ lib.optionals withDbus [
            dbus
          ]
          ++ lib.optionals withFontconfig [
            fontconfig
          ]
          ++ lib.optional withPulseaudio libpulseaudio
          ++ lib.optionals withSpeechd [
            speechd-minimal
            glib
          ]
          ++ lib.optional withUdev udev;

        preConfigure = lib.optionalString (editor && withMono) ''
          # Redot renamed projects from Godot to Redot
          dotnet sln modules/mono/editor/GodotTools/RedotTools.sln \
            remove modules/mono/editor/GodotTools/GodotTools.OpenVisualStudio/RedotTools.OpenVisualStudio.csproj

          dotnet restore modules/mono/glue/GodotSharp/RedotSharp.sln
          dotnet restore modules/mono/editor/GodotTools/RedotTools.sln
          dotnet restore modules/mono/editor/Godot.NET.Sdk/Redot.NET.Sdk.sln
        '';

        # Redot 26.x is based on Godot 4.5 — no NIX_LDFLAGS harfbuzz-raster needed
        preBuild = "";

        sconsFlags = mkSconsFlagsFromAttrSet {
          precision = "single";
          production = true;
          platform = "linuxbsd";
          inherit target;
          debug_symbols = true;

          alsa = withAlsa;
          dbus = withDbus;
          fontconfig = withFontconfig;
          pulseaudio = withPulseaudio;
          speechd = withSpeechd;
          touch = true;
          udev = withUdev;
          wayland = true;
          x11 = true;

          module_mono_enabled = withMono;

          ccflags = "-fno-strict-aliasing";
          linkflags = "-Wl,--build-id";

          builtin_msdfgen = true;
          builtin_rvo2_2d = true;
          builtin_rvo2_3d = true;
          builtin_xatlas = true;
          builtin_clipper2 = true;
          builtin_miniupnpc = true;

          use_sowrap = false;
          redirect_build_objects = false;
        };

        enableParallelBuilding = true;
        strictDeps = true;

        postPatch = ''
          # this stops scons from hiding e.g. NIX_CFLAGS_COMPILE
          perl -pi -e '{ $r += s:(env = Environment\(.*):\1\nenv["ENV"] = os.environ: } END { exit ($r != 1) }' SConstruct

          substituteInPlace thirdparty/glad/egl.c \
            --replace-fail \
              'static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"}' \
              'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libEGL.so"}'

          substituteInPlace thirdparty/glad/gl.c \
            --replace-fail \
              'static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"}' \
              'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libGLESv2.so"}'

          substituteInPlace thirdparty/glad/gl{,x}.c \
            --replace-fail \
              '"libGL.so.1"' \
              '"${lib.getLib libGL}/lib/libGL.so"'

          substituteInPlace thirdparty/volk/volk.c \
            --replace-fail \
              'dlopen("libvulkan.so.1"' \
              'dlopen("${lib.getLib vulkan-loader}/lib/libvulkan.so"'
        '';

        postBuild = lib.optionalString (editor && withMono) ''
          echo "Generating Glue"
          bin/${binary} --headless --generate-mono-glue modules/mono/glue
          echo "Building C#/.NET Assemblies"
          python modules/mono/build_scripts/build_assemblies.py --godot-output-dir bin --precision=single
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p "$out"/{bin,libexec}
          cp -r bin/${binary} "$out"/libexec/

          cd "$out"/bin
          ln -s ../libexec/${binary} redot-engine${suffix}
          cd -
        ''
        + (
          if editor then
            ''
              installManPage misc/dist/linux/${shortName}.6

              mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
              cp misc/dist/linux/org.redotengine.Redot.desktop \
                "$out/share/applications/org.redotengine.Redot${suffix}.desktop"

              substituteInPlace "$out/share/applications/org.redotengine.Redot${suffix}.desktop" \
                --replace-fail "Exec=redot" "Exec=$out/bin/redot-engine${suffix}" \
                --replace-fail "Redot Engine" "Redot Engine ${version}"

              cp icon.svg "$out/share/icons/hicolor/scalable/apps/redot-engine.svg"
              cp icon.png "$out/share/icons/redot-engine.png"
            ''
            + lib.optionalString withMono ''
              cp -r bin/GodotSharp "$out"/libexec/
              mkdir -p "$out"/share/nuget
              mv "$out"/libexec/GodotSharp/Tools/nupkgs "$out"/share/nuget/source

              wrapProgram "$out"/libexec/${binary} \
                --prefix NUGET_FALLBACK_PACKAGES ';' "$out"/share/nuget/packages/
            ''
          else
            let
              tname = {
                template_release = "linux_release";
                template_debug = "linux_debug";
              }.${target};
            in
              ''
		templates="$out"/share/godot/export_templates/${dottedVersion}
              mkdir -p "$templates"
              ln -s "$out"/libexec/${binary} "$templates"/${tname}.${arch}
              ''
        )
        + ''
          runHook postInstall
        '';

        passthru = lib.optionalAttrs editor {
          export-template = mkTarget "template_release";
          export-template-debug = mkTarget "template_debug";
        };

        requiredSystemFeatures = [ "big-parallel" ];

        meta = with lib; {
          changelog = "https://github.com/Redot-Engine/redot-engine/releases/tag/${tag}";
          description = "Free and Open Source 2D and 3D game engine (Redot fork of Godot)";
          homepage = "https://redotengine.org";
          license = licenses.mit;
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          maintainers = with maintainers; [ elzorrorebelde ];
          mainProgram = "redot-engine${suffix}";
        };
      };

      unwrapped = stdenv.mkDerivation (
        if (editor && withMono) then
          dotnetCorePackages.addNuGetDeps {
            inherit nugetDeps;
            overrideFetchAttrs = old: rec {
              runtimeIds = map (system: dotnetCorePackages.systemToDotnetRid system) old.meta.platforms;
              buildInputs =
                old.buildInputs
                ++ lib.concatLists (lib.attrValues (lib.getAttrs runtimeIds dotnet-sdk.targetPackages));
            };
          } attrs
        else
          attrs
      );

      wrapper =
        if (editor && withMono) then
          stdenv.mkDerivation (finalAttrs: {
            __structuredAttrs = true;

            pname = "${shortName}${suffix}-wrapper";
            inherit (finalAttrs.unwrapped) version outputs meta;
            inherit unwrapped dotnet-sdk;

            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;

            nativeBuildInputs = [ makeWrapper ];
            strictDeps = true;

            installPhase = ''
              runHook preInstall

              mkdir -p "$out"/{bin,libexec,share/applications,nix-support}

              cp -d "$unwrapped"/bin/* "$out"/bin/
              ln -s "$unwrapped"/libexec/* "$out"/libexec/
              ln -s "$unwrapped"/share/nuget "$out"/share/
              cp "$unwrapped/share/applications/org.redotengine.Redot${suffix}.desktop" \
                "$out/share/applications/org.redotengine.Redot${suffix}.desktop"

              substituteInPlace "$out/share/applications/org.redotengine.Redot${suffix}.desktop" \
                --replace-fail "Exec=$unwrapped/bin/redot-engine${suffix}" "Exec=$out/bin/redot-engine${suffix}"
              ln -s "$unwrapped"/share/icons $out/share/

              echo "${finalAttrs.dotnet-sdk}" >> "$out"/nix-support/propagated-build-inputs

              wrapProgram "$out"/libexec/${binary} \
                --prefix PATH : "${lib.makeBinPath [ finalAttrs.dotnet-sdk ]}"

              runHook postInstall
            '';

            postFixup = lib.concatMapStringsSep "\n" (output: ''
              [[ -e "''$${output}" ]] || ln -s "${unwrapped.${output}}" "''$${output}"
            '') finalAttrs.unwrapped.outputs;

            inherit (unwrapped) passthru;
          })
        else
          unwrapped;
    in
      wrapper;

  withAlsa = true;
  withDbus = true;
  withFontconfig = true;
  withPulseaudio = true;
  withSpeechd = true;
  withUdev = true;
  withWayland = true;
  withX11 = true;
in
  mkTarget "editor"
