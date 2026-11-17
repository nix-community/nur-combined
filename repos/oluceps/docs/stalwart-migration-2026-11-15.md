# Stalwart relocation: abhoth → nodens

Completed on 2026-11-15. The mail server now runs on the OCI instance `nodens`.
Both source and destination use Stalwart **0.16.22**; the data moved from
x86_64 to aarch64 without a version upgrade.

## Data cutover

- Source stopped at **02:03:42 UTC**; target process started at **02:06:44 UTC**.
- Copied the entire `/var/lib/stalwart/`, including RocksDB and the blob directory.
  The cold file set contained **146 files**, totaling **482,320,433 bytes**.
- Every file passed SHA-256 verification on nodens before Stalwart started.
- Re-encrypted the existing Stalwart environment for nodens with Vaultix.
  Decrypted source and target environment files have identical checksums.
  No plaintext secrets were added to the repository.
- The anonymous JMAP session response, including its Web Push public key and
  17 capabilities, was identical before and after relocation.
- Existing mail, accounts, server configuration, TLS material, and relay
  configuration in the database were retained. No new smarthost configuration
  or DNS/MX change was made as part of this relocation.

## Declarative configuration

- `mod/hosts/nodens.nix` imports `stalwart`; `abhoth.nix` no longer imports it.
- `mod/age.nix` assigns the Stalwart secret to nodens.
- `mod/constant.nix` assigns the internal `box.nyaw.xyz` service alias to nodens.
- `sec` contains a new nodens-encrypted cache entry (commit `40ed1c7`).
- Generated service endpoints now publish SMTP submission on
  `[fdcc::8]:14650` and Stalwart Web/JMAP on `[fdcc::8]:19313`.
- Eihort's SPIRE reconciler moved the Stalwart registration to nodens.
  The SMTP identity remains `spiffe://nyaw.xyz/service/stalwart`; the web
  gateway identity is `spiffe://nyaw.xyz/service/observability-nodens`.

New system configurations were activated on **nodens, abhoth, eihort, hastur,
azasos, and yidhra**. Abhoth has no Stalwart unit in its active system.
The configurations for **uubboo and kaambl** were built but could not be
activated because neither node was reachable over its mesh or LAN address.
Deploy their current configurations when they return. In particular, uubboo's
monitoring catalog still needs that update; the live mail service and the
other two monitors have already moved.

## Verification

- Stalwart is active on nodens, with no automatic process restarts during
  validation. Source Stalwart is stopped and removed from its enabled system.
- SMTP 25/587 STARTTLS, SMTP 465, IMAP 993, and POP3 995 passed protocol/TLS
  checks over the mesh, with a valid `box.nyaw.xyz` certificate.
- SMTP 465 and IMAP 993 also returned valid TLS greetings over **both public
  IPv4 and IPv6**.
- Two independent check-host.net nodes connected to public IPv4 TCP 25; a
  third timed out. Existing cluster test sources also timed out to Gmail TCP
  25, so their TCP 25 results were not used to infer OCI ingress availability.
  External report: https://check-host.net/check-report/57e674bak3dd
- Forgejo, Vaultwarden, and Pocket-ID each reached SMTP through their own
  authenticated mesh adapters; Forgejo's existing SMTP account authenticated
  successfully. No test message was sent to an external recipient.
- Public IPv4/IPv6 JMAP and the former abhoth HTTPS entrypoint returned HTTP 200.
- Eihort and hastur both report `stalwart_metrics{instance="nodens"}` as UP.
- Nodens can connect over TLS to `mail.smtp2go.com:465`. An actual outbound
  message delivery was not exercised.
- All six activated nodes had no failed systemd units at final verification.

## Retained data and rollback

On abhoth, the original `/var/lib/stalwart` remains intact. A separate cold copy
was made with Btrfs reflinks at:

```
/var/lib/stalwart-migration-20261115/source-cold
```

The parent directory is root-only. It also contains `source.sha256`, the stop
time, and the former system closure path. Nodens retains its checksum
verification log and former system closure path under the same root-only
migration directory. The target's temporary startup guard was removed.

The cold copy is a **point-in-time backup**, not a live replica. If rolling
back after nodens has accepted new mail or configuration changes, first stop
target writers and preserve/copy the current target data back to abhoth.
Restore ownership for its Stalwart user, restore the service location and
SPIRE/catalog configuration, and activate the corresponding systems before
starting the source. Do not simply restart an old source snapshot: it would
omit post-cutover mail and could create two independent writers.

Public MX records and the outstanding Oracle PTR request were not changed
**during the server relocation**. At that point, the `nyaw.xyz` apex still used
Cloudflare Email Routing, while `box.nyaw.xyz` had its own MX and public A/AAAA
pointing to nodens. The subsequent mail-routing cutover is recorded below.
The denied OCI outbound TCP 25 exemption does not prevent authenticated SMTP
submission to a relay on port 465/587.

## Direct MX and catch-all cutover (2026-11-15)

After the user disabled Cloudflare Email Routing and confirmed the destination
mailboxes, both main domains moved to direct Oracle reception. DNS changes
completed at approximately **07:52:19 UTC**.

| Domain | Domain object ID | Native `catchAllAddress` | Apex MX |
| --- | --- | --- | --- |
| `aeon.onl` | `b` | `i@aeon.onl` | `10 box.nyaw.xyz.` |
| `nyaw.xyz` | `d` | `i@nyaw.xyz` | `10 box.nyaw.xyz.` |

The fields were saved through the user's authenticated Stalwart WebUI and
read back afterward. Plus addressing remains enabled, and domain relaying
remains disabled. Existing local recipients retain normal precedence over
the catch-all fallback. No account passwords were changed, and the running
Stalwart process was not restarted.

Cloudflare API batch requests added the missing `aeon.onl` apex MX and replaced
`nyaw.xyz`'s three residual Cloudflare MX records with the direct MX. TTL is
300 seconds. Both Cloudflare and Google public resolvers returned the new MX
for both domains, with DNSSEC validation indicated. An API snapshot comparison
confirmed every other DNS record stayed unchanged, including the SMTP2GO
Return-Path/DKIM records and existing DMARC policies. Cloudflare Email Routing
remains disabled for both domains; Cloudflare still hosts DNS/CDN and the
existing DMARC report address where configured.

SMTP envelope checks after saving the fields returned 250 for both `i@`
addresses, unknown addresses in both domains, `i+tag` addresses, and the
existing `forgejo@nyaw.xyz` recipient. An unauthenticated unrelated-domain
recipient was still rejected with 550 `Relay not allowed`. No DATA command
or real test message was sent; these checks verify recipient acceptance,
not end-to-end mailbox delivery or external sending authentication.

DNS snapshots, API results, before/after domain values, and the SMTP results
are retained on nodens in the root-only directory:

```
/var/lib/stalwart-mail-cutover-20261115/
```

The DNS-before snapshot reflects the user's **already-disabled Routing**
state: no apex MX on aeon.onl and stale Cloudflare MX on nyaw.xyz. Restoring
that snapshot alone would not restore a functioning Cloudflare mail route.
Reverting to Cloudflare requires re-enabling Email Routing and verifying its
routing rules as well as its MX records.
