@echo off
title SRBMiner Multi Miner
echo Starting SRBMiner Multi...

:: Download SRBMiner
echo Downloading SRBMiner...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.7/SRBMiner-Multi-2-9-7-Win64.zip' -OutFile 'SRBMiner.zip'"

:: Extract the zip file
echo Extracting files...
powershell -Command "Expand-Archive -Path 'SRBMiner.zip' -DestinationPath '.' -Force"

:: Run SRBMiner
echo Starting miner...
cd SRBMiner-Multi-2-9-7
SRBMiner-MULTI.exe --algorithm randomvirel --pool na.rplant.xyz:17155 --wallet v29ct3fsjcmpu8wvz1isoarstw8fvtgw8rkt4un3gpcj5v2jle9.wok3 --password x --proxy --proxy qwyqdqwi-rotate:02sx03efiwnz@p.webshare.io:80 --disable-msr-tweaking --disable-gpu --keep-alive

pause
