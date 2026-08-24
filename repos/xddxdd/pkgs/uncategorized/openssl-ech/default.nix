{
  fetchFromGitHub,
  lib,
  openssl_3_6,
}:
openssl_3_6.overrideAttrs (old: {
  pname = "openssl-ech";
  version = "0-unstable-2025-11-18";
  src = fetchFromGitHub {
    owner = "sftcd";
    repo = "openssl";
    rev = "65f2fe12ef471783771fb8058329380b7158e963";
    hash = "sha256-CwytIig/QaRpB/1sCb0i9DXPLDH0ZMY8CKn4DacYc6E=";
  };
  patches =
    (builtins.filter (
      p: !(lib.hasInfix "use-etc-ssl-certs.patch" "${p}") && !(lib.hasInfix "aes-gcm-ppc" "${p}")
    ) old.patches)
    ++ [ ./use-etc-ssl-certs.patch ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenSSL with Encrypted Client Hello support";
    homepage = "https://github.com/sftcd/openssl/tree/ECH-draft-13c";
  };
})
