MODULE ModCam1
  !***************************************************
  !Programtype:  Foreground
  !Description:  ModCam1
  !              Project M11xxx
  !              This Module handles the initalizing, 
  !              picking and stopping of camera 1
  !
  !Programmer:   Xxxx Xxxxxxx
  !              Svensk Industriautomation AB.
  !              Phone +46 36 2100xxx
  !
  ! Copyright (c) Svensk Industriautomation AB 2011
  ! All rights reserved
  !
  !---------------------------------------------------
  !Version           Date            Description
  !---------------------------------------------------
  !4.0              20111124         Created
  !
  !***************************************************

  !
  !# -----------------------
  !# ------ Loaddata
  !# -----------------------
  !
  PERS loaddata lDetailCam1:=[0.001,[0,0,0.001],[1,0,0,0],0,0,0];
  
  !# -----------------------
  !# ------ Robtargetdata
  !# -----------------------
  !
  PERS robtarget pRefPosInCam1:=[[282.32,-370.67,338.87],[0.0551018,0.47132,0.878656,-0.0527792],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pRefPosOutCam1:=[[282.32,-370.67,338.87],[0.0551009,0.471319,0.878656,-0.0527787],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pDrop:=[[71.45,40.47,26.91],[0.00419481,0.237089,0.971282,0.0195693],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pBeforeDrop:=[[624.74,-157.52,505.02],[0.0506627,0.131262,0.989956,0.0138061],[-1,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pFalseGripp:=[[336.51,-390.84,232.42],[0.0550925,0.413471,0.908396,-0.0286807],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pvpMachine:=[[173.17,-355.73,430.58],[0.0608158,-0.254847,0.964993,0.0119669],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];


  !# -----------------------
  !#--------Bool data
  !# -----------------------
  
  Var bool Ok;
  VAr Clock MaschineTimer; 
	Var Num nMaschineTimer;
	VAR Clock CycleTimer; 
	VAR Num nCycleTime;
  VAR iodev ioFileLog;
  VAR intnum TableTurn;

  !
  !# -----------------------
  !#--------Num data
  !# -----------------------
  !
  PERS Num nVibTime:=1.41;
  !
  !# -----------------------
  !#--------String data
  !# -----------------------
  !
  PERS string sVibTime:="-1";
  
  !------------------------------------------------------------------------------------------------
  ! Procedure:   ProgramLogic
  ! Description: This procedure is executed when state=idle and handles the whole logic
  !              Diese Prozedure wird ausgeführt wenn state=idle ist und beinhaltet die Programm Logik.
  !------------------------------------------------------------------------------------------------
  PROC ProgramLogic()
      RefPosInCam_1;
      WHILE bCoordReceived{1}=FALSE DO
        CheckSystem;
      ENDWHILE
      PickCamera1;
      !Checksensor
      If diGripper = 0 Then
       Falseparte;
       Else
    	 Position_n;
      ENDIF
  ENDPROC
  
  !-----------------------------------------------------------------------------
  ! Procedure:     Cam1Position_n
  ! Description:   These are the procedures called when handling picked parts
  !                from camera 1.
  !                When a position taught in as position 1 at camera 1 in 
  !                PickVision is found the procedure Cam2Position_1 is called, 
  !                when one in position 2 at camera 1 is found the procedure 
  !                Cam1Position_2 is called, etc.
  !                Add code for handling different positions here.
  !                Add a procedure Cam2Position_n for each position that is teached
  !                in PickVision where n is the position number given by
  !                PickVision. Make sure that ConfL\On and ConfJ\On is called
  !                in the beginning of each procedure to avoid unwanted robot
  !                movements
  ! Argument:
  ! Remarks:
  ! Called from:   Position
  !-----------------------------------------------------------------------------
  PROC Cam1Position_1()
    ConfJ\On;
    ConfL\On;

    LoadMachine;
  ENDPROC

  PROC CycleTime()
  	
  	clkstop CycleTimer;
  	nCycleTime:=ClkRead(CycleTimer);
  	TPWrite "Cycle Time"+ValToStr(nCycleTime)+ "'s";
  	WriteCycleTimeLog(nCycleTime);
  	clkreset CycleTimer;
    clkstart CycleTimer;
  	
  ENDPROC

  LOCAL PROC WriteCycleTimeLog(num nCycleTime)
    Open "home:/CycleTimes.txt",ioFileLog\Append;
    Write ioFileLog,CDate()+" "+CTime()+" Taktzeit: "+ValToStr(nCycleTime);
    Close ioFileLog;
  ENDPROC

  PROC Cam1Position_2()
    ConfJ\On;  
    ConfL\On;
    LoadMachine;
  ENDPROC

  PROC Cam1Position_3()
    ConfJ\On;
    ConfL\On;
    LoadMachine;

  ENDPROC

  PROC Cam1Position_4()
    ConfJ\On;
    ConfL\On;
    LoadMachine;
  ENDPROC
  
  !-----------------------------------------------------------------------------
  ! Procedure:     InitializeCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:			 
  ! Remarks:       
  ! Called from:   LoadCameraModules in mainmodule
  !-----------------------------------------------------------------------------
  PROC InitializeCam1()
  	clkstart MaschineTimer;
  	nMaschineTimer:=0;
     BELT_ACTION{1}:=RUN_NO_DETAIL;
     ALLOW_AUTO_GRAB{1}:=TRUE;
     nImageGrabDelay{1}:=0.05;
     tGripper:=tGripper1;
     Ok:=StrToVal(SendFreeParameter1(CAMERA_NO_1),NVibTime);
     !Initialisierung des Tischinterrupts
     bTableLoaded:=FALSE;
     !CONNECT TableTurn WITH TableTurned;
     !ISignalDI diMachineRdy, low, TableTurn;
     !ISleep TableTurn;
  ENDPROC
  
  !-----------------------------------------------------------------------------
  ! Procedure:     LoadMachine
  ! Description:   
  ! Argument:
  ! Remarks:
  ! Called from:   Position
  !-----------------------------------------------------------------------------
  PROC LoadMachine()
  	VAR btnres answer;
		CONST string my_message{5}:= ["Es scheint noch ein","Teil in der Ablage zu sein"," ","Einfach ","weiter Takten?"];
		CONST string my_buttons{2}:=["Ja","Nein"];

    MoveJ pvpMachine, vmax, z100, tGripper1\WObj:=wMachine;
    !Wait for Maschine Entrance
    WHILE (DOutput(doStartMachine)=1) DO 
    	WaitTime 0.1;
    ENDWHILE
    WHILE ((diMachineRdy=0) OR (diPartinMachine=1) OR bTableLoaded) DO
    	WaitTime 0.1;
    	IF ((diPartinMachine=1) AND (diMachineRdy=1)) THEN
    		answer:= UIMessageBox (
				\Header:="UIMessageBox Header"
				\MsgArray:=my_message
				\BtnArray:=my_buttons
				\Icon:=iconInfo);
				IF answer = 1 THEN
					! Bediener sagt weiter Tagten.
					CycleTime;
			    bTableLoaded:=TRUE;
			    WaitUntil bTableLoaded = FALSE;
				ENDIF
			ENDIF
    ENDWHILE
    !waituntil ((diMachineRdy=1) and ((diPartinMachine=0)));
  
    MoveJ Offs(pDrop,0,0,300), vmax, z40, tGripper1\WObj:=wMachine;
    MoveL Offs(pDrop,0,0,30), vmax, z5, tGripper1\WObj:=wMachine;
    MoveL pDrop, v100, fine, tGripper1\WObj:=wMachine;
    Gripper 0;
    MoveL Offs(pDrop,0,0,40), vmax, fine, tGripper1\WObj:=wMachine;
 		IF diPartinMachine=1 THEN
 			!Teil ist eingelegt Fertig
 			CycleTime;
	    

	 		MoveJ Offs(pDrop,0,0,220), vmax, z150, tGripper1\WObj:=wMachine;
	 		MoveJSync pvpMachine, vmax, z20, tGripper1\WObj:=wMachine, "StartMaschine";
	    !MoveJ pvpMachine, vmax, z100, tGripper1\WObj:=wMachine;
  		
!  		!Set dosignal10 = Start machine
!	    SetDo doStartMachine,1;
!	    !wait disignal9 = Machine ready = 0
!	    waitDi diMachineRdy,0;
!	    bTableLoaded:=FALSE;
!	    !reset dosignal10 = start machine
!	    SetDo doStartMachine,0;
	    
	    !Set dosignal10 = Start machine
	    !Änderung mit Interupt zur Taktzeitoptimierung

	    !wait disignal9 = Machine ready = 0
	    !waitDi diMachineRdy,0;
	    !reset dosignal10 = start machine
	    !SetDo doStartMachine,0;
    ELSE
    	!Teil wurde nicht/nicht richtig eingelgt mitnehmen und neues holen 			
 			MoveL pDrop, v2000, fine, tGripper1\WObj:=wMachine;
    	Gripper 1;
    	MoveL Offs(pDrop,0,0,40), vmax, Z10, tGripper1\WObj:=wMachine;
 			MoveJ Offs(pDrop,0,0,220), vmax, z100, tGripper1\WObj:=wMachine;
	    MoveJ pvpMachine, vmax, z100, tGripper1\WObj:=wMachine;
      Falseparte;
    ENDIF
  ENDPROC 

  !-----------------------------------------------------------------------------
  ! Procedure:     PickCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:
  ! Remarks:       
  ! Called from:   PickCamera
  !-----------------------------------------------------------------------------
  PROC PickCam_1()
    ConfJ\Off;
    ConfL\Off;
    MoveJ RelTool(pPick,0,0,-nPZ), vmax, z5, tGripper1\WObj:=wCamera1;
    MoveL pPick, v1000, fine, tGripper1\WObj:=wCamera1;
		Gripper 1;
		If diGripper = 0 Then
			Gripper 0;
			Gripper 1;
    ENDIF
    GripLoad lDetailCam1;
    MoveL Offs(pPick,0,0,nPZ), vmax, z40, tGripper1\WObj:=wCamera1;
  ENDPROC
  
  Proc CheckTablePart()
  	If diPartinMachine=0 then
    	tpwrite "!!!ACHTUNG!!!";
    	tpwrite "Teil wurde nicht eingelegt!";
    	tpwrite "Roboterprog Neu starten!";
    	stop;
    ENDIF
  Endproc
  
  Proc Falseparte()
  	MoveL Offs(pFalseGripp,0,0,100), vmax, z40, tGripper1\WObj:=wobj0;
  	MoveL pFalseGripp, vmax, fine, tGripper1\WObj:=wobj0;
  	Gripper 0;
  	MoveL Offs(pFalseGripp,0,0,100), v2000, z40, tGripper1\WObj:=wobj0;
  Endproc


  !-----------------------------------------------------------------------------
  ! Procedure:     RefPosInCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:
  ! Remarks:       
  ! Called from:   Main
  !-----------------------------------------------------------------------------
  PROC RefPosInCam_1()
    ConfJ\On;
    ConfL\On;
    IF bFirstRefPos=TRUE THEN
      bFirstRefPos:=FALSE;
      MoveJ pRefPosInCam1, v500, z200, tGripper1\WObj:=wobj0;
    ELSE
      MoveJ pRefPosInCam1, vmax, z200, tGripper1\WObj:=wobj0;
    ENDIF
  ENDPROC
  
  !-----------------------------------------------------------------------------
  ! Procedure:     RefPosOut_n
  ! Description:   This is an intermediate position used when leaving the picking
  !                area. Update this position to suite the current application.
  ! Argument: 
  ! Remarks:       
  ! Called from:   Main
  !-----------------------------------------------------------------------------
  PROC RefPosOutCam_1()
    ConfJ\On;
    ConfL\On;
    MoveJSync pRefPosOutCam1, vmax, z200, tGripper1\WObj:=wobj0, "ConfirmPick1";
  ENDPROC

  !------------------------------------------------------------------------------------------------
  ! Procedure:   StopRoutine
  ! Description: This procedure is executed when PickVision is stopped
  !              Diese Prozedure wird ausgeführt wenn PickVision gestoppt wird
  !------------------------------------------------------------------------------------------------
  PROC StopRoutineCam_1()
  	SetDo doStartMachine,0;
  ENDPROC
  
  
  PROC StartMaschine()
  	bTableLoaded:=TRUE;
	ENDPROC


ENDMODULE
