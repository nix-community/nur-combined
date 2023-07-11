# from https://github.com/lukaslaobeyer/nix-fpgapkgs/blob/master/pkgs/vivado/builder.sh
# specific for vivado 2017.2

source $stdenv/setup

#echo "unpacking $src..."
#mkdir extracted
#tar xzf $src -C extracted --strip-components=1

echo "running installer..."

cat <<EOF > install_config.txt
Edition=Vivado HL WebPACK
Destination=$out/opt
Modules=Artix-7:1,Spartan-7:1,Kintex-7:1,Virtex-7:1,Zynq-7000:1,Kintex UltraScale:1,Virtex UltraScale:1,Kintex UltraScale+:1,Virtex UltraScale+:1,Zynq UltraScale+ MPSoC:1,Software Development Kit (SDK):1,System Generator for DSP:1,DocNav:1
InstallOptions=Acquire or Manage a License Key:1,Enable WebTalk for SDK to send usage statistics to Xilinx:0,Install Cable Drivers:1,run-xic:1
CreateProgramGroupShortcuts=1
ProgramGroupFolder=Xilinx Design Tools
CreateShortcutsForAllUsers=1
CreateDesktopShortcuts=1
CreateFileAssociation=0
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
($extracted/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config install_config.txt || true) | while read line
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

# Add vivado and xsdk to bin folder
mkdir $out/bin
ln -s $out/opt/Vivado/2017.4/bin/vivado $out/bin/vivado
ln -s $out/opt/SDK/2017.4/bin/xsdk $out/bin/xsdk
