MODULE Articles
    ! ArticleCounter
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


	CONST num MAX_ARTICLE_COUNTER := 5;
	VAR num ctMean;
	VAR num ctCounter;

	
	!TODO Optimization for re-wrting data to file (write the actual article only in the specific row)

    PROC initArticleCounter()
        CONNECT getAD WITH getArticleData;
        ISignalDO getADpulser,1,getAD;

        CONNECT setAD WITH setArticleData;
        ISignalDO setADpulser,1,setAD;
    ENDPROC

    TRAP getArticleData
        sendArticleData;
    ENDTRAP

    TRAP setArticleData
        setArticlesAndCounters;
    ENDTRAP

    PROC setArticlesAndCounters()
        ! Load articles from file
        FOR row FROM 1 TO MAX_ARTICLE_COUNTER DO
		    lastArticleDate{row}:=ReadFromFile(filename,row,1);
            lastArticleTime{row}:=ReadFromFile(filename,row,2);
            lastArticleNames{row}:=ReadFromFile(filename,row,3);
            lastArticleCounters{row}:=ReadFromFile(filename,row,4);
            lastArticleCycleTime{row}:=ReadFromFile(filename,row,5);
        ENDFOR

        ! Get article counter
        i:=1;
        WHILE ((i<=MAX_ARTICLE_COUNTER) AND (positionFound=FALSE)) DO
            IF (lastArticleNames{i}=" ") THEN
                lastArticleNames{i}:=actualProgName;
				lastArticleDate{i}:=CDate();
				lastArticleTime{i}:=CTime();
				lastArticleCycleTime{i}:=ValToStr(nCyclesShow);
                articleCounter:=i;
                positionFound:=TRUE;
            ELSEIF (lastArticleNames{i}=actualProgName) THEN
                articleCounter:=i;
				lastArticleDate{i}:=CDate();
				lastArticleTime{i}:=CTime();
				lastArticleCycleTime{i}:=ValToStr(nCyclesShow);
                positionFound:=TRUE;
            ELSEIF ((NOT (lastArticleNames{i}=" ")) AND (i=MAX_ARTICLE_COUNTER)) THEN
                FOR j FROM 1 TO MAX_ARTICLE_COUNTER DO
                    IF (j<MAX_ARTICLE_COUNTER) THEN
                        lastArticleNamesTemp{j}:=lastArticleNames{j+1};
                        lastArticleCountersTemp{j}:=lastArticleCounters{j+1};
                        lastArticleTimeTemp{j}:=lastArticleTime{j+1};
                        lastArticleDateTemp{j}:=lastArticleDate{j+1};
                        lastArticleCycleTimeTemp{j}:=lastArticleCycleTime{j+1};
                    ENDIF
                    lastArticleNamesTemp{MAX_ARTICLE_COUNTER}:=actualProgName;
                    lastArticleDateTemp{MAX_ARTICLE_COUNTER}:=CDate();
                    lastArticleTimeTemp{MAX_ARTICLE_COUNTER}:=CTime();
					
                    lastArticleNames{j}:=lastArticleNamesTemp{j};
                    lastArticleCounters{j}:=lastArticleCountersTemp{j};
                    lastArticleDate{j}:=lastArticleDateTemp{j};
                    lastArticleTime{j}:=lastArticleTimeTemp{j};
                    lastArticleCycleTime{j}:=lastArticleCycleTimeTemp{j};
                ENDFOR
                articleCounter:=MAX_ARTICLE_COUNTER;
                positionFound:=TRUE;
            ENDIF
            i:=i+1;
        ENDWHILE
        positionFound:=FALSE;
    ENDPROC

    PROC sendArticleData()
        IF (articleCounter>0) THEN
            ! Save counter for actual article to array
            lastArticleCounters{articleCounter}:=ValToStr(nCyclesShow);
            lastArticleCycleTime{articleCounter}:=ValToStr(ctMean);

            ! Set header
            WriteToFile filename,data,header,MAX_ARTICLE_DESCRIPTION_DATA,TRUE,TRUE,FALSE;

            FOR j FROM 1 TO MAX_ARTICLE_COUNTER DO
                data{1}:=lastArticleDate{j};
                data{2}:=lastArticleTime{j};
                data{3}:=lastArticleNames{j};
                data{4}:=lastArticleCounters{j};
                data{5}:=lastArticleCycleTime{j};
                IF (j<=articleCounter) THEN
                    IF (j=MAX_ARTICLE_COUNTER) THEN
                        WriteToFile filename,data,header,MAX_ARTICLE_DESCRIPTION_DATA,FALSE,FALSE,TRUE;
                    ELSE
                        WriteToFile filename,data,header,MAX_ARTICLE_DESCRIPTION_DATA,FALSE,FALSE,FALSE;
                    ENDIF
                ELSE
                    IF (j=MAX_ARTICLE_COUNTER) THEN
                        WriteToFile filename,data,header,MAX_ARTICLE_DESCRIPTION_DATA,FALSE,FALSE,TRUE;
                    ELSE
                        WriteToFile filename,data,header,MAX_ARTICLE_DESCRIPTION_DATA,FALSE,FALSE,FALSE;
                    ENDIF
                ENDIF
            ENDFOR
            ! Send article information (counter + last used articles)
            FOR i FROM 1 TO MAX_ARTICLE_COUNTER DO
                tpWriteSocket lastArticleNames{i}+"::"+lastArticleCounters{i}+"::"+ValToStr(i-1),":a:";
            ENDFOR
        ENDIF
    ENDPROC
ENDMODULE