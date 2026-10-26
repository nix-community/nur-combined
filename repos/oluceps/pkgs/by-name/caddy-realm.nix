{
  caddy,
}:
# Published plugin versions keep the fixed-output source reproducible.
(caddy.withPlugins {
  plugins = [
    "github.com/caddy-dns/cloudflare@v0.0.0-20250724223520-f589a18c0f5d"
    "github.com/mholt/caddy-ratelimit@v0.1.0"
    "github.com/ss098/certmagic-s3@v0.0.0-20250607141218-0c4ff782fbd0"
    "github.com/greenpau/caddy-security@v1.1.31"
    "github.com/mholt/caddy-l4@v0.0.0-20260112235400-e24201789f06"
    "github.com/oluceps/caddy-plugins-realm/spiffe@v0.2.0"
  ];
  hash = "sha256-rB5KM54QerCbA680wLQQ6J8ejPRggXPjXHhgRiArs50=";
}).overrideAttrs
  (previous: {
    installCheckPhase = previous.installCheckPhase + ''
      $out/bin/caddy list-modules | grep -Fx tls.get_certificate.spiffe
      $out/bin/caddy list-modules | grep -Fx tls.client_auth.verifier.spiffe
    '';
  })
