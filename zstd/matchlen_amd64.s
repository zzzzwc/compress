// Code generated by command: go run gen_matchlen.go -out ../matchlen_amd64.s -pkg=zstd. DO NOT EDIT.

//go:build !appengine && !noasm && gc && !noasm

#include "textflag.h"

// func matchLen(a []byte, b []byte) int
// Requires: AVX, AVX2, BMI, CMOV
TEXT ·matchLen(SB), NOSPLIT, $0-56
	// load param
	MOVQ a_base+0(FP), AX
	MOVQ a_len+8(FP), CX
	MOVQ b_base+24(FP), DX
	XORQ SI, SI

	// find the minimum length slice
loop:
	CMPQ CX, $0x20
	JB   last_loop

	// load 32 bytes into YMM registers
	VMOVDQU (AX), Y0
	VMOVDQU (DX), Y1

	// compare bytes in adata and bdata, like 'bytewise XNOR'
	// if the byte is the same in adata and bdata, VPCMPEQB will store 0xFF in the same position in equalMaskBytes
	VPCMPEQB Y0, Y1, Y0

	// like convert byte to bit, store equalMaskBytes into general reg
	VPMOVMSKB Y0, BX
	CMPL      BX, $0xffffffff
	JNE       cal_prefix
	ADDQ      $0x20, AX
	ADDQ      $0x20, DX
	SUBQ      $0x20, CX
	ADDQ      $0x20, SI
	JMP       loop

last_loop:
	TESTQ     CX, CX
	JZ        ret
	VMOVDQU   (AX), Y0
	VMOVDQU   (DX), Y1
	VPCMPEQB  Y0, Y1, Y0
	VPMOVMSKB Y0, BX
	CMPL      BX, $0xffffffff
	JNE       cal_last_prefix

	// if last bytes are all equal, just add remaining len on ret and return
	ADDQ CX, SI
	JMP  ret

cal_last_prefix:
	NOTQ BX

	// store first not equal position into matchedLen
	TZCNTQ BX, AX

	// if matched len > remaining len, just add remaining on ret
	CMPQ    CX, AX
	CMOVQLT CX, AX
	ADDQ    AX, SI
	JMP     ret

cal_prefix:
	NOTQ   BX
	TZCNTQ BX, AX
	ADDQ   AX, SI

ret:
	MOVQ SI, ret+48(FP)
	RET
