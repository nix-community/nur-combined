/*
just a messy work-in-progress draft, which i will probably never finish
based on: nixpkgs/pkgs/build-support/docker/default.nix
sample use: test.nix
*/
{ bashInteractive
, buildPackages
, cacert
, callPackage
, closureInfo
, coreutils
, e2fsprogs
, fakeroot
, findutils
, go
, jq
, jshon
, lib
, makeWrapper
, moreutils
, nix
, pigz
, pkgs
, rsync
, runCommand
, runtimeShell
, shadow
, skopeo
, storeDir ? builtins.storeDir
, substituteAll
, symlinkJoin
, util-linux
, vmTools
, writeReferencesToFile
, writeScript
, writeText
, writeTextDir
, writers
}:

let

  mkDbExtraCommand = contents:
    let
      contentsList = if builtins.isList contents then contents else [ contents ];
    in
    ''
      echo "Generating the nix database..."
      echo "Warning: only the database of the deepest Nix layer is loaded."
      echo "         If you want to use nix commands in the container, it would"
      echo "         be better to only have one layer that contains a nix store."

      export NIX_REMOTE=local?root=$PWD
      # A user is required by nix
      # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
      export USER=nobody
      ${buildPackages.nix}/bin/nix-store --load-db < ${closureInfo {rootPaths = contentsList;}}/registration

      mkdir -p nix/var/nix/gcroots/docker/
      for i in ${lib.concatStringsSep " " contentsList}; do
      ln -s $i nix/var/nix/gcroots/docker/$(basename $i)
      done;
    '';

  # The OCI Image specification recommends that configurations use values listed
  # in the Go Language document for GOARCH.
  # Reference: https://github.com/opencontainers/image-spec/blob/master/config.md#properties
  # For the mapping from Nixpkgs system parameters to GOARCH, we can reuse the
  # mapping from the go package.
  defaultArch = go.GOARCH;

in
rec {
  examples = callPackage ./examples.nix {
    inherit buildImage buildLayeredImage fakeNss pullImage shadowSetup buildImageWithNixDb;
  };

  pullImage =
    let
      fixName = name: builtins.replaceStrings [ "/" ":" ] [ "-" "-" ] name;
    in
    { imageName
      # To find the digest of an image, you can use skopeo:
      # see doc/functions.xml
    , imageDigest
    , sha256
    , os ? "linux"
    , arch ? defaultArch

      # This is used to set name to the pulled image
    , finalImageName ? imageName
      # This used to set a tag to the pulled image
    , finalImageTag ? "latest"
      # This is used to disable TLS certificate verification, allowing access to http registries on (hopefully) trusted networks
    , tlsVerify ? true

    , name ? fixName "docker-image-${finalImageName}-${finalImageTag}.tar"
    }:

    runCommand name
      {
        inherit imageDigest;
        imageName = finalImageName;
        imageTag = finalImageTag;
        impureEnvVars = lib.fetchers.proxyImpureEnvVars;
        outputHashMode = "flat";
        outputHashAlgo = "sha256";
        outputHash = sha256;

        nativeBuildInputs = lib.singleton skopeo;
        SSL_CERT_FILE = "${cacert.out}/etc/ssl/certs/ca-bundle.crt";

        sourceURL = "docker://${imageName}@${imageDigest}";
        destNameTag = "${finalImageName}:${finalImageTag}";
      } ''
      skopeo \
        --insecure-policy \
        --tmpdir=$TMPDIR \
        --override-os ${os} \
        --override-arch ${arch} \
        copy \
        --src-tls-verify=${lib.boolToString tlsVerify} \
        "$sourceURL" "oci-archive://$out:$destNameTag" \
        
        
        #| cat  # pipe through cat to force-disable progress bar
    '';

  # buildEnv creates symlinks to dirs, which is hard to edit inside the overlay VM
  mergeDrvs =
    { derivations
    , onlyDeps ? false
    }:
    runCommand "merge-drvs"
      {
        inherit derivations onlyDeps;
      } ''
      if [[ -n "$onlyDeps" ]]; then
        echo $derivations > $out
        exit 0
      fi

      mkdir $out
      for derivation in $derivations; do
        echo "Merging $derivation..."
        if [[ -d "$derivation" ]]; then
          # If it's a directory, copy all of its contents into $out.
          cp -drf --preserve=mode -f $derivation/* $out/
        else
          # Otherwise treat the derivation as a tarball and extract it
          # into $out.
          tar -C $out -xpf $drv || true
        fi
      done
    '';

  # Helper for setting up the base files for managing users and
  # groups, only if such files don't exist already. It is suitable for
  # being used in a runAsRoot script.
  shadowSetup = ''
    export PATH=${shadow}/bin:$PATH
    mkdir -p /etc/pam.d
    if [[ ! -f /etc/passwd ]]; then
      echo "root:x:0:0::/root:${runtimeShell}" > /etc/passwd
      echo "root:!x:::::::" > /etc/shadow
    fi
    if [[ ! -f /etc/group ]]; then
      echo "root:x:0:" > /etc/group
      echo "root:x::" > /etc/gshadow
    fi
    if [[ ! -f /etc/pam.d/other ]]; then
      cat > /etc/pam.d/other <<EOF
    account sufficient pam_unix.so
    auth sufficient pam_rootok.so
    password requisite pam_unix.so nullok sha512
    session required pam_unix.so
    EOF
    fi
    if [[ ! -f /etc/login.defs ]]; then
      touch /etc/login.defs
    fi
  '';

  # Run commands in a virtual machine.
  runWithOverlay =
    { name
    , fromImage ? null
    , fromImageName ? null
    , fromImageTag ? null
    , diskSize ? 1024
    , preMount ? ""
    , postMount ? ""
    , postUmount ? ""
    }:
      vmTools.runInLinuxVM (
        runCommand name
          {
            preVM = vmTools.createEmptyImage {
              size = diskSize;
              fullName = "docker-run-disk";
              destination = "./image";
            };
            inherit fromImage fromImageName fromImageTag;

            nativeBuildInputs = [ util-linux e2fsprogs jshon rsync jq ];
          } ''
          mkdir disk
          mkfs /dev/${vmTools.hd}
          mount /dev/${vmTools.hd} disk
          cd disk

          # TODO refactor docker/oci code in runWithOverlay and buildImage
          touch layer-list
          if [[ -n "$fromImage" ]]; then
            echo "Unpacking base image..."
            mkdir image
            tar -C image -xpf "$fromImage"
            if [ -e image/manifest.json ]; then
              imageFormat=docker
              manifestFile=image/manifest.json
              parentIDFilter1='.[] | select(.RepoTags | contains([$desiredTag])).Config | rtrimstr(".json")'
              parentIDFilter2='.[0].Config | rtrimstr(".json")'
            else if [ -e image/index.json ]; then
              imageFormat=oci
              manifestFile=image/index.json
              # TODO handle single-manifest oci format
              # TODO verify parentID
              parentIDFilter1='.manifests[] | select(.annotations."org.opencontainers.image.ref.name" == $desiredTag).digest | ltrimstr("sha256:")'
              parentIDFilter2='.manifests[0].digest | ltrimstr("sha256:")'
            else
              echo "Failed to detect format of fromImage $fromImage"
              exit 1
            fi

            if [[ -n "$fromImageName" ]] && [[ -n "$fromImageTag" ]]; then
              parentID=$(cat $manifestFile | jq -r "$parentIDFilter1" --arg desiredTag "$fromImageName:$fromImageTag")
            else
              # TODO only print this if tag is ambiguous?
              echo "From-image name or tag wasn't set. Reading the first ID."
              parentID="$(cat $manifestFile | jq -r "$parentIDFilter2")"
            fi
            if [ "$imageFormat" = "docker" ]; then
              cat $manifestFile | jq -r '.[0].Layers | .[]' > layer-list
            else
              cat image/blobs/sha256/$parentID | jq -r '.layers[] | .digest | ltrimstr("sha256:")' > layer-list
            fi
          fi

          # Unpack all of the parent layers into the image.
          lowerdir=""
          extractionID=0
          for layerTar in $(tac layer-list); do
            if [ "$imgFmt" = "docker" ]
            then layerTarFile=image/$layerTar
            else layerTarFile=image/blobs/sha256/$layerTar
            fi
            echo "Unpacking layer $layerTar"
            extractionID=$((extractionID + 1))
            mkdir -p image/$extractionID/layer
            tar -C image/$extractionID/layer -xpf $layerTarFile
            rm $layerTarFile

            find image/$extractionID/layer -name ".wh.*" -exec bash -c 'name="$(basename {}|sed "s/^.wh.//")"; mknod "$(dirname {})/$name" c 0 0; rm {}' \;

            # Get the next lower directory and continue the loop.
            lowerdir=image/$extractionID/layer''${lowerdir:+:}$lowerdir
          done

          mkdir work
          mkdir layer
          mkdir mnt

          ${lib.optionalString (preMount != "") ''
            # Execute pre-mount steps
            echo "Executing pre-mount steps..."
            ${preMount}
          ''}

          if [ -n "$lowerdir" ]; then
            mount -t overlay overlay -olowerdir=$lowerdir,workdir=work,upperdir=layer mnt
          else
            mount --bind layer mnt
          fi

          ${lib.optionalString (postMount != "") ''
            # Execute post-mount steps
            echo "Executing post-mount steps..."
            ${postMount}
          ''}

          umount mnt

          (
            cd layer
            cmd='name="$(basename {})"; touch "$(dirname {})/.wh.$name"; rm "{}"'
            find . -type c -exec bash -c "$cmd" \;
          )

          ${postUmount}
        '');

  exportImage = { name ? fromImage.name, fromImage, fromImageName ? null, fromImageTag ? null, diskSize ? 1024 }:
    runWithOverlay {
      inherit name fromImage fromImageName fromImageTag diskSize;

      postMount = ''
        echo "Packing raw image..."
        tar -C mnt --hard-dereference --sort=name --mtime="@$SOURCE_DATE_EPOCH" -cf $out/layer.tar .
      '';

      postUmount = ''
        mv $out/layer.tar .
        rm -rf $out
        mv layer.tar $out
      '';
    };

  # Create an executable shell script which has the coreutils in its
  # PATH. Since root scripts are executed in a blank environment, even
  # things like `ls` or `echo` will be missing.
  shellScript = name: text:
    writeScript name ''
      #!${runtimeShell}
      set -e
      export PATH=${coreutils}/bin:/bin
      ${text}
    '';

  # Create a "layer" (set of files).
  mkPureLayer =
    {
      # Name of the layer
      name
    , # JSON containing configuration and metadata for this layer.
      baseJson
    , # Files to add to the layer.
      contents ? null
    , # When copying the contents into the image, preserve symlinks to
      # directories (see `rsync -K`).  Otherwise, transform those symlinks
      # into directories.
      keepContentsDirlinks ? false
    , # Additional commands to run on the layer before it is tar'd up.
      extraCommands ? ""
    , uid ? 0
    , gid ? 0
    }:
    runCommand "container-layer-${name}.tar"
      {
        inherit baseJson contents extraCommands;
        nativeBuildInputs = [ jshon rsync ];
      }
      ''
        mkdir layer
        if [[ -n "$contents" ]]; then
          echo "Adding contents..."
          for item in $contents; do
            echo "Adding $item"
            rsync -a${if keepContentsDirlinks then "K" else "k"} --chown=0:0 $item/ layer/
          done
        else
          echo "No contents to add to layer."
        fi

        chmod ug+w layer

        if [[ -n "$extraCommands" ]]; then
          (cd layer; eval "$extraCommands")
        fi

        echo "Packing layer..."
        tar -C layer --hard-dereference --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
          --owner=${toString uid} --group=${toString gid} -cf - . > $out
        # checksum will change later
        echo "Finished building layer '${name}'"
      '';

  # Make a "root" layer; required if we need to execute commands as a
  # privileged user on the image. The commands themselves will be
  # performed in a virtual machine sandbox.
  mkRootLayer =
    {
      # Name of the image.
      name
    , # Script to run as root. Bash.
      runAsRoot
    , # Files to add to the layer. If null, an empty layer will be created.
      contents ? null
    , # When copying the contents into the image, preserve symlinks to
      # directories (see `rsync -K`).  Otherwise, transform those symlinks
      # into directories.
      keepContentsDirlinks ? false
    , # JSON containing configuration and metadata for this layer.
      baseJson
    , # Existing image onto which to append the new layer.
      fromImage ? null
    , # Name of the image we're appending onto.
      fromImageName ? null
    , # Tag of the image we're appending onto.
      fromImageTag ? null
    , # How much disk to allocate for the temporary virtual machine.
      diskSize ? 1024
    , # Commands (bash) to run on the layer; these do not require sudo.
      extraCommands ? ""
    }:
    # Generate an executable script from the `runAsRoot` text.
    let
      runAsRootScript = shellScript "run-as-root.sh" runAsRoot;
      extraCommandsScript = shellScript "extra-commands.sh" extraCommands;
    in
    runWithOverlay {
      name = "docker-layer-${name}";

      inherit fromImage fromImageName fromImageTag diskSize;

      preMount = lib.optionalString (contents != null && contents != [ ]) ''
        echo "Adding contents..."
        for item in ${toString contents}; do
          echo "Adding $item..."
          rsync -a${if keepContentsDirlinks then "K" else "k"} --chown=0:0 $item/ layer/
        done

        chmod ug+w layer
      '';

      postMount = ''
        mkdir -p mnt/{dev,proc,sys} mnt${storeDir}

        # Mount /dev, /sys and the nix store as shared folders.
        mount --rbind /dev mnt/dev
        mount --rbind /sys mnt/sys
        mount --rbind ${storeDir} mnt${storeDir}

        # Execute the run as root script. See 'man unshare' for
        # details on what's going on here; basically this command
        # means that the runAsRootScript will be executed in a nearly
        # completely isolated environment.
        #
        # Ideally we would use --mount-proc=mnt/proc or similar, but this
        # doesn't work. The workaround is to setup proc after unshare.
        # See: https://github.com/karelzak/util-linux/issues/648
        unshare -imnpuf --mount-proc sh -c 'mount --rbind /proc mnt/proc && chroot mnt ${runAsRootScript}'

        # Unmount directories and remove them.
        umount -R mnt/dev mnt/sys mnt${storeDir}
        rmdir --ignore-fail-on-non-empty \
          mnt/dev mnt/proc mnt/sys mnt${storeDir} \
          mnt$(dirname ${storeDir})
      '';

      postUmount = ''
        (cd layer; ${extraCommandsScript})

        echo "Packing layer..."
        mkdir -p $out/blobs/sha256
        tar -C layer --hard-dereference --sort=name --mtime="@$SOURCE_DATE_EPOCH" -cf - . > $out/layer.tar
        # TODO avoid sha256sum?
        tarhash=$(sha256sum $out/layer.tar | cut -d' ' -f1)
        echo debug 454
        mv -v $out/layer.tar $out/blobs/sha256/$tarhash
        echo tar > $out/layer-type
        echo "Finished building layer '${name}' -> blobs/sha256/$tarhash"
      '';
    };

  buildLayeredImage = { name, ... }@args:
    let
      stream = streamLayeredImage args;
    in
    runCommand "${baseNameOf name}.tar.gz" # TODO compress or no compress?
      {
        inherit (stream) imageName;
        passthru = { inherit (stream) imageTag; };
        nativeBuildInputs = [ pigz ];
      } "${stream} | pigz -nT > $out";

  # 1. extract the base image
  # 2. create the layer
  # 3. add layer deps to the layer itself, diffing with the base image
  # 4. compute the layer id
  # 5. put the layer in the image
  # 6. repack the image
  buildImage =
    args@{
      # Image name.
      name
    , # Image tag, when null then the nix output hash will be used.
      tag ? null
    , # Parent image, to append to.
      fromImage ? null
    , # Name of the parent image; will be read from the image otherwise.
      fromImageName ? null
    , # Tag of the parent image; will be read from the image otherwise.
      fromImageTag ? null
    , # Files to put on the image (a nix store path or list of paths).
      contents ? null
    , # When copying the contents into the image, preserve symlinks to
      # directories (see `rsync -K`).  Otherwise, transform those symlinks
      # into directories.
      keepContentsDirlinks ? false
    , # Docker config; e.g. what command to run on the container.
      config ? null
    , # Optional bash script to run on the files prior to fixturizing the layer.
      extraCommands ? ""
    , uid ? 0
    , gid ? 0
    , # Optional bash script to run as root on the image when provisioning.
      runAsRoot ? null
    , # Size of the virtual machine disk to provision when building the image.
      diskSize ? 1024
    , # Time of creation of the image.
      created ? "1970-01-01T00:00:01Z"
    #, compressionLevel ? 6 # valid range: 0 to 9. see: man pigz
    , compressionLevel ? 0 # valid range: 0 to 9. see: man pigz
    , compress ? true # true -> tar.gz, false -> tar
    ,
    }:

    let
      baseName = baseNameOf name;

      # Create a JSON blob of the configuration. Set the date to unix zero.
      baseJson =
        let
          pure = writeText "${baseName}-config.json" (builtins.toJSON {
            inherit created config;
            architecture = defaultArch;
            os = "linux";
          });
          impure = runCommand "${baseName}-config.json"
            { nativeBuildInputs = [ jq ]; }
            ''
              jq ".created = \"$(TZ=utc date --iso-8601="seconds")\"" ${pure} > $out
            '';
        in
        if created == "now" then impure else pure;

      layer =
        if runAsRoot == null
        then
          mkPureLayer
            {
              name = baseName;
              inherit baseJson contents keepContentsDirlinks extraCommands uid gid;
            } else
          mkRootLayer {
            name = baseName;
            inherit baseJson fromImage fromImageName fromImageTag
              contents keepContentsDirlinks runAsRoot diskSize
              extraCommands;
          };
      result = runCommand "container-image-${baseName}.tar${lib.optionalString compress ".gz"}"
        {
          nativeBuildInputs = [ jshon pigz coreutils findutils jq moreutils ];
          # Image name must be lowercase
          imageName = lib.toLower name;
          imageTag = if tag == null then "" else tag;
          inherit fromImage baseJson;
          layerClosure = writeReferencesToFile layer;
          passthru.buildArgs = args;
          passthru.layer = layer;
          passthru.imageTag =
            if tag != null
            then tag
            else
              lib.head (lib.strings.splitString "-" (baseNameOf result.outPath));
        } ''
        ${lib.optionalString (tag == null) ''
          outName="$(basename "$out")"
          outHash=$(echo "$outName" | cut -d - -f 1)

          imageTag=$outHash
        ''}

        echo "debug: line 570"
        set -o xtrace; PS4='+ Line $(expr $LINENO + 557): '

        # TODO optimize ls_tar - hot code!
        
        # Print tar contents:
        # 1: Interpreted as relative to the root directory
        # 2: With no trailing slashes on directories
        # This is useful for ensuring that the output matches the
        # values generated by the "find" command
        ls_tar() {
          tar -tf $1 | sed -E 's|^\./|/|; s|^[^/]|/&|; s|/$||' | grep -v '^$'
          # | tee /dev/stderr # debug
        }

        mkdir temp image
        touch baseFiles
        baseEnvs='[]'

        # TODO refactor docker/oci code in runWithOverlay and buildImage
        touch layer-list # paths to layer tars

        echo "debug: line 590"
        echo "debug: fromImage = $fromImage"
        


        # FIXME why /etc has permissions 0555 = read only?
        # in source, /etc has 0755, /tmp has 1755 (sticky bit)
        # here, $(umask) == 0022, as it should be
        # problem is NOT here.
        # here we extract only the OCI image,
        # but the linux filesystem (etc, tmp, ...)
        # is in the layerTar files, so perms are preserved

        if [[ -n "$fromImage" ]]; then
          echo "Unpacking base image..."
          tar -C temp -xpf "$fromImage"

          echo "debug 597: find temp"; find temp
          # FIXME properly import docker image

          if [ -e temp/manifest.json ]; then
            imageFormat=docker
            manifestFile=temp/manifest.json
            layersFilter='.[0].Layers | .[]'
            parentIDFilter1='.[] | select(.RepoTags | contains([$desiredTag])).Config | rtrimstr(".json")'
            parentIDFilter2='.[0].Config | rtrimstr(".json")'
          elif [ -e temp/index.json ]; then
            imageFormat=oci
            manifestFile=temp/index.json
            layersFilter='.[0].Layers | .[]'
            # TODO handle single-manifest oci format
              # TODO verify parentID
            parentIDFilter1='.manifests[] | select(.annotations."org.opencontainers.image.ref.name" == $desiredTag).digest | ltrimstr("sha256:")'
            parentIDFilter2='.manifests[0].digest | ltrimstr("sha256:")'
          else
            echo "Failed to detect format of fromImage $fromImage"
            exit 1
          fi

          ###########



          ###########

          # Extract the parentID from the manifest
          if [[ -n "$fromImageName" ]] && [[ -n "$fromImageTag" ]]; then
            parentID=$(cat $manifestFile | jq -r "$parentIDFilter1" --arg desiredTag "$fromImageName:$fromImageTag")
          else
            echo "From-image name or tag wasn't set. Reading the first ID."
            parentID="$(cat $manifestFile | jq -r "$parentIDFilter2")"
          fi

          # Store the layers and the environment variables from the base image
          if [ "$imageFormat" = "docker" ]; then
            cat $manifestFile | jq -r '.[0].Layers | .[]' > layer-list
            configName=$(cat $manifestFile | jq -r '.[0].Config')
            baseEnvs="$(cat temp/$configName | jq '.config.Env // []')"
          else
            echo blobs/sha256/$(cat temp/blobs/sha256/$parentID | jq -r '.layers[] | .digest | ltrimstr("sha256:")') > layer-list
            configName=$(cat temp/blobs/sha256/$parentID | jq -r '.config.digest | ltrimstr("sha256:")')
            baseEnvs="$(cat temp/blobs/$configName | jq '.config.Env // []')"
          fi

          # Otherwise do not import the base image configuration and manifest
          # TODO(milahu) wdym "Otherwise"?
          chmod -R a+w temp
          # TODO(milahu) why rm? have we parsed all json files at this point?
          #rm -f temp/*.json

          echo "debug 644: cat layer-list"
          cat layer-list
          echo "debug 646"

          ls -l image
          ls -l temp/*

          for layerTar in $(cat layer-list); do
            sha256sum temp/$layerTar
            tar tf temp/$layerTar | head || true
          done

          for mysteryTar in temp/*/layer.tar; do
            sha256sum $mysteryTar
            tar tf $mysteryTar | head || true
          done

          echo "debug 666: find ."; find .
          #####exit 1

          if [ "$imageFormat" = "docker" ]; then
            for l in temp/*/layer.tar; do ls_tar $l >> baseFiles; done
          else
            for l in $(cat layer-list); do ls_tar temp/blobs/$l >> baseFiles; done
          fi
        fi

        echo TODO move needed files from temp to image
        find temp

        if [ "$imageFormat" = "docker" ]; then
          # convert docker to oci
          # TODO support "nested index"? https://github.com/opencontainers/image-spec/blob/main/image-index.md
          # or do we need only the layers of fromImage?
          mkdir -p image/blobs/sha256
          # TODO must we buffer contents of layer-list?
          for layerTar in $(cat layer-list); do
            layerSum=''${layerTar%%.*}
            mv temp/$layerTar image/blobs/sha256/$layerSum
            sed -i "s|$layerTar|blobs/sha256/$layerSum|" layer-list
          done
          echo "TODO 686: what else must we convert?"
        else
          mv -v temp/* image/
        fi

        ################exit 1

        chmod -R ug+rw image

        echo "debug 695: find temp"; find temp
        echo "debug 696: rm -rf temp/*"
        rm -rf temp/*

        echo "debug 699: find layer"; find ${layer}

        cp -r ${layer} temp/layer.tar
        chmod ug+w temp/*

        echo "debug: find temp"; find temp

        cat $layerClosure | xargs find >layerFiles

        echo "Adding layer..."
        # Record the contents of the tarball with ls_tar.

        # TODO remove
        #layerTar="$(find temp/ -path temp/layer.tar -or -path 'temp/blobs/sha256/*')"
        #[ $(echo "$layerTar" | wc -l) = 1 ] || {
        #  echo "assertion error. found multiple tars in layer ${layer}:"; echo "$layerTar"; exit 1; }
        #  # TODO implement?

        layerTar=temp/layer.tar
        ls_tar $layerTar >> baseFiles

        # Append nix/store directory to the layer so that when the layer is loaded in the
        # image /nix/store has read permissions for non-root users.
        # nix/store is added only if the layer has /nix/store paths in it.
        if [ $(wc -l < $layerClosure) -gt 1 ] && [ $(grep -c -e "^/nix/store$" baseFiles) -eq 0 ]; then
          mkdir -p nix/store
          chmod -R 555 nix
          echo "./nix" >> layerFiles
          echo "./nix/store" >> layerFiles
        fi

        # Get the files in the new layer which were *not* present in
        # the old layer, and record them as newFiles.
        comm <(sort -n baseFiles|uniq) \
             <(sort -n layerFiles|uniq|grep -v ${layer}) -1 -3 > newFiles
        # Append the new files to the layer.

        # FIXME

        if false; then
        #echo "#### debug: cat newFiles"
        #cat newFiles
        echo "#### debug: stat layerTar"
        stat $layerTar
        echo "#### debug: tar tf layerTar"
        tar tf $layerTar
        echo "#### debug"
        fi

        # modify tar -> new checksum
        echo debug 703
        mv -v $layerTar layer.tar
        layerTar=layer.tar
        echo debug 706

        tar -rpf $layerTar --hard-dereference --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
          --owner=0 --group=0 --no-recursion --verbatim-files-from --files-from newFiles

        echo "Adding meta..."

        # TODO(milahu) no parentID in oci format?
        if false; then
        # If we have a parentID, add it to the json metadata.
        if [[ -n "$parentID" ]]; then
          cat temp/json | jshon -s "$parentID" -i parent | sponge temp/json
        fi
        fi # if false

        if false; then
          # Take the sha256 sum of the generated json and use it as the layer ID.
          # Compute the size and add it to the json under the 'Size' field.
          layerID=$(sha256sum temp/json | cut -d ' ' -f 1)
          size=$(stat --printf="%s" $layerTar)
          cat temp/json | jshon -s "$layerID" -i id -n $size -i Size > tmpjson
          mv tmpjson temp/json

          # Use the temp folder we've been working on to create a new image.
          mv temp image/$layerID

          # Add the new layer ID to the end of the layer list
          echo "$layerID/layer.tar" >>layer-list
        fi # if false


        echo "debug 783"
        layerChecksum=$(sha256sum $layerTar | cut -d ' ' -f 1)
        echo blobs/sha256/$layerChecksum >>layer-list

        mkdir -p image/blobs/sha256
        mv $layerTar image/blobs/sha256/$layerChecksum
        layerTar=image/blobs/sha256/$layerChecksum

        echo "debug 740: find ."; find .

        # Create image json and image manifest
        imageJson=$(cat ${baseJson} | jq '.config.Env = $baseenv + .config.Env' --argjson baseenv "$baseEnvs")
        imageJson=$(echo "$imageJson" | jq ". + {\"rootfs\": {\"diff_ids\": [], \"type\": \"layers\"}}")
        manifestJson=$(jq -n '{"schemaVersion":2,"config":{},"layers":[]}')

        # add layers
        if false; then
          for layerTar in $(cat ./layer-list); do
            layerChecksum=$(sha256sum image/$layerTar | cut -d ' ' -f1)
            imageJson=$(echo "$imageJson" | jq ".history |= . + [{\"created\": \"$(jq -r .created ${baseJson})\"}]")
            # diff_ids order is from the bottom-most to top-most layer
            imageJson=$(echo "$imageJson" | jq ".rootfs.diff_ids |= . + [\"sha256:$layerChecksum\"]")
            manifestJson=$(echo "$manifestJson" | jq ".[0].Layers |= . + [\"$layerTar\"]")
          done
        fi # if false

        cat layer-list
        echo "debug 771: find image"; find image

        # FIXME image/ contains old format and new format
        #image/746e646689cefccc4b07923569a7d658580ff9487482f59f80171f1bee5badbb
        #image/746e646689cefccc4b07923569a7d658580ff9487482f59f80171f1bee5badbb/json
        #image/746e646689cefccc4b07923569a7d658580ff9487482f59f80171f1bee5badbb/VERSION
        #image/746e646689cefccc4b07923569a7d658580ff9487482f59f80171f1bee5badbb/layer.tar
        #image/repositories
        #image/e2eb06d8af8218cfec8210147357a68b7e13f7c485b991c288c2d01dc228bb68.tar
        #image/blobs
        #image/blobs/sha256
        #image/blobs/sha256/7d8d9175409afd620c1b2cbd60bf3a2c27d11c36baea379a36196ea07a6370d3

        # FIXME wrong path in layer-list

        # add config to manifest
        imageJson=$(echo "$imageJson" | jq -c)
        imageJsonChecksum=$(echo "$imageJson" | sha256sum | cut -d ' ' -f1)
        imageJsonSize=$(expr length "$imageJson"$'\n')
        #echo "$imageJson" > image/$imageJsonChecksum.json # docker
        echo "$imageJson" > image/blobs/sha256/$imageJsonChecksum # oci
        #manifestJson=$(echo "$manifestJson" | jq ".[0].Config = \"$imageJsonChecksum.json\"") # docker
        manifestJson=$(echo "$manifestJson" | jq '.config = {"mediaType": "application/vnd.oci.image.config.v1+json",
          "digest": "sha256:'$imageJsonChecksum'", "size": '$imageJsonSize'}') # oci

        # add layers to manifest
        echo "debug 826"
        for layerTar in $(cat layer-list); do
          echo "debug: layerTar = $layerTar"
          if [ "''${layerTar:0:13}" != "blobs/sha256/" ]; then
            layerChecksum=$(sha256sum image/$layerTar | cut -d ' ' -f1)
            mv -v image/$layerTar image/blobs/sha256/$layerChecksum
            layerTar=image/blobs/sha256/$layerChecksum
          else layerChecksum=$(basename $layerTar); fi
          #imageJson=$(echo "$imageJson" | jq ".history |= . + [{\"created\": \"$(jq -r .created ${baseJson})\"}]")
          # diff_ids order is from the bottom-most to top-most layer
          #imageJson=$(echo "$imageJson" | jq ".rootfs.diff_ids |= . + [\"sha256:$layerChecksum\"]")
          #manifestJson=$(echo "$manifestJson" | jq ".[0].Layers |= . + [\"$layerTar\"]")
          # FIXME no such file
          layerSize=$(stat --printf="%s" image/blobs/sha256/$layerChecksum)
          manifestJson=$(echo "$manifestJson" | jq '.layers += [{"mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "digest": "sha256:'$layerChecksum'", "size": '$layerSize'}]') # oci
        done

        # add manifest to index
        manifestJson=$(echo "$manifestJson" | jq -c)
        #echo "$manifestJson" > image/manifest.json # docker
        manifestChecksum=$(echo "$manifestJson" | sha256sum | cut -d ' ' -f1)
        manifestSize=$(expr length "$manifestJson"$'\n')
        echo "$manifestJson" > image/blobs/sha256/$manifestChecksum # oci

        # add index to image
        echo '{"mediaType":"application/vnd.oci.image.index.v1+json","schemaVersion":2,
          "manifests":[{"mediaType":"application/vnd.oci.image.manifest.v1+json",
          "digest":"sha256:'$manifestChecksum'","size":'$manifestSize',
          "annotations":{"org.opencontainers.image.ref.name":"'"$imageName:$imageTag"'"},
          "platform":{"architecture":"${defaultArch}","os":"linux"}}]}' | jq -c >image/index.json

        # TODO add file: oci-layout

        # FIXME OCI image vs docker load
        # $ ./result/bin/my-container-app-docker-load 
        #  379MiB 0:00:07 [53.3MiB/s] [==================================================>] 100%            
        # open /var/lib/docker/tmp/docker-import-171095956/blobs/json: no such file or directory

        if false; then
        # Store the json under the name image/repositories.
        jshon -n object \
          -n object -s "$layerID" -i "$imageTag" \
          -i "$imageName" > image/repositories
        fi # if false

        # Make the image read-only.
        chmod -R a-w image

        echo debug...
        set -o xtrace
        echo "debug 875: find ."; find .

        cat image/index.json | jq
        manifestSum=$(cat image/index.json | jq -r '.manifests[0].digest | ltrimstr("sha256:")')
        cat image/blobs/sha256/$manifestSum | jq
        configSum=$(cat image/blobs/sha256/$manifestSum | jq -r '.config.digest | ltrimstr("sha256:")')
        cat image/blobs/sha256/$configSum | jq
        # TODO loop all layers
        layer0Sum=$(cat image/blobs/sha256/$manifestSum | jq -r '.layers[0].digest | ltrimstr("sha256:")')
        echo $(tar tf image/blobs/sha256/$layer0Sum | wc -l) files in layer $layer0Sum
        set +o xtrace

        echo "Compressing the image..."
        tar -C image --hard-dereference --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
          --owner=0 --group=0 --xform s:'^./':: -c . ${lib.optionalString compress "| pigz -nT -${toString compressionLevel}"} > $out

        echo "debug: tar tf $out"
        tar tf $out

        echo "Finished."
      '';

    in
    result;

  # Merge the tarballs of images built with buildImage into a single
  # tarball that contains all images. Running `docker load` on the resulting
  # tarball will load the images into the docker daemon.
  mergeImages = images: runCommand "merge-docker-images"
    {
      inherit images;
      nativeBuildInputs = [ pigz jq ];
    } ''
    mkdir image inputs
    # Extract images
    if false; then
    repos=()
    manifests=()
    indexfiles=()
    for item in $images; do
      name=$(basename $item)
      mkdir inputs/$name
      tar -I pigz -xf $item -C inputs/$name
      if [ -f inputs/$name/repositories ]; then
        repos+=(inputs/$name/repositories)
      fi
      if [ -f inputs/$name/manifest.json ]; then
        manifests+=(inputs/$name/manifest.json)
      fi
      if [ -f inputs/$name/index.json ]; then
        indexfiles+=(inputs/$name/index.json)
      fi
    done
    fi # if false

    echo "mergeImages: images = $images" # debug

    indexfiles=()
    for item in $images; do
      name=$(basename $item)
      mkdir inputs/$name
      echo "mergeImages: item = $item" # debug
      tar -I pigz -xf $item -C inputs/$name
      if [ -f inputs/$name/repositories ] || [ -f inputs/$name/manifest.json ]; then
        echo "error: image $item has docker format, expected OCI format"
        exit 1
      fi
      if [ -f inputs/$name/index.json ]; then
        indexfiles+=(inputs/$name/index.json)
      else
        echo "info: image $item has no index.json file"
        # TODO index required?
      fi
    done
    echo "debug: found indexfiles ''${indexfiles[@]}"

    # Copy all layers from input images to output image directory
    #cp -R --no-clobber inputs/*/* image/
    echo "debug: Copy all layers from input images to output image directory"
    cp --verbose -R --no-clobber inputs/*/* image/

    # debug
    echo "#### 906 mergeImages: find inputs"
    find inputs
    echo "#### 908 mergeImages: find image"
    find image
    echo "#### 910 mergeImages"

    # TODO(milahu) merge manifests into new index file

    # TODO(milahu) set default env: USER=nobody
    # A user is required by nix
    # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478

    # Merge repositories objects and manifests
    echo "TODO Merge repositories objects and manifests"
    jq -s add "''${repos[@]}" > repositories
    jq -s add "''${manifests[@]}" > manifest.json
    # Replace output image repositories and manifest with merged versions
    #mv repositories image/repositories
    mv manifest.json image/manifest.json
    # Create tarball and gzip
    tar -C image --hard-dereference --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
      --owner=0 --group=0 --xform s:'^./':: -c . | pigz -nT > $out
  '';


  # Provide a /etc/passwd and /etc/group that contain root and nobody.
  # Useful when packaging binaries that insist on using nss to look up
  # username/groups (like nginx).
  # /bin/sh is fine to not exist, and provided by another shim.
  fakeNss = symlinkJoin {
    name = "fake-nss";
    paths = [
      (writeTextDir "etc/passwd" ''
        root:x:0:0:root user:/var/empty:/bin/sh
        nobody:x:65534:65534:nobody:/var/empty:/bin/sh
      '')
      (writeTextDir "etc/group" ''
        root:x:0:
        nobody:x:65534:
      '')
      (writeTextDir "etc/nsswitch.conf" ''
        hosts: files dns
      '')
      (runCommand "var-empty" { } ''
        mkdir -p $out/var/empty
      '')
    ];
  };

  # This provides a /usr/bin/env, for shell scripts using the
  # "#!/usr/bin/env executable" shebang.
  usrBinEnv = runCommand "usr-bin-env" { } ''
    mkdir -p $out/usr/bin
    ln -s ${pkgs.coreutils}/bin/env $out/usr/bin
  '';

  # This provides /bin/sh, pointing to bashInteractive.
  binSh = runCommand "bin-sh" { } ''
    mkdir -p $out/bin
    ln -s ${bashInteractive}/bin/bash $out/bin/sh
  '';

  # Build an image and populate its nix database with the provided
  # contents. The main purpose is to be able to use nix commands in
  # the container.
  # Be careful since this doesn't work well with multilayer.
  buildImageWithNixDb = args@{ contents ? null, extraCommands ? "", ... }: (
    buildImage (args // {
      extraCommands = (mkDbExtraCommand contents) + extraCommands;
    })
  );

  buildLayeredImageWithNixDb = args@{ contents ? null, extraCommands ? "", ... }: (
    buildLayeredImage (args // {
      extraCommands = (mkDbExtraCommand contents) + extraCommands;
    })
  );

  streamLayeredImage =
    {
      # Image Name
      name
    , # Image tag, the Nix's output hash will be used if null
      tag ? null
    , # Parent image, to append to.
      fromImage ? null
    , # Files to put on the image (a nix store path or list of paths).
      contents ? [ ]
    , # Docker config; e.g. what command to run on the container.
      config ? { }
    , # Time of creation of the image. Passing "now" will make the
      # created date be the time of building.
      created ? "1970-01-01T00:00:01Z"
    , # Optional bash script to run on the files prior to fixturizing the layer.
      extraCommands ? ""
    , # Optional bash script to run inside fakeroot environment.
      # Could be used for changing ownership of files in customisation layer.
      fakeRootCommands ? ""
    , # We pick 100 to ensure there is plenty of room for extension. I
      # believe the actual maximum is 128.
      maxLayers ? 100
    , # Whether to include store paths in the image. You generally want to leave
      # this on, but tooling may disable this to insert the store paths more
      # efficiently via other means, such as bind mounting the host store.
      includeStorePaths ? true
    ,
    }:
      assert
      (lib.assertMsg (maxLayers > 1)
        "the maxLayers argument of dockerTools.buildLayeredImage function must be greather than 1 (current value: ${toString maxLayers})");
      let
        baseName = baseNameOf name;

        streamScript = writers.writePython3 "stream" { } ./stream_layered_image.py;
        baseJson = writeText "${baseName}-base.json" (builtins.toJSON {
          inherit config;
          architecture = defaultArch;
          os = "linux";
        });

        contentsList = if builtins.isList contents then contents else [ contents ];

        # We store the customisation layer as a tarball, to make sure that
        # things like permissions set on 'extraCommands' are not overriden
        # by Nix. Then we precompute the sha256 for performance.
        customisationLayer = symlinkJoin {
          name = "${baseName}-customisation-layer";
          paths = contentsList;
          inherit extraCommands fakeRootCommands;
          nativeBuildInputs = [ fakeroot ];
          postBuild = ''
            mv $out old_out
            (cd old_out; eval "$extraCommands" )

            mkdir $out

            fakeroot bash -c '
              source $stdenv/setup
              cd old_out
              eval "$fakeRootCommands"
              tar \
                --sort name \
                --numeric-owner --mtime "@$SOURCE_DATE_EPOCH" \
                --hard-dereference \
                -cf $out/layer.tar .
            '

            # TODO remove?
            sha256sum $out/layer.tar \
              | cut -f 1 -d ' ' \
              > $out/checksum
          '';
        };

        closureRoots = lib.optionals includeStorePaths /* normally true */ (
          [ baseJson ] ++ contentsList
        );
        overallClosure = writeText "closure" (lib.concatStringsSep " " closureRoots);

        # These derivations are only created as implementation details of docker-tools,
        # so they'll be excluded from the created images.
        unnecessaryDrvs = [ baseJson overallClosure ];

        conf = runCommand "${baseName}-conf.json"
          {
            inherit fromImage maxLayers created;
            imageName = lib.toLower name;
            passthru.imageTag =
              if tag != null
              then tag
              else
                lib.head (lib.strings.splitString "-" (baseNameOf conf.outPath));
            paths = buildPackages.referencesByPopularity overallClosure;
            nativeBuildInputs = [ jq ];
          } ''
          ${if (tag == null) then ''
            outName="$(basename "$out")"
            outHash=$(echo "$outName" | cut -d - -f 1)

            imageTag=$outHash
          '' else ''
            imageTag="${tag}"
          ''}

          # convert "created" to iso format
          if [[ "$created" != "now" ]]; then
              created="$(date -Iseconds -d "$created")"
          fi

          paths() {
            cat $paths ${lib.concatMapStringsSep " "
                           (path: "| (grep -v ${path} || true)")
                           unnecessaryDrvs}
          }

          # Compute the number of layers that are already used by a potential
          # 'fromImage' as well as the customization layer. Ensure that there is
          # still at least one layer available to store the image contents.
          usedLayers=0

          # subtract number of base image layers
          if [[ -n "$fromImage" ]]; then
            (( usedLayers += $(tar -xOf "$fromImage" manifest.json | jq '.[0].Layers | length') ))
          fi

          # one layer will be taken up by the customisation layer
          (( usedLayers += 1 ))

          if ! (( $usedLayers < $maxLayers )); then
            echo >&2 "Error: usedLayers $usedLayers layers to store 'fromImage' and" \
                      "'extraCommands', but only maxLayers=$maxLayers were" \
                      "allowed. At least 1 layer is required to store contents."
            exit 1
          fi
          availableLayers=$(( maxLayers - usedLayers ))

          # Create $maxLayers worth of Docker Layers, one layer per store path
          # unless there are more paths than $maxLayers. In that case, create
          # $maxLayers-1 for the most popular layers, and smush the remainaing
          # store paths in to one final layer.
          #
          # The following code is fiddly w.r.t. ensuring every layer is
          # created, and that no paths are missed. If you change the
          # following lines, double-check that your code behaves properly
          # when the number of layers equals:
          #      maxLayers-1, maxLayers, and maxLayers+1, 0
          store_layers="$(
            paths |
              jq -sR '
                rtrimstr("\n") | split("\n")
                  | (.[:$maxLayers-1] | map([.])) + [ .[$maxLayers-1:] ]
                  | map(select(length > 0))
              ' \
                --argjson maxLayers "$availableLayers"
          )"

          cat ${baseJson} | jq '
            . + {
              "store_dir": $store_dir,
              "from_image": $from_image,
              "store_layers": $store_layers,
              "customisation_layer", $customisation_layer,
              "repo_tag": $repo_tag,
              "created": $created
            }
            ' --arg store_dir "${storeDir}" \
              --argjson from_image ${if fromImage == null then "null" else "'\"${fromImage}\"'"} \
              --argjson store_layers "$store_layers" \
              --arg customisation_layer ${customisationLayer} \
              --arg repo_tag "$imageName:$imageTag" \
              --arg created "$created" |
            tee $out
        '';
        result = runCommand "stream-${baseName}"
          {
            inherit (conf) imageName;
            passthru = {
              inherit (conf) imageTag;

              # Distinguish tarballs and exes at the Nix level so functions that
              # take images can know in advance how the image is supposed to be used.
              isExe = true;
            };
            nativeBuildInputs = [ makeWrapper ];
          } ''
          makeWrapper ${streamScript} $out --add-flags ${conf}
        '';
      in
      result;
}
