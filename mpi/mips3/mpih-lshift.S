/* mips3    lshift
 *
 *      Copyright (C) 1995, 1998, 2000,
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
 * _gcry_mpih_lshift( mpi_ptr_t wp,	($4)
 *		   mpi_ptr_t up,	($5)
 *		   mpi_size_t usize,	($6)
 *		   unsigned cnt)	($7)
 */

	.text
	.align	2
	.globl	_gcry_mpih_lshift
	.ent	_gcry_mpih_lshift
_gcry_mpih_lshift:
	.set	noreorder
	.set	nomacro

	dsll	$2,$6,3
	daddu	$5,$5,$2	# make r5 point at end of src
	ld	$10,-8($5)	# load first limb
	dsubu	$13,$0,$7
	daddu	$4,$4,$2	# make r4 point at end of res
	daddiu	$6,$6,-1
	and	$9,$6,4-1	# number of limbs in first loop
	beq	$9,$0,.L0	# if multiple of 4 limbs, skip first loop
	 dsrl	$2,$10,$13	# compute function result

	dsubu	$6,$6,$9

.Loop0: ld	$3,-16($5)
	daddiu	$4,$4,-8
	daddiu	$5,$5,-8
	daddiu	$9,$9,-1
	dsll	$11,$10,$7
	dsrl	$12,$3,$13
	move	$10,$3
	or	$8,$11,$12
	bne	$9,$0,.Loop0
	 sd	$8,0($4)

.L0:	beq	$6,$0,.Lend
	 nop

.Loop:	ld	$3,-16($5)
	daddiu	$4,$4,-32
	daddiu	$6,$6,-4
	dsll	$11,$10,$7
	dsrl	$12,$3,$13

	ld	$10,-24($5)
	dsll	$14,$3,$7
	or	$8,$11,$12
	sd	$8,24($4)
	dsrl	$9,$10,$13

	ld	$3,-32($5)
	dsll	$11,$10,$7
	or	$8,$14,$9
	sd	$8,16($4)
	dsrl	$12,$3,$13

	ld	$10,-40($5)
	dsll	$14,$3,$7
	or	$8,$11,$12
	sd	$8,8($4)
	dsrl	$9,$10,$13

	daddiu	$5,$5,-32
	or	$8,$14,$9
	bgtz	$6,.Loop
	 sd	$8,0($4)

.Lend:	dsll	$8,$10,$7
	j	$31
	sd	$8,-8($4)
	.end	_gcry_mpih_lshift
