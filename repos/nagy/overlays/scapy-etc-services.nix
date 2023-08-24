final: prev:
(prev.__MkPythonOverlay "scapy" (old: {
  postPatch = (old.postPatch or "") + ''
    substituteInPlace scapy/data.py \
      --replace '"/etc/services"'  '"${prev.iana-etc}/etc/services"' \
      --replace '"/etc/protocols"' '"${prev.iana-etc}/etc/protocols"'
  '';
})) final prev
