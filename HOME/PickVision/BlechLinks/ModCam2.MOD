MODULE ModCam2
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
  PERS loaddata lDetailCam2:=[0.001,[0,0,0.001],[1,0,0,0],0,0,0];
  
  !# -----------------------
  !# ------ Robtargetdata
  !# -----------------------
  !
  PERS robtarget pRefPosInCam2:=[[234.06,-284.28,501.73],[0.0855767,-0.692985,0.706532,0.115154],[-1,-1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pRefPosOutCam2:=[[265.39,-363.96,552.07],[0.748213,-0.120078,0.566899,-0.323086],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pDropX:=[[44.13,19.62,59.98],[0.200017,-0.217547,0.726905,0.6199],[0,-2,2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pPrePick:=[[-265.42,-3.55,164.66],[0.0156929,-0.994543,-0.0600214,0.0838718],[-1,-1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pBeforeDrop2:=[[624.74,-157.52,505.02],[0.0506627,0.131262,0.989956,0.0138061],[-1,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pPreFalseGripp2:=[[287.24,-268.99,533.56],[0.0385303,-0.734165,0.677585,0.0198931],[-1,-1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pPre2FalseGripp2:=[[193.38,-856.33,447.77],[0.0385314,-0.734164,0.677586,0.019894],[-1,-1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pFalseGripp2:=[[196.72,-887.81,437.40],[0.0385035,-0.734171,0.677583,0.0197959],[-1,-1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  PERS robtarget pvpMachine2:=[[173.17,-355.73,430.58],[0.0608158,-0.254847,0.964993,0.0119669],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
  CONST robtarget pPreFalseGripp12:=[[271.90,-124.48,494.47],[0.306326,-0.645284,0.096117,0.693206],[-1,0,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

  
  !-----------------------------------------------------------------------------
  ! Procedure:     InitializeCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:			 
  ! Remarks:       
  ! Called from:   LoadCameraModules in mainmodule
  !-----------------------------------------------------------------------------
  PROC InitializeCam2()
     BELT_ACTION{2}:=RUN_NO_DETAIL;
     ALLOW_AUTO_GRAB{2}:=TRUE;
     nImageGrabDelay{2}:=0.05;
     tGripperCam2:=tGripperMutter;
  ENDPROC
  

  !-----------------------------------------------------------------------------
  ! Procedure:     PickCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:
  ! Remarks:       
  ! Called from:   PickCamera
  !-----------------------------------------------------------------------------
  PROC PickCam_2()   
    ConfJ\On;
    ConfL\On;   
	!Overwrite orientation to prevent unreachable positioning
    pPick.rot.q1 := 0.0;
    pPick.rot.q2 := 0.99992;
    pPick.rot.q3 := 0.00122;
    pPick.rot.q4 := -0.01286;
	MoveJ pPrePick, vmax, z200, tGripperCam2\WObj:=wCamera2;

    MoveJ RelTool(pPick,0,0,-nPZ), vmax, z5, tGripperCam2\WObj:=wCamera2;
    MoveL pPick, v1000, fine, tGripperCam2\WObj:=wCamera2;
    Gripper2 1;
    GripLoad lDetailCam2;
    MoveL Offs(pPick,0,0,nPZ), vmax, z40, tGripperCam2\WObj:=wCamera2;
    MoveJ pPrePick, vmax, z5, tGripperCam2\WObj:=wCamera2;
  ENDPROC
  
  
  Proc Falseparte2()
  	MoveJ pPreFalseGripp2, vmax, z40, tGripperCam2\WObj:=wobj0;
  	MoveL pPreFalseGripp2, vmax, z40, tGripperCam2\WObj:=wobj0;
    MoveL pPre2FalseGripp2, vmax, z10, tGripperCam2\WObj:=wobj0;
    MoveL pFalseGripp2, vmax, fine, tGripperCam2\WObj:=wobj0;
  	Gripper2 0;
  	Gripper2 1;
  	Gripper2 0;
    MoveL Offs(pPreFalseGripp2,0,0,15), vmax, z40, tGripperCam2\WObj:=wobj0;
  	!MoveL pPreFalseGripp2, vmax, z10, tGripperCam2\WObj:=wobj0;
  Endproc


  !-----------------------------------------------------------------------------
  ! Procedure:     RefPosInCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:
  ! Remarks:       
  ! Called from:   Main
  !-----------------------------------------------------------------------------
  PROC RefPosInCam_2()
    ConfJ\On;
    ConfL\On;
    IF ( (diGripperOpen=0) AND (diGripper=0) ) THEN
    	Gripper2 0;
    ENDIF
    IF bFirstRefPos=TRUE THEN
      bFirstRefPos:=FALSE;
      !MoveJSync pRefPosInCam2, v500, z200, tGripperCam2\WObj:=wobj0, "StartMaschine";
      MoveJ pRefPosInCam2, v500, z200, tGripperCam2\WObj:=wobj0;
    ELSE
      !MoveJSync pRefPosInCam2, vmax, z200, tGripperCam2\WObj:=wobj0, "StartMaschine";
      MoveJ pRefPosInCam2, vmax, z200, tGripperCam2\WObj:=wobj0;
    ENDIF
    IF diGripper=1 THEN
    	Falseparte2;
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
  PROC RefPosOutCam_2()
    ConfJ\On;
    ConfL\On;
    MoveJSync pRefPosOutCam2, vmax, z200, tGripperCam2\WObj:=wobj0, "ConfirmPick2";
  ENDPROC

  !------------------------------------------------------------------------------------------------
  ! Procedure:   StopRoutine
  ! Description: This procedure is executed when PickVision is stopped
  !              Diese Prozedure wird ausgeführt wenn PickVision gestoppt wird
  !------------------------------------------------------------------------------------------------
  PROC StopRoutineCam_2()

  ENDPROC

ENDMODULE
