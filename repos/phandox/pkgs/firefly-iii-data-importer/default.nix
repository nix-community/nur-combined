{ lib
, fetchFromGitHub
, buildNpmPackage
, php83
, dataDir ? "/var/lib/firefly-iii-data-importer"
}:

let
  pname = "firefly-iii-data-importer";
  version = "1.5.2";
  phpPackage = php83;

  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "data-importer";
    rev = "v${version}";
    sha256 = "sha256-xGYaSoK6luGTZ2/waGbnnvdXk1IoyseSbD/uW8KIqto=";
  };

  assets = buildNpmPackage {
    pname = "${pname}-assets";
    inherit version src;
    npmDepsHash = "sha256-ZSHMDalFM3Iu7gL0SoZ0akrS5UAH1FOWTRsGjzM7DWA=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      npm run build --workspace=v2
      cp -r ./public $out/
      runHook postInstall
    '';
  };
in

phpPackage.buildComposerProject (finalAttrs: {
  inherit pname src version;

  # taken from lib.fakeHash ; not lib.fakeSha256
  vendorHash = "sha256-dSv8Xcd1YUBr9D/kKuMJSVzX6rel9t7HQv5Nf8NGWCc=";

  passthru = {
    inherit phpPackage;
  };


  postInstall = ''
    mv $out/share/php/${pname}/* $out/
    rm -R $out/share $out/storage $out/bootstrap/cache $out/public
    ln -s ${dataDir}/storage $out/storage
    ln -s ${dataDir}/cache $out/bootstrap/cache
    cp -a ${assets} $out/public
  '';

  meta = {
    changelog = "https://github.com/firefly-iii/data-importer/releases/tag/v${version}";
    description = "The Firefly III Data Importer can import data into Firefly III ";
    homepage = "https://github.com/firefly-iii/data-importer";
    license = lib.licenses.agpl3Only;
    # not yet in nixpkgs maintainers
    #maintainers = [ lib.maintainers.phandox ];
  };
})
