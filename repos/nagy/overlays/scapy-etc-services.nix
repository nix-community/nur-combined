self: super: {
  python3 = super.python3 // {
    pkgs = super.python3.pkgs.overrideScope (pyself: pysuper: {
      scapy = pysuper.scapy.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace scapy/data.py \
            --replace '"/etc/services"'  '"${super.iana-etc}/etc/services"' \
            --replace '"/etc/protocols"' '"${super.iana-etc}/etc/protocols"'
        '';
      });
    });
  };
  python3Packages = self.python3.pkgs;
  hy = super.hy.override { python = self.python3; };
}
