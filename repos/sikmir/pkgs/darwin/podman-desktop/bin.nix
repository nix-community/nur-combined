{ lib, stdenv, fetchfromgh, undmg }:

let
  arch = {
    "aarch64-darwin" = "arm64";
    "x86_64-darwin" = "x64";
  }.${stdenv.hostPlatform.system};
  hash = {
    "aarch64-darwin" = "sha256-mOXI5L1rR050kqsYgpgxXuuGdTbeouYCdhF46YrhMX8=";
    "x86_64-darwin" = "sha256-YcKfP/3alkaDfio8ng4bd7T7q+6HO6gXNxRMEm1kAcw=";
  }.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "podman-desktop";
  version = "0.12.0";

  src = fetchfromgh {
    owner = "containers";
    repo = "podman-desktop";
    name = "podman-desktop-${finalAttrs.version}-${arch}.dmg";
    version = "v${finalAttrs.version}";
    inherit hash;
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications
  '';

  meta = with lib; {
    description = "A graphical tool for developing on containers and Kubernetes";
    homepage = "https://podman-desktop.io/";
    license = licenses.asl20;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
})
