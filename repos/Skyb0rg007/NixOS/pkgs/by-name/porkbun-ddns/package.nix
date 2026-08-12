{
  lib,
  pkgs,
  fetchFromGitHub,
  python3,
  stdenv,
  nix-update-script,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "porkbun-ddns";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mietzen";
    repo = "porkbun-ddns";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SSLNCmFaW9P5+LXPDcVUvyWGOGMXd1kqXbxTlYUTsas=";
  };

  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [
    jinja2
    xdg-base-dirs
  ];
  nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];
  enabledTestPaths = [ "porkbun_ddns/test" ];

  passthru.updateScript = nix-update-script { };

  doCheck = !stdenv.hostPlatform.isDarwin;

  meta = {
    description = "An unofficial DDNS-Client for Porkbun Domains";
    longDescription = ''
      porkbun-ddns is a unofficial DDNS-Client for Porkbun Domains.
      This library will only update the records if the IP(s) have changed or
      the dns entry didn't exist before, it will also set/update A (IPv4) and
      AAAA (IPv6) records.
    '';
    homepage = "https://github.com/mietzen/porkbun-ddns";
    license = lib.licenses.mit;
    mainProgram = "porkbun-ddns";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
