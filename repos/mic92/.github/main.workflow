workflow "New workflow" {
  on = "push"
  resolves = ["docker://lnl7/nix:2018-09-21"]
}

action "docker://lnl7/nix:2018-09-21" {
  uses = "docker://lnl7/nix:2018-09-21"
  args = "nix-env -f default.nix -qaP *"
}
