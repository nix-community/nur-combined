{
  lib,
  bambu-studio,
  fetchFromGitea,
  libnoise,
  assimp,
  nodejs,
  pnpm,
}:

# Viscose is a fork of Bambu Studio maintained at the Software Freedom
# Conservancy Forgejo, tracking Bambu Lab releases while improving user
# software freedom.
# https://f.sfconservancy.org/baltobu/viscose
bambu-studio.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "viscose";

    # Last commit of https://f.sfconservancy.org/baltobu/viscose
    # as of 2026-07-07: 22638157e2680dfffcf65062f0caf1152ca40252
    src = fetchFromGitea {
      domain = "f.sfconservancy.org";
      owner = "baltobu";
      repo = "viscose";
      rev = "22638157e2680dfffcf65062f0caf1152ca40252";
      hash = "sha256-VKG26jqi7x0LvhkZbGV8NyTPcssHFfc9v5eZoVyz2dw=";
      fetchSubmodules = true;
    };

    patches = lib.filter (p: builtins.baseNameOf p != "dont-link-opencv-world-bambu.patch") (
      previousAttrs.patches or [ ]
    );

    postPatch = (previousAttrs.postPatch or "") + ''
      substituteInPlace src/slic3r/GUI/DeviceWeb/CMakeLists.txt \
        --replace-fail 'prepare_node_env()' "" \
        --replace-fail "\''${PNPM_EXECUTABLE} install" 'echo "install"' \
        --replace-fail "\''${PNPM_EXECUTABLE} run build" 'mkdir -p dist && touch dist/index.html'

      substituteInPlace src/libslic3r/CMakeLists.txt \
        --replace-fail 'opencv_world' 'opencv_core
      opencv_imgproc'
    '';

    buildInputs = (previousAttrs.buildInputs or [ ]) ++ [
      libnoise
      assimp
    ];
    nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
      nodejs
      pnpm
    ];

    cmakeFlags = (previousAttrs.cmakeFlags or [ ]) ++ [
      "-DLIBNOISE_INCLUDE_DIR=${libnoise}/include/noise"
      "-DLIBNOISE_LIBRARY=${libnoise}/lib/libnoise-static.a"
      "-DNODE_EXECUTABLE=${nodejs}/bin/node"
      "-DPNPM_EXECUTABLE=${pnpm}/bin/pnpm"
    ];

    env = (previousAttrs.env or { }) // {
      NIX_CFLAGS_COMPILE = (previousAttrs.env.NIX_CFLAGS_COMPILE or "") + " -I${libnoise}/include/noise";
    };

    meta = previousAttrs.meta // {
      description = "Viscose — a freedom-respecting fork of Bambu Studio";
      homepage = "https://f.sfconservancy.org/baltobu/viscose";
      maintainers = [ ];
    };
  }
)
