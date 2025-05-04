{
  lib,
  writeShellApplication,
}:
writeShellApplication rec {
  name = "ls-iommu";
  derivationArgs.version = "1.0";
  text = ''
    shopt -s nullglob
    lastgroup=""
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        for d in "$g/devices"/*; do
            if [ "''${g##*/}" != "$lastgroup" ]; then
                echo -en "Group ''${g##*/}:\t"
            else
                echo -en "\t\t"
            fi
            lastgroup=''${g##*/}
            lspci -nms "''${d##*/}" | awk -F'"' '{printf "[%s:%s]", $4, $6}'
            if [[ -e "$d"/reset ]]; then echo -en " [R] "; else echo -en "     "; fi

            lspci -mms "''${d##*/}" | awk -F'"' '{printf "%s %-40s %s\n", $1, $2, $6}'
            for u in "''${d}"/usb*/; do
                bus=$(cat "''${u}/busnum")
                lsusb -s "$bus:" | \
                    awk '{gsub(/:/,"",$4); printf "%s|%s %s %s %s|", $6, $1, $2, $3, $4; for(i=7;i<=NF;i++){printf "%s ", $i}; printf "\n"}' | \
                    awk -F'|' '{printf "USB:\t\t[%s]\t\t %-40s %s\n", $1, $2, $3}'
            done
        done
    done
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "List IOMMUs on system";
    homepage = "https://gist.github.com/r15ch13/ba2d738985fce8990a4e9f32d07c6ada";
    license = lib.licenses.free;
    mainProgram = name;
  };
}
