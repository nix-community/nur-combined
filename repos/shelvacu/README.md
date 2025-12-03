more just notes for now

---

deploy:

```sh
nixos-rebuild switch --flake .#triple-dezert --target-host trip.shelvacu.com --use-remote-sudo
```

---

build flake on remote machine, including eval:

```sh
git add . && ssh trip nix flake check $(nix flake archive --to ssh://trip --json | jq .path -r)
```

---

search for string in closure

```sh
rg search_str $(nix path-info --recursive ./result)
```

or

```sh
rg search_str $(nix path-info --recursive .#qb.trip)
```
