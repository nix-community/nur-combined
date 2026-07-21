{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "1.0.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kodama-community";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mOVBYG5V7vJDDlyeU7A2Y3LKFxiqbMkFnCEWK1wjEfg=";
  };

  cargoHash = "sha256-7EMH40utzbtT1AB64VRlGDBvPpx0fDrWXpOPf/JS+TE=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kodama-community/kodama";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
