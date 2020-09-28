{ pkgs, ... }:

{
  annotatego = pkgs.callPackage ./annotatego { };
  go-hello-world = pkgs.callPackage ./go-hello-world { };
  nanoc = pkgs.callPackage ./nanoc { };
  rust-hello-world = pkgs.callPackage ./rust-hello-world { };

  # Work around missing functions in factorio-utils
  factorio-mods = pkgs.callPackage ./factorio-mods/mods.nix {
    factorio-utils = pkgs.factorio-utils // {
      fetchurlWithAuth =
        let
          helpMsg = ''

    ===FETCH FAILED===
    Please ensure you have set the username and token with config.nix, or
    /etc/nix/nixpkgs-config.nix if on NixOS.

    Your token can be seen at https://factorio.com/profile (after logging in). It is
    not as sensitive as your password, but should still be safeguarded. There is a
    link on that page to revoke/invalidate the token, if you believe it has been
    leaked or wish to take precautions.

    Example:
    {
      packageOverrides = pkgs: {
        factorio = pkgs.factorio.override {
          username = "FactorioPlayer1654";
          token = "d5ad5a8971267c895c0da598688761";
        };
      };
    }

    Alternatively, instead of providing the username+token, you may manually
    download the release through https://factorio.com/download , then add it to
    the store using e.g.:

      releaseType=alpha
      version=0.17.74
      nix-prefetch-url file://$HOME/Downloads/factorio_\''${releaseType}_x64_\''${version}.tar.xz --name factorio_\''${releaseType}_x64-\''${version}.tar.xz

    Note the ultimate "_" is replaced with "-" in the --name arg!
  '';
        in
        { name, url, sha1 ? "", sha256 ? "", username, token }:
        pkgs.lib.overrideDerivation
          (pkgs.fetchurl {
            inherit name url sha1 sha256;
            curlOpts = [
              "--get"
              "--data-urlencode"
              "username@username"
              "--data-urlencode"
              "token@token"
            ];
          })
          (_: {
            # This preHook hides the credentials from /proc
            preHook = ''
              echo -n "${username}" >username
              echo -n "${token}"    >token
            '';
            failureHook = ''
              cat <<EOF
              ${helpMsg}
              EOF
            '';
          });
    };
  };
} // (if (builtins.hasAttr "lowdown" pkgs && builtins.hasAttr "mdbook" pkgs) then {
  # Newer version of nixUnstable
  nixUnstable = pkgs.nixUnstable.overrideAttrs (oldAttrs: rec {
    name = "nix-3.0${suffix}";
    suffix = "pre20200928_649c465";

    src = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nix";
      rev = "649c465873b20465590d3934fdc0672e4b6b826a";
      sha256 = "0xb2jv24d8n389r58nq6m04ggmgm26ipxy2bsq32hv9zzz6v9317";
    };

    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.mdbook ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.lowdown ];
  });
} else { })
