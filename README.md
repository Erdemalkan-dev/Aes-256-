# Aes-256-
This Repo founded to access Aes 256 files
AES-256 on FPGA (UART I/O + Live Status Display)

Hardware implementation of AES-256 encryption/decryption on FPGA, with a UART interface for host communication and 7-segment displays for live status/debug. Designed for teaching, experimentation, and easy integration into embedded pipelines.

Language: Verilog
I/O: UART RX/TX (configurable baud)
UI: 7-segment display drivers + LEDs
Flow: Simulation (xsim/Questa), Synthesis (Vivado)

✨ Features

AES-256 core (14 rounds, 128-bit block, 256-bit key)

Encrypt & Decrypt support (includes InvSubBytes, InvShiftRows, InvMixColumns)

On-chip key schedule for 256-bit keys

UART bridge for FPGA↔Host data exchange

Control FSMs for deterministic sequencing

7-segment display for system status (IDLE/BUSY/DONE/ERR)

Configurable baud rate and pipeline depth

Tested with NIST vectors

Encrypt: AddRoundKey → 13× (SubBytes → ShiftRows → MixColumns → AddRoundKey) → Final (SubBytes → ShiftRows → AddRoundKey)
Decrypt: AddRoundKey → 13× (InvShiftRows → InvSubBytes → AddRoundKey → InvMixColumns) → Final (InvShiftRows → InvSubBytes → AddRoundKey)

🔌 UART Protocol

Serial: 8N1 @ 115200 baud (default, configurable)
Frame Example:
[0xAA][CMD][FLAGS][KEY(32B)][BLOCK(16B)]
Response:
[0x55][STATUS][META][DATA(16B)]

| Key (256-bit)                                                    | Plaintext                        | Expected Ciphertext              |
| ---------------------------------------------------------------- | -------------------------------- | -------------------------------- |
| 603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4 | 6bc1bee22e409f96e93d7e117393172a | f3eed1bdb5d2a03c064b5a7e3db181f8 |
