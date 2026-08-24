{
  fetchzip,
  nix-update-script,
  proton,
}:
proton.mkProton (finalAttrs: {
  pname = "proton-sarek-async";
  version = "10-3-r1";
  src = fetchzip {
    url = "https://github.com/pythonlover02/Proton-Sarek/releases/download/Proton-Sarek${finalAttrs.version}/Proton-Sarek${finalAttrs.version}-async.tar.gz";
    sha256 = "sha256-iRpwuE80F/0UrekQhDirwI3oqvbfQtCZChl+sWfJVps=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "Proton-Sarek(.*)"
    ];
  };

  meta = {
    description = "Steam Play compatibility tool based on Wine and additional components, with a focus on older PCs (with DXVK async)";
    homepage = "https://github.com/pythonlover02/Proton-Sarek";
  };
})
