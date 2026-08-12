{
  lib,
  python3,
  source,
}:

python3.pkgs.buildPythonApplication {
  inherit (source) pname src;

  version = "unstable-${source.date}";

  format = "other";

  dependencies = with python3.pkgs; [
    pycryptodome
  ];

  installPhase = ''
    install -Dm755 $src/sign.py $out/bin/thinkpad-uefi-sign
    install -Dm755 $src/verify.py $out/bin/thinkpad-uefi-verify
  '';

  meta = {
    description = "Tools to check and cryptographically sign UEFI firmware images found in ThinkPads";
    homepage = "https://github.com/thrimbor/thinkpad-uefi-sign";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
