- nix_signing_key.bin:
  - generate with `nix-store --generate-binary-cache-key desko cache-priv-key.pem cache-pub-key.pem`
  - used when deploying packages to a remote machine
- colin-passwd.bin:
  - generate with `mkpasswd -m sha512crypt`, or `mkpasswd --rounds=2000000 --method=sha512crypt`
- guest/authorized_keys.bin
  - who's allowed to login to the guest account
