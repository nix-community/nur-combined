{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  pyudev,
}:
buildPythonPackage rec {
  inherit (sources.smfc) pname version src;
  pyproject = true;

  build-system = [ setuptools ];

  propagatedBuildInputs = [ pyudev ];

  pythonImportsCheck = [ "smfc" ];

  postPatch = ''
    patchShebangs .

    substituteInPlace config/smfc.conf \
      --replace-fail "/usr/bin/" "" \
      --replace-fail "/usr/sbin/" ""

    for F in src/smfc/*.py; do
      substituteInPlace "$F" \
        --replace-quiet "/usr/bin/" "" \
        --replace-quiet "/usr/sbin/" ""
    done
  '';

  postInstall = ''
    install -Dm644 config/smfc.conf $out/etc/smfc.conf
  '';

  meta = {
    changelog = "https://github.com/petersulyok/smfc/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Super Micro Fan Control";
    homepage = "https://github.com/petersulyok/smfc";
    license = with lib.licenses; [ gpl3Only ];
    mainProgram = "smfc";
  };
}

# stdenv.mkDerivation (finalAttrs: {
#   inherit (sources.smfc) pname version src;

#   nativeBuildInputs = [ makeWrapper ];

#   postPatch = ''
#     sed -i "s#/usr/bin/ipmitool#${ipmitool}/bin/ipmitool#g" src/smfc.conf src/smfc.py
#     sed -i "s#/usr/bin/python3#${python3}/bin/python3#g" src/smfc.conf src/smfc.py
#     sed -i "s#/usr/sbin/hddtemp#${hddtemp}/bin/hddtemp#g" src/smfc.conf src/smfc.py
#     sed -i "s#/usr/sbin/smartctl#${smartmontools}/bin/smartctl#g" src/smfc.conf src/smfc.py
#   '';

#   installPhase = ''
#     runHook preInstall

#     mkdir -p $out/bin
#     install -Dm644 src/smfc.conf $out/etc/smfc.conf
#     install -Dm755 src/smfc.py $out/opt/smfc.py
#     makeWrapper ${python3}/bin/python3 $out/bin/smfc \
#       --add-flags "$out/opt/smfc.py"

#     runHook postInstall
#   '';

#   meta = {
#     changelog = "https://github.com/petersulyok/smfc/releases/tag/v${finalAttrs.version}";
#     maintainers = with lib.maintainers; [ xddxdd ];
#     description = "Super Micro Fan Control";
#     homepage = "https://github.com/petersulyok/smfc";
#     license = with lib.licenses; [ gpl3Only ];
#     mainProgram = "smfc";
#   };
# })
