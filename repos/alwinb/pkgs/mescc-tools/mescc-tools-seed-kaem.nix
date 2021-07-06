{bootstrapseeds, mescctoolsseed, m2planet, m2libc, mescctools, full-script, mkdirm1}:
# This is wrapped inside an expression because the kaem seed can not read the environment
''
#! /usr/bin/env bash
# Mes --- Maxwell Equations of Software
# Copyright © 2021 Alwin Berger
# Copyright © 2017,2019 Jan Nieuwenhuizen <janneke@gnu.org>
# Copyright © 2017,2019 Jeremiah Orians
#
# This file is part of Mes.
#
# Mes is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at
# your option) any later version.
#
# Mes is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mes.  If not, see <http://www.gnu.org/licenses/>.



# Can also be run by kaem or any other shell of your personal choice
# To run in kaem simply: kaem --verbose --strict
# Warning all binaries prior to the use of blood-elf will not be readable by
# Objdump, you may need to use ndism or gdb to view the assembly in the binary.


#################################
# Phase-1 Build hex1 from hex0  #
#################################
${bootstrapseeds}/POSIX/x86/hex0-seed ${mescctoolsseed}/x86/hex1_x86.hex0 hex1
# hex1 adds support for single character labels and is available in various froms
# in mescc-tools/x86_bootstrap to allow you various ways to verify correctness

#################################
# Phase-1b Build catm from hex0 #
#################################
${bootstrapseeds}/POSIX/x86/hex0-seed ${mescctoolsseed}/x86/catm_x86.hex0 catm
# catm removes the need for cat or shell support for redirection by providing
# equivalent functionality via catm output_file input1 input2 ... inputN

#################################
# Phase-2 Build hex2 from hex1  #
#################################
./hex1 ${mescctoolsseed}/x86/hex2_x86.hex1 hex2-0
# hex2 adds support for long labels and absolute addresses thus allowing it
# to function as an effective linker for later stages of the bootstrap
# This is a minimal version which will be used to bootstrap a much more advanced
# version in a later stage.

###############################
# Phase-3 Build M0 from hex2  #
###############################
./catm hold ${mescctoolsseed}/x86/ELF-i386.hex2 ${mescctoolsseed}/x86/M0_x86.hex2
./hex2-0 hold M0
# M0 is the architecture specific version of M1 and is by design single
# architecture only and will be replaced by the C code version of M1

###################################
# Phase-4 Build cc_x86 from M0    #
###################################
./M0 ${mescctoolsseed}/x86/cc_x86.M1 temp1
./catm hold ${mescctoolsseed}/x86/ELF-i386.hex2 temp1
./hex2-0 hold cc_x86


# #########################################
# # Phase-5 Build M2-Planet from cc_x86   #
# #########################################
./catm hold \
	${m2libc}/x86/Linux/bootstrap.c \
	${m2planet}/cc.h \
	${m2libc}/bootstrappable.c \
	${m2planet}/cc_globals.c \
	${m2planet}/cc_reader.c \
	${m2planet}/cc_strings.c \
	${m2planet}/cc_types.c \
	${m2planet}/cc_core.c \
	${m2planet}/cc_macro.c \
	${m2planet}/cc.c
./cc_x86 hold M2.M1
./catm hold ${mescctoolsseed}/x86/x86_defs.M1 ${mescctoolsseed}/x86/libc-core.M1 M2.M1
./M0 hold temp1
./catm hold ${mescctoolsseed}/x86/ELF-i386.hex2 temp1
./hex2-0 hold M2

#############################################
# Phase-6 Build blood-elf-0 from C sources  #
#############################################
./M2 --architecture x86 \
        -f ${m2libc}/x86/Linux/bootstrap.c \
        -f ${m2libc}/bootstrappable.c \
	-f ${mescctools}/blood-elf.c \
	--bootstrap-mode \
	-o blood-elf.M1

./catm hold ${m2libc}/x86/x86_defs.M1 ${m2libc}/x86/libc-core.M1 blood-elf.M1
./M0 hold temp1
./catm hold ${mescctoolsseed}/x86/ELF-i386.hex2 temp1
./hex2-0 hold blood-elf-0
# This is the last stage where the binaries will not have debug info
# and the last piece built that isn't part of the output binaries

###################################
# Phase-7 Build M1-0 from C sources #
###################################
./M2 --architecture x86 \
        -f ${m2libc}/x86/Linux/bootstrap.c \
        -f ${m2libc}/bootstrappable.c \
	-f ${mescctools}/M1-macro.c \
	--bootstrap-mode \
	--debug \
	-o M1-macro.M1

./blood-elf-0 -f M1-macro.M1 -o M1-macro-footer.M1
./catm hold ${m2libc}/x86/x86_defs.M1 ${m2libc}/x86/libc-core.M1 M1-macro.M1 M1-macro-footer.M1
./M0 hold temp1
./catm hold ${m2libc}/x86/ELF-x86-debug.hex2 temp1
./hex2-0 hold M1-0

#####################################
# Phase-8 Build hex2 from C sources #
#####################################
./M2 --architecture x86 \
        -f ${m2libc}/sys/types.h \
	-f ${m2libc}/x86/Linux/sys/stat.h \
	-f ${m2libc}/stddef.h \
	-f ${m2libc}/x86/Linux/unistd.h \
	-f ${m2libc}/stdlib.c \
	-f ${m2libc}/x86/Linux/fcntl.h \
	-f ${m2libc}/stdio.c \
	-f ${m2libc}/bootstrappable.c \
	-f ${mescctools}/hex2_linker.c \
	--debug \
	-o hex2_linker.M1

./blood-elf-0 -f hex2_linker.M1 -o hex2_linker-footer.M1

./M1-0 --architecture x86 \
	--little-endian \
        -f ${m2libc}/x86/x86_defs.M1 \
	-f ${m2libc}/x86/libc-core.M1 \
	-f hex2_linker.M1 \
	-f hex2_linker-footer.M1 \
	-o temp1

./catm hold ${m2libc}/x86/ELF-x86-debug.hex2 temp1

./hex2-0 hold hex2-1

# This is the last stage where we will be using the handwritten hex2 and instead
# be using the far more powerful, cross-platform version with a bunch more goodies

###################################
# Phase-9 Build M1 from C sources #
###################################
./M2 --architecture x86 \
	-f ${m2libc}/sys/types.h \
	-f ${m2libc}/stddef.h \
	-f ${m2libc}/string.c \
	-f ${m2libc}/x86/Linux/unistd.h \
	-f ${m2libc}/stdlib.c \
	-f ${m2libc}/x86/Linux/fcntl.h \
	-f ${m2libc}/stdio.c \
	-f ${m2libc}/bootstrappable.c \
	-f ${mescctools}/M1-macro.c \
	--debug \
	-o M1-macro.M1

./blood-elf-0 -f M1-macro.M1 -o M1-macro-footer.M1

./M1-0 --architecture x86 \
	--little-endian \
	-f ${m2libc}/x86/x86_defs.M1 \
	-f ${m2libc}/x86/libc-full.M1 \
	-f M1-macro.M1 \
	-f M1-macro-footer.M1 \
	-o temp1

./hex2-1 --architecture x86 \
	--little-endian \
	--base-address 0x8048000 \
	-f ${m2libc}/x86/ELF-x86-debug.hex2 \
	-f temp1 \
	-o M1

# Nix specific: save the last step for later
./catm hold_over_M1.hex2 temp1

######################################
# Phase-10 Build hex2 from C sources #
######################################
./M2 --architecture x86 \
	-f ${m2libc}/sys/types.h \
	-f ${m2libc}/x86/Linux/sys/stat.h \
	-f ${m2libc}/stddef.h \
	-f ${m2libc}/x86/Linux/unistd.h \
	-f ${m2libc}/stdlib.c \
	-f ${m2libc}/x86/Linux/fcntl.h \
	-f ${m2libc}/stdio.c \
	-f ${m2libc}/bootstrappable.c \
	-f ${mescctools}/hex2_linker.c \
	--debug \
	-o hex2_linker.M1

./blood-elf-0 -f hex2_linker.M1 -o hex2_linker-footer.M1

./M1 --architecture x86 \
	--little-endian \
	-f ${m2libc}/x86/x86_defs.M1 \
	-f ${m2libc}/x86/libc-full.M1 \
	-f hex2_linker.M1 \
	-f hex2_linker-footer.M1 \
	-o hold

./hex2-1 --architecture x86 \
	--little-endian \
	--base-address 0x8048000 \
	-f ${m2libc}/x86/ELF-x86-debug.hex2 \
	-f hold \
	-o hex2

# Nix specific: save the last step for later
./catm hold_over_hex2.hex2 hold

#####################################
# Phase-11 Build kaem from C sources#
#####################################
./M2 --architecture x86 \
	-f ${m2libc}/sys/types.h \
	-f ${m2libc}/stddef.h \
	-f ${m2libc}/string.c \
	-f ${m2libc}/x86/Linux/unistd.h \
	-f ${m2libc}/stdlib.c \
	-f ${m2libc}/x86/Linux/fcntl.h \
	-f ${m2libc}/stdio.c \
	-f ${m2libc}/bootstrappable.c \
	-f ${mescctools}/Kaem/kaem.h \
	-f ${mescctools}/Kaem/variable.c \
	-f ${mescctools}/Kaem/kaem_globals.c \
	-f ${mescctools}/Kaem/kaem.c \
	--debug \
	-o kaem.M1

./blood-elf-0 -f kaem.M1 -o kaem-footer.M1

./M1 --architecture x86 \
	--little-endian \
	-f ${m2libc}/x86/x86_defs.M1 \
	-f ${m2libc}/x86/libc-full.M1 \
	-f kaem.M1 \
	-f kaem-footer.M1 \
	-o hold

./hex2 --architecture x86 \
	--little-endian \
	-f ${m2libc}/x86/ELF-x86-debug.hex2 \
	-f hold \
	--base-address 0x8048000 \
	-o kaem

# Nix specific: save the last step for later
./catm hold_over_kaem.hex2 ${m2libc}/x86/ELF-x86-debug.hex2 hold

###################################################
# Phase-7b mkdir for Nix only!					  #
# Nix needs a way to create $out				  #
# So we build an absolutley minimal mkdir with M1 #
###################################################

./M1 -f ${m2libc}/x86/x86_defs.M1 \
  -f ${mkdirm1} \
  --little-endian \
  --architecture x86 \
  -o temp1

./hex2 -f ${m2libc}/x86/ELF-x86.hex2 \
  -f temp1 \
  --little-endian \
  --architecture x86 \
  --BaseAddress 0x8048000 \
  -o mkdirm

./catm hold_over_mkdir.M1 ${mescctoolsseed}/x86/ELF-i386.hex2 temp1

##################################################
# Phase-11b upgrade kaem for Nix $out			 #
# The full Kaem can read where $out is			 #
# So we perform stages 11-14 in the next script	 #
##################################################

./kaem --verbose --strict --file ${full-script}

''
