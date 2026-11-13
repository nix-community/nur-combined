# Plain function library (NOT a NixOS module — do not register in default.nix).
#
# Single source of truth for which Traefik middlewares protect a route.
# Consumed by k3s-edge.nix (IngressRoutes) and the in-cluster Ingress
# generators (k3s-homepage, k3s-homeassistant, k3s-starr) so the host-port
# edge and the in-cluster plane cannot drift apart.
{ lib }:
let
  edgeNamespace = "edge";

  # Homelab-style service flags in, middleware short names out. Defaults
  # mirror k3s-edge.nix route construction: diekvoss.net is private,
  # forward-auth gates default on. Extra attrs on the input are ignored,
  # so callers may pass raw homelab service attrsets or edge route records.
  routerMiddlewareNames =
    svc:
    let
      domain = svc.domain or "diekvoss.net";
      public = svc.public or (domain != "diekvoss.net");
      forwardAuthGate = svc.forwardAuthGate or true;
      selfSigned = svc.selfSigned or false;
    in
    [ "edge-secure-headers" ]
    ++ lib.optional (!public) "edge-lan-only"
    ++ lib.optional (forwardAuthGate && !selfSigned) "edge-authentik-forwardauth";
in
{
  inherit routerMiddlewareNames;

  # Value for the traefik.ingress.kubernetes.io/router.middlewares
  # annotation on plain Ingresses. The middlewares live in the edge
  # namespace, so refs must use cross-namespace `namespace-name@provider`
  # form (e.g. edge-edge-lan-only@kubernetescrd).
  ingressMiddlewareAnnotation =
    svc:
    lib.concatStringsSep "," (
      map (name: "${edgeNamespace}-${name}@kubernetescrd") (routerMiddlewareNames svc)
    );
}
