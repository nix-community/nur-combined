{
  bash,
  browserpass,
  fetchFromGitea,
  gnused,
  lib,
  sane-scripts,
  sops,
  static-nix-shell,
  stdenv,
  substituteAll,
}:

let
  sops-gpg-adapter = static-nix-shell.mkBash {
    pname = "sops-gpg-adapter";
    srcRoot = ./.;
    pkgs = [ "gnused" "sane-scripts.secrets-unlock" "sops" ];
    postInstall = ''
      ln -s sops-gpg-adapter $out/bin/gpg
      ln -s sops-gpg-adapter $out/bin/gpg2
    '';
  };
in
  browserpass.overrideAttrs (upstream: {
    src = fetchFromGitea {
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
      ln -s $out/lib/browserpass/hosts/firefox/*.json $out/lib/mozilla/native-messaging-hosts
    '';

    passthru = (upstream.passthru or {}) // {
      inherit sops-gpg-adapter;
    };
  })
