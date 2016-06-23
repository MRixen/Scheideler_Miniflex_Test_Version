MODULE MainModule
    !***************************************************
    !Programtype:  Foreground
    !Description:  Main Program
    !              Project M14xxx
    !              This Module handles the main loop
    !              This program is common to all parts
    !
    !Programmer:   Xxxx Xxxxxxx
    !              Svensk Industriautomation AB.
    !              Service Phone +46 36 2100020
    !
    ! Copyright (c) Svensk Industriautomation AB 2014
    ! All rights reserved
    !
    !---------------------------------------------------
    !Version           Date            Description
    !---------------------------------------------------
    !4.0              20111124         Created
    !4.1              20121204         LoadCameraModules and StopRoutine, updated to use ModExist function
    !                                  Copyright date 2012 /roha
    !4.2              20131112         LoadCameraModules and StopRoutine updated /olma
    !4.3              20140107         Added nTempInPosArray to record if Inposition sensor was activated in entry request procedure, Tidy up, Copyright date 2014 /roha
    !
    !***************************************************

    !
    !# -----------------------
    !#------- Bool data
    !# -----------------------
    !
    PERS bool bFirstRefPos:=FALSE;
    PERS bool bModuleCamLoaded{4};
    !
    !# -----------------------
    !# ------ Loaddata
    !# -----------------------
    !

    !
    !# -----------------------
    !#------- Num data
    !# -----------------------
    !
    LOCAL PERS num nCamera:=1;
    PERS num nRunMode:=1;
    !
    !# -----------------------
    !# ------ Robtargetdata
    !# -----------------------
    !

    Var bool bMaschine:=True;
    !# -----------------------
    !#------- String data
    !# -----------------------
    !
    PERS string sModuleCam{4};
    VAR string sState:="Idle";

    !-----------------------------------------------------------------------------
    ! Procedure:   main
    ! Description: This procedure handles the main pick loop.
    !              DO NOT ADD ANY CODE HERE.
    !              Add all code for initialization in procedure Initialize,
    !              otherwise the system might not behave correctly.
    !-----------------------------------------------------------------------------
    PROC Main()
        initDiagnose;
        !    InitializeMain;
        !    InitPickVision;
        !    IF DOutput(do_Grip1Open)=0 THEN
        !    	Falseparte;
        !    ENDIF
        InitializeCam1; ! Normaly this proc starts from InitPickVision 
        WHILE TRUE DO
            !CheckSystem;
            ProgramLogic;
            executeDiagnose(DiagnoseCommands.MACHINE_DATA);
        ENDWHILE
    ENDPROC


    PROC initDiagnose()
        robSpeed:=ValToStr(MaxRobSpeed());
        loggingMsg:="Program start executed";
        executeDiagnose(DiagnoseCommands.LOG);
        executeDiagnose(DiagnoseCommands.MACHINE_DATA);
        executeDiagnose(DiagnoseCommands.GET_ARTICLE);
    ENDPROC


    PROC executeDiagnose(String command)
        TEST command
        CASE DiagnoseCommands.LOG:
            PulseDO\PLength:=0.5,DOF_LogPulser;
        CASE DiagnoseCommands.MACHINE_DATA:
            PulseDO\PLength:=0.5,DOF_MDpulser;
        CASE DiagnoseCommands.GET_CYCLETIME:
            PulseDO\PLength:=0.5,DOF_CTpulser;
        CASE DiagnoseCommands.RESET_CYCLTIME:
            PulseDO\PLength:=0.5,DOF_resetCTpulser;
        CASE DiagnoseCommands.GET_ARTICLE:
            PulseDO\PLength:=0.5,DOF_ADpulser;
        DEFAULT:
        ENDTEST
    ENDPROC


    !-----------------------------------------------------------------------------
    ! Procedure:     CheckSystem
    ! Description:   This procedure checks If endcycle or Entry has been requested
    ! Argument:
    ! Remarks:
    ! Called from:   Main
    !-----------------------------------------------------------------------------



    PROC CheckSystem()
        VAR bool bTempArray{4};
        VAR num nTempInPosArray{4};
        VAR num nChosenNumber;

        IF DOutput(DOF_P1)=1 AND nRunMode<>1 THEN
            ClearDices;
            nRunMode:=1;
            EnablePosition 1,1000;
            IF bCoordReceived{1}=TRUE DiscardAndTakeNewImage 1;
        ELSEIF DOutput(DOF_P2)=1 AND nRunMode<>2 THEN
            ClearDices;
            nRunMode:=2;
            EnablePosition 1,1000;
            IF bCoordReceived{1}=TRUE DiscardAndTakeNewImage 1;
        ELSEIF DOutput(DOF_P3)=1 AND nRunMode<>3 THEN
            ClearDices;
            nRunMode:=3;
            DisablePosition 1,1000;
            pDice:=pDice6;
            EnablePosition 1,6;
            IF bCoordReceived{1}=TRUE DiscardAndTakeNewImage 1;
        ELSEIF DOutput(DOF_P4)=1 AND nRunMode<>4 THEN
            ClearDices;
            nRunMode:=4;
            DisablePosition 1,1000;
            pDice:=pDice6;
            nChosenNumber:=UINumEntry(\Header:="Välj tärning."\Icon:=iconInfo\MinValue:=1\MaxValue:=6\AsInteger);
            EnablePosition 1,nChosenNumber;
            IF bCoordReceived{1}=TRUE DiscardAndTakeNewImage 1;
        ENDIF
        Reset DOF_P1;
        Reset DOF_P2;
        Reset DOF_P3;
        Reset DOF_P4;

        IF DOutput(DOF_EndCycle)=1 THEN
            ! ordered stop from PickVision
            bFirstRefPos:=TRUE;
            StopRoutine;
            bFirstRefPos:=TRUE;
            WaitRob\InPos;
            Set DOF_CycleEnded;
            WaitTime 3;
            Stop;
            EXIT;
        ELSEIF DOutput(DOF_EntryRequest)=1 AND DOutput(DOF_AutoOn)=1 THEN
            ! Handle request for entry
            Stop;
            ! reset old bCoordReceived status, but remenber which coordinates we already had ...
            ! if someone had entered the cell, we cannot guarantee that details are at same position
            nTempInPosArray{1}:=DOutput(DOF_InPosition1);
            nTempInPosArray{2}:=DOutput(DOF_InPosition2);
            nTempInPosArray{3}:=DOutput(DOF_InPosition3);
            nTempInPosArray{4}:=DOutput(DOF_InPosition4);
            FOR i FROM START_ACCEPT_CAM TO STOP_ACCEPT_CAM DO
                bTempArray{i}:=bCoordReceived{i};
                bCoordReceived{i}:=FALSE;
            ENDFOR
            SendClearSend;
            WaitTime 3;
            ! discard old coordinates and take new images in case we already had received coordinates
            FOR i FROM START_ACCEPT_CAM TO STOP_ACCEPT_CAM DO
                IF (bTempArray{i}=TRUE OR (sModuleCam{i}<>stEmpty AND nTempInPosArray{i}=1)) THEN
                    DiscardAndTakeNewImage i;
                    Cont1:
                    bTempArray{i}:=FALSE;
                ELSEIF sModuleCam{i}<>stEmpty AND nTempInPosArray{i}=0 THEN
                    DiscardAndStartBelt i;
                    Cont2:
                    bTempArray{i}:=FALSE;
                ENDIF
            ENDFOR
        ELSE
            WaitTime 0.1;
            !Roboten väntar på detaljer
        ENDIF
        RETURN ;
    ENDPROC

    !-----------------------------------------------------------------------------
    ! Procedure:     InitializeMain
    ! Description:   This procedure holds all initialization made when starting the
    !                robot program for the beginning. Add all initialization for the
    !                current application here.
    ! Argument:
    ! Remarks:       Set AllowManualModeFeederX Default 1 in EIO.cfg
    ! Called from:   Main
    !-----------------------------------------------------------------------------
    PROC InitializeMain()
        bFirstRefPos:=TRUE;
        nRunMode:=1;
        !wurde eingefügt
        SafeRobotStart;
        !
        vmax:=v7000;
        reset doStartMachine;
        Reset DOF_P1;
        Reset DOF_P2;
        Reset DOF_P3;
        Reset DOF_P4;
        !Assign pCompareTarget here. e g pHome
        SetDO DOF_EntryRequest,0;
        ! Eingefuegt da Tueranforderung sonst ansteht
    ENDPROC

    !-----------------------------------------------------------------------------
    ! Procedure:     LoadCameraModules
    ! Description:   These procedure is used to load the cameramodules.
    !                PickVision always loads PvMain when started.
    !                START_ACCEPT_CAM and STOP_ACCEPT_CAM are set in PcMcSys
    !
    !                If the Article modules cannot be named ModCamX, There are two options.
    !             1: bModuleCamLoaded{X} can be used instead of ModExist ("ModCam"+ValToStr(i))
    !                NOTE: bModuleCamXLoaded has to be initialized as FALSE.
    !                If PickVision is started and you choose to start robot program from robotcontroler
    !                then bModuleCamXLoaded is TRUE and then sModuleCamX is not loaded.
    !
    !             2: If you use the same name length for every part and StrMatch and StrPart to identify the part name.
    !                i.e Article number, A193035154,
    !                nFound := StrMatch(sModuleCam{i},1,".mod");
    !                nFound, The character position of the first substring,sModuleCam{i},
    !                at or past the specified position, 1, that is equal to the specified pattern string, ".mod".
    !                NOTE: If no such substring is found, string length +1 is returned.
    !                sPart := StrPart(sModuleCam{i},(nFound-10),10);
    !                sPart, The substring of the specified string, sModuleCam{i}, which has the specified length,(nFound-10),
    !                and starts at the specified character position, 10.
    !                IF ModExist (sPart) = FALSE AND sModuleCam{i}<>stEmpty THEN
    !                NOTE: Define variables nFound and sPart
    !
    ! Remarks:
    ! Called from:   IntiPickVision
    !-----------------------------------------------------------------------------
    PROC LoadCameraModules()
        sModuleCam{1}:=sModuleCam1;
        sModuleCam{2}:=sModuleCam2;
        sModuleCam{3}:=sModuleCam3;
        sModuleCam{4}:=sModuleCam4;
        ! load camera specific modules
        FOR i FROM START_ACCEPT_CAM TO STOP_ACCEPT_CAM DO
            IF sModuleCam{i}<>stEmpty OR OPMode()<>OP_AUTO THEN
                IF ModExist("ModCam"+ValToStr(i))=FALSE AND bModuleCamLoaded{i}=FALSE AND sModuleCam{i}<>stEmpty THEN
                    Load sModuleCam{i};
                    bModuleCamLoaded{i}:=TRUE;
                    %"InitializeCam"+ValToStr(i)%;
                ELSEIF ModExist("ModCam"+ValToStr(i))=TRUE OR bModuleCamLoaded{i}=TRUE THEN
                    bModuleCamLoaded{i}:=TRUE;
                    %"InitializeCam"+ValToStr(i)%;
                ELSE
                    BELT_ACTION{i}:=RUN_NEVER;
                    ALLOW_AUTO_GRAB{i}:=FALSE;
                    bModuleCamLoaded{i}:=FALSE;
                ENDIF
            ELSE
                BELT_ACTION{i}:=RUN_NEVER;
                ALLOW_AUTO_GRAB{i}:=FALSE;
                bModuleCamLoaded{i}:=FALSE;
            ENDIF
        ENDFOR
        RETURN ;
    ENDPROC

    !-----------------------------------------------------------------------------
    ! Procedure:     PickCamera1
    ! Description:   Called when entering state PickCamera1.
    ! Argument:
    ! Remarks:
    ! Called from:   CheckAndEnterState
    !-----------------------------------------------------------------------------
    PROC PickCamera1()
        SetNextTarget 1;
        CallByVar "PickCam_",1;
        CallByVar "RefPosOutCam_",1;
    ENDPROC

    PROC PickCamera2()
        SetNextTarget 2;
        CallByVar "PickCam_",2;
        CallByVar "RefPosOutCam_",2;
    ENDPROC

    !-----------------------------------------------------------------------------
    ! Procedure:     Position_n
    ! Description:   Called when entering state Position.
    ! Argument:
    ! Remarks:
    ! Called from:   CheckAndEnterState
    !-----------------------------------------------------------------------------
    PROC Position_n()
        IF nCamera=CAMERA_NO_1 CallByVar "Cam1Position_",nPosition;
        IF nCamera=CAMERA_NO_2 CallByVar "Cam2Position_",nPosition;
        IF nCamera=CAMERA_NO_3 CallByVar "Cam3Position_",nPosition;
        IF nCamera=CAMERA_NO_4 CallByVar "Cam4Position_",nPosition;
    ENDPROC

    !-----------------------------------------------------------------------------
    ! Procedure:     StopRoutine
    ! Description:   This procedure is executed when the robot is in RefPosIn and PickVision is stopped
    !                Diese Prozedure wird ausgeführt wenn der Roboter in RefposIn steht und PickVision gestoppt wird
    ! Remarks:
    ! Called from:
    !-----------------------------------------------------------------------------
    PROC StopRoutine()
        FOR i FROM START_ACCEPT_CAM TO STOP_ACCEPT_CAM DO
            IF ModExist("ModCam"+ValToStr(i))=TRUE OR bModuleCamLoaded{i}=TRUE %"StopRoutineCam_"+ValToStr(i)%;
        ENDFOR
    ENDPROC

ENDMODULE
