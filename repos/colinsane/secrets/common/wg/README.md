# wireguard keys

- generate key with `wg genkey`
- obtain the pubkey with `echo <above> | wg pubkey`

N.B.: we reuse privkeys here because OVPN limits the number of keys we can deploy.

## distinct key sets:
- ukr
- us
- {us-*}

