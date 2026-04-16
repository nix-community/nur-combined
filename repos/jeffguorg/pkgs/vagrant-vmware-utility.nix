{ buildGoModule, fetchFromGitHub, vmware-workstation, coreutils, sources, ... }:
buildGoModule rec {
  inherit (sources.vagrant-vmware-utility) pname version;

  subPackages = [
    "go_src/${pname}"
  ];
  allowGoReference = true;

  vendorHash = "sha256-Gf8kVSv4q6RS4U0JE5qL13IouhsnFfju19eePIYx5Fw=";

  postConfigure = ''
    substituteInPlace go_src/${pname}/utility/vmware_paths_linux.go \
      --replace "/usr/lib/vmware" "${vmware-workstation}/lib/vmware/" \
      --replace "/usr/bin/vmware-networks" "${vmware-workstation}/bin/vmware-networks" \
      --replace "/usr/bin/vmrun" "${vmware-workstation}/bin/vmrun" \
      --replace "/usr/bin/vmware-vdiskmanager" "${vmware-workstation}/bin/vmware-vdiskmanager"
    substituteInPlace go_src/${pname}/utility/paths.go \
      --replace "filepath.Join(installDirectory(), thing)" 'filepath.Join("/etc/${pname}", thing)'
  '';
  postInstall = ''
    mkdir -p $out/config $out/lib/systemd/system
    $out/bin/${pname} service install \
      -print \
      -config-path /etc/${pname}/service.hcl \
      -config-write $out/config/service.hcl \
      -exe-path $out/bin/${pname} \
      -init-style "systemd" > $out/lib/systemd/system/${pname}.service
    sed -i "/^ExecStart=/   a ExecStartPre=${coreutils}/bin/mkdir -pv /etc/${pname}" $out/lib/systemd/system/${pname}.service
    sed -i "/^ExecStartPre=/a ExecStartPre=${coreutils}/bin/cp -u -v $out/config/service.hcl /etc/${pname}" $out/lib/systemd/system/${pname}.service
  '';

  src = sources.vagrant-vmware-utility.src;
}
