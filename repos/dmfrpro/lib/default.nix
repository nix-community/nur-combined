{ pkgs, ... }:

{
  fetchDockerRootfs =
    {
      imageName,
      imageDigest,
      hash,
      finalImageName ? null,
      finalImageTag ? null,
    }:
    let
      tarball = pkgs.dockerTools.pullImage {
        inherit imageName imageDigest hash;
        finalImageName = if finalImageName != null then finalImageName else imageName;
        finalImageTag = if finalImageTag != null then finalImageTag else "latest";
      };
    in
    pkgs.runCommand "docker-rootfs-${baseNameOf imageName}"
      {
        nativeBuildInputs = with pkgs; [
          gnutar
          mktemp
          jq
          coreutils
        ];
      }
      ''
        mkdir -p $out
        tmp=$(mktemp -d)

        tar -xf ${tarball} -C "$tmp"

        layers=$(jq -r '.[0].Layers[]' "$tmp/manifest.json")

        for layer in $layers; do
          echo "extracting $layer"
          tar -xf "$tmp/$layer" -C "$out"
        done

        rm -rf "$tmp"
      '';
}
