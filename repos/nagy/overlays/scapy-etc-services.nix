self: super:
(super.__MkPythonOverlay "scapy" (old: {
  postPatch = (old.postPatch or "") + ''
    substituteInPlace scapy/data.py \
      --replace '"/etc/services"'  '"${super.iana-etc}/etc/services"' \
      --replace '"/etc/protocols"' '"${super.iana-etc}/etc/protocols"'
  '';
})) self super
