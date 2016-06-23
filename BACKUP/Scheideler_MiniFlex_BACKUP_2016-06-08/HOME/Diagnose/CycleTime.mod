MODULE CycleTime
    ! CycleTimer
    CONST num TOTAL_NUM_OF_CYCLES:=50;
    PERS bool bFirstCycle:=FALSE;
    PERS num nCycleTime:=2.044;
    PERS num cycleTimeMean{TOTAL_NUM_OF_CYCLES};
    VAR clock cCycleTime;
    VAR num nCycles;
    VAR num nCyclesShow;
    VAR num cycleTimeActual{TOTAL_NUM_OF_CYCLES};
    VAR num totalTime;
    VAR iodev ioFileLog;
    VAR intnum getCT;
    VAR intnum resetCT;
	
				VAR string time;
			VAR string hour;
			VAR string minute;
			VAR string second;
			VAR string  msgTemp;

    PROC initCycleTimer()
        CONNECT getCT WITH getCycleTimeData;
        ISignalDO getCTpulser,1,getCT;
        CONNECT resetCT WITH resetCycleTimeData;
        ISignalDO resetCTpulser,1,resetCT;
    ENDPROC


    TRAP getCycleTimeData
        NextCycleTime;
    ENDTRAP

    TRAP resetCycleTimeData
        ResetCycleTimes;
    ENDTRAP

    PROC NextCycleTime()
		VAR num counter:=2;
		VAR num startLimiter{3}:=[0,0,0];
		VAR num endLimiter{3}:=[0,0,0];
		
        ! skip calculation first cycle and start clock
        IF bFirstCycle=FALSE THEN
            ! maximum numbers of cycles in calculation=TOTAL_NUM_OF_CYCLES
            IF nCycles<TOTAL_NUM_OF_CYCLES Incr nCycles;
            Incr nCyclesShow;
            ClkStop cCycleTime;
            nCycleTime:=ClkRead(cCycleTime);

            ! store latset cycle time in the array
            FOR i FROM (TOTAL_NUM_OF_CYCLES-1) TO 1 DO
                cycleTimeActual{i+1}:=cycleTimeActual{i};
                cycleTimeMean{i+1}:=cycleTimeMean{i};
            ENDFOR
            cycleTimeActual{1}:=nCycleTime;
            cycleTimeMean{1}:=totalTime/nCycles;

            ! Save total time
            totalTime:=0;
            FOR i FROM 1 TO TOTAL_NUM_OF_CYCLES DO
                totalTime:=totalTime+cycleTimeActual{i};
            ENDFOR

            ! Send logs and cycle time to remote console (smartphone)
            tpWriteSocket "Gesamtzahl der gefertigten Teile:: "+ValToStr(nCyclesShow),":l:";
            tpWriteSocket ValToStr(nCycleTime),":c1:";
            tpWriteSocket ValToStr(cycleTimeMean{1}),":c2:";
			
			time := CTime()+":";
			startLimiter{1}:=1;
			WHILE (counter<=3) DO
				startLimiter{counter}:=StrFind(time,startLimiter{counter-1},":")+1;
				counter:=counter+1;
            ENDWHILE
            
            FOR i FROM 1 TO 3 DO
                endLimiter{i}:=StrFind(time,startLimiter{i},":")-1;				
            ENDFOR           
			
			hour := StrPart(time,startLimiter{1},(endLimiter{1}-startLimiter{1})+1);
			minute := StrPart(time,startLimiter{2},(endLimiter{2}-startLimiter{2})+1);
			second := StrPart(time,startLimiter{3},(endLimiter{3}-startLimiter{3})+1);
			
			!msgTemp := ValToStr(cycleTimeMean{1})+ "::" +hour+ "::" +minute+ "::" +second;
			msgTemp := ValToStr(nCycleTime)+ "::" +hour+ "::" +minute+ "::" +second;
			TPwrite msgTemp;
            tpWriteSocket msgTemp,":c1x:";
					

            ! Copy to global variable
            ctMean:=cycleTimeMean{1};
            ctCounter:=nCycleTime;

            ClkReset cCycleTime;
        ENDIF
        ClkStart cCycleTime;
        bFirstCycle:=FALSE;
    ENDPROC

    PROC ResetCycleTimes()
        nCycles:=0;
        nCyclesShow:=0;
        ! reset the array
        FOR i FROM 1 TO TOTAL_NUM_OF_CYCLES DO
            cycleTimeActual{i}:=0;
        ENDFOR
        ClkStop cCycleTime;
        ClkReset cCycleTime;
        bFirstCycle:=TRUE;
    ENDPROC
ENDMODULE