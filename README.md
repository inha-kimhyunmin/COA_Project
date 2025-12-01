XOR, Shift, Rotate 연산 속도 개선을 위한 CPU



12191529 장준영

12211472 김현민

12211785 송상윤

12236553 안효리

폴더 구조

Code 폴더
Xorshift, Xoshiro, SHA-256, ChaCha20 알고리즘을 기계어로 적어놓은 코드
Python을 이용해서 구현한 32비트 어셈블러


Source 폴더
CPU_TOP.v : 각 모듈들을 전부 합친 코드
- Stage1
Stage1전체 코드, Stage1의 각 유닛들의 코드
- Reg_TOP(Stage2)
Stage2전체 코드, Stage2의 각 유닛들의 코드
- ALU_TOP(Stage3)
Stage3전체 코드, Stage3의 각 유닛들의 코드
- PC_TOP(Stage4)
Stage4전체 코드, Stage4의 각 유닛들의 코드
- Controller
Control State Machine구현과 Control 신호를 출력하는 Controller 코드