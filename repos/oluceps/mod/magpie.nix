{
  flake.modules.nixos.magpie =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      version = "0.1.4291";
      upstream = "ghcr.io/yetone/magpie:${version}";
      # Upstream ships a bookworm image with no Vulkan userspace, so the
      # privacy-filter model (pf-serve) falls back to CPU and the masking pass
      # keeps hitting its 15s deadline. Bookworm's Mesa (22.3) predates
      # Battlemage, and the host's Nix Mesa needs glibc 2.38, so rebuild the
      # same layout on trixie (Mesa 25) with the Intel ANV driver instead.
      containerfileText = ''
        FROM ${upstream} AS upstream

        FROM docker.io/library/debian:trixie-slim
        RUN apt-get update \
          && apt-get install -y --no-install-recommends \
            ca-certificates curl libvulkan1 mesa-vulkan-drivers \
          && rm -rf /var/lib/apt/lists/* \
          && groupadd -g 65532 nonroot \
          && useradd -u 65532 -g nonroot -d /config/home -s /bin/bash nonroot
        COPY --from=upstream /magpie /magpie
        RUN ln -s /magpie /usr/local/bin/magpie
        COPY --from=upstream --chown=65532:65532 /config /config
        USER nonroot
        ENV HOME=/config/home XDG_CONFIG_HOME=/config XDG_CACHE_HOME=/config/cache \
          XDG_DATA_HOME=/config/data XDG_STATE_HOME=/config/state MAGPIE_ADDR=0.0.0.0:3425 \
          VK_DRIVER_FILES=/usr/share/vulkan/icd.d/intel_icd.json
        VOLUME ["/config"]
        HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["/magpie", "healthcheck"]
        EXPOSE 3425/tcp 3430/tcp
        ENTRYPOINT ["/magpie"]
        CMD ["serve"]
      '';
      containerfile = pkgs.writeText "magpie-vulkan.Containerfile" containerfileText;
      image = "localhost/magpie-vulkan:${version}-${
        builtins.substring 0 12 (builtins.hashString "sha256" containerfileText)
      }";
      # Arc B580 (xe, pci-0000:03:00.0); the AMD iGPU is renderD129. The by-path
      # name can't be used: podman splits --device on its colons.
      gpuRender = "/dev/dri/renderD128";
      buildImage = pkgs.writeShellScript "magpie-build-image" ''
        podman image exists ${image} && exit 0
        exec podman build --format docker --pull=missing -t ${image} -f ${containerfile} /var/empty
      '';
    in
    {
      vaultix.secrets.magpie = {
        owner = "magpie";
        mode = "400";
      };

      users = {
        groups.magpie = { };
        users.magpie = {
          isSystemUser = true;
          group = "magpie";
          home = "/var/lib/magpie";
          linger = true;
          createHome = true;
          uid = 950;
          autoSubUidGidRange = true;
        };
      };

      systemd.services.podman-magpie = {
        after = [
          "network-online.target"
          # "vaultix-activate.service"
        ];
        # Start after the secret files exist, but do not tie the container's
        # lifetime to that unit. Every switch restarts vaultix-activate, and a
        # Requires edge turned that into a stop of this container mid-flight; the
        # podman stop then failed and left the unit failed instead of restarting.
        wants = [
          "network-online.target"
          # "vaultix-activate.service"
        ];
        serviceConfig = {
          Restart = lib.mkForce "always";
          ExecStartPre = lib.mkBefore [ buildImage ];
        };
      };

      virtualisation.oci-containers = {
        backend = "podman";
        containers.magpie = {
          inherit image;
          pull = "never";
          cmd = [
            "web"
            "--addr"
            "[::]:3430"
            "--no-open"
          ];
          ports = [
            "[::]:3425:3425"
            "[::]:3430:3430"
          ];
          volumes = [ "magpie-config:/config" ];
          devices = [ gpuRender ];
          environmentFiles = [ config.vaultix.secrets.magpie.path ];
          podman.user = "magpie";
        };
      };
    };
}
