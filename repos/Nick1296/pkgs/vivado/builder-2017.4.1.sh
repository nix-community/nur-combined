# from https://github.com/lukaslaobeyer/nix-fpgapkgs/blob/master/pkgs/vivado/builder.sh
# specific for vivado 2017.2

source $stdenv/setup

#echo "unpacking $src..."
#mkdir extracted
#tar xzf $src -C extracted --strip-components=1

echo "running installer..."
#option are taken from page 25 of: https://docs.xilinx.com/v/u/2017.4-English/ug973-vivado-release-notes-install-license
cat <<EOF > install_config.txt
#### Vivado HL System Edition Install Configuration ####
Edition=Vivado HL System Edition
# Path where Xilinx software will be installed.
Destination=$out/opt
# Choose the Products/Devices the you would like to install.
Modules=Zynq UltraScale+ MPSoC:1,DocNav:1,Kintex-7:1,Virtex UltraScale+:1,Virtex UltraScale+ HBM ES:0,Zynq-7000:1,Kintex UltraScale+ ES:0,Kintex UltraScale+:1,Model Composer:0,ARM Cortex-A53:1,Spartan-7:1,Zynq UltraScale+ RFSoC ES:0,Engineering Sample Devices:0,Kintex UltraScale:1,System Generator for DSP:1,Virtex UltraScale:1,SDK Core Tools:1,ARM Cortex-A9:1,ARM Cortex R5:1,Virtex-7:1,Virtex UltraScale+ ES:0,Zynq UltraScale+ MPSoC ES:0,MicroBlaze:1,Artix-7:1
# Choose the post install scripts you'd like to run as part of the finalization step. Please note that some of these scripts may require user interaction during runtime.
InstallOptions=Acquire or Manage a License Key:0,Enable WebTalk for SDK to send usage statistics to Xilinx:1,Enable WebTalk for Vivado to send usage statistics to Xilinx (Always enabled for WebPACK license):1
## Shortcuts and File associations ##
# Choose whether Start menu/Application menu shortcuts will be created or not.
CreateProgramGroupShortcuts=1
# Choose the name of the Start menu/Application menu shortcut. This setting will be ignored if you choose NOT to create shortcuts.
ProgramGroupFolder=Xilinx Design Tools
# Choose whether shortcuts will be created for All users or just the Current user. Shortcuts can be created for all users only if you run the installer as administrator.
CreateShortcutsForAllUsers=0
# Choose whether shortcuts will be created on the desktop or not.
CreateDesktopShortcuts=1
# Choose whether file associations will be created or not.
CreateFileAssociation=1
EOF
cat <<EOF > update_config.txt
#### Vivado HL System Edition Install Configuration ####
Edition=Vivado HL System Edition
# Path where Xilinx software will be installed.
Destination=$out/opt
## Shortcuts and File associations ##
# Choose whether Start menu/Application menu shortcuts will be created or not.
CreateProgramGroupShortcuts=1
# Choose the name of the Start menu/Application menu shortcut. This setting will be ignored if you choose NOT to create shortcuts.
ProgramGroupFolder=Xilinx Design Tools
# Choose whether shortcuts will be created for All users or just the Current user. Shortcuts can be created for all users only if you run the installer as administrator.
CreateShortcutsForAllUsers=0
# Choose whether shortcuts will be created on the desktop or not.
CreateDesktopShortcuts=1
# Choose whether file associations will be created or not.
CreateFileAssociation=1
EOF

#patchShebangs extracted

#patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#         extracted/tps/lnx64/jre/bin/java

mkdir -p $out/opt

#sed -i -- 's|/bin/rm|rm|g' extracted/xsetup


export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${libPath}"

# The installer will be killed as soon as it says that post install tasks have failed.
# This is required because it tries to run the unpatched scripts to check if the installation
# has succeeded. However, these scripts will fail because they have not been patched yet,
# and the installer will proceed to delete the installation if not killed.
($source/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config install_config.txt || true) | while read line
do
    [[ "${line}" == *"Execution of Pre/Post Installation Tasks Failed"* ]] && echo "killing installer!" && ((pkill -9 -f "extracted/tps/lnx64/jre/bin/java") || true)
    echo ${line}
done
#Do the same for the update
($update/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config update_config.txt || true) | while read line
do
    [[ "${line}" == *"Execution of Pre/Post Installation Tasks Failed"* ]] && echo "killing installer!" && ((pkill -9 -f "extracted/tps/lnx64/jre/bin/java") || true)
    echo ${line}
done

rm -rf extracted

# Patch installed files
patchShebangs $out/opt/Vivado/2017.4/bin
patchShebangs $out/opt/SDK/2017.4/bin
echo "Shebangs patched"

# Hack around lack of libtinfo in NixOS
ln -s $ncurses/lib/libncursesw.so.6 $out/opt/Vivado/2017.4/lib/lnx64.o/libtinfo.so.5
ln -s $ncurses/lib/libncursesw.so.6 $out/opt/SDK/2017.4/lib/lnx64.o/libtinfo.so.5

# Patch ELFs
for f in $out/opt/Vivado/2017.4/bin/unwrapped/lnx64.o/*
do
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $f || true
done

for f in $out/opt/SDK/2017.4/bin/unwrapped/lnx64.o/*
do
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $f || true
done

patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/SDK/2017.4/eclipse/lnx64.o/eclipse

patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/opt/SDK/2017.4/tps/lnx64/jre/bin/java

echo "ELFs patched"

wrapProgram $out/opt/Vivado/2017.4/bin/vivado --prefix LD_LIBRARY_PATH : "$libPath"
wrapProgram $out/opt/SDK/2017.4/bin/xsdk --prefix LD_LIBRARY_PATH : "$libPath"
wrapProgram $out/opt/SDK/2017.4/eclipse/lnx64.o/eclipse --prefix LD_LIBRARY_PATH : "$libPath"
wrapProgram $out/opt/SDK/2017.4/tps/lnx64/jre/bin/java --prefix LD_LIBRARY_PATH : "$libPath"
# wrapProgram on its own will not work because of the way the Vivado script runs ./launch
# Therefore, we need Even More Patches...
sed -i -- 's|`basename "\$0"`|vivado|g' $out/opt/Vivado/2017.4/bin/.vivado-wrapped
sed -i -- 's|`basename "\$0"`|xsdk|g' $out/opt/SDK/2017.4/bin/.xsdk-wrapped

# fix simulation behavior
chmod +w $out/opt/Vivado/2019.2/data/xsim/xsim.ini
# Add vivado and xsdk to bin folder
mkdir $out/bin
ln -s $out/opt/Vivado/2017.4/bin/vivado $out/bin/vivado
ln -s $out/opt/SDK/2017.4/bin/xsdk $out/bin/xsdk
