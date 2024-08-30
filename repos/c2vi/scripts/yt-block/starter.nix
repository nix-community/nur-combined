{ pkgs
, ...
}: let
  myPython = pkgs.python3.withPackages (ps: with ps; [pkgs.python311Packages.cryptography]);
	python_script = pkgs.writeText "main-py" (builtins.readFile ./main.py);
in pkgs.writeShellApplication {
  name = "yt_block_sterter";
  runtimeInputs = with pkgs; [ myPython iptables bash gnugrep ps util-linux ];
  text = ''
    ${myPython}/bin/python ${python_script} starter
  '';
}
