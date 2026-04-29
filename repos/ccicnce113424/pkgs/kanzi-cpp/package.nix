{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kanzi-cpp";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "flanglet";
    repo = "kanzi-cpp";
    tag = finalAttrs.version;
    hash = "sha256-nuHqJwAm3ySRwbTffMj4hgL+W0f49IqI1S5Q06SZc9U=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  strictDeps = true;
  __structuredAttrs = true;

  cmakeFlags = [ (lib.cmakeBool "KANZI_ENABLE_NATIVE_OPTIMIZATIONS" false) ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Fast lossless data compressor";
    homepage = "https://github.com/flanglet/kanzi-cpp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "kanzi";
  };
})
