{ pkgs
, ...
}: let
  python = pkgs.python3.withPackages (ps: with ps; [ pkgs.python311Packages.cryptography pkgs.python311Packages.psutil ]);
	python_script = pkgs.writeText "main-py" (builtins.readFile ./main.py);
  read-helper = pkgs.callPackage ./read-helper.nix {};
in pkgs.writeShellApplication {
  name = "yt_block";
  runtimeInputs = with pkgs; [ iptables bash gnugrep ps util-linux ];
  text = ''
    export PYTHON=${python}/bin/python
    export READ_HELPER=${read-helper}/bin/read-helper
    ${python}/bin/python ${python_script} "$@"
  '';
}
