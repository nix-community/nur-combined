{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib stdenv fetchurl unzip;
in
  stdenv.mkDerivation rec {
    pname = "powershell_es";
    version = "4.1.0";
    src = fetchurl {
      name = "PowerShellEditorServices.v${version}.zip";
      url = "https://github.com/PowerShell/PowerShellEditorServices/releases/download/v${version}/PowerShellEditorServices.zip";
      hash = "sha256-cNzRVw6V8bmAosx+gFBQCHX8cH+IHp8CjDTR+bdNoHM=";
    };

    nativeBuildInputs = [
      unzip
    ];

    sourceRoot = ".";
    dontUnpack = true;

    installPhase = ''
         mkdir -p $out/docs
         mkdir -p $out/PowerShellEditorServices
         mkdir -p $out/PSReadLine
         mkdir -p $out/PSScriptAnalyzer

      unzip -d $out $src
    '';

    postUnpackPhase = ''

    '';

    meta = {
      description = "LSP for PowerShell that supplies rich editor functionality like code completion, syntax highlighting, and code annotation.";
      homepage = "https://github.com/PowerShell/PowerShellEditorServices";
      sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      license = lib.licenses.mit;
    };
  }
