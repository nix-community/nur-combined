{bootstrapseeds, mescctoolsseed, m2planet, mescctools, full-script, mkdirm1}:
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
./catm hold ${m2planet}/test/common_x86/functions/file.c \
	${m2planet}/test/common_x86/functions/malloc.c \
	${m2planet}/functions/calloc.c \
	${m2planet}/test/common_x86/functions/exit.c \
	${m2planet}/functions/match.c \
	${m2planet}/functions/in_set.c \
	${m2planet}/functions/numerate_number.c \
	${m2planet}/functions/file_print.c \
	${m2planet}/functions/number_pack.c \
	${m2planet}/functions/string.c \
	${m2planet}/functions/require.c \
	${m2planet}/functions/fixup.c \
	${m2planet}/cc.h \
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
	-f ${m2planet}/test/common_x86/functions/exit.c \
	-f ${m2planet}/test/common_x86/functions/file.c \
	-f ${m2planet}/functions/file_print.c \
	-f ${mescctools}/functions/numerate_number.c \
	-f ${m2planet}/test/common_x86/functions/malloc.c \
	-f ${m2planet}/functions/calloc.c \
	-f ${m2planet}/functions/match.c \
	-f ${mescctools}/blood-elf.c \
	-f ${m2planet}/functions/require.c \
	-f ${m2planet}/functions/in_set.c \
	--bootstrap-mode \
	-o blood-elf.M1

./catm hold ${mescctoolsseed}/x86/x86_defs.M1 ${mescctoolsseed}/x86/libc-core.M1 blood-elf.M1
./M0 hold temp1
./catm hold ${mescctoolsseed}/x86/ELF-i386.hex2 temp1
./hex2-0 hold blood-elf-0
# This is the last stage where the binaries will not have debug info
# and the last piece built that isn't part of the output binaries

###################################
# Phase-7 Build M1 from C sources #
###################################
./M2 --architecture x86 \
	-f ${m2planet}/test/common_x86/functions/exit.c \
	-f ${m2planet}/test/common_x86/functions/file.c \
	-f ${m2planet}/functions/file_print.c \
	-f ${m2planet}/test/common_x86/functions/malloc.c \
	-f ${m2planet}/functions/calloc.c \
	-f ${m2planet}/functions/match.c \
	-f ${m2planet}/functions/in_set.c \
	-f ${m2planet}/functions/numerate_number.c \
	-f ${m2planet}/functions/string.c \
	-f ${m2planet}/functions/require.c \
	-f ${mescctools}/M1-macro.c \
	--bootstrap-mode \
	--debug \
	-o M1-macro.M1

./blood-elf-0 -f M1-macro.M1 -o M1-macro-footer.M1
./catm hold ${mescctoolsseed}/x86/x86_defs.M1 ${mescctoolsseed}/x86/libc-core.M1 M1-macro.M1 M1-macro-footer.M1
./M0 hold temp1
./catm hold ${mescctoolsseed}/x86/ELF-i386-debug.hex2 temp1
./hex2-0 hold M1

# Nix specific: save the last step for later
./catm hold_over_M1.hex2 hold

#####################################
# Phase-8 Build hex2 from C sources #
#####################################
./M2 --architecture x86 \
	-f ${m2planet}/test/common_x86/functions/exit.c \
	-f ${m2planet}/test/common_x86/functions/file.c \
	-f ${m2planet}/functions/file_print.c \
	-f ${m2planet}/test/common_x86/functions/malloc.c \
	-f ${m2planet}/functions/calloc.c \
	-f ${m2planet}/functions/match.c \
	-f ${m2planet}/functions/require.c \
	-f ${m2planet}/functions/in_set.c \
	-f ${m2planet}/functions/numerate_number.c \
	-f ${m2planet}/test/common_x86/functions/stat.c \
	-f ${mescctools}/hex2_linker.c \
	--bootstrap-mode \
	--debug \
	-o hex2_linker.M1

./blood-elf-0 -f hex2_linker.M1 -o hex2_linker-footer.M1
./M1 -f ${mescctoolsseed}/x86/x86_defs.M1 \
	-f ${mescctoolsseed}/x86/libc-core.M1 \
	-f hex2_linker.M1 \
	-f hex2_linker-footer.M1 \
	--LittleEndian \
	--architecture x86 \
	-o temp1
./catm hold ${mescctoolsseed}/x86/ELF-i386-debug.hex2 temp1
./hex2-0 hold hex2
# This is the last stage where we will be using the handwritten hex2 and instead
# be using the far more powerful, cross-platform version with a bunch more goodies

# Nix specific: save the last step for later
./catm hold_over_hex2.hex2 hold

# This is the last stage where catm will need to be used and the last stage where
# M0 is used, as we will being using it's much more powerful and cross-platform
# version with a bunch of extra goodies.

#####################################
# Phase-9 Build kaem from C sources#
#####################################
./M2 --architecture x86 \
	-f ${m2planet}/test/common_x86/functions/exit.c \
	-f ${m2planet}/test/common_x86/functions/file.c \
	-f ${m2planet}/functions/file_print.c \
	-f ${m2planet}/test/common_x86/functions/malloc.c \
	-f ${m2planet}/functions/calloc.c \
	-f ${m2planet}/functions/match.c \
	-f ${m2planet}/functions/in_set.c \
	-f ${m2planet}/functions/require.c \
	-f ${mescctools}/functions/string.c \
	-f ${m2planet}/functions/numerate_number.c \
	-f ${m2planet}/test/common_x86/functions/fork.c \
	-f ${m2planet}/test/common_x86/functions/execve.c \
	-f ${m2planet}/test/common_x86/functions/chdir.c \
	-f ${m2planet}/test/common_x86/functions/getcwd.c \
	-f ${mescctools}/Kaem/kaem.h \
	-f ${mescctools}/Kaem/variable.c \
	-f ${mescctools}/Kaem/kaem_globals.c \
	-f ${mescctools}/Kaem/kaem.c \
	--bootstrap-mode \
	--debug \
	-o kaem.M1

./blood-elf-0 -f kaem.M1 -o kaem-footer.M1

./M1 -f ${mescctoolsseed}/x86/x86_defs.M1 \
	-f ${mescctoolsseed}/x86/libc-core.M1 \
	-f kaem.M1 \
	-f kaem-footer.M1 \
	--LittleEndian \
	--architecture x86 \
	-o hold

./hex2 -f ${mescctoolsseed}/x86/ELF-i386-debug.hex2 \
	-f hold \
	--LittleEndian \
	--architecture x86 \
	--BaseAddress 0x8048000 \
	-o kaem \
	--exec_enable

# Nix specific: save the last step for later
./catm hold_over_kaem.hex2 ${mescctoolsseed}/x86/ELF-i386-debug.hex2 hold

###################################################
# Phase-7b mkdir for Nix only!					  #
# Nix needs a way to create $out				  #
# So we build an absolutley minimal mkdir with M1 #
###################################################

./M1 -f ${mescctoolsseed}/x86/x86_defs.M1 -f ${mkdirm1} --LittleEndian --architecture x86 -o temp1
./hex2 -f ${mescctoolsseed}/x86/ELF-i386.hex2 -f temp1 --LittleEndian --architecture x86 --BaseAddress 0x8048000 -o mkdirm --exec_enable

./catm hold_over_mkdir.M1 ${mescctoolsseed}/x86/ELF-i386.hex2 temp1

##################################################
# Phase-9b upgrade kaem for Nix $out			 #
# The full Kaem can read where $out is			 #
# So we perform stages 9-12 in the next script	 #
##################################################

./kaem --verbose --strict -f ${full-script}

''