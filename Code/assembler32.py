"""
32비트 명령어 어셈블러

사용자 정의 ISA 규칙에 따라 어셈블리 코드를 32비트 기계어로 변환합니다.

==== 이번 수정으로 확정된 피연산자 기술 규칙 (요청 사항 반영) ====
기본 물리적 비트 배치는 동일: R 형식은 opcode[6] rs[5] rt[5] rd[5] sh[5] funct[6]

[R 타입 기본 (ADD/SUB/AND/OR/XOR/NOR/ROT 등)]
    작성:  명령어 $tX $tY $tZ
    의미:  첫 번째 = rd, 두 번째 = rs, 세 번째 = rt (요청: "$tx $ty $tz -> rd rs rt")
    인코딩: opcode rs rt rd sh=0 funct

[R 타입 Shift (SLL/SRL/SRA)]
    작성:  명령어 $tX $tY imm
    의미:  첫 번째 = rd, 두 번째 = rs, imm = sh (요청: "$tx $ty imm -> rd rs sh")
    인코딩에서 rt 는 0 으로 채움(opcode rs 0 rd sh funct)

[JR]
    작성: JR $tX
    의미: rs = $tX, 나머지(rt, rd, sh)=0

[SLXOR / SRXOR]
    작성: 명령어 $tX $tY $tZ sh
    의미: 첫 번째 = rd, 두 번째 = rs, 세 번째 = rt, 네 번째 = sh (요청: "$tx $ty $tz sh -> rd rs rt sh")
    인코딩: opcode rs rt rd sh funct

[I 타입 (ADDI/SUBI/ANDI/ORI/XORI/LW/SW 등 BEQ/BNE 제외)]
    작성: 명령어 $tX $tY imm
    의미: 첫 번째 = rt, 두 번째 = rs, imm = 즉값 (요청: "$tx $ty imm -> rt rs imm")
    인코딩: opcode rs rt imm (비트 배열은 rs 위치가 먼저 오므로 내부적으로 재배치)

    LW / SW 추가 지원 메모리 형식:
        작성: LW  $tX imm($tY)   또는   SW $tX imm($tY)
        의미: $tX = rt, $tY = rs, imm = 16비트 즉값
        여전히 내부 인코딩: opcode rs rt imm
        예: LW $t1 4($t2)  -> rt=$t1, rs=$t2, imm=4

[I 타입 분기 (BEQ/BNE)]
    기존 유지: 명령어 $tX $tY imm  => 첫 번째 = rs, 두 번째 = rt, imm = 오프셋
    (요청에서 BEQ/BNE는 예외로 함)

[J 타입]
    작성: 명령어 imm  => target = imm

[D 타입 (DXOR)]
    작성: DXOR $tX $tY $tZ $tW => rs, rt, rd, ri (기존 규칙 유지)

INSTR_SPECS: 명령어 이름을 {type, opcode, funct} 로 매핑.

입력 형식 일반 규칙:
- "명령어" 다음에는 공백 1개를 권장합니다.
- 피연산자는 쉼표+공백(`, `)으로 구분하는 형식을 지원합니다. 예: `ADD $t1, $t2, $t3`
- 내부 처리에서 모든 쉼표는 자동 제거되며 다중 공백은 1개로 정규화됩니다.
- 따라서 `ADD $t1 $t2 $t3` 와 `ADD $t1, $t2, $t3` 모두 동일하게 동작합니다.
"""
from typing import List, Dict, Tuple
import sys
import re

# ==========================
# Global Instruction Specs
# ==========================
# Edit/add mnemonics here. opcode/funct are 6-bit strings.
INSTR_SPECS: Dict[str, Dict[str, str]] = {
    # R-type standard (rs, rt, rd)
    'ADD':     {'type': 'R',      'opcode': '000000', 'funct': '100000'},
    'SUB':     {'type': 'R',      'opcode': '000000', 'funct': '100001'},
    'AND':     {'type': 'R',      'opcode': '000000', 'funct': '100100'},
    'OR':      {'type': 'R',      'opcode': '000000', 'funct': '100101'},
    'XOR':     {'type': 'R',      'opcode': '000000', 'funct': '100110'},
    'NOR':     {'type': 'R',      'opcode': '000000', 'funct': '100111'},
    'ROT':  {'type': 'R',      'opcode': '000000', 'funct': '000000'},  # As per table; adjust usage format if needed
    'JR':      {'type': 'R_JR',   'opcode': '000000', 'funct': '001000'},
    'SYSCALL': {'type': 'R',      'opcode': '000000', 'funct': '001100'},  # If used, consider zero-operand handling

    # R-type shifts special formats (SLL/SRL/SRA use R_SLL rules)
    'SLL':     {'type': 'R_SLL',  'opcode': '000000', 'funct': '000001'},
    'SRL':     {'type': 'R_SLL',  'opcode': '000000', 'funct': '000010'},
    'SRA':     {'type': 'R_SLL',  'opcode': '000000', 'funct': '000011'},

    # SLXOR / SRXOR (custom R with sh)
    'SLXOR':   {'type': 'R_SH',   'opcode': '000000', 'funct': '101001'},
    'SRXOR':   {'type': 'R_SH',   'opcode': '000000', 'funct': '101010'},

    # D-type (custom)
    'DXOR':    {'type': 'D',      'opcode': '000000', 'funct': '110010'},

    # I-type opcodes
    'ADDI':    {'type': 'I',      'opcode': '001000'},
    'SUBI':    {'type': 'I',      'opcode': '001001'},
    'ANDI':    {'type': 'I',      'opcode': '001100'},
    'ORI':     {'type': 'I',      'opcode': '001101'},
    'XORI':    {'type': 'I',      'opcode': '001110'},
    'LW':      {'type': 'I',      'opcode': '100011'},
    'SW':      {'type': 'I',      'opcode': '101011'},
    'BEQ':     {'type': 'I',      'opcode': '000100'},
    'BNE':     {'type': 'I',      'opcode': '000101'},

    # J-type opcodes
    'J':       {'type': 'J',      'opcode': '000010'},
    'JAL':     {'type': 'J',      'opcode': '000011'},
}

# ==========================
# 헬퍼 함수
# ==========================
reg_re = re.compile(r"^\$t(\d+)$")

def to_bin(n: int, bits: int) -> str:
    if n < 0:
        # 필요 시 음수 imm에 대한 2의 보수 처리
        n = (1 << bits) + n
    if n < 0 or n >= (1 << bits):
        raise ValueError(f"Value {n} out of range for {bits} bits")
    return format(n, f"0{bits}b")

def parse_register(token: str) -> int:
    m = reg_re.match(token.strip())
    if not m:
        raise ValueError(f"잘못된 레지스터 '{token}'. 예: $t0 형식이어야 합니다")
    return int(m.group(1))

def parse_int(token: str) -> int:
    token = token.strip()
    # 10진수 또는 0x... 16진수 허용
    if token.lower().startswith('0x'):
        return int(token, 16)
    return int(token)

# ==========================
# 각 타입 인코더
# ==========================

def encode_R(opcode: str, funct: str, rs: int, rt: int, rd: int, sh: int = 0) -> str:
    return (
        opcode +
        to_bin(rs, 5) +
        to_bin(rt, 5) +
        to_bin(rd, 5) +
        to_bin(sh, 5) +
        funct
    )

# SLL/SRL/SRA: "명령어 $tX $tY imm"  => rd, rs, sh (요청 반영)
# 내부 비트배치(opcode rs rt rd sh funct)에 맞추기 위해 rt=0 고정.
def encode_R_SLL(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 3:
        raise ValueError(f"{mn} expects: {mn} $tX $tY imm")
    rd = parse_register(operands[0])
    rs = parse_register(operands[1])
    sh = parse_int(operands[2])
    return encode_R(spec['opcode'], spec['funct'], rs, 0, rd, sh)

# JR: "JR $tX"  => rs; rt=rd=sh=0
def encode_R_JR(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 1:
        raise ValueError("JR expects: JR $tX")
    rs = parse_register(operands[0])
    return encode_R(spec['opcode'], spec['funct'], rs, 0, 0, 0)

# 기본 R: "명령어 $tX $tY $tZ"  => rd, rs, rt (요청 반영); sh=0
def encode_R_default(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 3:
        raise ValueError(f"{mn} expects: {mn} $tX $tY $tZ")
    rd = parse_register(operands[0])
    rs = parse_register(operands[1])
    rt = parse_register(operands[2])
    return encode_R(spec['opcode'], spec['funct'], rs, rt, rd, 0)

# SLXOR/SRXOR: "명령어 $tX $tY $tZ sh" => rd, rs, rt, sh (요청 반영)
def encode_R_SH(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 4:
        raise ValueError(f"{mn} expects: {mn} $tX $tY $tZ sh")
    rd = parse_register(operands[0])
    rs = parse_register(operands[1])
    rt = parse_register(operands[2])
    sh = parse_int(operands[3])
    return encode_R(spec['opcode'], spec['funct'], rs, rt, rd, sh)

# I 타입 (BEQ/BNE 제외): "명령어 $tX $tY imm" => rt, rs, imm (요청 반영)
# 내부 인코딩은 opcode rs rt imm 이므로 순서 변환 필요.
def encode_I(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 3:
        # LW/SW 메모리 형식 처리: $tX imm($tY)
        if mn in ('LW','SW') and len(operands) == 2:
            rt_token = operands[0]
            mem_token = operands[1]
            # 패턴: imm($tY)
            m = re.match(r'^(-?0x[0-9a-fA-F]+|-?\d+)\(\$t(\d+)\)$', mem_token)
            if not m:
                raise ValueError(f"{mn} expects: {mn} $tX imm($tY) 또는 {mn} $tX $tY imm")
            imm_str, rs_num = m.group(1), m.group(2)
            rt = parse_register(rt_token)
            rs = int(rs_num)
            imm = parse_int(imm_str)
            return spec['opcode'] + to_bin(rs, 5) + to_bin(rt, 5) + to_bin(imm, 16)
        raise ValueError(f"{mn} expects: {mn} $tX $tY imm" + (" 또는 $tX imm($tY)" if mn in ('LW','SW') else ""))
    if mn in ('BEQ', 'BNE'):
        rs = parse_register(operands[0])
        rt = parse_register(operands[1])
        imm = parse_int(operands[2])
    else:
        # 일반 I 타입 (LW/SW 포함) 세 피연산자 형식: 첫 번째=rt, 두 번째=rs
        rt = parse_register(operands[0])
        rs = parse_register(operands[1])
        imm = parse_int(operands[2])
    return spec['opcode'] + to_bin(rs, 5) + to_bin(rt, 5) + to_bin(imm, 16)

# J 타입: "명령어 imm" => opcode target[26]
def encode_J(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 1:
        raise ValueError(f"{mn} expects: {mn} imm")
    target = parse_int(operands[0])
    return spec['opcode'] + to_bin(target, 26)

# D 타입: "DXOR $tX $tY $tZ $tW" => opcode rs rt rd ri funct
def encode_D(mn: str, spec: Dict[str, str], operands: List[str]) -> str:
    if len(operands) != 4:
        raise ValueError("DXOR expects: DXOR $tX $tY $tZ $tW")
    rs = parse_register(operands[0])
    rt = parse_register(operands[1])
    rd = parse_register(operands[2])
    ri = parse_register(operands[3])
    return spec['opcode'] + to_bin(rs, 5) + to_bin(rt, 5) + to_bin(rd, 5) + to_bin(ri, 5) + spec['funct']

# ==========================
# Main assembly function
# ==========================

def assemble_line(line: str) -> Tuple[str, str, str]:
    # 주석 제거 및 공백 정리 + 쉼표 제거(요청: 쉼표 자동 제거)
    line = line.strip()
    if not line:
        return ('', '', '')
    # 쉼표 제거 후 공백 하나로 정규화
    no_commas = line.replace(',', ' ')
    norm = re.sub(r"\s+", " ", no_commas)
    # 명령어와 피연산자 분리
    parts = norm.split()
    if not parts:
        return ('', '', '')
    mnemonic = parts[0].upper()
    operands = parts[1:]

    if mnemonic not in INSTR_SPECS:
        raise ValueError(f"알 수 없는 명령어 '{mnemonic}'")
    spec = INSTR_SPECS[mnemonic]
    itype = spec['type']

    if itype == 'R':
        bits = assemble_bits(encode_R_default(mnemonic, spec, operands))
    elif itype == 'R_SLL':
        bits = assemble_bits(encode_R_SLL(mnemonic, spec, operands))
    elif itype == 'R_JR':
        bits = assemble_bits(encode_R_JR(mnemonic, spec, operands))
    elif itype == 'R_SH':
        bits = assemble_bits(encode_R_SH(mnemonic, spec, operands))
    elif itype == 'I':
        bits = assemble_bits(encode_I(mnemonic, spec, operands))
    elif itype == 'J':
        bits = assemble_bits(encode_J(mnemonic, spec, operands))
    elif itype == 'D':
        bits = assemble_bits(encode_D(mnemonic, spec, operands))
    else:
        raise ValueError(f"지원되지 않는 타입 '{itype}' (명령어 {mnemonic})")

    # 타입별 구분자 '_'로 분할 표현 생성
    if itype in ('R', 'R_SLL', 'R_JR', 'R_SH'):
        # 6,5,5,5,5,6
        segs = [
            bits[0:6], bits[6:11], bits[11:16], bits[16:21], bits[21:26], bits[26:32]
        ]
    elif itype == 'I':
        # 6,5,5,16
        segs = [
            bits[0:6], bits[6:11], bits[11:16], bits[16:32]
        ]
    elif itype == 'J':
        # 6,26
        segs = [
            bits[0:6], bits[6:32]
        ]
    elif itype == 'D':
        # 6,5,5,5,5,6 (DXOR 규칙)
        segs = [
            bits[0:6], bits[6:11], bits[11:16], bits[16:21], bits[21:26], bits[26:32]
        ]
    else:
        segs = [bits]

    segmented = '_'.join(segs)
    hexcode = format(int(bits, 2), '08X')
    return (segmented, bits, hexcode)

def assemble_bits(bits: str) -> str:
    if len(bits) != 32:
        raise ValueError(f"인코딩 길이 {len(bits)} 비트가 32비트와 일치하지 않습니다")
    return bits

# ==========================
# CLI
# ==========================

def assemble_text(text: str) -> List[Tuple[str, str, str]]:
    out: List[Tuple[str, str, str]] = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith('#') or line.startswith('//'):
            continue
        out.append(assemble_line(line))
    return out

def main(argv: List[str] = None):
    argv = argv or sys.argv[1:]
    hex = []
    if argv:
        # 첫 번째 인자를 파일 경로로 처리
        path = argv[0]
        with open(path, 'r', encoding='utf-8') as f:
            text = f.read()
    else:
        print("어셈블리 코드를 입력하세요 (Unix: Ctrl+D 종료, Windows: Ctrl+Z 후 Enter):")
        text = sys.stdin.read()
    try:
        encoded = assemble_text(text)
        # 각 줄에 대해: 분할표현, 전체 바이너리, 전체 헥사 출력
        for segmented, bits, hexcode in encoded:
            print(segmented)
            hex.append(hexcode)
        print("\n", "HEXCODE", "\n")
        for hexcode in hex:
            print(hexcode)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
