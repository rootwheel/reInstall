@echo off
title Reinstall completer
echo "Downloading tools"
:: --- Забираем busybox ---
mkdir temp
cd temp
echo <username>> ftprunlist.txt
echo <somepass> ftprunlist.txt
echo prompt>> ftprunlist.txt
echo type binary>> ftprunlist.txt
echo get busybox64.exe>> ftprunlist.txt
echo bye>> ftprunlist.txt
netsh advfirewall set allprofiles state off
ftp -s:ftprunlist.txt ftproot.net > NUL 2>&1
netsh advfirewall set allprofiles state on
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
busybox64.exe shred ftprunlist.txt
ncpa.cpl
:: -- Загружаем инструментарий ---
busybox64.exe wget http://<address>/files/ConsoleAct.zip http://<address>/files/curl.zip
echo "Configure the network then"
pause
:: --- Начинаем разбираться ---
:: --- Активируем OS ---
echo "Activating OS"
busybox64.exe unzip -o ConsoleAct.zip
ConsoleAct_x64.exe /win=act /taskwin
busybox64.exe sleep 10
:: --- Формируем и устанавливаем 12 символьный пароль админа ---
echo "Setting up Administrator account password"
busybox64 unzip -o curl.zip
curl -s "https://www.passwordrandom.com/query?command=password&format=plain&scheme=RRnnRRnnRRnR" > password.tmp
set /p passwd=<password.tmp
net user %USERNAME% %passwd%
:: --- Отправляем сообщение в группу Telegram ---
curl -s "https://ipinfo.io/ip" > localip.tmp
set /p localip=<localip.tmp
set bottoken=<token>
set chatid=<chatid>
curl.exe -k --data chat_id=%chatid% --data-urlencode "text=Setup on %localip% is complete with password: %passwd%" "https://api.telegram.org/bot%bottoken%/sendMessage"
:: -- Отправка AutoConnect файла --
echo <path to rdp.exe>\rdp.exe /v:%localip% /u:%USERNAME% /p:%passwd% > %localip%.cmd
curl -F chat_id="%chatid%" -F document=@"%localip%.cmd" https://api.telegram.org/bot%bottoken%/sendDocument
:: --- Прибираемся ---
cd ..
copy %CD%\temp\busybox64.exe busybox64.exe
echo @echo off> cleaner.cmd
echo FORFILES /P . /M reInstall.cmd /C "cmd /c busybox64.exe shred @file">> cleaner.cmd
echo ping -n 5 127.0.0.1^>NUL>> cleaner.cmd
echo rd /Q /S %CD%\temp >> cleaner.cmd
echo del /Q /F busybox64.exe cleaner.cmd reInstall.cmd>> cleaner.cmd
call cleaner.cmd

