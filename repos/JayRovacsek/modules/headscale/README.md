# Headscale

This markdown really only exists to remind me what/how I've done here.

## Opinions Applied Here

In this config, there's a few things to be wary of:

- preauth secrets are expected to be stored in a folder at the top of the repository `secrets`
- preauth keys are set to expire in 2050 - if you need to rotate these you are best doing it via the agenix secret and then forcing a reload of the systemctl unit: headscale-autosetup.service - noting your clients will de-auth until you also roll their secrets
- ACL rules are written as nix rather than JSON to keep the repo nix'd

This is completely experimental and currently only being PoC'd by myself as a step towards "zero trust" networking if we could call it that.

Currently this lacks mutual TLS auth - I intend to add this also.

## Possible Footgun

With the dynamic loading of preauth keys and creations of namespaces, I am yet to test if the order is deterministic always. I anticipate it is, however if it isn't there may
be an edge case in which a namespace and the associated preauth key are misaligned and devices could be assigned the wrong tailnet.

## Generating Headscale's Private Key

```sh
nix-shell -p wireguard-tools
wg genkey > .private.key
agenix -e headscale-private-key.age
```
