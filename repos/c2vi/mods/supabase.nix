{ stdenv
, autoPatchelfHook
, dpkg
, makeWrapper
, wrapGAppsHook
, libgee
, json-glib
, openldap
, gtksourceview4
, fetchurl
, libsecret
, gtksourceview
, 
... }:

stdenv.mkDerivation {
  name = "supabase-cli";
  src = fetchurl {
    url = "https://github.com/supabase/cli/releases/download/v1.111.3/supabase_1.111.3_linux_amd64.deb";
    sha256 = "sha256-mrqM1IoKENbf+ZvCMx/GZIpUteDUy4hOxbYQwXXlNpc=";
  };
  #sourceRoot = "opt/tableplus";

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    echo hiiiiiiiiiiiiiiiiiiiiiiiii
    echo $(pwd)
    ls -la usr/bin
    mkdir -p "$out/bin"
    cp usr/bin/supabase $out/bin

    chmod -R g-w "$out"
    runHook postInstall
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    libgee
    json-glib
    openldap
    gtksourceview4
    libsecret
    gtksourceview
  ];
}

