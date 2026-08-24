{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  makeWrapper,
  python3,
  uesave-0_3_0,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "palworld-worldoptions";
  version = "1.11.0";
  src = fetchFromGitHub {
    owner = "legoduded";
    repo = "palworld-worldoptions";
    tag = "v1.11.0";
    hash = "sha256-U0PlWK5KPr6m9nIrD+qWRiKWb4zr2hBCEROVI5qBor0=";
  };
  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    rm -rf src/uesave
    sed -i "s/running_dir = .*/running_dir = os.getcwd()/g" src/main.py
  '';

  postInstall = ''
    mkdir -p $out/bin $out/opt
    cp -r src/* $out/opt/

    makeWrapper ${lib.getExe python3} $out/bin/palworld-worldoptions \
      --add-flags "$out/opt/main.py" \
      --add-flags "--uesave" \
      --add-flags "${lib.getExe uesave-0_3_0}"
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/legoduded/palworld-worldoptions/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Tool for managing Palworld dedicated server settings";
    homepage = "https://github.com/legoduded/palworld-worldoptions";
    # Unspecified license
    license = lib.licenses.unfree;
    mainProgram = "palworld-worldoptions";
  };
})
