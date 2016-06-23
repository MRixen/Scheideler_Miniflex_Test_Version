%%%
  VERSION:1
  LANGUAGE:ENGLISH
%%%

MODULE MainAF
  !====================================================================
  ! Module: MainAF
  ! Datum: 11.10.12
  ! Version: 0.2
  ! Programmierer: SS
  ! Firma: RBC-Foerdertechnik
  !
  ! Beschreibung: Ansteuerung für Anyfeeder.
  ! Einbindung in PV als normales Förderband.
  ! somit kaum Änderungen an PvSys nötig.
  !====================================================================
  !
  PERS bool TPInfo:=TRUE;
  CONST num nBlackScreen:=100;
  PERS bool bCoordReceived{4};
  PERS bool bGrabInProgres{4};
  PERS bool bWaitForData{4};
  !AnyFeeder Variablen die von PickVision kommen
  PERS num amountOfDetails:=10.0133;
  PERS num amountOfDetails1:=6.44431;
  PERS num amountOfDetails2:=9.08681;
  PERS num amountOfDetails3:=4.46525;
  
  PERS num amountOfDetails1_0:=0;
  PERS num amountOfDetails1_1:=0;
  PERS num amountOfDetails1_2:=0;
  PERS num amountOfDetails1_3:=0;
  
  PERS num amountOfDetails2_0:=0;
  PERS num amountOfDetails2_1:=0;
  PERS num amountOfDetails2_2:=0;
  PERS num amountOfDetails2_3:=0;
  
  PERS num amountOfDetails3_0:=20.0133;
  PERS num amountOfDetails3_1:=6.44431;
  PERS num amountOfDetails3_2:=9.08681;
  PERS num amountOfDetails3_3:=4.46525;
  
  PERS num amountOfDetails4_0:=20.0133;
  PERS num amountOfDetails4_1:=6.44431;
  PERS num amountOfDetails4_2:=9.08681;
  PERS num amountOfDetails4_3:=4.46525;
  
  PERS num lamountOfDetails1_0:=0;
  PERS num lamountOfDetails1_1:=0;
  PERS num lamountOfDetails1_2:=0;
  PERS num lamountOfDetails1_3:=0;
  
  !User Settings von PV falls nicht direkt an SPS gesendet.
  PERS num nMaxAmount:=1;
  PERS num nMinAmount:=1;
  PERS num nDispenseTurn:=2;
  PERS num nDispenseSpeed:=2;
  PERS num nFeedFwdTurn:=4;
  PERS num nFeedFwdSpeed:=2;
  PERS num nFlipTurn:=4;
  PERS num nFlipSpeed:=2;
  PERS num nFlipBwdTurn:=4;
  PERS num nFlipBwdSpeed:=2;
  PERS num nFlipFwdTurn:=4;
  PERS num nFlipFwdSpeed:=5;
  !
  PERS bool bAnyFeederInit:=FALSE;
  PERS bool bAnyFeederWork:=FALSE;
  !
  PERS bool bAnyFeederPurge:=FALSE;
  PERS num nPurgeTurn:=100;
  PERS num nPurgeSpeed:=8;
  
  VAR signaldi ldi_AF_SyntaxError;
  VAR signaldi ldi_AF_ServoError1;
  VAR signaldi ldi_AF_ServoError2;
  VAR signaldi ldi_AF_Ready;
  VAR signaldi ldi_AF_Active;


  !====================================================================
  !===================== Anpassung der PvSys ==========================
  !====================================================================
  ! Diese Procedure, Variablen muss in PvSys stehen (StartBelt modifizieren?)
  ! Werte zuweisen, AnyFeeder starten
  !====================================================================
  !PERS bool bAnyFeederInit:=FALSE;
  !PERS bool bAnyFeederWork:=FALSE;
  !AnyFeeder Variablen die von PickVision kommen
  !PERS num amountOfDetails:=19.681;
  !PERS num amountOfDetails1:=8.60648;
  !PERS num amountOfDetails2:=9.50221;
  !PERS num amountOfDetails3:=1.55149;
  !!User Settings von PV
  !PERS num nMaxAmount:=7;
  !PERS num nMinAmount:=3;
  !PERS num nDispenseTurn:=5;
  !PERS num nDispenseSpeed:=5;
  !PERS num nFeedFwdTurn:=5;
  !PERS num nFeedFwdSpeed:=5;
  !PERS num nFlipTurn:=5;
  !PERS num nFlipSpeed:=5;
  !PERS num nFlipBwdTurn:=5;
  !PERS num nFlipBwdSpeed:=5;
  !PERS num nFlipFwdTurn:=10;
  !PERS num nFlipFwdSpeed:=5;
  !!Daten für AnyFeeder
  !PERS bool bAnyFeederInit:=TRUE;
  !PERS bool bAnyFeederWork:=TRUE;
  !AnyFeeder Initialisieren
  !bAnyFeederInit:=TRUE;
  !StartAnyFeeder;
  !LOCAL PROC StartAnyFeeder()
  !Reset DOF_inPosition1;
  !bAnyFeederWork:=TRUE;
  !ENDPROC
  !====================================================================
  !====================================================================

  !====================================================================
  ! AnyFeeder kommunication
  ! Endlosschleife Pickvision sagt was zu tuhen ist
  !====================================================================
  PROC main()
  bAnyFeederInit:=FALSE;
  bAnyFeederWork:=FALSE;
  bAnyFeederPurge:=FALSE;
  Reset do_AF1_FeedFWD;
  Reset do_AF1_FlipFWD;
  Reset do_AF1_FlipBWD;
  Reset do_AF1_Flip;
  Reset do_AF1_Purge;
  Reset do_AF1_Dispense;
  Reset DOF_inPosition2;
  Reset DOF_RunFeeder2;
  TPWrite "COMAF wurde neu gestartet";
  !
  WHILE TRUE DO
    WaitTime 0.03;
    IF DOutput(setTPInfo)=1 THEN
    	TPInfo:=FALSE;
    ENDIF
    IF DOutput(DOF_Runfeeder2)=1 AND DOutput(EntryRequestControlLamp)=0 THEN
    	Reset do_AF1_FeedFWD;
		  Reset do_AF1_FlipFWD;
		  Reset do_AF1_FlipBWD;
		  Reset do_AF1_Flip;
		  Reset do_AF1_Purge;
		  Reset do_AF1_Dispense;
		  Reset DOF_inPosition2;
    	lamountOfDetails1_0:=Round(amountOfDetails1_0); !Gesamtanteil schwarz im Bild
	  	lamountOfDetails1_1:=Round(amountOfDetails1_1);!schwarz vorn am Anyfeeder
	  	lamountOfDetails1_2:=Round(amountOfDetails1_2);!schwarz mitte am Anyfeeder
	  	lamountOfDetails1_3:=Round(amountOfDetails1_3);!schwarz hinten am Anyfeeder
    	AFLogic DOF_Runfeeder2,
    					do_AF1_FeedFWD,
    					do_AF1_FlipFWD,
    					do_AF1_FlipBWD,
    					do_AF1_Flip,
    					do_AF1_Purge,
    					do_AF1_Dispense,
    					DOF_inPosition2,
    					1
    					;
    ENDIF
  ENDWHILE
  ENDPROC

  !====================================================================
  !Prog DoAnyfeederAction
  !Startet die gewünschte Aktion und wartet auf die abarbeitung.
  !====================================================================
  PROC DoAnyfeederAction(VAR SIGNALDO dof_Action,num Feeder1)
  	VAR bool bTimeFlag;
  	IF DOutput(dof_Action)=1 THEN
  		SetDO dof_Action,0;
  		WaitTime 0.2;
  	ENDIF
  	SetDo dof_Action,1;
  	IF Feeder1=1 THEN
  		WaitDI di_AF1_Active,1,\MaxTime:=8,\TimeFlag:=bTimeFlag;
  	ENDIF
  	IF bTimeFlag THEN
  		!RAISE 1;
  		TPWrite "Zeitüberschreitung beim Starten einer Aktion";
  		RETURN;
  	ENDIF
  	SetDo dof_Action,0;
  	IF Feeder1=1 THEN
  		WaitDI di_AF1_Active,0,\MaxTime:=40,\TimeFlag:=bTimeFlag;
  	ENDIF
  	IF bTimeFlag THEN
  		!RAISE 2;
  		TPWrite "Zeitüberschreitung beim Starten einer Aktion";
  		RETURN;
  	ENDIF
  	IF di_AF1_SyntaxError=1 THEN
  		!RAISE 11;
  		TPWrite "Syntaxerror Anyfeeder1";
  		RETURN;
  	ENDIF
  	IF di_AF1_ServoError1=1 THEN
  		!RAISE 12;
  		TPWrite "Servofehler Motor1 Anyfeeder1";
  		RETURN;
  	ENDIF
  	IF di_AF1_ServoError2=1 THEN
  		!RAISE 13;
  		TPWrite "Servofehler Motor2 Anyfeeder1";
  		RETURN;
  	ENDIF
  	!----------------------------------------------------------------------------------------
    !Start Error Handling 
    !----------------------------------------------------------------------------------------
    ERROR
		TEST ERRNO
	  	CASE 1: ErrWrite "Fehler AnyFeeder","Zeitüberschreitung beim Starten einer Aktion"\RL2:="Wo -> Anyfeeder";
	  	CASE 2: ErrWrite "Fehler AnyFeeder","Zeitüberschreitung beim Ausführen einer Aktion"\RL2:="Wo -> Anyfeeder";
	  	CASE 11: ErrWrite "Fehler AnyFeeder","Syntaxerror Anyfeeder1"\RL2:="Wo -> Anyfeeder";
	  	CASE 12: ErrWrite "Fehler AnyFeeder","Servofehler Motor1 Anyfeeder1"\RL2:="Wo -> Anyfeeder";
	  	CASE 13: ErrWrite "Fehler AnyFeeder","Servofehler Motor2 Anyfeeder1"\RL2:="Wo -> Anyfeeder";
	  DEFAULT:
	    ErrWrite "Fehler Anyfeeder aktion","Unbekannter Fehler"\RL2:="Wo -> Anyfeederlogic";
		ENDTEST
		!----------------------------------------------------------------------------------------
    !Ende Error Handling 
    !----------------------------------------------------------------------------------------
  ENDPROC

  !====================================================================
  ! Entscheiden was zu tuhen ist Anyfeeder 1
  !====================================================================
  PROC AFLogic(
  	VAR SignalDO ldo_RunFeeder,
  	VAR SignalDO ldo_AF_FeedFWD,
  	VAR SignalDO ldo_AF_FlipFWD,
  	VAR SignalDO ldo_AF_FlipBWD,
  	VAR SignalDO ldo_AF_Flip,
  	VAR SignalDO ldo_AF_Purge,
  	VAR SignalDO ldo_AF_Dispense,
  	
  	VAR SignalDO ldi_Inposition,
		num Feeder
  	)
  	VAR BOOL bTimeFlag;
  	Reset ldi_Inposition;
  	Reset ldo_RunFeeder;
  	IF Feeder=1 THEN
  		nMaxAmount:=dig_AF1_Max;
  		nMinAmount:=dig_AF1_Min;
  		WaitDI di_AF1_Active,0,\MaxTime:=10,\TimeFlag:=bTimeFlag;
  		IF bTimeFlag THEN
  			IF TPInfo TPWrite "Fehler Anyfeeder 1 nicht bereit.";
  			RETURN;
  		ENDIF
  	ENDIF
  	IF TPInfo TPwrite "amountOfDetails1: "\num:=amountOfDetails;
    IF TPInfo TPwrite "amountOfDetails1: "\num:=amountOfDetails1;
    IF TPInfo TPwrite "amountOfDetails2: "\num:=amountOfDetails2;
    IF TPInfo TPwrite "amountOfDetails3: "\num:=amountOfDetails3;
    IF lamountOfDetails1_0>=nBlackScreen THEN
      ErrWrite "Fehler AnyFeeder","Kamerafeld ist ganz schwarz darf nicht sein"\RL2:="Wo -> AFLogic";
      ExitCycle;
    ELSEIF lamountOfDetails1_0>=(nBlackScreen*0.9) THEN
      IF TPInfo tpwrite "Kamerafeld ist fast ganz schwarz, Flip zurück";
      DoAnyfeederAction ldo_AF_FlipBWD,Feeder1:=Feeder;
    ELSEIF lamountOfDetails1_0<nMinAmount THEN
      IF TPInfo tpwrite "Minimalmenge unterschritten";
      !Zuführen mit Bunker öffnen
      DoAnyfeederAction ldo_AF_Dispense,Feeder1:=Feeder;
      DoAnyfeederAction ldo_AF_FeedFWD,Feeder1:=Feeder;
      DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
    ELSEIF amountOfDetails>nMaxAmount THEN
      IF TPInfo tpwrite"Maximalmenge überschritten";
      !Auswerten in welche Richtung zu Flippen ist
      IF lamountOfDetails1_1 > lamountOfDetails1_2 AND lamountOfDetails1_1 > lamountOfDetails1_3 THEN
        IF TPInfo tpwrite"IF 1";
        DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
      ELSEIF lamountOfDetails1_2 > lamountOfDetails1_1 AND lamountOfDetails1_2 > lamountOfDetails1_3 THEN
        IF TPInfo tpwrite"IF 2";
        DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
      ELSEIF lamountOfDetails1_3 > lamountOfDetails1_1 AND lamountOfDetails1_3 > lamountOfDetails1_2 THEN
        IF TPInfo tpwrite"IF 3";
        DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
      ELSE
      	IF TPInfo tpwrite"ELSE";
      	DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
      ENDIF
    ELSE
      IF TPInfo tpwrite"Angemessene Menge im Bild";
      !Flippen
      IF lamountOfDetails1_1=0 THEN
      	IF TPInfo tpwrite"IF 4";
      	DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
      ELSEIF lamountOfDetails1_1 < lamountOfDetails1_2 THEN
      	IF TPInfo tpwrite"IF 5";
      	DoAnyfeederAction ldo_AF_FlipFWD,Feeder1:=Feeder;
      ELSEIF lamountOfDetails1_1 > lamountOfDetails1_2 THEN
      	IF TPInfo tpwrite"IF 6";
      	DoAnyfeederAction ldo_AF_FlipBWD,Feeder1:=Feeder;
      ELSE
      	IF TPInfo tpwrite"IF 7";
      	DoAnyfeederAction ldo_AF_Flip,Feeder1:=Feeder;
      ENDIF
    ENDIF
    IF lamountOfDetails1_1<=0 AND lamountOfDetails1_2<=0 AND lamountOfDetails1_1<=0 THEN
      IF TPInfo TPWrite "No amount. Flip.";
      IF TPInfo tpwrite"IF 8";
      DoAnyfeederAction ldo_AF_Flip,Feeder1:=Feeder;
    ENDIF
	  Set ldi_Inposition;
  ENDPROC
  
  !====================================================================
  ! Zyclus für das manuelle Entladen Anyfeeder1
  !====================================================================
  PROC AFPurge1()
		IF TPInfo tpwrite"Entladen 1";
		PulseDO do_AF1_Purge;
  ENDPROC
  
ENDMODULE