MODULE ModCam2


  !-----------------------------------------------------------------------------
  ! Procedure:     InitializeCam_n
  ! Description:   This is an intermediate position used when entering the picking
  !                area. Update this position to suite the current application.						
  ! Argument:			 
  ! Remarks:       
  ! Called from:   LoadCameraModules in mainmodule
  !-----------------------------------------------------------------------------
  PROC InitializeCam2()
     BELT_ACTION{2}:=RUN_NEVER;
     ALLOW_AUTO_GRAB{2}:=FALSE;
     nImageGrabDelay{2}:=0.05;
  ENDPROC
  


ENDMODULE
