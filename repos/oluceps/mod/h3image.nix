{
  flake.modules.nixos.h3image =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      version = "20261118";
      user = config.identity.user;
      stateDir = "/var/lib/h3image";

      # Upstream's manylinux release binary. Vulkan is dlopen()ed by ncnn at
      # runtime, so only the C++/OpenMP runtimes need patching here.
      h3image = pkgs.stdenv.mkDerivation {
        pname = "h3image-ncnn-vulkan";
        inherit version;
        src = pkgs.fetchzip {
          url = "https://github.com/nihui/h3image-ncnn-vulkan/releases/download/${version}/h3image-ncnn-vulkan-${version}-linux.zip";
          sha256 = "1f5m7q2c8ahc0g7qq9j178dmwyws5lkqk9byp2diay4mn0rd8mdn";
        };
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.llvmPackages.openmp
        ];
        runtimeDependencies = [ pkgs.vulkan-loader ];
        installPhase = ''
          install -Dm755 h3image-ncnn-vulkan -t $out/bin
          install -Dm644 LICENSE README.md -t $out/share/doc/h3image-ncnn-vulkan
        '';
        meta.mainProgram = "h3image-ncnn-vulkan";
      };

      # Self-contained image: Nix Mesa ships the ANV driver for the Arc B580
      # (Battlemage), so no distro base image is needed.
      image = pkgs.dockerTools.buildLayeredImage {
        name = "localhost/h3image-ncnn-vulkan";
        tag = version;
        contents = [ h3image ];
        extraCommands = "mkdir -m 1777 tmp";
        config = {
          Entrypoint = [ (lib.getExe h3image) ];
          Env = [
            "LD_LIBRARY_PATH=${pkgs.vulkan-loader}/lib"
            "VK_DRIVER_FILES=${pkgs.mesa}/share/vulkan/icd.d/intel_icd.x86_64.json"
            "TMPDIR=/tmp"
          ];
        };
      };
      imageRef = "${image.imageName}:${image.imageTag}";

      # Arc B580 is pci-0000:03:00.0 -> renderD128 (renderD129 is the AMD iGPU).
      # The by-path name can't be used: podman splits --device on its colons.
      gpuRender = "/dev/dri/renderD128";

      # A CLI, not a daemon: each invocation is a throwaway rootless container.
      # The current directory is bind-mounted at the same path so relative and
      # absolute -i/-o paths below it work unchanged. -m/--cache-dir given by
      # the caller override the defaults (the parser keeps the last value).
      wrapper = pkgs.writeShellApplication {
        name = "h3image";
        runtimeInputs = [ pkgs.podman ];
        text = ''
          if ! podman image exists ${imageRef}; then
            podman load -q -i ${image}
          fi
          tty=()
          [ -t 0 ] && tty=(-t)
          exec podman run --rm -i "''${tty[@]}" \
            --userns=keep-id --group-add keep-groups \
            --device ${gpuRender} \
            --security-opt label=disable \
            -v ${stateDir}/models:/models:ro \
            -v ${stateDir}/cache:/cache \
            -v ${stateDir}/tmp:/tmp \
            -v "$PWD:$PWD" -w "$PWD" \
            ${imageRef} \
            -m /models/h3image --cache-dir /cache "$@"
        '';
      };

      # ~94 GB of prepared weights. Not started automatically:
      #   systemctl start h3image-models
      fetchModels = pkgs.writeShellScript "h3image-fetch-models" ''
        exec ${lib.getExe pkgs.python3Packages.huggingface-hub} download \
          nihui-szyl/h3-image-ncnn --local-dir ${stateDir}/models \
          "h3image/processor/*" "h3image/text_encoder/*" \
          "h3image/vision/*" "h3image/vae/*" \
          "h3image/transformer/transformer-core.ncnn.*" \
          "h3image/transformer/fixed-modulations-bf16*.bin"
      '';
    in
    {
      environment.systemPackages = [ wrapper ];

      systemd.tmpfiles.rules = [
        "d ${stateDir} 0755 ${user} users - -"
        "d ${stateDir}/models 0755 ${user} users - -"
        "d ${stateDir}/cache 0755 ${user} users - -"
        # Weight streaming spills here (tens of GB); keep it on disk, not tmpfs.
        "d ${stateDir}/tmp 0755 ${user} users 1d -"
      ];

      systemd.services.h3image-models = {
        description = "Download h3image-ncnn-vulkan model weights";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        environment.HF_HOME = "${stateDir}/hf-home";
        serviceConfig = {
          Type = "oneshot";
          User = user;
          ExecStart = fetchModels;
          TimeoutStartSec = "infinity";
        };
      };
    };
}
