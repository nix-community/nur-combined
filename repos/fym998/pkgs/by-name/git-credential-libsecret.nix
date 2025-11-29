{
  stdenv,
  pkg-config,
  glib,
  libsecret,
  git,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "git-credential-libsecret";
  inherit (git)
    version
    src
    ;
  sourceRoot = "git-${finalAttrs.version}/contrib/credential/libsecret";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    glib
    libsecret
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/git/contrib/credential/libsecret/
    install -Dm755 git-credential-libsecret $out/share/git/contrib/credential/libsecret/

    mkdir -p $out/libexec/git-core
    ln -s $out/share/git/contrib/credential/libsecret/git-credential-libsecret $out/libexec/git-core/

    # ideally unneeded, but added for backwards compatibility
    mkdir -p $out/bin
    ln -s $out/libexec/git-core/git-credential-libsecret $out/bin/

    runHook postInstall
  '';

  meta = git.meta // {
    mainProgram = "git-credential-libsecret";
    description = "Git credential helper using libsecret";
  };
})
