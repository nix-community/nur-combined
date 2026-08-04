# Sops-nix

Sops-nix is one of the multiple tools available to handle secrets on a repository. It uses GPG and age keys as decryption methods.

## Setup

- Reference sops-nix on your flake inputs
- Create an ssh key for the server
  - You can set a persistent ssh key (impermanence) and save it to `/etc/ssh/ssh_host_ALGORITHM_key`
- Generate an age key from this SSH key by running `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`. Save the output
- Get your GPG key ID by running `gpg --list-secret-keys`
- Create a `.sops.yaml` on the root of your repository with the following structure:
```yaml
keys:
  - &users:
    - &username pgp_key/age_key 
  - &hosts:
    - &hostname pgp_key/age_key
creation_rules:
  - path_regex: path/to/key.ya?ml$
    key_groups:
    - pgp:
      - *user_with_pgp_key
	  - *host_with_pgp_key
      age:
      - *user_with_age_key
	  - *host_with_age_key
```
- Open a new secrets file with sops by running `sops path/to/secret.yaml`
- Write your secret the following way:
```
secret_name: value
parent_sec:
	subsec: value
```
- To import your secret on your config use the options [here](https://github.com/Mic92/sops-nix/blob/master/modules/sops/default.nix)
- Finally, run `nixos-rebuild`. Your secrets will be located at `/run/secrets/SECRET/NAME`

## Add new keys

- Add new key to `.sops.yaml` file. Remember it should be the public age key.
- For all of the secrets, you need to run `sops updatekeys /path/to/file`

### References
- [Official repository](https://github.com/Mic92/sops-nix)
