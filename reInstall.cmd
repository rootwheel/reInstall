@echo off
title Reinstall completer
echo "Downloading tools"
:: --- Забираем YourFTPUser ---
mkdir temp
cd temp
echo YourFTPUser> ftprunlist.txt
echo YourFTPPass>> ftprunlist.txt
echo prompt>> ftprunlist.txt
echo type binary>> ftprunlist.txt
echo get YourFTPUser64.exe>> ftprunlist.txt
echo bye>> ftprunlist.txt
echo "Disabling firewall"
netsh advfirewall set allprofiles state off
ftp -s:ftprunlist.txt ftpdomain.ru > NUL 2>&1
echo "Enabling firewall"
netsh advfirewall set allprofiles state on
echo "Adding ICMP rule"
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
YourFTPUser64.exe shred ftprunlist.txt
ncpa.cpl
:: -- Загружаем инструментарий ---
YourFTPUser64.exe wget http://domain.ru/files/ConsoleAct.zip http://domain.ru/files/curl.zip
echo "Check network configuration (ip, gateway, etc)"
pause
:: --- Начинаем разбираться ---
:: --- Активируем OS ---
echo "Activating OS"
YourFTPUser64.exe unzip -o ConsoleAct.zip
ConsoleAct_x64.exe /win=act /taskwin
YourFTPUser64.exe sleep 10
:: --- Формируем и устанавливаем 12 символьный пароль админа ---
echo "Setting up Administrator account password"
YourFTPUser64 unzip -o curl.zip
curl -s "https://www.passwordrandom.com/query?command=password&format=plain&scheme=RRnnRRnnRRnR" > password.tmp
set /p passwd=<password.tmp
net user %USERNAME% %passwd%
:: --- Отправляем сообщение в группу Telegram ---
curl -s "https://ipinfo.io/ip" > localip.tmp
set /p localip=<localip.tmp
set bottoken=YourBotToken
set chatid=YourChatID
curl.exe -k --data chat_id=%chatid% --data-urlencode "text=Setup on %localip% is complete with password: %passwd%" "https://api.telegram.org/bot%bottoken%/sendMessage"
:: -- Отправка AutoConnect файла --
echo e:\ScriptsRepo\reInstallRemastered\rdp.exe /v:%localip% /u:%USERNAME% /p:%passwd% > %localip%.cmd
curl -F chat_id="%chatid%" -F document=@"%localip%.cmd" https://api.telegram.org/bot%bottoken%/sendDocument
:: --- Прибираемся ---
cd ..
copy %CD%\temp\YourFTPUser64.exe YourFTPUser64.exe
echo @echo off> cleaner.cmd
echo FORFILES /P . /M reInstall.cmd /C "cmd /c YourFTPUser64.exe shred @file">> cleaner.cmd
echo ping -n 5 127.0.0.1^>NUL>> cleaner.cmd
echo rd /Q /S %CD%\temp >> cleaner.cmd
echo del /Q /F YourFTPUser64.exe cleaner.cmd reInstall.cmd>> cleaner.cmd
call cleaner.cmd

