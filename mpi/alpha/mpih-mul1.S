/* Alpha 21064 mpih-mul1.S -- Multiply a limb vector with a limb and store
 *			      the result in a second limb vector.
 *
 *      Copyright (C) 1992, 1994, 1995, 1998, 
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
 * mpi_limb_t
 * _gcry_mpih_mul_1( mpi_ptr_t res_ptr,	(r16)
 *		  mpi_ptr_t s1_ptr,	(r17)
 *		  mpi_size_t s1_size,	(r18)
 *		  mpi_limb_t s2_limb)	(r19)
 *
 * This code runs at 42 cycles/limb on the EV4 and 18 cycles/limb on the EV5.
 *
 * To improve performance for long multiplications, we would use
 * 'fetch' for S1 and 'fetch_m' for RES.  It's not obvious how to use
 * these instructions without slowing down the general code: 1. We can
 * only have two prefetches in operation at any time in the Alpha
 * architecture.  2. There will seldom be any special alignment
 * between RES_PTR and S1_PTR.	Maybe we can simply divide the current
 * loop into an inner and outer loop, having the inner loop handle
 * exactly one prefetch block?
 */

	.set	noreorder
	.set	noat
.text
	.align	3
	.globl	_gcry_mpih_mul_1
	.ent	_gcry_mpih_mul_1 2
_gcry_mpih_mul_1:
	.frame	$30,0,$26

	ldq	$2,0($17)	# $2 = s1_limb
	subq	$18,1,$18	# size--
	mulq	$2,$19,$3	# $3 = prod_low
	bic	$31,$31,$4	# clear cy_limb
	umulh	$2,$19,$0	# $0 = prod_high
	beq	$18,Lend1	# jump if size was == 1
	ldq	$2,8($17)	# $2 = s1_limb
	subq	$18,1,$18	# size--
	stq	$3,0($16)
	beq	$18,Lend2	# jump if size was == 2

	.align	3
Loop:	mulq	$2,$19,$3	# $3 = prod_low
	addq	$4,$0,$0	# cy_limb = cy_limb + 'cy'
	subq	$18,1,$18	# size--
	umulh	$2,$19,$4	# $4 = cy_limb
	ldq	$2,16($17)	# $2 = s1_limb
	addq	$17,8,$17	# s1_ptr++
	addq	$3,$0,$3	# $3 = cy_limb + prod_low
	stq	$3,8($16)
	cmpult	$3,$0,$0	# $0 = carry from (cy_limb + prod_low)
	addq	$16,8,$16	# res_ptr++
	bne	$18,Loop

Lend2:	mulq	$2,$19,$3	# $3 = prod_low
	addq	$4,$0,$0	# cy_limb = cy_limb + 'cy'
	umulh	$2,$19,$4	# $4 = cy_limb
	addq	$3,$0,$3	# $3 = cy_limb + prod_low
	cmpult	$3,$0,$0	# $0 = carry from (cy_limb + prod_low)
	stq	$3,8($16)
	addq	$4,$0,$0	# cy_limb = prod_high + cy
	ret	$31,($26),1
Lend1:	stq	$3,0($16)
	ret	$31,($26),1

	.end	_gcry_mpih_mul_1


