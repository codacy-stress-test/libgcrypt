/* MIPS3 submul_1 -- Multiply a limb vector with a single limb and
 *		     subtract the product from a second limb vector.
 *
 *      Copyright (C) 1992, 1994, 1995, 1998, 2000
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
 * _gcry_mpih_submul_1( mpi_ptr_t res_ptr,      (r4)
 *		     mpi_ptr_t s1_ptr,	     (r5)
 *		     mpi_size_t s1_size,     (r6)
 *		     mpi_limb_t s2_limb)     (r7)
 */

	.text
	.align	4
	.globl	_gcry_mpih_submul_1
	.ent	_gcry_mpih_submul_1
_gcry_mpih_submul_1:
	.set	noreorder
	.set	nomacro

/* # warm up phase 0 */
	ld	$8,0($5)

/* # warm up phase 1 */
	daddiu	$5,$5,8
	dmultu	$8,$7

	daddiu	$6,$6,-1
	beq	$6,$0,$LC0
	 move	$2,$0		# zero cy2

	daddiu	$6,$6,-1
	beq	$6,$0,$LC1
	ld	$8,0($5)	# load new s1 limb as early as possible

Loop:	ld	$10,0($4)
	mflo	$3
	mfhi	$9
	daddiu	$5,$5,8
	daddu	$3,$3,$2	# add old carry limb to low product limb
	dmultu	$8,$7
	ld	$8,0($5)	# load new s1 limb as early as possible
	daddiu	$6,$6,-1	# decrement loop counter
	sltu	$2,$3,$2	# carry from previous addition -> $2
	dsubu	$3,$10,$3
	sgtu	$10,$3,$10
	daddu	$2,$2,$10
	sd	$3,0($4)
	daddiu	$4,$4,8
	bne	$6,$0,Loop
	 daddu	$2,$9,$2	# add high product limb and carry from addition

/* # cool down phase 1 */
$LC1:	ld	$10,0($4)
	mflo	$3
	mfhi	$9
	daddu	$3,$3,$2
	sltu	$2,$3,$2
	dmultu	$8,$7
	dsubu	$3,$10,$3
	sgtu	$10,$3,$10
	daddu	$2,$2,$10
	sd	$3,0($4)
	daddiu	$4,$4,8
	daddu	$2,$9,$2	# add high product limb and carry from addition

/* # cool down phase 0 */
$LC0:	ld	$10,0($4)
	mflo	$3
	mfhi	$9
	daddu	$3,$3,$2
	sltu	$2,$3,$2
	dsubu	$3,$10,$3
	sgtu	$10,$3,$10
	daddu	$2,$2,$10
	sd	$3,0($4)
	j	$31
	daddu	$2,$9,$2	# add high product limb and carry from addition

	.end	_gcry_mpih_submul_1

