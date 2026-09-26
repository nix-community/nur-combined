# A throwaway NixOS guest that installs sasso the three ways a NixOS user
# would, and says PASS or FAIL. `nix flake check` in the repo root proves the
# derivations build; this proves the *experience*: that `pkgs.sasso` from the
# overlay lands in a system profile, that `nix run` against the published flake
# URL works from a machine that has never seen this tree, and that the C ABI is
# linkable from the closure a NixOS puts in `environment.systemPackages`.
#
# Run it with ./run.sh (needs Linux, /dev/kvm and root). Deliberately NOT part
# of `nix flake check`: it wants a hypervisor, a tap device and a network, none
# of which a build sandbox has. See ../README.md for when it is worth running.
#
# No flake.lock here on purpose — a smoke test wants today's nixpkgs and today's
# microvm.nix, not a pin someone has to remember to refresh.
{
  description = "A throwaway NixOS microVM that installs sasso the way a NixOS user would";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    # ./run.sh overrides this with `--override-input sasso $SASSO_FLAKE`, so a
    # local checkout can be booted before it is pushed anywhere.
    sasso.url = "github:momiji-rs/sasso";
    sasso.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      microvm,
      sasso,
      ...
    }:
    let
      # What the guest types at a shell, i.e. what a user copies out of the
      # README. Keep in sync with `inputs.sasso.url` above: overriding the input
      # changes where the overlay comes from, never what these steps fetch.
      flakeRef = "github:momiji-rs/sasso";

      # One /24 between host and guest. `run.sh` owns the host end; the tap name
      # below is the one it brings up, so the two have to agree.
      tap = "sasso-vm0";
      hostIp = "10.0.0.1";
      guestIp = "10.0.0.2";
      mac = "02:00:00:00:5a:50";
    in
    {
      nixosConfigurations.sasso-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          microvm.nixosModules.microvm
          (
            { pkgs, ... }:
            {
              networking.hostName = "sasso-vm";
              system.stateVersion = "26.05";
              users.users.root.password = "";
              services.getty.autologinUser = "root";

              microvm = {
                hypervisor = "firecracker";
                vcpu = 4;
                mem = 4096;
                interfaces = [
                  {
                    type = "tap";
                    id = tap;
                    inherit mac;
                  }
                ];
                # `nix run` and `nix profile add` write to the store, which is a
                # read-only erofs image here, so give them a writable overlay on
                # a scratch disk. Without this, steps 5 and 6 fail on a full
                # store rather than on anything about sasso.
                writableStoreOverlay = "/nix/.rwstore";
                volumes = [
                  {
                    image = "store.img";
                    mountPoint = "/nix/.rwstore";
                    size = 8192;
                  }
                ];
              };

              # Address the link by MAC, not by name: firecracker's PCI mode
              # renames the NIC (enp0s… rather than eth0), and a config keyed on
              # `eth0` silently configures nothing — which looks exactly like a
              # broken guest network.
              networking.useDHCP = false;
              networking.useNetworkd = true;
              networking.nameservers = [ "1.1.1.1" ];
              networking.firewall.enable = false;
              systemd.network.networks."10-uplink" = {
                matchConfig.MACAddress = mac;
                address = [ "${guestIp}/24" ];
                routes = [ { Gateway = hostIp; } ];
              };

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              # Install path 1: the flake's overlay, i.e. what a NixOS
              # configuration does. `pkgs.sasso` and `pkgs.sasso-ffi` resolve to
              # this repo's derivations from here on.
              nixpkgs.overlays = [ sasso.overlays.default ];
              # Spelled out rather than `with pkgs;`: this flake's own input is
              # also called `sasso`, and `with` loses to a lexical binding — so
              # `with pkgs; [ sasso ]` installs the source tree, silently, and
              # the guest ends up with no `sasso` on PATH at all.
              environment.systemPackages = [
                pkgs.sasso
                pkgs.sasso-ffi
                pkgs.pkg-config
                pkgs.gcc
              ];

              systemd.services.sasso-smoke = {
                description = "Prove sasso works on this NixOS";
                wantedBy = [ "multi-user.target" ];
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  StandardOutput = "journal+console";
                  StandardError = "journal+console";
                };
                # Every command is spelled with an absolute store path or a path
                # the guest is being tested for: a unit-level `path =` would let
                # this pass by shipping its own copy of sasso. `sed` gets the
                # same treatment even though it only indents output — an
                # invariant with one exception is one nobody can rely on.
                script =
                  let
                    inherit (pkgs) sasso sasso-ffi;
                    sw = "/run/current-system/sw/bin";
                    sed = "${pkgs.gnused}/bin/sed";
                  in
                  ''
                    set -u
                    fails=0
                    ck() {
                      label=$1
                      shift
                      if "$@" > /tmp/o 2>&1; then echo "ok   $label"; else echo "FAIL $label"; fails=$((fails + 1)); fi
                      ${sed} 's/^/       /' /tmp/o
                    }

                    echo "@@ sasso smoke on $(${pkgs.coreutils}/bin/uname -n), NixOS ${pkgs.lib.version}"

                    # 1. environment.systemPackages put it on every user's PATH.
                    ck "on PATH via environment.systemPackages" test -x ${sw}/sasso
                    ck "--version agrees with the flake" \
                      test "$(${sw}/sasso --version)" = "sasso ${sasso.version}"

                    # 2. issue #82's flag set: the shape a real build passes.
                    ${pkgs.coreutils}/bin/mkdir -p /tmp/w
                    cd /tmp/w
                    ${pkgs.coreutils}/bin/cat > in.scss <<'EOF'
                    @use "sass:color";
                    $brand: #336699;
                    .button {
                      padding: 4px * 2;
                      color: $brand;
                      &:hover { color: color.adjust($brand, $lightness: -10%); }
                    }
                    EOF
                    ck "dart-compatible flag set compiles" \
                      ${sw}/sasso --no-error-css --stop-on-error --no-color --quiet --quiet-deps \
                        --style=compressed --no-source-map in.scss:out.css
                    ck "it wrote CSS" ${pkgs.coreutils}/bin/cat out.css

                    # 3. a broken stylesheet fails loudly, and non-zero.
                    echo 'a { b: $nope; }' > bad.scss
                    if ${sw}/sasso bad.scss > /tmp/o 2>&1; then
                      echo "FAIL an error exits non-zero"
                      fails=$((fails + 1))
                    else
                      echo "ok   an error exits non-zero"
                    fi
                    ${sed} 's/^/       /' /tmp/o

                    # 4. the C ABI is linkable straight out of the closure.
                    ${pkgs.coreutils}/bin/cat > v.c <<'EOF'
                    #include <sasso.h>
                    #include <stdio.h>
                    int main(void) { printf("libsasso reports %s\n", sasso_version()); return 0; }
                    EOF
                    ck "pkg-config finds the library" \
                      env PKG_CONFIG_PATH=${sasso-ffi}/lib/pkgconfig ${sw}/pkg-config --cflags --libs sasso
                    # The -rpath is explicit rather than left to the cc-wrapper:
                    # this is a hand-run compile in a guest, not a nixpkgs build.
                    ck "a C program links and runs against it" ${pkgs.bash}/bin/bash -c '
                      set -e
                      export PKG_CONFIG_PATH=${sasso-ffi}/lib/pkgconfig
                      ${sw}/gcc v.c -o v $(${sw}/pkg-config --cflags --libs sasso) -Wl,-rpath,${sasso-ffi}/lib
                      ./v
                    '

                    # 5. the network the next two steps need. When this fails the
                    #    reason is always the link, so say what the link is.
                    echo "     links:"
                    ${pkgs.iproute2}/bin/ip -brief addr | ${sed} 's/^/       /'
                    ${pkgs.iproute2}/bin/ip route | ${sed} 's/^/       /'
                    ck "network reaches the internet" ${pkgs.iputils}/bin/ping -c1 -W5 1.1.1.1

                    # 6. install path 2: nix run, from the published flake URL,
                    #    on a machine that has never seen this tree.
                    #
                    #    The PATH holds git and nothing else: a `git+https` ref
                    #    (what you point this at to rehearse a branch) is fetched
                    #    by shelling out to git, while a plain `github:` ref uses
                    #    nix' own tarball fetcher. Keeping it to git means these
                    #    steps still cannot find a sasso they did not install.
                    nixpath=${pkgs.git}/bin:${pkgs.coreutils}/bin
                    ck "nix run ${flakeRef}" \
                      env PATH=$nixpath ${pkgs.nix}/bin/nix run ${flakeRef} -- --version

                    # 7. install path 3: nix profile add.
                    ck "nix profile add ${flakeRef}" \
                      env PATH=$nixpath ${pkgs.nix}/bin/nix profile add ${flakeRef}
                    ck "the profile's sasso runs" /root/.nix-profile/bin/sasso --version

                    if [ "$fails" -eq 0 ]; then
                      echo "@@ RESULT: PASS"
                    else
                      echo "@@ RESULT: FAIL ($fails)"
                    fi
                    # Let the console drain before the machine goes away.
                    ${pkgs.coreutils}/bin/sleep 3
                    ${pkgs.systemd}/bin/systemctl poweroff
                  '';
              };
            }
          )
        ];
      };
    };
}
