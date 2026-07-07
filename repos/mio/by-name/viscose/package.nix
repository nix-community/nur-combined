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
bambu-studio.overrideAttrs (old: {
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

  patches = lib.filter (p: builtins.baseNameOf p != "dont-link-opencv-world-bambu.patch") (old.patches or []);

  postPatch = (old.postPatch or "") + ''
    sed -i 's/prepare_node_env()//g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt
    sed -i 's/''${PNPM_EXECUTABLE} install/echo "install"/g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt
    sed -i 's/''${PNPM_EXECUTABLE} run build/mkdir -p dist \&\& touch dist\/index.html/g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt
    sed -i 's/opencv_world/opencv_core\n    opencv_imgproc/g' src/libslic3r/CMakeLists.txt
  '';

  buildInputs = (old.buildInputs or []) ++ [ libnoise assimp ];
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ nodejs pnpm ];

  cmakeFlags = (old.cmakeFlags or []) ++ [
    "-DLIBNOISE_INCLUDE_DIR=${libnoise}/include/noise"
    "-DLIBNOISE_LIBRARY=${libnoise}/lib/libnoise-static.a"
    "-DNODE_EXECUTABLE=${nodejs}/bin/node"
    "-DPNPM_EXECUTABLE=${pnpm}/bin/pnpm"
  ];

  env = (old.env or {}) // {
    NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -I${libnoise}/include/noise";
  };

  meta = old.meta // {
    description = "Viscose — a freedom-respecting fork of Bambu Studio";
    homepage = "https://f.sfconservancy.org/baltobu/viscose";
    maintainers = [ ];
  };
})
