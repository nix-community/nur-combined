{
  lib,
  stdenvNoCC,
  _7zz,
  sourceRoot,
  makeBinaryWrapper,
  source,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  inherit sourceRoot;

  nativeBuildInputs = [
    _7zz
    makeBinaryWrapper
  ];

  installPhase = ''
    		runHook preInstall

    		mkdir -p $out/Applications
    		mv Ghostty.app $out/Applications/
    		makeWrapper $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin/ghostty

    		runHook postInstall
    	'';

  outputs = [
    "out"
    "man"
    "shell_integration"
    "terminfo"
    "vim"
  ];

  postFixup =
    let
      resources = "$out/Applications/Ghostty.app/Contents/Resources";
    in
    ''
      			mkdir -p $man/share
      			ln -s ${resources}/man $man/share/man

      			mkdir -p $terminfo/share
      			ln -s ${resources}/terminfo $terminfo/share/terminfo

      			mkdir -p $shell_integration
      			for folder in "${resources}/ghostty/shell-integration"/*; do
      				ln -s $folder $shell_integration/$(basename "$folder")
      			done

      			mkdir -p $vim
      			for folder in "${resources}/vim/vimfiles"/*; do
      				ln -s $folder $vim/$(basename "$folder")
      			done
      		'';

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
    ];
    platforms = lib.platforms.darwin;
  };
})
