DUMP1050 - Dump modified 1050 ROM to Atari DOS file

Notes
- Dumps the 1050 drive ROM for Happy, Lazer or similar drives
- Dumps the 1050 command table
- Should run on any stock 8-bit computer (16K RAM or more)
- May transfer data at an unpredictable rate with Hias's high-speed patched OS routines
- May not work correctly if 1050 drive is already programmed by DOS, etc.
- Source code is assembled with ATASM Macro Assembler
- Development environment was WUDSN running on Linux
- Dumped ROM files are not suitable for CRC comparision as bank select addresses ($FFF8, $FFF9) do not return consistent values when dumped
- First public release, so best used with the ATR included
- Based on code from the German Magazine "Atari Magazin", 1987 issues 1 - 5
