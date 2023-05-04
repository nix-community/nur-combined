{ config, ... }:

{
  # SOPS configuration:
  #   docs: https://github.com/Mic92/sops-nix
  #
  # for each new user you want to edit sops files:
  # create a private age key from ssh key:
  #   $ mkdir -p ~/.config/sops/age; ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt; chmod 600 ~/.config/sops/age/keys.txt
  #   if the private key was password protected, then first decrypt it:
  #     $ cp ~/.ssh/id_ed25519 /tmp/id_ed25519
  #     $ ssh-keygen -p -N "" -f /tmp/id_ed25519
  #
  # for each user you want to decrypt secrets:
  #   $ cat ~/.ssh/id_ed25519.pub | ssh-to-age
  #   add the result to .sops.yaml
  #   since we specify ssh pubkeys in the nix config, you can just grep for `ssh-ed25519` here and use those instead
  #
  # for each host you want to decrypt secrets:
  #   $ cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
  #   add the result to .sops.yaml
  #   $ sops updatekeys secrets/example.yaml
  #
  # to create a new secret:
  #   $ sops secrets/example.yaml
  #   control access below (sops.secret.<x>.owner = ...)
  #
  # to read a secret:
  #   $ cat /run/secrets/example_key

  # sops.age.sshKeyPaths = [ "/home/colin/.ssh/id_ed25519_dec" ];
  # This will add secrets.yaml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ../../secrets/universal.yaml;
  sops.gnupg.sshKeyPaths = [];  # disable RSA key import
  # This is using an age key that is expected to already be in the filesystem
  # sops.age.keyFile = "/home/colin/.ssh/age.pub";
  # sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  # sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  # sops.secrets.example_key = {
  #   owner = config.users.users.colin.name;
  # };
  # sops.secrets."myservice/my_subdir/my_secret" = {};

  ## universal secrets
  # TODO: glob these?

  sops.secrets."jackett_apikey" = {
    sopsFile = ../../secrets/universal.yaml;
    owner = config.users.users.colin.name;
  };
  sops.secrets."mx-sanebot-env" = {
    sopsFile = ../../secrets/universal/mx-sanebot-env.bin;
    format = "binary";
    owner = config.users.users.colin.name;
  };
  sops.secrets."router_passwd" = {
    sopsFile = ../../secrets/universal.yaml;
  };
  sops.secrets."transmission_passwd" = {
    sopsFile = ../../secrets/universal.yaml;
  };
  sops.secrets."wg_ovpnd_us_privkey" = {
    sopsFile = ../../secrets/universal.yaml;
  };
  sops.secrets."wg_ovpnd_us-atl_privkey" = {
    sopsFile = ../../secrets/universal.yaml;
  };
  sops.secrets."wg_ovpnd_us-mi_privkey" = {
    sopsFile = ../../secrets/universal.yaml;
  };
  sops.secrets."wg_ovpnd_ukr_privkey" = {
    sopsFile = ../../secrets/universal.yaml;
  };

  sops.secrets."snippets" = {
    sopsFile = ../../secrets/universal/snippets.bin;
    format = "binary";
    owner = config.users.users.colin.name;
  };

  sops.secrets."bt/car" = {
    sopsFile = ../../secrets/universal/bt/car.bin;
    format = "binary";
  };
  sops.secrets."bt/earbuds" = {
    sopsFile = ../../secrets/universal/bt/earbuds.bin;
    format = "binary";
  };
  sops.secrets."bt/portable-speaker" = {
    sopsFile = ../../secrets/universal/bt/portable-speaker.bin;
    format = "binary";
  };

  sops.secrets."iwd/community-university.psk" = {
    sopsFile = ../../secrets/universal/net/community-university.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/friend-libertarian-dod.psk" = {
    sopsFile = ../../secrets/universal/net/friend-libertarian-dod.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/friend-rationalist-empathist.psk" = {
    sopsFile = ../../secrets/universal/net/friend-rationalist-empathist.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/home-shared.psk" = {
    sopsFile = ../../secrets/universal/net/home-shared.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/makespace-south.psk" = {
    sopsFile = ../../secrets/universal/net/makespace-south.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/archive-2023-02-home-bedroom.psk" = {
    sopsFile = ../../secrets/universal/net/archive/2023-02-home-bedroom.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/archive-2023-02-home-shared-24G.psk" = {
    sopsFile = ../../secrets/universal/net/archive/2023-02-home-shared-24G.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/archive-2023-02-home-shared.psk" = {
    sopsFile = ../../secrets/universal/net/archive/2023-02-home-shared.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/iphone" = {
    sopsFile = ../../secrets/universal/net/iphone.psk.bin;
    format = "binary";
  };
  sops.secrets."iwd/parents" = {
    sopsFile = ../../secrets/universal/net/parents.psk.bin;
    format = "binary";
  };
}


