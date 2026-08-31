{
  fetchFromGitHub,
  unstableGitUpdater,
  lib,
  openssl_3_6,
}:
openssl_3_6.overrideAttrs (old: {
  pname = "openssl-ech";
  version = "0-unstable-2026-06-09";
  src = fetchFromGitHub {
    owner = "sftcd";
    repo = "openssl";
    rev = "5191045371b4ae1383f0ae1a0f078117e9d9b1c4";
    hash = "sha256-VrO3c0p2goejbgDLFK/0TH++oVKZxtdMC0+DXXS0y3s=";
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

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/sftcd/openssl";
    hardcodeZeroVersion = true;
  };
})
