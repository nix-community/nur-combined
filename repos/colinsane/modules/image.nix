# this builds a disk image which can be flashed onto a HDD, SD card, etc, and boot a working image.
# debug the image by building one of:
# - `nix build '.#imgs.$host' --builders "" -v`
# - `nix build '.#imgs.$host.passthru.{bootFsImg,nixFsImg,withoutBootloader}'`
# then loop-mounting it:
# - `sudo losetup -Pf ./result/disk.img`
# - `mkdir /tmp/nixos.boot`
# - `sudo mount /dev/loop0p1 /tmp/nixos.boot`, and look inside
#
# TODO: replace mobile-nixos parts with Disko <https://github.com/nix-community/disko>
#   or just inline them here.
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.sane.image;
in
{
  options = {
    # packages whose contents should be copied directly into the /boot partition.
    # e.g. EFI loaders, u-boot bootloader, etc.
    sane.image.extraBootFiles = mkOption {
      default = [];
      type = types.listOf types.package;
    };

    # the GPT header is fixed to Logical Block Address 1,
    # but we can actually put the partition entries anywhere.
    # this option reserves so many bytes after LBA 1 but *before* the partition entries.
    # this is not universally supported, but is an easy hack to claim space near the start
    # of the disk for other purposes (e.g. firmware blobs)
    sane.image.extraGPTPadding = mkOption {
      default = 0;
      # NB: rpi doesn't like non-zero values for this.
      # at the same time, spinning disks REALLY need partitions to be aligned to 4KiB boundaries.
      # maybe there's some imageBuilder.fileSystem type which represents empty space?
      # default = 2014 * 512;  # standard is to start part0 at sector 2048  (versus 34 if no padding)
      type = types.int;
    };
    # optional space (in bytes) to leave unallocated after the GPT structure and before the first partition.
    sane.image.firstPartGap = mkOption {
      # align the first part to 16 MiB.
      # do this by inserting a gap of 16 MiB - gptHeaderSize
      default = 16 * 1024 * 1024 - 34 * 512;
      type = types.nullOr types.int;
    };
    sane.image.platformPartSize = mkOption {
      default = null;
      type = types.nullOr types.int;
      description = ''
        size of the platform firmware (or, bootloader) partition, in bytes.
        most platforms don't need this. the primary user is "depthcharge" chromebooks.
        the partition contents is taken from `config.system.build.platformPartition`.
      '';
    };
    sane.image.bootPartSize = mkOption {
      default = 2 * 1024 * 1024 * 1024;
      type = types.int;
      description = ''
        size of the boot partition, in bytes.
        don't skimp on this. nixos kernels are by default HUGE, and restricting this
        will make kernel tweaking extra painful,
        particularly on non-x86 platforms, most of which don't support compressed kernels.
      '';
    };
    sane.image.sectorSize = mkOption {
      default = 512;
      type = types.int;
      description = ''
        disk sector size. MUST match what the disk firmware believes it to be.
        for nvme drives it may be better to use a large sector size like 4096.
        see: <https://wiki.archlinux.org/title/Advanced_Format#Changing_sector_size>.

        N.B.: setting this to something other than 512B is not well tested.
      '';
    };
    sane.image.installBootloader = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = ''
        command which takes the full disk image and installs hw-specific bootloader (u-boot, tow-boot, etc).
        for EFI-native systems (most x86_64), can be left empty.
      '';
    };
  };
  config = let
    # return the (string) path to get from `stem` to `path`
    # or errors if not a sub-path
    relPath = stem: path: (
      builtins.head (builtins.match "^${stem}(.+)" path)
    );

    fileSystems = config.fileSystems;
    bootFs = fileSystems."/boot";
    nixFs = fileSystems."/nix/store" or fileSystems."/nix" or fileSystems."/";
    # resolves to e.g. "nix/store", "/store" or ""
    storeRelPath = relPath nixFs.mountPoint "/nix/store";

    uuidFromFs = fs: builtins.head (builtins.match "/dev/disk/by-uuid/(.+)" fs.device);
    vfatUuidFromFs = fs: builtins.replaceStrings ["-"] [""] (uuidFromFs fs);

    # TODO: consolidate bootFsImg, nixFsImg builders; split into separate file?

    bootFsImg = pkgs.runCommand "ESP" {
      nativeBuildInputs = with pkgs; [
        dosfstools
        libfaketime
        mtools
        rsync
      ];
      partitionID = vfatUuidFromFs bootFs;
      size = cfg.bootPartSize;
      sectorSize = cfg.sectorSize;
      # partition properties
      partitionLabel = "EFI System";
      partitionType = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";  # "EFI"
      partitionUUID = "44444444-4444-4444-4444-4444${vfatUuidFromFs bootFs}";
    } ''
      # hoisted (in simplified form) from pkgs.mobile-nixos.imageBuilder.fileSystem.makeESP
      mkdir -p $out
      mkdir -p files

      (
        cd files
        echo "installing extraBootFiles"
        for d in ${lib.escapeShellArgs cfg.extraBootFiles}; do
          echo "installing '$d'"
          rsync -arv $d/ ./
        done
        echo "copied extraBootFiles"
      )

      (
        set -x
        truncate -s $size "$out/partition.img"
      )

      echo " -> Making filesystem"
      faketime -f "1970-01-01 00:00:01" mkfs.vfat \
        -F 32 \
        -S "$sectorSize" \
        -i "$partitionID" \
        -n "$partName" \
        "$out/partition.img"

      echo " -> Copying files"
      (
        cd files
        for f in ./* ./.*; do
          if [[ "$f" != "./." && "$f" != "./.." ]]; then
            faketime -f "1970-01-01 00:00:01" \
              mcopy -psv -i "$out/partition.img" "$f" ::
          fi
        done
      )

      echo " -> Checking filesystem"
      fsck.vfat -vn "$out/partition.img"

      cat >> $out/layout.json <<EOF
      {
        "partitionType": "$partitionType",
        "partitionUUID": "$partitionUUID",
        "partitionLabel": "$partitionLabel"
      }
      EOF
    '';

    nixFsImg = pkgs.runCommand "NIXOS_SYSTEM" {
      # fs properties
      nativeBuildInputs = with pkgs; [ btrfs-progs ];
      blockSize = cfg.sectorSize;
      partitionID = uuidFromFs nixFs;
      # partition properties
      partitionLabel = "Linux filesystem";
      partitionType = "0FC63DAF-8483-4772-8E79-3D69D8477DE4";  # "Linux filesystem data"
      partitionUUID = uuidFromFs nixFs;
    } ''
      # hoisted (in simplified form) from pkgs.mobile-nixos.imageBuilder.fileSystem.makeBtrfs
      sum-lines() {
        local acc=0
        while read -r number; do
          acc=$(( $acc + $number))
        done

        echo "$acc"
      }

      compute-minimal-size() {
        local size=0
        (
          cd files
          # Size rounded in blocks. This assumes all files are to be rounded to a
          # multiple of blockSize.
          # Use of `--apparent-size` is to ensure we don't get the block size of the underlying FS.
          # Use of `--block-size` is to get *our* block size.
          size=$(find . ! -type d -print0 | du --files0-from=- --apparent-size --block-size "$blockSize" | cut -f1 | sum-lines)
          echo "Reserving $size sectors for files..." 1>&2

          # Adds one blockSize per directory, they do take some place, in the end.
          local directories=$(find . -type d | wc -l)
          echo "Reserving $directories sectors for directories..." 1>&2
        )

        size=$(( $directories + $size ))
        size=$(( $size * $blockSize))
        echo "$size"
      }

      mkdir -p $out
      mkdir -p files

      (
        cd files
        mkdir -p ./${storeRelPath}
        echo "Copying system closure..."
        while IFS= read -r path; do
          echo "  Copying $path"
          cp -prf "$path" ./${storeRelPath}
        done < "${pkgs.buildPackages.closureInfo { rootPaths = config.system.build.toplevel; }}/store-paths"
        echo "Done copying system closure..."
      )

      (
        size=$(compute-minimal-size)

        set -x
        truncate -s $size "$out/partition.img"
      )

      (
        cd files
        set -x
        mkfs.btrfs \
          -r . \
          -L "$partName" \
          -U "$partitionID" \
          --shrink \
          "$out/partition.img"
      )

      cat >> $out/layout.json <<EOF
      {
        "partitionType": "$partitionType",
        "partitionUUID": "$partitionUUID",
        "partitionLabel": "$partitionLabel"
      }
      EOF
    '';

    platformFsImg = pkgs.runCommand "kernel" {
      filename = "${config.system.build.platformPartition}";
      partSize = cfg.platformPartSize;
      partImage = config.system.build.platformPartition;
      # from: <https://www.chromium.org/chromium-os/chromiumos-design-docs/disk-format>
      partitionType = "FE3A2A5D-4F32-41A7-B725-ACCC3285A309";  # "ChromeOS Kernel"
      partitionLabel = "kernel";  #< TODO: is it safe to rename this?
    } ''
      mkdir $out
      truncate -s $partSize $out/partition.img
      dd if=$partImage of=$out/partition.img bs=512
      # TODO: assert that the `dd` command didn't overflow the allocated partition space
      cat >> $out/layout.json <<EOF
      {
        "partitionType": "$partitionType",
        "partitionUUID": "$partitionUUID",
        "partitionLabel": "$partitionLabel"
      }
      EOF
    '';

    img = pkgs.runCommand "nixos" {
      nativeBuildInputs = with pkgs; [
        jq
        vboot_reference
      ];
      partitions = lib.optionals (cfg.platformPartSize != null) [
        platformFsImg
      ] ++ [
        bootFsImg
        nixFsImg
      ];
      inherit (cfg)
        firstPartGap
        sectorSize
        extraGPTPadding
      ;
      passthru = {
        inherit bootFsImg nixFsImg;
      };
    } ''
      # hoisted (in simplified form) from pkgs.mobile-nixos.imageBuilder.diskImage.makeGPT
      roundUp() {
        # adjusts $1 upward until it's a multiple of $2.
        local inp=$1
        local mult=$2
        if (($inp % $mult)); then
          echo $(( $mult + $inp / $mult * $mult ))
        else
          echo $inp
        fi
      }
      getPartSize() {
        local partImg="$1/partition.img"
        local partSize=$(($(du --apparent-size -B 512 "$partImg" | awk '{ print $1 }') * 512))
        echo $(roundUp $partSize $mb)
      }
      mb=$((1024*1024))

      mkdir -p $out

      # 34 is the base GPT header size, as added to -p by cgpt.
      # more precisely: PMBR (1 block) + Primary GPT header (1 block) + Primary GPT Table (32 blocks)
      gptSize=$((34*512))
      part0Start=$(( $extraGPTPadding + $gptSize + $firstPartGap ))

      (
        # solve for the size of the disk image
        echo "planned disk layout:"
        echo "- 0 -> primary GPT header"
        totalSize=$part0Start
        for part in $partitions; do
          echo "- $totalSize -> $part"
          partSize=$(getPartSize $part)
          totalSize=$(( $totalSize + $partSize ))
        done
        echo "- $totalSize -> secondary GPT header"
        totalSize=$(( $totalSize + $gptSize ))
        echo "- $totalSize -> end of disk"

        truncate -s $totalSize $out/disk.img
        # Zeroes the GPT
        ( set -x ; cgpt create -z $out/disk.img )
        # Create the GPT, optionally with some extra padding between the primary GPT header and the primary GPT table
        ( set -x ; cgpt create -p $(( $extraGPTPadding / $sectorSize )) $out/disk.img )
        # Add the PMBR
        ( set -x ; cgpt boot -p $out/disk.img )
      )

      (
        partStart=$part0Start
        for part in $partitions; do
          partSize=$(getPartSize $part)
          partitionType=$(jq -r .partitionType $part/layout.json)
          partitionUUID=$(jq -r .partitionUUID $part/layout.json)
          partitionLabel=$(jq -r .partitionLabel $part/layout.json)

          (
            set -x
            cgpt add \
              -b "$(( $partStart / $sectorSize ))" \
              -s "$(( $partSize / $sectorSize ))" \
              -t "$partitionType" \
              -u "$partitionUUID" \
              -l "$partitionLabel" \
              $out/disk.img
            dd conv=notrunc if=$part/partition.img of=$out/disk.img \
              seek=$(( $partStart / $sectorSize)) count=$(( $partSize / $sectorSize )) bs=$sectorSize
          )

          partStart=$(( $partStart + $partSize ))
        done
      )

      echo "disk image created:"
      ls -lh $out/disk.img
      cgpt show $out/disk.img
    '';
  in
  {
    system.build.img = pkgs.runCommand "nixos-with-bootloader" {
      preferLocalBuild = true;
      passthru = {
        inherit bootFsImg nixFsImg;
        withoutBootloader = img;  #< XXX: this derivation places the image at $out/disk.img
      };
    } (
      if cfg.installBootloader == null then ''
        ln -s ${img}/disk.img $out
      '' else ''
        cp ${img}/disk.img $out
        chmod +w $out
        (
          set -x
          ${cfg.installBootloader}
        )
        chmod -w $out
      ''
    );

    sane.image.extraBootFiles =
      lib.optionals config.boot.loader.generic-extlinux-compatible.enable [
        (pkgs.runCommandLocal "populate-extlinux" {} ''
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d "$out"
        '')
      ]
      ++
      lib.optionals config.boot.loader.systemd-boot.enable ([
        pkgs.bootpart-systemd-boot
        # it'd be cool to use `config.system.build.installBootLoader` to install both the bootloader config AND the bootloader itself,
        # but the combination of custom nixpkgs logic + systemd's sanity checking makes it near impossible to use
        # outside a live system.
        # so manually generate a bootloader entry:
        (pkgs.runCommandLocal "populate-systemd-boot" {} ''
          toplevel=${config.system.build.toplevel}
          dtbpath=${if config.hardware.deviceTree.name != null then config.hardware.deviceTree.name else ""}
          kernel_params=$(cat "$toplevel/kernel-params")

          kernel=$(readlink "$toplevel/kernel")
          kernel_name="''${kernel/\/nix\/store\//}"
          kernel_name="''${kernel_name/\//-}"
          efi_kernel="/EFI/nixos/$kernel_name.efi"
          install -Dm644 "$kernel" "$out/$efi_kernel"

          initrd=$(readlink "$toplevel/initrd")
          initrd_name="''${initrd/\/nix\/store\//}"
          initrd_name="''${initrd_name/\//-}"
          efi_initrd="/EFI/nixos/$initrd_name.efi"
          install -Dm644 "$initrd" "$out/$efi_initrd"

          efi_dtb=
          if [ -n "$dtbpath" ]; then
            dtbs=$(readlink "$toplevel/dtbs")
            dtbs_name="''${dtbs/\/nix\/store\//}"
            dtbs_name="''${dtbs_name/\//-}"
            # nixos-generated devicetree path is relative to /boot instead of being fully qualified, for some reason.
            efi_dtb="EFI/nixos/$dtbs_name-$(basename $dtbpath).efi"
            install -Dm644 "$dtbs/$dtbpath" "$out/$efi_dtb"
          fi

          mkdir -p $out/loader/entries
          cat > $out/loader/entries/nixos-generation-0.conf <<EOF
            title NixOS
            sort-key nixos
            version Generation 0 NixOS
            linux $efi_kernel
            initrd $efi_initrd
            options init=$toplevel/init $kernel_params
            ''${efi_dtb:+devicetree $efi_dtb}
          EOF
          cat > $out/loader/loader.conf <<EOF
            timeout 5
            default nixos-generation-0.conf
            console-mode keep
          EOF
        '')
      ])
    ;
  };
}
