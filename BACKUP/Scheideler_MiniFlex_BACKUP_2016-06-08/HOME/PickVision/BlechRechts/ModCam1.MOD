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
	!
	! ----------------------!!!!!!!! IMPORTANT !!!!!!!
	!
	! Programm zum Abgreifen des Rechtssteils (Blech)
	
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
    PERS robtarget pRefPosInCam1:=[[223.20,-259.62,576.87],[0.0793376,-0.0616998,0.970923,-0.217273],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pRefPosOutCam1:=[[170.92,-355.84,471.66],[0.0256784,0.13359,-0.987574,-0.0786928],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pGetPlate:=[[33.54,36.96,45.94],[0.0137845,0.377947,-0.925691,-0.00784311],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pGetPlate1:=[[4.94,26.77,147.57],[0.015712,0.0077416,-0.999844,-0.00217044],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pGetPlate2:=[[5.36,23.50,44.57],[0.0157141,0.00774065,-0.999844,-0.00217095],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pGetPlate3:=[[16.55,23.67,44.22],[0.0157119,0.00774106,-0.999844,-0.00217017],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pGetPlate4:=[[32.09,36.38,53.93],[0.00395586,-0.377122,0.925557,0.0332709],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pGetPlate5:=[[31.59,67.25,105.93],[0.00395513,-0.377117,0.925559,0.0332713],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropPlate2:=[[73.82,51.49,73.02],[0.168528,-0.24,-0.800371,-0.522881],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropPlate1:=[[80.94,86.71,162.90],[0.117711,-0.297058,-0.883375,-0.342854],[0,-1,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropPlate3:=[[76.31,23.48,59.06],[0.189975,-0.254559,-0.743294,-0.588747],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropPlate4:=[[76.35,26.95,63.36],[0.204163,-0.24132,-0.743118,-0.589795],[0,-2,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropPlate5:=[[76.94,15.79,57.36],[0.21778,-0.228267,-0.706297,-0.633728],[0,-2,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        PERS robtarget pDropPlate6:=[[74.39,5.92,56.96],[0.207837,-0.206623,-0.665401,-0.686551],[0,-2,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
            PERS robtarget pDropPlate7:=[[76.52,4.96,51.43],[0.233644,-0.207626,-0.671305,-0.67205],[0,-2,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropPlate:=[[74.79,5.80,53.77],[0.200644,-0.212691,-0.683588,-0.668739],[0,-2,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNutDeep1:=[[59.81,22.96,53.02],[0.000730872,0.533081,0.846028,0.00779802],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut1:=[[203.82,-395.01,418.68],[0.572143,0.334425,0.550765,-0.507415],[-1,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut2:=[[178.61,-132.45,257.68],[0.334602,0.398627,0.783428,-0.339674],[-1,0,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut3:=[[46.28,27.71,64.80],[0.162486,-0.231184,0.755698,0.590824],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut4:=[[43.93,5.16,59.53],[0.220143,-0.190926,0.655803,0.696424],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut5:=[[43.97,4.90,59.07],[0.206568,-0.20431,0.657178,0.695488],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut:=[[60.51,22.02,65.42],[0.00645603,0.539111,0.842141,0.0107554],[0,1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
PERS robtarget pDropChangeOrient:=[[95.63,24.10,156.57],[0.402143,0.0599832,0.885688,-0.224142],[0,0,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
PERS robtarget pBeforeDrop:=[[624.74,-157.52,505.02],[0.0506627,0.131262,0.989956,0.0138061],[-1,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPreFalseGripp:=[[185.75,-345.93,485.93],[0.0207185,-0.216681,0.975445,0.0335615],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pFalseGripp:=[[317.21,-411.58,364.32],[0.0207147,-0.216682,0.975445,0.0335616],[-1,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pvpMachine:=[[240.50,-338.58,469.35],[0.10341,-0.150051,-0.900405,-0.395047],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];


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
    PERS Num nVibTime:=-1;
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
        RefPosInCam_2;
        WHILE bCoordReceived{2}=FALSE DO
            CheckSystem;
        ENDWHILE
        PickCamera2;
        IF diGripper=1 THEN
	        RefPosInCam_1;
	        WHILE bCoordReceived{1}=FALSE DO
	            CheckSystem;
	        ENDWHILE
	        PickCamera1;
	        Position_n;
      	ELSE
      		Gripper2 0;
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
        TPWrite "Cycle Time"+ValToStr(nCycleTime)+"'s";
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
	
	    PROC Cam1Position_5()
        ConfJ\On;
        ConfL\On;
        LoadMachine;
    ENDPROC
	
	    PROC Cam1Position_6()
        ConfJ\On;
        ConfL\On;
        LoadMachine;
    ENDPROC
	
	    PROC Cam1Position_7()
        ConfJ\On;
        ConfL\On;
        LoadMachine;
    ENDPROC
	
	    PROC Cam1Position_8()
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
        tGripper:=tGripperBlech;
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
        VAR bool bMaxTime;
        CONST string my_message{5}:=["Es scheint noch ein","Teil in der Ablage zu sein"," ","Einfach ","weiter Takten?"];
        CONST string my_buttons{2}:=["Ja","Nein"];
        ConfJ\On;
        ConfL\On;
        MoveJ pvpMachine,vmax,z100,tGripperBlech\WObj:=wMachine;
        !Wait for Maschine Entrance
        WHILE (DOutput(doStartMachine)=1) DO
            WaitTime 0.1;
        ENDWHILE
        WHILE ((diMachineRdy=0) OR (diPartinMachine2=1) OR bTableLoaded) DO
            WaitTime 0.1;
            IF ((diPartinMachine2=1) AND (diMachineRdy=1)) THEN
                answer:=UIMessageBox(
				\Header:="UIMessageBox Header"
				\MsgArray:=my_message
				\BtnArray:=my_buttons
				\Icon:=iconInfo);
                IF answer=1 THEN
                    ! Bediener sagt weiter Tagten.
                    CycleTime;
                    bTableLoaded:=TRUE;
                    WaitUntil bTableLoaded=FALSE;
                ENDIF
            ENDIF
        ENDWHILE
        !waituntil ((diMachineRdy=1) and ((diPartinMachine2=0)));

        ! Load machine with nut
        loadNut;
        ! Load machine with plate
        loadPlate;
        WaitUntil diPartinMachine2=1\MaxTime:=1\TimeFlag:=bMaxTime;
        IF NOT bMaxTime THEN
            !Teil ist eingelegt Fertig
            CycleTime;
            !MoveL RelTool(pDropPlate,0,0,-30), vmax, z10, tGripper\WObj:=wMachine;
            MoveJSync pvpMachine,vmax,z20,tGripper\WObj:=wMachine,"StartMaschine";
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
            ! Blech entnehmen			
            MoveJ pGetPlate1,vmax,z0,tGripper\WObj:=wMachine;
            MoveL pGetPlate2,vmax,z10,tGripper\WObj:=wMachine;
            MoveL pGetPlate3,vmax,z10,tGripper\WObj:=wMachine;
            MoveL pGetPlate2,vmax,z10,tGripper\WObj:=wMachine;
            
            MoveJ Offs(pGetPlate,0,0,50),vmax,z10,tGripper\WObj:=wMachine;
            MoveL pGetPlate,vmax,fine,tGripper\WObj:=wMachine;
            Gripper 1;
            WaitTime 0.01;
            MoveL pGetPlate4,vmax,z0,tGripper\WObj:=wMachine;
            MoveL pGetPlate5,vmax,z0,tGripper\WObj:=wMachine;
            ! Mutter entnehmen
            tGripper:=tGripperMutter;
            MoveL pDropChangeOrient, vmax, z80, tGripper\WObj:=wMachine;
             MoveL RelTool(pDropNut,0,0,-30), vmax, z10, tGripper\WObj:=wMachine;
             MoveL pDropNutDeep1, vmax, fine, tGripper\WObj:=wMachine;
             Gripper2 1;
             MoveJ RelTool(pDropNut,0,0,-10), vmax, z10, tGripper\WObj:=wMachine;
             tGripper:=tGripperBlech;
             MoveJ pvpMachine, vmax, z100, tGripper\WObj:=wMachine;         
            Falseparte;
            Falseparte2;
        ENDIF
    ENDPROC
    
    PROC loadNut()
        tGripper:=tGripperMutter;
        MoveJ pDropNut1, vmax, z50, tGripper\WObj:=wMachine;
        MoveJ RelTool(pDropNut,0,0,-10), vmax, z10, tGripper\WObj:=wMachine;
        MoveL pDropNut, vmax, fine, tGripper\WObj:=wMachine;
        Gripper2 0;
        MoveL RelTool(pDropNut,0,0,-30), vmax, z10, tGripper\WObj:=wMachine;
        MoveL pDropChangeOrient, vmax, z150, tGripper\WObj:=wMachine;
    ENDPROC    
    
    PROC loadPlate()
        tGripper:=tGripperBlech;
        MoveJ pDropPlate1,vmax,z10,tGripper\WObj:=wMachine;
        MoveL pDropPlate2, vmax, z0, tGripper\WObj:=wMachine;
        !MoveL pDropPlate3, vmax, z0, tGripper\WObj:=wMachine;
        MoveL pDropPlate4, vmax, z0, tGripper\WObj:=wMachine;
        MoveL pDropPlate5, vmax, z0, tGripper\WObj:=wMachine;
        MoveL pDropPlate6, vmax, z0, tGripper\WObj:=wMachine;
        MoveL pDropPlate, vmax, fine, tGripper\WObj:=wMachine;
        Gripper 0;
        WaitTime 0.01;
        MoveL RelTool(pDropPlate,0,0,-30), vmax, z10, tGripper\WObj:=wMachine;
        MoveL RelTool(pDropPlate,100,100,0), vmax, z10, tGripper\WObj:=wMachine;
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
        MoveL RelTool(pPick,0,0,-nPZ),vmax,z5,tGripper\WObj:=wCamera1;
        MoveL pPick,v1000,fine,tGripper\WObj:=wCamera1;
        Gripper 1;
        GripLoad lDetailCam1;
        MoveL Offs(pPick,0,0,nPZ),vmax,z40,tGripper\WObj:=wCamera1;
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
        MoveL pPreFalseGripp,vmax,fine,tGripper\WObj:=wobj0;
        MoveL pFalseGripp,vmax,fine,tGripper\WObj:=wobj0;

        Gripper 0;
        MoveL Offs(pFalseGripp,0,0,100),v2000,z40,tGripper\WObj:=wobj0;
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
            MoveJ pRefPosInCam1,v500,z200,tGripper\WObj:=wobj0;
        ELSE
            MoveJ pRefPosInCam1,vmax,z200,tGripper\WObj:=wobj0;
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
        MoveJSync pRefPosOutCam1,vmax,z200,tGripper\WObj:=wobj0,"ConfirmPick1";
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
