# This build script is largely based on the following MIT-licensed
# work: https://github.com/lukaslaobeyer/nix-fpgapkgs
#
# A copy of the MIT-license is included in the root of this
# repository, as "LICENSE-MIT"

source $stdenv/setup

echo "Running Xilinx Vivado installer..."

mkdir -p $out/opt

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${libPath}"

cat > install_config.txt <<EOF
#### Vivado HL WebPACK Install Configuration ####
Edition=Vivado HL WebPACK

Product=Vivado

# Path where Xilinx software will be installed.
Destination=$out/opt

# Choose the Products/Devices the you would like to install.
Modules=Virtex UltraScale+ HBM:1,Zynq UltraScale+ MPSoC:1,DocNav:1,Kintex UltraScale:1,Zynq-7000:1,Spartan-7:1,System Generator for DSP:0,Artix-7:1,Virtex UltraScale+:1,Kintex-7:1,Kintex UltraScale+:1,Model Composer:0

# Choose the post install scripts you'd like to run as part of the
# finalization step. Please note that some of these scripts may require
# user interaction during runtime.
InstallOptions=

## Shortcuts and File associations ##
# Choose whether Start menu/Application menu shortcuts will be created or not.
CreateProgramGroupShortcuts=0

# Choose the name of the Start menu/Application menu shortcut. This
setting will be ignored if you choose NOT to create shortcuts.
ProgramGroupFolder=Xilinx Design Tools

# Choose whether shortcuts will be created for All users or just the
# Current user. Shortcuts can be created for all users only if you run
# the installer as administrator.
CreateShortcutsForAllUsers=0

# Choose whether shortcuts will be created on the desktop or not.
CreateDesktopShortcuts=0

# Choose whether file associations will be created or not.
CreateFileAssociation=0

# Choose whether disk usage will be optimized (reduced) after installation
EnableDiskUsageOptimization=1
EOF

# The installer will be killed as soon as it says that post install
# tasks have failed.  This is required because it tries to run the
# unpatched scripts to check if the installation has
# succeeded. However, these scripts will fail because they have not
# been patched yet, and the installer will proceed to delete the
# installation if not killed.
($extracted/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config install_config.txt || true) | while read line
do
    [[ "${line}" == *"Execution of Pre/Post Installation Tasks Failed"* ]] && echo "killing installer!" && ((pkill -9 -f "extracted/tps/lnx64/jre/bin/java") || true)
    echo ${line}
done


# Patch installed files
patchShebangs $out/opt/Vivado/2020.1/bin
echo "Shebangs patched"

# Hack around lack of libtinfo in NixOS
ln -s $ncurses/lib/libncursesw.so.6 $out/opt/Vivado/2020.1/lib/lnx64.o/libtinfo.so.5

# Patch ELFs
for f in $out/opt/Vivado/2020.1/bin/unwrapped/lnx64.o/*
do
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $f || true
done

patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/Vivado/2020.1/lnx64/tools/eclipse/eclipse

patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/Vivado/2020.1/tps/lnx64/jre9.0.4/bin/java

echo "ELFs patched"

wrapProgram $out/opt/Vivado/2020.1/bin/vivado --prefix LD_LIBRARY_PATH : "$libPath"
wrapProgram $out/opt/Vivado/2020.1/lnx64/tools/eclipse/eclipse --prefix LD_LIBRARY_PATH : "$libPath"
wrapProgram $out/opt/Vivado/2020.1/tps/lnx64/jre9.0.4/bin/java --prefix LD_LIBRARY_PATH : "$libPath"

# wrapProgram on its own will not work because of the way the Vivado
# script runs ./launch. Therefore, we need even more patches...
sed -i -- 's|`basename "\$0"`|vivado|g' $out/opt/Vivado/2020.1/bin/.vivado-wrapped
sed -i -- 's|/bin/touch|/usr/bin/env touch|g' $out/opt/Vivado/2020.1/scripts/ISEWrap.sh

# Remove all created references to $extracted, to avoid making it a runtime dependency
#
# If this package is upgraded to a newer Vivado version, this must be verified to be
# effective using nix why-depends <this built derivation> $extracted
sed -i -- "s|$extracted|/nix/store/00000000000000000000000000000000-vivado-2020.1-extracted|g" $out/opt/.xinstall/Vivado_2020.1/data/instRecord.dat
sed -i -- "s|$extracted|/nix/store/00000000000000000000000000000000-vivado-2020.1-extracted|g" $out/opt/.xinstall/Vivado_2020.1/xinstall.log
sed -i -- "s|$extracted|/nix/store/00000000000000000000000000000000-vivado-2020.1-extracted|g" $out/opt/.xinstall/xic/data/instRecord.dat
sed -i -- "s|$extracted|/nix/store/00000000000000000000000000000000-vivado-2020.1-extracted|g" $out/opt/.xinstall/DocNav/data/instRecord.dat

# Add Vivado and xsdk to bin folder
mkdir $out/bin
ln -s $out/opt/Vivado/2020.1/bin/vivado $out/bin/vivado
