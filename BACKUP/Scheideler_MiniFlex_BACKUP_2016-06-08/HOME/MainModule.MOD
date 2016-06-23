MODULE MainModule
	CONST robtarget pVaranHemma:=[[369.58,-12.54,226.21],[0.711507,-0.017642,0.702403,-0.00876183],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare10:=[[383,260,36],[0.0522537,-0.707714,0.704169,0.0235505],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare20:=[[383.00,259.98,-3.97],[0.00624872,0.463856,-0.884041,0.0571571],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare30:=[[91,260,-2],[0.0378147,-0.709731,0.703453,0.00172641],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare40:=[[91,160,-2],[0.0353016,-0.449138,0.89266,0.013573],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare50:=[[383,160,-2],[0.0352804,-0.449177,0.892641,0.0135976],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare60:=[[383,260,-2],[0.0352723,-0.449208,0.892627,0.0135622],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawSqare70:=[[383,260,60],[0.0352654,-0.44919,0.892636,0.0135803],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle10:=[[382.99,260.00,35.99],[0.0522618,-0.707715,0.704168,0.0235389],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle20:=[[383.01,259.99,-3],[0.0184698,0.443818,-0.894605,0.0486245],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle30:=[[90.99,260.00,-2.00],[0.0378323,-0.709746,0.703438,0.0017104],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle40:=[[383.00,160.00,-2.01],[0.035265,-0.449176,0.892642,0.0136007],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle50:=[[382.98,259.99,-2.01],[0.0352589,-0.449213,0.892624,0.0135815],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle60:=[[383.00,260.01,60.01],[0.0352671,-0.449174,0.892643,0.0136189],[0,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawTriangle70:=[[539.74,254.67,-52.01],[0.00943473,0.0272459,0.999473,-0.0148301],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle10:=[[382.76,203.94,100],[0.0448253,-0.812052,0.579454,0.0528469],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle20:=[[382.76,203.95,-2.66],[0.000120832,0.799372,-0.59959,0.0386546],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle40:=[[256.32,210.88,-4.00],[0.0104117,0.818303,-0.574124,0.0255234],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle30:=[[318.62,260.64,-3.48],[0.010398,0.818303,-0.574125,0.0255172],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle60:=[[382.75,203.94,-2.66],[0.0448482,-0.812055,0.579451,0.052821],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle50:=[[318.45,159.91,-3.58],[0.0104322,0.818284,-0.574151,0.0255289],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	CONST robtarget pDrawCircle70:=[[382.75,203.95,50.39],[0.0448775,-0.812062,0.579439,0.0528146],[-1,-1,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
	PROC main()
		GoHome;
		SelectFigure;
		GoHome;
		Stop;
	ENDPROC
	PROC GoHome()
		MoveJ pVaranHemma, v100, z50, tool0\WObj:=wobj0;
	ENDPROC
	PROC DrawSquare()
		MoveL Offs(pDrawSqare20,0,0,50), v200, fine, tPencil\WObj:=wTable;
		MoveL pDrawSqare20, v50, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawSqare20,-300,0,0), v200, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawSqare20,-300,-100,0), v200, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawSqare20,0,-100,0), v200, fine, tPencil\WObj:=wTable;
		MoveL pDrawSqare20, v100, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawSqare20,0,0,50), v100, fine, tPencil\WObj:=wTable;
	ENDPROC
	PROC DrawTriangle()
		MoveL Offs(pDrawTriangle20,0,0,50), v100, fine, tPencil\WObj:=wTable;
		MoveL pDrawTriangle20, v100, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawTriangle20,-300,0,0), v100, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawTriangle20,0,-100,0), v100, fine, tPencil\WObj:=wTable;
		MoveL pDrawTriangle20, v100, fine, tPencil\WObj:=wTable;
		MoveL Offs(pDrawTriangle20,0,0,50), v100, fine, tPencil\WObj:=wTable;
	ENDPROC
	PROC DrawCircle()
		MoveL pDrawCircle10, v150, z50, tPencil\WObj:=wTable;
		MoveL pDrawCircle20, v150, fine, tPencil\WObj:=wTable;
		MoveC pDrawCircle30, pDrawCircle40, v150, z40, tPencil\WObj:=wTable;
		MoveC pDrawCircle50, pDrawCircle60, v150, fine, tPencil\WObj:=wTable;
		MoveL pDrawCircle70, v150, z50, tPencil\WObj:=wTable;
	ENDPROC
	PROC SelectFigure()
		WaitDI di_16_b2, 1;
		IF di_17_b2 = 1 THEN
			DrawSquare;
		ENDIF
	ENDPROC
ENDMODULE