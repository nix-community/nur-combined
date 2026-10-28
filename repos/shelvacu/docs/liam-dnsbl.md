# liam — DNSBL headers

`hosts/liam/dnsbl/` is a pymilter milter that looks up every incoming SMTP
message in a set of free DNS blocklists and **only adds headers**. It never
rejects, tags the subject, or files anything. The point is to collect data on
which lists flag real mail correctly and which flag it wrongly.

## What it adds

Headers go at the top, in this order:

```
X-DNSBL: ip=203.0.113.5 rdns=mail.example.net helo=mail.example.net domains=example.net,example.com,...
X-DNSBL: zen.spamhaus.org=127.0.0.11(pbl)
X-DNSBL: bl.spamcop.net=-
...
X-DNSBL: dbl.spamhaus.org=bad.example:127.0.1.2(spam)
X-DNSBL: multi.uribl.com=-
```

- The first line shows what was queried. IP lists run against the connecting
  client IP; this is skipped for non-global IPs. Domain lists run against the
  registered domain (via the public suffix list) of: the envelope sender,
  `From:`, HELO, rDNS, and every `http(s)://` host in the text parts. The domain
  set is capped at 20.
- `-` means not listed. `error(<dnspython exception>)` means the lookup failed
  or took longer than 10s overall. Known return codes get a label in parentheses
  (see `DECODE` in `milter.py`). Every other code is shown raw.
- A sender can forge `X-DNSBL` headers. The milter's own headers are always the
  topmost ones, directly under liam's `Received:`.

Outgoing mail on the submissions port skips the milter (it gets `smtpd_milters`
with only opendkim), and so does locally generated mail (`non_smtpd_milters`).
The milter is registered with `default_action=accept`, so if it crashes or is
missing, mail still flows.

## DNS

Spamhaus, URIBL and SURBL return error codes, or nothing, for queries that come
through big public resolvers. Spamhaus returns `127.255.255.254`. For that
reason the milter uses its own unbound on `127.0.0.1:5335`. The system resolver
is left alone (`resolveLocalQueries = false`).

## The lists

All of these were checked on 2026-10-20: the `127.0.0.2` test entry is listed
and `8.8.8.8` is not, so none of them is a dead zone that answers every query.

IP lists:

| zone                              | notes                                                                                                                            |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| zen.spamhaus.org                  | free for low-volume non-commercial use via public mirrors; SBL/CSS/XBL/DROP/PBL. PBL is "dynamic/end-user IP", not spam evidence |
| bl.spamcop.net                    | report-driven, auto-expiring                                                                                                     |
| b.barracudacentral.org            | free, but Barracuda asks you to register the querying resolver's IP; unregistered queries may stop working                       |
| dnsbl-1/2/3.uceprotect.net        | L1 = IP, L2 = allocation, L3 = whole ASN. L2/L3 are notorious for collateral damage; included as a known-bad baseline            |
| ips.backscatterer.org             | backscatter senders (UCEPROTECT-run)                                                                                             |
| psbl.surriel.com                  | spamtrap-driven                                                                                                                  |
| bl.mailspike.net, z.mailspike.net | bl = blocklist, z = reputation (127.0.0.10 worst … 14)                                                                           |
| all.spamrats.com                  | 36 dyna, 37 noptr, 38 spam, 43 auth                                                                                              |
| hostkarma.junkemailfilter.com     | returns white/black/yellow/brown, not only "listed"                                                                              |
| all.s5h.net                       |                                                                                                                                  |
| bl/rbl/nbl.0spam.org              | free, including commercial use, up to 4000 queries per 5s                                                                        |
| truncate.gbudb.net                |                                                                                                                                  |
| dnsbl.justspam.org                |                                                                                                                                  |
| bl.blocklist.de                   | fail2ban-report driven; mostly brute-force/attack IPs                                                                            |
| rbl.interserver.net               |                                                                                                                                  |
| bl.nordspam.com                   |                                                                                                                                  |
| bl.spameatingmonkey.net           | operator site was erroring on 2026-10-20 but the zone answers                                                                    |
| dnsbl.spfbl.net                   |                                                                                                                                  |
| list.dnswl.org                    | **allowlist**; a hit means "known good", trustN = 0–3                                                                            |

Domain lists:

| zone             | notes                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------- |
| dbl.spamhaus.org | same terms as ZEN                                                                        |
| multi.surbl.org  | free under low volume; bitmask                                                           |
| multi.uribl.com  | free under 300k queries/day; bitmask (2 black, 4 grey, 8 red); 127.0.0.1 = query refused |
| dbl.nordspam.com |                                                                                          |

Left out:

- dead: SORBS (2024-06), WPBL (2024), NiX Spam `ix.dnsbl.manitu.net` (2025-01),
  Lashback `ubl.unsubscore.com` (2021). See
  <https://www.dnsbl.com/search/label/dead%20dnsbls>.
- needs a key: Abusix Mail Intelligence (free tier), Spamhaus DQS.
- paid: Invaluement.
- not mail-focused: DroneBL.
- `dbl.0spam.org` is keyed on IP, not domain.

## Looking at the data

The header is one line per list, so tallying is a grep over the mailbox:

```sh
doveadm fetch -u shelvacu 'hdr' all | grep '^X-DNSBL: ' | grep -v '^X-DNSBL: ip=' \
  | sed 's/=.*-$/ miss/; s/=error.*/ error/; s/=.*/ hit/' | sort | uniq -c
```

For a per-list false-positive rate, cross that with which mailbox the message
ended up in, or with whether it was spam.
