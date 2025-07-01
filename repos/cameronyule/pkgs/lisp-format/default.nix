{ stdenv, pkgs, lib }:

let
  lisp-format-src = pkgs.fetchFromGitHub {
    owner = "eschulte";
    repo = "lisp-format";
    rev = "088c8f78ca41204b44f2636275517ac09a2de6a9";
    sha256 = "sha256-L2Wl+UWQSiJYvzctyXrMQNViZiZ6Q5vgek1PWkIaTn4=";
  };

  lispFormatWithEmacs = stdenv.mkDerivation {
    pname = "lisp-format";
    version = lisp-format-src.rev;
    src = lisp-format-src;

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;
    dontStrip = true;

    # FIXME One test (test/add-tabs-default) is currently failing, related to
    # Emacs `indent-tabs-mode` setting. Disabling until I can fix.
    #doInstallCheck = true;

    buildInputs = with pkgs; [
      ((emacsPackagesFor emacs).emacsWithPackages (
        epkgs: [ epkgs.paredit ]
      ))
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp ${lisp-format-src}/lisp-format $out/bin/lisp-format
      runHook postInstall
    '';

    postInstall = ''
      substituteInPlace $out/bin/lisp-format \
        --replace-fail "emacs" "${pkgs.emacs}/bin/emacs"
    '';

    installCheckPhase = ''
      runHook preCheck
      make check
      runHook postCheck
    '';

    meta = with lib; {
      description = "An Emacs Lisp code formatter, packaged with its Emacs dependency.";
      homepage = "https://github.com/eschulte/lisp-format";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };

in
  # The file returns the package derivation itself.
  lispFormatWithEmacs
