# nur-packages

Lilly's [NUR](https://github.com/nix-community/NUR) repository.

| Package | Description |
| --- | --- |
| [akyuu](https://github.com/lillycham/akyuu) | A content-addressed memory store for AI agents |
| [cern-httpd](https://github.com/lillycham/cern-httpd) | Tim Berners-Lee's early CERN web servers, ported to modern systems (macOS) |
| [dq](https://github.com/lillycham/dq) | Query and manipulate directory trees with jq expressions |
| [hydrus-tagger](https://github.com/lillycham/hydrus-tagger) | Import images into hydrus with WD tagger and OCR tags (macOS) |
| [lambdash](https://github.com/lillycham/lambdash) | A functional shell with composable environments |
| [nibble](https://github.com/lillycham/nibble) | A small local-model harness for tasks that don't need a big agent |
| [nibble-gui](https://github.com/lillycham/nibble) | A native chat window for nibble (macOS) |
| [nibble-mlx-server](https://github.com/lillycham/nibble) | The MLX model server that nibble starts on demand (Apple silicon) |
| [shiki](https://github.com/lillycham/shiki) | Scheduled probes that serve their results as JSON |
| [why](https://github.com/lillycham/why) | Explain the origin of a file, command or listening port |
| [worldwideweb](https://github.com/lillycham/worldwideweb) | Tim Berners-Lee's first web browser and editor, ported to modern macOS |

## Use

With the NUR overlay: `pkgs.nur.repos.lillycham.<package>`, for example `pkgs.nur.repos.lillycham.dq`.

As a flake: `github:lillycham/nur-packages#<package>`, for example `nix run github:lillycham/nur-packages#dq`.

### Shiki service

Import `inputs.nur-packages.homeModules.shiki` in Home Manager.
With NUR, import `pkgs.nur.repos.lillycham.modules.shiki` instead.
The module uses the Shiki package from this repository.

```nix
{
  services.shiki = {
    enable = true;
    probes = [
      {
        name = "site";
        kind = "http";
        url = "http://127.0.0.1:8080/";
        every = 30;
      }
    ];
  };
}
```

The service uses launchd on macOS and a user systemd service on Linux.

## Licence

The Nix expressions in this repository are licensed under the MIT licence. See [LICENSE](LICENSE).
Each package's own licence is in its `meta.license`.
