{
  lib,
  makeWrapper,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wayland,
  wayland-protocols,
  mesa,
  libGL,
  libdrm,
  libx11,
  libxrandr,
  libxcb,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "chameleos";
  version = "0.1.2";

  # https://github.com/Treeniks/chameleos.git
  src = fetchFromGitHub {
    owner = "Treeniks";
    repo = "chameleos";
    tag = "v${finallAttrs.version}";
    hash = "sha256-zCAYEtDYJm9A+HC9M2XLtz47q+6dcBOVPgh4lmp4z/k=";
  };

  cargoHash = "sha256-zBEu/T17W7dwz8jxnXm2NsHaVZo1wDFSW75yiYfRIoY=";

  # 用 substituteInPlace 替换 build.rs 内 git 命令
  postPatch = ''
      cat > build.rs <<'EOF'
    use std::path::Path;

    fn main() {
        println!("cargo::rerun-if-changed=src");

        let version = format!("v{}", env!("CARGO_PKG_VERSION"));
        let commit_hash = "unknown";
        let rustc_version = "rustc (nix)";
        let build_time = "nix";
        let target = format!(
            "{}-{}-{}",
            std::env::var("CARGO_CFG_TARGET_ARCH").unwrap(),
            std::env::var("CARGO_CFG_TARGET_VENDOR").unwrap(),
            std::env::var("CARGO_CFG_TARGET_OS").unwrap(),
        );

        let long_version = format!(
            "{version}\ncommit hash: {commit_hash}\nbuild time: {build_time}\n{rustc_version}\n{target}"
        );

        let out_dir = std::env::var("OUT_DIR").unwrap();
        let dest_path = Path::new(&out_dir).join("metadata.rs");
        std::fs::write(
            dest_path,
            format!(
                r#"
    pub const VERSION: &str = "{version}";
    pub const LONG_VERSION: &str = "{long_version}";
    "#
            ),
        )
        .unwrap();
    }
    EOF
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    wayland
    wayland-protocols
    mesa
    libGL
    libdrm
    libx11
    libxrandr
    libxcb
  ];

  postInstall = ''
    for bin in chameleos chamel; do
      wrapProgram $out/bin/$bin \
        --set WGPU_BACKEND GL \
        --prefix LD_LIBRARY_PATH : ${mesa}/lib:${libGL}/lib
    done
  '';

  meta = {
    description = "Screen annotation tool for niri and Hyprland";
    homepage = "https://github.com/Treeniks/chameleos";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "chameleos";
    broken = true;
  };
})
