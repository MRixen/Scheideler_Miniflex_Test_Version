MODULE Sender
	!
	!Description: Send all process data of the robot
	!
	CONST string IP:="127.0.0.1";
	CONST num PORT_1:=4447;	
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
    VAR string recMsg:="0";
    VAR socketstatus socketState;
    VAR bool connectionEstablished:=FALSE;
    CONST NUM MAX_RESEND_COUNTER:=5;
    VAR NUM resendCounter:=1;
	
    PROC main()	
		WHILE TRUE DO
			setupConnection;
			sendReceive;
		ENDWHILE
    ENDPROC
		
	PROC setupConnection()
        IF (NOT connectionEstablished) THEN		
				SocketCreate client_socket{1};
                SocketConnect client_socket{1},IP,PORT_1\Time:=2;
				IF((SocketGetStatus( client_socket{1} ) = SOCKET_CONNECTED)) THEN
					connectedToServer:=TRUE;
					WaitTime 1;
					connectionEstablished:=TRUE;
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
	
	PROC sendReceive()
			IF (connectedToServer) THEN
				recMsg := "-1";
				!IF (recCmd>0) THEN
					FOR i FROM 1 TO 25 DO
							IF (bufferState{i}) THEN
								RESEND:
								SocketSend client_socket{1}\Str:=sendbuffer{i};
								!SocketReceive client_socket{1}\Str:=recMsg\Time:=3;
!								IF ((recMsg<0) AND (resendCounter<=MAX_RESEND_COUNTER)) THEN
!									resendCounter := resendCounter+1;
!									GOTO RESEND;
!								ENDIF
								sendbuffer{i}:="";
								bufferState{i}:=false;
								resendCounter:=1;
								recMsg:="0";
								WaitTime sendDelayTime;
							ENDIF
							IF (NOT bufferState{i}) THEN
								! Send something to signal alive state
								SocketSend client_socket{1}\Str:=":p:;";
								WaitTime sendDelayTime;
							ENDIF
					ENDFOR
				!ENDIF
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