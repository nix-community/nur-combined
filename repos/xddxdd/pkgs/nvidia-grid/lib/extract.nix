{
  stdenv,
  lib,
  fetchurl,
  unzip,
  p7zip,
}:
let
  unpack =
    args: version: source:
    stdenv.mkDerivation (
      {
        inherit version;

        srcs = lib.mapAttrsToList (
          url: hash:
          fetchurl {
            inherit url;
            sha256 = hash;
          }
        ) source.urls;
        sourceRoot = ".";

        unpackPhase = ''
          for _src in $srcs; do
            NEWNAME=$(basename "$_src" | cut -c 34-)
            echo "$NEWNAME"
            ln -s "$_src" "$NEWNAME"
          done

          SRCARR=($srcs)
          FILE=$(basename "''${SRCARR[0]}" | cut -c 34-)
          echo "Extracting $FILE"

          if [[ $FILE == *.zip ]]; then
            unzip "$FILE"
          else
            7z x -y "$FILE"
          fi

          for _src in $srcs; do
            NEWNAME=$(basename "$_src" | cut -c 34-)
            rm -f "$NEWNAME"
          done

          cd NVIDIA-GRID-Linux-KVM-* || true
        '';

        nativeBuildInputs = [
          unzip
          p7zip
        ];
      }
      // args
    );
in
{
  extractVgpuDriver = unpack {
    pname = "nvidia-vgpu-driver";
    installPhase = ''
      cp "''$(find . -name \*-vgpu-kvm.run)" $out
    '';

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      homepage = "https://www.nvidia.com/object/unix.html";
      description = "NVIDIA vGPU host driver (vGPU-KVM driver) installer";
      license = lib.licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" ];
    };
  };

  extractGridDriver = unpack {
    pname = "nvidia-grid-driver";
    installPhase = ''
      cp "''$(find . -name \*-grid.run)" $out
    '';

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      homepage = "https://www.nvidia.com/object/unix.html";
      description = "NVIDIA vGPU guest driver (GRID driver) installer";
      license = lib.licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" ];
    };
  };
}
