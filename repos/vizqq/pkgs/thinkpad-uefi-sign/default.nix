{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication {
  pname = "thinkpad-uefi-sign";
  version = "0.1";

  format = "other";

  src = fetchFromGitHub {
    owner = "thrimbor";
    repo = "thinkpad-uefi-sign";
    rev = "b502420583b8a38d4b3e706b20a51a435740f749";
    hash = "sha256-FqyrTZQWSKcDLLrG6jfrrW+vtAOUgE65C5jP3v3To8U=";
  };

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
