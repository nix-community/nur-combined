{
  qemu,
  fetchFromGitHub,
  cacert,
  git,
  meson,
  libgcrypt,
}:

# Documentation: https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32
(qemu.override {
  hostCpuTargets = [ "xtensa-softmmu" ];
  capstoneSupport = false;

  # no need for graphics
  gtkSupport = false;
  vncSupport = false;
  sdlSupport = false;
  openGLSupport = false;

  # no need for audio
  pulseSupport = false;
  pipewireSupport = false;
  jackSupport = false;
}).overrideAttrs
  (
    {
      configureFlags ? [ ],
      buildInputs ? [ ],
      postPatch ? "",
      postInstall ? "",
      meta ? { },
      ...
    }:
    {
      version = "8.2.0";

      src = fetchFromGitHub {
        owner = "espressif";
        repo = "qemu";
        rev = "esp-develop-8.2.0-20240122";
        hash = "sha256-Aa4+d5zCIz+hbUj5kGl4AwvApYfgP9C1nPI2Q5vAvEk=";
        nativeBuildInputs = [
          cacert
          git
          meson
        ];
        postFetch = ''
          (
            cd "$out"
            for prj in subprojects/*.wrap; do
              meson subprojects download "$(basename "$prj" .wrap)"
              rm -rf subprojects/$(basename "$prj" .wrap)/.git
            done
          )
        '';
      };

      configureFlags = configureFlags ++ [ "--enable-gcrypt" ];
      buildInputs = buildInputs ++ [ libgcrypt ];

      # for libgcrypt
      postPatch =
        postPatch
        + ''
          substituteInPlace meson.build \
            --replace-fail config-tool pkg-config
        '';

      # dangling symlink
      postInstall =
        postInstall
        + ''
          rm $out/bin/qemu-kvm
        '';

      meta = meta // {
        description = meta.description + " (Espressif fork)";
        mainProgram = "qemu-system-xtensa";
      };
    }
  )
