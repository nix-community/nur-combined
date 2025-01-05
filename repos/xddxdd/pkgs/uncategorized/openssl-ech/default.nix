{
  sources,
  lib,
  openssl,
}:
openssl.overrideAttrs (old: {
  inherit (sources.openssl-ech) pname version src;

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenSSL with Encrypted Client Hello support";
    homepage = "https://github.com/sftcd/openssl/tree/ECH-draft-13c";
  };
})
