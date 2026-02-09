{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "endfield-daily";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = "endfield-daily";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wBCa4VpSvHyegyRFVtAgp1dZbKsqkb1XUE46Nz2R8kQ=";
  };

  vendorHash = "sha256-2U9hBA+q3nW4YO47PN+eorBLq0z4kj2zCZ6q7wD75PQ=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Daily check-in bot for Arknights: Endfield";
    homepage = "https://github.com/AtaraxiaSjel/endfield-daily";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "endfield-daily";
  };
})
