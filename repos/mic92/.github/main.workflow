workflow "New workflow" {
  on = "push"
  resolves = ["eval nix expressions"]
}

action "eval nix expressions" {
  uses = "docker://nixpkgs/nix-unstable"
  args = "nix-env -f default.nix -qaP *"
}
