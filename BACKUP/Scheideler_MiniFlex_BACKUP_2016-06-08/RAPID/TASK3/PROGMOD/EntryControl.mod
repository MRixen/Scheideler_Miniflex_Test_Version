MODULE EntryControl
  !***************************************************
  !Programtype:  Background
  !Description:  Control Program Gate Lock Functions
  !              Entering Cell
  !
  !Programmer:   Ingemar Kronqvist
  !              Svensk Industriautomation AB.
  !    Phone +46 36 2100024
  !
  ! Copyright (c) Svensk Industriautomation AB 2011
  ! All rights reserved
  !
  !---------------------------------------------------
  !Version           Date            Description of changes:
  !---------------------------------------------------
  !1.0              20110622          Created
  !1.x              20yymmdd          Modified xxx by xxx Phone +46 36 21000xx
  !
  !***************************************************
  !
  !--- Variabel definitions
  !
  !# -----------------------
  !#--------Bool data
  !# -----------------------
  !# -----------------------
  !#--------Intnum data
  !# -----------------------
  !# -----------------------
  !# ------ Loaddata
  !# -----------------------
  !# -----------------------
  !#--------Num data
  !# -----------------------
  !# -----------------------
  !#--------Robtarget data
  !# -----------------------
  !# -----------------------
  !# ------ Speeddata
  !# -----------------------
  !# -----------------------
  !# ------ Stringdata
  !# -----------------------
  !# -----------------------
  !# ------ Tooldata
  !# -----------------------
  !# -----------------------
  !# ------ Wobjdata
  !# -----------------------
  !# -----------------------

  PROC main()
    WaitUntil EntryRequest=1 OR DOutput(DOF_EntryRequest)=1 OR DOutput(DOF_AutoStop_Ok)=0;
    IF EntryRequest=1 THEN
      SetDO DOF_EntryRequest,1;
      WaitDI EntryRequest,0;
    ELSEIF DOutput(DOF_EntryRequest)=1 AND (DOutput(DOF_CycleOn)=0 OR OPMode()<>OP_AUTO) THEN
      SetDO LockGate,0;
      WaitDO DOF_AutoStop_Ok,0;
      WaitDO DOF_AutoStop_Ok,1;
      SetDO LockGate,1;
      SetDO DOF_EntryRequest,0;
    ELSEIF DOutput(DOF_AutoStop_Ok)=0 THEN
      SetDO DOF_EntryRequest,1;
    ENDIF
    WaitTime 1;
  ENDPROC
ENDMODULE
