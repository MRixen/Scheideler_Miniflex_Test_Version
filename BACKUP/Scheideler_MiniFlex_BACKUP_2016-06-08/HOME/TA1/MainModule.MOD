MODULE MainModule
	PERS robtarget pPickdetail:=[[-30.87,134.37,47.41],[0.488385,-0.500768,0.499923,0.510674],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pPickdetail10:=[[-29.10,57.42,50.10],[0.488404,-0.500695,0.499955,0.510696],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pLoadmachine1:=[[507.65,54.76,35.48],[0.488378,-0.500778,0.49992,0.510674],[-1,-1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pUnloadMachine1:=[[507.63,54.77,35.48],[0.488376,-0.500789,0.499908,0.510677],[-1,-1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pUnloadMachine2:=[[601.08,50.09,36.50],[0.488315,-0.500845,0.499914,0.510675],[-1,-1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pLoadMachine12:=[[601.10,50.08,36.51],[0.488319,-0.500835,0.499924,0.510672],[-1,-1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pUnloadMachine12:=[[601.10,50.08,36.51],[0.488317,-0.500835,0.499925,0.510671],[-1,-1,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pLeavePallet:=[[143.73,122.19,34.25],[0.493098,-0.494213,0.49532,0.516977],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	PERS bool bMachin1Loader:=TRUE;
	PERS bool bMachin2Loader:=FALSE;
	PERS num nPosX:=0;
	VAR num nXoffset:=0;
	VAR num nYoffset:=0;
	VAR num nPosY:=0;
	VAR num nPosZ:=0;
	VAR num nZoffset:=0;
	PROC main()
		Init;
		WHILE TRUE DO
			IF bMachin1Loader = FALSE AND bMachin2Loader = FALSE THEN
				PickMagazine;
				LoadMachine1;
			ELSEIF bMachin1Loader = TRUE AND bMachin2Loader = FALSE THEN
				UnloadMachine;
				LoadMachine2;
			ELSEIF bMachin1Loader = FALSE AND bMachin2Loader = TRUE THEN
				PickMagazine;
				LoadMachine1;
			ELSEIF bMachin1Loader = TRUE AND bMachin2Loader = TRUE THEN
				UnloadMachine2;
				LeavePallet;
				!Stop;
			ENDIF
			GoHome;
		ENDWHILE
	ENDPROC
	PROC PickMagazine()
		MoveL Offs(pPickdetail,0,-60,0), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL pPickdetail, v1000, fine, tGripper\WObj:=wTABLE;
		CloseGripper;
		MoveL Offs(pPickdetail,0,-80,0), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL Offs(pPickdetail,130,-80,150), v1000, fine, tGripper\WObj:=wTABLE;
	ENDPROC
	PROC GoHome()
		MoveL pHome, v1000, z50, tGripper\WObj:=wTABLE;
	ENDPROC
	PROC LoadMachine1()
		MoveL Offs(pLoadmachine1,0,-50,50), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL Offs(pLoadmachine1,0,0,50), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL pLoadmachine1, v1000, fine, tGripper\WObj:=wTABLE;
		Set Lampa1;
		OpenGripper;
		MoveL Offs(pLoadmachine1,0,-50,0), v1000, fine, tGripper\WObj:=wTABLE;
		bMachin1Loader := TRUE;
	ENDPROC
	PROC UnloadMachine()
		MoveL Offs(pUnloadMachine1,0,-50,0), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL pUnloadMachine1, v1000, fine, tGripper\WObj:=wTABLE;
		CloseGripper;
		MoveL Offs(pUnloadMachine1,0,0,80), v1000, fine, tGripper\WObj:=wTABLE;
		Reset Lampa1;
		MoveL Offs(pUnloadMachine1,0,-70,80), v1000, fine, tGripper\WObj:=wTABLE;
		bMachin1Loader := FALSE;
	ENDPROC
	PROC LoadMachine2()
		MoveL Offs(pLoadMachine12,0,-70,80), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL Offs(pLoadMachine12,0,0,80), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL pLoadMachine12, v1000, fine, tGripper\WObj:=wTABLE;
		Set Lampa2;
		OpenGripper;
		MoveL Offs(pLoadMachine12,0,-50,0), v1000, fine, tGripper\WObj:=wTABLE;
		bMachin2Loader := TRUE;
	ENDPROC
	PROC UnloadMachine2()
		MoveL Offs(pUnloadMachine2,0,-60,0), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL pUnloadMachine2, v1000, fine, tGripper\WObj:=wTABLE;
		CloseGripper;
		MoveL Offs(pUnloadMachine2,0,0,200), v1000, fine, tGripper\WObj:=wTABLE;
		Reset Lampa2;
		bMachin2Loader := FALSE;
	ENDPROC
	PROC LeavePallet()
		MoveL Offs(pLeavePallet,nXoffset,-nYoffset,nZoffset + 200), v1000, fine, tGripper\WObj:=wTABLE;
		MoveL Offs(pLeavePallet,nXoffset,-nYoffset,nZoffset), v1000, fine, tGripper\WObj:=wTABLE;
		OpenGripper;
		MoveL Offs(pLeavePallet,nXoffset,-nYoffset - 60,nZoffset), v1000, fine, tGripper\WObj:=wTABLE;
		CheckNextPosition;
	ENDPROC
	PROC Init()
		GoHome;
		bMachin1Loader := FALSE;
		bMachin2Loader := FALSE;
		Reset Lampa1;
		Reset Lampa2;
		OpenGripper;
		nPosX := 0;
		nPosY := 0;
		nPosZ := 0;
	ENDPROC
	PROC CheckNextPosition()
		IF nPosX = 2 THEN
			nPosX := 0;
			IF nPosY = 1 THEN
				nPosY := 0;
				IF nPosZ = 1 THEN
					Stop;
				ELSE
					Incr nPosZ;
				ENDIF
			ELSE
				Incr nPosY;
			ENDIF
		ELSE
			Incr nPosX;
		ENDIF
		nXoffset := nPosX * 100;
		nYoffset := nPosY * 55;
		nZoffset := nPosZ * 58;
	ENDPROC
ENDMODULE