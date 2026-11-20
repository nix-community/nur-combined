### Task 1: office manifests dark

**Files:**
- Create: `modules/nixos/k3s-office.nix`
- Modify: `modules/nixos/default.nix` (registry)
- Modify: `configurations/nixos/nas/configuration.nix` (import + `nixcfg.k3sOffice.enable = true`)
- Create: `k8s/office/secretspec.toml`
- Modify: `todos.md` (add tracking entry)

**Interfaces:**
- Consumes: nothing (greenfield; wildcard TLS + `nfs-pool`/local-path provisioners exist).
- Produces: Deployment + Service + Ingress (live on switch, no traffic until wired), `euro-office-jwt` Secret shape, local-path PVCs.

- [ ] **Step 1: Verify upstream image tag**

  ghcr manifest API: `ghcr.io/euro-office/documentserver:v9.3.1` resolves (same token flow as Immich's ghcr check). If absent, STOP and record the ruling (nearest exact tag, no guessing).
  Expected: tag resolves, recorded verbatim in the module.

- [ ] **Step 2: Write `modules/nixos/k3s-office.nix`**

  Deployment (1 replica, nodeAffinity nas, pinned image, env `JWT_ENABLED=true`, `JWT_SECRET` from `euro-office-jwt` secretKeyRef, `JWT_HEADER=Authorization`, `EXAMPLE_ENABLED=false`, `ALLOW_PRIVATE_IP_ADDRESS=true`, containerPort 80, `/var/lib/euro-office/documentserver` claimTemplate 20Gi + `/var/www/euro-office/Data` claimTemplate 5Gi + `emptyDir` logs + `/dev/shm` memory emptyDir 2Gi, TZ, `/healthcheck` readiness + liveness probes, resources requests 500m/2Gi + limits 4000m/8Gi), Service named `euro-office` ClusterIP :80 (this exact name — the connector's `DocumentServerInternalUrl` is `http://euro-office:80/` and resolves via cluster DNS), Ingress class traefik host `office.diekvoss.net` + wildcard TLS, NO forward-auth annotation (DS has its own JWT auth — same reasoning as *arr/Immich opt-outs).
  Expected: file exists, all values as specified, no literal secrets.

- [ ] **Step 3: Secretspec + register + enable + verify eval**

  `k8s/office/secretspec.toml`: contract for `JWT_SECRET` (32+ chars, alias discipline, `refs.kube.item = JWT_SECRET` into `euro-office-jwt`). Register in `modules/nixos/default.nix`; nas config: import + `nixcfg.k3sOffice.enable = true;`. Run: `nix eval` on the deployment spec — expect image pinned, env names exactly `JWT_ENABLED/JWT_SECRET/JWT_HEADER/EXAMPLE_ENABLED/ALLOW_PRIVATE_IP_ADDRESS`, both claimTemplates local-path, `/dev/shm` memory emptyDir, probes on `/healthcheck`, Ingress host `office.diekvoss.net`, NO auth middleware annotation. `nix flake show` PASS.
  Expected: all match, no eval errors.

- [ ] **Step 4: Build nas toplevel (no switch)**

  Run: `nix build .#nixosConfigurations.nas.config.system.build.toplevel` — PASS. Do NOT switch yet (Task 3 sequencing — nothing consumes it until then).
  Expected: build green.

- [ ] **Step 5: Describe commit**

```bash
nix fmt
jj describe -m "feat: euro-office docs manifests in k3s (dark)"
```

