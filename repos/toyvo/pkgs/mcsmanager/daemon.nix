{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc-unwrapped,
}:
stdenv.mkDerivation rec {
  pname = "mcsmanager-daemon";
  version = "4.12.1";

  src = fetchurl {
    url = "https://github.com/MCSManager/MCSManager/releases/download/v10.12.2/mcsmanager_linux_daemon_only_release.tar.gz";
    hash = "sha256-oDZ9AJpzLuSoCClvgYceH9KMdEZoitD/mqR2pbUl7Uw=";
  };

  sourceRoot = "mcsmanager/daemon";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gcc-unwrapped.lib ];

  dontBuild = true;
  dontConfigure = true;

  installPhase =
    let
      arch = if stdenv.hostPlatform.isx86_64 then "x64" else "arm64";
    in
    ''
      runHook preInstall
      mkdir -p $out/lib/mcsmanager/daemon/lib

      cp app.js app.js.map package.json $out/lib/mcsmanager/daemon/
      cp -r node_modules $out/lib/mcsmanager/daemon/

      # Install only platform-appropriate native binaries
      for bin in pty_linux_${arch} file_zip_linux_${arch} 7z_linux_${arch}; do
        if [ -f "lib/$bin" ]; then
          install -m755 "lib/$bin" "$out/lib/mcsmanager/daemon/lib/$bin"
        fi
      done

      # License files for 7z
      cp lib/7z-*.txt $out/lib/mcsmanager/daemon/lib/ 2>/dev/null || true

      runHook postInstall
    '';

  meta = with lib; {
    description = "MCSManager daemon - manages game server instances";
    homepage = "https://mcsmanager.com/";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [
      {
        name = "Collin Diekvoss";
        email = "Collin@Diekvoss.com";
        matrix = "@toyvo:matrix.org";
        github = "ToyVo";
        githubId = 5168912;
      }
    ];
  };
}
