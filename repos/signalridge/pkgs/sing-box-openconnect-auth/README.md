# OpenConnect authentication adapter

Connect an external cookie authenticator to sing-box's OpenConnect API. The
adapter polls configured selectors, authenticates only while the endpoint is
selected, and submits the result against the current challenge. Optional priority
fallback selects the VPN after preferred exits fail. It requires
sing-box's API service with server reflection and cookie-based browser challenges.

```sh
nix profile install github:signalridge/nur-packages#sing-box-openconnect-auth
sing-box-openconnect-auth --config ~/.config/sing-box/openconnect-auto.json watch
```

The Nix package supplies Bash, Buf, jq, curl and coreutils. A source installation
needs Bash 4.4 or newer and those commands on PATH. Keep `auth.jq` and
`fallback.sh` beside the script.

## Configuration

The configuration contains command argument arrays, never secret values or shell
fragments. The example uses a hypothetical authenticator that accepts credential
JSON on descriptor 3 and returns a session JSON object on stdout.

```json
{
  "endpoint": "Office VPN",
  "apiURL": "http://127.0.0.1:9091",
  "gateway": "https://vpn.example.test/",
  "selectors": ["Egress"],
  "defaultMethod": "certificate",
  "pollSeconds": 5,
  "apiSecretCommand": ["secret-tool", "api-secret"],
  "authCommands": {
    "certificate": ["example-vpn-auth", "--credentials-fd", "3", "--session-json"]
  },
  "credentials": [
    {"path": ["username"], "command": ["secret-tool", "username"]},
    {"path": ["password"], "command": ["secret-tool", "password"]}
  ]
}
```

Each credential is read from its command's stdout and placed at its JSON `path`.
The default `text` encoding strips trailing line endings and rejects empty or
multiline values. `gopass-base64` reads a MIME/base64 binary entry produced by
`gopass show --nosync --nofuzzysearch --noparsing --unsafe ENTRY`. Use `show`, not
`gopass cat`: the latter can write an entry when stdin is not a terminal. Optional
`methods` limits a credential to specified authentication methods.

An authenticator receives the credential object through descriptor 3. Its session
output must be a single JSON object:

```json
{
  "gateway": "https://vpn.example.test/",
  "cookies": {"Session": "value", "Token": "value"}
}
```

The gateway must match the configured HTTPS origin. The adapter submits only
cookies requested by the current challenge. It never invents a final URL for a
cookie-only challenge. Form and header challenges require a different adapter.

For `jaist-vpn-auth`, configure an argument array such as
`["jaist-vpn-auth", "--method", "certificate", "--url", "https://vpn.example.test/", "--credentials-fd", "3", "--session-json"]`
with the actual gateway. Supply `username`, `password`, `certificate.pfxBase64`
and `certificate.passphrase`. Additional `totp` and `email-otp` command arrays
enable interactive login over a local or SSH terminal.

## Priority fallback

Configure an existing selector with preferred exits, this adapter's VPN endpoint
and a final fallback. The adapter changes that selector directly, so dashboards
show the actual selected outbound without requiring an extra group:

```json
{
  "clashAPIURL": "http://127.0.0.1:9090",
  "fallbacks": [{
    "selector": "Office",
    "preferred": ["Primary", "Secondary"],
    "fallback": "Egress",
    "probeURL": "https://www.example.com/"
  }]
}
```

Preferred exits and the final fallback remain automatically managed, matching a
priority failover selector. The adapter records when it selects the VPN so it can
return to a preferred exit later. A VPN selected explicitly, or another manual
outbound, is left alone. Selecting an already automatically selected VPN again
does not communicate a separate pin operation.

An optional `parent` enables the previous nested-selector mode. In that mode only
the child selector is changed while the parent selects it; other parent choices
remain manual. Existing preferred/fallback parent choices migrate to the child
once. Omitting `parent` uses the flat selector mode above.

Preferred exits are checked in order using the Clash API's synchronous delay
endpoint. If none answers, the VPN is selected before authentication, allowing a
cold session to log in. A usable VPN remains selected until a preferred exit
recovers. Failed authentication, a failed VPN connectivity check or an expired
authentication grace period selects the final fallback and starts a retry cooldown.
Permanent authentication errors also retain the existing persistent pause.

Defaults are `fallbackPollSeconds: 30`, `fallbackAuthSeconds: 240` and
`fallbackRetrySeconds: 300`. Cooldown timestamps survive service restarts. Manual
`login` clears the pause and cooldown. Preferred exits can recover while login is
paused. Use a probe URL that tests the network the route is intended to reach.
The Clash API and gRPC API must use the same secret; only loopback APIs are accepted.
Other routing controllers must leave these automatic selectors and their parents
to this process.

## Commands

- `watch`: poll selectors and renew expired authentication while selected.
- `watch --once`: perform one automatic check, suitable for a scheduler.
- `login [--method NAME]`: resume and authenticate manually, independent of selectors.
- `status`: print connection and pause state without reading login credentials.
- `cancel`: persistently pause automation and cancel the current challenge.

Run the adapter as the user that owns the secret store, under launchd or systemd.
Headless operation requires that store to be unlockable without a graphical prompt.
Interactive challenges require `login` in a terminal; a background service pauses.

Credentials, certificates, API secrets and session cookies are held in memory and
passed through pipes or descriptors. Only lock ownership, pause state and sanitized
failure codes, automatic selections and fallback timestamps are written beneath `$XDG_STATE_HOME/openconnect-auto`. Providers'
stderr is shown only during an interactive login, and never copied into service logs.

Network failures back off from one minute to fifteen minutes. Rejected credentials,
unsupported flows and invalid configuration pause automatic login until `login`.
Exit codes are 0 for success, 65 for a persistent failure, 73 for another login in
progress, 75 for a retryable failure, and 130 for cancellation. The provider's
`network:` and `timeout:` error prefixes indicate retryable failures; unknown
errors pause. All command executions have time limits.
