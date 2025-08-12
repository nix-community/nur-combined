# Remark42 NixOS Module

This module provides configuration for [Remark42](https://remark42.com/), a lightweight, privacy-focused comment engine.

## Basic Configuration

```nix
{
  services.remark42 = {
    enable = true;
    url = "https://comments.example.com";
    sites = ["mysite"];
    environmentFile = "/path/to/secrets.env";
  };
}
```

## Environment File

The `environmentFile` should contain sensitive configuration. Example content:

```bash
SECRET=your-very-long-secret-key-here
AUTH_GITHUB_CID=your-github-client-id
AUTH_GITHUB_CSEC=your-github-client-secret
AUTH_GOOGLE_CID=your-google-client-id
AUTH_GOOGLE_CSEC=your-google-client-secret
SMTP_PASSWORD=your-smtp-password
```

## Authentication Providers

Remark42 requires at least one authentication provider. You can configure OAuth providers via environment variables:

- **GitHub**: `AUTH_GITHUB_CID` and `AUTH_GITHUB_CSEC`
- **Google**: `AUTH_GOOGLE_CID` and `AUTH_GOOGLE_CSEC`
- **Facebook**: `AUTH_FACEBOOK_CID` and `AUTH_FACEBOOK_CSEC`
- **Microsoft**: `AUTH_MICROSOFT_CID` and `AUTH_MICROSOFT_CSEC`
- **Discord**: `AUTH_DISCORD_CID` and `AUTH_DISCORD_CSEC`

Alternatively, you can enable anonymous commenting:

```nix
services.remark42.anonymousAuth = true;
```

## Email Notifications

To enable email notifications, add SMTP configuration to your environment file:

```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_TLS=true
NOTIFY_ADMINS=email
NOTIFY_EMAIL_FROM=your-email@gmail.com
```

## Data Storage

By default, remark42 stores data in `/var/lib/remark42`. You can change this:

```nix
services.remark42.dataDir = "/custom/path";
```

## Backup Configuration

Backups are enabled by default:

```nix
services.remark42.backup = {
  enable = true;
  path = "/var/lib/remark42/backup";  # default
  maxFiles = 10;                      # default
};
```

## Advanced Configuration

Additional environment variables can be set via the `environment` option:

```nix
services.remark42.environment = {
  EMOJI = true;
  MAX_VOTES = 10;
  LOW_SCORE = -5;
  CRITICAL_SCORE = -10;
  EDIT_TIME = "10m";
  READONLY_AGE = 365;  # days
  NOTIFY_ADMINS = "email";
  ADMIN_SHARED_EMAIL = "admin@example.com";
};
```

## Security

The module implements comprehensive systemd hardening:

- Runs as dedicated user `remark42`
- Restricted filesystem access
- No new privileges
- Memory execution protection
- Isolated temporary directories
- Restricted system calls

## Reverse Proxy

Remark42 typically runs behind a reverse proxy. Example nginx configuration:

```nix
services.nginx.virtualHosts."comments.example.com" = {
  enableACME = true;
  forceSSL = true;
  locations."/" = {
    proxyPass = "http://127.0.0.1:8080";
    proxyWebsockets = true;
  };
};
```

## Frontend Integration

Add this to your website:

```html
<script>
  var remark_config = {
    host: "https://comments.example.com",
    site_id: "mysite",
  }
</script>
<script>!function(e,n){for(var o=0;o<e.length;o++){var r=n.createElement("script"),c=".js",d=n.head||n.body;"noModule"in r?(r.type="module",c=".mjs"):r.async=!0,r.defer=!0,r.src=remark_config.host+"/web/"+e[o]+c,d.appendChild(r)}}(remark_config.components||["embed"],document);</script>

<div id="remark42"></div>
```

## Troubleshooting

- Check service status: `systemctl status remark42`
- View logs: `journalctl -u remark42 -f`
- Test installation: Visit `https://your-domain/web` (include your site ID in the `sites` list)
- Verify environment variables are loaded correctly in the service logs