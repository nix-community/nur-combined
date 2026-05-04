{ pkgs ? import <nixpkgs> {} }:

let
  runtimeLibs = with pkgs; [
    pipewire wayland libxkbcommon dbus fontconfig
    libx11 libxcursor libxrandr libxi
  ];
in

pkgs.rustPlatform.buildRustPackage {
  pname = "ie-r";
  version = "0.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "miaupaw";
    repo  = "ie-r";
    rev   = "v0.1.1";
    hash  = "sha256-N7usgQvHwbeodQM2vBI2NxSTIBqCnF6iXiG7gaXeDLI=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  doCheck = false;
  nativeBuildInputs = with pkgs; [ pkg-config llvmPackages.libclang patchelf ];
  buildInputs = runtimeLibs;
  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  postInstall = ''
    install -Dm644 assets/ie-r.desktop -t $out/share/applications/
    install -Dm644 assets/ie-r.svg -t $out/share/icons/hicolor/scalable/apps/
    install -Dm644 LICENSE -t $out/share/licenses/ie-r/
    substituteInPlace $out/share/applications/ie-r.desktop \
      --replace-fail "Exec=ie-r" "Exec=$out/bin/ie-r"
  '';

  meta = with pkgs.lib; {
    description = "Instant Eyedropper Reborn — pixel-perfect color picker for Linux (Wayland & X11)";
    homepage    = "https://instant-eyedropper.com/linux/";
    license     = licenses.unfree;
    mainProgram = "ie-r";
    platforms   = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
