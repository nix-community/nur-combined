{ options, ... }:
{
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.package = options.sops.package.default.overrideAttrs (old: {
    patches = [
      ./decrypt_file.patch
    ];
  });

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.secrets.github_token = {
    owner = "nixos";
  };
}
