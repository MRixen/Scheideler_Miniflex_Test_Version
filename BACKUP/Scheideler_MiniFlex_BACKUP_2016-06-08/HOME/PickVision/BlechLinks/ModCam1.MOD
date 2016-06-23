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
    PERS robtarget pRefPosInCam1:=[[-136.30,31.29,166.65],[0.0554008,-0.839525,-0.0572418,0.537449],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pRefPosOutCam1:=[[282.32,-370.67,338.87],[0.0551009,0.471319,0.878656,-0.0527787],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDrop:=[[134.13,97.89,69.92],[0.113645,0.404563,0.706281,0.569719],[0,-2,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pBeforeDrop:=[[624.74,-157.52,505.02],[0.0506627,0.131262,0.989956,0.0138061],[-1,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pFalseGripp:=[[310.38,-412.72,364.05],[0.336908,0.207634,0.896059,-0.201147],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pvpMachine:=[[47.71,-295.64,293.13],[0.158133,-0.0318904,0.986811,0.0134725],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pvpMachineOut:=[[146.62,-289.48,555.00],[0.0176877,0.994543,0.0576758,-0.0851185],[0,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropChangeOrient:=[[70.60,-38.49,281.79],[0.443901,0.671788,0.551819,-0.217135],[0,-1,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNutDeep1:=[[60.56,23.14,38.65],[0.0551416,0.997082,0.00369827,-0.0526606],[0,-1,3,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPickSim:=[[143.44,89.55,5.95],[0.0225651,0.931317,-0.0401836,-0.361281],[-2,0,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPickSimCollision:=[[332.22,-9.37,41.54],[0.759158,0.622212,-0.113536,0.153752],[-2,-1,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS jointtarget pCollisionPos:=[[-90.5,55,20,-87,120,250],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];


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
    VAR num maxUnloadCycleCntr:=0;
    CONST num MAX_UNLOAD_CYCLES:=5;
    VAR num cd_simCounter:=1;
    CONST num MAX_CD_SIM_COUNTER:=100;
    !
    !# -----------------------
    !#--------String data
    !# -----------------------
    !
    PERS string sVibTime:="-1";
    PERS robtarget pDropNut:=[[94.43,96.27,86.26],[0.00593286,-0.0394249,-0.9992,-0.00298078],[-1,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pDropNut1:=[[145.55,5.84,152.86],[0.396595,-0.109864,0.911229,0.0174227],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

    !------------------------------------------------------------------------------------------------
    ! Procedure:   ProgramLogic
    ! Description: This procedure is executed when state=idle and handles the whole logic
    !              Diese Prozedure wird ausgeführt wenn state=idle ist und beinhaltet die Programm Logik.
    !------------------------------------------------------------------------------------------------
    PROC ProgramLogic()
        gripFromAnyfeederFirst;
    ENDPROC

    PROC gripFromAnyfeederFirst()
        RefPosInCam_2;
        PickCam_2;
        TAKE_NEW_PLATE:
        RefPosInCam_1;
        IF (cd_simCounter<MAX_CD_SIM_COUNTER) THEN
            PickCam_1;
            cd_simCounter:=cd_simCounter+1;
        ELSE
            MoveAbsJ pCollisionPos, vmax, fine, tool0;
            !MoveJ pPickSimCollision,vmax,z5,tGripper\WObj:=wCamera1;
            cd_simCounter:=1;
        ENDIF
        Cam1Position_1;
        executeDiagnose(DiagnoseCommands.GET_CYCLETIME);       
        executeDiagnose(DiagnoseCommands.GET_ARTICLE);
    ENDPROC

    PROC gripFromMaxiflexFirst()
        RefPosInCam_1;
        WHILE bCoordReceived{1}=FALSE DO
            CheckSystem;
        ENDWHILE
        PickCamera1;
        IF diGripperPlateGripped=1 THEN
            TAKE_NEW_RING:
            RefPosInCam_2;
            WHILE bCoordReceived{2}=FALSE DO
                CheckSystem;
            ENDWHILE
            PickCamera2;
            IF diGripper=1 THEN
                Position_n;
            ELSE
                Gripper2 0;
                GOTO TAKE_NEW_RING;
            ENDIF
        ELSE
            Gripper 0;
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

    !-----------------------------------------------------------------------------
    ! Procedure:     InitializeCam_n
    ! Description:   This is an intermediate position used when entering the picking
    !                area. Update this position to suite the current application.						
    ! Argument:			 
    ! Remarks:       
    ! Called from:   LoadCameraModules in mainmodule
    !-----------------------------------------------------------------------------
    PROC InitializeCam1()
!        clkstart MaschineTimer;
!        nMaschineTimer:=0;
!        BELT_ACTION{1}:=RUN_NO_DETAIL;
!        ALLOW_AUTO_GRAB{1}:=TRUE;
!        nImageGrabDelay{1}:=0.05;
!        tGripper:=tGripperSpacer_Blech;
!        Ok:=StrToVal(SendFreeParameter1(CAMERA_NO_1),NVibTime);
!        !Initialisierung des Tischinterrupts
!        bTableLoaded:=FALSE;
        actualProgName:="BlechLinks";
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
        VAR bool bMaxTime_PartInMachine;
        VAR bool bMaxTime_PartInMachine2;
        CONST string my_message{5}:=["Es scheint noch ein","Teil in der Ablage zu sein"," ","Einfach ","weiter Takten?"];
        CONST string my_buttons{2}:=["Ja","Nein"];
        CONST string my_message_unload{2}:=["Achtung!","Kontrolliere Sensoren Teile Abfrage"];
        CONST string my_buttons_unload{1}:=["OK"];
        ConfJ\On;
        ConfL\On;
        MoveJ pvpMachine,vmax,z200,tGripperSpacer_Blech\WObj:=wMachine;
        !Wait for Maschine Entrance
        !        WHILE (DOutput(doStartMachine)=1) DO
        !            WaitTime 0.1;
        !        ENDWHILE

        ! Check signals for load control
        !        WaitUntil diPartinMachine2=0\MaxTime:=1\TimeFlag:=bMaxTime_PartInMachine;
        !        WaitUntil diPartinMachine=0\MaxTime:=1\TimeFlag:=bMaxTime_PartInMachine2;
        IF bMaxTime_PartInMachine OR bMaxTime_PartInMachine2 THEN
            Falseparte;
            Falseparte2;
            GOTO UNLOAD_MACHINE;
        ENDIF

        !        WHILE ((diMachineRdy=0) OR diPartinMachine=1 OR diPartinMachine2=1 OR bTableLoaded) DO
        !            WaitTime 0.1;
        !            IF ((diPartinMachine=1 AND diPartinMachine2=1) AND (diMachineRdy=1)) THEN
        !                answer:=UIMessageBox(
        !				\Header:="UIMessageBox Header"
        !				\MsgArray:=my_message
        !				\BtnArray:=my_buttons
        !				\Icon:=iconInfo);
        !                IF answer=1 THEN
        !                    ! Bediener sagt weiter Tagten.
        !                    CycleTime;
        !                    bTableLoaded:=TRUE;
        !                    WaitUntil bTableLoaded=FALSE;
        !                ENDIF
        !            ENDIF
        !        ENDWHILE
        !waituntil ((diMachineRdy=1) and ((diPartinMachine=0)));

        !Load machine with plate
        loadPlate;
        !Load machine with nut
        loadNut;
        ! Check if nut and plate is present
        !        WaitUntil diPartinMachine2=1\MaxTime:=1\TimeFlag:=bMaxTime_PartInMachine;
        !        WaitUntil diPartinMachine=1\MaxTime:=1\TimeFlag:=bMaxTime_PartInMachine2;
        UNLOAD_MACHINE:
        IF ((NOT bMaxTime_PartInMachine) AND (NOT bMaxTime_PartInMachine2)) THEN
            !Teil ist eingelegt Fertig
            CycleTime;
            !MoveJ Offs(pDrop,0,0,220), vmax, z150, tGripper\WObj:=wMachine;
            MoveJSync pvpMachineOut,vmax,z200,tGripper\WObj:=wMachine,"StartMaschine";
            !MoveJ pvpMachineOut,vmax,z200,tGripper\WObj:=wMachine;

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
            maxUnloadCycleCntr:=0;
        ELSE
            !Teil wurde nicht/nicht richtig eingelgt mitnehmen und neues holen 
            ! Mutter entnehmen
            WaitTime 0.01;
            Gripper2 0;
            tGripper:=tGripperMutter;
            MoveJ RelTool(pDropNut,0,0,-30),vmax,z10,tGripper\WObj:=wMachine;
            MoveL pDropNut,vmax,fine,tGripper\WObj:=wMachine;
            WaitTime 0.01;
            Gripper2 1;
            MoveJ RelTool(pDropNut,0,0,-100),vmax,z10,tGripper\WObj:=wMachine;

            ! Blech entnehmen
            tGripper:=tGripperSpacer_Blech;
            WaitTime 0.01;
            Gripper 0;
            !MoveJ pDropChangeOrient,vmax,z40,tGripper\WObj:=wMachine;
            MoveL Offs(pDrop,0,0,30),vmax,z5,tGripper\WObj:=wMachine;
            MoveL Offs(pDrop,0,0,10),vmax,z5,tGripper\WObj:=wMachine;
            MoveL pDrop,v100,fine,tGripper\WObj:=wMachine;
            Gripper 1;
            MoveL Offs(pDrop,0,0,40),vmax,fine,tGripper\WObj:=wMachine;

            MoveJ pvpMachine,vmax,z100,tGripper\WObj:=wMachine;
            Falseparte;
            Falseparte2;

            ! Increment counter for max unload cycles
            maxUnloadCycleCntr:=maxUnloadCycleCntr+1;
            IF (maxUnloadCycleCntr>=MAX_UNLOAD_CYCLES) THEN
                answer:=UIMessageBox(
													\Header:="UIMessageBox Header"
													\MsgArray:=my_message_unload
													\BtnArray:=my_buttons_unload
													\Icon:=iconInfo);
                maxUnloadCycleCntr:=0;
            ENDIF
        ENDIF
    ENDPROC

    PROC loadNut()
        tGripper:=tGripperMutter;
        MoveJ pDropNut1,vmax,z50,tGripper\WObj:=wMachine;
        !MoveJ pDropNut2, vmax, z50, tGripper\WObj:=wMachine;
        MoveJ RelTool(pDropNut,0,0,-30),vmax,z10,tGripper\WObj:=wMachine;
        MoveL pDropNut,vmax,fine,tGripper\WObj:=wMachine;
        Gripper2 0;
        MoveL RelTool(pDropNut,0,0,-30),vmax,z10,tGripper\WObj:=wMachine;
        !MoveL pDropChangeOrient,vmax,z80,tGripper\WObj:=wMachine;
    ENDPROC

    PROC loadPlate()
        tGripper:=tGripperSpacer_Blech;
        MoveJ Offs(pDrop,0,0,100),vmax,z40,tGripper\WObj:=wMachine;
        MoveL Offs(pDrop,0,0,30),vmax,z5,tGripper\WObj:=wMachine;
        MoveL Offs(pDrop,0,0,10),vmax,z5,tGripper\WObj:=wMachine;
        MoveL pDrop,v100,fine,tGripper\WObj:=wMachine;
        Gripper 0;
        MoveL Offs(pDrop,0,0,40),vmax,fine,tGripper\WObj:=wMachine;
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
        tGripper:=tGripperSpacer_Blech;
        ConfJ\Off;
        ConfL\Off;
        MoveJ Offs(pPickSim,0,0,50),vmax,z5,tGripper\WObj:=wCamera1;
        MoveL pPickSim,v1000,fine,tGripper\WObj:=wCamera1;
        Gripper 1;
        GripLoad lDetailCam1;
        MoveL Offs(pPickSim,0,0,50),vmax,z40,tGripper\WObj:=wCamera1;
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
        MoveL Offs(pFalseGripp,0,0,100),vmax,z40,tGripper\WObj:=wobj0;
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
            MoveJ pRefPosInCam1,v500,z200,tGripper\WObj:=wCamera1;
        ELSE
            MoveJ pRefPosInCam1,vmax,z200,tGripper\WObj:=wCamera1;
        ENDIF
        IF diGripperPlateGripped=1 THEN
            Falseparte;
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
