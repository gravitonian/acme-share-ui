@ECHO OFF

SET COMPOSE_FILE_PATH=%CD%\target\classes\docker\docker-compose.yml

IF [%M2_HOME%]==[] (
    SET MVN_EXEC=mvn -DextensionProjectActivation
)

IF NOT [%M2_HOME%]==[] (
    SET MVN_EXEC=%M2_HOME%\bin\mvn -DextensionProjectActivation
)

IF [%1]==[] (
    echo "Usage: %0 {build_start|start|stop|purge|tail|reload_share|build_test|test}"
    GOTO END
)

IF %1==build_start (
    CALL :down
    CALL :build
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==start (
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==stop (
    CALL :down
    GOTO END
)
IF %1==purge (
    CALL:down
    CALL:purge
    GOTO END
)
IF %1==tail (
    CALL :tail
    GOTO END
)
IF %1==reload_share (
    CALL :build_share
    CALL :start_share
    CALL :tail
    GOTO END
)
echo "Usage: %0 {build_start|start|stop|purge|tail|reload_share}"
:END
EXIT /B %ERRORLEVEL%

:start
    docker volume create acme-share-ui-acs-volume
    docker volume create acme-share-ui-db-volume
    docker volume create acme-share-ui-ass-volume
    docker-compose -f "%COMPOSE_FILE_PATH%" up --build -d
EXIT /B 0
:start_share
    docker-compose -f "%COMPOSE_FILE_PATH%" up --build -d acme-share-ui-share
EXIT /B 0
:down
    if exist "%COMPOSE_FILE_PATH%" (
        docker-compose -f "%COMPOSE_FILE_PATH%" down
    )
EXIT /B 0
:build
	call %MVN_EXEC% clean package
EXIT /B 0
:build_share
    docker-compose -f "%COMPOSE_FILE_PATH%" kill acme-share-ui-share
    docker-compose -f "%COMPOSE_FILE_PATH%" rm -f acme-share-ui-share
	call %MVN_EXEC% clean package
EXIT /B 0
:tail
    docker-compose -f "%COMPOSE_FILE_PATH%" logs -f
EXIT /B 0
:tail_all
    docker-compose -f "%COMPOSE_FILE_PATH%" logs --tail="all"
EXIT /B 0
:purge
    docker volume rm -f acme-share-ui-acs-volume
    docker volume rm -f acme-share-ui-db-volume
    docker volume rm -f acme-share-ui-ass-volume
EXIT /B 0