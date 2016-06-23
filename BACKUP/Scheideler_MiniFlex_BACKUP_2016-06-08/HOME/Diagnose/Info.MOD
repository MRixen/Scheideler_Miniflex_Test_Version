MODULE Info
    ! MachineData
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
	VAR BOOL syncNonStaticMachineData := TRUE;


    PROC initMachineData()
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
        ISignalDO getMDpulser,1,getMD;
    ENDPROC

    PROC sendMachineData()
        IF syncNonStaticMachineData THEN
            setNonStaticData;
            IF (NOT allDataIsSend) THEN
                FOR i FROM 1 TO MAX_DATA_SIZE DO
                    tpWriteSocket mData{i},":"+ValToStr(i-1)+":";
                ENDFOR
                allDataIsSend:=TRUE;
            ELSE
                ! Send only the non static data
                FOR i FROM 13 TO MAX_DATA_SIZE DO
                    tpWriteSocket mData{i},":"+ValToStr(i-1)+":";
                ENDFOR
            ENDIF
        ELSE
            FOR i FROM 1 TO MAX_DATA_SIZE DO
                tpWriteSocket mData{i},":"+ValToStr(i-1)+":";
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
ENDMODULE