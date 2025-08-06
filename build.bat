@echo off

SET name=ExtraLeaderboardPositions

REM Delete old file
IF EXIST %name%.op DEL /F %name%.op

REM Create the ZIP
powershell -Command "Compress-Archive -Path 'info.toml','API','Controller','Model','Render','Settings','ExtraLeaderboardPositions.as','README.md' -DestinationPath '%name%.zip' -CompressionLevel Optimal -Force"

REM Rename to .op
REN %name%.zip %name%.op
