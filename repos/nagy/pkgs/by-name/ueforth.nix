{ gcc12Stdenv, lib, python3, fetchFromGitHub, nodejs, git, zip, imagemagick }:

# gcc13 causes build errors
gcc12Stdenv.mkDerivation (finalAttrs: {
  pname = "ueforth";
  version = "unstable-2023-12-09";

  src = fetchFromGitHub {
    owner = "flagxor";
    repo = "ueforth";
    rev = "d02499511b71ad35b2bc60941ab103e8d7370b42";
    hash = "sha256-1FiVl+kIGSBTtAdT7M9QUbIXgCpgdKZpvaEqF2lLqL0=";
  };

  makeFlags = [
    "TARGETS:=esp32_target"
    "TESTS:="
    "NODEJS:=${lib.getExe nodejs}"
    "REVISION:=${finalAttrs.src.rev or "custom"}"
    "esp32_target"
    "web"
    "posix_target"
    "out/deploy/app.yaml"
  ];

  postPatch = ''
    substituteInPlace {web,tools}/*.js \
      --replace "/usr/bin/env nodejs" "/usr/bin/env node"
    patchShebangs {web,tools}/*.js tools/memuse.py
  '';

  nativeBuildInputs =
    [ imagemagick (python3.withPackages (p: [ p.pyserial ])) nodejs git zip ];

  checkTarget = "tests";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/
    mv out/esp32 $out/share/ueforth
    rm $out/share/ueforth/ESP32forth.zip
    mv out/deploy/ $out/share/html
    install -Dm755 out/posix/ueforth $out/bin/ueforth

    runHook postInstall
  '';

  # personal fork with espnow and wdts (watchdog) support.
  passthru.fork = finalAttrs.finalPackage.overrideAttrs
    ({ postPatch ? "", version, src, makeFlags, ... }: {
      src = fetchFromGitHub {
        owner = "nagy";
        repo = "ueforth";
        rev = "2fef290cffe1b08fa507a789169c0964ff118115";
        hash = "sha256-9nQ0pGZ+nmug/6YXosueoqZs+ZHw0YLAI0YpFj0Z8Ks=";
      };
      makeFlags = makeFlags
        ++ [ "out/esp32/ESP32forth/espnow.h" "out/esp32/ESP32forth/wdts.h" ];
      # these can be set by the derivation to include userwords
      # env = {
      #   userwords_h = "${./userwords.h}";
      #   userwords_fs = "${./userwords.fs}";
      # };
      postPatch = postPatch + ''
        if [[ ! -z $userwords_h ]]; then
          # esp32
          mkdir -p out/esp32/ESP32forth/optional/
          cat $userwords_h \
            <(node tools/source_to_string.js user_source ${version} "${
              src.rev or "custom"
            }" $userwords_fs) \
            > out/esp32/ESP32forth/userwords.h
          # posix
          cp out/esp32/ESP32forth/userwords.h posix/userwords.h
        fi
      '';
      doCheck = false; # userwords break test coverage
    });

  meta = with lib; {
    description =
      "This EForth inspired implementation of Forth is bootstraped from a minimalist C kernel";
    homepage = "https://esp32forth.appspot.com/ESP32forth.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "ueforth";
  };
})
