{
  sources,
  lib,
  stdenv,
  makeWrapper,
  python3,
  uesave-0_3_0,
}:
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
    description = "Tool for creating WorldOption.sav and applying the PalWorldSettings.ini for dedicated servers";
    homepage = "https://github.com/legoduded/palworld-worldoptions";
    # Unspecified license
    license = licenses.unfree;
  };
}
