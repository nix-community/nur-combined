{
  fetchzip,
  nix-update-script,
  proton,
}:
proton.mkProton (finalAttrs: {
  pname = "proton-sarek";
  version = "10-3-r1";
  src = fetchzip {
    url = "https://github.com/pythonlover02/Proton-Sarek/releases/download/Proton-Sarek${finalAttrs.version}/Proton-Sarek${finalAttrs.version}.tar.gz";
    sha256 = "sha256-UCog5Q1ixqdBhApaXT4ZEXL03udF28ps4f92eVbmHtE=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "Proton-Sarek(.*)"
    ];
  };

  meta = {
    description = "Steam Play compatibility tool based on Wine and additional components, with a focus on older PCs";
    homepage = "https://github.com/pythonlover02/Proton-Sarek";
  };
})
