/* SPARC _add_n -- Add two limb vectors of the same length > 0 and store
 *		   sum in a third limb vector.
 *
 *      Copyright (C) 1995, 1996, 1998,
 *                    2001, 2002 Free Software Foundation, Inc.
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



/*******************
 *  mpi_limb_t
 *  _gcry_mpih_add_n( mpi_ptr_t res_ptr,
 *		   mpi_ptr_t s1_ptr,
 *		   mpi_ptr_t s2_ptr,
 *		   mpi_size_t size)
 */

! INPUT PARAMETERS
#define res_ptr %o0
#define s1_ptr	%o1
#define s2_ptr	%o2
#define size	%o3

#include "sysdep.h"

	.text
	.align	4
	.global C_SYMBOL_NAME(_gcry_mpih_add_n)
C_SYMBOL_NAME(_gcry_mpih_add_n):
	xor	s2_ptr,res_ptr,%g1
	andcc	%g1,4,%g0
	bne	L1			! branch if alignment differs
	nop
! **  V1a  **
L0:	andcc	res_ptr,4,%g0		! res_ptr unaligned? Side effect: cy=0
	be	L_v1			! if no, branch
	nop
/* Add least significant limb separately to align res_ptr and s2_ptr */
	ld	[s1_ptr],%g4
	add	s1_ptr,4,s1_ptr
	ld	[s2_ptr],%g2
	add	s2_ptr,4,s2_ptr
	add	size,-1,size
	addcc	%g4,%g2,%o4
	st	%o4,[res_ptr]
	add	res_ptr,4,res_ptr
L_v1:	addx	%g0,%g0,%o4		! save cy in register
	cmp	size,2			! if size < 2 ...
	bl	Lend2			! ... branch to tail code
	subcc	%g0,%o4,%g0		! restore cy

	ld	[s1_ptr+0],%g4
	addcc	size,-10,size
	ld	[s1_ptr+4],%g1
	ldd	[s2_ptr+0],%g2
	blt	Lfin1
	subcc	%g0,%o4,%g0		! restore cy
/* Add blocks of 8 limbs until less than 8 limbs remain */
Loop1:	addxcc	%g4,%g2,%o4
	ld	[s1_ptr+8],%g4
	addxcc	%g1,%g3,%o5
	ld	[s1_ptr+12],%g1
	ldd	[s2_ptr+8],%g2
	std	%o4,[res_ptr+0]
	addxcc	%g4,%g2,%o4
	ld	[s1_ptr+16],%g4
	addxcc	%g1,%g3,%o5
	ld	[s1_ptr+20],%g1
	ldd	[s2_ptr+16],%g2
	std	%o4,[res_ptr+8]
	addxcc	%g4,%g2,%o4
	ld	[s1_ptr+24],%g4
	addxcc	%g1,%g3,%o5
	ld	[s1_ptr+28],%g1
	ldd	[s2_ptr+24],%g2
	std	%o4,[res_ptr+16]
	addxcc	%g4,%g2,%o4
	ld	[s1_ptr+32],%g4
	addxcc	%g1,%g3,%o5
	ld	[s1_ptr+36],%g1
	ldd	[s2_ptr+32],%g2
	std	%o4,[res_ptr+24]
	addx	%g0,%g0,%o4		! save cy in register
	addcc	size,-8,size
	add	s1_ptr,32,s1_ptr
	add	s2_ptr,32,s2_ptr
	add	res_ptr,32,res_ptr
	bge	Loop1
	subcc	%g0,%o4,%g0		! restore cy

Lfin1:	addcc	size,8-2,size
	blt	Lend1
	subcc	%g0,%o4,%g0		! restore cy
/* Add blocks of 2 limbs until less than 2 limbs remain */
Loope1: addxcc	%g4,%g2,%o4
	ld	[s1_ptr+8],%g4
	addxcc	%g1,%g3,%o5
	ld	[s1_ptr+12],%g1
	ldd	[s2_ptr+8],%g2
	std	%o4,[res_ptr+0]
	addx	%g0,%g0,%o4		! save cy in register
	addcc	size,-2,size
	add	s1_ptr,8,s1_ptr
	add	s2_ptr,8,s2_ptr
	add	res_ptr,8,res_ptr
	bge	Loope1
	subcc	%g0,%o4,%g0		! restore cy
Lend1:	addxcc	%g4,%g2,%o4
	addxcc	%g1,%g3,%o5
	std	%o4,[res_ptr+0]
	addx	%g0,%g0,%o4		! save cy in register

	andcc	size,1,%g0
	be	Lret1
	subcc	%g0,%o4,%g0		! restore cy
/* Add last limb */
	ld	[s1_ptr+8],%g4
	ld	[s2_ptr+8],%g2
	addxcc	%g4,%g2,%o4
	st	%o4,[res_ptr+8]

Lret1:	retl
	addx	%g0,%g0,%o0	! return carry-out from most sign. limb

L1:	xor	s1_ptr,res_ptr,%g1
	andcc	%g1,4,%g0
	bne	L2
	nop
! **  V1b  **
	mov	s2_ptr,%g1
	mov	s1_ptr,s2_ptr
	b	L0
	mov	%g1,s1_ptr

! **  V2  **
/* If we come here, the alignment of s1_ptr and res_ptr as well as the
   alignment of s2_ptr and res_ptr differ.  Since there are only two ways
   things can be aligned (that we care about) we now know that the alignment
   of s1_ptr and s2_ptr are the same.  */

L2:	cmp	size,1
	be	Ljone
	nop
	andcc	s1_ptr,4,%g0		! s1_ptr unaligned? Side effect: cy=0
	be	L_v2			! if no, branch
	nop
/* Add least significant limb separately to align s1_ptr and s2_ptr */
	ld	[s1_ptr],%g4
	add	s1_ptr,4,s1_ptr
	ld	[s2_ptr],%g2
	add	s2_ptr,4,s2_ptr
	add	size,-1,size
	addcc	%g4,%g2,%o4
	st	%o4,[res_ptr]
	add	res_ptr,4,res_ptr

L_v2:	addx	%g0,%g0,%o4		! save cy in register
	addcc	size,-8,size
	blt	Lfin2
	subcc	%g0,%o4,%g0		! restore cy
/* Add blocks of 8 limbs until less than 8 limbs remain */
Loop2:	ldd	[s1_ptr+0],%g2
	ldd	[s2_ptr+0],%o4
	addxcc	%g2,%o4,%g2
	st	%g2,[res_ptr+0]
	addxcc	%g3,%o5,%g3
	st	%g3,[res_ptr+4]
	ldd	[s1_ptr+8],%g2
	ldd	[s2_ptr+8],%o4
	addxcc	%g2,%o4,%g2
	st	%g2,[res_ptr+8]
	addxcc	%g3,%o5,%g3
	st	%g3,[res_ptr+12]
	ldd	[s1_ptr+16],%g2
	ldd	[s2_ptr+16],%o4
	addxcc	%g2,%o4,%g2
	st	%g2,[res_ptr+16]
	addxcc	%g3,%o5,%g3
	st	%g3,[res_ptr+20]
	ldd	[s1_ptr+24],%g2
	ldd	[s2_ptr+24],%o4
	addxcc	%g2,%o4,%g2
	st	%g2,[res_ptr+24]
	addxcc	%g3,%o5,%g3
	st	%g3,[res_ptr+28]
	addx	%g0,%g0,%o4		! save cy in register
	addcc	size,-8,size
	add	s1_ptr,32,s1_ptr
	add	s2_ptr,32,s2_ptr
	add	res_ptr,32,res_ptr
	bge	Loop2
	subcc	%g0,%o4,%g0		! restore cy

Lfin2:	addcc	size,8-2,size
	blt	Lend2
	subcc	%g0,%o4,%g0		! restore cy
Loope2: ldd	[s1_ptr+0],%g2
	ldd	[s2_ptr+0],%o4
	addxcc	%g2,%o4,%g2
	st	%g2,[res_ptr+0]
	addxcc	%g3,%o5,%g3
	st	%g3,[res_ptr+4]
	addx	%g0,%g0,%o4		! save cy in register
	addcc	size,-2,size
	add	s1_ptr,8,s1_ptr
	add	s2_ptr,8,s2_ptr
	add	res_ptr,8,res_ptr
	bge	Loope2
	subcc	%g0,%o4,%g0		! restore cy
Lend2:	andcc	size,1,%g0
	be	Lret2
	subcc	%g0,%o4,%g0		! restore cy
/* Add last limb */
Ljone:	ld	[s1_ptr],%g4
	ld	[s2_ptr],%g2
	addxcc	%g4,%g2,%o4
	st	%o4,[res_ptr]

Lret2:	retl
	addx	%g0,%g0,%o0	! return carry-out from most sign. limb



