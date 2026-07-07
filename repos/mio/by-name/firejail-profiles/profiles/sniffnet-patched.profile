# Firejail profile for sniffnet-patched
# Description: Sniffnet with no-animations patch - network traffic monitor
# Persistent local customizations
include sniffnet-patched.local
# Persistent global definitions
# added by included profile
#include globals.local

# Redirect to upstream sniffnet profile
include sniffnet.profile
