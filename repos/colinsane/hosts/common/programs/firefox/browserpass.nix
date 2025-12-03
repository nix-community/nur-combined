{ lib, pkgs, ... }:
let
  sops-gpg-adapter = pkgs.static-nix-shell.mkBash {
    pname = "sops-gpg-adapter";
    srcRoot = ./.;
    pkgs = [ "gnused" "sops" ];
    postInstall = ''
      ln -s sops-gpg-adapter $out/bin/gpg
      ln -s sops-gpg-adapter $out/bin/gpg2
    '';
  };
  browserpass = pkgs.browserpass.overrideAttrs (upstream: {
    src = pkgs.fetchFromGitea {
      domain = "git.uninsane.org";
      owner = "colin";
      repo = "browserpass-native";
      # don't forcibly append '.gpg'
      rev = "d3ef88e12cb127914fb0ead762b7baee6913592f";
      hash = "sha256-FRnFmCJI/1f92DOI1VXSPivSBzIR372gmgLUfLLiuPc=";
    };
    installPhase = ''
      make install

      wrapProgram $out/bin/browserpass \
        --prefix PATH : ${lib.makeBinPath [ sops-gpg-adapter ]}

      # This path is used by our firefox wrapper for finding native messaging hosts
      mkdir -p $out/lib/mozilla/native-messaging-hosts
      cp $out/lib/browserpass/hosts/firefox/*.json $out/lib/mozilla/native-messaging-hosts/
    '';

    passthru = (upstream.passthru or {}) // {
      inherit sops-gpg-adapter;
    };
  });
in
{
  sane.programs.browserpass = {
    packageUnwrapped = browserpass;

    sandbox.extraHomePaths = [
      ".config/sops"
      "knowledge/secrets/accounts"
    ];

    # firefox learns about this package by looking in ~/.mozilla/native-messaging-hosts
    fs.".mozilla/native-messaging-hosts/com.github.browserpass.native.json".symlink.target
      = "${browserpass}//lib/mozilla/native-messaging-hosts/com.github.browserpass.native.json";

    # TODO: env.PASSWORD_STORE_DIR only needs to be present within the browser session.
    # alternative to PASSWORD_STORE_DIR:
    # fs.".password-store".symlink.target = "knowledge/secrets/accounts";
    env.PASSWORD_STORE_DIR = "/home/colin/knowledge/secrets/accounts";
  };
}
