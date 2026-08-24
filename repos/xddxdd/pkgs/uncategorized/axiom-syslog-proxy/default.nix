{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "axiom-syslog-proxy";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "axiomhq";
    repo = "axiom-syslog-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Dh0G3mFdUmbmPZc2qKPE8MnHOPN+k24CpSDeFb6cx7k=";
  };
  vendorHash = "sha256-tueoQF9+G8ovAe1tIjZllks6zTAVp7La+A7vpdu5hzU=";

  meta = {
    changelog = "https://github.com/axiomhq/axiom-syslog-proxy/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Syslog push interface to Axiom";
    homepage = "https://github.com/axiomhq/axiom-syslog-proxy";
    license = lib.licenses.mit;
    mainProgram = "axiom-syslog-proxy";
  };

  passthru.updateScript = nix-update-script { };
})
