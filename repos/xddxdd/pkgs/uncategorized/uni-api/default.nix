{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-23";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "1fcb3eb9082f2cc23621f64379c386378224f0a0";
    hash = "sha256-NAwwiqpJinJYqJXR1mIwh+y0Z8flKTJ+nmpEATJW1jk=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-RcV6YYa9VzgeSXJCDkt+J9DsSCUZie9x0HTsiL5rHhE=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
