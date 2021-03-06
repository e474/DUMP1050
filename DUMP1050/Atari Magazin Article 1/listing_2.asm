; Listing 2 

; IDIESER BEFEHL ERMOEGLICHT DAS 
; DAS AUSLESEN DES FLOPPYBETRIEB- 
; SYSTEMS 
;
DAUX 	=	$82 
PUFL 	=	$99 
PUFH 	=	$9A 
RAMPUF 	=	$8000 
;
SENDCPL	=	$F48F 
SENDPUF	=	$F503 
;
		* = $9000 		; KOMMANDOADR. 
;
		LDA DAUX+1		; BEI POSITIVEM 
		BMI NOSWITCH 	; DAUX+1 
		ORA #$80 		; 2. 4K ROM
		STA DAUX+1 		; EINBLENDEN 
;
; BLENDE 2. 4K ROM EIN 
		LDA $FFF9 
;
NOSWITCH LDY #0 
LOOP	CPY #$F6 		; AUFPASSEN
		BCC OK 			; DASS NICHT
		CPY #$FA 		; AUS VERSEHEN
		BCS OK 			; UMGEBLENDET
		LDA DAUX+1 		; WIRD
		CMP #$FF 		; ( LDA #$FFF8 )
		BNE OK 			; ( LDA #$FFF9 )
		JMP WEITER 
;
OK		LDA (DAUX),Y
		STA RAMPUF,Y
WEITER 	INY
		BNE LOOP 		
;
; BLENDE 1. 4K ROM EIN
;
	LDA $FFF8 
;
; SIGNALISIERE COMPUTER, DASS 
; OPERATION BEENDET IST UND 
; DATENBLOCK GLEICH FOLGT 
;
	JSR SENDCPL 
	
; SENDE 256 DATENBYTES MIT 
; CHECKSUMME
	
	LDA # <RAMPUF 
	STA PUFL 
	LDA	#> RAMPUF 
	STA PUFH
	LDY #0 
	JSR SENDPUF 
;
; ZURUECK ZUM SYSTEM 
;
	RTS
	
