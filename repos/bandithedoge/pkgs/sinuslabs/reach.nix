{
  fetchzip,
  lib,
  sinuslabs,
  writeScript,
}:
sinuslabs.mkSinuslabs (finalAttrs: {
  pname = "reach";
  version = "1.6.6";
  src = fetchzip {
    url = "https://github.com/Sinuslabs/Reach/releases/download/${finalAttrs.version}/Reach-Linux.zip";
    sha256 = "sha256-lP8Zs72BdqU7uuw6Bk9DM89xuiwxWSK5aIun9peAMto=";
    stripRoot = false;
  };

  # nix-update really insists on getting 1.41 rather than the actual latest release,
  # even with the correct regex: (\d+\.\d+\.\d+)
  passthru.updateScript = writeScript "update-sinuslabs-reach" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl common-updater-scripts jq

    version="$(curl -s https://api.github.com/repos/Sinuslabs/Reach/releases/latest | jq -r .tag_name)"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Extraterrestrial Reverb with a unique Sound";
    homepage = "https://sinuslabs.io/products/reach";
    license = lib.licenses.gpl3Plus;
  };
})
