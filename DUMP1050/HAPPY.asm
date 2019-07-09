;
; System equates for HAPPY 1050 programming
;
; This was cobled together from the German magazine "Atari Magazin"
; issues 1987 1 - 5 (inclusive)
;
;
; 
; LOW MEMORY RAM
;
HAPPY_DAUX1 						=	$82
HAPPY_DAUX2							=	$83
HAPPY_TRACK							=	$8D

HAPPY_BUF_LO						= 	$99
HAPPY_BUF_HI						=	$9A
;
;
; system equates for HAPPY 1050 programming
;
;

;
; RIOT PORTS
;
HAPPY_PORTA						= 	$280
HAPPY_PACTL						=	$281
HAPPY_PORTB						=	$282
HAPPY_PBCTL						=	$283



HAPPY_TIMER_VALUE				=	$294
HAPPY_FAST_TIMER				= 	$296
HAPPY_START_TIMER				=	$29F
HAPPY_BUFFER_STATUS				=	$400
HAPPY_DATA						= 	$403

;
; MAIN BUFFER MEMORY 
;
HAPPY_RAM_BUFFER1				=	$8000

;
; CALLABLE ROUTINES
;
HAPPY_SEND_BUFFER				=	$F000		; Send buffer to computer
HAPPY_SEND_STATUS				=	$F002 		; Send status (Akku) to computer Computer 
HAPPT_RESTART					=	$F040 		; Restart 
HAPPY_MOTOR_OFF					=	$F1FB 		; Motor off 
HAPPY_START_MOTOR				=	$F212 		; Start motor 
HAPPY_MOTOR_ON					=	$F239 		; Motor on 
HAPPY_MOVE_HEAD_TO_TRACK_0		=	$F275 		; Head to track 0 
HAPPY_MOVE_HEAD_TO_TRACK		= 	$F2EC 		; Head to track 
HAPPY_CONTROLLER_RESET			=	$F362 		; Controler Reset 
HAPPY_EVALUATE_COMMAND			=	$F40B 		; Evaluate command 
HAPPY_SEND_ACKNOWLEDGE			=	$F485 		; Send Acknowledgement 
HAPPE_SEND_NACK					=	$F48A 		; Send Nack 
HAPPY_SEND_COMPLETE				=	$F48F		; Send Complete
HAPPY_SEND_ERROR				=	$F494 		; Send Error 
HAPPY_RECEIVE_1_BYTE			=	$F499 		; Receive 1 byte from computer 
HAPPY_SEND_BUFFER_QUESTIONABLE	=	$F503		; NOT LISTED IN MAGAZINE
HAPPY_READ_SECTOR				=	$F5BB 		; Read one sector
HAPPY_WRITE_SECTOR				=	$F6A8 		; Write a sector 
HAPPY_FORMAT_TRACK				=	$F8D4 		; Format a track 
HAPPY_FLASH_POWERLIGHT			=	$FBA3 		; engine flashing on error 

;
; FDC Command codes
;

FDC_READ_SECTOR					=	$88
FDC_WRITE_SECTOR				=	$A8
FDC_READ_ADDRESS				=	$C0
FDC_READ_TRACK					=	$E0
FDC_FORMAT_TRACK				=	$F0
FDC_FORCE_INTERRUPT				=	$D0


;
; MAIN BUFFER MEMORY IN HAPPY
;
HAPPY_RAM_BUFFER					=	$8000

; rom banks 1 and 2

HAPPY_ROM_BANK_1				= $F000
HAPPY_ROM_BANK_2				= $7000

