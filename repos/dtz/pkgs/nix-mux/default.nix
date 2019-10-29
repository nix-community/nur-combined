{ stdenv, runCommandNoCC, lib }:

let
  versionSuffix = "dtz-mux-3d312c9";
  version = "2.4" + versionSuffix;
  nix-mux-tarball = lib.from-nar {
    name = "nix-${version}";
    narurl = "nar/98c8376595122bc4ad4e66ec85d3554f9fdd0f5c8267b6586655bd9ea6b64a57.nar.xz";
    narHash = "sha256:14r6m1hafa6wfgb94x7h00sg1xxfqichr1c13bpbcj84q1sri2fa";
  };

  bootstrapFiles = {
    # TODO: better way of grabbing this
    busybox = stdenv.bootstrapTools.builder;

    tarball = nix-mux-tarball;
  };

  unpack = import ./unpack.nix {
    name = "nix-${version}";
    inherit (stdenv.hostPlatform) system;
    inherit bootstrapFiles;
  };

  meta = with lib; {
    description = "Nix All-in-One! (multiplexed)";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.lgpl2Plus;
    homepage = https://github.com/allvm/allvm-tools;
  };
in
  unpack // { inherit meta; }
