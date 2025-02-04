{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sftpgo-plugin-auth";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "sftpgo";
    repo = "sftpgo-plugin-auth";
    rev = "v${version}";
    hash = "sha256-hwg1D97dw276OoaupAdBOmIadLny7y7RtY/sv29meFw=";
  };

  vendorHash = "sha256-tkeldkN8aMosOjwaypFfjYHKN38Et7X4fDHtKeRfTE0=";

  ldflags = [ "-s" "-w" ];

  doCheck = false;

  preBuild = ''
    substituteInPlace authenticator/ldap.go \
      --replace-fail "user.HomeDir = filepath.Join(a.BaseDir, user.Username)" "user.HomeDir = a.BaseDir"
  '';

  meta = {
    description = "LDAP/Active Directory authentication for SFTPGo";
    homepage = "https://github.com/sftpgo/sftpgo-plugin-auth";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sftpgo-plugin-auth";
  };
}
