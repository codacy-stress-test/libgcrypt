/* IBM POWER lshift
 *
 *      Copyright (C) 1992, 1994, 1999, 2002 Free Software Foundation, Inc.
 *
 * This file is part of Libgcrypt.
 *
 * Libgcrypt is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * Libgcrypt is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, see <https://www.gnu.org/licenses/>.
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "sysdep.h"
#include "asm-syntax.h"

/*
# INPUT PARAMETERS
# res_ptr	r3
# s_ptr 	r4
# size		r5
# cnt		r6
 */

	.toc
	.extern _gcry_mpih_lshift[DS]
	.extern ._gcry_mpih_lshift
.csect [PR]
	.align 2
	.globl _gcry_mpih_lshift
	.globl ._gcry_mpih_lshift
	.csect _gcry_mpih_lshift[DS]
_gcry_mpih_lshift:
	.long ._gcry_mpih_lshift, TOC[tc0], 0
	.csect [PR]
._gcry_mpih_lshift:
	sli	0,5,2
	cax	9,3,0
	cax	4,4,0
	sfi	8,6,32
	mtctr	5		# put limb count in CTR loop register
	lu	0,-4(4) 	# read most significant limb
	sre	3,0,8		# compute carry out limb, and init MQ register
	bdz	Lend2		# if just one limb, skip loop
	lu	0,-4(4) 	# read 2:nd most significant limb
	sreq	7,0,8		# compute most significant limb of result
	bdz	Lend		# if just two limb, skip loop
Loop:	lu	0,-4(4) 	# load next lower limb
	stu	7,-4(9) 	# store previous result during read latency
	sreq	7,0,8		# compute result limb
	bdn	Loop		# loop back until CTR is zero
Lend:	stu	7,-4(9) 	# store 2:nd least significant limb
Lend2:	sle	7,0,6		# compute least significant limb
	st	7,-4(9) 	# store it
	br

