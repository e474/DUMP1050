
;
; Author:	E474
; Version: 	1.0
; Copyright (c) 2019, E474, United Kingdom.
; File:		PRGHAPPY.asm
;
; Program an upgraded 1050 Floppy Disk Drive with a new SIO command 'X'
; Read drive ROMS using this new 'X' command
; Dump ROMS to file
;  
; 1050 Command Table is also dumped to screen and file
; works best with a Happy, or "compatible" drive, drives 1 - 4 supported
;
; Code uploaded to Happy based on articles in German Atari Magazin 1987, issues 1-5 
;
; 
 
;
; Handy system equates defined as part of ATASM
;

	.INCLUDE "OS.asm"

;
; Equates for sizes, buffers and variables
;

;VERSION_STRING = "1.0"

COMMAND_TABLE_SIZE	 	= 	$20		; Number of SIO commands that can be defined
COMMAND_TABLE_POINTER 	= 	$80		; Page zero variable used for indirect addressing

COMMAND_TABLE_BUFFER	=	$600	; Command table from drive is loaded here

;ROM_BANK_BUFFER			= 	$3000

;ROM_BANK_1_BUFFER		=	$6000	; Drive ROM 1 is dumped to this buffer 
ROM_BANK_2_BUFFER		=	$7000	; Drive ROM 2 is dumped to this buffer 



DRIVE_COMMAND_TABLE		= 	$9780	; Location in Drive RAM of Command Table 
DRIVE_COMMAND_ADDRESS	= 	$9000	; Location in Drive RAM to write new commands 
									; to. This memory location is also used on 
									; the 8-bit, e.g. assembled to, as it 
									; simplifies coding

SIO_READ_DATA			= $40
SIO_WRITE_DATA			= $80

;
; Start of actual program area
;
									
	*= $2000
	JMP PROGRAM_INIT				; Jump over Strings defined at start of
									; program (stops some assemblers complaining)
;
; MAC65 Macro files. Mainly used for I/O Macros
;

	.INCLUDE "SYSEQU.M65"
	.INCLUDE "IOMAC.LIB"
	
	
;
; Strings and variables
;
	
	.INCLUDE "TEXT.asm"
  
;
;
;
;
;
;
;
; Start here
; 

PROGRAM_INIT	

	LDA #0
	STA LMARGN											; set left margin to zero

	OPEN 2,4,0,"K:"									; open keyboard for reading


;
; main loop
;
GET_DRIVE_NUMBER

; Greeting, purpose, exit method

	BPUT 0, WELCOME_TEXT,WELCOME_TEXT_LENGTH

PROCESS_KEYPRESS
	BGET 2,DRIVE_NUMBER_CHAR,1  							; Read keystroke
    BPUT 0,DRIVE_NUMBER_CHAR,1  							; Echo keystroke

	LDA DRIVE_NUMBER_CHAR								; Validate drive number is in range 1 - 4
    CMP #'1
    BMI INVALID_DRIVE_NUMBER
    CMP #'5
    BMI VALID_DRIVE_NUMBER
INVALID_DRIVE_NUMBER								; not a valid drive

	BPUT 0, BAD_DRIVE_NUMBER_TEXT, BAD_DRIVE_NUMBER_TEXT_LENGTH	
	
	JMP GET_DRIVE_NUMBER							; try again
	
VALID_DRIVE_NUMBER

	SEC
	LDA	DRIVE_NUMBER_CHAR					; convert DRIVE_NUMBER_CHAR into actual drive number (1..4)
	SBC #'0		 							;
	STA DRIVE_NUMBER
; 
; Everything is automatic from now on
;
; Processing is
; 1. Load drive command table from drive (ask for new drive number if this fails)
; 2. Write out command table to screen and disk file (D1)
; 3. Find empty place in command table
; 4. Update command table to include new 'X' SIO command, and vector for the code 
; 5. Write updated table to drive memory
; 6. Write code for SIO 'X' command to drive memory
; 7. Fill both buffers on 8-bit with drive ROM code using uploaded 'X' command
; 8. Write out buffers to file on disk 1
;
; Failure generally indicated with an error message, and prompt for new drive number
;
;

;
; Load Command Table from specified drive
;	

	PRINT 0,DRIVE_SELECTED_MESSAGE, DRIVE_SELECTED_LENGTH
	 
	LDA	#<COMMAND_TABLE_BUFFER
	STA	DBUFLO
	LDA	#>COMMAND_TABLE_BUFFER
	STA	DBUFHI
	
	LDA	#<DRIVE_COMMAND_TABLE		; Sectors are mapped to drive memory
	STA	DAUX1						; Command Table is stored at $97A0
	LDA	#>DRIVE_COMMAND_TABLE		; So memory is read from sector $9780
	STA DAUX2
	LDA #'R							
	STA DCOMND
	
	LDX #SIO_READ_DATA
	STX DSTATS
	
	LDA #$31						; SIO code for disk drive
	STA DDEVIC
	
	LDA DRIVE_NUMBER
	STA DUNIT
	
	LDA #2
	STA DTIMLO
	
	LDA #$80
	STA DBYTLO
	LDA #0
	STA DBYTHI
	
    JSR	SIOV
    
    BMI	ERROR
    JMP PROCESS_COMMAND_TABLE		; Command Table in memory, procees it and continue

ERROR								; Drive didn't return data at this sector/address
									; ** Show stopper ** for this drive number
	LDA DRIVE_NUMBER_CHAR
	STA DRIVE_NUMBER_NOT_HAPPY
									; Tell the user
	PRINT 0,DRIVE_CANNOT_READ_COMMAND_TABLE_MESSAGE,DRIVE_NUMBER_NOT_HAPPY_LENGTH

	JMP GET_DRIVE_NUMBER			; Start again

;
; Drive returned a command table
;
PROCESS_COMMAND_TABLE				

	BPUT 0, DRIVE_READ_COMMAND_TABLE_MESSAGE_TEXT, DRIVE_READ_COMMAND_TABLE_MESSAGE_TEXT_LENGTH

;
; set up page zero indirect addressing pointer
; commands start at $97A0, which is $20 bytes into the buffer/sector
;

	LDA #<(COMMAND_TABLE_BUFFER+$20)
	STA COMMAND_TABLE_POINTER
	LDA #>(COMMAND_TABLE_BUFFER+$20)
	STA COMMAND_TABLE_POINTER+1

	LDA #0
	STA COMMAND_TABLE_INDEX
	
	JSR PRINT_COMMAND_TABLE_PREP		; lots of processing done to output
										; command table to screen and also save it 
										; to a file. Pretty printing, but not
										; that important

;
; Update drive table with new command pointer to command 'X'
; Progress report
;

	BPUT 0, UPDATING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT, UPDATING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT_LENGTH  ; length of string, used as argument to PRINT macro
	
;
; Look for an empty place in the command table (empty is indicated by
; command byte of $00)
;
	
	LDY	#$20						; Commands start at offset $20

SEARCH_FOR_UNUSED_ENTRY_IN_COMMAND_TABLE	
	LDA COMMAND_TABLE_BUFFER,Y
	BEQ ADD_NEW_COMMAND						; Found available location
	CMP #'X									; drive already has an 'X' command
	BNE CHECK_REST_OF_TABLE
	JMP DUMP_DRIVE_MEMORY						; assume program is being re-run
CHECK_REST_OF_TABLE
	INY
	JMP SEARCH_FOR_UNUSED_ENTRY_IN_COMMAND_TABLE	

;
; found empty spot - update command code and vector for actual code
; format for command table is
; $20 character codes = SIO commands, followed by $20 lo byte address for 
; handler routines, then $20 hi byte addresses 
;
	
ADD_NEW_COMMAND

	LDA #'X							; Add new SIO command code 'X' to command code table buffer
	STA COMMAND_TABLE_BUFFER,Y

	LDA #<COMMAND_X  				; Add low part of address of command, to command table in buffer
	STA	COMMAND_TABLE_BUFFER+$20,Y				
	LDA #>COMMAND_X					; Add hi part of address of command
	STA	COMMAND_TABLE_BUFFER+$40,Y
	
	
;
; Program drive with new command table
; 

	BPUT 0, PROGRAMMING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT, PROGRAMMING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT_LENGTH

	LDA	#<COMMAND_TABLE_BUFFER		; Updated command table buffer
	STA	DBUFLO
	LDA	#>COMMAND_TABLE_BUFFER
	STA	DBUFHI
	
	LDA	#<DRIVE_COMMAND_TABLE		; Sectors are mapped to drive memory
	STA	DAUX1						; 
	LDA	#>DRIVE_COMMAND_TABLE
	STA DAUX2

	LDA #'P							; setup SIO control block
	STA DCOMND

	LDX #SIO_WRITE_DATA
	STX DSTATS

	LDA #$31
	STA DDEVIC

	LDA DRIVE_NUMBER
	STA DUNIT

	LDA #2
	STA DTIMLO
	
	LDA #$80
	STA DBYTLO									
	LDA #0
	STA DBYTHI
	
    JSR	SIOV						; write command table back to drive

;
; command table has been written to drive
; now write actual command to drive

;	SEND NEW COMMAND TO FLOPPY 
;	(COMPUTER-RAM	$9000 - $93FF)
;	(HAPPY-RAM		$9000 - $93FF)
;

	BPUT 0, PROGRAMMING_DRIVE_NEW_COMMAND_MESSAGE_TEXT,PROGRAMMING_DRIVE_NEW_COMMAND_MESSAGE_TEXT_LENGTH

	LDA #<COMMAND_X
	STA	DBUFLO					; atari memory and 1050 memory are at same addresses
	STA DAUX1
	LDA	#>COMMAND_X
	STA	DBUFHI
	STA DAUX2
	
UPLOAD_NEW_COMMAND_TO_DRIVE		; (hint) memory $9000 - $93FF written
								
	LDA #'P
	STA DCOMND
	
	LDX #SIO_WRITE_DATA
	STX DSTATS

	LDA #$31
	STA DDEVIC

	LDA DRIVE_NUMBER
	STA DUNIT
	
	LDA #2
	STA DTIMLO
	
	LDA #$80
	STA DBYTLO									
	LDA #0
	STA DBYTHI
	
    JSR	SIOV					; write block

								; maths to update (by $80 bytes = 1 sector) 
								; where data is read/written to
	CLC
	LDA DBUFLO
	ADC #$80
	STA DBUFLO
	BCC ?L1 					;*+5
	INC DBUFHI

?L1
	LDA DBUFLO
	STA DAUX1
	LDA DBUFHI
	STA DAUX2
	CMP #[>COMMAND_X_END]+1					; next page after end of drive X command program code
	BCC UPLOAD_NEW_COMMAND_TO_DRIVE			; more sectors/memory to write

	BPUT 0, PROGRAMMED_DRIVE_NEW_COMMAND_MESSAGE_TEXT, PROGRAMMED_DRIVE_NEW_COMMAND_MESSAGE_TEXT_LENGTH
		
;
; Protect RAM area in floppy from being over-written by track buffer
; Best bet is that this disables the track buffer, so uploaded
; SIO 'X' command is not over-written/trashed
;

	LDA #$60
	STA DAUX1
	STA DAUX2 
	
	LDA #'H
	STA DCOMND
	
	LDA #$80
	STA DSTATS

	LDA #$31
	STA DDEVIC

	LDA DRIVE_NUMBER
	STA DUNIT
	LDA #2
	STA DTIMLO
	LDA #$80
	STA DBYTLO
;
	LDA #0
	STA DTIMLO+1 ; NOT NECESSARY	
	STA DBYTHI
    JSR	SIOV
;    BMI	?LERROR

	BPUT 0, PROTECTED_NEW_COMMAND_MESSAGE_TEXT, PROTECTED_NEW_COMMAND_MESSAGE_TEXT_LENGTH
 
;
;	Finished programming floppy
;

;
; Now use the newly uploaded 'X' command to download contents of drive ROM	
;

	JMP DUMP_DRIVE_MEMORY



DUMP_DRIVE_MEMORY

;
; setup rom dump file name extension (drive number in file name extension)
;

	LDA DRIVE_NUMBER_CHAR
	STA ROM_DUMP_FROM_DRIVE
	
; 
; open output file
;

	CLOSE 3											; just in case

	LDY #0
SETUP_EXISTING_FILENAME_CHECK_STRING2	
	LDA ROM_DUMP_FILE,Y
	STA EXISTING_FILE_NAME,Y
	INY
	CPY #EXISTING_FILE_NAME_LENGTH
	BNE SETUP_EXISTING_FILENAME_CHECK_STRING2

	BPUT 0,STARTING_TO_DUMP_ROM_TEXT, STARTING_TO_DUMP_ROM_TEXT_LENGTH


	JSR CHECK_FOR_EXISITING_FILE

	BCS OK_TO_WRITE_OUT_ROM_DUMP_TO_FILE
	JMP DO_NOT_OVER_WRITE_FILES

OK_TO_WRITE_OUT_ROM_DUMP_TO_FILE

	OPEN 3,8,0,ROM_DUMP_FILE						

;
; read first bank
;

;
; Tell the user what's going on

	LDY #'1							; bank #1 in putput text
	JSR READING_BANK

; 
; dump bank 1 using SIO 'X' command. Bank 1 is indicated by hi address of
; $F000 (highest bit set)
;

	LDA	# <ROM_BANK_BUFFER
	STA DBUFLO
	LDA	# >ROM_BANK_BUFFER
	STA DBUFHI
	LDA #<HAPPY_ROM_BANK_1
	STA DAUX1
	LDA #>HAPPY_ROM_BANK_1
	STA DAUX2
	
LOOP1
	LDA #$31
	STA DDEVIC
	
	LDA DRIVE_NUMBER
	STA DUNIT
	
	LDA #'X					; new command
	STA DCOMND
	
	LDX #$40
	STX DSTATS
	
	LDA #2
	STA DTIMLO

	LDA #0
	STA DBYTLO
	LDA	#1							; 256 byte sector/memory reads
	STA DBYTHI
	
    JSR	SIOV

	INC	DBUFHI
	INC DAUX2
	LDA DAUX2
	CMP #<[HAPPY_ROM_BANK_1+$1000]	; may be a bug in MAC/65
	BNE LOOP1

;
; The drive ROM bank 1 has now been transferred to the 8bit's memory
;
; ROM bank 1 in ROM_BANK_BUFFER

; tell the user first bank now being dumped to file

	JSR INFORM_AND_DUMP

;
; read second bank
;

;
; Tell the user what's going on
;

	LDY #'2							; bank #2 in putput text
	JSR READING_BANK


;
; dump bank 2 using SIO 'X' command. Bank 1 is indicated by hi address of
; $7000 (highest bit set) - this happens to coincide with the value of
; ROM_BANK_2_BUFFER
;
	
	LDA #<ROM_BANK_BUFFER
	STA DBUFLO
	LDA	#>ROM_BANK_BUFFER
	STA DBUFHI
	LDA # <HAPPY_ROM_BANK_2
	STA DAUX1
	LDA # >HAPPY_ROM_BANK_2
	STA DAUX2
	
LOOP2
	LDA #$31
	STA DDEVIC
	LDA DRIVE_NUMBER
	STA DUNIT
	LDA #'X					; new command
	STA DCOMND
	LDX #$40
	STX DSTATS
	LDA #2
	STA DTIMLO
	LDA #0
	STA DBYTLO
	LDA	#1
	STA DBYTHI
    JSR	SIOV

	INC DAUX2
	INC DBUFHI
	LDA DAUX2
	CMP #>[HAPPY_ROM_BANK_2+$1000]					; $8000 is end of buffer for ROM_BANK_BUFFER
	BNE LOOP2
	
; ROM bank 2 in ROM_BANK_BUFFER
;

; 
; write buffers out to disk file (drive 1)
;

;
; Note use of I/O macros
;

	JSR INFORM_AND_DUMP

	CLOSE 3
	
	BPUT 0,ROM_DUMPED_MESSAGE_TEXT,ROM_DUMPED_MESSAGE_TEXT_LENGTH

	JMP GET_DRIVE_NUMBER							; Maybe another drive?

;
; *******************************************************************
; subroutines
; *******************************************************************
;


READING_BANK
	STY READING_BANK_NUMBER_CHAR
	BPUT 0, READING_BANK_NUMBER_MESSAGE_TEXT, READING_BANK_NUMBER_MESSAGE_TEXT_LENGTH
	RTS

INFORM_AND_DUMP
	BPUT 0, DUMPING_TO_ROM_FILE_MESSAGE, DUMPING_TO_ROM_FILE_MESSAGE_LENGTH
	BPUT 3,ROM_BANK_BUFFER,$1000
	RTS

;
; Pretty print the command table
;
; Nothing amazing. Format of command table is
; $20 bytes of (SIO) command codes
; $20 bytes of lo byte of vector to command
; $20 bytes of hi byte of vector to command
; Command table is located at $97A0 in drive memory, which is read in using a
; read at sector (memory address) of $9780 - so the command codes actualy
; start $20 bytes into the buffer used to load data from $9780 
; ($9780 + $20 = $97A0 = start of command code table)
;
; empty commands (command code is $00) are skipped, and not listed
;
	
PRINT_COMMAND_TABLE_PREP

;
; set up file name for dumping command table (extension is ".D<drive number>")
; tell the user what is going on, open file, etc
;

	LDA DRIVE_NUMBER_CHAR
	STA COMMAND_TABLE_DUMP_FROM_DRIVE
	CLOSE 3								; Just in case

	BPUT 0,DUMPING_COMMAND_TABLE_TO_FILE_MESSAGE,DUMPING_COMMAND_TABLE_TO_FILE_MESSAGE_LENGTH

	LDY #0
SETUP_EXISTING_FILENAME_CHECK_STRING	
	LDA COMMAND_TABLE_DUMP_FILE,Y
	STA EXISTING_FILE_NAME,Y
	INY
	CPY #EXISTING_FILE_NAME_LENGTH
	BNE SETUP_EXISTING_FILENAME_CHECK_STRING

	JSR CHECK_FOR_EXISITING_FILE
	BCS OK_TO_WRITE_OUT_COMMAND_TABLE_TO_FILE

DO_NOT_OVER_WRITE_FILES
	BPUT 0, TELL_TO_RENAME_IN_DOS_TEXT, TELL_TO_RENAME_IN_DOS_TEXT_LENGTH
	JMP GET_DRIVE_NUMBER

OK_TO_WRITE_OUT_COMMAND_TABLE_TO_FILE


	OPEN 3,8,0,COMMAND_TABLE_DUMP_FILE
	BPUT 3, DUMPING_COMMAND_TABLE_HEADER_TEXT, DUMPING_COMMAND_TABLE_HEADER_TEXT_LENGTH

PRINT_COMMAND_TABLE
	
	LDY COMMAND_TABLE_INDEX
	LDA (COMMAND_TABLE_POINTER),Y
	STA CURRENT_COMMAND
	BNE PROCESS_LINE					; list command to screen and disk file
	JMP SKIP_ZERO						; Current command is $00, don't list
	
PROCESS_LINE	

;
; Convert 2 byte jump vector value into 4 digit hexadecimal value 
; that represents vector used by command in command table
;
; hi byte of vector is (COMMAND_TABLE_POINTER + $40), indexed by Y
; lo byte of vector is (COMMAND_TABLE_POINTER + $20), indexed by Y (see below)
;

	CLC
	LDA COMMAND_TABLE_INDEX
	ADC #$40
	TAY
	LDA (COMMAND_TABLE_POINTER),Y		; hi byte of vector

	JSR HEX_TO_ASCII

; 
; update hi byte (first 2 characters of 4 digit hexadecimal number)
;

	STA HEX_VALS				; upper nyble (4 bits in hex)
	STY HEX_VALS+1				; lower nyble (4 bits in hex)

;
; now do the same for the lo byte of vector, located at 
; COMMAND_TABLE_POINTER + $20, index by Y
;
	CLC
	LDA COMMAND_TABLE_INDEX
	ADC #$20
	TAY
	LDA (COMMAND_TABLE_POINTER),Y

	JSR HEX_TO_ASCII


; update lo byte part of 4 digit hexadecimal number
;
	STA HEX_VALS+2
	STY HEX_VALS+3
;
; output formatted entry of command table to disk file
;
	PRINT 3,CURRENT_COMMAND,DISPLAY_CURRENT_COMMAND

; fall through to next entry in command table
	
SKIP_ZERO
	INC COMMAND_TABLE_INDEX
	LDA COMMAND_TABLE_INDEX
	CMP #COMMAND_TABLE_SIZE				; end of table ?
	BEQ PROCESSED_TABLE
	JMP PRINT_COMMAND_TABLE


PROCESSED_TABLE							; all done
	CLOSE 3								; close file to avoid data loss
	RTS	
	


;
;HEX TO ASCII
;  A = ENTRY VALUE
;
HEX_TO_ASCII
	
 	SED        ;2  @2
 	TAX        ;2  @4
 	AND #$0F   ;2  @6
 	CMP #9+1   ;2  @8
 	ADC #$30   ;2  @10
 	TAY        ;2  @12
 	TXA        ;2  @14
 	LSR        ;2  @16
 	LSR        ;2  @18
  	LSR        ;2  @20
  	LSR        ;2  @22
  	CMP #9+1   ;2  @24
  	ADC #$30   ;2  @26
  	CLD        ;2  @28

;  A = MSN ASCII CHAR
;  Y = LSN ASCII CHAR

	RTS

CHECK_FOR_EXISITING_FILE
		
	; try and open the file specified in EXISTING_FILE_NAME
	
	OPEN 5,4,0,EXISTING_FILE_NAME
	BPL FILE_EXISTS
	JMP DOES_NOT_EXIST
FILE_EXISTS	
	CLOSE 5
	
	; synthesise over-write message

	LDY #0
COPY_EXISTING_FILENAME_LOOP
	LDA EXISTING_FILE_NAME,Y
	CMP #EOL					; not sure if this gets set
	BEQ END_OF_FILENAME_LOOP
	STA OVER_WRITE_EXISTING_FILE_NAME,Y
	INY
	CPY #OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT_LENGTH
	BNE COPY_EXISTING_FILENAME_LOOP

;
; should not get here!
;
	PRINT 0,"File name not EOL terminated!"
	
	CLC
	RTS
	
END_OF_FILENAME_LOOP

; copy yes/no question to end of prompt string

	LDX #0
COPY_YN_LOOP
	LDA YES_NO_TEXT,X
	STA OVER_WRITE_EXISTING_FILE_NAME,Y
	INY
	INX  
	CPX #YES_NO_TEXT_LENGTH
	BNE COPY_YN_LOOP
	
	; add on length of prefix string
	
	CLC
	TYA
	ADC #OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT_PREFIX_LENGTH
	
	STA SYNTHESISED_OVER_WRITE_LENGTH
		
	; write message of specified byyte length to Editor channel
	
	LDX #0					; Channel 0
	LDA #CPBINR
	STA ICCOM,X
	LDA # <OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT
	STA ICBADR,X
	LDA # >OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT
	STA ICBADR+1,X
	LDA SYNTHESISED_OVER_WRITE_LENGTH
	STA ICBLEN,X
	LDA #0
	STA ICBLEN+1,X
	JSR CIO
	
	BGET 2,OVER_WRITE_CHAR,1
	BPUT 0,OVER_WRITE_CHAR,2		; there is a .BYTE EOL after it for sneaky coding
	
	LDA OVER_WRITE_CHAR


	CMP #'Y
	BEQ OK_TO_WRITE_FILE
	CLC
	RTS
	
DOES_NOT_EXIST
	CLOSE 5
OK_TO_WRITE_FILE	
	SEC				; no problem to proceed
	RTS
	
END_OF_PROGRAM_CODE

ROM_BANK_BUFFER = *






;
;
;
;
; this SIO command allows you to read a modified 1050 drive ROM
; it executes inside the 1050
;
; space between $9000 and $93ff can be used for programming drive (1:1) 
; correspondance between 1050 address space and 8bit address space, which helps
; with generating machine code with the correct JMPs, JSRs, 
; buffer references, etc.
; Memory from $8000 - $8FFF on the 1050 might be available, but not tested yet
;
; *************************************************************************
; 
; NOTE: This code is executed on the **** 1050 DRIVE **** - so it will not 
; look like 8bit code (system/hardware equates, etc.)
; 
; *************************************************************************
;
	.INCLUDE "HAPPY.asm"
	
	*=DRIVE_COMMAND_ADDRESS

;
; program code that implements SIO command 'X' in the drive's memory
;

COMMAND_X			
;
; see which bank is being addressed by inspecting HAPPY_DAUX2
; and checking highest value bit ($80)
; bank switch as approriate by reading from memory address $FFF9 to 
; select ROM bank 2, or reading from memory address $FFF8 to select ROM
; bank 1

	LDA HAPPY_DAUX2
	BMI NOSWITCH
	ORA	#$80
	STA	HAPPY_DAUX2
;	
; SELECT 4k BANK 2
;
	
	LDA $FFF9
;
NOSWITCH
	LDY	#0
LOOP
	CPY #$F8
	BCC OK
	CPY #$FA
	BCS OK
	LDA HAPPY_DAUX2
	CMP #$FF
	BNE OK
	BEQ CONTINUE						; for relocatable code
;
OK	
	LDA (HAPPY_DAUX1),Y					; page zero indirect pointer to 
										; ROM memory, address specified as
										; part of SIO 'X' command
	STA HAPPY_RAM_BUFFER,Y
CONTINUE
	INY
	BNE LOOP
; 
; SELECT 4K BANK 1
;
	LDA $FFF8
;
; SEND 256 DATA BYTES WITH CHECK SUM
;

	JSR HAPPY_SEND_COMPLETE
	
; send 256 data bytes with checksum

	LDA	#<HAPPY_RAM_BUFFER
	STA HAPPY_BUF_LO
	LDA #>HAPPY_RAM_BUFFER
	STA	HAPPY_BUF_HI
	LDY #0
	JSR	HAPPY_SEND_BUFFER_QUESTIONABLE

;
; BACK TO THE SYSTEM
;

	RTS
	
COMMAND_X_END	
	
;
; (DOS) START ADDRESS 
; 
	*= $02E0
	.WORD PROGRAM_INIT
		
