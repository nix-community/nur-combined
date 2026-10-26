# OpenConnect authentication adapter

Connect an external cookie authenticator to sing-box's OpenConnect API. The
adapter polls configured selectors, authenticates only while the endpoint is
selected, and submits the result against the current challenge. It requires
sing-box's API service with server reflection and cookie-based browser challenges.

```sh
nix profile install github:signalridge/nur-packages#sing-box-openconnect-auth
sing-box-openconnect-auth --config ~/.config/sing-box/openconnect-auto.json watch
```

The Nix package supplies Bash, Buf, jq and coreutils. A source installation needs
Bash 4.4 or newer and those commands on PATH. Keep `auth.jq` beside the script.

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
failure codes are written beneath `$XDG_STATE_HOME/openconnect-auto`. Providers'
stderr is shown only during an interactive login, and never copied into service logs.

Network failures back off from one minute to fifteen minutes. Rejected credentials,
unsupported flows and invalid configuration pause automatic login until `login`.
Exit codes are 0 for success, 65 for a persistent failure, 73 for another login in
progress, 75 for a retryable failure, and 130 for cancellation. The provider's
`network:` and `timeout:` error prefixes indicate retryable failures; unknown
errors pause. All command executions have time limits.
