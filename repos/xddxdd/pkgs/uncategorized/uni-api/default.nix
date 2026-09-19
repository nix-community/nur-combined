{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-18";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "035560fdceb5a7060aac78e80b04c3f22f099a90";
    hash = "sha256-NYoiYJCdJjt8muYnXVrcMGsrm3h0B1mnR5JtjFfKyuA=";
  };
  cargoRoot = "rust/uni-api-native";
  buildAndTestSubdir = "rust/uni-api-native";

  cargoHash = "sha256-UK6JmTpJ872JucxI+t2poK6KgnllZA4OiRm+/M84u2c=";

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/yym68686/uni-api";
    tagPrefix = "v";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
