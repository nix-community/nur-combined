{
  lib,
  stdenvNoCC,
  _7zz,
  sourceRoot,
  makeBinaryWrapper,
  source,
  rsync,
  isNightly ? false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  inherit sourceRoot;

  nativeBuildInputs = [
    _7zz
    makeBinaryWrapper
    rsync
  ];
  unpackPhase =
    if isNightly then
      ''
                        		rsync -a --chmod=ugo=rwX $src/ Ghostty.app
        						chmod +x ./Ghostty.app/Contents/MacOS/ghostty
                				runHook postUnpack
      ''
    else
      ''
        runHook preUnpack
        7zz -snld x $src
        runHook postUnpack
      '';

  postInstall = ''
    		mkdir -p $out/Applications
    		mv Ghostty.app $out/Applications/
    		makeWrapper "$out/Applications/Ghostty.app/Contents/MacOS/ghostty" "$out/bin/ghostty"
    	'';

  outputs = [
    "out"
    "man"
    "shell_integration"
    "terminfo"
    "vim"
  ];
  resourceDir = "${placeholder "out"}/Applications/Ghostty.app/Contents/Resources";
  postFixup = ''
    mkdir -p $terminfo/share
    cp -r $resourceDir/terminfo $terminfo/share/terminfo

    cp -r $resourceDir/ghostty/shell-integration $shell_integration

    cp -r $resourceDir/vim/vimfiles $vim
  '';

  # Usually the multiple-outputs hook would take care of this, but
  # our manpages are in the .app bundle
  preFixup = ''
    mkdir -p $man/share
    cp -r $resourceDir/man $man/share/man
  '';

  preferLocalBuild = true;
  meta = {
    description = "Fast, native, feature-rich terminal emulator pushing modern features";
    longDescription = ''
      			Ghostty is a terminal emulator that differentiates itself by being
      			fast, feature-rich, and native. While there are many excellent terminal
      			emulators available, they all force you to choose between speed,
      			features, or native UIs. Ghostty provides all three.
      		'';
    homepage = "https://ghostty.org/";
    downloadPage = "https://ghostty.org/download";
    license = lib.licenses.mit;
    mainProgram = "ghostty";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ DimitarNestorov ];
    outputsToInstall = [
      "out"
      "man"
      "shell_integration"
      "terminfo"
      "vim"
    ];
    platforms = lib.platforms.darwin;
  };
})
