{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lappverk";
  version = "0.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "natkr";
    repo = "lappverk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nn0t8PWHAsG631KFWIcgzZBlGiFQmpEqHwLDhfRCNHk=";
  };

  cargoHash = "sha256-4sD8uTJvX9xaxi/Ert+o/3z+L2bkAqiF4aACWDillnI=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  # no tests available
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lappverk is a tool for modifying other people's software";
    homepage = "https://codeberg.org/natkr/lappverk";
    changelog = "https://codeberg.org/natkr/lappverk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "lappverk";
  };
})
