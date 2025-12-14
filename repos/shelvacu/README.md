more just notes for now

---

build flake on remote machine, including eval:

```sh
git add . && ssh prop nix flake check $(nix flake archive --to ssh://prop --json | jq .path -r)
```

---

search for string in closure

```sh
rg search_str $(nix path-info --recursive ./result)
```

or

```sh
rg search_str $(nix path-info --recursive .#qb.prop)
```
