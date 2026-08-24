{
  fetchzip,
  nix-update-script,
  proton,
}:
proton.mkProton (finalAttrs: {
  pname = "proton-cachyos";
  version = "11.0-20260703";
  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64_v3.tar.xz";
    sha256 = "sha256-8Y7orUvnFOG0zSqCrMyvmclmy3JInj7d8A2h0Y7RwhE=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "cachyos-(.*)-slr"
    ];
  };

  meta = {
    description = "A compatibility tool for Steam Play based on Wine and additional components, experimental branch with extra CachyOS flavour";
    homepage = "https://github.com/CachyOS/proton-cachyos";
    broken = true; # broken symlinks
  };
})
