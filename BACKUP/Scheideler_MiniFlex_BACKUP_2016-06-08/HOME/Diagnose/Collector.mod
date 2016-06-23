MODULE Collector
    ! DEFINITIONS FOR ARTICLE DATA
    VAR num articleCounter;
    VAR bool positionFound:=FALSE;
    VAR num i:=1;
    VAR intnum getAD;
    VAR intnum setAD;
    CONST num MAX_ARTICLE_DESCRIPTION_DATA:=5;
    VAR string filename:="home:/LastUsedArticles.txt";
    VAR string data{MAX_ARTICLE_DESCRIPTION_DATA}:=[" "," "," "," "," "];
    VAR string header{MAX_ARTICLE_DESCRIPTION_DATA}:=["Date","Time","Article","Counter","CycleTime"];
    VAR string lastArticleNames{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleNamesTemp{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleCounters{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleCountersTemp{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleDate{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleDateTemp{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleTime{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleTimeTemp{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleCycleTime{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    VAR string lastArticleCycleTimeTemp{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
    CONST num MAX_ARTICLE_COUNTER:=5;
    VAR num ctMean;
    VAR num ctCounter;

    ! DEFINITIONS FOR MACHINE DATA
    CONST num MAX_DATA_SIZE:=14;
    VAR string mData{MAX_DATA_SIZE};
    VAR string serial;
    VAR string version;
    VAR string rtype;
    VAR string cid;
    VAR string lanip;
    VAR string clang;
    VAR string dutyTime;
    VAR string machineName;
    VAR string projectNumber;
    VAR string dateOfCreation;
    VAR string preAccept;
    VAR string finAccept;
    VAR string actOverride;
    VAR intnum getMD;
    VAR BOOL syncNonStaticMachineData:=TRUE;

    ! DEFINITIONS FOR CYCLETIME
    CONST num TOTAL_NUM_OF_CYCLES:=50;
    PERS bool bFirstCycle:=FALSE;
    PERS num nCycleTime:=5.401;
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
    VAR string msgTemp;

    ! DEFINITIONS FOR EVENT MESSAGES
    VAR intnum err_int;
    VAR trapdata err_data;
    VAR errdomain err_domain;
    VAR num err_number;
    VAR errtype err_type;
    VAR num firstCycleStart;
    VAR num robotState:=1;
    VAR string str1:="";
    VAR string str2:="";
    VAR string str3:="";
    VAR string str4:="";
    VAR string str5:="";
    VAR String collisionSector;
    VAR String collisionMessage;
    VAR pos robotPosition;

    ! DEFINITIONS FOR LOGGING


    ! GLOBAL DEFINITIONS	
    PERS num cntr:=13;
    VAR intnum getLog;

    !TODO Wertefehler, da am Ende ein Whitespace steht (5. Zeile)

    PROC main()
        init;
        WHILE TRUE DO
            WaitTime 0.01;
        ENDWHILE
    ENDPROC

    ! --------------------------
    ! ROUTINES FOR ARTICLE DATA
    ! --------------------------
    TRAP getArticleData
        tpWriteSocket actualProgName+"::"+ValToStr(nCyclesShow)+"::"+ValToStr(cycleTimeMean{1}),":a:";
    ENDTRAP

    ! --------------------------
    ! --------------------------


    ! --------------------------
    ! ROUTINES FOR MACHINE DATA
    ! --------------------------
    PROC sendMachineData()
        IF syncNonStaticMachineData THEN
            setNonStaticData;
            IF (NOT allDataIsSend) THEN
                FOR i FROM 1 TO MAX_DATA_SIZE DO
                    tpWriteSocket ValToStr(i-1)+"::"+mData{i},":i:";
                ENDFOR
                allDataIsSend:=TRUE;
            ELSE
                ! Send only the non static data
                FOR i FROM 13 TO MAX_DATA_SIZE DO
                    tpWriteSocket ValToStr(i-1)+"::"+mData{i},":i:";
                ENDFOR
            ENDIF
        ELSE
            FOR i FROM 1 TO MAX_DATA_SIZE DO
                tpWriteSocket ValToStr(i-1)+"::"+mData{i},":i:";
            ENDFOR
        ENDIF
    ENDPROC

    TRAP getMachineData
        sendMachineData;
    ENDTRAP

    PROC setNonStaticData()
        dutyTime:=GetServiceInfo(ROB_1\DutyTimeCnt);
        actOverride:=ValToStr(CSpeedOverride());
        mData:=[machineName,projectNumber,dateOfCreation,preAccept,finAccept,serial,version,rtype,cid,lanip,clang,robSpeed,actOverride,dutyTime];
    ENDPROC

    ! --------------------------
    ! --------------------------


    ! --------------------------
    ! ROUTINES FOR CYCLETIME
    ! --------------------------
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

            tpWriteSocket ValToStr(nCyclesShow)+"::"+"500"+"::"+"500"+"::"+ValToStr(nCycleTime)+"::"+ValToStr(cycleTimeMean{1}),":c:";

            time:=CTime()+":";
            startLimiter{1}:=1;
            WHILE (counter<=3) DO
                startLimiter{counter}:=StrFind(time,startLimiter{counter-1},":")+1;
                counter:=counter+1;
            ENDWHILE

            FOR i FROM 1 TO 3 DO
                endLimiter{i}:=StrFind(time,startLimiter{i},":")-1;
            ENDFOR

            hour:=StrPart(time,startLimiter{1},(endLimiter{1}-startLimiter{1})+1);
            minute:=StrPart(time,startLimiter{2},(endLimiter{2}-startLimiter{2})+1);
            second:=StrPart(time,startLimiter{3},(endLimiter{3}-startLimiter{3})+1);

            !msgTemp := ValToStr(cycleTimeMean{1})+ "::" +hour+ "::" +minute+ "::" +second;
            msgTemp:=ValToStr(nCycleTime)+"::"+hour+"::"+minute+"::"+second;
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

    ! --------------------------
    ! --------------------------


    ! --------------------------
    ! ROUTINES FOR EVENT MESSAGES
    ! --------------------------
    TRAP events
        GetTrapData err_data;
        ReadErrData err_data,err_domain,err_number,err_type\Str1:=str1\Str2:=str2\Str3:=str3\Str4:=str4\Str5:=str5;

        IF (DOutput(DOF_CycleOn))=1 AND firstCycleStart=0 THEN
            ! Cycle On State
            robotState:=1;
            firstCycleStart:=1;
        ENDIF
        IF (DOutput(DOF_CycleOn)=0) AND (firstCycleStart=1) THEN
            ! Cycle Off State - Robot stops, something happen
            robotState:=0;
            firstCycleStart:=0;
            ! Send event only when inside belt area
            IF DOutput(DOF_collisionDetect_001)=0 THEN
                robotPosition:=CPos(\Tool:=tool0\WObj:=wobj0);
                tpWriteSocket ValToStr(robotPosition.x)+"::"+ValToStr(robotPosition.y)+"::"+ValToStr(robotPosition.z),":cd:";
            ENDIF

            ! Send only the first string (str1) because there is too much load in string when using str1...5           
        ENDIF
    ENDTRAP

    ! --------------------------
    ! --------------------------


    ! --------------------------
    ! ROUTINES FOR LOGGING
    ! --------------------------
    TRAP getLoggingData
        tpWriteSocket loggingMsg,":l:";
    ENDTRAP

    ! --------------------------
    ! --------------------------

    ! --------------------------
    ! GLOBAL ROUTINES 
    ! --------------------------
    PROC WriteToFile(string filename,string data{*},string header{*},num size,bool setHeader,bool overwrite,bool noNewLine)
        VAR string headerString;
        VAR string dataString;
        VAR string readText:="EOF";
        VAR bool fileIsAvailable:=TRUE;

        IF (size<1) size:=1;

        ! Overwrite file or read from it to check if its empty
        IF overwrite THEN
            RemoveFile filename;
        ELSE
            Open filename,ioFileLog\Read;
            IF (fileIsAvailable) THEN
                readText:=ReadStr(ioFileLog);
                ! read from file to check if it is empty (write header) or not (dont write header)
                Close ioFileLog;
            ENDIF
        ENDIF

        ! Open file and write the header (when its empty and if flag is set)
        Open filename,ioFileLog\Append;
        ! Set header
        IF (readText=EOF) THEN
            IF setHeader THEN
                FOR i FROM 1 TO size DO
                    headerString:=headerString+header{i}+";";
                    IF (i=size) Write ioFileLog,headerString;
                ENDFOR
            ENDIF
        ENDIF
        ! Set data
        FOR i FROM 1 TO size DO
            dataString:=dataString+data{i}+";";
        ENDFOR
        IF (NOT setHeader) THEN
            IF (NOT noNewLine) THEN
                Write ioFileLog,dataString;
            ELSE
                Write ioFileLog,dataString\NoNewLine;
            ENDIF
            Close ioFileLog;
        ELSE
            Close ioFileLog;
        ENDIF
    ERROR
        IF ERRNO=ERR_FILEOPEN THEN
            fileIsAvailable:=FALSE;
            TRYNEXT;
        ENDIF
        IF ERRNO=ERR_FILEACC THEN
            TRYNEXT;
        ENDIF
    ENDPROC

    FUNC string ReadFromFile(string filename,num row,num column)
        VAR string readText{MAX_ARTICLE_COUNTER}:=[" "," "," "," "," "];
        VAR string element:=" ";
        VAR num startLimiter:=0;
        VAR num endLimiter:=1;
        VAR num counter:=1;
        VAR bool fileIsAvailable:=TRUE;

        ! Read the hole file without header
        Open filename,ioFileLog\Read;
        IF (fileIsAvailable) THEN
            readText{1}:=ReadStr(ioFileLog);
            FOR i FROM 1 TO MAX_ARTICLE_COUNTER DO
                readText{i}:=ReadStr(ioFileLog);
            ENDFOR
            Close ioFileLog;

            IF (NOT (readText{1}="EOF")) THEN
                ! Extract the specific string at position (row, column) only when file isn't empty
                WHILE (counter<=column-1) DO
                    startLimiter:=StrFind(readText{row},startLimiter+1,";");
                    counter:=counter+1;
                ENDWHILE
                endLimiter:=StrFind(readText{row},startLimiter+1,";");

                element:=StrPart(readText{row},startLimiter+1,(endLimiter-startLimiter)-1);
            ENDIF
        ENDIF
        RETURN element;
    ERROR
        IF ERRNO=ERR_FILEOPEN THEN
            fileIsAvailable:=FALSE;
            TRYNEXT;
        ENDIF
    ENDFUNC

    PROC tpWriteSocket(string msg,string msgType)
        IF connectedToServer THEN
            sendbuffer{cntr}:=msgType+msg+";";
            bufferState{cntr}:=TRUE;
            cntr:=cntr+1;
            IF (cntr>=25) THEN
                cntr:=1;
            ENDIF
        ENDIF
    ENDPROC

    PROC init()
        ! ----------------
        ! Init machine data
        ! ----------------
        serial:=GetSysInfo(\SerialNo);
        version:=GetSysInfo(\SWVersion);
        rtype:=GetSysInfo(\RobotType);
        cid:=GetSysInfo(\CtrlId);
        lanip:=GetSysInfo(\LanIp);
        clang:=GetSysInfo(\CtrlLang);
        dutyTime:=GetServiceInfo(ROB_1\DutyTimeCnt);
        machineName:="MaxiFlex Kreuzgelenke";
        projectNumber:="20193";
        dateOfCreation:="2015";
        preAccept:="KW 42";
        finAccept:="?";
        actOverride:=ValToStr(CSpeedOverride());

        CONNECT getMD WITH getMachineData;
        ISignalDO DOF_MDpulser,1,getMD;

        ! ----------------
        ! Init event messages
        ! ----------------       
        CONNECT err_int WITH events;
        IError COMMON_ERR,TYPE_ALL,err_int;

        ! ----------------
        ! Init logging
        ! ----------------     
        CONNECT getLog WITH getLoggingData;
        ISignalDO DOF_LogPulser,1,getLog;

        ! ----------------
        ! Init cycle timer
        ! ----------------  
        CONNECT getCT WITH getCycleTimeData;
        ISignalDO DOF_CTpulser,1,getCT;
        CONNECT resetCT WITH resetCycleTimeData;
        ISignalDO DOF_resetCTpulser,1,resetCT;

        ! ----------------
        ! Init article counter
        ! ----------------          
                CONNECT getAD WITH getArticleData;
                ISignalDO DOF_ADpulser,1,getAD;
        
    ENDPROC
ENDMODULE