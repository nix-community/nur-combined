{
  fetchFromGitHub,
  lib,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cc-switch-cli";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "SaladDay";
    repo = "cc-switch-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JwtgT8cP+i7hsaB13o0PTDZJWvC3os1zWagMqmbffXk=";
  };

  sourceRoot = "${finalAttrs.src.name}/src-tauri";

  cargoHash = "sha256-m70IR0IFUj8C48WcHgdCCtPwW/8KOxeDIqgG1bIcOpo=";

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform CLI All-in-One assistant tool for Claude Code, Codex & Gemini CLI";
    homepage = "https://github.com/SaladDay/cc-switch-cli";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
