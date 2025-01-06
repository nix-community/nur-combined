#!/bin/sh
export INSTALL4J_JAVA_HOME_OVERRIDE='__JAVAHOME__'
mkdir -p $HOME/.tws
VMOPTIONS=$HOME/.tws/tws.vmoptions
if [ ! -e tws.vmoptions ]; then
    cp __OUT__/libexec/tws.vmoptions $HOME/.tws
fi
# The vm options file should always refer to itself.
sed -i -e 's#-DvmOptionsPath=.*#-DvmOptionsPath=$VMOPTIONS#' $VMOPTIONS
export LD_LIBRARY_PATH=__GTK__/lib:__CCLIBS__/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec "__OUT__/libexec/tws"  -J-DjtsConfigDir=$HOME/.tws --J-Dawt.useSystemAAFontSettings=lcd -J-Dswing.aatext=true "$@"
