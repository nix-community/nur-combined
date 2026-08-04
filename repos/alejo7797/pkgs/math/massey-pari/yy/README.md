# Help for YY

Copy `default.nix` and `pari.patch` into the same folder as `massey.c`.

To (re)build Eric's program, run

```sh
nix-build
```

You can then use it by doing

```sh
./result/bin/massey p 'pol(s)'
```
