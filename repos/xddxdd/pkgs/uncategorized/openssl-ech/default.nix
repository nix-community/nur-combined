{
  sources,
  lib,
  openssl_3_6,
}:
openssl_3_6.overrideAttrs (old: {
  inherit (sources.openssl-ech) pname version src;

  patches = (builtins.filter (p: !(lib.hasInfix "use-etc-ssl-certs.patch" "${p}")) old.patches) ++ [
    ./use-etc-ssl-certs.patch
  ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenSSL with Encrypted Client Hello support";
    homepage = "https://github.com/sftcd/openssl/tree/ECH-draft-13c";
  };
})
