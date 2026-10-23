{
  # The T3 Code service is loopback-only; do not enable the shared
  # homelab.services bundle (Caddy, ACME, and firewall ports).
  homelab.services.t3code.enable = true;
}
