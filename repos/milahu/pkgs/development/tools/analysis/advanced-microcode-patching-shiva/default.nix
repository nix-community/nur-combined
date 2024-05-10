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

  buildInputs = [
    capstone
    libelfmaster
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail \
        '=musl-gcc' \
        '=gcc' \
      --replace-fail \
        'libcapstone_x86_64.a' \
        '-lcapstone' \
      --replace-fail \
        '$(MUSL) -static ' \
        '$(MUSL) ' \

    substituteInPlace Makefile tools/shiva-ld/Makefile \
      --replace-fail \
        '/opt/elfmaster/lib/libelfmaster.a' \
        '-lelfmaster' \

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
        '-lcapstone' \
  '';

  # Makefile
  /*
    cp build/shiva /lib/shiva
    ln -sf build/shiva shiva
    ln -sf /lib/shiva /usr/bin/shiva
    cp tools/shiva-ld/shiva-ld /usr/bin
    mkdir -p /opt/shiva/modules
  */

  installPhase = ''
    install -D build/shiva $out/lib/shiva # TODO why not /lib/libshiva.so
    ln -s shiva $out/lib/libshiva.so # no?
    mkdir -p $out/bin
    ln -sf $out/lib/shiva $out/bin/shiva
    install -D tools/shiva-ld/shiva-ld $out/bin
  '';

  # TODO build + install modules
  #  ln -sf build/shiva shiva
  #  mkdir -p $out/opt/shiva/modules

  meta = with lib; {
    description = "A custom ELF linker/loader for installing ET_REL binary patches at runtime";
    homepage = "https://github.com/advanced-microcode-patching/shiva/tree/x86_64_port";
    changelog = "https://github.com/advanced-microcode-patching/shiva/blob/${src.rev}/CHANGELOG.md";
    # https://github.com/advanced-microcode-patching/shiva/raw/main/SHIVA-LICENSE.txt
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "shiva";
    platforms = platforms.all;
  };
}
