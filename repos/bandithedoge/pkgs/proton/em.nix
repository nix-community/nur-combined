{
  fetchzip,
  nix-update-script,
  proton,
}:
proton.mkProton (finalAttrs: {
  pname = "proton-em";
  version = "10.0-37-HDR";
  src = fetchzip {
    url = "https://github.com/Etaash-mathamsetty/Proton/releases/download/EM-${finalAttrs.version}/proton-EM-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-yap/7G6TeJ9vMtc5H/iWu8w3sM8mI6762G+K2JzSlgk=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "EM-(.*)"
      "--use-github-releases"
    ];
  };

  meta = {
    description = "Development Oriented Compatibility tool for Steam Play based on Wine and additional components";
    homepage = "https://github.com/Etaash-mathamsetty/Proton";
  };
})
