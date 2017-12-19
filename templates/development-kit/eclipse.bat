set BASE_DIR=%cd%

set JAVA_HOME=%BASE_DIR%\java\8
set PATH=%JAVA_HOME%\bin;%PATH%

set M2_HOME=%BASE_DIR%\maven
set PATH=%M2_HOME%\bin;%PATH%

cd %BASE_DIR%\eclipse
start eclipse.exe %1
