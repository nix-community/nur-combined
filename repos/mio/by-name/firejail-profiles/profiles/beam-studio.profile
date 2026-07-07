# Firejail profile for beam-studio
# Description: Laser engraving and cutting design software (Flux Beam Studio)
# Persistent local customizations
include beam-studio.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/FLUX.BeamStudio
noblacklist ${HOME}/.local/share/FLUX.BeamStudio

mkdir ${HOME}/.config/FLUX.BeamStudio
mkdir ${HOME}/.local/share/FLUX.BeamStudio
whitelist ${HOME}/.config/FLUX.BeamStudio
whitelist ${HOME}/.local/share/FLUX.BeamStudio

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
