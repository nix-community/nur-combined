# Add a new user

## Observations

- If the new user does not need `home-manager`, do not create anything on `home/`

# Steps

To add a new user here, do the following:
- Create a password hash with `mkpasswd -m sha512crypt --stdin`
- Store the generated hash through `sops` at `systems/hosts/common/secrets.yml`
  - The format must be `NEW_USER: GENERATED_HASH`
  - This project contains the `sops-env` shell, with the necessary tools
- Create the user directories at:
  - `home/users/USERNAME`
  - `system/users/USERNAME`
- On the `home/users/USERNAME` directory, create a `default.nix` file with the following content:
  - ```nix
  { config, pkgs, ... }:

  {
    home = {
      username = "USERNAME";
      homeDirectory = "HOME_PATH"; # You can refer to the username with ${config.home.username}
      stateVersion = "23.05";
    };
  }
  ```
  - Obviously, you can edit this according to your needs.
- On the `system/users/USERNAME` directory, create a `default.nix` file with the following content:
  - ```nix
  { pkgs, ... }:

  {
    programs.SHELL.enable = true; # use a shell like bash, zsh, fish, etc
    users.users.USERNAME = {
      isNormalUser = true;
      shell = pkgs.SHELL; # Use the same shell as specified above
      extraGroups = [ "nixers" ]; # Add to the groups you need
    };
  }
  ```
  - Obviously, you can edit this according to your needs.
- On the directories created previously, create a `hosts` directory, and add the configuration files for the hosts you need.
  - For example, if you want to create a user called `amanda` on the `arenal` host, create the {home,system}/users/amanda/hosts directories and add the `arenal.nix` file with the configurations.
- Finally, add the user to the corresponding hosts on `system/hosts/default.nix`. You need to add the new user to the `users` and `hm-users` attributes of the host.
