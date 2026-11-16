# use like:
# ```
# $ nix-shell
# [nix-shell:~/nixos/master/pkgs/by-name/mx-sanebot]$ cargo build
# [nix-shell:~/nixos/master/pkgs/by-name/mx-sanebot]$ exit
# ```
{
  pkgs ? import ../../../. { },
}:

let
  inherit (pkgs)
    cacert
    cargo
    mkShell
    mx-sanebot
    ;
in
mkShell {
  nativeBuildInputs =
    mx-sanebot.buildInputs
    ++ mx-sanebot.nativeBuildInputs
    ++ [
      cargo
    ];

  # Allow cargo to download crates.
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
}
