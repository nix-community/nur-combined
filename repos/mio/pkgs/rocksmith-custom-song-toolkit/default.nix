{
  lib,
  stdenv,
  fetchFromGitHub,
  mono,
  msbuild,
  makeWrapper,
  perl,
  libgdiplus,
  fontconfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocksmith-custom-song-toolkit";
  version = "2.9.2.1";

  src = fetchFromGitHub {
    owner = "rscustom";
    repo = "rocksmith-custom-song-toolkit";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-SmJ4LJCNUzbUY8qNVTui4vRmdstwO+8CSO0g+2GR+G4=";
  };

  patches = [
    ./disable-prebuild.patch
  ];

  nativeBuildInputs = [
    mono
    msbuild
    makeWrapper
    perl
  ];

  buildInputs = [
    libgdiplus
    fontconfig
  ];

  postPatch = ''
    if [ -L RocksmithToolkitLib/resources ]; then
      rm -f RocksmithToolkitLib/resources
    fi
    if [ ! -d RocksmithToolkitLib/resources ]; then
      mkdir -p RocksmithToolkitLib/resources
    fi
    for f in RocksmithToolkitLib/Resources/*; do
      name="$(basename "$f")"
      lower="$(printf '%s' "$name" | tr 'A-Z' 'a-z')"
      ln -sf "../Resources/$name" "RocksmithToolkitLib/resources/$lower"
    done
    for proj in RocksmithToolkitCLI/*/*.csproj; do
      perl -0777 -pi -e 's@<PostBuildEvent[^>]*>.*?</PostBuildEvent>@<PostBuildEvent></PostBuildEvent>@sg' "$proj"
    done
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR"
    export FONTCONFIG_FILE="${fontconfig.out}/etc/fonts/fonts.conf"
    export FONTCONFIG_PATH="${fontconfig.out}/etc/fonts"

    toolProjects=(
      artistfolders
      cdlcconverter
      convert2012
      devtools
      packagecreator
      pcdecrypt
      pedalgen
      sng2014
      sngtotab
      toneliberator
      transferprofile
      xml2sng
    )

    buildOut="$PWD/build-out"
    mkdir -p "$buildOut"

    for name in "''${toolProjects[@]}"; do
      msbuild "RocksmithToolkitCLI/$name/$name.csproj" \
        /p:Configuration=Release \
        /p:Platform=x86 \
        /p:RunPostBuildEvent=Never \
        /p:OutputPath="$buildOut/$name/" \
        /p:BaseIntermediateOutputPath="$buildOut/$name/obj/"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    root="$out/lib/rocksmith-custom-song-toolkit"
    mkdir -p "$root" "$out/bin"

    cp -R lib "$root/lib"
    if [ -d ThirdPartyApps ]; then
      cp -R ThirdPartyApps "$root/ThirdPartyApps"
    fi

    toolProjects=(
      artistfolders
      cdlcconverter
      convert2012
      devtools
      packagecreator
      pcdecrypt
      pedalgen
      sng2014
      sngtotab
      toneliberator
      transferprofile
      xml2sng
    )

    buildOut="$PWD/build-out"

    for name in "''${toolProjects[@]}"; do
      buildDir="$buildOut/$name"
      toolDir="$root/$name"

      mkdir -p "$toolDir"
      cp -R "$buildDir/"* "$toolDir/"

      makeWrapper ${mono}/bin/mono "$out/bin/$name" \
        --add-flags "$toolDir/$name.exe" \
        --chdir "$toolDir"
    done

    runHook postInstall
  '';

  meta = {
    description = "Rocksmith custom song toolkit CLI utilities (Mono build)";
    homepage = "https://github.com/rscustom/rocksmith-custom-song-toolkit";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
