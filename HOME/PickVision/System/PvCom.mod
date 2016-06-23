MODULE PvCom
  
  !***************************************************
  !Programtype:  Background
  !Description:  This is one of the main system module for picking with
  !              PickVision with one or multiple cameras in concurrent operation.
  !              User is adviced not to make any changes to this
  !              file.
  !
  !
  !              Svensk Industriautomation AB.
  !
  ! Copyright (c) Svensk Industriautomation AB 2012
  ! All rights reserved
  !
  !---------------------------------------------------
  !Version           Date            Description
  !---------------------------------------------------
  !4.0              20111124         Created
  !
  !***************************************************


  !
  ! definition for belt actions, when to move them
  ! select from Belt Action constant values
  ! Definition, wann das Theaterband anlaufen soll
  ! Auswahl aus Theaterband Aktions-Konstanten
  PERS num BELT_ACTION{4};
  PERS bool ALLOW_AUTO_GRAB{4};
  PERS num nImageGrabDelay{4};
  !
  ! defines which cameras are accepted in CoordTrap
  ! to be used if a second robot accepts its coordinates
  ! in another task with its own CoordTrap
  PERS num START_ACCEPT_CAM;
  PERS num STOP_ACCEPT_CAM;
  PERS bool IS_SLAVE_PVMCSYS;
  !
  ! Belt Action constant values
  ! Theaterband Aktions-Konstanten
  CONST num RUN_NEVER:=0;
  CONST num RUN_NO_DETAIL:=1;
  CONST num RUN_ONE_DETAIL:=2;
  CONST num RUN_ALWAYS:=4;
  !
  ! camera constant values
  ! Kamera-Konstanten
  CONST num CAMERA_NO_1:=1;
  CONST num CAMERA_NO_2:=2;
  CONST num CAMERA_NO_3:=3;
  CONST num CAMERA_NO_4:=4;
  !
  !
  ! temporary communication variables PickVision
  ! temporäre Kommunikationsvariablen für PickVision
  PERS num x;
  PERS num y;
  PERS num z;
  PERS num pz;
  PERS num rotX;
  PERS num rotY;
  PERS num rotZ;
  PERS num amountOfDetails;
  PERS num amountOfDetails1;
  PERS num amountOfDetails2;
  PERS num amountOfDetails3;
  PERS num position;
  PERS num action;
  PERS num nPVStatus:=-1;
  PERS string sFreeParameter:="";
  PERS num cam;
  !
  ! PickVision action constant values
  ! PickVision Aktions-Konstanten
  CONST num NO_DETAILS:=1;
  CONST num ONE_DETAIL:=2;
  CONST num MANY_DETAILS:=4;
  CONST num CHANGE_BIN:=8;
  CONST num PICK_INTERLAYER:=16;
  CONST num PICK_INTERLAYER_AND_CHANGE_BIN:=32;
  CONST num MANY_DETAILS_NO_GRAB:=256;
  !
  ! command data to PickVision
  ! Kommando-Daten zu PickVision
  PERS bool bGrab1;
  PERS bool bGrab2;
  PERS bool bGrab3;
  PERS bool bGrab4;
  PERS bool bCoord;

  PERS bool bCoordReceived{4};
  PERS bool bStartUp_ShutDown;
  PERS bool bClearSend;
  
  PERS bool bPvComReady:=FALSE;
  PERS bool bIsMultiTaskSystem:=TRUE;
  !
  ! MultiCoordinate data received from PickVision
  ! MultiCoordinate Daten von PickVision
  CONST num MAX_NO_COORDS:=20;
  CONST num IS_FREE:=0;
  CONST num IN_USE:=1;
  CONST num MC_In_USE:=1;
  CONST num MC_X:=2;
  CONST num MC_Y:=3;
  CONST num MC_Z:=4;
  CONST num MC_ROTX:=5;
  CONST num MC_ROTY:=6;
  CONST num MC_ROTZ:=7;
  CONST num MC_POSZ:=8;
  CONST num MC_POSITION:=9;
  CONST num MC_AMOUNT_DETAIL:=10;
  PERS num nCoordIndex{4};
  PERS num nNumberOfCoords{4};
  PERS num nCoordValues{MAX_NO_COORDS,10,4};
  PERS num nMultiCoordinateLastAction{4};
  
  ! internal variables
  ! Interne Variablen
  VAR intnum iBeltReady{4};
  VAR intnum iCoord;
  !
  ! internal variables multicam
  ! Interne Variablen Multi-Cam
  PERS bool bGrabInProgres{4};
  PERS num nCamera;
  PERS num nLastCamera;
  PERS bool bIsMultiCam:=FALSE;
  
 
  PERS string log:="";
  !

  PROC main()
    InitTraps;
    bPvComReady:=TRUE;
    WHILE TRUE DO
      bIsMultiTaskSystem:=TRUE;
      IF bPvComReady=FALSE ExitCycle;
      WaitTime 0.05;
    ENDWHILE
  ENDPROC
  
  !-----------------------------------------------------------------------------
  ! These traps tells PickVision to grab an image after the belt
  ! has stopped.
  ! Dieser Interrupt lässt PickVision ein neues Bild aufnehmen, 
  ! sobald das Band gestoppt wurde
  !-----------------------------------------------------------------------------
  TRAP BeltReadyTrap1
    IF bGrabInProgres{CAMERA_NO_1}=TRUE THEN
    	 WriteLog("bGrabInProgress Cam1 = TRUE in BeltReadyTrap");
      RETURN;
    ENDIF
    !
    IF ALLOW_AUTO_GRAB{CAMERA_NO_1}=TRUE THEN
      WaitTime nImageGrabDelay{CAMERA_NO_1};
      bGrabInProgres{CAMERA_NO_1}:=TRUE;
      SendGrab1;
    ENDIF
  ENDTRAP

  TRAP BeltReadyTrap2
    !
    IF bGrabInProgres{CAMERA_NO_2}=TRUE THEN
    	WriteLog("bGrabInProgress Cam2 = TRUE in BeltReadyTrap");
      RETURN;
    ENDIF
    !
    IF ALLOW_AUTO_GRAB{CAMERA_NO_2}=TRUE THEN
      WaitTime nImageGrabDelay{CAMERA_NO_2};
      bGrabInProgres{CAMERA_NO_2}:=TRUE;
      SendGrab2;
    ENDIF
  ENDTRAP

  TRAP BeltReadyTrap3
    !
    IF bGrabInProgres{CAMERA_NO_3}=TRUE THEN
    	WriteLog("bGrabInProgress Cam3 = TRUE in BeltReadyTrap");
      RETURN;
    ENDIF
    ! 
    IF ALLOW_AUTO_GRAB{CAMERA_NO_3}=TRUE THEN
      WaitTime nImageGrabDelay{CAMERA_NO_3};
      bGrabInProgres{CAMERA_NO_3}:=TRUE;
      SendGrab3;
    ENDIF
  ENDTRAP

  TRAP BeltReadyTrap4
    !
    IF bGrabInProgres{CAMERA_NO_4}=TRUE THEN
    	WriteLog("bGrabInProgress Cam4 = TRUE in BeltReadyTrap");
      RETURN;
    ENDIF
    ! 
    IF ALLOW_AUTO_GRAB{CAMERA_NO_4}=TRUE THEN
      WaitTime nImageGrabDelay{CAMERA_NO_4};
      bGrabInProgres{CAMERA_NO_4}:=TRUE;
      SendGrab4;
    ENDIF
  ENDTRAP

  !-----------------------------------------------------------------------------
  ! This trap checks if nothing was found in the image and starts
  ! the belt immediately if so.
  ! Dieser Interrupt kontrolliert ob nichts im vorhergehenden Bild
  ! gefunden wurde und started in diesem Fall sofort das Band
  !-----------------------------------------------------------------------------
  TRAP CoordTrap
    !
    ! immediately reset trap triggered to allow new coordinates to arrive
    Reset DOF_Coord;
    !
    ! test for acceptance camera
    ! let the other robot tasks take care of this result ...
    IF (cam>0) AND ((cam<START_ACCEPT_CAM) OR (cam>STOP_ACCEPT_CAM)) THEN
      RETURN;
    ENDIF
    !
    IF (cam=0) AND (IS_SLAVE_PVMCSYS=TRUE) THEN
      RETURN;
    ENDIF
    !
    ! we cannot receive coordinates for the same camera before the old ones are used
    ! cam contains the camera that was used for the transferred coordinates
    IF bCoordReceived{cam}=TRUE THEN
      ! this should never happen
      WriteLog("PvMcSys::CoordTrap bCoordReceived{" + ValToStr(cam) + ")=TRUE on entry");
      SendCoord;
    ENDIF
    !
    ! test for FreeParameters and PvStatus
    IF (cam=0) AND (sFreeParameter<>"" OR nPVStatus<>-1)THEN
      !
      ! received PickVision status, do nothing but SendCoord
    ELSEIF (ALLOW_AUTO_GRAB{cam}=TRUE) AND (action<=NO_DETAILS) AND (BELT_ACTION{cam}<>RUN_NEVER) THEN
      !
      ! check for the case that we have to start the belt here
      StartBelt cam;
      bGrabInProgres{cam}:=FALSE;
    ELSE
      !
      ! transfer coordinates to the array
      IF (nCoordIndex{cam}<MAX_NO_COORDS) THEN
        nCoordIndex{cam}:=nCoordIndex{cam}+1;
        nCoordValues{nCoordIndex{cam},MC_IN_USE,cam}:=IN_USE;
        nCoordValues{nCoordIndex{cam},MC_X,cam}:=x;
        nCoordValues{nCoordIndex{cam},MC_Y,cam}:=y;
        nCoordValues{nCoordIndex{cam},MC_Z,cam}:=z;
        nCoordValues{nCoordIndex{cam},MC_ROTX,cam}:=rotX;
        nCoordValues{nCoordIndex{cam},MC_ROTY,cam}:=rotY;
        nCoordValues{nCoordIndex{cam},MC_ROTZ,cam}:=rotZ;
        nCoordValues{nCoordIndex{cam},MC_POSZ,cam}:=pz;
        nCoordValues{nCoordIndex{cam},MC_POSITION,cam}:=position;
        nCoordValues{nCoordIndex{cam},MC_AMOUNT_DETAIL,cam}:=amountOfDetails;
        nNumberOfCoords{cam}:=nCoordIndex{cam};
      ENDIF
      !
      ! bCoordReceived is sent first when the last detail has been seen;
      IF ((action=ONE_DETAIL) OR (action=MANY_DETAILS) OR (action=CHANGE_BIN) OR (action=PICK_INTERLAYER) OR (action=PICK_INTERLAYER_AND_CHANGE_BIN)) THEN
        nMultiCoordinateLastAction{cam}:=action;
        bCoordReceived{cam}:=TRUE;
        nCoordIndex{cam}:=0;
      ENDIF
    ENDIF
    SendCoord;
  ENDTRAP
  
  PROC InitTraps()
    !
    ! disable old belt ready interrupts
    IDelete iBeltReady{CAMERA_NO_1};
    IDelete iBeltReady{CAMERA_NO_2};
    IDelete iBeltReady{CAMERA_NO_3};
    IDelete iBeltReady{CAMERA_NO_4};
    !
    ! connect to belt ready signal
    IF BELT_ACTION{CAMERA_NO_1}<>RUN_NEVER THEN
      CONNECT iBeltReady{CAMERA_NO_1} WITH BeltReadyTrap1;
      ISignalDO DOF_InPosition1,1,iBeltReady{CAMERA_NO_1};
    ENDIF
    IF BELT_ACTION{CAMERA_NO_2}<>RUN_NEVER THEN
      CONNECT iBeltReady{CAMERA_NO_2} WITH BeltReadyTrap2;
      ISignalDO DOF_InPosition2,1,iBeltReady{CAMERA_NO_2};
    ENDIF
    IF BELT_ACTION{CAMERA_NO_3}<>RUN_NEVER THEN
      CONNECT iBeltReady{CAMERA_NO_3} WITH BeltReadyTrap3;
      ISignalDO DOF_InPosition3,1,iBeltReady{CAMERA_NO_3};
    ENDIF
    IF BELT_ACTION{CAMERA_NO_4}<>RUN_NEVER THEN
      CONNECT iBeltReady{CAMERA_NO_4} WITH BeltReadyTrap4;
      ISignalDO DOF_InPosition4,1,iBeltReady{CAMERA_NO_4};
    ENDIF
    !
    ! prepare coordinates received signal
    IDelete iCoord;
    CONNECT iCoord WITH CoordTrap;
    ISignalDO DOF_Coord,1,iCoord;  
  ENDPROC


  LOCAL PROC SendCoord()
    bCoord:=TRUE;
    WaitUntil bCoord=FALSE;
  ENDPROC

  PROC SendGrab1()
    bGrabInProgres{CAMERA_NO_1}:=TRUE;
    bGrab1:=TRUE;
    WaitUntil bGrab1=FALSE;
  ENDPROC

  PROC SendGrab2()
    bGrabInProgres{CAMERA_NO_2}:=TRUE;
    bGrab2:=TRUE;
    WaitUntil bGrab2=FALSE;
  ENDPROC

  PROC SendGrab3()
    bGrabInProgres{CAMERA_NO_3}:=TRUE;
    bGrab3:=TRUE;
    WaitUntil bGrab3=FALSE;
  ENDPROC

  PROC SendGrab4()
    bGrabInProgres{CAMERA_NO_4}:=TRUE;
    bGrab4:=TRUE;
    WaitUntil bGrab4=FALSE;
  ENDPROC


  !-----------------------------------------------------------------------------
  ! This procedure starts the belt corresponding to
  ! the given inputs and outputs
  ! Diese Prozedure startet das Band entsprechend der
  ! gegebenen Ein- und Ausgänge.
  !-----------------------------------------------------------------------------
  PROC StartBelt(num nCameraNo)
      TEST nCameraNo
        CASE CAMERA_NO_1:
          Set DOF_RunFeeder1;
          WaitTime 0.2;
          Reset DOF_RunFeeder1;
        CASE CAMERA_NO_2:
          Set DOF_RunFeeder2;
          WaitTime 0.2;
          Reset DOF_RunFeeder2;
        CASE CAMERA_NO_3:
          Set DOF_RunFeeder3;
          WaitTime 0.2;
          Reset DOF_RunFeeder3;
        CASE CAMERA_NO_4:
          Set DOF_RunFeeder4;
          WaitTime 0.2;
          Reset DOF_RunFeeder4;
      ENDTEST
  ENDPROC

  !-----------------------------------------------------------------------------
  ! This procedure can be used whenever the user want to write a
  ! log item in the PickVision log.
  ! Diese Prozedure kan benutzt werden, um einen Eintrag in der
  ! LogDatei von PickVision einzufügen.
  !-----------------------------------------------------------------------------
  PROC WriteLog(
    string logItem)

    log:=logItem;
    WaitUntil log="";
  ENDPROC

ENDMODULE
