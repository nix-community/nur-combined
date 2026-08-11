# radicle

based on https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/version-management/radicle-upstream

last PR https://github.com/NixOS/nixpkgs/pull/169755

## source

https://app.radicle.xyz/seeds/seed.radicle.xyz

```
git clone https://seed.radicle.xyz/z4V1sjrXqjvFdnCUbxPFqd5p4DtH5.git radicle-interface
git clone https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git heartwood
```

```
git clone https://seed.radicle.xyz/z2ATVRDqFu2Yq2MG5ZZCWecwSDYqj.git radicle-homepage
git clone https://seed.radicle.xyz/z3trNYnLWS11cJWC6BbxDs5niGo82.git rips # Radicle Improvement Proposals (RIPs)
git clone https://seed.radicle.xyz/z2u2CP3ZJzB7ZqE8jHrau19yjcfCQ.git sandbox
# This is the repository of the Radicle Team. It contains team resources and information on Radicle from an organizational standpoint.
git clone https://seed.radicle.xyz/z2Jk1mNqyX7AjT4K83jJW9vQoHn4f.git radicle-team
```

### github

- https://github.com/radicle-dev/radicle-interface
- https://github.com/radicle-dev/heartwood
- https://github.com/radicle-dev/radicle-git
- https://github.com/radicle-dev/radicle-cli - archive: warning Notice: Development of the Radicle CLI has moved to the [Heartwood repository](https://github.com/radicle-dev/heartwood). This repository is being deprecated.

### docker files

- https://github.com/radicle-dev/heartwood/blob/master/docker-compose.yml - `version: "3.7"`

### rust files

- https://github.com/radicle-dev/heartwood/blob/master/Cargo.toml - workspace
- https://github.com/radicle-dev/heartwood/blob/master/radicle/Cargo.toml - `version = "0.2.0"`
- https://github.com/radicle-dev/heartwood/blob/master/radicle-cli/Cargo.toml - `version = "0.8.0"`
- https://github.com/radicle-dev/heartwood/blob/master/radicle-node/Cargo.toml - `version = "0.2.0"`
- https://github.com/radicle-dev/heartwood/blob/master/radicle-httpd/Cargo.toml - `version = "0.1.0"`

### nix files

create build-environment for radicle = install rust toolchain

- https://github.com/radicle-dev/heartwood/tree/master/.nix
- https://github.com/radicle-dev/heartwood/blob/master/.nix/default.nix
- https://github.com/radicle-dev/heartwood/blob/master/.nix/shell.nix
- https://github.com/radicle-dev/heartwood/blob/master/.nix/sources.json
- https://github.com/radicle-dev/heartwood/blob/master/.nix/sources.nix

## binary release

https://radicle.xyz/install &rarr; radicle-bin-install.sh

https://files.radicle.xyz/

https://files.radicle.xyz/?sort=time&order=asc

```
594381d051b06a87dc9f517e99cc0d524274c6a9/	—	04/07/2023, 10:56:55 AM
```

&rarr; 2023-04-07

https://files.radicle.xyz/594381d051b06a87dc9f517e99cc0d524274c6a9/x86_64-unknown-linux-musl/

```
git-remote-rad	6.2 MiB	04/07/2023, 10:56:59 AM	
rad	14 MiB	04/07/2023, 10:57:00 AM	
radicle-httpd	13 MiB	04/07/2023, 10:57:02 AM	
radicle-node	9.6 MiB	04/07/2023, 10:57:03 AM	
radicle-x86_64-unknown-linux-musl.tar.gz	14 MiB	04/07/2023, 10:57:04 AM	
```

&rarr; binary release

### archive contents

```
$ tar tf radicle-x86_64-unknown-linux-musl.tar.gz 
radicle-x86_64-unknown-linux-musl/
radicle-x86_64-unknown-linux-musl/rad
radicle-x86_64-unknown-linux-musl/radicle-node
radicle-x86_64-unknown-linux-musl/git-remote-rad
radicle-x86_64-unknown-linux-musl/radicle-httpd
```

```
$ tar tf radicle-x86_64-apple-darwin.tar.gz
radicle-x86_64-apple-darwin/
radicle-x86_64-apple-darwin/radicle-node
radicle-x86_64-apple-darwin/git-remote-rad
radicle-x86_64-apple-darwin/radicle-httpd
radicle-x86_64-apple-darwin/rad
```

```
$ tar tf radicle-aarch64-unknown-linux-musl.tar.gz
radicle-aarch64-unknown-linux-musl/
radicle-aarch64-unknown-linux-musl/rad
radicle-aarch64-unknown-linux-musl/radicle-node
radicle-aarch64-unknown-linux-musl/git-remote-rad
radicle-aarch64-unknown-linux-musl/radicle-httpd
```

```
$ tar tf radicle-aarch64-apple-darwin.tar.gz
radicle-aarch64-apple-darwin/
radicle-aarch64-apple-darwin/radicle-node
radicle-aarch64-apple-darwin/git-remote-rad
radicle-aarch64-apple-darwin/radicle-httpd
radicle-aarch64-apple-darwin/rad
```

### statically linked

```
$ ldd result/bin/*
result/bin/git-remote-rad:
        statically linked
result/bin/rad:
        statically linked
result/bin/radicle-httpd:
        statically linked
result/bin/radicle-node:
        statically linked
```
