MODULE Selector
	!
	!Description: Receive and interpret commands from server
	!
		CONST string IP:="192.168.1.3";
		VAR num PORT_2:=4554;
    PERS num MAX_CLIENTS:=1;
    VAR socketdev socket;
    VAR num state:=1;
    CONST num MAX_PORT_NUMBER:=4999;
    VAR bool listening:=true;
    VAR num i:=1;
    VAR socketdev client_socket{3};
    VAR num nRetries_Closed;
    VAR num nRetries_AddrUsed;
    VAR num nRetries_Timeout;
    CONST num MAX_EQUAL_DATA_AMOUNT:=25;
    CONST num sendDelayTime:=0.08;
    VAR string receive_string;
    VAR socketstatus socketState;
    VAR bool connectionEstablished:=FALSE;
    CONST NUM MAX_RESEND_COUNTER:=5;
    VAR NUM resendCounter:=1;
	PERS NUM MAX_CMD_LENGTH := 10;
	
    PROC main()	
		WHILE TRUE
			setupConnection;
			sendReceive;
		ENDWHILE
    ENDPROC
		
	PROC setupConnection()
        IF (NOT connectionEstablished) THEN	
				SocketCreate client_socket{1};
                SocketConnect client_socket{1},IP,PORT_2\Time:=2;
				IF((SocketGetStatus( client_socket{1} ) = SOCKET_CONNECTED) AND (SocketGetStatus( client_socket{2} ) = SOCKET_CONNECTED)) THEN
					connectedToServer:=TRUE;
					WaitTime 1;
					connectionEstablished:=TRUE;
				ENDIF				
        ENDIF
	ENDPROC
	
	PROC sendReceive()
		VAR num recCmd := "";
			IF (connectedToServer) THEN			
								SocketReceive client_socket{1}\Str:=recCmd\Time:=3;
								
								! Check length to validate complete message								
								IF(StrLen(recCmd) <> MAX_CMD_LENGTH) THEN									
									SocketSend client_socket{1}\Str:="0";
								ELSE
									SocketSend client_socket{1}\Str:="1";
									interpreteCommand(recCmd);
								ENDIF						
			ENDIF

		ERROR
			IF ERRNO=ERR_SOCK_CLOSED THEN
				IF (DOutput(showSocketCmts)=1) TPwrite "Socket closed.";
				nRetries_Closed:=RemainingRetries();
				IF (nRetries_Closed>=0) THEN
					IF (DOutput(showSocketCmts)=1) TPwrite "Initialize socket.";
					initSocket;
					TRYNEXT;
				ENDIF
			ENDIF
			IF ERRNO=ERR_SOCK_ADDR_INUSE THEN
				IF (DOutput(showSocketCmts)=1) TPwrite "Soccket addres in use.";
				nRetries_AddrUsed:=RemainingRetries();
				IF (nRetries_AddrUsed>=0) THEN
					TRYNEXT;
				ENDIF
			ENDIF
			IF ERRNO=ERR_SOCK_TIMEOUT THEN
				! Prevent to save log in queue
				SkipWarn;
				IF (DOutput(showSocketCmts)=1) TPwrite "Socket timeout.";
				nRetries_Timeout:=RemainingRetries();
	            IF (nRetries_Timeout>=0) THEN
				    initSocket;
					TRYNEXT;
	            ENDIF
			ENDIF
		ENDPROC
	
	PROC interpreteCommand(num recCmd)
		FOR i FROM 1 TO MAX_CMD_LENGTH DO
			! Convert command string to boolean command array
		ENDFOR
	ENDPROC
	
	
	PROC initSocket()
        allDataIsSend:=FALSE;
		SocketClose socket;
		SocketClose client_socket{1};
		clientNameAlreadySend:=FALSE;
        i:=1;
        state:=1;
        listening:=TRUE;
        connectedToServer:=FALSE;
        isSending:=TRUE;
        nRetries_Closed:=0;
        nRetries_AddrUsed:=0;
        nRetries_Timeout:=0;
        connectionEstablished:=FALSE;
    ENDPROC
ENDMODULE