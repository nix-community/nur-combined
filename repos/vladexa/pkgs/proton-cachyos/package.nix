# if you want this updated it's better to file a PR than wait for me to update it
# i'm a lazy bum
{
  lib,
  stdenvNoCC,
  fetchzip,
  # writeScript,
  # Can be overridden to alter the display name in steam
  # This could be useful if multiple versions should be installed together
  steamDisplayName ? "Proton-CachyOS",
  # Can be overriden to x86_64_v{3,4}, and possibly arm64 but I can't test the last one.
  # I'm probably using v4
  archVersion ? "x86_64",
}:
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    pureVersion = lib.removeSuffix "-${archVersion}" finalAttrs.version;
    fullname = "proton-cachyos-${pureVersion}-slr-${archVersion}";
    hashes = {
      x86_64 = "sha256-bOppcHF4XpCTM+BJCPiR6GsVr2r/yGxEwSaQr5Hamh8=";
      x86_64_v3 = "sha256-vVAWphVI8fTSvfelVn4KNksrbPnbgtTLNZ3xSooP9rY=";
      x86_64_v4 = "sha256-WBZcBL2bDG9liumSoXJlGemYnkNU7otM45zTqngxrKE=";
      arm64 = "sha256-9Fbvp0pYa1z8eL7pwuLjdsVQQuHvyhzb4GX1yx6rN8w=";
    };
  in
  {
    pname = "proton-cachyos-bin";
    version = "10.0-20260320-${archVersion}";

    src = fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${pureVersion}-slr/${fullname}.tar.xz";
      hash = hashes.${archVersion};
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    outputs = [
      "out"
      "steamcompattool"
    ];

    installPhase = ''
      runHook preInstall

      # Make it impossible to add to an environment. You should use the appropriate NixOS option.
      # Also leave some breadcrumbs in the file.
      echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

      mkdir $steamcompattool
      ln -s $src/* $steamcompattool
      rm $steamcompattool/compatibilitytool.vdf
      cp $src/compatibilitytool.vdf $steamcompattool

      runHook postInstall
    '';

    preFixup = ''
      substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
        --replace-fail "${fullname}" "${steamDisplayName}"
    '';

    /*
      We use the created releases, and not the tags, for the update script as nix-update loads releases.atom
      that contains both. Sometimes upstream pushes the tags but the Github releases don't get created due to
      CI errors. Last time this happened was on 8-33, where a tag was created but no releases were created.
      As of 2024-03-13, there have been no announcements indicating that the CI has been fixed, and thus
      we avoid nix-update-script and use our own update script instead.
      See: <https://github.com/NixOS/nixpkgs/pull/294532#issuecomment-1987359650>
    */
    # passthru.updateScript = writeScript "update-proton-ge" ''
    #   #!/usr/bin/env nix-shell
    #   #!nix-shell -i bash -p curl jq common-updater-scripts
    #   repo="https://api.github.com/repos/CachyOS/proton-cachyos/releases"
    #   version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output)"
    #   update-source-version proton-cachyos "$version"
    # '';

    meta = {
      description = ''
        Compatibility tool for Steam Play based on Wine and additional components.

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/CachyOS/proton-cachyos";
      license = lib.licenses.bsd3;
      maintainers = [
        {
          email = "vgrechannik@gmail.com";
          name = "Vladislav Grechannik";
          github = "VlaDexa";
          githubId = 52157081;
        }
      ];
      platforms = [
        "x86_64-linux"
        # once again, I can't test if this works so fix issues yourself
        "aarch64-linux"
      ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  }
)
