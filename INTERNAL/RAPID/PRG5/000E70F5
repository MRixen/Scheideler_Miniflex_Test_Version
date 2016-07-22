MODULE MachineSignals
  PROC main()
		IF bTableLoaded THEN
			SetDo doStartMachine,1;
			waitDi diMachineRdy,0;
			SetDo doStartMachine,0;
			bTableLoaded:=FALSE;
		ELSE
			WaitTime 0.02;
		ENDIF
  ENDPROC
ENDMODULE
