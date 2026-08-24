{
  common-updater-scripts,
  curl,
  fetchurl,
  jq,
  writeScript,

  lib,
  stdenv,
}:
let
  version = "0.9.1";
  sources = {
    x86_64-linux = fetchurl {
      url = "https://codeberg.org/git-pages/git-pages/releases/download/v${version}/git-pages.linux-amd64";
      sha256 = "sha256-9Sm0S9dua+oEtaHUOdoHGTNm6+7LA1JU1vWZWGi/FEM=";
    };
    aarch64-linux = fetchurl {
      url = "https://codeberg.org/git-pages/git-pages/releases/download/v${version}/git-pages.linux-arm64";
      sha256 = "sha256-nvNZ5DPBs6qqJw6KvWyzYDs4Ok73IYCH7qnF+ECnMpY=";
    };
    aarch64-darwin = fetchurl {
      url = "https://codeberg.org/git-pages/git-pages/releases/download/v${version}/git-pages.darwin-arm64";
      sha256 = "sha256-gMZV9qizmFMlHMDC1H4Pnr1hNbLbunuXKJDg9ZfXTpQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "git-pages-bin";
  inherit version;
  src = sources.${stdenv.targetPlatform.system} or sources.x86_64-linux;

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    cp $src $out/bin/git-pages
    chmod +x $out/bin/git-pages

    runHook postBuild
  '';

  passthru = sources // {
    updateScript = writeScript "update-git-pages-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl common-updater-scripts jq

      version="$(curl -s https://codeberg.org/api/v1/repos/git-pages/git-pages/releases/latest \
        | jq -r '.tag_name | scan("v(.*)") | .[0]')"

      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version git-pages-bin "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Scalable static site server for Git forges (like GitHub Pages or Netlify)";
    homepage = "https://git-pages.org";
    license = lib.licenses.bsd0;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "git-pages";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
