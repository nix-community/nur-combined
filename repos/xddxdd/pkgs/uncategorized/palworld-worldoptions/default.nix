{
  sources,
  lib,
  stdenv,
  makeWrapper,
  python3,
  rustPlatform,
}:
let
  uesave-0_3_0 = rustPlatform.buildRustPackage {
    pname = "uesave";
    inherit (sources.uesave-0_3_0) version src;

    cargoHash = "sha256-sSiiMtCuSic0PQn4m1Udv2UbEwHUy0VldpGMYSDGh8g=";
  };
in
stdenv.mkDerivation {
  inherit (sources.palworld-worldoptions) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    rm -rf src/uesave
    sed -i "s/running_dir = .*/running_dir = os.getcwd()/g" src/main.py
  '';

  postInstall = ''
    mkdir -p $out/bin $out/opt
    cp -r src/* $out/opt/

    makeWrapper ${python3}/bin/python3 $out/bin/palworld-worldoptions \
      --add-flags "$out/opt/main.py" \
      --add-flags "--uesave" \
      --add-flags "${uesave-0_3_0}/bin/uesave"
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A tool for creating WorldOption.sav and applying the PalWorldSettings.ini for dedicated servers";
    homepage = "https://github.com/legoduded/palworld-worldoptions";
    # Unspecified license
    license = licenses.unfree;
  };
}
