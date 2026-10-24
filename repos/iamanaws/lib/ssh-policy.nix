# Review this allowlist when updating OpenSSH; checks validate the rendered policy.
# https://www.openssh.com/releasenotes.html
# https://man.openbsd.org/sshd_config
{
  # Hybrid post-quantum exchange first, with Curve25519 compatibility.
  kexAlgorithms = [
    "mlkem768x25519-sha256"
    "sntrup761x25519-sha512"
    "sntrup761x25519-sha512@openssh.com"
    "curve25519-sha256"
    "curve25519-sha256@libssh.org"
  ];

  # Authenticated encryption only.
  ciphers = [
    "chacha20-poly1305@openssh.com"
    "aes256-gcm@openssh.com"
    "aes128-gcm@openssh.com"
  ];

  # AEAD ciphers authenticate internally; retain a strict MAC policy for overrides.
  macs = [
    # "hmac-sha2-512" # ?
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
  ];

  # Host and user signatures: Ed25519 and RSA with SHA-2, including certificates.
  keyAlgorithms = [
    "ssh-ed25519"
    "ssh-ed25519-cert-v01@openssh.com"
    "sk-ssh-ed25519@openssh.com"
    "sk-ssh-ed25519-cert-v01@openssh.com"
    "rsa-sha2-512"
    "rsa-sha2-512-cert-v01@openssh.com"
    "rsa-sha2-256"
    "rsa-sha2-256-cert-v01@openssh.com"
  ];
}
