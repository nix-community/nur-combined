# radicle-interface

## error: path '/nix/store/683zi3g8a2qd490lyvgrbz94yccmsbkb-source.drv' is not valid

https://github.com/nix-community/NUR/actions/runs/5754986310/job/15601437947#step:4:4493

```
error:
       … while querying the derivation named 'radicle-interface-1.0.0-unstable-2023-08-01'

       … while evaluating the attribute 'buildInputs' of the derivation 'radicle-interface-1.0.0-unstable-2023-08-01'

...

       … while calling 'node_modules'

       at /nix/store/lscij6njgagajrwr98nmn5j9a3r81ndm-source/pkgs/development/tools/npmlock2nix/src/npmlock2nix/internal-v2.nix:428:5:

...

          446|         lockfile = readPackageLikeFile packageLockJson;

...

       error: path '/nix/store/683zi3g8a2qd490lyvgrbz94yccmsbkb-source.drv' is not valid
```

fix: use local package.json and package-lock.json
