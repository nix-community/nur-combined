{ stdenv, pkgs, lib, fetchFromGitHub, perl, perlPackages, makeWrapper }:

stdenv.mkDerivation rec {
  name = "oar-${version}";
  version = "2.5.10+g5k7";

  src = fetchFromGitHub {
        owner = "oar-team";
        repo = "oar";
        rev = "76ccf2e691e2d662e94c93e2f8e62090bae32cb8";
        sha256 = "sha256-RbwsHG0GFQeyO3YpvuPoAD+ttItrCxGxGFRv9JB7YqU=";
  };

  #src = /home/auguste/dev/oar2;
  
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with perlPackages; [ perl JSON YAML DBI DBDPg DBDmysql SortVersions ];
  
  preConfigure = ''
   substituteInPlace Makefile --replace /bin/bash ${pkgs.bash}/bin/bash
   find -type f | xargs sed -i 's@/usr/bin/perl@${perl}/bin/perl@' || true #remove

   export PREFIX="$out"
   export BINDIR="$out/bin"
   export PERLLIBDIR="$out/lib"
   export EXAMPLEDIR="$out/examples" 
   export OARDIR="$out/oar" 
   export OARCONFDIR="$out/etc"
 '';
  
  buildPhase = ''
    make server-build
    make node-build
    make user-build
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$out/lib" "$out/examples" "$out/oar" "$out/etc"
    make server-install
    make node-install
    make user-install
  '';

  # --run command below allows to set OARCONFFILE for wrapped command (in $out/oar) either oardo set to $out/etc/oar.conf (see the previously export OARCONFDIR="$out/etc") 
  preFixup = ''
    all_progs=( $(find "$out"/oar -type f) )

    progs=($(for i in ''${all_progs[@]} ; do echo $i ; done | grep -v -E 'oarsh|oarsh_shell|setup|oardodo|oarnodecheckrun|oar_resources_add|oar_resources_init|database|oarexec'))

    for prog in ''${progs[@]}; do
    wrapProgram $prog \
      --set PERL5LIB ${ with perlPackages; makePerlPath [ perl JSON YAML DBI DBDPg DBDmysql SortVersions ]}:"$out"/lib \
      --set OARDIR "$out/bin" \
      --run "export OARCONFFILE=\$([[ \$OARCONFFILE == $out/etc/oar.conf ]] && echo /etc/oar/oar.conf || echo \$OARCONFFILE)"
    done
  '';

  doCheck = false;

  postInstall = ''
  '';

  meta = {
    #broken = true;
    homepage = "https://github.com/oar-team/oar";
    description = "The OAR Resources and Tasks Management System - version 2 series";
    license = lib.licenses.lgpl3;
    longDescription = "";
  };
}
