/*
FIXME error: ‘ELF_LOAD_F_PRIV_MAP’ undeclared
https://github.com/advanced-microcode-patching/shiva/issues/25
gcc  -ggdb shiva-ld.c -o shiva-ld /nix/store/cbblpyx7izddkl27v20xf5gjfcvz15i4-libelfmaster-0.4-alpha-unstable-2023-02-23/lib/libelfmaster.a /nix/store/jagvcafr5xbnriwg6xajw2brvcjxcwi1-capstone-4.0.2/lib/libcapstone.a
shiva-ld.c: In function ‘main’:
shiva-ld.c:1484:53: error: ‘ELF_LOAD_F_PRIV_MAP’ undeclared (first use in this function); did you mean ‘ELF_LOAD_F_STRICT’?
 1484 |                 ELF_LOAD_F_STRICT|ELF_LOAD_F_MODIFY|ELF_LOAD_F_PRIV_MAP, &error) == false) {
      |                                                     ^~~~~~~~~~~~~~~~~~~
      |                                                     ELF_LOAD_F_STRICT
*/

{ lib
, stdenv
, fetchFromGitHub
, pkgsMusl
, callPackage
, capstone
}:

let
  # fix: shiva.h:403:22: error: 'PATH_MAX' undeclared here (not in a function)
  stdenv = pkgsMusl.stdenv;
in

let
  libelfmaster = callPackage ./libelfmaster.nix {
    # fix: libelfmaster.a(internal.o): in function `ldso_cache_cmp': (.text+0xcc): undefined reference to `__isoc23_strtoul'
    inherit stdenv;
  };

  capstone-musl = capstone.override {
    # fix: libcapstone.a(XCoreInstPrinter.c.o): in function `XCore_insn_extract': (.text+0x23c): undefined reference to `__strcpy_chk'
    inherit stdenv;
  };
in

let
  capstone = capstone-musl;
in

stdenv.mkDerivation rec {
  pname = "shiva";
  #version = "0.13";
  version = "0.13-unstable-2024-03-23";

  src = fetchFromGitHub {
    owner = "advanced-microcode-patching";
    repo = "shiva";
    #rev = "v${version}";
    # https://github.com/advanced-microcode-patching/shiva/issues/13
    # Support for x86_64 binary patching
    # https://github.com/advanced-microcode-patching/shiva/tree/x86_64_port
    rev = "fc5d5b96127bdc956950b2fd4dd1cb6585216979";
    hash = "sha256-S/Fv81toX7lM5hgixzV5mo4D4dmnD+fwo5kfhfC1URU=";
  };

  passthru = {
    inherit libelfmaster capstone;
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail \
        '=musl-gcc' \
        '=gcc' \
      --replace-fail \
        'libcapstone_x86_64.a' \
        '${capstone}/lib/libcapstone.a' \

    substituteInPlace Makefile tools/shiva-ld/Makefile \
      --replace-fail \
        '/opt/elfmaster/lib/libelfmaster.a' \
        '${libelfmaster}/lib/libelfmaster.a' \

    substituteInPlace shiva.h tools/shiva-ld/shiva-ld.c \
      --replace-fail \
        '#include "/opt/elfmaster/include/libelfmaster.h"' \
        '#include <libelfmaster.h>' \

    substituteInPlace shiva.h \
      --replace-fail \
        '#include "include/capstone/capstone.h"' \
        '#include <capstone/capstone.h>' \

    substituteInPlace tools/shiva-ld/shiva-ld.c \
      --replace-fail \
        '#include "../../include/capstone/capstone.h"' \
        '#include <capstone/capstone.h>' \

    substituteInPlace tools/shiva-ld/Makefile \
      --replace-fail \
        '../../libcapstone_x86_64.a' \
        '${capstone}/lib/libcapstone.a' \
  '';

  buildInputs = [
    libelfmaster
    capstone
  ];

  meta = with lib; {
    description = "A custom ELF linker/loader for installing ET_REL binary patches at runtime";
    homepage = "https://github.com/advanced-microcode-patching/shiva/tree/x86_64_port";
    changelog = "https://github.com/advanced-microcode-patching/shiva/blob/${src.rev}/CHANGELOG.md";
    # https://github.com/advanced-microcode-patching/shiva/raw/main/SHIVA-LICENSE.txt
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "shiva"; # TODO
    platforms = platforms.all;
  };
}
