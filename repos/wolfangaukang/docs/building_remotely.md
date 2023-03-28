# Building systems remotely

Nixops? deploy-rs? Colmena? Nah, `nixos-rebuild` is your best friend, you can run whatever you need there. (Also we don't have budget for having machines turned on, or having servers deployed somewhere else :D).

## Steps

- First, ensure that the servers you want to enable access have access. Just try to ssh there.
- Optional (and very recommended), try to set passwordless access to the server by associating a SSH key.
- If the other service requires superuser access to run these building commands, then you will need to also check that the sudo user can be accessed.
  - One strategy would be setting `services.openssh.settings.PermitRootLogin` to yes and setting `services.openssh.settings.PasswordAuthentication` to true. Then set a ssh key to access root without password (through `ssh-copy-id`), while being able to use the password when prompted. After doing this, set the first attribute to `prohibit-password`, and set the second attribute to false.
- From here, you might need to specify the key to access root, so you will need to run the `nixos-rebuild` command like this:
  - `NIX_SSHOPTS="-i /path/to/ssh/key" doas nixos-rebuild boot --flake ".#remote_host" --target-host host_ip`
