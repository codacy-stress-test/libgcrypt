/* Alpha 21064 __udiv_qrnnd
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
 *
 * Note: This code is heavily based on the GNU MP Library.
 *	 Actually it's the same code with only minor changes in the
 *	 way the data is stored; this is to support the abstraction
 *	 of an optional secure memory allocation which may be used
 *	 to avoid revealing of sensitive data due to paging etc.
 */



	.set noreorder
	.set noat
.text
	.align	3
	.globl	__udiv_qrnnd
	.ent	__udiv_qrnnd
__udiv_qrnnd:
	.frame $30,0,$26,0
	.prologue 0
#define cnt	$2
#define tmp	$3
#define rem_ptr $16
#define n1	$17
#define n0	$18
#define d	$19
#define qb	$20

	ldiq	cnt,16
	blt	d,.Largedivisor

.Loop1: cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	d,n1,qb
	subq	n1,d,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	d,n1,qb
	subq	n1,d,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	d,n1,qb
	subq	n1,d,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	d,n1,qb
	subq	n1,d,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	subq	cnt,1,cnt
	bgt	cnt,.Loop1
	stq	n1,0(rem_ptr)
	bis	$31,n0,$0
	ret	$31,($26),1

.Largedivisor:
	and	n0,1,$4

	srl	n0,1,n0
	sll	n1,63,tmp
	or	tmp,n0,n0
	srl	n1,1,n1

	and	d,1,$6
	srl	d,1,$5
	addq	$5,$6,$5

.Loop2: cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	$5,n1,qb
	subq	n1,$5,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	$5,n1,qb
	subq	n1,$5,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	$5,n1,qb
	subq	n1,$5,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	cmplt	n0,0,tmp
	addq	n1,n1,n1
	bis	n1,tmp,n1
	addq	n0,n0,n0
	cmpule	$5,n1,qb
	subq	n1,$5,tmp
	cmovne	qb,tmp,n1
	bis	n0,qb,n0
	subq	cnt,1,cnt
	bgt	cnt,.Loop2

	addq	n1,n1,n1
	addq	$4,n1,n1
	bne	$6,.LOdd
	stq	n1,0(rem_ptr)
	bis	$31,n0,$0
	ret	$31,($26),1

.LOdd:
	/* q' in n0. r' in n1 */
	addq	n1,n0,n1
	cmpult	n1,n0,tmp	# tmp := carry from addq
	beq	tmp,.LLp6
	addq	n0,1,n0
	subq	n1,d,n1
.LLp6:	cmpult	n1,d,tmp
	bne	tmp,.LLp7
	addq	n0,1,n0
	subq	n1,d,n1
.LLp7:
	stq	n1,0(rem_ptr)
	bis	$31,n0,$0
	ret	$31,($26),1

	.end	__udiv_qrnnd
