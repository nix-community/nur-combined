{ options, ... }:
{
  sops.age.keyFile = "/persist/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.package = options.sops.package.default.overrideAttrs (old: {
    patches = [
      ./decrypt_file.patch
    ];
  });
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
}
