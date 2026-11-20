### Task 1: qbittorrent manifests (dark) + SecretSpec contract

**Files:**
- Modify: `modules/nixos/k3s-starr.nix` (add qbittorrent block), `configurations/nixos/nas/configuration.nix` (enable flag).
- Create: SecretSpec contract file for the WireGuard key material (location per existing homepage pattern).

**Interfaces:**
- Consumes: qbittorrent port 4080, existing qbit UID/GID, ProtonVPN endpoint/gateway (confirm current), SecretSpec-managed Secret.
- Produces: qbittorrent StatefulSet + Service + Ingress (dark), nas-applied.

- [ ] **Step 1: Confirm ProtonVPN endpoint + pick pinned images**

  Verify current endpoint IP/port + gateway (today `79.127.187.156:5180` / `10.2.0.1` — re-confirm, Proton rotates). Hub-verify linuxserver/qbittorrent tag + wireguard sidecar image tag.
  Expected: values recorded in ledger, no `latest` anywhere.

- [ ] **Step 2: Write the SecretSpec contract (values by user)**

  Contract file with `refs.kube` entries for the WireGuard private key (and endpoint/public key if not hardcoded). User loads values into Proton Pass `secretspec` vault; builder verifies via alias invocation + `kubectl get secret` key names only (never values).
  Expected: Secret exists with exact key names, values never in repo/store.

- [ ] **Step 3: Add qbittorrent block (NO storage shortcuts)**

  StatefulSet (1 replica, nodeAffinity nas, three containers + iptables initContainer with NET_ADMIN, `dnsPolicy: None` + Proton DNS, `wg0.conf` secret volume, local-path config claimTemplate + RW media PVC on `nfs-pool`, containerPort 4080), Service ClusterIP :4080, Ingress class traefik host `qbittorrent.diekvoss.net`. PUID/PGID = existing qbit ids.

- [ ] **Step 4: Enable + verify eval (INCLUDING secret absence)**

  nas config: `nixcfg.k3sStarr.qbittorrent.enable = true;`. Run: manifest eval — expect image pins, NET_ADMIN present, dnsPolicy None, no storage shortcuts. Run: `nix eval ... | rg -i "private|secret|key"` — expect NO key material (only refs/names).
  Expected: structure correct, store clean.

- [ ] **Step 5: Build nas toplevel**

  Run: `nix build ...nas toplevel...` — PASS. Do NOT switch yet.

- [ ] **Step 6: Commit**

```bash
nix fmt
git add modules/nixos/k3s-starr.nix configurations/nixos/nas/configuration.nix <secretspec-contract>
git commit -m "feat: qbittorrent manifests in k3s (dark, vpn-isolated)"
```

