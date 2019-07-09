;
; TEXT.asm
;

;	
; Strings used in text output, file names, etc. 
; These strings may get modified to show which drive number is being worked with, etc.
; Put at start of program due to some assemblers not liking forward references in Macros, etc., etc.	
;

WELCOME_TEXT
	.BYTE EOL
	.BYTE "--------------------------------------",EOL
	.BYTE "E474's modded 1050 ROM dumper V. "
VERSION_NUMBER
	.BYTE "1.0",EOL
	.BYTE "Copyright (c) E474 06 July, 2019",EOL
    .BYTE "<"
    .BYTE +$80,"SYSTEM RESET"						; inverse video - specific to ATASM?
    .BYTE "> to exit",EOL
	.BYTE "Source code at github.com/e474",EOL
	.BYTE "Please e-mail dumped files to:",EOL
	.BYTE " e474sr@gmail.com",EOL
	.BYTE "--------------------------------------",EOL,EOL
    .BYTE "Drive number to dump (1 - 4): "
WELCOME_TEXT_LENGTH = * - WELCOME_TEXT

;
; Initial prompt
;

;DRIVE_NUMBER_QUESTION								
;    .BYTE "Drive number to dump (1 - 4): "
;DRIVE_QUESTION_LENGTH = * - DRIVE_NUMBER_QUESTION	; length of string, used as argument to PRINT macro

BAD_DRIVE_NUMBER_TEXT
	.BYTE 	EOL,EOL,"* Error: Drive number not between 1 and 4", EOL		; inform user
BAD_DRIVE_NUMBER_TEXT_LENGTH = * - BAD_DRIVE_NUMBER_TEXT
	
;
; Feedback on which drive is being worked on
;
DRIVE_SELECTED_MESSAGE								
	.BYTE EOL, EOL, "* Reading drive: "
DRIVE_NUMBER_CHAR
	.BYTE	"1"										; This value is updated
DRIVE_SELECTED_LENGTH = * - DRIVE_SELECTED_MESSAGE	; length of string, used as argument to PRINT macro

DRIVE_NUMBER
	.BYTE 0											; numeric drive number ($1..$4), (not
													; character code for drive number)
;
; Drive can't be programmed error message
;
DRIVE_CANNOT_READ_COMMAND_TABLE_MESSAGE				
	.BYTE "* Error: Cannot read command table from drive "
DRIVE_NUMBER_NOT_HAPPY
	.BYTE 	"1",EOL										; This value is updated
DRIVE_NUMBER_NOT_HAPPY_LENGTH = * - DRIVE_CANNOT_READ_COMMAND_TABLE_MESSAGE ; length of string, used as argument to PRINT macro

; Drive has a command table, which has been successfully read
DRIVE_READ_COMMAND_TABLE_MESSAGE_TEXT	
	.BYTE "* Read command table OK",EOL			; Tell the user 
DRIVE_READ_COMMAND_TABLE_MESSAGE_TEXT_LENGTH = * - DRIVE_READ_COMMAND_TABLE_MESSAGE_TEXT ; length of string, used as argument to PRINT macro

UPDATING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT	
	.BYTE "* Updating command table",EOL
UPDATING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT_LENGTH = * - UPDATING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT ; length of string, used as argument to PRINT macro

DUMPING_COMMAND_TABLE_HEADER_TEXT
	.BYTE "Command table dump file",EOL
DUMPING_COMMAND_TABLE_HEADER_TEXT_LENGTH = * - DUMPING_COMMAND_TABLE_HEADER_TEXT



PROGRAMMING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT	
	.BYTE "* Uploading new command table",EOL
PROGRAMMING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT_LENGTH = * - PROGRAMMING_DRIVE_COMMAND_TABLE_MESSAGE_TEXT ; length of string, used as argument to PRINT macro

PROGRAMMING_DRIVE_NEW_COMMAND_MESSAGE_TEXT	
		.BYTE "* Uploading new command" ,EOL
PROGRAMMING_DRIVE_NEW_COMMAND_MESSAGE_TEXT_LENGTH = * - PROGRAMMING_DRIVE_NEW_COMMAND_MESSAGE_TEXT ; length of string, used as argument to PRINT macro

PROGRAMMED_DRIVE_NEW_COMMAND_MESSAGE_TEXT	
		.BYTE "* Drive programmed with new command" ,EOL
PROGRAMMED_DRIVE_NEW_COMMAND_MESSAGE_TEXT_LENGTH = * - PROGRAMMED_DRIVE_NEW_COMMAND_MESSAGE_TEXT ; length of string, used as argument to PRINT macro

PROTECTED_NEW_COMMAND_MESSAGE_TEXT	
		.BYTE "* Command memory area protected" ,EOL
PROTECTED_NEW_COMMAND_MESSAGE_TEXT_LENGTH = * - PROTECTED_NEW_COMMAND_MESSAGE_TEXT ; length of string, used as argument to PRINT macro

TELL_TO_RENAME_IN_DOS_TEXT
		.BYTE "Please exit to DOS and rename file(s)",EOL
TELL_TO_RENAME_IN_DOS_TEXT_LENGTH = * - TELL_TO_RENAME_IN_DOS_TEXT


READING_BANK_NUMBER_MESSAGE_TEXT	
		.BYTE "* Reading ROM bank "
READING_BANK_NUMBER_CHAR
		.BYTE "1"
		.BYTE " from drive" ,EOL
READING_BANK_NUMBER_MESSAGE_TEXT_LENGTH = * - READING_BANK_NUMBER_MESSAGE_TEXT ; length of string, used as argument to PRINT macro


;
; file that command table is written to, file extension depends 
; on drive number begin dumped
;
DUMPING_COMMAND_TABLE_TO_FILE_MESSAGE
    .BYTE "* Dumping command table to "					; tell user dumping to a 

COMMAND_TABLE_DUMP_FILE								
.BYTE "D:CTAB.D"
COMMAND_TABLE_DUMP_FROM_DRIVE
.BYTE "1"											; .D# This # value is updated
.BYTE EOL
DUMPING_COMMAND_TABLE_TO_FILE_MESSAGE_LENGTH = * - DUMPING_COMMAND_TABLE_TO_FILE_MESSAGE	; length of string, used as argument to PRINT macro

;
; file that Drive ROM banks 1 and 2 is written to, file extension depends 
; on drive number begin dumped
;

STARTING_TO_DUMP_ROM_TEXT
	.BYTE "* Dumping drive ROM",EOL
STARTING_TO_DUMP_ROM_TEXT_LENGTH = * - STARTING_TO_DUMP_ROM_TEXT


DUMPING_TO_ROM_FILE_MESSAGE
    .BYTE "* Writing drive ROM to "					; tell user dumping to a 
ROM_DUMP_FILE
.BYTE "D:ROM.D"
ROM_DUMP_FROM_DRIVE
.BYTE "1"											; .D# This # value is updated
.BYTE EOL
DUMPING_TO_ROM_FILE_MESSAGE_LENGTH = * - DUMPING_TO_ROM_FILE_MESSAGE			; length of string, used as argument to PRINT macro

;
; Text buffer, used for converting a byte into hexadecimal text representation
;
COMMAND_TABLE_INDEX .BYTE 0
CURRENT_COMMAND		.BYTE 0
.BYTE " = $"
HEX_VALS
.BYTE "     "
.BYTE EOL
DISPLAY_CURRENT_COMMAND = * - CURRENT_COMMAND		; length of string, used as argument to PRINT macro

OVER_WRITE_CHAR
	.BYTE 0, EOL

ROM_DUMPED_MESSAGE_TEXT	
	; .BYTE EOL,
	.BYTE "+ ROM dumped",EOL, "Pleased to be of service",EOL 
ROM_DUMPED_MESSAGE_TEXT_LENGTH = * - ROM_DUMPED_MESSAGE_TEXT ; length of string, used as argument to PRINT macro


EXISTING_FILE_MESSAGE
	.BYTE "Over-write "
EXISTING_FILE_NAME
	.BYTE 0
	* = * + 40				; 40 bytes buffer for file name
EXISTING_FILE_NAME_LENGTH = * - EXISTING_FILE_NAME
	
OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT	
	.BYTE "Over-write "
OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT_PREFIX_LENGTH = * - OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT	
OVER_WRITE_EXISTING_FILE_NAME
	.BYTE 0
	* = * + 40
OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT_LENGTH = * - OUTPUT_OVERWRITE_EXISTING_FILE_MESSAGE_TEXT	

YES_NO_TEXT
	.BYTE "? (Y/N): "		
YES_NO_TEXT_LENGTH = * - YES_NO_TEXT

SYNTHESISED_OVER_WRITE_LENGTH
	.BYTE 0
	

	