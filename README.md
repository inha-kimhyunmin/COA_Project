# XOR/Shift/Rotate 최적화 CPU 프로젝트

프로젝트 팀: 12191529 장준영 · 12211472 김현민 · 12211785 송상윤 · 12236553 안효리

## 개요
- **목표:** XOR, Shift, Rotate 연산을 고속 처리하는 파이프라인 CPU 구현
- **구성:** Verilog 기반 4-Stage 파이프라인과 Python 어셈블러(32-bit)

## 아키텍처
![CPU Pipeline Diagram](./image01.png)
- Stage 1: `PC`/`Cache`/Instr Fetch
- Stage 2: `Reg file`/Decode/Imm 처리
- Stage 3: `ALU` + Shift/Logic/Adder
- Stage 4: `PC update`/Branch/Jump

## 폴더 구조
- `Code/`
	- 알고리즘 기계어: Xorshift, Xoshiro, SHA-256, ChaCha20
	- `assembler32.py`: Python으로 구현한 32비트 어셈블러
- `Source/`
	- `CPU_TOP.v`: 전체 모듈 통합 Top
	- `Stage1/`: Stage1 전체 및 구성 유닛
	- `Reg_TOP(Stage2)/`: Stage2 전체 및 구성 유닛
	- `ALU_TOP(Stage3)/`: Stage3 전체 및 구성 유닛
	- `PC_TOP(Stage4)/`: Stage4 전체 및 구성 유닛
	- `Controller/`: FSM 및 Control 신호 생성
- `TestBench/`: 각 모듈별 테스트벤치

## 어셈블러 사용법 (`Code/assembler32.py`)
- 입력 형식:
	- 명령어 뒤는 공백, 피연산자는 쉼표+공백(`, `) 또는 공백으로 구분
	- 예: `ADD $t1, $t2, $t3` 또는 `ADD $t1 $t2 $t3`
- 주요 규칙:
	- R 기본: `$tX $tY $tZ` → `rd rs rt`
	- SLL/SRL/SRA: `$tX $tY imm` → `rd rs sh` (rt=0)
	- I (BEQ/BNE 제외): `$tX $tY imm` → `rt rs imm`
	- BEQ/BNE: `$tX $tY imm` → `rs rt imm`
	- SLXOR/SRXOR: `$tX $tY $tZ sh` → `rd rs rt sh`
	- LW/SW: `$tX imm($tY)` 또는 `$tX $tY imm` → `rt rs imm`
- 실행 예시 (파일 입력):
	- PowerShell
		```powershell
		python .\Code\assembler32.py .\Code\program.asm
		```

## 테스트
- `TestBench/`의 각 `tb_*.v`를 사용해 모듈 단위 검증 수행
- 시뮬레이터에서 Stage별 신호 확인 및 알고리즘 벤치마크 진행

## 참고
- 입력의 쉼표는 자동 제거되며 다중 공백은 하나로 정규화됩니다.
- 분기 오프셋/주소 규칙은 시스템 사양에 따릅니다.