{ stdenv
, vscode-utils
, autoPatchelfHook
, /*icu, curl, lttng-ust,*/ xorg
, gnome3
, utillinux
, openssl
, icu
, zlib
, curl
, lttng-ust
, libsecret
, libkrb5
, gcc
, libunwind
, binutils
}:
let
  runtimeVersion = "2.1.1";
  runtimeHash = "6985b9f6844d51ba1197c3f52aabc7291bb15bc1";
  runtime = fetchTarball {
    url = "https://download.microsoft.com/download/9/3/E/93ED35C8-57B9-4D50-AE32-0330111B38E8/dotnet-runtime-${runtimeVersion}-linux-x64.tar.gz";
    sha256 = "1g754mpwznmxlml5vnbxlm7v253al2m5jwzfvd7hj74f45yx8amf";
  };
  rpath = stdenv.lib.makeLibraryPath [ utillinux openssl icu zlib curl lttng-ust libsecret libkrb5 gcc.cc.lib libunwind binutils.bintools_bin ];
in
(
  vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vsliveshare";
      publisher = "ms-vsliveshare";
      version = "0.3.504";
      sha256 = "1y24q5id9hkgdndh2v8z1rpw736bi16yk66n260s44qd3w5yss8r";
    };
  }
).overrideAttrs (
  attrs:
  {
    buildInputs = attrs.buildInputs
      ++ [ autoPatchelfHook ]
      ++ [ icu curl lttng-ust xorg.libX11 ];

    installPhase = attrs.installPhase + ''

    runHook postInstall
    '';

    postInstall = ''
      bash -s <<ENDSUBSHELL
      shopt -s extglob
      cd $out/share/*/extensions/*
      cp \
          "${runtime}"/shared/Microsoft.NETCore.App/2.1.1/* \
          dotnet_modules/runtimes/linux-x64/!(native) \
          dotnet_modules/runtimes/linux-x64/native/* \
          dotnet_modules/runtimes/unix/lib/netstandard1.3/* \
          "dotnet_modules"
      chmod +x \
          dotnet_modules/vsls-agent \
          dotnet_modules/Microsoft.Cascade.VSCodeAdapter \
          dotnet_modules/createdump \
          dotnet_modules/Microsoft.Cascade.VSCodeHostAdapter \
          dotnet_modules/runtimes/linux-x64/vsls-agent \
          dotnet_modules/runtimes/linux-x64/Microsoft.Cascade.VSCodeHostAdapter \
          dotnet_modules/runtimes/linux-x64/Microsoft.Cascade.VSCodeAdapter \

      touch "install.Lock"
      cat <<EOF > dotnet_modules/.version
      ${runtimeHash}
      ${runtimeVersion}
      EOF
      sed -i out/src/launcher.js \
          -e "s|path.join(Launcher.extensionRootPath, 'cascade.json')|'/tmp/cascade.json'|"
      sed -i out/src/extension.js \
          -e "s|yield downloader_1.ExternalDownloader.ensureRuntimeDependenciesAsync(liveShareExtension)|downloader_1.EnsureRuntimeDependenciesResult.Success|" \
          -e "s|yield downloader_1.isInstallCorrupt(traceSource_1.traceSource)|false|"
      sed -i out/src/internalConfig.js \
          -e "s|path.join(__dirname, '..', '..', 'modifiedInternalSettings.json')|'/tmp/modifiedInternalSettings.json'|"
      ENDSUBSHELL
    '';

    #-e "s|launcher_1.Launcher.safelyDeleteCascadeUrlFile();||" \
    #-e "s|yield launcher_1.Launcher.readCascadeURL()|void 0|" \

    postFixup = ''
      cd $out/share/*/extensions/*
      find . -iname '*.so' -ls -exec patchelf --set-rpath ${rpath} '{}' \;
    '';

    propagatedBuildInputs = with gnome3; [ gnome-keyring ];
  }
)
