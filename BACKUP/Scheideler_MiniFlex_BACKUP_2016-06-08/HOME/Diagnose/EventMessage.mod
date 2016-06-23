MODULE EventMessage
    ! EventMessages
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

    PROC initEventMessages()
        CONNECT err_int WITH events;
        IError COMMON_ERR,TYPE_ALL,err_int;
    ENDPROC

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
        ENDIF
        tpWriteSocket ValToStr(robotState)+"::"+ValToStr(err_domain)+"::"+ValToStr(err_number)+"::"+ValToStr(err_type)+"::"+str1+"::"+"X"+"::"+"X"+"::"+"X"+"::"+"X",":e:";
        ! Send only the first string (str1) because there is too much load in string when using str1...5 
    ENDTRAP
ENDMODULE