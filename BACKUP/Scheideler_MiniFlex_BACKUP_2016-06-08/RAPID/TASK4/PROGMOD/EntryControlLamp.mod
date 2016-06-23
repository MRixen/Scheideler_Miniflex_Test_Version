MODULE EntryControlLamp
  !***************************************************
  !Programtype:  Background
  !Description:  Control Program Lamp Functions
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
  !1.0              20100412          Created
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
      SetDO EntryRequestControlLamp,1;
      WaitUntil EntryRequest=0;
    ELSEIF DOutput(DOF_EntryRequest)=1 AND DOutput(LockGate)=0 THEN
      SetDO EntryRequestControlLamp,1;
      WaitUntil DOutput(LockGate)=1 AND DOutput(DOF_AutoStop_Ok)=1;
      SetDO EntryRequestControlLamp,0;
    ELSEIF DOutput(DOF_EntryRequest)=1 THEN
      PulseDO\PLength:=0.7,EntryRequestControlLamp;
      WaitTime 0.9;
    ELSEIF DOutput(DOF_AutoStop_Ok)=0 THEN
      SetDO EntryRequestControlLamp,1;
      WaitUntil DOutput(LockGate)=1 AND DOutput(DOF_AutoStop_Ok)=1;
      SetDO EntryRequestControlLamp,0;
    ELSE
      SetDO EntryRequestControlLamp,0;
      WaitTime 1;
    ENDIF
  ENDPROC
ENDMODULE
