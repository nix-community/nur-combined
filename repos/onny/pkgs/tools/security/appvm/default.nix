{ stdenv, buildGoPackage, fetchFromGitHub, lib }:

buildGoPackage rec {
  pname = "appvm";
  version = "0.3";

  src = fetchFromGitHub {
    owner  = "jollheef";
    repo   = "appvm";
    rev    = "v${version}";
    sha256 = "0w0lgc3db9r1knd7hp98ycxfbfxbpfrb0vf4vxcqxlvlkjcrvg1z";
  };

  #buildInputs = [ makeWrapper ];

  goPackagePath = "code.dumpstack.io/tools/${pname}";

  #postFixup = ''
  #  wrapProgram $out/bin/appvm \
  #    --prefix PATH : "${lib.makeBinPath [ nix virt-manager-without-menu ]}"
  #'';

  meta = {
    description = "Nix-based app VMs";
    homepage = "https://code.dumpstack.io/tools/${pname}";
    maintainers = [ lib.maintainers.dump_stack lib.maintainers.cab404 ];
    license = lib.licenses.gpl3;
  };
}
