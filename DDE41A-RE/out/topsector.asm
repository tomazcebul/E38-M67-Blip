; Top flash sector 0xFC000-0xFFFFF from BMW_E38_3.9D_180KW_0281010843_1037351475_Bosch__.ori
; RAM blocks are listed at their run address; 'flash' = address in the 0x80000 flash image

;==========================================================================
; ram_block_C000: flash 0FC000-0FC2FF, runs at 00C000, 768 bytes, 534 bytes decoded
; header (32-bit words): ptr1 00C014 ptr2 00C000 ptr3 00C01C end 00C300 info 0000E601
;==========================================================================
entry_00C01C:
  00C01C: 8870      MOV     [-R0], R7
  00C01E: 8880      MOV     [-R0], R8
  00C020: 8890      MOV     [-R0], R9
  00C022: 26f01400  SUB     R0, #0x0014
  00C026: ec00      PUSH    DPP0
  00C028: dc4d      EXTP    R13, #1
  00C02A: a84c      MOV     R4, [R12]
  00C02C: c4400600  MOV     [R0+#0x0006], R4
  00C030: f2f4e8fa  MOV     R4, 0xFAE8
  00C034: f2f5eafa  MOV     R5, 0xFAEA
  00C038: dc65      EXTP    R5, #3
  00C03A: d4a40200  MOV     R10, [R4+#0x0002]
  00C03E: d4b40400  MOV     R11, [R4+#0x0004]
  00C042: cc00      NOP
  00C044: f0ea      MOV     R14, R10
  00C046: fc00      POP     DPP0
  00C048: e6f701f7  MOV     R7, #0xF701
  00C04C: e108      MOVB    RL4, #0
  00C04E: e4800300  MOVB    [R0+#0x0003], RL4
  00C052: f3fabcf9  MOVB    RL5, 0xF9BC
  00C056: e4a00200  MOVB    [R0+#0x0002], RL5
  00C05A: f3f6bdf9  MOVB    RL3, 0xF9BD
  00C05E: e4600100  MOVB    [R0+#0x0001], RL3
  00C062: a400bef9  MOVB    [R0], 0xF9BE
  00C066: e104      MOVB    RL2, #0
  00C068: e4400b00  MOVB    [R0+#0x000B], RL2
  00C06C: f3f2bff9  MOVB    RL1, 0xF9BF
  00C070: e4200a00  MOVB    [R0+#0x000A], RL1
  00C074: f3f8c0f9  MOVB    RL4, 0xF9C0
  00C078: e4800900  MOVB    [R0+#0x0009], RL4
  00C07C: f3f8c1f9  MOVB    RL4, 0xF9C1
  00C080: e4800800  MOVB    [R0+#0x0008], RL4
  00C084: a840      MOV     R4, [R0]
  00C086: 6841      AND     R4, #1
  00C088: 3d22      JMPR    cc_NZ, 0x00C0CE
  00C08A: d4400800  MOV     R4, [R0+#0x0008]
  00C08E: 6841      AND     R4, #1
  00C090: 2d1e      JMPR    cc_Z, 0x00C0CE
  00C092: a840      MOV     R4, [R0]
  00C094: d4500200  MOV     R5, [R0+#0x0002]
  00C098: d4a00800  MOV     R10, [R0+#0x0008]
  00C09C: d4b00a00  MOV     R11, [R0+#0x000A]
  00C0A0: 204a      SUB     R4, R10
  00C0A2: 305b      SUBC    R5, R11
  00C0A4: ed14      JMPR    cc_UGT, 0x00C0CE
  00C0A6: a840      MOV     R4, [R0]
  00C0A8: d4500200  MOV     R5, [R0+#0x0002]
  00C0AC: a8ae      MOV     R10, [R14]
  00C0AE: d4be0200  MOV     R11, [R14+#0x0002]
  00C0B2: 204a      SUB     R4, R10
  00C0B4: 305b      SUBC    R5, R11
  00C0B6: 8d0b      JMPR    cc_C, 0x00C0CE
  00C0B8: d4400800  MOV     R4, [R0+#0x0008]
  00C0BC: d4500a00  MOV     R5, [R0+#0x000A]
  00C0C0: f02e      MOV     R2, R14
  00C0C2: 0824      ADD     R2, #4
  00C0C4: 98a2      MOV     R10, [R2+]
  00C0C6: a8b2      MOV     R11, [R2]
  00C0C8: 204a      SUB     R4, R10
  00C0CA: 305b      SUBC    R5, R11
  00C0CC: 8d10      JMPR    cc_C, 0x00C0EE
loc_00C0CE:
  00C0CE: d4400600  MOV     R4, [R0+#0x0006]
  00C0D2: 0af48080  BFLDL   R4, #0x80, #0x80
  00C0D6: c4400600  MOV     [R0+#0x0006], R4
  00C0DA: d4500600  MOV     R5, [R0+#0x0006]
  00C0DE: 0af52020  BFLDL   R5, #0x20, #0x20
  00C0E2: c4500600  MOV     [R0+#0x0006], R5
  00C0E6: e7f83100  MOVB    RL4, #0x31
  00C0EA: f7f8f6fa  MOVB    0xFAF6, RL4
loc_00C0EE:
  00C0EE: ec00      PUSH    DPP0
  00C0F0: ec01      PUSH    DPP1
  00C0F2: cc00      NOP
  00C0F4: d4400600  MOV     R4, [R0+#0x0006]
  00C0F8: 66f40001  AND     R4, #0x0100
  00C0FC: 3d15      JMPR    cc_NZ, 0x00C128
  00C0FE: f78ef7fa  MOVB    0xFAF7, ZEROS
  00C102: f78ef8fa  MOVB    0xFAF8, ZEROS
  00C106: e00a      MOV     R10, #0
  00C108: e6fb2000  MOV     R11, #0x0020
  00C10C: f04b      MOV     R4, R11
  00C10E: f6f400fe  MOV     0xFE00, R4
  00C112: cc00      NOP
  00C114: e008      MOV     R8, #0
  00C116: e7f8f000  MOVB    RL4, #0xF0
  00C11A: b988      MOVB    [R8], RL4
  00C11C: d4400600  MOV     R4, [R0+#0x0006]
  00C120: 1af40101  BFLDH   R4, #0x01, #0x01
  00C124: c4400600  MOV     [R0+#0x0006], R4
loc_00C128:
  00C128: cc00      NOP
  00C12A: 0d61      JMPR    cc_UC, 0x00C1EE
loc_00C12C:
  00C12C: a840      MOV     R4, [R0]
  00C12E: d4500200  MOV     R5, [R0+#0x0002]
  00C132: f025      MOV     R2, R5
  00C134: 7cf4      SHR     R4, #15
  00C136: 7cf5      SHR     R5, #15
  00C138: 5c12      SHL     R2, #1
  00C13A: 7042      OR      R4, R2
  00C13C: f0f4      MOV     R15, R4
  00C13E: f04f      MOV     R4, R15
  00C140: c084      MOVBZ   R4, RL4
  00C142: 5c14      SHL     R4, #1
  00C144: f6f400fe  MOV     0xFE00, R4
  00C148: 0841      ADD     R4, #1
  00C14A: f6f402fe  MOV     0xFE02, R4
  00C14E: cc00      NOP
  00C150: a840      MOV     R4, [R0]
  00C152: d4500200  MOV     R5, [R0+#0x0002]
  00C156: 66f4ff7f  AND     R4, #0x7FFF
  00C15A: 6850      AND     R5, #0
  00C15C: f094      MOV     R9, R4
  00C15E: a849      MOV     R4, [R9]
  00C160: c4401200  MOV     [R0+#0x0012], R4
  00C164: f4801300  MOVB    RL4, [R0+#0x0013]
  00C168: 05f8f8fa  ADDB    0xFAF8, RL4
  00C16C: 9a880210  JNB     PSW.1, 0x00C174
  00C170: 258ff7fa  SUBB    0xFAF7, ONES
loc_00C174:
  00C174: f4801200  MOVB    RL4, [R0+#0x0012]
  00C178: 05f8f8fa  ADDB    0xFAF8, RL4
  00C17C: 9a880210  JNB     PSW.1, 0x00C184
  00C180: 258ff7fa  SUBB    0xFAF7, ONES
loc_00C184:
  00C184: a840      MOV     R4, [R0]
  00C186: d4500200  MOV     R5, [R0+#0x0002]
  00C18A: 0842      ADD     R4, #2
  00C18C: 1850      ADDC    R5, #0
  00C18E: b840      MOV     [R0], R4
  00C190: c4500200  MOV     [R0+#0x0002], R5
  00C194: d4a00800  MOV     R10, [R0+#0x0008]
  00C198: d4b00a00  MOV     R11, [R0+#0x000A]
  00C19C: 204a      SUB     R4, R10
  00C19E: 305b      SUBC    R5, R11
  00C1A0: fd26      JMPR    cc_ULE, 0x00C1EE
  00C1A2: d4400600  MOV     R4, [R0+#0x0006]
  00C1A6: 0af42020  BFLDL   R4, #0x20, #0x20
  00C1AA: c4400600  MOV     [R0+#0x0006], R4
  00C1AE: f3f8f7fa  MOVB    RL4, 0xFAF7
  00C1B2: e4800f00  MOVB    [R0+#0x000F], RL4
  00C1B6: f3faf8fa  MOVB    RL5, 0xFAF8
  00C1BA: e4a00e00  MOVB    [R0+#0x000E], RL5
  00C1BE: f3f6c2f9  MOVB    RL3, 0xF9C2
  00C1C2: e4601100  MOVB    [R0+#0x0011], RL3
  00C1C6: f3f4c3f9  MOVB    RL2, 0xF9C3
  00C1CA: e4401000  MOVB    [R0+#0x0010], RL2
  00C1CE: d4401000  MOV     R4, [R0+#0x0010]
  00C1D2: d4500e00  MOV     R5, [R0+#0x000E]
  00C1D6: 4054      CMP     R5, R4
  00C1D8: 2d0a      JMPR    cc_Z, 0x00C1EE
  00C1DA: d4200600  MOV     R2, [R0+#0x0006]
  00C1DE: 0af28080  BFLDL   R2, #0x80, #0x80
  00C1E2: c4200600  MOV     [R0+#0x0006], R2
  00C1E6: e7f81000  MOVB    RL4, #0x10
  00C1EA: f7f8f6fa  MOVB    0xFAF6, RL4
loc_00C1EE:
  00C1EE: d4400600  MOV     R4, [R0+#0x0006]
  00C1F2: 66f42000  AND     R4, #0x0020
  00C1F6: 3d07      JMPR    cc_NZ, 0x00C206
  00C1F8: f2f442fe  MOV     R4, 0xFE42
  00C1FC: 46f40a00  CMP     R4, #0x000A
  00C200: 8d02      JMPR    cc_C, 0x00C206
  00C202: 9ab19370  JNB     T3IC.7, 0x00C12C
loc_00C206:
  00C206: f4800200  MOVB    RL4, [R0+#0x0002]
  00C20A: f7f8bcf9  MOVB    0xF9BC, RL4
  00C20E: f4a00100  MOVB    RL5, [R0+#0x0001]
  00C212: f7fabdf9  MOVB    0xF9BD, RL5
  00C216: b400bef9  MOVB    0xF9BE, [R0]
  00C21A: d4400600  MOV     R4, [R0+#0x0006]
  00C21E: dc4d      EXTP    R13, #1
  00C220: b84c      MOV     [R12], R4
  00C222: fc01      POP     DPP1
  00C224: fc00      POP     DPP0
  00C226: 06f01400  ADD     R0, #0x0014
  00C22A: 9890      MOV     R9, [R0+]
  00C22C: 9880      MOV     R8, [R0+]
  00C22E: 9870      MOV     R7, [R0+]
  00C230: db00      RETS

;==========================================================================
; ram_block_E000: flash 0FC300-0FC5FF, runs at 00E000, 768 bytes, 656 bytes decoded
; header (32-bit words): ptr1 00E014 ptr2 00E02E ptr3 00E034 end 00E300 info 000C4702
;==========================================================================
entry_00E02E:
  00E02E: 452f      DB      0x45 0x2F

entry_00E034:
  00E034: 8860      MOV     [-R0], R6
  00E036: 8870      MOV     [-R0], R7
  00E038: 8880      MOV     [-R0], R8
  00E03A: 8890      MOV     [-R0], R9
  00E03C: 26f01400  SUB     R0, #0x0014
  00E040: ec00      PUSH    DPP0
  00E042: e6868e04  MOV     BUSCON0, #0x048E
  00E046: dc4d      EXTP    R13, #1
  00E048: a84c      MOV     R4, [R12]
  00E04A: b840      MOV     [R0], R4
  00E04C: f2f4e8fa  MOV     R4, 0xFAE8
  00E050: f2f5eafa  MOV     R5, 0xFAEA
  00E054: dc65      EXTP    R5, #3
  00E056: d4a40200  MOV     R10, [R4+#0x0002]
  00E05A: d4b40400  MOV     R11, [R4+#0x0004]
  00E05E: cc00      NOP
  00E060: c4a00e00  MOV     [R0+#0x000E], R10
  00E064: dc65      EXTP    R5, #3
  00E066: d4a40600  MOV     R10, [R4+#0x0006]
  00E06A: d4b40800  MOV     R11, [R4+#0x0008]
  00E06E: cc00      NOP
  00E070: f08a      MOV     R8, R10
  00E072: a988      MOVB    RL4, [R8]
  00E074: 53f8aaf9  XORB    RL4, 0xF9AA
  00E078: b180      CPLB    RL4
  00E07A: e4800200  MOVB    [R0+#0x0002], RL4
  00E07E: f4a80100  MOVB    RL5, [R8+#0x0001]
  00E082: 53faabf9  XORB    RL5, 0xF9AB
  00E086: b1a0      CPLB    RL5
  00E088: e4a00300  MOVB    [R0+#0x0003], RL5
  00E08C: f4680200  MOVB    RL3, [R8+#0x0002]
  00E090: 53f6adf9  XORB    RL3, 0xF9AD
  00E094: b160      CPLB    RL3
  00E096: e4600400  MOVB    [R0+#0x0004], RL3
  00E09A: f4480300  MOVB    RL2, [R8+#0x0003]
  00E09E: 53f4acf9  XORB    RL2, 0xF9AC
  00E0A2: b140      CPLB    RL2
  00E0A4: e4400500  MOVB    [R0+#0x0005], RL2
  00E0A8: f4280400  MOVB    RL1, [R8+#0x0004]
  00E0AC: 53f2acf9  XORB    RL1, 0xF9AC
  00E0B0: b120      CPLB    RL1
  00E0B2: e4200600  MOVB    [R0+#0x0006], RL1
  00E0B6: fc00      POP     DPP0
  00E0B8: e6f401f7  MOV     R4, #0xF701
  00E0BC: c4401200  MOV     [R0+#0x0012], R4
  00E0C0: f3f8bcf9  MOVB    RL4, 0xF9BC
  00E0C4: e4800900  MOVB    [R0+#0x0009], RL4
  00E0C8: f3fabdf9  MOVB    RL5, 0xF9BD
  00E0CC: e4a00800  MOVB    [R0+#0x0008], RL5
  00E0D0: f3f6bff9  MOVB    RL3, 0xF9BF
  00E0D4: e4600d00  MOVB    [R0+#0x000D], RL3
  00E0D8: f3f4c0f9  MOVB    RL2, 0xF9C0
  00E0DC: e4400c00  MOVB    [R0+#0x000C], RL2
  00E0E0: e7f2ff00  MOVB    RL1, #0xFF
  00E0E4: f1e2      MOVB    RL7, RL1
  00E0E6: f1c2      MOVB    RL6, RL1
  00E0E8: e01f      MOV     R15, #1
  00E0EA: 0d1a      JMPR    cc_UC, 0x00E120
loc_00E0EC:
  00E0EC: f04f      MOV     R4, R15
  00E0EE: c084      MOVBZ   R4, RL4
  00E0F0: 5c14      SHL     R4, #1
  00E0F2: d4500e00  MOV     R5, [R0+#0x000E]
  00E0F6: 0054      ADD     R5, R4
  00E0F8: a845      MOV     R4, [R5]
  00E0FA: c4400a00  MOV     [R0+#0x000A], R4
  00E0FE: d4500800  MOV     R5, [R0+#0x0008]
  00E102: 4054      CMP     R5, R4
  00E104: 3d01      JMPR    cc_NZ, 0x00E108
  00E106: f06f      MOV     R6, R15
loc_00E108:
  00E108: d4400a00  MOV     R4, [R0+#0x000A]
  00E10C: 2841      SUB     R4, #1
  00E10E: d4500c00  MOV     R5, [R0+#0x000C]
  00E112: 4054      CMP     R5, R4
  00E114: 3d02      JMPR    cc_NZ, 0x00E11A
  00E116: f07f      MOV     R7, R15
  00E118: 29e1      SUBB    RL7, #1
loc_00E11A:
  00E11A: f04f      MOV     R4, R15
  00E11C: 0981      ADDB    RL4, #1
  00E11E: f0f4      MOV     R15, R4
loc_00E120:
  00E120: d4200e00  MOV     R2, [R0+#0x000E]
  00E124: f04f      MOV     R4, R15
  00E126: c084      MOVBZ   R4, RL4
  00E128: 484a      CMP     R4, [R2]
  00E12A: fde0      JMPR    cc_ULE, 0x00E0EC
  00E12C: f3f8bef9  MOVB    RL4, 0xF9BE
  00E130: 3d0a      JMPR    cc_NZ, 0x00E146
  00E132: f3fac1f9  MOVB    RL5, 0xF9C1
  00E136: 47faff00  CMPB    RL5, #0xFF
  00E13A: 3d05      JMPR    cc_NZ, 0x00E146
  00E13C: 41ce      CMPB    RL6, RL7
  00E13E: ed03      JMPR    cc_UGT, 0x00E146
  00E140: 47feff00  CMPB    RL7, #0xFF
  00E144: 3d08      JMPR    cc_NZ, 0x00E156
loc_00E146:
  00E146: a840      MOV     R4, [R0]
  00E148: 0af48080  BFLDL   R4, #0x80, #0x80
  00E14C: b840      MOV     [R0], R4
  00E14E: e7f83100  MOVB    RL4, #0x31
  00E152: f7f8f4fa  MOVB    0xFAF4, RL4
loc_00E156:
  00E156: ec00      PUSH    DPP0
  00E158: ec01      PUSH    DPP1
  00E15A: cc00      NOP
  00E15C: d4400800  MOV     R4, [R0+#0x0008]
  00E160: 7c74      SHR     R4, #7
  00E162: e4801000  MOVB    [R0+#0x0010], RL4
  00E166: d4900800  MOV     R9, [R0+#0x0008]
  00E16A: 5c89      SHL     R9, #8
  00E16C: 66f9ff7f  AND     R9, #0x7FFF
  00E170: a840      MOV     R4, [R0]
  00E172: 66f40001  AND     R4, #0x0100
  00E176: 3d3e      JMPR    cc_NZ, 0x00E1F4
  00E178: a840      MOV     R4, [R0]
  00E17A: 66f48000  AND     R4, #0x0080
  00E17E: 3d3a      JMPR    cc_NZ, 0x00E1F4
  00E180: e00a      MOV     R10, #0
  00E182: e6fb2000  MOV     R11, #0x0020
  00E186: f04b      MOV     R4, R11
  00E188: 0842      ADD     R4, #2
  00E18A: f6f400fe  MOV     0xFE00, R4
  00E18E: e00a      MOV     R10, #0
  00E190: e6fb2000  MOV     R11, #0x0020
  00E194: f04b      MOV     R4, R11
  00E196: 0841      ADD     R4, #1
  00E198: f6f402fe  MOV     0xFE02, R4
  00E19C: cc00      NOP
  00E19E: e6feaa2a  MOV     R14, #0x2AAA
  00E1A2: f4800200  MOVB    RL4, [R0+#0x0002]
  00E1A6: b98e      MOVB    [R14], RL4
  00E1A8: e6fe5455  MOV     R14, #0x5554
  00E1AC: f4800300  MOVB    RL4, [R0+#0x0003]
  00E1B0: b98e      MOVB    [R14], RL4
  00E1B2: e6feaa2a  MOV     R14, #0x2AAA
  00E1B6: f4800400  MOVB    RL4, [R0+#0x0004]
  00E1BA: b98e      MOVB    [R14], RL4
  00E1BC: e6feaa2a  MOV     R14, #0x2AAA
  00E1C0: f4800500  MOVB    RL4, [R0+#0x0005]
  00E1C4: b98e      MOVB    [R14], RL4
  00E1C6: e6fe5455  MOV     R14, #0x5554
  00E1CA: f4800600  MOVB    RL4, [R0+#0x0006]
  00E1CE: b98e      MOVB    [R14], RL4
  00E1D0: f4801000  MOVB    RL4, [R0+#0x0010]
  00E1D4: c084      MOVBZ   R4, RL4
  00E1D6: 5c14      SHL     R4, #1
  00E1D8: f6f400fe  MOV     0xFE00, R4
  00E1DC: 0841      ADD     R4, #1
  00E1DE: f6f402fe  MOV     0xFE02, R4
  00E1E2: cc00      NOP
  00E1E4: e6f43000  MOV     R4, #0x0030
  00E1E8: b849      MOV     [R9], R4
  00E1EA: a840      MOV     R4, [R0]
  00E1EC: 1af40101  BFLDH   R4, #0x01, #0x01
  00E1F0: b840      MOV     [R0], R4
  00E1F2: 0d09      JMPR    cc_UC, 0x00E206
loc_00E1F4:
  00E1F4: f4801000  MOVB    RL4, [R0+#0x0010]
  00E1F8: c084      MOVBZ   R4, RL4
  00E1FA: 5c14      SHL     R4, #1
  00E1FC: f6f400fe  MOV     0xFE00, R4
  00E200: 0841      ADD     R4, #1
  00E202: f6f402fe  MOV     0xFE02, R4
loc_00E206:
  00E206: a840      MOV     R4, [R0]
  00E208: 66f48000  AND     R4, #0x0080
  00E20C: 3d46      JMPR    cc_NZ, 0x00E29A
  00E20E: a849      MOV     R4, [R9]
  00E210: c4400a00  MOV     [R0+#0x000A], R4
  00E214: a859      MOV     R5, [R9]
  00E216: 7c65      SHR     R5, #6
  00E218: 6851      AND     R5, #1
  00E21A: d4200a00  MOV     R2, [R0+#0x000A]
  00E21E: 7c62      SHR     R2, #6
  00E220: 6821      AND     R2, #1
  00E222: 4025      CMP     R2, R5
  00E224: 3d16      JMPR    cc_NZ, 0x00E252
  00E226: a850      MOV     R5, [R0]
  00E228: 66f5fffe  AND     R5, #0xFEFF
  00E22C: b850      MOV     [R0], R5
  00E22E: 09c1      ADDB    RL6, #1
  00E230: f18c      MOVB    RL4, RL6
  00E232: 418e      CMPB    RL4, RL7
  00E234: ed09      JMPR    cc_UGT, 0x00E248
  00E236: c0c4      MOVBZ   R4, RL6
  00E238: 5c14      SHL     R4, #1
  00E23A: d4200e00  MOV     R2, [R0+#0x000E]
  00E23E: 0024      ADD     R2, R4
  00E240: a842      MOV     R4, [R2]
  00E242: c4400800  MOV     [R0+#0x0008], R4
  00E246: 0d29      JMPR    cc_UC, 0x00E29A
loc_00E248:
  00E248: a840      MOV     R4, [R0]
  00E24A: 0af42020  BFLDL   R4, #0x20, #0x20
  00E24E: b840      MOV     [R0], R4
  00E250: 0d24      JMPR    cc_UC, 0x00E29A
loc_00E252:
  00E252: d4400a00  MOV     R4, [R0+#0x000A]
  00E256: 66f42000  AND     R4, #0x0020
  00E25A: 2d1f      JMPR    cc_Z, 0x00E29A
  00E25C: a849      MOV     R4, [R9]
  00E25E: c4400a00  MOV     [R0+#0x000A], R4
  00E262: a859      MOV     R5, [R9]
  00E264: 7c65      SHR     R5, #6
  00E266: 6851      AND     R5, #1
  00E268: d4200a00  MOV     R2, [R0+#0x000A]
  00E26C: 7c62      SHR     R2, #6
  00E26E: 6821      AND     R2, #1
  00E270: 4025      CMP     R2, R5
  00E272: 2d13      JMPR    cc_Z, 0x00E29A
  00E274: a850      MOV     R5, [R0]
  00E276: 0af58080  BFLDL   R5, #0x80, #0x80
  00E27A: b850      MOV     [R0], R5
  00E27C: e7f81000  MOVB    RL4, #0x10
  00E280: f7f8f4fa  MOVB    0xFAF4, RL4
  00E284: e00a      MOV     R10, #0
  00E286: e6fb2000  MOV     R11, #0x0020
  00E28A: f04b      MOV     R4, R11
  00E28C: f6f400fe  MOV     0xFE00, R4
  00E290: cc00      NOP
  00E292: e00e      MOV     R14, #0
  00E294: e7f8f000  MOVB    RL4, #0xF0
  00E298: b98e      MOVB    [R14], RL4
loc_00E29A:
  00E29A: f4800900  MOVB    RL4, [R0+#0x0009]
  00E29E: f7f8bcf9  MOVB    0xF9BC, RL4
  00E2A2: f4a00800  MOVB    RL5, [R0+#0x0008]
  00E2A6: f7fabdf9  MOVB    0xF9BD, RL5
  00E2AA: a840      MOV     R4, [R0]
  00E2AC: dc4d      EXTP    R13, #1
  00E2AE: b84c      MOV     [R12], R4
  00E2B0: fc01      POP     DPP1
  00E2B2: fc00      POP     DPP0
  00E2B4: 06f01400  ADD     R0, #0x0014
  00E2B8: 9890      MOV     R9, [R0+]
  00E2BA: 9880      MOV     R8, [R0+]
  00E2BC: 9870      MOV     R7, [R0+]
  00E2BE: 9860      MOV     R6, [R0+]
  00E2C0: db00      RETS

;==========================================================================
; ram_block_E300: flash 0FC600-0FC8FF, runs at 00E300, 768 bytes, 670 bytes decoded
; header (32-bit words): ptr1 00E314 ptr2 00E31C ptr3 00E320 end 00E600 info 0000D380
;==========================================================================
entry_00E31C:
  00E31C: 452f      DB      0x45 0x2F

entry_00E320:
  00E320: 8860      MOV     [-R0], R6
  00E322: 8870      MOV     [-R0], R7
  00E324: 8880      MOV     [-R0], R8
  00E326: 8890      MOV     [-R0], R9
  00E328: 26f00e00  SUB     R0, #0x000E
  00E32C: ec00      PUSH    DPP0
  00E32E: dc4d      EXTP    R13, #1
  00E330: a84c      MOV     R4, [R12]
  00E332: b840      MOV     [R0], R4
  00E334: f2f4e8fa  MOV     R4, 0xFAE8
  00E338: f2f5eafa  MOV     R5, 0xFAEA
  00E33C: dc65      EXTP    R5, #3
  00E33E: d4a40200  MOV     R10, [R4+#0x0002]
  00E342: d4b40400  MOV     R11, [R4+#0x0004]
  00E346: cc00      NOP
  00E348: f08a      MOV     R8, R10
  00E34A: fc00      POP     DPP0
  00E34C: e6f701f7  MOV     R7, #0xF701
  00E350: e108      MOVB    RL4, #0
  00E352: e4800500  MOVB    [R0+#0x0005], RL4
  00E356: f2f4e6fa  MOV     R4, 0xFAE6
  00E35A: a9a4      MOVB    RL5, [R4]
  00E35C: e4a00400  MOVB    [R0+#0x0004], RL5
  00E360: f4640100  MOVB    RL3, [R4+#0x0001]
  00E364: e4600300  MOVB    [R0+#0x0003], RL3
  00E368: f4440200  MOVB    RL2, [R4+#0x0002]
  00E36C: e4400200  MOVB    [R0+#0x0002], RL2
  00E370: d4400200  MOV     R4, [R0+#0x0002]
  00E374: d4500400  MOV     R5, [R0+#0x0004]
  00E378: a8a8      MOV     R10, [R8]
  00E37A: d4b80200  MOV     R11, [R8+#0x0002]
  00E37E: 204a      SUB     R4, R10
  00E380: 305b      SUBC    R5, R11
  00E382: 8d13      JMPR    cc_C, 0x00E3AA
  00E384: d4400200  MOV     R4, [R0+#0x0002]
  00E388: d4500400  MOV     R5, [R0+#0x0004]
  00E38C: f2f2e6fa  MOV     R2, 0xFAE6
  00E390: f4220300  MOVB    RL1, [R2+#0x0003]
  00E394: c02a      MOVBZ   R10, RL1
  00E396: e00b      MOV     R11, #0
  00E398: 004a      ADD     R4, R10
  00E39A: 105b      ADDC    R5, R11
  00E39C: f038      MOV     R3, R8
  00E39E: 0834      ADD     R3, #4
  00E3A0: 98a3      MOV     R10, [R3+]
  00E3A2: a8b3      MOV     R11, [R3]
  00E3A4: 204a      SUB     R4, R10
  00E3A6: 305b      SUBC    R5, R11
  00E3A8: fd08      JMPR    cc_ULE, 0x00E3BA
loc_00E3AA:
  00E3AA: a840      MOV     R4, [R0]
  00E3AC: 0af48080  BFLDL   R4, #0x80, #0x80
  00E3B0: b840      MOV     [R0], R4
  00E3B2: e7f83100  MOVB    RL4, #0x31
  00E3B6: f7f8f5fa  MOVB    0xFAF5, RL4
loc_00E3BA:
  00E3BA: f2f4e8fa  MOV     R4, 0xFAE8
  00E3BE: f2f5eafa  MOV     R5, 0xFAEA
  00E3C2: dc65      EXTP    R5, #3
  00E3C4: d4a40600  MOV     R10, [R4+#0x0006]
  00E3C8: d4b40800  MOV     R11, [R4+#0x0008]
  00E3CC: cc00      NOP
  00E3CE: f09a      MOV     R9, R10
  00E3D0: a989      MOVB    RL4, [R9]
  00E3D2: 53f8aaf9  XORB    RL4, 0xF9AA
  00E3D6: b180      CPLB    RL4
  00E3D8: e4800800  MOVB    [R0+#0x0008], RL4
  00E3DC: f4a90100  MOVB    RL5, [R9+#0x0001]
  00E3E0: 53faabf9  XORB    RL5, 0xF9AB
  00E3E4: b1a0      CPLB    RL5
  00E3E6: e4a00900  MOVB    [R0+#0x0009], RL5
  00E3EA: f4690200  MOVB    RL3, [R9+#0x0002]
  00E3EE: 53f6aaf9  XORB    RL3, 0xF9AA
  00E3F2: b160      CPLB    RL3
  00E3F4: e4600a00  MOVB    [R0+#0x000A], RL3
  00E3F8: ec00      PUSH    DPP0
  00E3FA: ec01      PUSH    DPP1
  00E3FC: cc00      NOP
  00E3FE: f2f4e6fa  MOV     R4, 0xFAE6
  00E402: f4a40400  MOVB    RL5, [R4+#0x0004]
  00E406: c0aa      MOVBZ   R10, RL5
  00E408: e00b      MOV     R11, #0
  00E40A: d4400200  MOV     R4, [R0+#0x0002]
  00E40E: d4500400  MOV     R5, [R0+#0x0004]
  00E412: 004a      ADD     R4, R10
  00E414: 105b      ADDC    R5, R11
  00E416: c4400200  MOV     [R0+#0x0002], R4
  00E41A: c4500400  MOV     [R0+#0x0004], R5
  00E41E: f025      MOV     R2, R5
  00E420: 7cf4      SHR     R4, #15
  00E422: 7cf5      SHR     R5, #15
  00E424: 5c12      SHL     R2, #1
  00E426: 7042      OR      R4, R2
  00E428: f1c8      MOVB    RL6, RL4
  00E42A: d4400200  MOV     R4, [R0+#0x0002]
  00E42E: d4500400  MOV     R5, [R0+#0x0004]
  00E432: 66f4ff7f  AND     R4, #0x7FFF
  00E436: 6850      AND     R5, #0
  00E438: f0e4      MOV     R14, R4
  00E43A: a840      MOV     R4, [R0]
  00E43C: 66f40001  AND     R4, #0x0100
  00E440: 3d50      JMPR    cc_NZ, 0x00E4E2
  00E442: a840      MOV     R4, [R0]
  00E444: 66f48000  AND     R4, #0x0080
  00E448: 3d4c      JMPR    cc_NZ, 0x00E4E2
  00E44A: c0c4      MOVBZ   R4, RL6
  00E44C: 5c14      SHL     R4, #1
  00E44E: f6f400fe  MOV     0xFE00, R4
  00E452: 0841      ADD     R4, #1
  00E454: f6f402fe  MOV     0xFE02, R4
  00E458: cc00      NOP
  00E45A: a84e      MOV     R4, [R14]
  00E45C: 46f4ffff  CMP     R4, #0xFFFF
  00E460: 2d0d      JMPR    cc_Z, 0x00E47C
  00E462: a840      MOV     R4, [R0]
  00E464: 66f40002  AND     R4, #0x0200
  00E468: 3d09      JMPR    cc_NZ, 0x00E47C
  00E46A: a840      MOV     R4, [R0]
  00E46C: 0af48080  BFLDL   R4, #0x80, #0x80
  00E470: b840      MOV     [R0], R4
  00E472: e7f82200  MOVB    RL4, #0x22
  00E476: f7f8f5fa  MOVB    0xFAF5, RL4
  00E47A: 0d3a      JMPR    cc_UC, 0x00E4F0
loc_00E47C:
  00E47C: e00a      MOV     R10, #0
  00E47E: e6fb2000  MOV     R11, #0x0020
  00E482: f04b      MOV     R4, R11
  00E484: 0842      ADD     R4, #2
  00E486: f6f400fe  MOV     0xFE00, R4
  00E48A: e00a      MOV     R10, #0
  00E48C: e6fb2000  MOV     R11, #0x0020
  00E490: f04b      MOV     R4, R11
  00E492: 0841      ADD     R4, #1
  00E494: f6f402fe  MOV     0xFE02, R4
  00E498: cc00      NOP
  00E49A: e6ffaa2a  MOV     R15, #0x2AAA
  00E49E: f4800800  MOVB    RL4, [R0+#0x0008]
  00E4A2: b98f      MOVB    [R15], RL4
  00E4A4: e6ff5455  MOV     R15, #0x5554
  00E4A8: f4800900  MOVB    RL4, [R0+#0x0009]
  00E4AC: b98f      MOVB    [R15], RL4
  00E4AE: e6ffaa2a  MOV     R15, #0x2AAA
  00E4B2: f4800a00  MOVB    RL4, [R0+#0x000A]
  00E4B6: b98f      MOVB    [R15], RL4
  00E4B8: c0c4      MOVBZ   R4, RL6
  00E4BA: 5c14      SHL     R4, #1
  00E4BC: f6f400fe  MOV     0xFE00, R4
  00E4C0: 0841      ADD     R4, #1
  00E4C2: f6f402fe  MOV     0xFE02, R4
  00E4C6: cc00      NOP
  00E4C8: f2f4e6fa  MOV     R4, 0xFAE6
  00E4CC: f4a40400  MOVB    RL5, [R4+#0x0004]
  00E4D0: c0a5      MOVBZ   R5, RL5
  00E4D2: 0045      ADD     R4, R5
  00E4D4: 0846      ADD     R4, #6
  00E4D6: c8e4      MOV     [R14], [R4]
  00E4D8: a840      MOV     R4, [R0]
  00E4DA: 1af40101  BFLDH   R4, #0x01, #0x01
  00E4DE: b840      MOV     [R0], R4
  00E4E0: 0d07      JMPR    cc_UC, 0x00E4F0
loc_00E4E2:
  00E4E2: c0c4      MOVBZ   R4, RL6
  00E4E4: 5c14      SHL     R4, #1
  00E4E6: f6f400fe  MOV     0xFE00, R4
  00E4EA: 0841      ADD     R4, #1
  00E4EC: f6f402fe  MOV     0xFE02, R4
loc_00E4F0:
  00E4F0: a840      MOV     R4, [R0]
  00E4F2: 66f48000  AND     R4, #0x0080
  00E4F6: 3d56      JMPR    cc_NZ, 0x00E5A4
  00E4F8: a84e      MOV     R4, [R14]
  00E4FA: c4400c00  MOV     [R0+#0x000C], R4
  00E4FE: a85e      MOV     R5, [R14]
  00E500: 7c65      SHR     R5, #6
  00E502: 6851      AND     R5, #1
  00E504: d4200c00  MOV     R2, [R0+#0x000C]
  00E508: 7c62      SHR     R2, #6
  00E50A: 6821      AND     R2, #1
  00E50C: 4025      CMP     R2, R5
  00E50E: 3d26      JMPR    cc_NZ, 0x00E55C
  00E510: a850      MOV     R5, [R0]
  00E512: 66f5fffe  AND     R5, #0xFEFF
  00E516: b850      MOV     [R0], R5
  00E518: f2f2e6fa  MOV     R2, 0xFAE6
  00E51C: f4820400  MOVB    RL4, [R2+#0x0004]
  00E520: c084      MOVBZ   R4, RL4
  00E522: 0024      ADD     R2, R4
  00E524: 0826      ADD     R2, #6
  00E526: a84e      MOV     R4, [R14]
  00E528: 484a      CMP     R4, [R2]
  00E52A: 3d0f      JMPR    cc_NZ, 0x00E54A
  00E52C: f2f4e6fa  MOV     R4, 0xFAE6
  00E530: f4a40300  MOVB    RL5, [R4+#0x0003]
  00E534: 0844      ADD     R4, #4
  00E536: a964      MOVB    RL3, [R4]
  00E538: 0962      ADDB    RL3, #2
  00E53A: b964      MOVB    [R4], RL3
  00E53C: 416a      CMPB    RL3, RL5
  00E53E: 8d32      JMPR    cc_C, 0x00E5A4
  00E540: a840      MOV     R4, [R0]
  00E542: 0af41010  BFLDL   R4, #0x10, #0x10
  00E546: b840      MOV     [R0], R4
  00E548: 0d2d      JMPR    cc_UC, 0x00E5A4
loc_00E54A:
  00E54A: a840      MOV     R4, [R0]
  00E54C: 0af48080  BFLDL   R4, #0x80, #0x80
  00E550: b840      MOV     [R0], R4
  00E552: e7f87200  MOVB    RL4, #0x72
  00E556: f7f8f5fa  MOVB    0xFAF5, RL4
  00E55A: 0d24      JMPR    cc_UC, 0x00E5A4
loc_00E55C:
  00E55C: d4400c00  MOV     R4, [R0+#0x000C]
  00E560: 66f42000  AND     R4, #0x0020
  00E564: 2d1f      JMPR    cc_Z, 0x00E5A4
  00E566: a84e      MOV     R4, [R14]
  00E568: c4400c00  MOV     [R0+#0x000C], R4
  00E56C: a85e      MOV     R5, [R14]
  00E56E: 7c65      SHR     R5, #6
  00E570: 6851      AND     R5, #1
  00E572: d4200c00  MOV     R2, [R0+#0x000C]
  00E576: 7c62      SHR     R2, #6
  00E578: 6821      AND     R2, #1
  00E57A: 4025      CMP     R2, R5
  00E57C: 2d13      JMPR    cc_Z, 0x00E5A4
  00E57E: a850      MOV     R5, [R0]
  00E580: 0af58080  BFLDL   R5, #0x80, #0x80
  00E584: b850      MOV     [R0], R5
  00E586: e7f87200  MOVB    RL4, #0x72
  00E58A: f7f8f5fa  MOVB    0xFAF5, RL4
  00E58E: e00a      MOV     R10, #0
  00E590: e6fb2000  MOV     R11, #0x0020
  00E594: f04b      MOV     R4, R11
  00E596: f6f400fe  MOV     0xFE00, R4
  00E59A: cc00      NOP
  00E59C: e00f      MOV     R15, #0
  00E59E: e7f8f000  MOVB    RL4, #0xF0
  00E5A2: b98f      MOVB    [R15], RL4
loc_00E5A4:
  00E5A4: a840      MOV     R4, [R0]
  00E5A6: dc4d      EXTP    R13, #1
  00E5A8: b84c      MOV     [R12], R4
  00E5AA: fc01      POP     DPP1
  00E5AC: fc00      POP     DPP0
  00E5AE: 06f00e00  ADD     R0, #0x000E
  00E5B2: 9890      MOV     R9, [R0+]
  00E5B4: 9880      MOV     R8, [R0+]
  00E5B6: 9870      MOV     R7, [R0+]
  00E5B8: 9860      MOV     R6, [R0+]
  00E5BA: db00      RETS

;==========================================================================
; flash_block_FCC00: flash 0FCC00-0FEBF9, runs at 0FCC00, 8186 bytes, 8142 bytes decoded
;==========================================================================
entry_0FCC00:
  0FCC00: 88c0      MOV     [-R0], R12
  0FCC02: 8860      MOV     [-R0], R6
  0FCC04: 8870      MOV     [-R0], R7
  0FCC06: 8880      MOV     [-R0], R8
  0FCC08: 8890      MOV     [-R0], R9
  0FCC0A: d4c00800  MOV     R12, [R0+#0x0008]
  0FCC0E: da002878  CALLS   0x007828    ; -> rom_7828
  0FCC12: e7f81200  MOVB    RL4, #0x12
  0FCC16: f7f8a6fc  MOVB    0xFCA6, RL4
  0FCC1A: f7f8a9fc  MOVB    0xFCA9, RL4
  0FCC1E: f3fab6fc  MOVB    RL5, 0xFCB6
  0FCC22: 47fa0900  CMPB    RL5, #0x09
  0FCC26: 3d06      JMPR    cc_NZ, 0x0FCC34
  0FCC28: e7f61200  MOVB    RL3, #0x12
  0FCC2C: f7f6a6fc  MOVB    0xFCA6, RL3
  0FCC30: f7f6a9fc  MOVB    0xFCA9, RL3
loc_0FCC34:
  0FCC34: ff24      BSET    0xFD48.15
  0FCC36: 2e25      BCLR    0xFD4A.2
  0FCC38: 7e25      BCLR    0xFD4A.7
  0FCC3A: e6f4cef9  MOV     R4, #0xF9CE
  0FCC3E: f6f4e6fa  MOV     0xFAE6, R4
  0FCC42: e017      MOV     R7, #1
  0FCC44: da007670  CALLS   0x007076    ; -> rom_7076
  0FCC48: e6fc00d0  MOV     R12, #0xD000
  0FCC4C: e6fdbc0d  MOV     R13, #0x0DBC
  0FCC50: e6fe3f00  MOV     R14, #0x003F
  0FCC54: e6ffffdb  MOV     R15, #0xDBFF
  0FCC58: da0f90eb  CALLS   0x0FEB90
  0FCC5C: e6fc00e0  MOV     R12, #0xE000
  0FCC60: e6fd0003  MOV     R13, #0x0300
  0FCC64: e6fe3f00  MOV     R14, #0x003F
  0FCC68: e6ffffe5  MOV     R15, #0xE5FF
  0FCC6C: da0f90eb  CALLS   0x0FEB90
  0FCC70: e014      MOV     R4, #1
  0FCC72: f6f408dc  MOV     0xDC08, R4
  0FCC76: da0f64e3  CALLS   0x0FE364
  0FCC7A: f3f8acfc  MOVB    RL4, 0xFCAC
  0FCC7E: 2d54      JMPR    cc_Z, 0x0FCD28
  0FCC80: f3fab7fc  MOVB    RL5, 0xFCB7
  0FCC84: 49a1      CMPB    RL5, #1
  0FCC86: 3d0f      JMPR    cc_NZ, 0x0FCCA6
  0FCC88: ae24      BCLR    0xFD48.10
  0FCC8A: f78e70fc  MOVB    0xFC70, ZEROS
  0FCC8E: e007      MOV     R7, #0
  0FCC90: e6f4c679  MOV     R4, #0x79C6
  0FCC94: e6f50000  MOV     R5, #0x0000
  0FCC98: d7500300  EXTP    #0x003, #2
  0FCC9C: f6f49a39  MOV     0x399A, R4
  0FCCA0: f6f59c39  MOV     0x399C, R5
  0FCCA4: 0d41      JMPR    cc_UC, 0x0FCD28
loc_0FCCA6:
  0FCCA6: 6eb7      BCLR    S0RIC.6
  0FCCA8: f68e00dc  MOV     0xDC00, ZEROS
  0FCCAC: af24      BSET    0xFD48.10
  0FCCAE: e7f81000  MOVB    RL4, #0x10
  0FCCB2: f7f873fc  MOVB    0xFC73, RL4
  0FCCB6: f7f872fc  MOVB    0xFC72, RL4
  0FCCBA: c2fc73fc  MOVBZ   R12, 0xFC73
  0FCCBE: da00e849  CALLS   0x0049E8    ; -> rom_49E8
  0FCCC2: f6f4b4fe  MOV     0xFEB4, R4
  0FCCC6: e6d86780  MOV     S0CON, #0x8067
  0FCCCA: f3f8b6fc  MOVB    RL4, 0xFCB6
  0FCCCE: 2d03      JMPR    cc_Z, 0x0FCCD6
  0FCCD0: 2e25      BCLR    0xFD4A.2
  0FCCD2: da00d84a  CALLS   0x004AD8    ; -> rom_4AD8
loc_0FCCD6:
  0FCCD6: e10c      MOVB    RL6, #0
loc_0FCCD8:
  0FCCD8: c0c4      MOVBZ   R4, RL6
  0FCCDA: f4a4acfc  MOVB    RL5, [R4+#0xFCAC]
  0FCCDE: c0c4      MOVBZ   R4, RL6
  0FCCE0: e4a44efb  MOVB    [R4+#0xFB4E], RL5
  0FCCE4: 09c1      ADDB    RL6, #1
  0FCCE6: 47fc0b00  CMPB    RL6, #0x0B
  0FCCEA: 8df6      JMPR    cc_C, 0x0FCCD8
  0FCCEC: f3f8adfc  MOVB    RL4, 0xFCAD
  0FCCF0: f7f89afc  MOVB    0xFC9A, RL4
  0FCCF4: f3faaefc  MOVB    RL5, 0xFCAE
  0FCCF8: f7fa9bfc  MOVB    0xFC9B, RL5
  0FCCFC: c2f49ffc  MOVBZ   R4, 0xFC9F
  0FCD00: f6f46cfc  MOV     0xFC6C, R4
  0FCD04: e118      MOVB    RL4, #1
  0FCD06: f7f87cfc  MOVB    0xFC7C, RL4
  0FCD0A: cf24      BSET    0xFD48.12
  0FCD0C: bf24      BSET    0xFD48.11
  0FCD0E: e7f6c800  MOVB    RL3, #0xC8
  0FCD12: f7f670fc  MOVB    0xFC70, RL3
  0FCD16: c2f44efb  MOVBZ   R4, 0xFB4E
  0FCD1A: 66f43f00  AND     R4, #0x003F
  0FCD1E: e6f553fb  MOV     R5, #0xFB53
  0FCD22: 0054      ADD     R5, R4
  0FCD24: f6f5fefc  MOV     0xFCFE, R5
loc_0FCD28:
  0FCD28: 4870      CMP     R7, #0
  0FCD2A: 2d42      JMPR    cc_Z, 0x0FCDB0
  0FCD2C: e6f4bccd  MOV     R4, #0xCDBC
  0FCD30: e6f50f00  MOV     R5, #0x000F
  0FCD34: e6f800d0  MOV     R8, #0xD000
  0FCD38: e009      MOV     R9, #0
  0FCD3A: 2084      SUB     R8, R4
  0FCD3C: 3095      SUBC    R9, R5
  0FCD3E: e6f400d0  MOV     R4, #0xD000
  0FCD42: e005      MOV     R5, #0
  0FCD44: d7500300  EXTP    #0x003, #2
  0FCD48: f6f49a39  MOV     0x399A, R4
  0FCD4C: f6f59c39  MOV     0x399C, R5
  0FCD50: e6f4a2ce  MOV     R4, #0xCEA2
  0FCD54: e6f50f00  MOV     R5, #0x000F
  0FCD58: 0048      ADD     R4, R8
  0FCD5A: 1059      ADDC    R5, R9
  0FCD5C: d7500300  EXTP    #0x003, #2
  0FCD60: f6f4941c  MOV     0x1C94, R4
  0FCD64: f6f5961c  MOV     0x1C96, R5
  0FCD68: e6f4d4cf  MOV     R4, #0xCFD4
  0FCD6C: e6f50f00  MOV     R5, #0x000F
  0FCD70: 0048      ADD     R4, R8
  0FCD72: 1059      ADDC    R5, R9
  0FCD74: d7500300  EXTP    #0x003, #2
  0FCD78: f6f4981c  MOV     0x1C98, R4
  0FCD7C: f6f59a1c  MOV     0x1C9A, R5
  0FCD80: e6f4c6d0  MOV     R4, #0xD0C6
  0FCD84: e6f50f00  MOV     R5, #0x000F
  0FCD88: 0048      ADD     R4, R8
  0FCD8A: 1059      ADDC    R5, R9
  0FCD8C: d7500300  EXTP    #0x003, #2
  0FCD90: f6f49c1c  MOV     0x1C9C, R4
  0FCD94: f6f59e1c  MOV     0x1C9E, R5
  0FCD98: e6f43cd1  MOV     R4, #0xD13C
  0FCD9C: e6f50f00  MOV     R5, #0x000F
  0FCDA0: 0048      ADD     R4, R8
  0FCDA2: 1059      ADDC    R5, R9
  0FCDA4: d7500300  EXTP    #0x003, #2
  0FCDA8: f6f4a01c  MOV     0x1CA0, R4
  0FCDAC: f6f5a21c  MOV     0x1CA2, R5
loc_0FCDB0:
  0FCDB0: 9890      MOV     R9, [R0+]
  0FCDB2: 9880      MOV     R8, [R0+]
  0FCDB4: 9870      MOV     R7, [R0+]
  0FCDB6: 9860      MOV     R6, [R0+]
  0FCDB8: 0802      ADD     R0, #2
  0FCDBA: db00      RETS
loc_0FCDBC:
  0FCDBC: 6f25      BSET    0xFD4A.6
  0FCDBE: f2f46efc  MOV     R4, 0xFC6E
  0FCDC2: 2d03      JMPR    cc_Z, 0x0FCDCA
  0FCDC4: 2841      SUB     R4, #1
  0FCDC6: f6f46efc  MOV     0xFC6E, R4
loc_0FCDCA:
  0FCDCA: 9a2420a0  JNB     0xFD48.10, 0x0FCE0E
  0FCDCE: c2f470fc  MOVBZ   R4, 0xFC70
  0FCDD2: 46f4be00  CMP     R4, #0x00BE
  0FCDD6: cd05      JMPR    cc_SLT, 0x0FCDE2
  0FCDD8: c2f470fc  MOVBZ   R4, 0xFC70
  0FCDDC: 46f4fa00  CMP     R4, #0x00FA
  0FCDE0: bd04      JMPR    cc_SLE, 0x0FCDEA
loc_0FCDE2:
  0FCDE2: ae24      BCLR    0xFD48.10
  0FCDE4: f78e70fc  MOVB    0xFC70, ZEROS
  0FCDE8: 0d12      JMPR    cc_UC, 0x0FCE0E
loc_0FCDEA:
  0FCDEA: da0f8ad7  CALLS   0x0FD78A
  0FCDEE: d7500300  EXTP    #0x003, #2
  0FCDF2: f2f4941c  MOV     R4, 0x1C94
  0FCDF6: f2f5961c  MOV     R5, 0x1C96
  0FCDFA: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
  0FCDFE: d7500300  EXTP    #0x003, #2
  0FCE02: f2f4981c  MOV     R4, 0x1C98
  0FCE06: f2f59a1c  MOV     R5, 0x1C9A
  0FCE0A: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
loc_0FCE0E:
  0FCE0E: f3f870fc  MOVB    RL4, 0xFC70
  0FCE12: 3d3b      JMPR    cc_NZ, 0x0FCE8A
  0FCE14: 9a253990  JNB     0xFD4A.9, 0x0FCE8A
  0FCE18: d7500100  EXTP    #0x001, #2
  0FCE1C: f2f4d437  MOV     R4, 0x37D4
  0FCE20: f2f5d637  MOV     R5, 0x37D6
  0FCE24: f6f500fe  MOV     0xFE00, R5
  0FCE28: cc00      NOP
  0FCE2A: a824      MOV     R2, [R4]
  0FCE2C: 6821      AND     R2, #1
  0FCE2E: b824      MOV     [R4], R2
  0FCE30: e6003c00  MOV     DPP0, #0x003C
  0FCE34: d7500100  EXTP    #0x001, #2
  0FCE38: f2f4e437  MOV     R4, 0x37E4
  0FCE3C: f2f5e637  MOV     R5, 0x37E6
  0FCE40: f6f500fe  MOV     0xFE00, R5
  0FCE44: cc00      NOP
  0FCE46: a824      MOV     R2, [R4]
  0FCE48: 6821      AND     R2, #1
  0FCE4A: b824      MOV     [R4], R2
  0FCE4C: e6003c00  MOV     DPP0, #0x003C
  0FCE50: d7500100  EXTP    #0x001, #2
  0FCE54: f2f4f437  MOV     R4, 0x37F4
  0FCE58: f2f5f637  MOV     R5, 0x37F6
  0FCE5C: f6f500fe  MOV     0xFE00, R5
  0FCE60: cc00      NOP
  0FCE62: a824      MOV     R2, [R4]
  0FCE64: 6821      AND     R2, #1
  0FCE66: b824      MOV     [R4], R2
  0FCE68: e6003c00  MOV     DPP0, #0x003C
  0FCE6C: d7500100  EXTP    #0x001, #2
  0FCE70: f2f40438  MOV     R4, 0x3804
  0FCE74: f2f50638  MOV     R5, 0x3806
  0FCE78: f6f500fe  MOV     0xFE00, R5
  0FCE7C: cc00      NOP
  0FCE7E: a824      MOV     R2, [R4]
  0FCE80: 6821      AND     R2, #1
  0FCE82: b824      MOV     [R4], R2
  0FCE84: e6003c00  MOV     DPP0, #0x003C
  0FCE88: cc00      NOP
loc_0FCE8A:
  0FCE8A: 8a2402a0  JB      0xFD48.10, 0x0FCE92
  0FCE8E: da0fced5  CALLS   0x0FD5CE
loc_0FCE92:
  0FCE92: da009c79  CALLS   0x00799C    ; -> rom_799C
  0FCE96: 2a2425e0  BCMP    0xFD4A.0, 0xFD48.14
  0FCE9A: 9d02      JMPR    cc_NC, 0x0FCEA0
  0FCE9C: da0fd4e6  CALLS   0x0FE6D4
loc_0FCEA0:
  0FCEA0: db00      RETS
loc_0FCEA2:
  0FCEA2: 8860      MOV     [-R0], R6
  0FCEA4: e10c      MOVB    RL6, #0
  0FCEA6: f3f870fc  MOVB    RL4, 0xFC70
  0FCEAA: 47f8dc00  CMPB    RL4, #0xDC
  0FCEAE: 3d3d      JMPR    cc_NZ, 0x0FCF2A
  0FCEB0: df24      BSET    0xFD48.13
  0FCEB2: f3f89dfc  MOVB    RL4, 0xFC9D
  0FCEB6: 47f83e00  CMPB    RL4, #0x3E
  0FCEBA: 2d19      JMPR    cc_Z, 0x0FCEEE
  0FCEBC: 47f81000  CMPB    RL4, #0x10
  0FCEC0: 2d19      JMPR    cc_Z, 0x0FCEF4
  0FCEC2: 47f83100  CMPB    RL4, #0x31
  0FCEC6: 2d19      JMPR    cc_Z, 0x0FCEFA
  0FCEC8: 47f83200  CMPB    RL4, #0x32
  0FCECC: 2d19      JMPR    cc_Z, 0x0FCF00
  0FCECE: 47f83300  CMPB    RL4, #0x33
  0FCED2: 2d19      JMPR    cc_Z, 0x0FCF06
  0FCED4: 47f83400  CMPB    RL4, #0x34
  0FCED8: 2d19      JMPR    cc_Z, 0x0FCF0C
  0FCEDA: 47f83600  CMPB    RL4, #0x36
  0FCEDE: 2d19      JMPR    cc_Z, 0x0FCF12
  0FCEE0: 47f83700  CMPB    RL4, #0x37
  0FCEE4: 2d19      JMPR    cc_Z, 0x0FCF18
  0FCEE6: 47f8a200  CMPB    RL4, #0xA2
  0FCEEA: 2d1b      JMPR    cc_Z, 0x0FCF22
  0FCEEC: 0d1d      JMPR    cc_UC, 0x0FCF28
loc_0FCEEE:
  0FCEEE: da001e58  CALLS   0x00581E    ; -> rom_581E
  0FCEF2: 0d1b      JMPR    cc_UC, 0x0FCF2A
loc_0FCEF4:
  0FCEF4: da0f50d9  CALLS   0x0FD950
  0FCEF8: 0d18      JMPR    cc_UC, 0x0FCF2A
loc_0FCEFA:
  0FCEFA: da0f5ad3  CALLS   0x0FD35A
  0FCEFE: 0d15      JMPR    cc_UC, 0x0FCF2A
loc_0FCF00:
  0FCF00: da00f25f  CALLS   0x005FF2    ; -> rom_5FF2
  0FCF04: 0d12      JMPR    cc_UC, 0x0FCF2A
loc_0FCF06:
  0FCF06: da000c61  CALLS   0x00610C    ; -> rom_610C
  0FCF0A: 0d0f      JMPR    cc_UC, 0x0FCF2A
loc_0FCF0C:
  0FCF0C: da0f28dc  CALLS   0x0FDC28
  0FCF10: 0d0c      JMPR    cc_UC, 0x0FCF2A
loc_0FCF12:
  0FCF12: da0f20df  CALLS   0x0FDF20
  0FCF16: 0d09      JMPR    cc_UC, 0x0FCF2A
loc_0FCF18:
  0FCF18: da0f64e3  CALLS   0x0FE364
  0FCF1C: da007266  CALLS   0x006672    ; -> rom_6672
  0FCF20: 0d04      JMPR    cc_UC, 0x0FCF2A
loc_0FCF22:
  0FCF22: da0f6add  CALLS   0x0FDD6A
  0FCF26: 0d01      JMPR    cc_UC, 0x0FCF2A
loc_0FCF28:
  0FCF28: e11c      MOVB    RL6, #1
loc_0FCF2A:
  0FCF2A: 49c0      CMPB    RL6, #0
  0FCF2C: 2d3d      JMPR    cc_Z, 0x0FCFA8
  0FCF2E: f3f89dfc  MOVB    RL4, 0xFC9D
  0FCF32: 47f88200  CMPB    RL4, #0x82
  0FCF36: 2d19      JMPR    cc_Z, 0x0FCF6A
  0FCF38: 47f88300  CMPB    RL4, #0x83
  0FCF3C: 2d19      JMPR    cc_Z, 0x0FCF70
  0FCF3E: 47f82700  CMPB    RL4, #0x27
  0FCF42: 2d19      JMPR    cc_Z, 0x0FCF76
  0FCF44: 47f81a00  CMPB    RL4, #0x1A
  0FCF48: 2d19      JMPR    cc_Z, 0x0FCF7C
  0FCF4A: 47f82100  CMPB    RL4, #0x21
  0FCF4E: 2d19      JMPR    cc_Z, 0x0FCF82
  0FCF50: 47f83b00  CMPB    RL4, #0x3B
  0FCF54: 2d19      JMPR    cc_Z, 0x0FCF88
  0FCF56: 47f83000  CMPB    RL4, #0x30
  0FCF5A: 2d19      JMPR    cc_Z, 0x0FCF8E
  0FCF5C: 47f82300  CMPB    RL4, #0x23
  0FCF60: 2d19      JMPR    cc_Z, 0x0FCF94
  0FCF62: 47f83100  CMPB    RL4, #0x31
  0FCF66: 2d19      JMPR    cc_Z, 0x0FCF9A
  0FCF68: 0d1b      JMPR    cc_UC, 0x0FCFA0
loc_0FCF6A:
  0FCF6A: da007046  CALLS   0x004670    ; -> rom_4670
  0FCF6E: 0d1c      JMPR    cc_UC, 0x0FCFA8
loc_0FCF70:
  0FCF70: da008646  CALLS   0x004686    ; -> rom_4686
  0FCF74: 0d19      JMPR    cc_UC, 0x0FCFA8
loc_0FCF76:
  0FCF76: da0f24da  CALLS   0x0FDA24
  0FCF7A: 0d16      JMPR    cc_UC, 0x0FCFA8
loc_0FCF7C:
  0FCF7C: da0f6add  CALLS   0x0FDD6A
  0FCF80: 0d13      JMPR    cc_UC, 0x0FCFA8
loc_0FCF82:
  0FCF82: da0fe0dd  CALLS   0x0FDDE0
  0FCF86: 0d10      JMPR    cc_UC, 0x0FCFA8
loc_0FCF88:
  0FCF88: da00344e  CALLS   0x004E34    ; -> rom_4E34
  0FCF8C: 0d0d      JMPR    cc_UC, 0x0FCFA8
loc_0FCF8E:
  0FCF8E: da0fd2e1  CALLS   0x0FE1D2
  0FCF92: 0d0a      JMPR    cc_UC, 0x0FCFA8
loc_0FCF94:
  0FCF94: da0f2ae2  CALLS   0x0FE22A
  0FCF98: 0d07      JMPR    cc_UC, 0x0FCFA8
loc_0FCF9A:
  0FCF9A: da0f5ad3  CALLS   0x0FD35A
  0FCF9E: 0d04      JMPR    cc_UC, 0x0FCFA8
loc_0FCFA0:
  0FCFA0: e6fc1100  MOV     R12, #0x0011
  0FCFA4: da0faceb  CALLS   0x0FEBAC
loc_0FCFA8:
  0FCFA8: c2f470fc  MOVBZ   R4, 0xFC70
  0FCFAC: 46f4dc00  CMP     R4, #0x00DC
  0FCFB0: 3d0f      JMPR    cc_NZ, 0x0FCFD0
  0FCFB2: f3f87cfc  MOVB    RL4, 0xFC7C
  0FCFB6: 4980      CMPB    RL4, #0
  0FCFB8: fd05      JMPR    cc_ULE, 0x0FCFC4
  0FCFBA: 9a2409d0  JNB     0xFD48.13, 0x0FCFD0
  0FCFBE: da0f00d7  CALLS   0x0FD700
  0FCFC2: 0d06      JMPR    cc_UC, 0x0FCFD0
loc_0FCFC4:
  0FCFC4: e7f8c800  MOVB    RL4, #0xC8
  0FCFC8: f7f870fc  MOVB    0xFC70, RL4
  0FCFCC: da0f4cd8  CALLS   0x0FD84C
loc_0FCFD0:
  0FCFD0: 9860      MOV     R6, [R0+]
  0FCFD2: db00      RETS
loc_0FCFD4:
  0FCFD4: 8860      MOV     [-R0], R6
  0FCFD6: f3fc70fc  MOVB    RL6, 0xFC70
  0FCFDA: c0c4      MOVBZ   R4, RL6
  0FCFDC: 46f4f000  CMP     R4, #0x00F0
  0FCFE0: 3d26      JMPR    cc_NZ, 0x0FD02E
  0FCFE2: c2f49ffc  MOVBZ   R4, 0xFC9F
  0FCFE6: 42f46cfc  CMP     R4, 0xFC6C
  0FCFEA: fd06      JMPR    cc_ULE, 0x0FCFF8
  0FCFEC: 9ab71f70  JNB     S0RIC.7, 0x0FD02E
  0FCFF0: 7eb7      BCLR    S0RIC.7
  0FCFF2: f68e6cfc  MOV     0xFC6C, ZEROS
  0FCFF6: 0d1b      JMPR    cc_UC, 0x0FD02E
loc_0FCFF8:
  0FCFF8: c2f473fc  MOVBZ   R4, 0xFC73
  0FCFFC: 46f41000  CMP     R4, #0x0010
  0FD000: dd02      JMPR    cc_SGE, 0x0FD006
  0FD002: 8a2408f0  JB      0xFD48.15, 0x0FD016
loc_0FD006:
  0FD006: e01c      MOV     R12, #1
  0FD008: da0fc2d8  CALLS   0x0FD8C2
  0FD00C: e7f8fa00  MOVB    RL4, #0xFA
  0FD010: f7f870fc  MOVB    0xFC70, RL4
  0FD014: 0d0c      JMPR    cc_UC, 0x0FD02E
loc_0FD016:
  0FD016: e00c      MOV     R12, #0
  0FD018: da0fc2d8  CALLS   0x0FD8C2
  0FD01C: 4980      CMPB    RL4, #0
  0FD01E: 2d05      JMPR    cc_Z, 0x0FD02A
  0FD020: e7f8fa00  MOVB    RL4, #0xFA
  0FD024: f7f870fc  MOVB    0xFC70, RL4
  0FD028: 0d02      JMPR    cc_UC, 0x0FD02E
loc_0FD02A:
  0FD02A: f68e6cfc  MOV     0xFC6C, ZEROS
loc_0FD02E:
  0FD02E: c0c4      MOVBZ   R4, RL6
  0FD030: 46f4fa00  CMP     R4, #0x00FA
  0FD034: 3d46      JMPR    cc_NZ, 0x0FD0C2
  0FD036: f68e6cfc  MOV     0xFC6C, ZEROS
  0FD03A: f2f4fcfc  MOV     R4, 0xFCFC
  0FD03E: 42f46afc  CMP     R4, 0xFC6A
  0FD042: fd17      JMPR    cc_ULE, 0x0FD072
  0FD044: 9ab73d70  JNB     S0RIC.7, 0x0FD0C2
  0FD048: 6eb6      BCLR    S0TIC.6
  0FD04A: 058f7cfc  ADDB    0xFC7C, ONES
  0FD04E: f3f87cfc  MOVB    RL4, 0xFC7C
  0FD052: 3d08      JMPR    cc_NZ, 0x0FD064
  0FD054: ef24      BSET    0xFD48.14
  0FD056: e7fac800  MOVB    RL5, #0xC8
  0FD05A: f7fa70fc  MOVB    0xFC70, RL5
  0FD05E: da0f4cd8  CALLS   0x0FD84C
  0FD062: 0d2f      JMPR    cc_UC, 0x0FD0C2
loc_0FD064:
  0FD064: f68e6cfc  MOV     0xFC6C, ZEROS
  0FD068: e7f8dc00  MOVB    RL4, #0xDC
  0FD06C: f7f870fc  MOVB    0xFC70, RL4
  0FD070: 0d28      JMPR    cc_UC, 0x0FD0C2
loc_0FD072:
  0FD072: 8a252350  JB      0xFD4A.5, 0x0FD0BC
  0FD076: 9ab72470  JNB     S0RIC.7, 0x0FD0C2
  0FD07A: f2f4fcfc  MOV     R4, 0xFCFC
  0FD07E: 2841      SUB     R4, #1
  0FD080: a9a4      MOVB    RL5, [R4]
  0FD082: c0a4      MOVBZ   R4, RL5
  0FD084: 42f4b2fe  CMP     R4, 0xFEB2
  0FD088: 3d0a      JMPR    cc_NZ, 0x0FD09E
  0FD08A: 7eb7      BCLR    S0RIC.7
  0FD08C: f2f4fcfc  MOV     R4, 0xFCFC
  0FD090: 248ffcfc  SUB     0xFCFC, ONES
  0FD094: a9a4      MOVB    RL5, [R4]
  0FD096: c0a4      MOVBZ   R4, RL5
  0FD098: f6f4b0fe  MOV     0xFEB0, R4
  0FD09C: 0d12      JMPR    cc_UC, 0x0FD0C2
loc_0FD09E:
  0FD09E: c2fc73fc  MOVBZ   R12, 0xFC73
  0FD0A2: da00e849  CALLS   0x0049E8    ; -> rom_49E8
  0FD0A6: f6f4b4fe  MOV     0xFEB4, R4
  0FD0AA: f2f47afc  MOV     R4, 0xFC7A
  0FD0AE: f6f4fcfc  MOV     0xFCFC, R4
  0FD0B2: e7f8f000  MOVB    RL4, #0xF0
  0FD0B6: f7f870fc  MOVB    0xFC70, RL4
  0FD0BA: 0d03      JMPR    cc_UC, 0x0FD0C2
loc_0FD0BC:
  0FD0BC: e01c      MOV     R12, #1
  0FD0BE: da005849  CALLS   0x004958    ; -> rom_4958
loc_0FD0C2:
  0FD0C2: 9860      MOV     R6, [R0+]
  0FD0C4: db00      RETS
loc_0FD0C6:
  0FD0C6: 8880      MOV     [-R0], R8
  0FD0C8: 8890      MOV     [-R0], R9
  0FD0CA: d7500100  EXTP    #0x001, #2
  0FD0CE: f2f8d437  MOV     R8, 0x37D4
  0FD0D2: f2f9d637  MOV     R9, 0x37D6
  0FD0D6: dc49      EXTP    R9, #1
  0FD0D8: a848      MOV     R4, [R8]
  0FD0DA: 0af40202  BFLDL   R4, #0x02, #0x02
  0FD0DE: dc59      EXTP    R9, #2
  0FD0E0: b848      MOV     [R8], R4
  0FD0E2: a848      MOV     R4, [R8]
  0FD0E4: 0af40808  BFLDL   R4, #0x08, #0x08
  0FD0E8: dc49      EXTP    R9, #1
  0FD0EA: b848      MOV     [R8], R4
  0FD0EC: 0d12      JMPR    cc_UC, 0x0FD112
loc_0FD0EE:
  0FD0EE: a758a7a7  SRVWDT
  0FD0F2: f0c8      MOV     R12, R8
  0FD0F4: f0d9      MOV     R13, R9
  0FD0F6: f2f4e8fa  MOV     R4, 0xFAE8
  0FD0FA: f2f5eafa  MOV     R5, 0xFAEA
  0FD0FE: f0a4      MOV     R10, R4
  0FD100: f0b5      MOV     R11, R5
  0FD102: dc6b      EXTP    R11, #3
  0FD104: d44a0a00  MOV     R4, [R10+#0x000A]
  0FD108: d45a0c00  MOV     R5, [R10+#0x000C]
  0FD10C: cc00      NOP
  0FD10E: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
loc_0FD112:
  0FD112: dc49      EXTP    R9, #1
  0FD114: a848      MOV     R4, [R8]
  0FD116: 7c54      SHR     R4, #5
  0FD118: 6841      AND     R4, #1
  0FD11A: 9af40200  JNB     R4.0, 0x0FD122
  0FD11E: 76f4feff  OR      R4, #0xFFFE
loc_0FD122:
  0FD122: dc49      EXTP    R9, #1
  0FD124: a858      MOV     R5, [R8]
  0FD126: 7c75      SHR     R5, #7
  0FD128: 6851      AND     R5, #1
  0FD12A: 9af50200  JNB     R5.0, 0x0FD132
  0FD12E: 76f5feff  OR      R5, #0xFFFE
loc_0FD132:
  0FD132: 7045      OR      R4, R5
  0FD134: 2ddc      JMPR    cc_Z, 0x0FD0EE
  0FD136: 9890      MOV     R9, [R0+]
  0FD138: 9880      MOV     R8, [R0+]
  0FD13A: db00      RETS
loc_0FD13C:
  0FD13C: 88e0      MOV     [-R0], R14
  0FD13E: 88d0      MOV     [-R0], R13
  0FD140: 88c0      MOV     [-R0], R12
  0FD142: 8860      MOV     [-R0], R6
  0FD144: 8870      MOV     [-R0], R7
  0FD146: 8880      MOV     [-R0], R8
  0FD148: 8890      MOV     [-R0], R9
  0FD14A: 26f00800  SUB     R0, #0x0008
  0FD14E: d4401600  MOV     R4, [R0+#0x0016]
  0FD152: d4501800  MOV     R5, [R0+#0x0018]
  0FD156: f0a4      MOV     R10, R4
  0FD158: f0b5      MOV     R11, R5
  0FD15A: 5ceb      SHL     R11, #14
  0FD15C: 70ab      OR      R10, R11
  0FD15E: f0b5      MOV     R11, R5
  0FD160: 7c2b      SHR     R11, #2
  0FD162: b8a0      MOV     [R0], R10
  0FD164: c4b00200  MOV     [R0+#0x0002], R11
  0FD168: e10c      MOVB    RL6, #0
  0FD16A: d7500100  EXTP    #0x001, #2
  0FD16E: f2f8e437  MOV     R8, 0x37E4
  0FD172: f2f9e637  MOV     R9, 0x37E6
  0FD176: dc49      EXTP    R9, #1
  0FD178: a828      MOV     R2, [R8]
  0FD17A: 7c12      SHR     R2, #1
  0FD17C: 6821      AND     R2, #1
  0FD17E: 9af20200  JNB     R2.0, 0x0FD186
  0FD182: 76f2feff  OR      R2, #0xFFFE
loc_0FD186:
  0FD186: 4820      CMP     R2, #0
  0FD188: ea30ccd2  JMPA    cc_NZ, 0x0FD2CC
  0FD18C: e11c      MOVB    RL6, #1
  0FD18E: d7500100  EXTP    #0x001, #2
  0FD192: f2f4e437  MOV     R4, 0x37E4
  0FD196: f2f5e637  MOV     R5, 0x37E6
  0FD19A: f6f500fe  MOV     0xFE00, R5
  0FD19E: cc00      NOP
  0FD1A0: a824      MOV     R2, [R4]
  0FD1A2: 6821      AND     R2, #1
  0FD1A4: b824      MOV     [R4], R2
  0FD1A6: e6003c00  MOV     DPP0, #0x003C
  0FD1AA: cc00      NOP
  0FD1AC: a840      MOV     R4, [R0]
  0FD1AE: d4500200  MOV     R5, [R0+#0x0002]
  0FD1B2: 6841      AND     R4, #1
  0FD1B4: 6850      AND     R5, #0
  0FD1B6: e4800600  MOVB    [R0+#0x0006], RL4
  0FD1BA: c084      MOVBZ   R4, RL4
  0FD1BC: f2fce6fa  MOV     R12, 0xFAE6
  0FD1C0: 00c4      ADD     R12, R4
  0FD1C2: 08c6      ADD     R12, #6
  0FD1C4: d4d01000  MOV     R13, [R0+#0x0010]
  0FD1C8: d4e01200  MOV     R14, [R0+#0x0012]
  0FD1CC: f4801400  MOVB    RL4, [R0+#0x0014]
  0FD1D0: c084      MOVBZ   R4, RL4
  0FD1D2: f4a00600  MOVB    RL5, [R0+#0x0006]
  0FD1D6: c0a5      MOVBZ   R5, RL5
  0FD1D8: 0045      ADD     R4, R5
  0FD1DA: f2ffe6fa  MOV     R15, 0xFAE6
  0FD1DE: 00f4      ADD     R15, R4
  0FD1E0: 08f6      ADD     R15, #6
  0FD1E2: da0f90eb  CALLS   0x0FEB90
  0FD1E6: dc49      EXTP    R9, #1
  0FD1E8: a848      MOV     R4, [R8]
  0FD1EA: 1af40202  BFLDH   R4, #0x02, #0x02
  0FD1EE: dc49      EXTP    R9, #1
  0FD1F0: b848      MOV     [R8], R4
  0FD1F2: f4800600  MOVB    RL4, [R0+#0x0006]
  0FD1F6: 2d1f      JMPR    cc_Z, 0x0FD236
  0FD1F8: a840      MOV     R4, [R0]
  0FD1FA: d4500200  MOV     R5, [R0+#0x0002]
  0FD1FE: 2841      SUB     R4, #1
  0FD200: 3850      SUBC    R5, #0
  0FD202: 8840      MOV     [-R0], R4
  0FD204: 7ce4      SHR     R4, #14
  0FD206: 5c25      SHL     R5, #2
  0FD208: 7054      OR      R5, R4
  0FD20A: 9840      MOV     R4, [R0+]
  0FD20C: 66f4ff3f  AND     R4, #0x3FFF
  0FD210: dc45      EXTP    R5, #1
  0FD212: a9e4      MOVB    RL7, [R4]
  0FD214: f2f4e6fa  MOV     R4, 0xFAE6
  0FD218: e4e40600  MOVB    [R4+#0x0006], RL7
  0FD21C: f4801400  MOVB    RL4, [R0+#0x0014]
  0FD220: 0981      ADDB    RL4, #1
  0FD222: e4801400  MOVB    [R0+#0x0014], RL4
  0FD226: a840      MOV     R4, [R0]
  0FD228: d4500200  MOV     R5, [R0+#0x0002]
  0FD22C: 2841      SUB     R4, #1
  0FD22E: 3850      SUBC    R5, #0
  0FD230: b840      MOV     [R0], R4
  0FD232: c4500200  MOV     [R0+#0x0002], R5
loc_0FD236:
  0FD236: f4801400  MOVB    RL4, [R0+#0x0014]
  0FD23A: 6981      ANDB    RL4, #1
  0FD23C: 2d1d      JMPR    cc_Z, 0x0FD278
  0FD23E: f4801400  MOVB    RL4, [R0+#0x0014]
  0FD242: 0981      ADDB    RL4, #1
  0FD244: e4801400  MOVB    [R0+#0x0014], RL4
  0FD248: a840      MOV     R4, [R0]
  0FD24A: d4500200  MOV     R5, [R0+#0x0002]
  0FD24E: f4601400  MOVB    RL3, [R0+#0x0014]
  0FD252: c06a      MOVBZ   R10, RL3
  0FD254: e00b      MOV     R11, #0
  0FD256: 004a      ADD     R4, R10
  0FD258: 105b      ADDC    R5, R11
  0FD25A: 8840      MOV     [-R0], R4
  0FD25C: 7ce4      SHR     R4, #14
  0FD25E: 5c25      SHL     R5, #2
  0FD260: 7054      OR      R5, R4
  0FD262: 9840      MOV     R4, [R0+]
  0FD264: 66f4ff3f  AND     R4, #0x3FFF
  0FD268: dc45      EXTP    R5, #1
  0FD26A: a9e4      MOVB    RL7, [R4]
  0FD26C: c064      MOVBZ   R4, RL3
  0FD26E: f2f5e6fa  MOV     R5, 0xFAE6
  0FD272: 0054      ADD     R5, R4
  0FD274: e4e50500  MOVB    [R5+#0x0005], RL7
loc_0FD278:
  0FD278: ef24      BSET    0xFD48.14
  0FD27A: e7f86000  MOVB    RL4, #0x60
  0FD27E: f7f8bcf9  MOVB    0xF9BC, RL4
  0FD282: f4a00200  MOVB    RL5, [R0+#0x0002]
  0FD286: f2f4e6fa  MOV     R4, 0xFAE6
  0FD28A: b9a4      MOVB    [R4], RL5
  0FD28C: f4800100  MOVB    RL4, [R0+#0x0001]
  0FD290: f2f5e6fa  MOV     R5, 0xFAE6
  0FD294: e4850100  MOVB    [R5+#0x0001], RL4
  0FD298: a980      MOVB    RL4, [R0]
  0FD29A: f2f5e6fa  MOV     R5, 0xFAE6
  0FD29E: e4850200  MOVB    [R5+#0x0002], RL4
  0FD2A2: f78ebef9  MOVB    0xF9BE, ZEROS
  0FD2A6: f78ebff9  MOVB    0xF9BF, ZEROS
  0FD2AA: f78ec0f9  MOVB    0xF9C0, ZEROS
  0FD2AE: f4801400  MOVB    RL4, [R0+#0x0014]
  0FD2B2: f7f8c1f9  MOVB    0xF9C1, RL4
  0FD2B6: f4a01400  MOVB    RL5, [R0+#0x0014]
  0FD2BA: f2f4e6fa  MOV     R4, 0xFAE6
  0FD2BE: e4a40300  MOVB    [R4+#0x0003], RL5
  0FD2C2: e108      MOVB    RL4, #0
  0FD2C4: f2f5e6fa  MOV     R5, 0xFAE6
  0FD2C8: e4850400  MOVB    [R5+#0x0004], RL4
loc_0FD2CC:
  0FD2CC: 49c0      CMPB    RL6, #0
  0FD2CE: 2d3c      JMPR    cc_Z, 0x0FD348
  0FD2D0: dc49      EXTP    R9, #1
  0FD2D2: a848      MOV     R4, [R8]
  0FD2D4: 0af40202  BFLDL   R4, #0x02, #0x02
  0FD2D8: dc49      EXTP    R9, #1
  0FD2DA: b848      MOV     [R8], R4
  0FD2DC: 0d07      JMPR    cc_UC, 0x0FD2EC
loc_0FD2DE:
  0FD2DE: ecf9      PUSH    R9
  0FD2E0: e009      MOV     R9, #0
  0FD2E2: a758a7a7  SRVWDT
  0FD2E6: da00d267  CALLS   0x0067D2    ; -> rom_67D2
  0FD2EA: fcf9      POP     R9
loc_0FD2EC:
  0FD2EC: dc49      EXTP    R9, #1
  0FD2EE: a848      MOV     R4, [R8]
  0FD2F0: 7c74      SHR     R4, #7
  0FD2F2: 6841      AND     R4, #1
  0FD2F4: 9af40200  JNB     R4.0, 0x0FD2FC
  0FD2F8: 76f4feff  OR      R4, #0xFFFE
loc_0FD2FC:
  0FD2FC: dc49      EXTP    R9, #1
  0FD2FE: a858      MOV     R5, [R8]
  0FD300: 7c55      SHR     R5, #5
  0FD302: 6851      AND     R5, #1
  0FD304: 9af50200  JNB     R5.0, 0x0FD30C
  0FD308: 76f5feff  OR      R5, #0xFFFE
loc_0FD30C:
  0FD30C: 7045      OR      R4, R5
  0FD30E: 2de7      JMPR    cc_Z, 0x0FD2DE
  0FD310: dc49      EXTP    R9, #1
  0FD312: a848      MOV     R4, [R8]
  0FD314: 7c74      SHR     R4, #7
  0FD316: 6841      AND     R4, #1
  0FD318: 9af40200  JNB     R4.0, 0x0FD320
  0FD31C: 76f4feff  OR      R4, #0xFFFE
loc_0FD320:
  0FD320: 4840      CMP     R4, #0
  0FD322: 3d02      JMPR    cc_NZ, 0x0FD328
  0FD324: e11c      MOVB    RL6, #1
  0FD326: 0d01      JMPR    cc_UC, 0x0FD32A
loc_0FD328:
  0FD328: e10c      MOVB    RL6, #0
loc_0FD32A:
  0FD32A: d7500100  EXTP    #0x001, #2
  0FD32E: f2f4e437  MOV     R4, 0x37E4
  0FD332: f2f5e637  MOV     R5, 0x37E6
  0FD336: f6f500fe  MOV     0xFE00, R5
  0FD33A: cc00      NOP
  0FD33C: a824      MOV     R2, [R4]
  0FD33E: 6821      AND     R2, #1
  0FD340: b824      MOV     [R4], R2
  0FD342: e6003c00  MOV     DPP0, #0x003C
  0FD346: cc00      NOP
loc_0FD348:
  0FD348: f18c      MOVB    RL4, RL6
  0FD34A: 06f00800  ADD     R0, #0x0008
  0FD34E: 9890      MOV     R9, [R0+]
  0FD350: 9880      MOV     R8, [R0+]
  0FD352: 9870      MOV     R7, [R0+]
  0FD354: 9860      MOV     R6, [R0+]
  0FD356: 0806      ADD     R0, #6
  0FD358: db00      RETS
loc_0FD35A:
  0FD35A: 8860      MOV     [-R0], R6
  0FD35C: 8880      MOV     [-R0], R8
  0FD35E: 8890      MOV     [-R0], R9
  0FD360: 2802      SUB     R0, #2
  0FD362: f2f878fc  MOV     R8, 0xFC78
  0FD366: e6f952fb  MOV     R9, #0xFB52
  0FD36A: d7500100  EXTP    #0x001, #2
  0FD36E: f2f4d437  MOV     R4, 0x37D4
  0FD372: f2f5d637  MOV     R5, 0x37D6
  0FD376: dc45      EXTP    R5, #1
  0FD378: a824      MOV     R2, [R4]
  0FD37A: b820      MOV     [R0], R2
  0FD37C: e10c      MOVB    RL6, #0
  0FD37E: f4880100  MOVB    RL4, [R8+#0x0001]
  0FD382: 4982      CMPB    RL4, #2
  0FD384: 2d05      JMPR    cc_Z, 0x0FD390
  0FD386: 4981      CMPB    RL4, #1
  0FD388: ea208cd5  JMPA    cc_Z, 0x0FD58C
  0FD38C: ea00bcd5  JMPA    cc_UC, 0x0FD5BC
loc_0FD390:
  0FD390: a840      MOV     R4, [R0]
  0FD392: 6841      AND     R4, #1
  0FD394: 3d04      JMPR    cc_NZ, 0x0FD39E
  0FD396: e7fc3300  MOVB    RL6, #0x33
  0FD39A: ea0080d5  JMPA    cc_UC, 0x0FD580
loc_0FD39E:
  0FD39E: a840      MOV     R4, [R0]
  0FD3A0: 6842      AND     R4, #2
  0FD3A2: ea300cd5  JMPA    cc_NZ, 0x0FD50C
  0FD3A6: b408acf9  MOVB    0xF9AC, [R8]
  0FD3AA: f4880100  MOVB    RL4, [R8+#0x0001]
  0FD3AE: f7f8adf9  MOVB    0xF9AD, RL4
  0FD3B2: da0f26e5  CALLS   0x0FE526
  0FD3B6: f1c8      MOVB    RL6, RL4
  0FD3B8: ea2006d5  JMPA    cc_Z, 0x0FD506
  0FD3BC: f2f4aef9  MOV     R4, 0xF9AE
  0FD3C0: 42f402dc  CMP     R4, 0xDC02
  0FD3C4: ed0a      JMPR    cc_UGT, 0x0FD3DA
  0FD3C6: 0841      ADD     R4, #1
  0FD3C8: f6f4aef9  MOV     0xF9AE, R4
  0FD3CC: e6fcaef9  MOV     R12, #0xF9AE
  0FD3D0: e02d      MOV     R13, #2
  0FD3D2: e00e      MOV     R14, #0
  0FD3D4: e00f      MOV     R15, #0
  0FD3D6: da0f8ce7  CALLS   0x0FE78C
loc_0FD3DA:
  0FD3DA: 49c3      CMPB    RL6, #3
  0FD3DC: 3d45      JMPR    cc_NZ, 0x0FD468
  0FD3DE: e6f4cc3c  MOV     R4, #0x3CCC
  0FD3E2: e6f53e00  MOV     R5, #0x003E
  0FD3E6: 8850      MOV     [-R0], R5
  0FD3E8: 8840      MOV     [-R0], R4
  0FD3EA: e6fc703f  MOV     R12, #0x3F70
  0FD3EE: e6fd3700  MOV     R13, #0x0037
  0FD3F2: e0ce      MOV     R14, #12
  0FD3F4: d7500300  EXTP    #0x003, #2
  0FD3F8: f2f4a01c  MOV     R4, 0x1CA0
  0FD3FC: f2f5a21c  MOV     R5, 0x1CA2
  0FD400: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
  0FD404: 0804      ADD     R0, #4
  0FD406: f1c8      MOVB    RL6, RL4
  0FD408: 2d15      JMPR    cc_Z, 0x0FD434
  0FD40A: e6f4d83c  MOV     R4, #0x3CD8
  0FD40E: e6f53e00  MOV     R5, #0x003E
  0FD412: 8850      MOV     [-R0], R5
  0FD414: 8840      MOV     [-R0], R4
  0FD416: e6fc943f  MOV     R12, #0x3F94
  0FD41A: e6fd3700  MOV     R13, #0x0037
  0FD41E: e07e      MOV     R14, #7
  0FD420: d7500300  EXTP    #0x003, #2
  0FD424: f2f4a01c  MOV     R4, 0x1CA0
  0FD428: f2f5a21c  MOV     R5, 0x1CA2
  0FD42C: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
  0FD430: 0804      ADD     R0, #4
  0FD432: f1c8      MOVB    RL6, RL4
loc_0FD434:
  0FD434: 49c0      CMPB    RL6, #0
  0FD436: 2d15      JMPR    cc_Z, 0x0FD462
  0FD438: e6f4df3c  MOV     R4, #0x3CDF
  0FD43C: e6f53e00  MOV     R5, #0x003E
  0FD440: 8850      MOV     [-R0], R5
  0FD442: 8840      MOV     [-R0], R4
  0FD444: e6fca93f  MOV     R12, #0x3FA9
  0FD448: e6fd3700  MOV     R13, #0x0037
  0FD44C: e07e      MOV     R14, #7
  0FD44E: d7500300  EXTP    #0x003, #2
  0FD452: f2f4a01c  MOV     R4, 0x1CA0
  0FD456: f2f5a21c  MOV     R5, 0x1CA2
  0FD45A: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
  0FD45E: 0804      ADD     R0, #4
  0FD460: f1c8      MOVB    RL6, RL4
loc_0FD462:
  0FD462: 49c0      CMPB    RL6, #0
  0FD464: 3d01      JMPR    cc_NZ, 0x0FD468
  0FD466: e16c      MOVB    RL6, #6
loc_0FD468:
  0FD468: f4880200  MOVB    RL4, [R8+#0x0002]
  0FD46C: f7f8bcf9  MOVB    0xF9BC, RL4
  0FD470: f4a80300  MOVB    RL5, [R8+#0x0003]
  0FD474: f7fabdf9  MOVB    0xF9BD, RL5
  0FD478: f4680400  MOVB    RL3, [R8+#0x0004]
  0FD47C: f7f6bef9  MOVB    0xF9BE, RL3
  0FD480: 49c1      CMPB    RL6, #1
  0FD482: 2d02      JMPR    cc_Z, 0x0FD488
  0FD484: 49c3      CMPB    RL6, #3
  0FD486: 3d08      JMPR    cc_NZ, 0x0FD498
loc_0FD488:
  0FD488: e1e8      MOVB    RL4, #14
  0FD48A: f7f8bff9  MOVB    0xF9BF, RL4
  0FD48E: f78fc0f9  MOVB    0xF9C0, ONES
  0FD492: f78fc1f9  MOVB    0xF9C1, ONES
  0FD496: 0d09      JMPR    cc_UC, 0x0FD4AA
loc_0FD498:
  0FD498: e1f8      MOVB    RL4, #15
  0FD49A: f7f8bff9  MOVB    0xF9BF, RL4
  0FD49E: e7fabf00  MOVB    RL5, #0xBF
  0FD4A2: f7fac0f9  MOVB    0xF9C0, RL5
  0FD4A6: f78fc1f9  MOVB    0xF9C1, ONES
loc_0FD4AA:
  0FD4AA: 49c6      CMPB    RL6, #6
  0FD4AC: 2d02      JMPR    cc_Z, 0x0FD4B2
  0FD4AE: 9f25      BSET    0xFD4A.9
  0FD4B0: e10c      MOVB    RL6, #0
loc_0FD4B2:
  0FD4B2: d7500100  EXTP    #0x001, #2
  0FD4B6: f2f4d437  MOV     R4, 0x37D4
  0FD4BA: f2f5d637  MOV     R5, 0x37D6
  0FD4BE: f6f500fe  MOV     0xFE00, R5
  0FD4C2: cc00      NOP
  0FD4C4: a824      MOV     R2, [R4]
  0FD4C6: 6821      AND     R2, #1
  0FD4C8: b824      MOV     [R4], R2
  0FD4CA: e6003c00  MOV     DPP0, #0x003C
  0FD4CE: e02c      MOV     R12, #2
  0FD4D0: da003c75  CALLS   0x00753C    ; -> rom_753C
  0FD4D4: 4980      CMPB    RL4, #0
  0FD4D6: 2d14      JMPR    cc_Z, 0x0FD500
  0FD4D8: 49c0      CMPB    RL6, #0
  0FD4DA: 3d12      JMPR    cc_NZ, 0x0FD500
  0FD4DC: d7500300  EXTP    #0x003, #2
  0FD4E0: f2f49c1c  MOV     R4, 0x1C9C
  0FD4E4: f2f59e1c  MOV     R5, 0x1C9E
  0FD4E8: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
  0FD4EC: d7500100  EXTP    #0x001, #2
  0FD4F0: f2f4d437  MOV     R4, 0x37D4
  0FD4F4: f2f5d637  MOV     R5, 0x37D6
  0FD4F8: dc45      EXTP    R5, #1
  0FD4FA: a824      MOV     R2, [R4]
  0FD4FC: b820      MOV     [R0], R2
  0FD4FE: 0d06      JMPR    cc_UC, 0x0FD50C
loc_0FD500:
  0FD500: e7fc2200  MOVB    RL6, #0x22
  0FD504: 0d03      JMPR    cc_UC, 0x0FD50C
loc_0FD506:
  0FD506: 7e25      BCLR    0xFD4A.7
  0FD508: e7fc3100  MOVB    RL6, #0x31
loc_0FD50C:
  0FD50C: a840      MOV     R4, [R0]
  0FD50E: 66f42000  AND     R4, #0x0020
  0FD512: 3d04      JMPR    cc_NZ, 0x0FD51C
  0FD514: a840      MOV     R4, [R0]
  0FD516: 66f48000  AND     R4, #0x0080
  0FD51A: 2d23      JMPR    cc_Z, 0x0FD562
loc_0FD51C:
  0FD51C: 49c0      CMPB    RL6, #0
  0FD51E: 3d21      JMPR    cc_NZ, 0x0FD562
  0FD520: a840      MOV     R4, [R0]
  0FD522: 66f48000  AND     R4, #0x0080
  0FD526: 3d14      JMPR    cc_NZ, 0x0FD550
  0FD528: e7f87100  MOVB    RL4, #0x71
  0FD52C: f059      MOV     R5, R9
  0FD52E: 0891      ADD     R9, #1
  0FD530: b985      MOVB    [R5], RL4
  0FD532: e128      MOVB    RL4, #2
  0FD534: f059      MOV     R5, R9
  0FD536: 0891      ADD     R9, #1
  0FD538: b985      MOVB    [R5], RL4
  0FD53A: e108      MOVB    RL4, #0
  0FD53C: f059      MOV     R5, R9
  0FD53E: 0891      ADD     R9, #1
  0FD540: b985      MOVB    [R5], RL4
  0FD542: e118      MOVB    RL4, #1
  0FD544: f059      MOV     R5, R9
  0FD546: 0891      ADD     R9, #1
  0FD548: b985      MOVB    [R5], RL4
  0FD54A: f6f96afc  MOV     0xFC6A, R9
  0FD54E: 0d09      JMPR    cc_UC, 0x0FD562
loc_0FD550:
  0FD550: 7e25      BCLR    0xFD4A.7
  0FD552: d7500100  EXTP    #0x001, #2
  0FD556: f2f4d037  MOV     R4, 0x37D0
  0FD55A: f2f5d237  MOV     R5, 0x37D2
  0FD55E: dc45      EXTP    R5, #1
  0FD560: a9c4      MOVB    RL6, [R4]
loc_0FD562:
  0FD562: d7500100  EXTP    #0x001, #2
  0FD566: f2f4d437  MOV     R4, 0x37D4
  0FD56A: f2f5d637  MOV     R5, 0x37D6
  0FD56E: f6f500fe  MOV     0xFE00, R5
  0FD572: cc00      NOP
  0FD574: a824      MOV     R2, [R4]
  0FD576: 6821      AND     R2, #1
  0FD578: b824      MOV     [R4], R2
  0FD57A: e6003c00  MOV     DPP0, #0x003C
  0FD57E: cc00      NOP
loc_0FD580:
  0FD580: 49c0      CMPB    RL6, #0
  0FD582: 2d20      JMPR    cc_Z, 0x0FD5C4
  0FD584: c0cc      MOVBZ   R12, RL6
  0FD586: da0faceb  CALLS   0x0FEBAC
  0FD58A: 0d1c      JMPR    cc_UC, 0x0FD5C4
loc_0FD58C:
  0FD58C: da0f1ceb  CALLS   0x0FEB1C
  0FD590: f1c8      MOVB    RL6, RL4
  0FD592: 49c3      CMPB    RL6, #3
  0FD594: 3d01      JMPR    cc_NZ, 0x0FD598
  0FD596: e14c      MOVB    RL6, #4
loc_0FD598:
  0FD598: 49c5      CMPB    RL6, #5
  0FD59A: 3d01      JMPR    cc_NZ, 0x0FD59E
  0FD59C: e12c      MOVB    RL6, #2
loc_0FD59E:
  0FD59E: e7f87100  MOVB    RL4, #0x71
  0FD5A2: f059      MOV     R5, R9
  0FD5A4: 0891      ADD     R9, #1
  0FD5A6: b985      MOVB    [R5], RL4
  0FD5A8: e118      MOVB    RL4, #1
  0FD5AA: f059      MOV     R5, R9
  0FD5AC: 0891      ADD     R9, #1
  0FD5AE: b985      MOVB    [R5], RL4
  0FD5B0: f049      MOV     R4, R9
  0FD5B2: 0891      ADD     R9, #1
  0FD5B4: b9c4      MOVB    [R4], RL6
  0FD5B6: f6f96afc  MOV     0xFC6A, R9
  0FD5BA: 0d04      JMPR    cc_UC, 0x0FD5C4
loc_0FD5BC:
  0FD5BC: e6fc1200  MOV     R12, #0x0012
  0FD5C0: da0faceb  CALLS   0x0FEBAC
loc_0FD5C4:
  0FD5C4: 0802      ADD     R0, #2
  0FD5C6: 9890      MOV     R9, [R0+]
  0FD5C8: 9880      MOV     R8, [R0+]
  0FD5CA: 9860      MOV     R6, [R0+]
  0FD5CC: db00      RETS
loc_0FD5CE:
  0FD5CE: f3f870fc  MOVB    RL4, 0xFC70
  0FD5D2: 2d0b      JMPR    cc_Z, 0x0FD5EA
  0FD5D4: 4981      CMPB    RL4, #1
  0FD5D6: 2d09      JMPR    cc_Z, 0x0FD5EA
  0FD5D8: 4982      CMPB    RL4, #2
  0FD5DA: 2d27      JMPR    cc_Z, 0x0FD62A
  0FD5DC: 4983      CMPB    RL4, #3
  0FD5DE: 2d4d      JMPR    cc_Z, 0x0FD67A
  0FD5E0: 47f83c00  CMPB    RL4, #0x3C
  0FD5E4: 2d55      JMPR    cc_Z, 0x0FD690
  0FD5E6: ea00fad6  JMPA    cc_UC, 0x0FD6FA
loc_0FD5EA:
  0FD5EA: f68e00dc  MOV     0xDC00, ZEROS
  0FD5EE: 9e24      BCLR    0xFD48.9
  0FD5F0: ae24      BCLR    0xFD48.10
  0FD5F2: be24      BCLR    0xFD48.11
  0FD5F4: ff24      BSET    0xFD48.15
  0FD5F6: 4ae225b1  BMOV    0xFD4A.1, P3.11
  0FD5FA: 4e25      BCLR    0xFD4A.4
  0FD5FC: 7e25      BCLR    0xFD4A.7
  0FD5FE: ae25      BCLR    0xFD4A.10
  0FD600: e7f81000  MOVB    RL4, #0x10
  0FD604: f7f873fc  MOVB    0xFC73, RL4
  0FD608: f7f872fc  MOVB    0xFC72, RL4
  0FD60C: 2f25      BSET    0xFD4A.2
  0FD60E: 3e25      BCLR    0xFD4A.3
  0FD610: f78e71fc  MOVB    0xFC71, ZEROS
  0FD614: 8a250210  JB      0xFD4A.1, 0x0FD61C
  0FD618: ea00fed6  JMPA    cc_UC, 0x0FD6FE
loc_0FD61C:
  0FD61C: 6eb8      BCLR    S0EIC.6
  0FD61E: da0f4cd8  CALLS   0x0FD84C
  0FD622: e128      MOVB    RL4, #2
  0FD624: f7f870fc  MOVB    0xFC70, RL4
  0FD628: db00      RETS
loc_0FD62A:
  0FD62A: 8ad81790  JB      S0CON.9, 0x0FD65C
  0FD62E: f2f4fefc  MOV     R4, 0xFCFE
  0FD632: 46f44efb  CMP     R4, #0xFB4E
  0FD636: fd63      JMPR    cc_ULE, 0x0FD6FE
  0FD638: f3f84efb  MOVB    RL4, 0xFB4E
  0FD63C: 47f8b800  CMPB    RL4, #0xB8
  0FD640: 2d03      JMPR    cc_Z, 0x0FD648
  0FD642: 47f8f800  CMPB    RL4, #0xF8
  0FD646: 3d06      JMPR    cc_NZ, 0x0FD654
loc_0FD648:
  0FD648: af24      BSET    0xFD48.10
  0FD64A: e7f8c800  MOVB    RL4, #0xC8
  0FD64E: f7f870fc  MOVB    0xFC70, RL4
  0FD652: db00      RETS
loc_0FD654:
  0FD654: 6eb7      BCLR    S0RIC.6
  0FD656: f78e70fc  MOVB    0xFC70, ZEROS
  0FD65A: db00      RETS
loc_0FD65C:
  0FD65C: 6eb7      BCLR    S0RIC.6
  0FD65E: 8ae208b0  JB      P3.11, 0x0FD672
  0FD662: e014      MOV     R4, #1
  0FD664: f6f400dc  MOV     0xDC00, R4
  0FD668: e138      MOVB    RL4, #3
  0FD66A: f7f870fc  MOVB    0xFC70, RL4
  0FD66E: 9ed8      BCLR    S0CON.9
  0FD670: db00      RETS
loc_0FD672:
  0FD672: e118      MOVB    RL4, #1
  0FD674: f7f870fc  MOVB    0xFC70, RL4
  0FD678: db00      RETS
loc_0FD67A:
  0FD67A: e7f81400  MOVB    RL4, #0x14
  0FD67E: f7f873fc  MOVB    0xFC73, RL4
  0FD682: e7fa3c00  MOVB    RL5, #0x3C
  0FD686: f7fa70fc  MOVB    0xFC70, RL5
  0FD68A: f68e6cfc  MOV     0xFC6C, ZEROS
  0FD68E: db00      RETS
loc_0FD690:
  0FD690: 4fd8      BSET    S0CON.4
  0FD692: 8ae214b0  JB      P3.11, 0x0FD6BE
  0FD696: f2f46cfc  MOV     R4, 0xFC6C
  0FD69A: 46f43200  CMP     R4, #0x0032
  0FD69E: fd2f      JMPR    cc_ULE, 0x0FD6FE
  0FD6A0: e6f4c679  MOV     R4, #0x79C6
  0FD6A4: e6f50000  MOV     R5, #0x0000
  0FD6A8: d7500300  EXTP    #0x003, #2
  0FD6AC: f6f49a39  MOV     0x399A, R4
  0FD6B0: f6f59c39  MOV     0x399C, R5
  0FD6B4: e7f86400  MOVB    RL4, #0x64
  0FD6B8: f7f870fc  MOVB    0xFC70, RL4
  0FD6BC: db00      RETS
loc_0FD6BE:
  0FD6BE: e6f41400  MOV     R4, #0x0014
  0FD6C2: 42f46cfc  CMP     R4, 0xFC6C
  0FD6C6: ed16      JMPR    cc_UGT, 0x0FD6F4
  0FD6C8: f2f46cfc  MOV     R4, 0xFC6C
  0FD6CC: 46f41e00  CMP     R4, #0x001E
  0FD6D0: ed11      JMPR    cc_UGT, 0x0FD6F4
  0FD6D2: e6f4c679  MOV     R4, #0x79C6
  0FD6D6: e6f50000  MOV     R5, #0x0000
  0FD6DA: d7500300  EXTP    #0x003, #2
  0FD6DE: f6f49a39  MOV     0x399A, R4
  0FD6E2: f6f59c39  MOV     0x399C, R5
  0FD6E6: e7f85a00  MOVB    RL4, #0x5A
  0FD6EA: f7f870fc  MOVB    0xFC70, RL4
  0FD6EE: da000048  CALLS   0x004800    ; -> rom_4800
  0FD6F2: db00      RETS
loc_0FD6F4:
  0FD6F4: f78e70fc  MOVB    0xFC70, ZEROS
  0FD6F8: db00      RETS
loc_0FD6FA:
  0FD6FA: f78e70fc  MOVB    0xFC70, ZEROS
loc_0FD6FE:
  0FD6FE: db00      RETS
loc_0FD700:
  0FD700: 9a241dd0  JNB     0xFD48.13, 0x0FD73E
  0FD704: da0f40d7  CALLS   0x0FD740
  0FD708: f6f4fcfc  MOV     0xFCFC, R4
  0FD70C: f6f47afc  MOV     0xFC7A, R4
  0FD710: f2fcfcfc  MOV     R12, 0xFCFC
  0FD714: f2fd6afc  MOV     R13, 0xFC6A
  0FD718: da0f72d7  CALLS   0x0FD772
  0FD71C: f2f56afc  MOV     R5, 0xFC6A
  0FD720: b985      MOVB    [R5], RL4
  0FD722: e7f8f000  MOVB    RL4, #0xF0
  0FD726: f7f870fc  MOVB    0xFC70, RL4
  0FD72A: 6eb7      BCLR    S0RIC.6
  0FD72C: c2fc73fc  MOVBZ   R12, 0xFC73
  0FD730: da00e849  CALLS   0x0049E8    ; -> rom_49E8
  0FD734: f6f4b4fe  MOV     0xFEB4, R4
  0FD738: 7eb7      BCLR    S0RIC.7
  0FD73A: 4fd8      BSET    S0CON.4
  0FD73C: ee24      BCLR    0xFD48.14
loc_0FD73E:
  0FD73E: db00      RETS
loc_0FD740:
  0FD740: e6f452fb  MOV     R4, #0xFB52
  0FD744: f2f56afc  MOV     R5, 0xFC6A
  0FD748: 2054      SUB     R5, R4
  0FD74A: f0c5      MOV     R12, R5
  0FD74C: e7f8b800  MOVB    RL4, #0xB8
  0FD750: f7f84efb  MOVB    0xFB4E, RL4
  0FD754: f3fa9bfc  MOVB    RL5, 0xFC9B
  0FD758: f7fa4ffb  MOVB    0xFB4F, RL5
  0FD75C: f3f6a9fc  MOVB    RL3, 0xFCA9
  0FD760: f7f650fb  MOVB    0xFB50, RL3
  0FD764: f02c      MOV     R2, R12
  0FD766: f7f451fb  MOVB    0xFB51, RL2
  0FD76A: e6fd4efb  MOV     R13, #0xFB4E
  0FD76E: f04d      MOV     R4, R13
  0FD770: db00      RETS
loc_0FD772:
  0FD772: e00f      MOV     R15, #0
  0FD774: f0ec      MOV     R14, R12
  0FD776: 0d05      JMPR    cc_UC, 0x0FD782
loc_0FD778:
  0FD778: a98e      MOVB    RL4, [R14]
  0FD77A: f05f      MOV     R5, R15
  0FD77C: 51a8      XORB    RL5, RL4
  0FD77E: f0f5      MOV     R15, R5
  0FD780: 08e1      ADD     R14, #1
loc_0FD782:
  0FD782: 40ed      CMP     R14, R13
  0FD784: 8df9      JMPR    cc_C, 0x0FD778
  0FD786: f04f      MOV     R4, R15
  0FD788: db00      RETS
loc_0FD78A:
  0FD78A: 8890      MOV     [-R0], R9
  0FD78C: c2f470fc  MOVBZ   R4, 0xFC70
  0FD790: 46f4c800  CMP     R4, #0x00C8
  0FD794: 3d59      JMPR    cc_NZ, 0x0FD848
  0FD796: af24      BSET    0xFD48.10
  0FD798: f2f9fefc  MOV     R9, 0xFCFE
  0FD79C: 42f97afc  CMP     R9, 0xFC7A
  0FD7A0: ed0e      JMPR    cc_UGT, 0x0FD7BE
  0FD7A2: f2f476fc  MOV     R4, 0xFC76
  0FD7A6: 46f406f9  CMP     R4, #0xF906
  0FD7AA: 2d14      JMPR    cc_Z, 0x0FD7D4
  0FD7AC: f2f56cfc  MOV     R5, 0xFC6C
  0FD7B0: 42f576fc  CMP     R5, 0xFC76
  0FD7B4: fd0f      JMPR    cc_ULE, 0x0FD7D4
  0FD7B6: 6eb7      BCLR    S0RIC.6
  0FD7B8: f78e70fc  MOVB    0xFC70, ZEROS
  0FD7BC: 0d0b      JMPR    cc_UC, 0x0FD7D4
loc_0FD7BE:
  0FD7BE: e00c      MOV     R12, #0
  0FD7C0: da005849  CALLS   0x004958    ; -> rom_4958
  0FD7C4: f6f97afc  MOV     0xFC7A, R9
  0FD7C8: e6f41400  MOV     R4, #0x0014
  0FD7CC: f6f476fc  MOV     0xFC76, R4
  0FD7D0: f68e6cfc  MOV     0xFC6C, ZEROS
loc_0FD7D4:
  0FD7D4: 9a2410c0  JNB     0xFD48.12, 0x0FD7F8
  0FD7D8: e6f94efb  MOV     R9, #0xFB4E
  0FD7DC: f2f4fefc  MOV     R4, 0xFCFE
  0FD7E0: 4049      CMP     R4, R9
  0FD7E2: fd0a      JMPR    cc_ULE, 0x0FD7F8
  0FD7E4: e7f8c000  MOVB    RL4, #0xC0
  0FD7E8: b989      MOVB    [R9], RL4
  0FD7EA: da003e44  CALLS   0x00443E    ; -> rom_443E
  0FD7EE: f6f46afc  MOV     0xFC6A, R4
  0FD7F2: e7f8b800  MOVB    RL4, #0xB8
  0FD7F6: b989      MOVB    [R9], RL4
loc_0FD7F8:
  0FD7F8: f2f4fefc  MOV     R4, 0xFCFE
  0FD7FC: 42f46afc  CMP     R4, 0xFC6A
  0FD800: fd23      JMPR    cc_ULE, 0x0FD848
  0FD802: 6eb7      BCLR    S0RIC.6
  0FD804: 4e25      BCLR    0xFD4A.4
  0FD806: f68e6cfc  MOV     0xFC6C, ZEROS
  0FD80A: da000445  CALLS   0x004504    ; -> rom_4504
  0FD80E: f7f871fc  MOVB    0xFC71, RL4
  0FD812: da005245  CALLS   0x004552    ; -> rom_4552
  0FD816: f3f871fc  MOVB    RL4, 0xFC71
  0FD81A: 2d14      JMPR    cc_Z, 0x0FD844
  0FD81C: f2f26afc  MOV     R2, 0xFC6A
  0FD820: 8820      MOV     [-R0], R2
  0FD822: e6fc4efb  MOV     R12, #0xFB4E
  0FD826: f0d2      MOV     R13, R2
  0FD828: da0f72d7  CALLS   0x0FD772
  0FD82C: 9820      MOV     R2, [R0+]
  0FD82E: 498a      CMPB    RL4, [R2]
  0FD830: 3d05      JMPR    cc_NZ, 0x0FD83C
  0FD832: e7f8dc00  MOVB    RL4, #0xDC
  0FD836: f7f870fc  MOVB    0xFC70, RL4
  0FD83A: 0d06      JMPR    cc_UC, 0x0FD848
loc_0FD83C:
  0FD83C: af25      BSET    0xFD4A.10
  0FD83E: da0f4cd8  CALLS   0x0FD84C
  0FD842: 0d02      JMPR    cc_UC, 0x0FD848
loc_0FD844:
  0FD844: da0f4cd8  CALLS   0x0FD84C
loc_0FD848:
  0FD848: 9890      MOV     R9, [R0+]
  0FD84A: db00      RETS
loc_0FD84C:
  0FD84C: 6eb6      BCLR    S0TIC.6
  0FD84E: 6eb7      BCLR    S0RIC.6
  0FD850: e6d86780  MOV     S0CON, #0x8067
  0FD854: f3f873fc  MOVB    RL4, 0xFC73
  0FD858: f7f872fc  MOVB    0xFC72, RL4
  0FD85C: c2fc73fc  MOVBZ   R12, 0xFC73
  0FD860: da00e849  CALLS   0x0049E8    ; -> rom_49E8
  0FD864: f6f4b4fe  MOV     0xFEB4, R4
  0FD868: 9a240ef0  JNB     0xFD48.15, 0x0FD888
  0FD86C: e7f83200  MOVB    RL4, #0x32
  0FD870: f7f8a0fc  MOVB    0xFCA0, RL4
  0FD874: e7fa6e00  MOVB    RL5, #0x6E
  0FD878: f7faa1fc  MOVB    0xFCA1, RL5
  0FD87C: e7f61400  MOVB    RL3, #0x14
  0FD880: f7f6a2fc  MOVB    0xFCA2, RL3
  0FD884: f78ea3fc  MOVB    0xFCA3, ZEROS
loc_0FD888:
  0FD888: f3f8a0fc  MOVB    RL4, 0xFCA0
  0FD88C: f7f89ffc  MOVB    0xFC9F, RL4
  0FD890: e6f44efb  MOV     R4, #0xFB4E
  0FD894: f6f47afc  MOV     0xFC7A, R4
  0FD898: e6f566fc  MOV     R5, #0xFC66
  0FD89C: f6f56afc  MOV     0xFC6A, R5
  0FD8A0: e118      MOVB    RL4, #1
  0FD8A2: f7f87cfc  MOVB    0xFC7C, RL4
  0FD8A6: e6f41027  MOV     R4, #0x2710
  0FD8AA: f6f476fc  MOV     0xFC76, R4
  0FD8AE: e00c      MOV     R12, #0
  0FD8B0: da008248  CALLS   0x004882    ; -> rom_4882
  0FD8B4: cf24      BSET    0xFD48.12
  0FD8B6: 9f24      BSET    0xFD48.9
  0FD8B8: 4e25      BCLR    0xFD4A.4
  0FD8BA: 4fd8      BSET    S0CON.4
  0FD8BC: 7eb7      BCLR    S0RIC.7
  0FD8BE: 6fb7      BSET    S0RIC.6
  0FD8C0: db00      RETS
loc_0FD8C2:
  0FD8C2: 88c0      MOV     [-R0], R12
  0FD8C4: 8860      MOV     [-R0], R6
  0FD8C6: f04c      MOV     R4, R12
  0FD8C8: 4981      CMPB    RL4, #1
  0FD8CA: 2d04      JMPR    cc_Z, 0x0FD8D4
  0FD8CC: 4980      CMPB    RL4, #0
  0FD8CE: 2d12      JMPR    cc_Z, 0x0FD8F4
  0FD8D0: ea0048d9  JMPA    cc_UC, 0x0FD948
loc_0FD8D4:
  0FD8D4: 5f25      BSET    0xFD4A.5
  0FD8D6: c2fc72fc  MOVBZ   R12, 0xFC72
  0FD8DA: da00e849  CALLS   0x0049E8    ; -> rom_49E8
  0FD8DE: f6f4b4fe  MOV     0xFEB4, R4
  0FD8E2: e01c      MOV     R12, #1
  0FD8E4: da008248  CALLS   0x004882    ; -> rom_4882
  0FD8E8: 6eb7      BCLR    S0RIC.6
  0FD8EA: 7fb7      BSET    S0RIC.7
  0FD8EC: 6fb7      BSET    S0RIC.6
  0FD8EE: e11c      MOVB    RL6, #1
  0FD8F0: ea0048d9  JMPA    cc_UC, 0x0FD948
loc_0FD8F4:
  0FD8F4: 5e25      BCLR    0xFD4A.5
  0FD8F6: be88      BCLR    PSW.11
  0FD8F8: cc00      NOP
  0FD8FA: 8ab70270  JB      S0RIC.7, 0x0FD902
  0FD8FE: ea000ed9  JMPA    cc_UC, 0x0FD90E
loc_0FD902:
  0FD902: bf88      BSET    PSW.11
  0FD904: cc00      NOP
  0FD906: 7eb7      BCLR    S0RIC.7
  0FD908: e10c      MOVB    RL6, #0
  0FD90A: ea0048d9  JMPA    cc_UC, 0x0FD948
loc_0FD90E:
  0FD90E: e65a3300  MOV     S0BG, #0x0033
  0FD912: ded8      BCLR    S0CON.13
  0FD914: 8ae202b0  JB      P3.11, 0x0FD91C
  0FD918: ea0036d9  JMPA    cc_UC, 0x0FD936
loc_0FD91C:
  0FD91C: f2f4fcfc  MOV     R4, 0xFCFC
  0FD920: 248ffcfc  SUB     0xFCFC, ONES
  0FD924: a9a4      MOVB    RL5, [R4]
  0FD926: c0a4      MOVBZ   R4, RL5
  0FD928: f6f4b0fe  MOV     0xFEB0, R4
  0FD92C: bf88      BSET    PSW.11
  0FD92E: cc00      NOP
  0FD930: e11c      MOVB    RL6, #1
  0FD932: ea0048d9  JMPA    cc_UC, 0x0FD948
loc_0FD936:
  0FD936: bf88      BSET    PSW.11
  0FD938: cc00      NOP
  0FD93A: c2fc73fc  MOVBZ   R12, 0xFC73
  0FD93E: da00e849  CALLS   0x0049E8    ; -> rom_49E8
  0FD942: f6f4b4fe  MOV     0xFEB4, R4
  0FD946: e10c      MOVB    RL6, #0
loc_0FD948:
  0FD948: f18c      MOVB    RL4, RL6
  0FD94A: 9860      MOV     R6, [R0+]
  0FD94C: 0802      ADD     R0, #2
  0FD94E: db00      RETS
loc_0FD950:
  0FD950: 8860      MOV     [-R0], R6
  0FD952: 8870      MOV     [-R0], R7
  0FD954: 8880      MOV     [-R0], R8
  0FD956: 8890      MOV     [-R0], R9
  0FD958: 2802      SUB     R0, #2
  0FD95A: f2f978fc  MOV     R9, 0xFC78
  0FD95E: e6f852fb  MOV     R8, #0xFB52
  0FD962: e10c      MOVB    RL6, #0
  0FD964: e10e      MOVB    RL7, #0
  0FD966: f4890200  MOVB    RL4, [R9+#0x0002]
  0FD96A: b980      MOVB    [R0], RL4
  0FD96C: f3fa9dfc  MOVB    RL5, 0xFC9D
  0FD970: f7faaaf9  MOVB    0xF9AA, RL5
  0FD974: f4690100  MOVB    RL3, [R9+#0x0001]
  0FD978: f7f6abf9  MOVB    0xF9AB, RL3
  0FD97C: f4690100  MOVB    RL3, [R9+#0x0001]
  0FD980: 47f68500  CMPB    RL3, #0x85
  0FD984: 2d03      JMPR    cc_Z, 0x0FD98C
  0FD986: e7fe1200  MOVB    RL7, #0x12
  0FD98A: 0d06      JMPR    cc_UC, 0x0FD998
loc_0FD98C:
  0FD98C: f3f89cfc  MOVB    RL4, 0xFC9C
  0FD990: 4983      CMPB    RL4, #3
  0FD992: 9d02      JMPR    cc_NC, 0x0FD998
  0FD994: e7fe1000  MOVB    RL7, #0x10
loc_0FD998:
  0FD998: 49e0      CMPB    RL7, #0
  0FD99A: 3d1f      JMPR    cc_NZ, 0x0FD9DA
  0FD99C: a980      MOVB    RL4, [R0]
  0FD99E: 4981      CMPB    RL4, #1
  0FD9A0: 2d0b      JMPR    cc_Z, 0x0FD9B8
  0FD9A2: 4982      CMPB    RL4, #2
  0FD9A4: 2d0c      JMPR    cc_Z, 0x0FD9BE
  0FD9A6: 4983      CMPB    RL4, #3
  0FD9A8: 2d0d      JMPR    cc_Z, 0x0FD9C4
  0FD9AA: 47f81000  CMPB    RL4, #0x10
  0FD9AE: 2d0d      JMPR    cc_Z, 0x0FD9CA
  0FD9B0: 47f88500  CMPB    RL4, #0x85
  0FD9B4: 2d0d      JMPR    cc_Z, 0x0FD9D0
  0FD9B6: 0d0f      JMPR    cc_UC, 0x0FD9D6
loc_0FD9B8:
  0FD9B8: e7fc1000  MOVB    RL6, #0x10
  0FD9BC: 0d0e      JMPR    cc_UC, 0x0FD9DA
loc_0FD9BE:
  0FD9BE: e7fc3000  MOVB    RL6, #0x30
  0FD9C2: 0d0b      JMPR    cc_UC, 0x0FD9DA
loc_0FD9C4:
  0FD9C4: e7fc5000  MOVB    RL6, #0x50
  0FD9C8: 0d08      JMPR    cc_UC, 0x0FD9DA
loc_0FD9CA:
  0FD9CA: e7fc1000  MOVB    RL6, #0x10
  0FD9CE: 0d05      JMPR    cc_UC, 0x0FD9DA
loc_0FD9D0:
  0FD9D0: e7fc8700  MOVB    RL6, #0x87
  0FD9D4: 0d02      JMPR    cc_UC, 0x0FD9DA
loc_0FD9D6:
  0FD9D6: e7fe3100  MOVB    RL7, #0x31
loc_0FD9DA:
  0FD9DA: 49e0      CMPB    RL7, #0
  0FD9DC: 3d13      JMPR    cc_NZ, 0x0FDA04
  0FD9DE: f7fc73fc  MOVB    0xFC73, RL6
  0FD9E2: 9f25      BSET    0xFD4A.9
  0FD9E4: e7f85000  MOVB    RL4, #0x50
  0FD9E8: f058      MOV     R5, R8
  0FD9EA: 0881      ADD     R8, #1
  0FD9EC: b985      MOVB    [R5], RL4
  0FD9EE: f4890100  MOVB    RL4, [R9+#0x0001]
  0FD9F2: f058      MOV     R5, R8
  0FD9F4: 0881      ADD     R8, #1
  0FD9F6: b985      MOVB    [R5], RL4
  0FD9F8: f048      MOV     R4, R8
  0FD9FA: 0881      ADD     R8, #1
  0FD9FC: c940      MOVB    [R4], [R0]
  0FD9FE: f6f86afc  MOV     0xFC6A, R8
  0FDA02: 0d03      JMPR    cc_UC, 0x0FDA0A
loc_0FDA04:
  0FDA04: c0ec      MOVBZ   R12, RL7
  0FDA06: da0faceb  CALLS   0x0FEBAC
loc_0FDA0A:
  0FDA0A: da00d670  CALLS   0x0070D6    ; -> rom_70D6
  0FDA0E: c084      MOVBZ   R4, RL4
  0FDA10: f6f4aef9  MOV     0xF9AE, R4
  0FDA14: f6f402dc  MOV     0xDC02, R4
  0FDA18: 0802      ADD     R0, #2
  0FDA1A: 9890      MOV     R9, [R0+]
  0FDA1C: 9880      MOV     R8, [R0+]
  0FDA1E: 9870      MOV     R7, [R0+]
  0FDA20: 9860      MOV     R6, [R0+]
  0FDA22: db00      RETS
loc_0FDA24:
  0FDA24: 8860      MOV     [-R0], R6
  0FDA26: 8870      MOV     [-R0], R7
  0FDA28: 8880      MOV     [-R0], R8
  0FDA2A: 8890      MOV     [-R0], R9
  0FDA2C: 2802      SUB     R0, #2
  0FDA2E: f2f878fc  MOV     R8, 0xFC78
  0FDA32: e6f452fb  MOV     R4, #0xFB52
  0FDA36: f6f47efc  MOV     0xFC7E, R4
  0FDA3A: e10c      MOVB    RL6, #0
  0FDA3C: f2f56efc  MOV     R5, 0xFC6E
  0FDA40: ea3004dc  JMPA    cc_NZ, 0x0FDC04
  0FDA44: f4e80100  MOVB    RL7, [R8+#0x0001]
  0FDA48: 49e1      CMPB    RL7, #1
  0FDA4A: 2d07      JMPR    cc_Z, 0x0FDA5A
  0FDA4C: 49e2      CMPB    RL7, #2
  0FDA4E: 2d77      JMPR    cc_Z, 0x0FDB3E
  0FDA50: 49e4      CMPB    RL7, #4
  0FDA52: ea2092db  JMPA    cc_Z, 0x0FDB92
  0FDA56: ea00fadb  JMPA    cc_UC, 0x0FDBFA
loc_0FDA5A:
  0FDA5A: 8a251920  JB      0xFD4A.2, 0x0FDA90
  0FDA5E: e7f86700  MOVB    RL4, #0x67
  0FDA62: f2f57efc  MOV     R5, 0xFC7E
  0FDA66: 248f7efc  SUB     0xFC7E, ONES
  0FDA6A: b985      MOVB    [R5], RL4
  0FDA6C: f2f47efc  MOV     R4, 0xFC7E
  0FDA70: 248f7efc  SUB     0xFC7E, ONES
  0FDA74: b9e4      MOVB    [R4], RL7
  0FDA76: e108      MOVB    RL4, #0
  0FDA78: f2f57efc  MOV     R5, 0xFC7E
  0FDA7C: 248f7efc  SUB     0xFC7E, ONES
  0FDA80: b985      MOVB    [R5], RL4
  0FDA82: f2f57efc  MOV     R5, 0xFC7E
  0FDA86: 248f7efc  SUB     0xFC7E, ONES
  0FDA8A: b985      MOVB    [R5], RL4
  0FDA8C: ea0008dc  JMPA    cc_UC, 0x0FDC08
loc_0FDA90:
  0FDA90: 3f25      BSET    0xFD4A.3
  0FDA92: f68e86fc  MOV     0xFC86, ZEROS
  0FDA96: f68e88fc  MOV     0xFC88, ZEROS
  0FDA9A: f2f97efc  MOV     R9, 0xFC7E
  0FDA9E: 2894      SUB     R9, #4
  0FDAA0: c2f406dc  MOVBZ   R4, 0xDC06
  0FDAA4: e6f52c00  MOV     R5, #0x002C
  0FDAA8: f6f40efe  MOV     0xFE0E, R4
  0FDAAC: 5b55      DIVU    R5
  0FDAAE: f2f40cfe  MOV     R4, 0xFE0C
  0FDAB2: b980      MOVB    [R0], RL4
  0FDAB4: e7fa6700  MOVB    RL5, #0x67
  0FDAB8: f2f47efc  MOV     R4, 0xFC7E
  0FDABC: 248f7efc  SUB     0xFC7E, ONES
  0FDAC0: b9a4      MOVB    [R4], RL5
  0FDAC2: f2f47efc  MOV     R4, 0xFC7E
  0FDAC6: 248f7efc  SUB     0xFC7E, ONES
  0FDACA: b9e4      MOVB    [R4], RL7
  0FDACC: da0ff8e7  CALLS   0x0FE7F8
  0FDAD0: f4891500  MOVB    RL4, [R9+#0x0015]
  0FDAD4: f4a92c00  MOVB    RL5, [R9+#0x002C]
  0FDAD8: 018a      ADDB    RL4, RL5
  0FDADA: a9a0      MOVB    RL5, [R0]
  0FDADC: c0a5      MOVBZ   R5, RL5
  0FDADE: f029      MOV     R2, R9
  0FDAE0: 0025      ADD     R2, R5
  0FDAE2: 098a      ADDB    RL4, [R2]
  0FDAE4: f7f889fc  MOVB    0xFC89, RL4
  0FDAE8: f4891600  MOVB    RL4, [R9+#0x0016]
  0FDAEC: f4a92d00  MOVB    RL5, [R9+#0x002D]
  0FDAF0: 018a      ADDB    RL4, RL5
  0FDAF2: a9a0      MOVB    RL5, [R0]
  0FDAF4: c0a5      MOVBZ   R5, RL5
  0FDAF6: f029      MOV     R2, R9
  0FDAF8: 0025      ADD     R2, R5
  0FDAFA: f4a20100  MOVB    RL5, [R2+#0x0001]
  0FDAFE: 018a      ADDB    RL4, RL5
  0FDB00: f7f888fc  MOVB    0xFC88, RL4
  0FDB04: f4891700  MOVB    RL4, [R9+#0x0017]
  0FDB08: f4a92e00  MOVB    RL5, [R9+#0x002E]
  0FDB0C: 018a      ADDB    RL4, RL5
  0FDB0E: a9a0      MOVB    RL5, [R0]
  0FDB10: c0a5      MOVBZ   R5, RL5
  0FDB12: f029      MOV     R2, R9
  0FDB14: 0025      ADD     R2, R5
  0FDB16: f4a20200  MOVB    RL5, [R2+#0x0002]
  0FDB1A: 018a      ADDB    RL4, RL5
  0FDB1C: f7f887fc  MOVB    0xFC87, RL4
  0FDB20: f4891800  MOVB    RL4, [R9+#0x0018]
  0FDB24: f4a92f00  MOVB    RL5, [R9+#0x002F]
  0FDB28: 018a      ADDB    RL4, RL5
  0FDB2A: a9a0      MOVB    RL5, [R0]
  0FDB2C: c0a5      MOVBZ   R5, RL5
  0FDB2E: f029      MOV     R2, R9
  0FDB30: 0025      ADD     R2, R5
  0FDB32: f4a20300  MOVB    RL5, [R2+#0x0003]
  0FDB36: 018a      ADDB    RL4, RL5
  0FDB38: f7f886fc  MOVB    0xFC86, RL4
  0FDB3C: 0d65      JMPR    cc_UC, 0x0FDC08
loc_0FDB3E:
  0FDB3E: f4880200  MOVB    RL4, [R8+#0x0002]
  0FDB42: 47f84200  CMPB    RL4, #0x42
  0FDB46: 3d22      JMPR    cc_NZ, 0x0FDB8C
  0FDB48: f4880300  MOVB    RL4, [R8+#0x0003]
  0FDB4C: 47f84d00  CMPB    RL4, #0x4D
  0FDB50: 3d1d      JMPR    cc_NZ, 0x0FDB8C
  0FDB52: f4880400  MOVB    RL4, [R8+#0x0004]
  0FDB56: 47f85700  CMPB    RL4, #0x57
  0FDB5A: 3d18      JMPR    cc_NZ, 0x0FDB8C
  0FDB5C: f4880500  MOVB    RL4, [R8+#0x0005]
  0FDB60: f7f806dc  MOVB    0xDC06, RL4
  0FDB64: e7fa6700  MOVB    RL5, #0x67
  0FDB68: f2f47efc  MOV     R4, 0xFC7E
  0FDB6C: 248f7efc  SUB     0xFC7E, ONES
  0FDB70: b9a4      MOVB    [R4], RL5
  0FDB72: f2f47efc  MOV     R4, 0xFC7E
  0FDB76: 248f7efc  SUB     0xFC7E, ONES
  0FDB7A: b9e4      MOVB    [R4], RL7
  0FDB7C: e7f83400  MOVB    RL4, #0x34
  0FDB80: f2f57efc  MOV     R5, 0xFC7E
  0FDB84: 248f7efc  SUB     0xFC7E, ONES
  0FDB88: b985      MOVB    [R5], RL4
  0FDB8A: 0d3e      JMPR    cc_UC, 0x0FDC08
loc_0FDB8C:
  0FDB8C: e7fc1000  MOVB    RL6, #0x10
  0FDB90: 0d3b      JMPR    cc_UC, 0x0FDC08
loc_0FDB92:
  0FDB92: f4880200  MOVB    RL4, [R8+#0x0002]
  0FDB96: 43f889fc  CMPB    RL4, 0xFC89
  0FDB9A: 3d11      JMPR    cc_NZ, 0x0FDBBE
  0FDB9C: f4880300  MOVB    RL4, [R8+#0x0003]
  0FDBA0: 43f888fc  CMPB    RL4, 0xFC88
  0FDBA4: 3d0c      JMPR    cc_NZ, 0x0FDBBE
  0FDBA6: f4880400  MOVB    RL4, [R8+#0x0004]
  0FDBAA: 43f887fc  CMPB    RL4, 0xFC87
  0FDBAE: 3d07      JMPR    cc_NZ, 0x0FDBBE
  0FDBB0: f4880500  MOVB    RL4, [R8+#0x0005]
  0FDBB4: 43f886fc  CMPB    RL4, 0xFC86
  0FDBB8: 3d02      JMPR    cc_NZ, 0x0FDBBE
  0FDBBA: 8a250230  JB      0xFD4A.3, 0x0FDBC2
loc_0FDBBE:
  0FDBBE: 8a251720  JB      0xFD4A.2, 0x0FDBF0
loc_0FDBC2:
  0FDBC2: 2e25      BCLR    0xFD4A.2
  0FDBC4: da00d84a  CALLS   0x004AD8    ; -> rom_4AD8
  0FDBC8: e7f86700  MOVB    RL4, #0x67
  0FDBCC: f2f57efc  MOV     R5, 0xFC7E
  0FDBD0: 248f7efc  SUB     0xFC7E, ONES
  0FDBD4: b985      MOVB    [R5], RL4
  0FDBD6: f2f47efc  MOV     R4, 0xFC7E
  0FDBDA: 248f7efc  SUB     0xFC7E, ONES
  0FDBDE: b9e4      MOVB    [R4], RL7
  0FDBE0: e7f83400  MOVB    RL4, #0x34
  0FDBE4: f2f57efc  MOV     R5, 0xFC7E
  0FDBE8: 248f7efc  SUB     0xFC7E, ONES
  0FDBEC: b985      MOVB    [R5], RL4
  0FDBEE: 0d0c      JMPR    cc_UC, 0x0FDC08
loc_0FDBF0:
  0FDBF0: f68f6efc  MOV     0xFC6E, ONES
  0FDBF4: e7fc3500  MOVB    RL6, #0x35
  0FDBF8: 0d07      JMPR    cc_UC, 0x0FDC08
loc_0FDBFA:
  0FDBFA: f68f6efc  MOV     0xFC6E, ONES
  0FDBFE: e7fc1000  MOVB    RL6, #0x10
  0FDC02: 0d02      JMPR    cc_UC, 0x0FDC08
loc_0FDC04:
  0FDC04: e7fc3700  MOVB    RL6, #0x37
loc_0FDC08:
  0FDC08: f2f47efc  MOV     R4, 0xFC7E
  0FDC0C: f6f46afc  MOV     0xFC6A, R4
  0FDC10: 49c0      CMPB    RL6, #0
  0FDC12: 2d04      JMPR    cc_Z, 0x0FDC1C
  0FDC14: 2f25      BSET    0xFD4A.2
  0FDC16: c0cc      MOVBZ   R12, RL6
  0FDC18: da0faceb  CALLS   0x0FEBAC
loc_0FDC1C:
  0FDC1C: 0802      ADD     R0, #2
  0FDC1E: 9890      MOV     R9, [R0+]
  0FDC20: 9880      MOV     R8, [R0+]
  0FDC22: 9870      MOV     R7, [R0+]
  0FDC24: 9860      MOV     R6, [R0+]
  0FDC26: db00      RETS
loc_0FDC28:
  0FDC28: 8860      MOV     [-R0], R6
  0FDC2A: 8880      MOV     [-R0], R8
  0FDC2C: 8890      MOV     [-R0], R9
  0FDC2E: f2f978fc  MOV     R9, 0xFC78
  0FDC32: e6f852fb  MOV     R8, #0xFB52
  0FDC36: e10c      MOVB    RL6, #0
  0FDC38: 9a250670  JNB     0xFD4A.7, 0x0FDC48
  0FDC3C: e6fc4000  MOV     R12, #0x0040
  0FDC40: da0faceb  CALLS   0x0FEBAC
  0FDC44: ea0062dd  JMPA    cc_UC, 0x0FDD62
loc_0FDC48:
  0FDC48: d7500100  EXTP    #0x001, #2
  0FDC4C: f2f4e437  MOV     R4, 0x37E4
  0FDC50: f2f5e637  MOV     R5, 0x37E6
  0FDC54: dc45      EXTP    R5, #1
  0FDC56: a824      MOV     R2, [R4]
  0FDC58: 6821      AND     R2, #1
  0FDC5A: 9af20200  JNB     R2.0, 0x0FDC62
  0FDC5E: 76f2feff  OR      R2, #0xFFFE
loc_0FDC62:
  0FDC62: 4820      CMP     R2, #0
  0FDC64: 3d06      JMPR    cc_NZ, 0x0FDC72
  0FDC66: e6fc3300  MOV     R12, #0x0033
  0FDC6A: da0faceb  CALLS   0x0FEBAC
  0FDC6E: ea0062dd  JMPA    cc_UC, 0x0FDD62
loc_0FDC72:
  0FDC72: ae25      BCLR    0xFD4A.10
  0FDC74: f4890400  MOVB    RL4, [R9+#0x0004]
  0FDC78: 4986      CMPB    RL4, #6
  0FDC7A: 2d07      JMPR    cc_Z, 0x0FDC8A
  0FDC7C: 4980      CMPB    RL4, #0
  0FDC7E: 2d05      JMPR    cc_Z, 0x0FDC8A
  0FDC80: e6fc1100  MOV     R12, #0x0011
  0FDC84: da0faceb  CALLS   0x0FEBAC
  0FDC88: 0d6c      JMPR    cc_UC, 0x0FDD62
loc_0FDC8A:
  0FDC8A: e7f86000  MOVB    RL4, #0x60
  0FDC8E: f7f8bcf9  MOVB    0xF9BC, RL4
  0FDC92: 7f25      BSET    0xFD4A.7
  0FDC94: 9f25      BSET    0xFD4A.9
  0FDC96: d7500100  EXTP    #0x001, #2
  0FDC9A: f2f4e437  MOV     R4, 0x37E4
  0FDC9E: f2f5e637  MOV     R5, 0x37E6
  0FDCA2: f6f500fe  MOV     0xFE00, R5
  0FDCA6: cc00      NOP
  0FDCA8: a824      MOV     R2, [R4]
  0FDCAA: 6821      AND     R2, #1
  0FDCAC: b824      MOV     [R4], R2
  0FDCAE: e6003c00  MOV     DPP0, #0x003C
  0FDCB2: cc00      NOP
  0FDCB4: f68e04dc  MOV     0xDC04, ZEROS
  0FDCB8: f4890100  MOVB    RL4, [R9+#0x0001]
  0FDCBC: f2f5e6fa  MOV     R5, 0xFAE6
  0FDCC0: b985      MOVB    [R5], RL4
  0FDCC2: f4890200  MOVB    RL4, [R9+#0x0002]
  0FDCC6: f2f5e6fa  MOV     R5, 0xFAE6
  0FDCCA: e4850100  MOVB    [R5+#0x0001], RL4
  0FDCCE: f4890300  MOVB    RL4, [R9+#0x0003]
  0FDCD2: f2f5e6fa  MOV     R5, 0xFAE6
  0FDCD6: e4850200  MOVB    [R5+#0x0002], RL4
  0FDCDA: f2f4e6fa  MOV     R4, 0xFAE6
  0FDCDE: a9a4      MOVB    RL5, [R4]
  0FDCE0: 47fa0f00  CMPB    RL5, #0x0F
  0FDCE4: 8d08      JMPR    cc_C, 0x0FDCF6
  0FDCE6: f4a40100  MOVB    RL5, [R4+#0x0001]
  0FDCEA: 47faf900  CMPB    RL5, #0xF9
  0FDCEE: 8d03      JMPR    cc_C, 0x0FDCF6
  0FDCF0: e118      MOVB    RL4, #1
  0FDCF2: f7f868fc  MOVB    0xFC68, RL4
loc_0FDCF6:
  0FDCF6: f4890500  MOVB    RL4, [R9+#0x0005]
  0FDCFA: f7f8bdf9  MOVB    0xF9BD, RL4
  0FDCFE: f78ebef9  MOVB    0xF9BE, ZEROS
  0FDD02: f4a90600  MOVB    RL5, [R9+#0x0006]
  0FDD06: f7fabff9  MOVB    0xF9BF, RL5
  0FDD0A: f4690700  MOVB    RL3, [R9+#0x0007]
  0FDD0E: f7f6c0f9  MOVB    0xF9C0, RL3
  0FDD12: f4490800  MOVB    RL2, [R9+#0x0008]
  0FDD16: f7f4c1f9  MOVB    0xF9C1, RL2
  0FDD1A: da0fd0e5  CALLS   0x0FE5D0
  0FDD1E: f1c8      MOVB    RL6, RL4
  0FDD20: f2f4e6fa  MOV     R4, 0xFAE6
  0FDD24: f4a40200  MOVB    RL5, [R4+#0x0002]
  0FDD28: 69a1      ANDB    RL5, #1
  0FDD2A: f3f8c1f9  MOVB    RL4, 0xF9C1
  0FDD2E: 6981      ANDB    RL4, #1
  0FDD30: 71a8      ORB     RL5, RL4
  0FDD32: 2d02      JMPR    cc_Z, 0x0FDD38
  0FDD34: e7fc3100  MOVB    RL6, #0x31
loc_0FDD38:
  0FDD38: 49c0      CMPB    RL6, #0
  0FDD3A: 2d07      JMPR    cc_Z, 0x0FDD4A
  0FDD3C: 7e25      BCLR    0xFD4A.7
  0FDD3E: f78e68fc  MOVB    0xFC68, ZEROS
  0FDD42: c0cc      MOVBZ   R12, RL6
  0FDD44: da0faceb  CALLS   0x0FEBAC
  0FDD48: 0d0c      JMPR    cc_UC, 0x0FDD62
loc_0FDD4A:
  0FDD4A: e7f87400  MOVB    RL4, #0x74
  0FDD4E: f058      MOV     R5, R8
  0FDD50: 0881      ADD     R8, #1
  0FDD52: b985      MOVB    [R5], RL4
  0FDD54: e7f8ef00  MOVB    RL4, #0xEF
  0FDD58: f058      MOV     R5, R8
  0FDD5A: 0881      ADD     R8, #1
  0FDD5C: b985      MOVB    [R5], RL4
  0FDD5E: f6f86afc  MOV     0xFC6A, R8
loc_0FDD62:
  0FDD62: 9890      MOV     R9, [R0+]
  0FDD64: 9880      MOV     R8, [R0+]
  0FDD66: 9860      MOV     R6, [R0+]
  0FDD68: db00      RETS
loc_0FDD6A:
  0FDD6A: 8860      MOV     [-R0], R6
  0FDD6C: 8870      MOV     [-R0], R7
  0FDD6E: 8890      MOV     [-R0], R9
  0FDD70: e10c      MOVB    RL6, #0
  0FDD72: f2f978fc  MOV     R9, 0xFC78
  0FDD76: e6f452fb  MOV     R4, #0xFB52
  0FDD7A: f6f47efc  MOV     0xFC7E, R4
  0FDD7E: f4e90100  MOVB    RL7, [R9+#0x0001]
  0FDD82: e10c      MOVB    RL6, #0
  0FDD84: f3f89dfc  MOVB    RL4, 0xFC9D
  0FDD88: 47f8a200  CMPB    RL4, #0xA2
  0FDD8C: 3d08      JMPR    cc_NZ, 0x0FDD9E
  0FDD8E: e7fae200  MOVB    RL5, #0xE2
  0FDD92: f2f47efc  MOV     R4, 0xFC7E
  0FDD96: 248f7efc  SUB     0xFC7E, ONES
  0FDD9A: b9a4      MOVB    [R4], RL5
  0FDD9C: 0d12      JMPR    cc_UC, 0x0FDDC2
loc_0FDD9E:
  0FDD9E: 47fe8000  CMPB    RL7, #0x80
  0FDDA2: 2d03      JMPR    cc_Z, 0x0FDDAA
  0FDDA4: e7fc1200  MOVB    RL6, #0x12
  0FDDA8: 0d0c      JMPR    cc_UC, 0x0FDDC2
loc_0FDDAA:
  0FDDAA: e7f85a00  MOVB    RL4, #0x5A
  0FDDAE: f2f57efc  MOV     R5, 0xFC7E
  0FDDB2: 248f7efc  SUB     0xFC7E, ONES
  0FDDB6: b985      MOVB    [R5], RL4
  0FDDB8: f2f47efc  MOV     R4, 0xFC7E
  0FDDBC: 248f7efc  SUB     0xFC7E, ONES
  0FDDC0: b9e4      MOVB    [R4], RL7
loc_0FDDC2:
  0FDDC2: da0ff8e7  CALLS   0x0FE7F8
  0FDDC6: f2f47efc  MOV     R4, 0xFC7E
  0FDDCA: f6f46afc  MOV     0xFC6A, R4
  0FDDCE: 49c0      CMPB    RL6, #0
  0FDDD0: 2d03      JMPR    cc_Z, 0x0FDDD8
  0FDDD2: c0cc      MOVBZ   R12, RL6
  0FDDD4: da0faceb  CALLS   0x0FEBAC
loc_0FDDD8:
  0FDDD8: 9890      MOV     R9, [R0+]
  0FDDDA: 9870      MOV     R7, [R0+]
  0FDDDC: 9860      MOV     R6, [R0+]
  0FDDDE: db00      RETS
loc_0FDDE0:
  0FDDE0: 8860      MOV     [-R0], R6
  0FDDE2: 8870      MOV     [-R0], R7
  0FDDE4: 8880      MOV     [-R0], R8
  0FDDE6: 8890      MOV     [-R0], R9
  0FDDE8: 26f00c00  SUB     R0, #0x000C
  0FDDEC: e10e      MOVB    RL7, #0
  0FDDEE: f2f478fc  MOV     R4, 0xFC78
  0FDDF2: c4400600  MOV     [R0+#0x0006], R4
  0FDDF6: e6f552fb  MOV     R5, #0xFB52
  0FDDFA: f6f57efc  MOV     0xFC7E, R5
  0FDDFE: f4a40100  MOVB    RL5, [R4+#0x0001]
  0FDE02: f085      MOV     R8, R5
  0FDE04: e10e      MOVB    RL7, #0
  0FDE06: f048      MOV     R4, R8
  0FDE08: 4981      CMPB    RL4, #1
  0FDE0A: 2d03      JMPR    cc_Z, 0x0FDE12
  0FDE0C: e7fe1200  MOVB    RL7, #0x12
  0FDE10: 0d0d      JMPR    cc_UC, 0x0FDE2C
loc_0FDE12:
  0FDE12: e7f86100  MOVB    RL4, #0x61
  0FDE16: f2f57efc  MOV     R5, 0xFC7E
  0FDE1A: 248f7efc  SUB     0xFC7E, ONES
  0FDE1E: b985      MOVB    [R5], RL4
  0FDE20: f048      MOV     R4, R8
  0FDE22: f2f57efc  MOV     R5, 0xFC7E
  0FDE26: 248f7efc  SUB     0xFC7E, ONES
  0FDE2A: b985      MOVB    [R5], RL4
loc_0FDE2C:
  0FDE2C: 49e0      CMPB    RL7, #0
  0FDE2E: 3d08      JMPR    cc_NZ, 0x0FDE40
  0FDE30: e6f45a2d  MOV     R4, #0x2D5A
  0FDE34: e6f53f00  MOV     R5, #0x003F
  0FDE38: c4400800  MOV     [R0+#0x0008], R4
  0FDE3C: c4500a00  MOV     [R0+#0x000A], R5
loc_0FDE40:
  0FDE40: e6fc8000  MOV     R12, #0x0080
  0FDE44: d4d00800  MOV     R13, [R0+#0x0008]
  0FDE48: d4e00a00  MOV     R14, [R0+#0x000A]
  0FDE4C: da008654  CALLS   0x005486    ; -> rom_5486
  0FDE50: f1e8      MOVB    RL7, RL4
  0FDE52: 2d04      JMPR    cc_Z, 0x0FDE5C
  0FDE54: c0ec      MOVBZ   R12, RL7
  0FDE56: da0faceb  CALLS   0x0FEBAC
  0FDE5A: 0d5b      JMPR    cc_UC, 0x0FDF12
loc_0FDE5C:
  0FDE5C: e6f952fb  MOV     R9, #0xFB52
  0FDE60: e12c      MOVB    RL6, #2
loc_0FDE62:
  0FDE62: c0c4      MOVBZ   R4, RL6
  0FDE64: f059      MOV     R5, R9
  0FDE66: 0054      ADD     R5, R4
  0FDE68: a985      MOVB    RL4, [R5]
  0FDE6A: e4800400  MOVB    [R0+#0x0004], RL4
  0FDE6E: c0c4      MOVBZ   R4, RL6
  0FDE70: f059      MOV     R5, R9
  0FDE72: 0054      ADD     R5, R4
  0FDE74: f4850200  MOVB    RL4, [R5+#0x0002]
  0FDE78: c0c5      MOVBZ   R5, RL6
  0FDE7A: f029      MOV     R2, R9
  0FDE7C: 0025      ADD     R2, R5
  0FDE7E: b982      MOVB    [R2], RL4
  0FDE80: f4800400  MOVB    RL4, [R0+#0x0004]
  0FDE84: c0c5      MOVBZ   R5, RL6
  0FDE86: f029      MOV     R2, R9
  0FDE88: 0025      ADD     R2, R5
  0FDE8A: e4820200  MOVB    [R2+#0x0002], RL4
  0FDE8E: 09c3      ADDB    RL6, #3
  0FDE90: 47fc4a00  CMPB    RL6, #0x4A
  0FDE94: 8de6      JMPR    cc_C, 0x0FDE62
  0FDE96: d7503e00  EXTP    #0x03E, #2
  0FDE9A: f2f4943c  MOV     R4, 0x3C94
  0FDE9E: f2f5963c  MOV     R5, 0x3C96
  0FDEA2: f0a4      MOV     R10, R4
  0FDEA4: f0b5      MOV     R11, R5
  0FDEA6: 5ceb      SHL     R11, #14
  0FDEA8: 70ab      OR      R10, R11
  0FDEAA: f0b5      MOV     R11, R5
  0FDEAC: 7c2b      SHR     R11, #2
  0FDEAE: b8a0      MOV     [R0], R10
  0FDEB0: c4b00200  MOV     [R0+#0x0002], R11
  0FDEB4: f0ab      MOV     R10, R11
  0FDEB6: f2fb1cff  MOV     R11, 0xFF1C
  0FDEBA: f04a      MOV     R4, R10
  0FDEBC: f2f27efc  MOV     R2, 0xFC7E
  0FDEC0: 248f7efc  SUB     0xFC7E, ONES
  0FDEC4: b982      MOVB    [R2], RL4
  0FDEC6: a840      MOV     R4, [R0]
  0FDEC8: d4500200  MOV     R5, [R0+#0x0002]
  0FDECC: f189      MOVB    RL4, RH4
  0FDECE: f19a      MOVB    RH4, RL5
  0FDED0: 7c85      SHR     R5, #8
  0FDED2: f2f57efc  MOV     R5, 0xFC7E
  0FDED6: 248f7efc  SUB     0xFC7E, ONES
  0FDEDA: b985      MOVB    [R5], RL4
  0FDEDC: a980      MOVB    RL4, [R0]
  0FDEDE: f2f57efc  MOV     R5, 0xFC7E
  0FDEE2: 248f7efc  SUB     0xFC7E, ONES
  0FDEE6: b985      MOVB    [R5], RL4
  0FDEE8: e7f8ff00  MOVB    RL4, #0xFF
  0FDEEC: f2f57efc  MOV     R5, 0xFC7E
  0FDEF0: 248f7efc  SUB     0xFC7E, ONES
  0FDEF4: b985      MOVB    [R5], RL4
  0FDEF6: f2f57efc  MOV     R5, 0xFC7E
  0FDEFA: 248f7efc  SUB     0xFC7E, ONES
  0FDEFE: b985      MOVB    [R5], RL4
  0FDF00: f2f57efc  MOV     R5, 0xFC7E
  0FDF04: 248f7efc  SUB     0xFC7E, ONES
  0FDF08: b985      MOVB    [R5], RL4
  0FDF0A: f2f47efc  MOV     R4, 0xFC7E
  0FDF0E: f6f46afc  MOV     0xFC6A, R4
loc_0FDF12:
  0FDF12: 06f00c00  ADD     R0, #0x000C
  0FDF16: 9890      MOV     R9, [R0+]
  0FDF18: 9880      MOV     R8, [R0+]
  0FDF1A: 9870      MOV     R7, [R0+]
  0FDF1C: 9860      MOV     R6, [R0+]
  0FDF1E: db00      RETS
loc_0FDF20:
  0FDF20: 8860      MOV     [-R0], R6
  0FDF22: 8880      MOV     [-R0], R8
  0FDF24: 8890      MOV     [-R0], R9
  0FDF26: 2802      SUB     R0, #2
  0FDF28: d7500100  EXTP    #0x001, #2
  0FDF2C: f2f4e437  MOV     R4, 0x37E4
  0FDF30: f2f5e637  MOV     R5, 0x37E6
  0FDF34: dc45      EXTP    R5, #1
  0FDF36: a824      MOV     R2, [R4]
  0FDF38: b820      MOV     [R0], R2
  0FDF3A: f2f878fc  MOV     R8, 0xFC78
  0FDF3E: e6f952fb  MOV     R9, #0xFB52
  0FDF42: 8a2502a0  JB      0xFD4A.10, 0x0FDF4A
  0FDF46: 8a251470  JB      0xFD4A.7, 0x0FDF72
loc_0FDF4A:
  0FDF4A: 7e25      BCLR    0xFD4A.7
  0FDF4C: a840      MOV     R4, [R0]
  0FDF4E: 0af40404  BFLDL   R4, #0x04, #0x04
  0FDF52: b840      MOV     [R0], R4
  0FDF54: e6fc2200  MOV     R12, #0x0022
  0FDF58: da0faceb  CALLS   0x0FEBAC
  0FDF5C: a840      MOV     R4, [R0]
  0FDF5E: d7500100  EXTP    #0x001, #2
  0FDF62: f2fae437  MOV     R10, 0x37E4
  0FDF66: f2fbe637  MOV     R11, 0x37E6
  0FDF6A: dc4b      EXTP    R11, #1
  0FDF6C: b84a      MOV     [R10], R4
  0FDF6E: ea00c8e1  JMPA    cc_UC, 0x0FE1C8
loc_0FDF72:
  0FDF72: a840      MOV     R4, [R0]
  0FDF74: 6842      AND     R4, #2
  0FDF76: 3d76      JMPR    cc_NZ, 0x0FE064
  0FDF78: f3f89cfc  MOVB    RL4, 0xFC9C
  0FDF7C: 2981      SUBB    RL4, #1
  0FDF7E: f2f5e6fa  MOV     R5, 0xFAE6
  0FDF82: e4850300  MOVB    [R5+#0x0003], RL4
  0FDF86: f2f4e6fa  MOV     R4, 0xFAE6
  0FDF8A: f4a40300  MOVB    RL5, [R4+#0x0003]
  0FDF8E: 69a1      ANDB    RL5, #1
  0FDF90: 2d16      JMPR    cc_Z, 0x0FDFBE
  0FDF92: 7e25      BCLR    0xFD4A.7
  0FDF94: f78e68fc  MOVB    0xFC68, ZEROS
  0FDF98: a850      MOV     R5, [R0]
  0FDF9A: 0af50404  BFLDL   R5, #0x04, #0x04
  0FDF9E: b850      MOV     [R0], R5
  0FDFA0: e6fc1000  MOV     R12, #0x0010
  0FDFA4: da0faceb  CALLS   0x0FEBAC
  0FDFA8: a840      MOV     R4, [R0]
  0FDFAA: d7500100  EXTP    #0x001, #2
  0FDFAE: f2fae437  MOV     R10, 0x37E4
  0FDFB2: f2fbe637  MOV     R11, 0x37E6
  0FDFB6: dc4b      EXTP    R11, #1
  0FDFB8: b84a      MOV     [R10], R4
  0FDFBA: ea00c8e1  JMPA    cc_UC, 0x0FE1C8
loc_0FDFBE:
  0FDFBE: e108      MOVB    RL4, #0
  0FDFC0: f2f5e6fa  MOV     R5, 0xFAE6
  0FDFC4: e4850400  MOVB    [R5+#0x0004], RL4
  0FDFC8: f1c8      MOVB    RL6, RL4
  0FDFCA: 0d0c      JMPR    cc_UC, 0x0FDFE4
loc_0FDFCC:
  0FDFCC: c0c4      MOVBZ   R4, RL6
  0FDFCE: f058      MOV     R5, R8
  0FDFD0: 0054      ADD     R5, R4
  0FDFD2: f4850100  MOVB    RL4, [R5+#0x0001]
  0FDFD6: c0c5      MOVBZ   R5, RL6
  0FDFD8: f2f2e6fa  MOV     R2, 0xFAE6
  0FDFDC: 0025      ADD     R2, R5
  0FDFDE: e4820600  MOVB    [R2+#0x0006], RL4
  0FDFE2: 09c1      ADDB    RL6, #1
loc_0FDFE4:
  0FDFE4: f2f4e6fa  MOV     R4, 0xFAE6
  0FDFE8: f4a40300  MOVB    RL5, [R4+#0x0003]
  0FDFEC: 41ca      CMPB    RL6, RL5
  0FDFEE: 8dee      JMPR    cc_C, 0x0FDFCC
  0FDFF0: 248f04dc  SUB     0xDC04, ONES
  0FDFF4: e7f87600  MOVB    RL4, #0x76
  0FDFF8: f059      MOV     R5, R9
  0FDFFA: 0891      ADD     R9, #1
  0FDFFC: b985      MOVB    [R5], RL4
  0FDFFE: f049      MOV     R4, R9
  0FE000: 0891      ADD     R9, #1
  0FE002: a40405dc  MOVB    [R4], 0xDC05
  0FE006: f049      MOV     R4, R9
  0FE008: 0891      ADD     R9, #1
  0FE00A: a40404dc  MOVB    [R4], 0xDC04
  0FE00E: e118      MOVB    RL4, #1
  0FE010: f059      MOV     R5, R9
  0FE012: 0891      ADD     R9, #1
  0FE014: b985      MOVB    [R5], RL4
  0FE016: f6f96afc  MOV     0xFC6A, R9
  0FE01A: a840      MOV     R4, [R0]
  0FE01C: d7500100  EXTP    #0x001, #2
  0FE020: f2fae437  MOV     R10, 0x37E4
  0FE024: f2fbe637  MOV     R11, 0x37E6
  0FE028: dc4b      EXTP    R11, #1
  0FE02A: b84a      MOV     [R10], R4
  0FE02C: d7500100  EXTP    #0x001, #2
  0FE030: f2f4e437  MOV     R4, 0x37E4
  0FE034: f2f5e637  MOV     R5, 0x37E6
  0FE038: f6f500fe  MOV     0xFE00, R5
  0FE03C: cc00      NOP
  0FE03E: a824      MOV     R2, [R4]
  0FE040: 6821      AND     R2, #1
  0FE042: b824      MOV     [R4], R2
  0FE044: e6003c00  MOV     DPP0, #0x003C
  0FE048: d7500100  EXTP    #0x001, #2
  0FE04C: f2f4e437  MOV     R4, 0x37E4
  0FE050: f2f5e637  MOV     R5, 0x37E6
  0FE054: dc45      EXTP    R5, #1
  0FE056: a824      MOV     R2, [R4]
  0FE058: 0af20202  BFLDL   R2, #0x02, #0x02
  0FE05C: dc45      EXTP    R5, #1
  0FE05E: b824      MOV     [R4], R2
  0FE060: ea00c8e1  JMPA    cc_UC, 0x0FE1C8
loc_0FE064:
  0FE064: a840      MOV     R4, [R0]
  0FE066: 66f42000  AND     R4, #0x0020
  0FE06A: 2d30      JMPR    cc_Z, 0x0FE0CC
  0FE06C: a840      MOV     R4, [R0]
  0FE06E: 66f48000  AND     R4, #0x0080
  0FE072: 3d14      JMPR    cc_NZ, 0x0FE09C
  0FE074: 248f04dc  SUB     0xDC04, ONES
  0FE078: e7f87600  MOVB    RL4, #0x76
  0FE07C: f059      MOV     R5, R9
  0FE07E: 0891      ADD     R9, #1
  0FE080: b985      MOVB    [R5], RL4
  0FE082: f049      MOV     R4, R9
  0FE084: 0891      ADD     R9, #1
  0FE086: a40405dc  MOVB    [R4], 0xDC05
  0FE08A: f049      MOV     R4, R9
  0FE08C: 0891      ADD     R9, #1
  0FE08E: a40404dc  MOVB    [R4], 0xDC04
  0FE092: e118      MOVB    RL4, #1
  0FE094: f059      MOV     R5, R9
  0FE096: 0891      ADD     R9, #1
  0FE098: b985      MOVB    [R5], RL4
  0FE09A: 0d14      JMPR    cc_UC, 0x0FE0C4
loc_0FE09C:
  0FE09C: 7e25      BCLR    0xFD4A.7
  0FE09E: 248f04dc  SUB     0xDC04, ONES
  0FE0A2: e7f87600  MOVB    RL4, #0x76
  0FE0A6: f059      MOV     R5, R9
  0FE0A8: 0891      ADD     R9, #1
  0FE0AA: b985      MOVB    [R5], RL4
  0FE0AC: f049      MOV     R4, R9
  0FE0AE: 0891      ADD     R9, #1
  0FE0B0: a40405dc  MOVB    [R4], 0xDC05
  0FE0B4: f049      MOV     R4, R9
  0FE0B6: 0891      ADD     R9, #1
  0FE0B8: a40404dc  MOVB    [R4], 0xDC04
  0FE0BC: e128      MOVB    RL4, #2
  0FE0BE: f059      MOV     R5, R9
  0FE0C0: 0891      ADD     R9, #1
  0FE0C2: b985      MOVB    [R5], RL4
loc_0FE0C4:
  0FE0C4: f6f96afc  MOV     0xFC6A, R9
  0FE0C8: ea00b6e1  JMPA    cc_UC, 0x0FE1B6
loc_0FE0CC:
  0FE0CC: a840      MOV     R4, [R0]
  0FE0CE: 66f41000  AND     R4, #0x0010
  0FE0D2: 2d70      JMPR    cc_Z, 0x0FE1B4
  0FE0D4: a840      MOV     R4, [R0]
  0FE0D6: 66f4efff  AND     R4, #0xFFEF
  0FE0DA: b840      MOV     [R0], R4
  0FE0DC: a850      MOV     R5, [R0]
  0FE0DE: 66f58000  AND     R5, #0x0080
  0FE0E2: 3d4f      JMPR    cc_NZ, 0x0FE182
  0FE0E4: f3f89cfc  MOVB    RL4, 0xFC9C
  0FE0E8: 2981      SUBB    RL4, #1
  0FE0EA: f2f5e6fa  MOV     R5, 0xFAE6
  0FE0EE: e4850300  MOVB    [R5+#0x0003], RL4
  0FE0F2: f2f4e6fa  MOV     R4, 0xFAE6
  0FE0F6: f4a40300  MOVB    RL5, [R4+#0x0003]
  0FE0FA: 69a1      ANDB    RL5, #1
  0FE0FC: 2d15      JMPR    cc_Z, 0x0FE128
  0FE0FE: 7e25      BCLR    0xFD4A.7
  0FE100: f78e68fc  MOVB    0xFC68, ZEROS
  0FE104: a850      MOV     R5, [R0]
  0FE106: 0af50404  BFLDL   R5, #0x04, #0x04
  0FE10A: b850      MOV     [R0], R5
  0FE10C: e6fc1000  MOV     R12, #0x0010
  0FE110: da0faceb  CALLS   0x0FEBAC
  0FE114: a840      MOV     R4, [R0]
  0FE116: d7500100  EXTP    #0x001, #2
  0FE11A: f2fae437  MOV     R10, 0x37E4
  0FE11E: f2fbe637  MOV     R11, 0x37E6
  0FE122: dc4b      EXTP    R11, #1
  0FE124: b84a      MOV     [R10], R4
  0FE126: 0d50      JMPR    cc_UC, 0x0FE1C8
loc_0FE128:
  0FE128: e108      MOVB    RL4, #0
  0FE12A: f2f5e6fa  MOV     R5, 0xFAE6
  0FE12E: e4850400  MOVB    [R5+#0x0004], RL4
  0FE132: f1c8      MOVB    RL6, RL4
  0FE134: 0d0c      JMPR    cc_UC, 0x0FE14E
loc_0FE136:
  0FE136: c0c4      MOVBZ   R4, RL6
  0FE138: f058      MOV     R5, R8
  0FE13A: 0054      ADD     R5, R4
  0FE13C: f4850100  MOVB    RL4, [R5+#0x0001]
  0FE140: c0c5      MOVBZ   R5, RL6
  0FE142: f2f2e6fa  MOV     R2, 0xFAE6
  0FE146: 0025      ADD     R2, R5
  0FE148: e4820600  MOVB    [R2+#0x0006], RL4
  0FE14C: 09c1      ADDB    RL6, #1
loc_0FE14E:
  0FE14E: f2f4e6fa  MOV     R4, 0xFAE6
  0FE152: f4a40300  MOVB    RL5, [R4+#0x0003]
  0FE156: 41ca      CMPB    RL6, RL5
  0FE158: 8dee      JMPR    cc_C, 0x0FE136
  0FE15A: 248f04dc  SUB     0xDC04, ONES
  0FE15E: e7f87600  MOVB    RL4, #0x76
  0FE162: f059      MOV     R5, R9
  0FE164: 0891      ADD     R9, #1
  0FE166: b985      MOVB    [R5], RL4
  0FE168: f049      MOV     R4, R9
  0FE16A: 0891      ADD     R9, #1
  0FE16C: a40405dc  MOVB    [R4], 0xDC05
  0FE170: f049      MOV     R4, R9
  0FE172: 0891      ADD     R9, #1
  0FE174: a40404dc  MOVB    [R4], 0xDC04
  0FE178: e118      MOVB    RL4, #1
  0FE17A: f059      MOV     R5, R9
  0FE17C: 0891      ADD     R9, #1
  0FE17E: b985      MOVB    [R5], RL4
  0FE180: 0d16      JMPR    cc_UC, 0x0FE1AE
loc_0FE182:
  0FE182: 7e25      BCLR    0xFD4A.7
  0FE184: f78e68fc  MOVB    0xFC68, ZEROS
  0FE188: 248f04dc  SUB     0xDC04, ONES
  0FE18C: e7f87600  MOVB    RL4, #0x76
  0FE190: f059      MOV     R5, R9
  0FE192: 0891      ADD     R9, #1
  0FE194: b985      MOVB    [R5], RL4
  0FE196: f049      MOV     R4, R9
  0FE198: 0891      ADD     R9, #1
  0FE19A: a40405dc  MOVB    [R4], 0xDC05
  0FE19E: f049      MOV     R4, R9
  0FE1A0: 0891      ADD     R9, #1
  0FE1A2: a40404dc  MOVB    [R4], 0xDC04
  0FE1A6: e128      MOVB    RL4, #2
  0FE1A8: f059      MOV     R5, R9
  0FE1AA: 0891      ADD     R9, #1
  0FE1AC: b985      MOVB    [R5], RL4
loc_0FE1AE:
  0FE1AE: f6f96afc  MOV     0xFC6A, R9
  0FE1B2: 0d01      JMPR    cc_UC, 0x0FE1B6
loc_0FE1B4:
  0FE1B4: de24      BCLR    0xFD48.13
loc_0FE1B6:
  0FE1B6: a840      MOV     R4, [R0]
  0FE1B8: d7500100  EXTP    #0x001, #2
  0FE1BC: f2fae437  MOV     R10, 0x37E4
  0FE1C0: f2fbe637  MOV     R11, 0x37E6
  0FE1C4: dc4b      EXTP    R11, #1
  0FE1C6: b84a      MOV     [R10], R4
loc_0FE1C8:
  0FE1C8: 0802      ADD     R0, #2
  0FE1CA: 9890      MOV     R9, [R0+]
  0FE1CC: 9880      MOV     R8, [R0+]
  0FE1CE: 9860      MOV     R6, [R0+]
  0FE1D0: db00      RETS
loc_0FE1D2:
  0FE1D2: 8860      MOV     [-R0], R6
  0FE1D4: 8870      MOV     [-R0], R7
  0FE1D6: 8880      MOV     [-R0], R8
  0FE1D8: 8890      MOV     [-R0], R9
  0FE1DA: f2f878fc  MOV     R8, 0xFC78
  0FE1DE: e6f952fb  MOV     R9, #0xFB52
  0FE1E2: f4c80100  MOVB    RL6, [R8+#0x0001]
  0FE1E6: f4e80200  MOVB    RL7, [R8+#0x0002]
  0FE1EA: 47fceb00  CMPB    RL6, #0xEB
  0FE1EE: 3d14      JMPR    cc_NZ, 0x0FE218
  0FE1F0: 49e1      CMPB    RL7, #1
  0FE1F2: 3d12      JMPR    cc_NZ, 0x0FE218
  0FE1F4: e7f87000  MOVB    RL4, #0x70
  0FE1F8: f059      MOV     R5, R9
  0FE1FA: 0891      ADD     R9, #1
  0FE1FC: b985      MOVB    [R5], RL4
  0FE1FE: f049      MOV     R4, R9
  0FE200: 0891      ADD     R9, #1
  0FE202: b9c4      MOVB    [R4], RL6
  0FE204: f049      MOV     R4, R9
  0FE206: 0891      ADD     R9, #1
  0FE208: b9e4      MOVB    [R4], RL7
  0FE20A: f049      MOV     R4, R9
  0FE20C: 0891      ADD     R9, #1
  0FE20E: a40407dc  MOVB    [R4], 0xDC07
  0FE212: f6f96afc  MOV     0xFC6A, R9
  0FE216: 0d04      JMPR    cc_UC, 0x0FE220
loc_0FE218:
  0FE218: e6fc1200  MOV     R12, #0x0012
  0FE21C: da0faceb  CALLS   0x0FEBAC
loc_0FE220:
  0FE220: 9890      MOV     R9, [R0+]
  0FE222: 9880      MOV     R8, [R0+]
  0FE224: 9870      MOV     R7, [R0+]
  0FE226: 9860      MOV     R6, [R0+]
  0FE228: db00      RETS
loc_0FE22A:
  0FE22A: 8860      MOV     [-R0], R6
  0FE22C: 8870      MOV     [-R0], R7
  0FE22E: 8880      MOV     [-R0], R8
  0FE230: 8890      MOV     [-R0], R9
  0FE232: 26f00800  SUB     R0, #0x0008
  0FE236: f2f778fc  MOV     R7, 0xFC78
  0FE23A: e6f452fb  MOV     R4, #0xFB52
  0FE23E: c4400400  MOV     [R0+#0x0004], R4
  0FE242: f4870100  MOVB    RL4, [R7+#0x0001]
  0FE246: c088      MOVBZ   R8, RL4
  0FE248: e009      MOV     R9, #0
  0FE24A: f098      MOV     R9, R8
  0FE24C: f2f81cff  MOV     R8, 0xFF1C
  0FE250: f4870200  MOVB    RL4, [R7+#0x0002]
  0FE254: c084      MOVBZ   R4, RL4
  0FE256: 5c84      SHL     R4, #8
  0FE258: e005      MOV     R5, #0
  0FE25A: 0084      ADD     R8, R4
  0FE25C: 1095      ADDC    R9, R5
  0FE25E: f4870300  MOVB    RL4, [R7+#0x0003]
  0FE262: c08a      MOVBZ   R10, RL4
  0FE264: e00b      MOV     R11, #0
  0FE266: 008a      ADD     R8, R10
  0FE268: 109b      ADDC    R9, R11
  0FE26A: f4870400  MOVB    RL4, [R7+#0x0004]
  0FE26E: e4800600  MOVB    [R0+#0x0006], RL4
  0FE272: f4a70500  MOVB    RL5, [R7+#0x0005]
  0FE276: e4a00700  MOVB    [R0+#0x0007], RL5
  0FE27A: c0aa      MOVBZ   R10, RL5
  0FE27C: 00a8      ADD     R10, R8
  0FE27E: 10b9      ADDC    R11, R9
  0FE280: b8a0      MOV     [R0], R10
  0FE282: c4b00200  MOV     [R0+#0x0002], R11
  0FE286: e7fc3100  MOVB    RL6, #0x31
  0FE28A: 4980      CMPB    RL4, #0
  0FE28C: 2d02      JMPR    cc_Z, 0x0FE292
  0FE28E: 4986      CMPB    RL4, #6
  0FE290: 3d34      JMPR    cc_NZ, 0x0FE2FA
loc_0FE292:
  0FE292: 46f90f00  CMP     R9, #0x000F
  0FE296: 3d01      JMPR    cc_NZ, 0x0FE29A
  0FE298: 4880      CMP     R8, #0
loc_0FE29A:
  0FE29A: 8d08      JMPR    cc_C, 0x0FE2AC
  0FE29C: a840      MOV     R4, [R0]
  0FE29E: d4500200  MOV     R5, [R0+#0x0002]
  0FE2A2: 26f4ffbf  SUB     R4, #0xBFFF
  0FE2A6: 36f50f00  SUBC    R5, #0x000F
  0FE2AA: fd14      JMPR    cc_ULE, 0x0FE2D4
loc_0FE2AC:
  0FE2AC: 46f90d00  CMP     R9, #0x000D
  0FE2B0: 3d02      JMPR    cc_NZ, 0x0FE2B6
  0FE2B2: 46f800ff  CMP     R8, #0xFF00
loc_0FE2B6:
  0FE2B6: 8d08      JMPR    cc_C, 0x0FE2C8
  0FE2B8: a840      MOV     R4, [R0]
  0FE2BA: d4500200  MOV     R5, [R0+#0x0002]
  0FE2BE: 26f4ffff  SUB     R4, #0xFFFF
  0FE2C2: 36f50d00  SUBC    R5, #0x000D
  0FE2C6: fd06      JMPR    cc_ULE, 0x0FE2D4
loc_0FE2C8:
  0FE2C8: 46f90f00  CMP     R9, #0x000F
  0FE2CC: 3d02      JMPR    cc_NZ, 0x0FE2D2
  0FE2CE: 46f800ec  CMP     R8, #0xEC00
loc_0FE2D2:
  0FE2D2: 8d01      JMPR    cc_C, 0x0FE2D6
loc_0FE2D4:
  0FE2D4: e10c      MOVB    RL6, #0
loc_0FE2D6:
  0FE2D6: e6f400f9  MOV     R4, #0xF900
  0FE2DA: e6f50f00  MOV     R5, #0x000F
  0FE2DE: 2048      SUB     R4, R8
  0FE2E0: 3059      SUBC    R5, R9
  0FE2E2: ed0b      JMPR    cc_UGT, 0x0FE2FA
  0FE2E4: a840      MOV     R4, [R0]
  0FE2E6: d4500200  MOV     R5, [R0+#0x0002]
  0FE2EA: e6fa20fc  MOV     R10, #0xFC20
  0FE2EE: e6fb0f00  MOV     R11, #0x000F
  0FE2F2: 204a      SUB     R4, R10
  0FE2F4: 305b      SUBC    R5, R11
  0FE2F6: ed01      JMPR    cc_UGT, 0x0FE2FA
  0FE2F8: e10c      MOVB    RL6, #0
loc_0FE2FA:
  0FE2FA: 49c0      CMPB    RL6, #0
  0FE2FC: 2d04      JMPR    cc_Z, 0x0FE306
  0FE2FE: c0cc      MOVBZ   R12, RL6
  0FE300: da0faceb  CALLS   0x0FEBAC
  0FE304: 0d28      JMPR    cc_UC, 0x0FE356
loc_0FE306:
  0FE306: e7f86300  MOVB    RL4, #0x63
  0FE30A: d4500400  MOV     R5, [R0+#0x0004]
  0FE30E: 0851      ADD     R5, #1
  0FE310: c4500400  MOV     [R0+#0x0004], R5
  0FE314: 2851      SUB     R5, #1
  0FE316: b985      MOVB    [R5], RL4
  0FE318: 0d14      JMPR    cc_UC, 0x0FE342
loc_0FE31A:
  0FE31A: f048      MOV     R4, R8
  0FE31C: f059      MOV     R5, R9
  0FE31E: 0881      ADD     R8, #1
  0FE320: 1890      ADDC    R9, #0
  0FE322: 8840      MOV     [-R0], R4
  0FE324: 7ce4      SHR     R4, #14
  0FE326: 5c25      SHL     R5, #2
  0FE328: 7054      OR      R5, R4
  0FE32A: 9840      MOV     R4, [R0+]
  0FE32C: 66f4ff3f  AND     R4, #0x3FFF
  0FE330: dc45      EXTP    R5, #1
  0FE332: a964      MOVB    RL3, [R4]
  0FE334: d4400400  MOV     R4, [R0+#0x0004]
  0FE338: 0841      ADD     R4, #1
  0FE33A: c4400400  MOV     [R0+#0x0004], R4
  0FE33E: 2841      SUB     R4, #1
  0FE340: b964      MOVB    [R4], RL3
loc_0FE342:
  0FE342: a840      MOV     R4, [R0]
  0FE344: d4500200  MOV     R5, [R0+#0x0002]
  0FE348: 2048      SUB     R4, R8
  0FE34A: 3059      SUBC    R5, R9
  0FE34C: ede6      JMPR    cc_UGT, 0x0FE31A
  0FE34E: d4400400  MOV     R4, [R0+#0x0004]
  0FE352: f6f46afc  MOV     0xFC6A, R4
loc_0FE356:
  0FE356: 06f00800  ADD     R0, #0x0008
  0FE35A: 9890      MOV     R9, [R0+]
  0FE35C: 9880      MOV     R8, [R0+]
  0FE35E: 9870      MOV     R7, [R0+]
  0FE360: 9860      MOV     R6, [R0+]
  0FE362: db00      RETS
loc_0FE364:
  0FE364: 8860      MOV     [-R0], R6
  0FE366: 8870      MOV     [-R0], R7
  0FE368: 8880      MOV     [-R0], R8
  0FE36A: 8890      MOV     [-R0], R9
  0FE36C: 26f00800  SUB     R0, #0x0008
  0FE370: e10c      MOVB    RL6, #0
  0FE372: e6fc2c2c  MOV     R12, #0x2C2C
  0FE376: e6fd3f00  MOV     R13, #0x003F
  0FE37A: e08e      MOV     R14, #8
  0FE37C: da0f6eea  CALLS   0x0FEA6E
  0FE380: f7f80bdc  MOVB    0xDC0B, RL4
  0FE384: e6fc703f  MOV     R12, #0x3F70
  0FE388: e6fd3700  MOV     R13, #0x0037
  0FE38C: e0ce      MOV     R14, #12
  0FE38E: da0f6eea  CALLS   0x0FEA6E
  0FE392: f7f80cdc  MOVB    0xDC0C, RL4
  0FE396: e6fc983c  MOV     R12, #0x3C98
  0FE39A: e6fd3e00  MOV     R13, #0x003E
  0FE39E: e6fe1000  MOV     R14, #0x0010
  0FE3A2: da0f6eea  CALLS   0x0FEA6E
  0FE3A6: f7f80ddc  MOVB    0xDC0D, RL4
  0FE3AA: e6fc943f  MOV     R12, #0x3F94
  0FE3AE: e6fd3700  MOV     R13, #0x0037
  0FE3B2: e07e      MOV     R14, #7
  0FE3B4: da0f6eea  CALLS   0x0FEA6E
  0FE3B8: f7f80edc  MOVB    0xDC0E, RL4
  0FE3BC: e6fc452c  MOV     R12, #0x2C45
  0FE3C0: e6fd3f00  MOV     R13, #0x003F
  0FE3C4: e09e      MOV     R14, #9
  0FE3C6: da0f6eea  CALLS   0x0FEA6E
  0FE3CA: f7f80fdc  MOVB    0xDC0F, RL4
  0FE3CE: f3fa0cdc  MOVB    RL5, 0xDC0C
  0FE3D2: 3d01      JMPR    cc_NZ, 0x0FE3D6
  0FE3D4: e1ac      MOVB    RL6, #10
loc_0FE3D6:
  0FE3D6: f3f80bdc  MOVB    RL4, 0xDC0B
  0FE3DA: 63f80fdc  ANDB    RL4, 0xDC0F
  0FE3DE: 3d03      JMPR    cc_NZ, 0x0FE3E6
  0FE3E0: e19c      MOVB    RL6, #9
  0FE3E2: f78e0cdc  MOVB    0xDC0C, ZEROS
loc_0FE3E6:
  0FE3E6: 49c0      CMPB    RL6, #0
  0FE3E8: 3d2e      JMPR    cc_NZ, 0x0FE446
  0FE3EA: c2f40bdc  MOVBZ   R4, 0xDC0B
  0FE3EE: 5c34      SHL     R4, #3
  0FE3F0: e6f82c2c  MOV     R8, #0x2C2C
  0FE3F4: e6f93f00  MOV     R9, #0x003F
  0FE3F8: 0084      ADD     R8, R4
  0FE3FA: c2f40cdc  MOVBZ   R4, 0xDC0C
  0FE3FE: f054      MOV     R5, R4
  0FE400: 5c25      SHL     R5, #2
  0FE402: 2054      SUB     R5, R4
  0FE404: 5c25      SHL     R5, #2
  0FE406: e6fa703f  MOV     R10, #0x3F70
  0FE40A: e6fb3700  MOV     R11, #0x0037
  0FE40E: 00a5      ADD     R10, R5
  0FE410: b8a0      MOV     [R0], R10
  0FE412: c4b00200  MOV     [R0+#0x0002], R11
  0FE416: f3f80ddc  MOVB    RL4, 0xDC0D
  0FE41A: 3d01      JMPR    cc_NZ, 0x0FE41E
  0FE41C: e1dc      MOVB    RL6, #13
loc_0FE41E:
  0FE41E: e10e      MOVB    RL7, #0
loc_0FE420:
  0FE420: c0e4      MOVBZ   R4, RL7
  0FE422: a8a0      MOV     R10, [R0]
  0FE424: d4b00200  MOV     R11, [R0+#0x0002]
  0FE428: 00a4      ADD     R10, R4
  0FE42A: dc4b      EXTP    R11, #1
  0FE42C: a98a      MOVB    RL4, [R10]
  0FE42E: c0e5      MOVBZ   R5, RL7
  0FE430: f0a8      MOV     R10, R8
  0FE432: f0b9      MOV     R11, R9
  0FE434: 00a5      ADD     R10, R5
  0FE436: dc4b      EXTP    R11, #1
  0FE438: a9aa      MOVB    RL5, [R10]
  0FE43A: 41a8      CMPB    RL5, RL4
  0FE43C: 2d01      JMPR    cc_Z, 0x0FE440
  0FE43E: e1bc      MOVB    RL6, #11
loc_0FE440:
  0FE440: 09e1      ADDB    RL7, #1
  0FE442: 49e6      CMPB    RL7, #6
  0FE444: 8ded      JMPR    cc_C, 0x0FE420
loc_0FE446:
  0FE446: 49c0      CMPB    RL6, #0
  0FE448: 3d2f      JMPR    cc_NZ, 0x0FE4A8
  0FE44A: c2f40cdc  MOVBZ   R4, 0xDC0C
  0FE44E: f054      MOV     R5, R4
  0FE450: 5c25      SHL     R5, #2
  0FE452: 2054      SUB     R5, R4
  0FE454: 5c25      SHL     R5, #2
  0FE456: e6f8703f  MOV     R8, #0x3F70
  0FE45A: e6f93700  MOV     R9, #0x0037
  0FE45E: 0085      ADD     R8, R5
  0FE460: c2f40ddc  MOVBZ   R4, 0xDC0D
  0FE464: 5c44      SHL     R4, #4
  0FE466: e6fa983c  MOV     R10, #0x3C98
  0FE46A: e6fb3e00  MOV     R11, #0x003E
  0FE46E: 00a4      ADD     R10, R4
  0FE470: b8a0      MOV     [R0], R10
  0FE472: c4b00200  MOV     [R0+#0x0002], R11
  0FE476: e11c      MOVB    RL6, #1
  0FE478: e10e      MOVB    RL7, #0
loc_0FE47A:
  0FE47A: c0e4      MOVBZ   R4, RL7
  0FE47C: a8a0      MOV     R10, [R0]
  0FE47E: d4b00200  MOV     R11, [R0+#0x0002]
  0FE482: 00a4      ADD     R10, R4
  0FE484: dc4b      EXTP    R11, #1
  0FE486: a98a      MOVB    RL4, [R10]
  0FE488: c0e5      MOVBZ   R5, RL7
  0FE48A: f0a8      MOV     R10, R8
  0FE48C: f0b9      MOV     R11, R9
  0FE48E: 00a5      ADD     R10, R5
  0FE490: dc4b      EXTP    R11, #1
  0FE492: a9aa      MOVB    RL5, [R10]
  0FE494: 41a8      CMPB    RL5, RL4
  0FE496: 2d01      JMPR    cc_Z, 0x0FE49A
  0FE498: e1ec      MOVB    RL6, #14
loc_0FE49A:
  0FE49A: 49e5      CMPB    RL7, #5
  0FE49C: 3d01      JMPR    cc_NZ, 0x0FE4A0
  0FE49E: e17e      MOVB    RL7, #7
loc_0FE4A0:
  0FE4A0: 09e1      ADDB    RL7, #1
  0FE4A2: 47fe0a00  CMPB    RL7, #0x0A
  0FE4A6: 8de9      JMPR    cc_C, 0x0FE47A
loc_0FE4A8:
  0FE4A8: f68e08dc  MOV     0xDC08, ZEROS
  0FE4AC: e6f4fe3f  MOV     R4, #0x3FFE
  0FE4B0: e6f53b00  MOV     R5, #0x003B
  0FE4B4: c4400400  MOV     [R0+#0x0004], R4
  0FE4B8: c4500600  MOV     [R0+#0x0006], R5
  0FE4BC: dc45      EXTP    R5, #1
  0FE4BE: a824      MOV     R2, [R4]
  0FE4C0: 46f2ffff  CMP     R2, #0xFFFF
  0FE4C4: 3d04      JMPR    cc_NZ, 0x0FE4CE
  0FE4C6: e022      MOV     R2, #2
  0FE4C8: f6f208dc  MOV     0xDC08, R2
  0FE4CC: e1cc      MOVB    RL6, #12
loc_0FE4CE:
  0FE4CE: f3f80cdc  MOVB    RL4, 0xDC0C
  0FE4D2: 2d15      JMPR    cc_Z, 0x0FE4FE
  0FE4D4: f2f408dc  MOV     R4, 0xDC08
  0FE4D8: 4842      CMP     R4, #2
  0FE4DA: 2d11      JMPR    cc_Z, 0x0FE4FE
  0FE4DC: e6f4fe3f  MOV     R4, #0x3FFE
  0FE4E0: e6f53e00  MOV     R5, #0x003E
  0FE4E4: c4400400  MOV     [R0+#0x0004], R4
  0FE4E8: c4500600  MOV     [R0+#0x0006], R5
  0FE4EC: dc45      EXTP    R5, #1
  0FE4EE: a824      MOV     R2, [R4]
  0FE4F0: 46f2ffff  CMP     R2, #0xFFFF
  0FE4F4: 3d04      JMPR    cc_NZ, 0x0FE4FE
  0FE4F6: e032      MOV     R2, #3
  0FE4F8: f6f208dc  MOV     0xDC08, R2
  0FE4FC: e1fc      MOVB    RL6, #15
loc_0FE4FE:
  0FE4FE: f2f408dc  MOV     R4, 0xDC08
  0FE502: 2d02      JMPR    cc_Z, 0x0FE508
  0FE504: 4845      CMP     R4, #5
  0FE506: 3d03      JMPR    cc_NZ, 0x0FE50E
loc_0FE508:
  0FE508: e014      MOV     R4, #1
  0FE50A: f6f408dc  MOV     0xDC08, R4
loc_0FE50E:
  0FE50E: e118      MOVB    RL4, #1
  0FE510: f7f80adc  MOVB    0xDC0A, RL4
  0FE514: f7fc07dc  MOVB    0xDC07, RL6
  0FE518: 06f00800  ADD     R0, #0x0008
  0FE51C: 9890      MOV     R9, [R0+]
  0FE51E: 9880      MOV     R8, [R0+]
  0FE520: 9870      MOV     R7, [R0+]
  0FE522: 9860      MOV     R6, [R0+]
  0FE524: db00      RETS
loc_0FE526:
  0FE526: 2806      SUB     R0, #6
  0FE528: f2fd78fc  MOV     R13, 0xFC78
  0FE52C: e6fe52fb  MOV     R14, #0xFB52
  0FE530: e01c      MOV     R12, #1
  0FE532: e108      MOVB    RL4, #0
  0FE534: e4800300  MOVB    [R0+#0x0003], RL4
  0FE538: f4ad0200  MOVB    RL5, [R13+#0x0002]
  0FE53C: e4a00200  MOVB    [R0+#0x0002], RL5
  0FE540: f46d0300  MOVB    RL3, [R13+#0x0003]
  0FE544: e4600100  MOVB    [R0+#0x0001], RL3
  0FE548: f44d0400  MOVB    RL2, [R13+#0x0004]
  0FE54C: b940      MOVB    [R0], RL2
  0FE54E: a840      MOV     R4, [R0]
  0FE550: d4500200  MOV     R5, [R0+#0x0002]
  0FE554: 2840      SUB     R4, #0
  0FE556: 36f50f00  SUBC    R5, #0x000F
  0FE55A: 8d01      JMPR    cc_C, 0x0FE55E
  0FE55C: e02c      MOV     R12, #2
loc_0FE55E:
  0FE55E: f2f408dc  MOV     R4, 0xDC08
  0FE562: 4842      CMP     R4, #2
  0FE564: 3d0c      JMPR    cc_NZ, 0x0FE57E
  0FE566: f04c      MOV     R4, R12
  0FE568: 4981      CMPB    RL4, #1
  0FE56A: 3d04      JMPR    cc_NZ, 0x0FE574
  0FE56C: e128      MOVB    RL4, #2
  0FE56E: f7f80adc  MOVB    0xDC0A, RL4
  0FE572: 0d2b      JMPR    cc_UC, 0x0FE5CA
loc_0FE574:
  0FE574: e178      MOVB    RL4, #7
  0FE576: f7f807dc  MOVB    0xDC07, RL4
  0FE57A: e00c      MOV     R12, #0
  0FE57C: 0d26      JMPR    cc_UC, 0x0FE5CA
loc_0FE57E:
  0FE57E: f2f408dc  MOV     R4, 0xDC08
  0FE582: 4843      CMP     R4, #3
  0FE584: 3d0c      JMPR    cc_NZ, 0x0FE59E
  0FE586: f04c      MOV     R4, R12
  0FE588: 4982      CMPB    RL4, #2
  0FE58A: 3d04      JMPR    cc_NZ, 0x0FE594
  0FE58C: e128      MOVB    RL4, #2
  0FE58E: f7f80adc  MOVB    0xDC0A, RL4
  0FE592: 0d1b      JMPR    cc_UC, 0x0FE5CA
loc_0FE594:
  0FE594: e188      MOVB    RL4, #8
  0FE596: f7f807dc  MOVB    0xDC07, RL4
  0FE59A: e00c      MOV     R12, #0
  0FE59C: 0d16      JMPR    cc_UC, 0x0FE5CA
loc_0FE59E:
  0FE59E: f04c      MOV     R4, R12
  0FE5A0: 4981      CMPB    RL4, #1
  0FE5A2: 3d08      JMPR    cc_NZ, 0x0FE5B4
  0FE5A4: e024      MOV     R4, #2
  0FE5A6: f6f408dc  MOV     0xDC08, R4
  0FE5AA: e128      MOVB    RL4, #2
  0FE5AC: f7f80adc  MOVB    0xDC0A, RL4
  0FE5B0: e03c      MOV     R12, #3
  0FE5B2: 0d0b      JMPR    cc_UC, 0x0FE5CA
loc_0FE5B4:
  0FE5B4: f04c      MOV     R4, R12
  0FE5B6: 4982      CMPB    RL4, #2
  0FE5B8: 3d07      JMPR    cc_NZ, 0x0FE5C8
  0FE5BA: e034      MOV     R4, #3
  0FE5BC: f6f408dc  MOV     0xDC08, R4
  0FE5C0: e128      MOVB    RL4, #2
  0FE5C2: f7f80adc  MOVB    0xDC0A, RL4
  0FE5C6: 0d01      JMPR    cc_UC, 0x0FE5CA
loc_0FE5C8:
  0FE5C8: e00c      MOV     R12, #0
loc_0FE5CA:
  0FE5CA: f04c      MOV     R4, R12
  0FE5CC: 0806      ADD     R0, #6
  0FE5CE: db00      RETS
loc_0FE5D0:
  0FE5D0: 8880      MOV     [-R0], R8
  0FE5D2: 8890      MOV     [-R0], R9
  0FE5D4: 2806      SUB     R0, #6
  0FE5D6: f2f4e6fa  MOV     R4, 0xFAE6
  0FE5DA: a9a4      MOVB    RL5, [R4]
  0FE5DC: c0ac      MOVBZ   R12, RL5
  0FE5DE: e00d      MOV     R13, #0
  0FE5E0: f0dc      MOV     R13, R12
  0FE5E2: f2fc1cff  MOV     R12, 0xFF1C
  0FE5E6: f4a40100  MOVB    RL5, [R4+#0x0001]
  0FE5EA: c0a5      MOVBZ   R5, RL5
  0FE5EC: 5c85      SHL     R5, #8
  0FE5EE: f0a5      MOV     R10, R5
  0FE5F0: e00b      MOV     R11, #0
  0FE5F2: 00ca      ADD     R12, R10
  0FE5F4: 10db      ADDC    R13, R11
  0FE5F6: f4a40200  MOVB    RL5, [R4+#0x0002]
  0FE5FA: c0aa      MOVBZ   R10, RL5
  0FE5FC: 00ca      ADD     R12, R10
  0FE5FE: 10db      ADDC    R13, R11
  0FE600: e108      MOVB    RL4, #0
  0FE602: e4800300  MOVB    [R0+#0x0003], RL4
  0FE606: f3fabff9  MOVB    RL5, 0xF9BF
  0FE60A: e4a00200  MOVB    [R0+#0x0002], RL5
  0FE60E: f3f6c0f9  MOVB    RL3, 0xF9C0
  0FE612: e4600100  MOVB    [R0+#0x0001], RL3
  0FE616: a400c1f9  MOVB    [R0], 0xF9C1
  0FE61A: a880      MOV     R8, [R0]
  0FE61C: d4900200  MOV     R9, [R0+#0x0002]
  0FE620: 008c      ADD     R8, R12
  0FE622: 109d      ADDC    R9, R13
  0FE624: e6feffff  MOV     R14, #0xFFFF
  0FE628: 0d10      JMPR    cc_UC, 0x0FE64A
loc_0FE62A:
  0FE62A: f04c      MOV     R4, R12
  0FE62C: f05d      MOV     R5, R13
  0FE62E: 8840      MOV     [-R0], R4
  0FE630: 7ce4      SHR     R4, #14
  0FE632: 5c25      SHL     R5, #2
  0FE634: 7054      OR      R5, R4
  0FE636: 9840      MOV     R4, [R0+]
  0FE638: 66f4ff3f  AND     R4, #0x3FFF
  0FE63C: dc45      EXTP    R5, #1
  0FE63E: a824      MOV     R2, [R4]
  0FE640: 60e2      AND     R14, R2
  0FE642: 08c2      ADD     R12, #2
  0FE644: 18d0      ADDC    R13, #0
  0FE646: a758a7a7  SRVWDT
loc_0FE64A:
  0FE64A: 40d9      CMP     R13, R9
  0FE64C: 3d01      JMPR    cc_NZ, 0x0FE650
  0FE64E: 40c8      CMP     R12, R8
loc_0FE650:
  0FE650: 8dec      JMPR    cc_C, 0x0FE62A
  0FE652: 08e1      ADD     R14, #1
  0FE654: 2d03      JMPR    cc_Z, 0x0FE65C
  0FE656: e7f83100  MOVB    RL4, #0x31
  0FE65A: 0d38      JMPR    cc_UC, 0x0FE6CC
loc_0FE65C:
  0FE65C: f2f408dc  MOV     R4, 0xDC08
  0FE660: 4841      CMP     R4, #1
  0FE662: 3d13      JMPR    cc_NZ, 0x0FE68A
  0FE664: e6f400f9  MOV     R4, #0xF900
  0FE668: e6f50f00  MOV     R5, #0x000F
  0FE66C: 204c      SUB     R4, R12
  0FE66E: 305d      SUBC    R5, R13
  0FE670: ed09      JMPR    cc_UGT, 0x0FE684
  0FE672: e6f420fc  MOV     R4, #0xFC20
  0FE676: e6f50f00  MOV     R5, #0x000F
  0FE67A: 2048      SUB     R4, R8
  0FE67C: 3059      SUBC    R5, R9
  0FE67E: 8d02      JMPR    cc_C, 0x0FE684
  0FE680: e108      MOVB    RL4, #0
  0FE682: 0d24      JMPR    cc_UC, 0x0FE6CC
loc_0FE684:
  0FE684: e7f83100  MOVB    RL4, #0x31
  0FE688: 0d21      JMPR    cc_UC, 0x0FE6CC
loc_0FE68A:
  0FE68A: f2f408dc  MOV     R4, 0xDC08
  0FE68E: 4842      CMP     R4, #2
  0FE690: 3d0a      JMPR    cc_NZ, 0x0FE6A6
  0FE692: 46fd0800  CMP     R13, #0x0008
  0FE696: 3d01      JMPR    cc_NZ, 0x0FE69A
  0FE698: 48c0      CMP     R12, #0
loc_0FE69A:
  0FE69A: 8d05      JMPR    cc_C, 0x0FE6A6
  0FE69C: 46f90f00  CMP     R9, #0x000F
  0FE6A0: 3d01      JMPR    cc_NZ, 0x0FE6A4
  0FE6A2: 4880      CMP     R8, #0
loc_0FE6A4:
  0FE6A4: fd0f      JMPR    cc_ULE, 0x0FE6C4
loc_0FE6A6:
  0FE6A6: f2f408dc  MOV     R4, 0xDC08
  0FE6AA: 4843      CMP     R4, #3
  0FE6AC: 3d0d      JMPR    cc_NZ, 0x0FE6C8
  0FE6AE: 46fd0f00  CMP     R13, #0x000F
  0FE6B2: 3d01      JMPR    cc_NZ, 0x0FE6B6
  0FE6B4: 48c0      CMP     R12, #0
loc_0FE6B6:
  0FE6B6: 8d08      JMPR    cc_C, 0x0FE6C8
  0FE6B8: 46f90f00  CMP     R9, #0x000F
  0FE6BC: 3d02      JMPR    cc_NZ, 0x0FE6C2
  0FE6BE: 46f800c0  CMP     R8, #0xC000
loc_0FE6C2:
  0FE6C2: ed02      JMPR    cc_UGT, 0x0FE6C8
loc_0FE6C4:
  0FE6C4: e108      MOVB    RL4, #0
  0FE6C6: 0d02      JMPR    cc_UC, 0x0FE6CC
loc_0FE6C8:
  0FE6C8: e7f83100  MOVB    RL4, #0x31
loc_0FE6CC:
  0FE6CC: 0806      ADD     R0, #6
  0FE6CE: 9890      MOV     R9, [R0+]
  0FE6D0: 9880      MOV     R8, [R0+]
  0FE6D2: db00      RETS
loc_0FE6D4:
  0FE6D4: be88      BCLR    PSW.11
  0FE6D6: e6070000  MOV     MDL, #0x0000
  0FE6DA: fa00d602  JMPS    0x0002D6    ; -> rom_fatal_reset

loc_0FE6E0:
  0FE6E0: f04d      MOV     R4, R13
  0FE6E2: f6f410dc  MOV     0xDC10, R4
  0FE6E6: f05f      MOV     R5, R15
  0FE6E8: f6f512dc  MOV     0xDC12, R5
  0FE6EC: f02c      MOV     R2, R12
  0FE6EE: f6f216dc  MOV     0xDC16, R2
  0FE6F2: f03e      MOV     R3, R14
  0FE6F4: f6f318dc  MOV     0xDC18, R3
  0FE6F8: ec02      PUSH    DPP2
  0FE6FA: ecf1      PUSH    R1
  0FE6FC: ecf6      PUSH    R6
  0FE6FE: ecf3      PUSH    R3
  0FE700: ecf0      PUSH    R0
  0FE702: ecf4      PUSH    R4
  0FE704: f20210dc  MOV     DPP2, 0xDC10
  0FE708: e001      MOV     R1, #0
  0FE70A: e006      MOV     R6, #0
  0FE70C: f2f316dc  MOV     R3, 0xDC16
  0FE710: 76f30080  OR      R3, #0x8000
loc_0FE714:
  0FE714: 420212dc  CMP     DPP2, 0xDC12
  0FE718: 8d08      JMPR    cc_C, 0x0FE72A
  0FE71A: f2f418dc  MOV     R4, 0xDC18
  0FE71E: 76f40080  OR      R4, #0x8000
  0FE722: 46f40080  CMP     R4, #0x8000
  0FE726: 2d1d      JMPR    cc_Z, 0x0FE762
  0FE728: 0d02      JMPR    cc_UC, 0x0FE72E
loc_0FE72A:
  0FE72A: e6f4ffbf  MOV     R4, #0xBFFF
loc_0FE72E:
  0FE72E: f004      MOV     R0, R4
  0FE730: 46f4ff9f  CMP     R4, #0x9FFF
  0FE734: fd09      JMPR    cc_ULE, 0x0FE748
  0FE736: e6f0ff9f  MOV     R0, #0x9FFF
  0FE73A: a758a7a7  SRVWDT
  0FE73E: da001016  CALLS   0x001610    ; -> rom_1610
  0FE742: a758a7a7  SRVWDT
  0FE746: f004      MOV     R0, R4
loc_0FE748:
  0FE748: a758a7a7  SRVWDT
  0FE74C: da001016  CALLS   0x001610    ; -> rom_1610
  0FE750: a758a7a7  SRVWDT
  0FE754: e6f30080  MOV     R3, #0x8000
  0FE758: 06020100  ADD     DPP2, #0x0001
  0FE75C: 420212dc  CMP     DPP2, 0xDC12
  0FE760: fdd9      JMPR    cc_ULE, 0x0FE714
loc_0FE762:
  0FE762: 26f130b5  SUB     R1, #0xB530
  0FE766: 36f61147  SUBC    R6, #0x4711
  0FE76A: 2d04      JMPR    cc_Z, 0x0FE774
  0FE76C: e116      MOVB    RL3, #1
  0FE76E: f7f614dc  MOVB    0xDC14, RL3
  0FE772: 0d03      JMPR    cc_UC, 0x0FE77A
loc_0FE774:
  0FE774: e106      MOVB    RL3, #0
  0FE776: f7f614dc  MOVB    0xDC14, RL3
loc_0FE77A:
  0FE77A: fcf4      POP     R4
  0FE77C: fcf0      POP     R0
  0FE77E: fcf3      POP     R3
  0FE780: fcf6      POP     R6
  0FE782: fcf1      POP     R1
  0FE784: fc02      POP     DPP2
  0FE786: f3f814dc  MOVB    RL4, 0xDC14
  0FE78A: db00      RETS
loc_0FE78C:
  0FE78C: 88f0      MOV     [-R0], R15
  0FE78E: 88e0      MOV     [-R0], R14
  0FE790: 88d0      MOV     [-R0], R13
  0FE792: 88c0      MOV     [-R0], R12
  0FE794: 8860      MOV     [-R0], R6
  0FE796: 8880      MOV     [-R0], R8
  0FE798: 8890      MOV     [-R0], R9
  0FE79A: d7403f00  EXTP    #0x03F, #1
  0FE79E: f3fc503f  MOVB    RL6, 0x3F50
  0FE7A2: f2f4aef9  MOV     R4, 0xF9AE
  0FE7A6: c0c5      MOVBZ   R5, RL6
  0FE7A8: 1b45      MULU    R4, R5
  0FE7AA: f2f40efe  MOV     R4, 0xFE0E
  0FE7AE: e6f80030  MOV     R8, #0x3000
  0FE7B2: e6f93f00  MOV     R9, #0x003F
  0FE7B6: 0084      ADD     R8, R4
  0FE7B8: f04e      MOV     R4, R14
  0FE7BA: 0084      ADD     R8, R4
  0FE7BC: 8890      MOV     [-R0], R9
  0FE7BE: 8880      MOV     [-R0], R8
  0FE7C0: d4400a00  MOV     R4, [R0+#0x000A]
  0FE7C4: f0c4      MOV     R12, R4
  0FE7C6: f0dc      MOV     R13, R12
  0FE7C8: 7ced      SHR     R13, #14
  0FE7CA: 5c1d      SHL     R13, #1
  0FE7CC: d4dd00fe  MOV     R13, [R13+#0xFE00]
  0FE7D0: 66fcff3f  AND     R12, #0x3FFF
  0FE7D4: f4800c00  MOVB    RL4, [R0+#0x000C]
  0FE7D8: c08e      MOVBZ   R14, RL4
  0FE7DA: d7500300  EXTP    #0x003, #2
  0FE7DE: f2f4a01c  MOV     R4, 0x1CA0
  0FE7E2: f2f5a21c  MOV     R5, 0x1CA2
  0FE7E6: da00e85b  CALLS   0x005BE8    ; -> rom_5BE8
  0FE7EA: 0804      ADD     R0, #4
  0FE7EC: 9890      MOV     R9, [R0+]
  0FE7EE: 9880      MOV     R8, [R0+]
  0FE7F0: 9860      MOV     R6, [R0+]
  0FE7F2: 06f00800  ADD     R0, #0x0008
  0FE7F6: db00      RETS
loc_0FE7F8:
  0FE7F8: c2f40edc  MOVBZ   R4, 0xDC0E
  0FE7FC: f054      MOV     R5, R4
  0FE7FE: 5c35      SHL     R5, #3
  0FE800: 2054      SUB     R5, R4
  0FE802: e6fd943f  MOV     R13, #0x3F94
  0FE806: e6fe3700  MOV     R14, #0x0037
  0FE80A: 00d5      ADD     R13, R5
  0FE80C: e00c      MOV     R12, #0
loc_0FE80E:
  0FE80E: f04c      MOV     R4, R12
  0FE810: c084      MOVBZ   R4, RL4
  0FE812: f0ad      MOV     R10, R13
  0FE814: f0be      MOV     R11, R14
  0FE816: 00a4      ADD     R10, R4
  0FE818: dc4b      EXTP    R11, #1
  0FE81A: a98a      MOVB    RL4, [R10]
  0FE81C: f2f57efc  MOV     R5, 0xFC7E
  0FE820: 248f7efc  SUB     0xFC7E, ONES
  0FE824: b985      MOVB    [R5], RL4
  0FE826: f04c      MOV     R4, R12
  0FE828: 0981      ADDB    RL4, #1
  0FE82A: f0c4      MOV     R12, R4
  0FE82C: f04c      MOV     R4, R12
  0FE82E: 4987      CMPB    RL4, #7
  0FE830: 8dee      JMPR    cc_C, 0x0FE80E
  0FE832: d7403f00  EXTP    #0x03F, #1
  0FE836: f3f8642c  MOVB    RL4, 0x2C64
  0FE83A: f2f57efc  MOV     R5, 0xFC7E
  0FE83E: 248f7efc  SUB     0xFC7E, ONES
  0FE842: b985      MOVB    [R5], RL4
  0FE844: d7403f00  EXTP    #0x03F, #1
  0FE848: f3f8652c  MOVB    RL4, 0x2C65
  0FE84C: f2f57efc  MOV     R5, 0xFC7E
  0FE850: 248f7efc  SUB     0xFC7E, ONES
  0FE854: b985      MOVB    [R5], RL4
  0FE856: f2f408dc  MOV     R4, 0xDC08
  0FE85A: 4843      CMP     R4, #3
  0FE85C: 3d30      JMPR    cc_NZ, 0x0FE8BE
  0FE85E: e00c      MOV     R12, #0
loc_0FE860:
  0FE860: e7f8ff00  MOVB    RL4, #0xFF
  0FE864: f2f57efc  MOV     R5, 0xFC7E
  0FE868: 248f7efc  SUB     0xFC7E, ONES
  0FE86C: b985      MOVB    [R5], RL4
  0FE86E: f04c      MOV     R4, R12
  0FE870: 0981      ADDB    RL4, #1
  0FE872: f0c4      MOV     R12, R4
  0FE874: f04c      MOV     R4, R12
  0FE876: 4984      CMPB    RL4, #4
  0FE878: 8df3      JMPR    cc_C, 0x0FE860
  0FE87A: d7403f00  EXTP    #0x03F, #1
  0FE87E: f3f8662c  MOVB    RL4, 0x2C66
  0FE882: f2f57efc  MOV     R5, 0xFC7E
  0FE886: 248f7efc  SUB     0xFC7E, ONES
  0FE88A: b985      MOVB    [R5], RL4
  0FE88C: d7403f00  EXTP    #0x03F, #1
  0FE890: f3f8672c  MOVB    RL4, 0x2C67
  0FE894: f2f57efc  MOV     R5, 0xFC7E
  0FE898: 248f7efc  SUB     0xFC7E, ONES
  0FE89C: b985      MOVB    [R5], RL4
  0FE89E: e00c      MOV     R12, #0
loc_0FE8A0:
  0FE8A0: e7f8ff00  MOVB    RL4, #0xFF
  0FE8A4: f2f57efc  MOV     R5, 0xFC7E
  0FE8A8: 248f7efc  SUB     0xFC7E, ONES
  0FE8AC: b985      MOVB    [R5], RL4
  0FE8AE: f04c      MOV     R4, R12
  0FE8B0: 0981      ADDB    RL4, #1
  0FE8B2: f0c4      MOV     R12, R4
  0FE8B4: f04c      MOV     R4, R12
  0FE8B6: 4984      CMPB    RL4, #4
  0FE8B8: 8df3      JMPR    cc_C, 0x0FE8A0
  0FE8BA: ea00d6e9  JMPA    cc_UC, 0x0FE9D6
loc_0FE8BE:
  0FE8BE: d7503e00  EXTP    #0x03E, #2
  0FE8C2: f2f4803c  MOV     R4, 0x3C80
  0FE8C6: f2f5823c  MOV     R5, 0x3C82
  0FE8CA: dc45      EXTP    R5, #1
  0FE8CC: a964      MOVB    RL3, [R4]
  0FE8CE: f2f27efc  MOV     R2, 0xFC7E
  0FE8D2: 248f7efc  SUB     0xFC7E, ONES
  0FE8D6: b962      MOVB    [R2], RL3
  0FE8D8: d7503e00  EXTP    #0x03E, #2
  0FE8DC: f2f4803c  MOV     R4, 0x3C80
  0FE8E0: f2f5823c  MOV     R5, 0x3C82
  0FE8E4: dc55      EXTP    R5, #2
  0FE8E6: f4640100  MOVB    RL3, [R4+#0x0001]
  0FE8EA: cc00      NOP
  0FE8EC: f2f27efc  MOV     R2, 0xFC7E
  0FE8F0: 248f7efc  SUB     0xFC7E, ONES
  0FE8F4: b962      MOVB    [R2], RL3
  0FE8F6: d7503e00  EXTP    #0x03E, #2
  0FE8FA: f2f4843c  MOV     R4, 0x3C84
  0FE8FE: f2f5863c  MOV     R5, 0x3C86
  0FE902: dc45      EXTP    R5, #1
  0FE904: a964      MOVB    RL3, [R4]
  0FE906: f2f27efc  MOV     R2, 0xFC7E
  0FE90A: 248f7efc  SUB     0xFC7E, ONES
  0FE90E: b962      MOVB    [R2], RL3
  0FE910: d7503e00  EXTP    #0x03E, #2
  0FE914: f2f4843c  MOV     R4, 0x3C84
  0FE918: f2f5863c  MOV     R5, 0x3C86
  0FE91C: dc55      EXTP    R5, #2
  0FE91E: f4640100  MOVB    RL3, [R4+#0x0001]
  0FE922: cc00      NOP
  0FE924: f2f27efc  MOV     R2, 0xFC7E
  0FE928: 248f7efc  SUB     0xFC7E, ONES
  0FE92C: b962      MOVB    [R2], RL3
  0FE92E: d7503e00  EXTP    #0x03E, #2
  0FE932: f2f4883c  MOV     R4, 0x3C88
  0FE936: f2f58a3c  MOV     R5, 0x3C8A
  0FE93A: dc45      EXTP    R5, #1
  0FE93C: a964      MOVB    RL3, [R4]
  0FE93E: f2f27efc  MOV     R2, 0xFC7E
  0FE942: 248f7efc  SUB     0xFC7E, ONES
  0FE946: b962      MOVB    [R2], RL3
  0FE948: d7503e00  EXTP    #0x03E, #2
  0FE94C: f2f4883c  MOV     R4, 0x3C88
  0FE950: f2f58a3c  MOV     R5, 0x3C8A
  0FE954: dc55      EXTP    R5, #2
  0FE956: f4640100  MOVB    RL3, [R4+#0x0001]
  0FE95A: cc00      NOP
  0FE95C: f2f27efc  MOV     R2, 0xFC7E
  0FE960: 248f7efc  SUB     0xFC7E, ONES
  0FE964: b962      MOVB    [R2], RL3
  0FE966: d7503e00  EXTP    #0x03E, #2
  0FE96A: f2f48c3c  MOV     R4, 0x3C8C
  0FE96E: f2f58e3c  MOV     R5, 0x3C8E
  0FE972: dc45      EXTP    R5, #1
  0FE974: a964      MOVB    RL3, [R4]
  0FE976: f2f27efc  MOV     R2, 0xFC7E
  0FE97A: 248f7efc  SUB     0xFC7E, ONES
  0FE97E: b962      MOVB    [R2], RL3
  0FE980: d7503e00  EXTP    #0x03E, #2
  0FE984: f2f48c3c  MOV     R4, 0x3C8C
  0FE988: f2f58e3c  MOV     R5, 0x3C8E
  0FE98C: dc55      EXTP    R5, #2
  0FE98E: f4640100  MOVB    RL3, [R4+#0x0001]
  0FE992: cc00      NOP
  0FE994: f2f27efc  MOV     R2, 0xFC7E
  0FE998: 248f7efc  SUB     0xFC7E, ONES
  0FE99C: b962      MOVB    [R2], RL3
  0FE99E: d7503e00  EXTP    #0x03E, #2
  0FE9A2: f2f4903c  MOV     R4, 0x3C90
  0FE9A6: f2f5923c  MOV     R5, 0x3C92
  0FE9AA: dc45      EXTP    R5, #1
  0FE9AC: a964      MOVB    RL3, [R4]
  0FE9AE: f2f27efc  MOV     R2, 0xFC7E
  0FE9B2: 248f7efc  SUB     0xFC7E, ONES
  0FE9B6: b962      MOVB    [R2], RL3
  0FE9B8: d7503e00  EXTP    #0x03E, #2
  0FE9BC: f2f4903c  MOV     R4, 0x3C90
  0FE9C0: f2f5923c  MOV     R5, 0x3C92
  0FE9C4: dc55      EXTP    R5, #2
  0FE9C6: f4640100  MOVB    RL3, [R4+#0x0001]
  0FE9CA: cc00      NOP
  0FE9CC: f2f27efc  MOV     R2, 0xFC7E
  0FE9D0: 248f7efc  SUB     0xFC7E, ONES
  0FE9D4: b962      MOVB    [R2], RL3
loc_0FE9D6:
  0FE9D6: c2f40fdc  MOVBZ   R4, 0xDC0F
  0FE9DA: f054      MOV     R5, R4
  0FE9DC: 5c35      SHL     R5, #3
  0FE9DE: 0054      ADD     R5, R4
  0FE9E0: e6fd452c  MOV     R13, #0x2C45
  0FE9E4: e6fe3f00  MOV     R14, #0x003F
  0FE9E8: 00d5      ADD     R13, R5
  0FE9EA: e00c      MOV     R12, #0
loc_0FE9EC:
  0FE9EC: f04c      MOV     R4, R12
  0FE9EE: c084      MOVBZ   R4, RL4
  0FE9F0: f0ad      MOV     R10, R13
  0FE9F2: f0be      MOV     R11, R14
  0FE9F4: 00a4      ADD     R10, R4
  0FE9F6: dc4b      EXTP    R11, #1
  0FE9F8: a98a      MOVB    RL4, [R10]
  0FE9FA: f2f57efc  MOV     R5, 0xFC7E
  0FE9FE: 248f7efc  SUB     0xFC7E, ONES
  0FEA02: b985      MOVB    [R5], RL4
  0FEA04: f04c      MOV     R4, R12
  0FEA06: 0981      ADDB    RL4, #1
  0FEA08: f0c4      MOV     R12, R4
  0FEA0A: f04c      MOV     R4, R12
  0FEA0C: 47f80900  CMPB    RL4, #0x09
  0FEA10: 8ded      JMPR    cc_C, 0x0FE9EC
  0FEA12: e7f8ff00  MOVB    RL4, #0xFF
  0FEA16: f2f57efc  MOV     R5, 0xFC7E
  0FEA1A: 248f7efc  SUB     0xFC7E, ONES
  0FEA1E: b985      MOVB    [R5], RL4
  0FEA20: e00c      MOV     R12, #0
loc_0FEA22:
  0FEA22: e7f8ff00  MOVB    RL4, #0xFF
  0FEA26: f2f57efc  MOV     R5, 0xFC7E
  0FEA2A: 248f7efc  SUB     0xFC7E, ONES
  0FEA2E: b985      MOVB    [R5], RL4
  0FEA30: f04c      MOV     R4, R12
  0FEA32: 0981      ADDB    RL4, #1
  0FEA34: f0c4      MOV     R12, R4
  0FEA36: f04c      MOV     R4, R12
  0FEA38: 4984      CMPB    RL4, #4
  0FEA3A: 8df3      JMPR    cc_C, 0x0FEA22
  0FEA3C: e6fd6d2c  MOV     R13, #0x2C6D
  0FEA40: e6fe3f00  MOV     R14, #0x003F
  0FEA44: e00c      MOV     R12, #0
loc_0FEA46:
  0FEA46: f04c      MOV     R4, R12
  0FEA48: c084      MOVBZ   R4, RL4
  0FEA4A: f0ad      MOV     R10, R13
  0FEA4C: f0be      MOV     R11, R14
  0FEA4E: 00a4      ADD     R10, R4
  0FEA50: dc4b      EXTP    R11, #1
  0FEA52: a98a      MOVB    RL4, [R10]
  0FEA54: f2f57efc  MOV     R5, 0xFC7E
  0FEA58: 248f7efc  SUB     0xFC7E, ONES
  0FEA5C: b985      MOVB    [R5], RL4
  0FEA5E: f04c      MOV     R4, R12
  0FEA60: 0981      ADDB    RL4, #1
  0FEA62: f0c4      MOV     R12, R4
  0FEA64: f04c      MOV     R4, R12
  0FEA66: 47f80900  CMPB    RL4, #0x09
  0FEA6A: 8ded      JMPR    cc_C, 0x0FEA46
  0FEA6C: db00      RETS
loc_0FEA6E:
  0FEA6E: 8860      MOV     [-R0], R6
  0FEA70: 8870      MOV     [-R0], R7
  0FEA72: 8880      MOV     [-R0], R8
  0FEA74: 8890      MOV     [-R0], R9
  0FEA76: 2804      SUB     R0, #4
  0FEA78: e10c      MOVB    RL6, #0
  0FEA7A: e10e      MOVB    RL7, #0
  0FEA7C: e008      MOV     R8, #0
  0FEA7E: e00f      MOV     R15, #0
  0FEA80: e009      MOV     R9, #0
  0FEA82: 0d41      JMPR    cc_UC, 0x0FEB06
loc_0FEA84:
  0FEA84: dc4d      EXTP    R13, #1
  0FEA86: a98c      MOVB    RL4, [R12]
  0FEA88: b980      MOVB    [R0], RL4
  0FEA8A: f05e      MOV     R5, R14
  0FEA8C: c0a4      MOVBZ   R4, RL5
  0FEA8E: f0ac      MOV     R10, R12
  0FEA90: f0bd      MOV     R11, R13
  0FEA92: 00a4      ADD     R10, R4
  0FEA94: dc4b      EXTP    R11, #1
  0FEA96: a98a      MOVB    RL4, [R10]
  0FEA98: e4800100  MOVB    [R0+#0x0001], RL4
  0FEA9C: f05e      MOV     R5, R14
  0FEA9E: c0a4      MOVBZ   R4, RL5
  0FEAA0: 5c14      SHL     R4, #1
  0FEAA2: f0ac      MOV     R10, R12
  0FEAA4: f0bd      MOV     R11, R13
  0FEAA6: 00a4      ADD     R10, R4
  0FEAA8: dc4b      EXTP    R11, #1
  0FEAAA: a98a      MOVB    RL4, [R10]
  0FEAAC: e4800200  MOVB    [R0+#0x0002], RL4
  0FEAB0: f4a00100  MOVB    RL5, [R0+#0x0001]
  0FEAB4: a960      MOVB    RL3, [R0]
  0FEAB6: 416a      CMPB    RL3, RL5
  0FEAB8: 2d01      JMPR    cc_Z, 0x0FEABC
  0FEABA: e11c      MOVB    RL6, #1
loc_0FEABC:
  0FEABC: f4800200  MOVB    RL4, [R0+#0x0002]
  0FEAC0: f4a00100  MOVB    RL5, [R0+#0x0001]
  0FEAC4: 41a8      CMPB    RL5, RL4
  0FEAC6: 2d01      JMPR    cc_Z, 0x0FEACA
  0FEAC8: e11e      MOVB    RL7, #1
loc_0FEACA:
  0FEACA: a980      MOVB    RL4, [R0]
  0FEACC: f4a00200  MOVB    RL5, [R0+#0x0002]
  0FEAD0: 41a8      CMPB    RL5, RL4
  0FEAD2: 2d01      JMPR    cc_Z, 0x0FEAD6
  0FEAD4: e018      MOV     R8, #1
loc_0FEAD6:
  0FEAD6: c0c4      MOVBZ   R4, RL6
  0FEAD8: c0e5      MOVBZ   R5, RL7
  0FEADA: 0045      ADD     R4, R5
  0FEADC: f058      MOV     R5, R8
  0FEADE: c0a5      MOVBZ   R5, RL5
  0FEAE0: 0045      ADD     R4, R5
  0FEAE2: 4842      CMP     R4, #2
  0FEAE4: bd02      JMPR    cc_SLE, 0x0FEAEA
  0FEAE6: e108      MOVB    RL4, #0
  0FEAE8: 0d13      JMPR    cc_UC, 0x0FEB10
loc_0FEAEA:
  0FEAEA: 49e0      CMPB    RL7, #0
  0FEAEC: 3d01      JMPR    cc_NZ, 0x0FEAF0
  0FEAEE: e02f      MOV     R15, #2
loc_0FEAF0:
  0FEAF0: f048      MOV     R4, R8
  0FEAF2: 4980      CMPB    RL4, #0
  0FEAF4: 3d01      JMPR    cc_NZ, 0x0FEAF8
  0FEAF6: e02f      MOV     R15, #2
loc_0FEAF8:
  0FEAF8: 49c0      CMPB    RL6, #0
  0FEAFA: 3d01      JMPR    cc_NZ, 0x0FEAFE
  0FEAFC: e01f      MOV     R15, #1
loc_0FEAFE:
  0FEAFE: 08c1      ADD     R12, #1
  0FEB00: f049      MOV     R4, R9
  0FEB02: 0981      ADDB    RL4, #1
  0FEB04: f094      MOV     R9, R4
loc_0FEB06:
  0FEB06: f04e      MOV     R4, R14
  0FEB08: f059      MOV     R5, R9
  0FEB0A: 41a8      CMPB    RL5, RL4
  0FEB0C: 8dbb      JMPR    cc_C, 0x0FEA84
  0FEB0E: f04f      MOV     R4, R15
loc_0FEB10:
  0FEB10: 0804      ADD     R0, #4
  0FEB12: 9890      MOV     R9, [R0+]
  0FEB14: 9880      MOV     R8, [R0+]
  0FEB16: 9870      MOV     R7, [R0+]
  0FEB18: 9860      MOV     R6, [R0+]
  0FEB1A: db00      RETS
loc_0FEB1C:
  0FEB1C: e00c      MOV     R12, #0
  0FEB1E: e6fd2400  MOV     R13, #0x0024
  0FEB22: e00e      MOV     R14, #0
  0FEB24: e6ff2500  MOV     R15, #0x0025
  0FEB28: da0fe0e6  CALLS   0x0FE6E0
  0FEB2C: 4980      CMPB    RL4, #0
  0FEB2E: 2d02      JMPR    cc_Z, 0x0FEB34
  0FEB30: e128      MOVB    RL4, #2
  0FEB32: db00      RETS
loc_0FEB34:
  0FEB34: d7402400  EXTP    #0x024, #1
  0FEB38: f2f4f83f  MOV     R4, 0x3FF8
  0FEB3C: 46f43dd3  CMP     R4, #0xD33D
  0FEB40: 3d07      JMPR    cc_NZ, 0x0FEB50
  0FEB42: d7402400  EXTP    #0x024, #1
  0FEB46: f2f5f63f  MOV     R5, 0x3FF6
  0FEB4A: 46f53dd3  CMP     R5, #0xD33D
  0FEB4E: 2d0d      JMPR    cc_Z, 0x0FEB6A
loc_0FEB50:
  0FEB50: e6fc800b  MOV     R12, #0x0B80
  0FEB54: e6fd3c00  MOV     R13, #0x003C
  0FEB58: e00e      MOV     R14, #0
  0FEB5A: e6ff3f00  MOV     R15, #0x003F
  0FEB5E: da0fe0e6  CALLS   0x0FE6E0
  0FEB62: 4980      CMPB    RL4, #0
  0FEB64: 2d02      JMPR    cc_Z, 0x0FEB6A
  0FEB66: e138      MOVB    RL4, #3
  0FEB68: db00      RETS
loc_0FEB6A:
  0FEB6A: e00c      MOV     R12, #0
  0FEB6C: e6fd2500  MOV     R13, #0x0025
  0FEB70: e6fe800b  MOV     R14, #0x0B80
  0FEB74: e6ff3c00  MOV     R15, #0x003C
  0FEB78: da0fe0e6  CALLS   0x0FE6E0
  0FEB7C: 4980      CMPB    RL4, #0
  0FEB7E: 2d06      JMPR    cc_Z, 0x0FEB8C
  0FEB80: f2f408dc  MOV     R4, 0xDC08
  0FEB84: 4842      CMP     R4, #2
  0FEB86: 2d02      JMPR    cc_Z, 0x0FEB8C
  0FEB88: e158      MOVB    RL4, #5
  0FEB8A: db00      RETS
loc_0FEB8C:
  0FEB8C: e108      MOVB    RL4, #0
  0FEB8E: db00      RETS
loc_0FEB90:
  0FEB90: 8890      MOV     [-R0], R9
  0FEB92: f09c      MOV     R9, R12
  0FEB94: 0d07      JMPR    cc_UC, 0x0FEBA4
loc_0FEB96:
  0FEB96: a758a7a7  SRVWDT
  0FEB9A: dc4e      EXTP    R14, #1
  0FEB9C: a98d      MOVB    RL4, [R13]
  0FEB9E: b989      MOVB    [R9], RL4
  0FEBA0: 0891      ADD     R9, #1
  0FEBA2: 08d1      ADD     R13, #1
loc_0FEBA4:
  0FEBA4: 409f      CMP     R9, R15
  0FEBA6: fdf7      JMPR    cc_ULE, 0x0FEB96
  0FEBA8: 9890      MOV     R9, [R0+]
  0FEBAA: db00      RETS
loc_0FEBAC:
  0FEBAC: e6fd52fb  MOV     R13, #0xFB52
  0FEBB0: e7f87f00  MOVB    RL4, #0x7F
  0FEBB4: f05d      MOV     R5, R13
  0FEBB6: 08d1      ADD     R13, #1
  0FEBB8: b985      MOVB    [R5], RL4
  0FEBBA: f04d      MOV     R4, R13
  0FEBBC: 08d1      ADD     R13, #1
  0FEBBE: a4049dfc  MOVB    [R4], 0xFC9D
  0FEBC2: f04c      MOV     R4, R12
  0FEBC4: f05d      MOV     R5, R13
  0FEBC6: 08d1      ADD     R13, #1
  0FEBC8: b985      MOVB    [R5], RL4
  0FEBCA: f6fd6afc  MOV     0xFC6A, R13
  0FEBCE: db00      RETS

