{ fetchurl }:
{ urls, hash, name, ... }: fetchurl {
  inherit urls hash name;
  recursiveHash = true;
  downloadToTemp = true;
  postFetch = ''
    mkdir -p "$out/data"
    mv "$downloadedFile" "$out/data/$name"
  '';
}
