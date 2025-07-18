;Preme For Windows keys 0.995 by jai_magical        25 January 2016

#SingleInstance off	;not force replace old instance like a reload.
#NoTrayIcon   ; #NoTrayIcon is better than menu, tray, noicon because it will not appear at all. compiled
#NoEnv
#KeyHistory 0
; if not A_IsAdmin
	; Gosub, closeSameNameMethod	;new09

	
;001 first variable  EDIT HERE		
versionNum = 0.995		; DetectProblemVer
warningDate = 30201220000000
expiredDate = 30201230000000
releaseDate = 20171216000000
expiredDateStr = 30 December 3020
releaseDateStr = 16 December 2017
;beta=1

;IfExist, %A_AppData%\premeUpdate.exe
;			FileDelete, %A_AppData%\premeUpdate.exe


;002 read its address
programfiledir = %ProgramFiles%\Preme for Windows
bindir = %A_AppData%\Preme for Windows\bin



;if it's in the bin dir and it's name is premeeng.exe
if( (InStr(A_ScriptDir, bindir)&&(A_ScriptName == "premeeng.exe")) )	;|| !A_IsCompiled
{
	
	parameter1 = %1%
	if(parameter1 == "getClassFromActive")		;At UI
	{
		Goto writeActiveClassFunc		;line 8617
		return
	}
	
	;if it expires, stop working.
	;FileGetTime, TodayTime, C:\Windows\bootstat.dat, M
	;if(TodayTime>expiredDate) ;the real expire date will be 25 May which the 15 is the warning date.
	;	ExitApp		;1 exception
	
	;numpara should be an eryption with date for security.
	Process, priority, , High  
	
	varForRunPremeExe = 0
	;numPara0 = %0%    ;The number of parameter 
	;numPara1 = %1%	;param1
	if(parameter1 == "UI" || WinExist("ahk_exe PremeInterface.exe"))
	{
		Gosub, startForceButtonListener
	}
	else
	{
		Gosub, startButtonListener

	}
	Gosub, closeSameNameMethod
	return
}  ;if(A_ScriptDir == bindir)&&(A_ScriptName == "preme.exe")

;premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe 
;premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe 
;premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe premeeng.exe 












;003 if it is in startup folder or programfiles folder or appdata/bindir and the name is preme.exe 
else if((( InStr(A_ScriptDir, programfiledir) || InStr(A_ScriptDir, A_Startup) || InStr(A_ScriptDir, bindir) )&&(A_ScriptName == "preme.exe")) || !A_IsCompiled)
{
	;if dpiV == 0, normal PC, if = 1, 125%, 2=150%
	RegRead, dpivalue, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI  ;96, 120 and 144
	dpiV := Round((dpivalue - 96)/24)
	if(dpiV == "" || dpiV == "ERROR")
		dpiV := 0
	
	;detect expire date first
	FileGetTime, TodayTime, C:\Windows\bootstat.dat, M
	if(TodayTime>expiredDate)
	{
		Gosub, noButtonListener		;important
		Goto, smallUpdateWin
		Loop,{
			sleep, 500
			IfWinNotExist, smallUpdate ahk_class PremeforWin
			{		
				Break
			}
		}
		ExitApp
	}
	else if(TodayTime>warningDate) ;the real expire date will be 25 May which the 15 is the warning date.
	{
		Gosub, noButtonListener		;important
		Gosub, smallUpdateWin
		Loop,{
			sleep, 500
			IfWinNotExist, smallUpdate ahk_class PremeforWin
			{		
				Break
			}
		}
	}    ;End of autoupdate
	
	
	if (InStr(A_ScriptDir, bindir) || !A_IsCompiled)
	{
		Gosub, closeSameNameMethod
		
		Process, priority, , High 
		; RegRead, verScrollValue, HKEY_CURRENT_USER, Control Panel\Desktop, WheelScrollLines
		; RegRead, horScrollValue, HKEY_CURRENT_USER, Control Panel\Desktop, WheelScrollChars

		
		Process, Exist, SnippingTool.exe
		processidsnippingtool := ErrorLevel
		
		
		;get the number of param and do
		numPara0 = %0%      ;It's the number of Parameter. 0 is Taskscheduler, 1 is from Tskscheduler, 2 is new install, 3 is from user click other file
		numPara1 = %1%		;4,5 is reload with/without error.
		numPara2 = %2%
		
		;Everytime it start at startup, check searchindexer.exe and check for update silently. There will be numPara1 == "startup" again.
		if (numPara0 == 1 && (numPara1 == "startup" || numPara1 == "startupfolder"))
		{
			if(GetKeyState("Shift"))
			{
				Tooltip, Preme for Windows is turned off by holding shift key.
				sleep, 4000
				Tooltip,
				ExitApp
			}
		
			TC := A_TickCount
			Loop, {
				Process, Exist, searchindexer.exe
				if((ErrorLevel!=0 && WinExist("ahk_class Shell_TrayWnd")) || (A_TickCount-TC) > 20000)    ;via TaskScheduler(numPara0==1)
				{
					; temp := A_TickCount-TC
					; Msgbox, loop%temp%
					Break
				}
				sleep, 500
			}
			;Check for update silently. The silent update will operate in the second startup from the day mod in 5 equals 0.
			
			FileGetTime, TodayTime3, C:\Windows\bootstat.dat, M
			IniRead, UpdateSilentlyR, %A_AppData%\Preme for Windows\premedata.ini, section1, UpdateSilentlyINI, 1
			IniRead, UDcheckDateR, %A_AppData%\Preme for Windows\premedata.ini, section1, UDcheckDateINI, 0
			;A it's close to warning date for 10 days, B the day mod5 = 0, C TodayTime3!=UDcheckDateR
			;D Today > UD for 5 days, E Today-UD<50, F Today-UD>70		The need of month(50and70)        201-130=71
			;if(A||( (D&&E) || F)
			;d1 := TodayTime3-UDcheckDateR
			;MsgBox, d1 = %d1% todayTime = %TodayTime3% UD = %UDcheckDateR%
			if(UpdateSilentlyR != 0 && (TodayTime3 > warningDate - 10000000 || TodayTime3>=UDcheckDateR))	; && numPara0 == 0
			{
				;Msgbox, 5 is good. 2
				if A_IsAdmin
				{
					FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeUpdateSilentlyHigh.xml, %A_AppData%\Preme for Windows\PremeUpdateSilently.xml, 1
					run, %comspec% /c schtasks /create /tn "PremeUpdateSilently" /xml "%A_AppData%\Preme for Windows\PremeUpdateSilently.xml" /F,, Hide
					;sleep, 1000
					;run, %comspec% /c schtasks /run /tn "PremeUpdateSilently",, 	;Hide	;When "Hide" this command window, it won't work. Creating task is for the next startup.
				}
				else
				{
					IfNotExist, %A_AppData%\Preme for Windows\bin\prememanage.exe
						FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\prememanage.exe, 1
					run, %A_AppData%\Preme for Windows\bin\prememanage.exe updatesilentlyplease
				}
				Random, dayPlus, 0, 4
				tempTW := mod(Floor(TodayTime3/1000000),100) - mod(mod(Floor(TodayTime3/1000000),100),5) + 5 + dayPlus
				dateWrite := ( ((Floor(TodayTime3/100000000)+Floor(tempTW/31))*100) + mod(tempTW,31) + Floor(tempTW/31) )*1000000	;ignore the new year.
				IniWrite, %dateWrite%, %A_AppData%\Preme for Windows\premedata.ini, section1, UDcheckDateINI
			}
			
			IfExist, %A_AppData%\premeUpdateExpress.exe
				FileDelete, %A_AppData%\premeUpdateExpress.exe
		}
		

		;The same in StartButton Listener
		if(SubStr(A_OSVersion,1,3) == "10.")
			winver := 2
		else if InStr(A_OSVersion, "WIN_8")
			winver := 1
		else 		;if InStr(A_OSVersion, "WIN_7")
			winver := 0
		
		IniRead, winverR, %A_AppData%\Preme for Windows\premedata.ini, section1, winverINI, -1
		if(winverR != 2 || winverR!= 1 || winverR!= 0)
			IniWrite, %winver%, %A_AppData%\Preme for Windows\premedata.ini, section1, winverINI
			;IniWrite For Preme Interface

		
		;initiate values of Min,Max,Close position
		if(winver == 2)	;Windows 10
		{
			if(dpiV == 0)		;100%
			{
				leftmin := -147
				leftmax := -100
				leftclose := -54
				underminmaxcloseMain := 31
				pointup := -27
			}
			else if(dpiV == 1)	;125%
			{
				leftmin := -187
				leftmax := -127
				leftclose := -68
				underminmaxcloseMain := 38
				pointup := -32
			}
			else				; >150%
			{
				leftmin := -222
				leftmax := -151
				leftclose := -81
				underminmaxcloseMain := 45
				pointup := -39				;win7&8 has its own
			}
			touchSlideXvar := 17
			touchSlideYvar := 16
			touchSlideXoutVar := 1
			touchSlideYoutVar := 9
		}
		else	;Windows 7,8
		{
			;These 3 var are the 1st left pixel of the button, the last is under the button(out of button area)
			leftmin := -111+4*winver-dpiV*(26-winver)
			leftmax := -82+3*winver-dpiV*(19-winver)
			leftclose := -55+2*winver-dpiV*(13-winver)
			underminmaxcloseMain := 21+1*winver+dpiV*(5+2*winver)
			touchSlideXvar := 5
			touchSlideYvar := 6
			touchSlideXoutVar := 7
			touchSlideYoutVar := 7
		}
		
		
		
		
		
		;tray icon management
		IniRead, hidetrayIconBit, %A_AppData%\Preme for Windows\premedata.ini, section1, HideTrayIcon, 0
		if (hidetrayIconBit != 1)
		{
			if(dpiV == 2)
			{
				IfNotExist, %A_AppData%\Preme for Windows\Untitled-23big.ico
					FileInstall, C:\Users\YourName\Desktop\Preme\compressed\Untitled-23big.ico, %A_AppData%\Preme for Windows\Untitled-23big.ico, 1
				menu, tray, Icon, %A_AppData%\Preme for Windows\Untitled-23big.ico
			}
			else if(dpiV == 1)
			{
				IfNotExist, %A_AppData%\Preme for Windows\Untitled-23big.ico
					FileInstall, C:\Users\YourName\Desktop\Preme\compressed\Untitled-23big.ico, %A_AppData%\Preme for Windows\Untitled-23big.ico, 1
				menu, tray, Icon, %A_AppData%\Preme for Windows\Untitled-23big.ico
			}
			else ;96
			{
				IfNotExist, %A_AppData%\Preme for Windows\Untitled-32.ico
					FileInstall, C:\Users\YourName\Desktop\Preme\compressed\Untitled-32.ico, %A_AppData%\Preme for Windows\Untitled-32.ico, 1
				menu, tray, Icon, %A_AppData%\Preme for Windows\Untitled-32.ico	
			}
			
			
			IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, section1, HideTrayIcon	;For being sure.
			menu, tray, Icon		
		}

		menu, tray, add, Close app, Pclose
		menu, tray, add, Quick, SmallPremeGUI
		menu, tray, add, Settings, Poption
		menu, Tray, Click, 1
		menu, Tray, Default, Quick
				menu, tray, Tip , Preme for Windows (%versionNum%) 
		if(A_IsCompiled)
			menu, tray, Nostandard
	
		
		;003e if there is ini file, normal using.
		IniRead, versionDate, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateINI, -1
		IniRead, appstate, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate, 0
		
		;003f if there is NO ini file, after installing.
		if (versionDate == -1)
		{
			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\premedata.ini, %A_AppData%\Preme for Windows\premedata.ini, 1	
			IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate		;0 is off, other is on
			IniWrite, %versionNum%, %A_AppData%\Preme for Windows\premedata.ini, section1, versionNumINI
			IniWrite, %releaseDate%, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateINI
			IniWrite, %releaseDate%, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateDurableINI
			lastStr := "An application made for speeding up you window switching`nExpired:		" . expiredDateStr
			lastStr .= "`nCompiled:	" . releaseDateStr . "`n`nYou can comment to the facebook page. Although I have no time, I try to read them all.`n`n"
			lastStr .= "Preme for Windows is designed for using Windows faster. When you move the pointer to the small specific "
			lastStr .= "area to switch windows, it's the effort. With these features, you will feel faster by less aiming and less switching. "
			lastStr .= "Preme for Windows is compiled by Autohotkey. It's fast and tiny."
			lastStr .= "`n`njai_magical"
			;Search aboutText to edit these duplicated Text************************************
			FileDelete, %A_AppData%\Preme for Windows\aboutText.txt
			FileAppend , %lastStr%, %A_AppData%\Preme for Windows\aboutText.txt
			if (A_PtrSize = 8)
				IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, section1, version64INI
			else
				IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, section1, version64INI
				
			
			Gosub, MainPremeInterface
			return
		}
		;if there is 2 param, new install(show GUI too.) Else, show GUI only.
		else if (numPara1 == "showGUI")
		{
			;new install(new version then there is some var that must be assigned.)
			if(numPara0 == 2 && (numPara2 == "startupInstall" || numPara2 == "programfilesInstall"))    
			{
				
				; IniRead, hotkeywithoutreloadR, %A_AppData%\Preme for Windows\premedata.ini, section1, hotkeywithoutreloadINI
				; if(hotkeywithoutreloadR == "ERROR")
					; IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, section1, hotkeywithoutreloadINI
				
				TrayTip, Preme for Windows, Installation Completed., , 1  ;1 is info, 2 is Warning, 3 is error.	
			}
			Gosub, MainPremeInterface
			return	
		}
		;if it's run from startup folder, if no preme is running, run without showing. If there is preme running, show GUI.
		else if(numPara1 == "startupfolder")
		{
			Gosub, readWinKeepPosMethod	;id, size and position of sliding window.
			if (hidetrayIconBit != 1)
			{
				if(A_IsCompiled)
					Gosub, reloadpremeengMethod		;with write premestate = 1 	,0 is off, other is on
			}
			else
			{
				Gosub, MainPremeInterface
			}
			return
		}
		else if(numPara1 == "startup")	;from tsksch "PremeStartup.xml"
		{
			IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch1INI
			IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch3INI
			IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch5INI
			IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch6INI
			Gosub, reloadpremeengMethod		;with write premestate = 1 	,0 is off, other is on
			return
		}
		else if(numPara1 == "logon")
		{
			if(appstate == 0)		;preme is closed, 1 is on, -1 is disable
			{
				Process, Close, premeeng.exe
				RefreshTray()
				ExitApp		;2nd exception
			}
			else if (appstate == 1)
			{
				Gosub, readWinKeepPosMethod	;id, size and position of sliding window.
				Gosub, reloadpremeengMethod		;with write premestate = 1 	,0 is off, other is on
			}
			else ;if (appstate == -1)
			{
				Gosub, noButtonListener		;important
				Gosub, readWinKeepPosMethod	;id, size and position of sliding window.
				RefreshTray()
				;Do s'th if there is.
			}
			
			return
		}
		else if !A_IsCompiled
		{
			
			Gosub, readWinKeepPosMethod		;id, size and position of sliding window.
			Gosub, engineWithINI
			Gosub, startButtonListener
			Gosub, buildSmallPremeGUI
			
			; Hotkey, vk9e, wheelDownButton
			; Hotkey, vk9f, wheelUpButton
			; Hotkey, +vk9e, wheelDownWithShift
			; Hotkey, +vk9f, wheelUpWithShift
			; Gui, +owner -0x800000
			; Gui, Show, x-10000 y-10000 h w Hide, blankWinForPreme
			;more with hotkey function. All insides one process.
			return
		}
		else ;numpara0 == 0
		{
			;if(A_IsCompiled)
			Gosub, readWinKeepPosMethod	;id, size and position of sliding window.
			Gosub, reloadpremeengMethod		;with write premestate = 1 	,0 is off, other is on
			
			return
		}
		
		return
		
	}
	;if (A_ScriptDir == bindir)
	
	
	
	
	
	;003a if it is in startup folder
	else if InStr(A_ScriptDir, A_Startup)	; || !A_IsCompiled
	{
		
		;In startup type, it is different from another that
		;exitapp if there is preme.exe in programfile dir
		;Show tray icon if startup windows is exist.
		Gosub, noButtonListener		;important
		if(A_IsCompiled)
			IfExist, %ProgramFiles%\Preme for Windows\preme.exe
				Exitapp		;3 exception
		
	
		;run /bin/preme.exe
		IfNotExist, %A_AppData%\Preme for Windows\bin\preme.exe
			FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\preme.exe, 1
		run, %A_AppData%\Preme for Windows\bin\preme.exe startupfolder
		ExitApp		;4 exception
	
	}



;the number of param, 0 is user clicking, 1 task scheduler, 2 after install, 3 from startup or programfiles, 4 reload, 5 error and reload.




	;003b else if it is in Program files folder
	else if (InStr(A_ScriptDir, programfiledir) || !A_IsCompiled)         
	{
		Gosub, noButtonListener		;important
		;menu, tray, NoIcon
		if not A_IsAdmin
		{
			DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
			ExitApp		;6 exception
		}
		
		
		;run bin/preme.exe
		IfNotExist, %A_AppData%\Preme for Windows\bin\preme.exe
			FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\preme.exe, 1
		run, %A_AppData%\Preme for Windows\bin\preme.exe showGUI programfile
		ExitApp		;7 exception
	}
	;END 004 else if it is in Program files folder
	

	
	
} ;END OF if preme.exe is in appdata\bin folder or startup folder or in programfile folder.


;for uninstall and silent update.(It's not in about window or running from user.)
else if(InStr(A_ScriptDir, bindir) && (A_ScriptName == "prememanage.exe" || A_ScriptName == "PremeManage.exe"))
{
	
	Gosub, closeSameNameMethod
	Gosub, noButtonListener		;important
	numPara0 = %0%
	para1 = %1%
	if((numPara0 == 1) && (para1 == "uninstall"))
	{
		MsgBox, 292, Preme for Windows, Uninstall ?   ;4+32+256(256 Makes the 2nd button the default)
		IfMsgBox Yes
		{
			DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "uninstallplease" , str, A_WorkingDir, int, 1)
			ExitApp		;8 exception
		}
		else
		{
			MsgBox, 292, Preme for Windows, Repair ?
			IfMsgBox Yes
				DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "repairplease" , str, A_WorkingDir, int, 1)
			ExitApp		;8 exception
		}
	}
	else if(para1 == "uninstallplease")
	{
		
		IfExist, %ProgramFiles%\Preme for Windows\preme.exe
		{
			if not A_IsAdmin
			{
				DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "uninstallplease" , str, A_WorkingDir, int, 1)
				ExitApp		;8 exception
			}
		}

		IniWrite, 00000000, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateINI
		sleep, 300	;with for preme.exe finishs closing itself in case it calls from main UI. 
		
		DetectHiddenWindows, On
		PostMessage, 0x5556, 90, 99,, ahk_class PremeforWin	;close preme.exe
		sleep, 200
		
		Process, Close, premeeng.exe
		Process, Close, preme.exe
		
		MsgBox, 64, Preme for Windows, Uninstalling is successful.

		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows,
		RegDelete, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903},
		RegDelete, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D1558C01-990A-45F9-8273-D34E3B11B903},

		run, %comspec% /c schtasks /delete /tn "PremeStartup" /F,, Hide
		run, %comspec% /c schtasks /delete /tn "PremeLogonStart" /F,, Hide
		run, %comspec% /c schtasks /delete /tn "PremeUpdateSilently" /F,, Hide
		
		;delete programfiles folder, preme.exe in startup, preme.exe and PremeEng in bin folder.
		SplitPath, ProgramFiles,,,,, driveSys 
		FileRemoveDir, %driveSys%\Program Files (x86)\Preme for Windows, 1
		run, %comspec% /c rmdir "%programfiles%\preme for windows" /s /q,, Hide
		run, %comspec% /c del "%A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\preme.exe" /s /q,, Hide
		FileDelete, %A_AppData%\Preme for Windows\bin\preme.exe
		FileDelete, %A_AppData%\Preme for Windows\bin\premeeng.exe
		
		ExitApp		;10 exception

		
	}
	
	else if(para1 == "repairplease")
	{
		IfExist, %ProgramFiles%\Preme for Windows\preme.exe
		{
			if not A_IsAdmin
			{
				;menu, tray, NoIcon
				DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "uninstallplease" , str, A_WorkingDir, int, 1)
				ExitApp		;8 exception
			}
		}
		
		if(numPara0 > 1)
		{
		MsgBox, 292, Preme for Windows, Repair?   ;36+256(Makes the 2nd button the default )
		IfMsgBox No
			ExitApp		;9.5 exception
		}
		
		FileCreateDir, %A_AppData%\Preme for Windows
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeSplashScreen.jpg, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, 1
		SplashImage, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, b  ;param B is borderless
		Gosub, PremeChangeConfig		;except PremeManage.exe
		Gosub, installGeneralFileMethod
		
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeStartup.xml, %A_AppData%\Preme for Windows\PremeStartup.xml, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeLogonStart.xml, %A_AppData%\Preme for Windows\PremeLogonStart.xml, 1						
		run, %comspec% /c schtasks /create /tn "PremeStartup" /xml "%A_AppData%\Preme for Windows\PremeStartup.xml" /F,, Hide
		run, %comspec% /c schtasks /create /tn "PremeLogonStart" /xml "%A_AppData%\Preme for Windows\PremeLogonStart.xml" /F,, Hide
		
		IfExist, %ProgramFiles%\Preme for Windows\preme.exe
		{
			FileCreateDir, %ProgramFiles%\Preme for Windows
			FileCopy, %A_ScriptFullPath%, %ProgramFiles%\Preme for Windows\preme.exe, 1
		}
		else
			FileCopy, %A_ScriptFullPath%, %A_Startup%\preme.exe, 1

		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\preme.exe, 1
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\premeeng.exe, 1
		
		
		sleep, 1500		;its swaping SplashScreen is too fast.
		Run, %A_AppData%\Preme for Windows\bin\preme.exe showGUI	;no need checking
		ExitApp
	}
	
	else if((numPara0 == 1) && (para1 == "updatesilentlyplease"))
	{
		Process, Exist, avp.exe
		;if Kaspersky is running on this PC, delete update silently scheduler.
		if(ErrorLevel!=0)
		{
			;delete scheduler and ExitApp
			;Msgbox, fail1 %ErrorLevel%
			run, %comspec% /c schtasks /delete /tn "PremeUpdateSilently" /F,, Hide
			ExitApp		;11 exception
		}
		
		sleep, 15000
		IfExist, %A_Startup%\preme.exe
			sleep, 5000	;sleep long time because internet still may not be started.
		
		RegRead, firewall_status, HKEY_LOCAL_MACHINE, SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List, %ProgramFiles%\Preme for Windows\preme.exe
		If (!InStr(firewall_status, "Enabled") && A_IsAdmin!=0)
		{
			RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List, %A_AppData%\Preme for Windows\bin\prememanage.exe, %A_AppData%\Preme for Windows\bin\prememanage.exe:*:Enabled:Preme for Windows
			if(ErrorLevel!=0)
			{
				;fail, don't do
				;Msgbox, fail2 %ErrorLevel%
				run, %comspec% /c schtasks /delete /tn "PremeUpdateSilently" /F,, Hide
				ExitApp		;12 exception
			}
		}
		
		UrlDownloadToFile, https://s3-ap-northeast-1.amazonaws.com/premeudcheck/updateFile.txt, %a_appdata%\Preme for Windows\update
		;if the internet connection is fail, exitapp.
		if(ErrorLevel != 0)
			ExitApp		;13 exception
			
		
		;Internet connection is available when reading code to here.
		
		;Video updation
		FileReadLine, updateVideoDate, %A_AppData%\Preme for Windows\update, 8    ;updateVideo date format is YYYYMMDD
		IniRead, versionVideoNum, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateVideoINI, 0
		if(updateVideoDate>versionVideoNum)
		{
			FileReadLine, checkPremeVideoSize, %A_AppData%\Preme for Windows\update, 9
			FileReadLine, updateVideoLink, %A_AppData%\Preme for Windows\update, 10
			UrlDownloadToFile, %updateVideoLink%, %A_AppData%\Preme for Windows\premeMedia.exe
			sleep, 100
			FileGetSize, premeVideoSize, %A_AppData%\Preme for Windows\premeMedia.exe
			if(ErrorLevel == 0)&&(checkPremeVideoSize == premeVideoSize)
			{
				UrlDownloadToFile, http://bit.ly/zPremeVideo3, %a_appdata%\Preme for Windows\z_aboutcount
				Run, %A_AppData%\Preme for Windows\premeMedia.exe
			}
			else
			{
				sleep, 10000
				FileReadLine, updateVideoLink, %A_AppData%\Preme for Windows\update, 11
				UrlDownloadToFile, %updateVideoLink%, %A_AppData%\Preme for Windows\premeMedia.exe
				sleep, 100
				FileGetSize, premeVideoSize, %A_AppData%\Preme for Windows\premeMedia.exe
				if(ErrorLevel == 0)&&(checkPremeVideoSize == premeVideoSize)
				{
					UrlDownloadToFile, http://bit.ly/zPremeVideo3, %a_appdata%\Preme for Windows\z_aboutcount
					Run, %A_AppData%\Preme for Windows\premeMedia.exe
				}
				else
					ExitApp
			}
		}	;if Videos are to be updated.
		
		;Main updation
		FileReadLine, updateDate, %A_AppData%\Preme for Windows\update, 1    ;update date format is YYYYMMDD
		if(updateDate>releaseDate || (A_PtrSize = 4 && A_Is64bitOS && updateDate >= releaseDate))	;A_PtrSize=4 is 32 bit Preme version. This line for upgrading to 64 too.
		{
			if(updateDate>releaseDate)
				UrlDownloadToFile, http://bit.ly/premeUpgrade3, %a_appdata%\Preme for Windows\z_premeupgrade
			else
				UrlDownloadToFile, http://bit.ly/preme64upgrade3, %a_appdata%\Preme for Windows\z_premeupgrade

			if (A_Is64bitOS)
			{
				FileReadLine, checksize, %A_AppData%\Preme for Windows\update, 5
				FileReadLine, updateLink, %A_AppData%\Preme for Windows\update, 6	;64 bit
			}
			else
			{
				FileReadLine, checksize, %A_AppData%\Preme for Windows\update, 3	
				FileReadLine, updateLink, %A_AppData%\Preme for Windows\update, 4	;32 bit
			}
			UrlDownloadToFile, %updateLink%, %A_AppData%\premeUpdateExpress.exe
			sleep, 100
			FileGetSize, premeUpdateSize, %A_AppData%\premeUpdateExpress.exe
			if(ErrorLevel!=0)||(checksize!=premeUpdateSize)
			{
				;Update fail, because download fails.
				ExitApp		;14 exception
			}
			else      ;if download success
			{
				UrlDownloadToFile, http://bit.ly/silentcount3, %a_appdata%\Preme for Windows\z_silentcount
				RegDelete, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903},
				RegDelete, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D1558C01-990A-45F9-8273-D34E3B11B903},
				Run, %A_AppData%\premeUpdateExpress.exe expresswayupdate		;no need checking
				Run, %comspec% /c schtasks /delete /tn "PremeUpdateSilently" /F,, Hide
				ExitApp		;15 exception
			}
		}
		else
		{
			;no update available, delete task
			UrlDownloadToFile, http://bit.ly/silentcount3, %a_appdata%\Preme for Windows\z_silentcount
			Run, %comspec% /c schtasks /delete /tn "PremeUpdateSilently" /F,, Hide
			ExitApp		;16 exception
		}			
		
		ExitApp		;17 exception
	}
	
	else
	{
		Tooltip, This file is not allowed to run by click.
		;Msgbox, 64, Preme for Windows, This file is not allowed for user clicking.
		sleep, 3000
		ExitApp		;18 exception
		
	}
	ExitApp
}



;premeUpdateExpress.exe is from silent update only.
else if(A_ScriptName == "premeUpdateExpress.exe")
{
	;menu, tray, NoIcon   ;there is noicon at the begin of script
	Gosub, closeSameNameMethod
	Gosub, noButtonListener		;important
	;FormatTime, TodayTime2,, yyyyMMddHHmmss
	FileGetTime, TodayTime, C:\Windows\bootstat.dat, M
	if(TodayTime>warningDate)
	{
		MsgBox, 64, Preme for Windows, Preme for Windows(%versionNum%) is now out of date or your date may be set to be wrong. Please download current version at www.premeforwindows.com  `nError code: %TodayTime%%warningDate%%TodayTime2%
		Run www.premeforwindows.com
		ExitApp		;19 exception
	}    ;End of checking expire date.
	
	Process, Close, premeeng.exe
	Process, WaitClose, premeeng.exe, 1		;Just wait 1 seconds
	
	DetectHiddenWindows, On
	PostMessage, 0x5556, 90, 99,, ahk_class PremeforWin	;close preme.exe
	sleep, 300
	Process, Close, preme.exe			;Close old process
	Process, WaitClose, preme.exe, 2		;Just wait 2 seconds
	Process, Close, prememanage.exe
	
	Gosub, PremeChangeConfig
	FileDelete, %A_AppData%\Preme for Windows\bin\PremeManage.exe
	
	;install install install install install install install install install 
	Gosub, installGeneralFileMethod
	;install install install install install install install install install 

	if A_IsAdmin
	{
		if (A_PtrSize == 8)
			FileCopy, %A_ScriptFullPath%, %ProgramFiles%\Preme for Windows\preme.exe, 1
		else
		{
			SplitPath, ProgramFiles,,,,, driveSys 
			FileCopy, %A_ScriptFullPath%, %driveSys%\Program Files (x86)\Preme for Windows\preme.exe, 1
		}
	}
	else
	{
		FileCopy, %A_ScriptFullPath%, %A_Startup%\preme.exe, 1		
	}
	
	;new install(new version then there is some var that must be assigned.)

	
	FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\preme.exe, 1
	FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\premeeng.exe, 1
	FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\prememanage.exe, 1
	Run, %A_AppData%\Preme for Windows\bin\preme.exe start
	ExitApp		;20 exception
}  ;update express



else if((A_ScriptName == "Preme.exe" || A_ScriptName == "PremeEng.exe") && InStr(A_ScriptDir, bindir))	;old version
{
	Gosub, noButtonListener		;important
	Msgbox, 52, Preme for Windows, %A_ScriptName%, some problem occurs. Try?		;4+48
	IfMsgBox No
	{
		ExitApp		;X exception
	}
	else
	{
		FileDelete, %A_AppData%\Preme for Windows\PremeManage.exe
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\prememanage.exe, 1
		run, %A_AppData%\Preme for Windows\bin\prememanage.exe repairplease tryProblem
		ExitApp
	}
}

else if(A_ScriptName == "preme.exe")		;abnormal case(This preme.exe is not in bin folder.)
{
	;Copy itself to temp folder and run it. So preme.exe can install from anywhere.
	FileCopy, %A_ScriptFullPath%, %A_Temp%\premeinstall.exe, 1
	run, %A_Temp%\premeinstall.exe
	ExitApp
}








;004 else dir (to install)
else
{
	
	Gosub, closeSameNameMethod
	Gosub, noButtonListener			;important
	;FormatTime, TodayTime2,, yyyyMMddHHmmss
	FileGetTime, TodayTime, C:\Windows\bootstat.dat, M
	if(TodayTime>warningDate) ;the real expire date will be 25 May which the 15 is the warning date.
	{
		MsgBox, 64, Preme for Windows, Preme for Windows(%versionNum%) is now out of date or your date may be set to be wrong. Please download current version at www.premeforwindows.com  `nError code: %TodayTime%%warningDate%%TodayTime2%
		Run www.premeforwindows.com
		ExitApp		;21 exception
	}    ;End of checking expire date.
	
	
	;004e5 check OS.
	
	;if InStr(A_OSVersion, "WIN_XP") || InStr(A_OSVersion, "WIN_2003") || InStr(A_OSVersion, "WIN_2000")
	if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_XP,WIN_2003,WIN_2000
	{
		Msgbox, 64, Preme for Windows, Preme does not support the old versions of Windows. You have to use premeForXP version.
		Run http://sdrv.ms/premefile
		ExitApp
	}
	else if !InStr(A_OSVersion, "WIN_7") && !InStr(A_OSVersion, "WIN_8") && !InStr(A_OSVersion, "10.")
	{
		Msgbox, 292, Preme for Windows, This Windows (%A_OSVersion%) is not suit to Preme for Windows. Many features will not work properly. Continue?
		IfMsgBox No
			ExitApp
	}
	
	;PStartup := 0
	;Pprogramfile := 0
	IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, section1, HideTrayIcon
	
	;FileGetTime, fgtthisfile, %A_ScriptFullPath%, M	;Get time of this exe file
	;fgt = 1         ;Set to be 1, if it still 1, so it never install before.

	;004a if both path have, delete both. This is a conflict, no need Msgbox
	IfExist, %A_Startup%\preme.exe
	IfExist, %ProgramFiles%\Preme for Windows\preme.exe
	{
		FileDelete, %A_Startup%\preme.exe
		if not A_IsAdmin
			{
				DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
				;Run *RunAs "%A_ScriptFullPath%"
				ExitApp		;22 exception
			}
		FileRemoveDir, %ProgramFiles%\Preme for Windows, 1
		sleep, 200	
	}

	;004b 
	premeinstalled := 0
	premeinstalledstartup := 0
	premeinstalledprogramfile := 0
	
	IfExist, %A_AppData%\Preme for Windows\bin\preme.exe
		IfExist, %A_AppData%\Preme for Windows\bin\premeeng.exe
	{
		premeinstalled := 1
			
		IfExist, %A_Startup%\preme.exe
			premeinstalledstartup := 1

		IfExist, %ProgramFiles%\Preme for Windows\preme.exe
			premeinstalledprogramfile := 1
	}	
	
	
	;004d assign Pinstall if it will install or not.
	IniRead, versionDate, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateINI, -1
	if (versionDate == -1) || (premeinstalled == 0)    ;This PC never install Preme for Windows before.
	{
		Pinstall := 1
		DetectHiddenWindows, On
		PostMessage, 0x5556, 90, 99,, ahk_class PremeforWin	;close preme.exe
		sleep, 300
		Process, Close, preme.exe
		Process, Close, premeeng.exe
		IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, section1, UpdateSilentlyINI
		Gosub, PremeChangeConfig
		FileDelete, %A_AppData%\Preme for Windows\bin\PremeManage.exe
	}
	else if InStr(versionDate, releaseDate)
	{
		
		Pinstall := 0				;if it is the same file, do nothing and close itself
		Process, Exist, preme.exe		
		if(ErrorLevel!=0)      ;if other preme.exe is exist, ErrorLevel is set to process id.
		{
			;Msgbox, 48,Preme for Windows, Preme for Windows (%versionNum%) is now running. preme.exe is exist.   
			if(premeinstalledprogramfile==1)    ;if there is preme installed in programfiles and has no admin privilege, get it.
				if not A_IsAdmin
				{
					DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "eulaAgreed" , str, A_WorkingDir, int, 1)
					ExitApp		;23 exception
				}
			Run, %A_AppData%\Preme for Windows\bin\preme.exe showGUI otherFileWithSameversion  ;show GUI
			ExitApp		;24 exception
		}
		;preme.exe in programfiles will be run in 004f(else of Pinstall=0) No need msgbox here.
	}
	else if(releaseDate>versionDate)
	{
		if (premeinstalledstartup == 1)
		{
			;no need admin
		}
		else if not A_IsAdmin
		{
			DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
			ExitApp		;25 exception
		}
		;Terminate that process then delete old file and copy this file to startup folder
		if(A_ScriptName != "premeUpdate.exe")
			MsgBox, 48, Preme for Windows, Your old version will be removed automatically.
		
		IniRead, UpdateSilentlyR, %A_AppData%\Preme for Windows\premedata.ini, section1, UpdateSilentlyINI, 1
		;if(UpdateSilentlyR == "ERROR")||(UpdateSilentlyR == "")
		if(UpdateSilentlyR != 0)
			IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, section1, UpdateSilentlyINI
		
		DetectHiddenWindows, On
		PostMessage, 0x5556, 90, 99,, ahk_class PremeforWin	;close preme.exe
		sleep, 200
		
		Process, Close, premeeng.exe
		Process, WaitClose, premeeng.exe, 1		;Just wait 1 seconds
		Process, Close, preme.exe			;Close old process
		Process, WaitClose, preme.exe, 2		;Just wait 2 seconds
		Gosub, PremeChangeConfig
		FileDelete, %A_AppData%\Preme for Windows\bin\PremeManage.exe
		;FileDelete, %A_AppData%\Preme for Windows\premedata.ini
		Pinstall := 1
	}
	else      ;(releaseDate<versionDate)      if this is an older file, do nothing 
	{
		Msgbox, 48, Preme for Windows, This file is older than your version. The process will be closed.
		Pinstall := 0
		if(A_IsCompiled)
			ExitApp		;26 exception
	}
	;When Preme will be updated, update versionDate too.
	
	
	
	
	
	;004e if this computer is never install preme before. Install it.
	if(Pinstall)
	{
		
		;Detecting Kaspersky process
		Process, Exist, avp.exe
		;004e1 if this computer is running Kaspersky 
		if(ErrorLevel!=0)
		{
			Loop,
			{
				MsgBox, 48, Preme for Windows, Your Kaspersky does not allow normal executable file to copy exe files. Please close Kaspersky now. 
				sleep, 700
				Process, Exist, avp.exe
				if(ErrorLevel==0)
					break
				else
				{
					MsgBox, 37, Preme for Windows, You should close your Kaspersky first. Would you like to install "Preme for Windows?"
					ifMsgBox Cancel
						ExitApp		;27 exception
					else
						Continue
				}
			} ;Loop
			
		}   ;else detection Kaspersky
		
		
		
		
		
		

		IniRead, installinStartup, %A_AppData%\Preme for Windows\premedata.ini, section3, ErrforProgramFiles, 0
		;004e2 if the operation fails to install last time.
		if (installinStartup==1) || (premeinstalledstartup == 1)
		{
			if (versionDate < 1)  ;Never install before
			{
				Gosub, InstallationType
				sleep, 2000
				Loop,{
					sleep, 500
					IfWinNotExist, Preme_select_type_win
					{
						OnMessage(0x201, "")
						Break
					}
				}
			}
			else
			{
				FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeSplashScreen.jpg, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, 1
				SplashImage, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, b  ;param B is borderless
				FileCopy, %A_ScriptFullPath%, %A_Startup%\preme.exe, 1
				
			}
			IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, section3, ErrforProgramFiles
			
		}
		
		;004e3 if it's not admin privilege, ask user, If startup is choosen, go on startup. Else run again with admin privilege.
		else if not A_IsAdmin
		{
			Gosub, InstallationType
			sleep, 2000
			Loop,{
				sleep, 500
				IfWinNotExist, Preme_select_type_win
				{		
					Break
				}
			}
			
		}
		;004e4 else, install in program file with A_IsAdmin
		else   ;A_IsAdmin==1   select program file to be default
		{
			numPara0 = %0%
			para1 = %1%
			;Msgbox, numpara0 and para1 %numPara0% and %para1%
			;if there is 1 param and that param is eulaAgreed(run after user clicked agreed) or from premeupdate(autoupdate) 
			;or user downloaded and run for updating(versionDate > 1) then [don't run the installType window]
			if((numPara0 == 1) && (InStr(para1, "eulaAgreed") || InStr(para1, "premeupdate"))) || (versionDate > 1)
			{
				;do nothing				
			}		
			else
			{
				Gosub, InstallationType
				sleep, 2000
				Loop,{
					sleep, 500
					IfWinNotExist, Preme_select_type_win
					{		
						Break
					}
				}
			}
		
			FileCreateDir, %A_AppData%\Preme for Windows
			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeSplashScreen.jpg, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, 1
			SplashImage, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, b  ;param B is borderless

			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeStartup.xml, %A_AppData%\Preme for Windows\PremeStartup.xml, 1
			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeLogonStart.xml, %A_AppData%\Preme for Windows\PremeLogonStart.xml, 1						
			run, %comspec% /c schtasks /create /tn "PremeStartup" /xml "%A_AppData%\Preme for Windows\PremeStartup.xml" /F,, Hide
			run, %comspec% /c schtasks /create /tn "PremeLogonStart" /xml "%A_AppData%\Preme for Windows\PremeLogonStart.xml" /F,, Hide
			
			FileCreateDir, %ProgramFiles%\Preme for Windows
			FileCopy, %A_ScriptFullPath%, %ProgramFiles%\Preme for Windows\preme.exe, 1
			
		}
		
		;Install startup mode, after installing because of admin.
		if not A_IsAdmin 
		{
			FileCreateDir, %A_AppData%\Preme for Windows
			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeSplashScreen.jpg, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, 1
			SplashImage, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, b  ;param B is borderless
			
			FileCopy, %A_ScriptFullPath%, %A_Startup%\preme.exe, 1
		}
		
		
		
		
		;004e6 Install many files.
		FileCreateDir, %A_AppData%\Preme for Windows\bin
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\preme.exe, 1
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\premeeng.exe, 1
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\prememanage.exe, 1
		IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate
		
		;install install install install install install install install install 
		Gosub, installGeneralFileMethod
		;install install install install install install install install install 
		
		FileGetTime, TodayTime3, C:\Windows\bootstat.dat, M
		Random, dayPlus, 0, 4
		tempTW := mod(Floor(TodayTime3/1000000),100) - mod(mod(Floor(TodayTime3/1000000),100),5) + 5 + dayPlus
		dateWrite := ( ((Floor(TodayTime3/100000000)+Floor(tempTW/31))*100) + mod(tempTW,31) + Floor(tempTW/31) )*1000000	;ignore the new year.
		IniWrite, %dateWrite%, %A_AppData%\Preme for Windows\premedata.ini, section1, UDcheckDateINI
		
		sleep, 2000
		
		;SplashImage, Off
		
		
		
		;004e7 run the installed file and terminate itself.
		IfExist, %A_Startup%\preme.exe
		{
			;MsgBox, 64, Preme for Windows, Installation Completed
			Run, %A_AppData%\Preme for Windows\bin\preme.exe showGUI startupInstall
		}
		else IfExist, %ProgramFiles%\Preme for Windows\preme.exe
		{
			;IfNotExist, %A_AppData%\Preme for Windows\premeupdate.exe
			;MsgBox, 64, Preme for Windows, Installation Completed
			Run, %A_AppData%\Preme for Windows\bin\preme.exe showGUI programfilesInstall
		}
		else
		{
			;IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, section3, ErrforProgramFiles
			SplashImage, Off
			Msgbox, 16, Preme for Windows, Error! Please try again.
		}
		;SplashImage, Off
		
		ExitApp		;28 exception
		return
	}
	
	;004f else if Preme has been installed. Running for some purpose from any folder.
	else    ;if(!Pinstall)
	{
		;004f1 if not A_IsAdmin and there is preme in program files, call itself with admin privilege.
		if not A_IsAdmin
			IfExist, %ProgramFiles%\Preme for Windows\preme.exe
			{
				DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
				;Run *RunAs "%A_ScriptFullPath%"
				ExitApp		;29 exception
			}
		
		FileCreateDir, %A_AppData%\Preme for Windows
		;004f2 Show splashscreen, install many files.
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeSplashScreen.jpg, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, 1
		SplashImage, %A_AppData%\Preme for Windows\PremeSplashScreen.jpg, b  ;param B is borderless
		
		if !InStr(A_OSVersion, "WIN_7") && !InStr(A_OSVersion, "WIN_8") && !InStr(A_OSVersion, "10.")
		{
			SplashImage, Off
			Msgbox, 48, Preme for Windows, This OS (%A_OSVersion%)is not suit to Preme for Windows. Most features will not work properly.
			;ExitApp
		}
		
		FileCreateDir, %A_AppData%\Preme for Windows\bin
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\preme.exe, 1
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\premeeng.exe, 1
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\prememanage.exe, 1
		IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate
		
		;install install install install install install install install install 
		Gosub, installGeneralFileMethod
		;install install install install install install install install install 
		
		sleep, 2000
		SplashImage, Off
		
		
		IfExist, %ProgramFiles%\Preme for Windows\preme.exe
		{
			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeStartup.xml, %A_AppData%\Preme for Windows\PremeStartup.xml, 1
			FileInstall, C:\Users\YourName\Desktop\Preme\compressed\PremeLogonStart.xml, %A_AppData%\Preme for Windows\PremeLogonStart.xml, 1
			
			run, %comspec% /c schtasks /create /tn "PremeStartup" /xml "%A_AppData%\Preme for Windows\PremeStartup.xml" /F,, Hide
			run, %comspec% /c schtasks /create /tn "PremeLogonStart" /xml "%A_AppData%\Preme for Windows\PremeLogonStart.xml" /F,, Hide
			;justcall and programfiles are parameters.
		}
		else ;startup mode
		{
			
		}
		
		Run, %A_AppData%\Preme for Windows\bin\preme.exe showGUI sameVersionwithWriteFile
		ExitApp		;30 exception

		return
	}

}  ;END OF 005 else (to install)




return         ; end of starting process, below method must be accessed by calling directly only.
;Main return Main return Main return Main return Main return Main return Main return Main return 
;Main return Main return Main return Main return Main return Main return Main return Main return 







closeSameNameMethod:
	if(numPara1 == "startupfolder" || numPara1 == "showGUI")
		sleep, 400

	if(A_ScriptName == "preme.exe" || A_IsCompiled != 1)
	{
		DetectHiddenWindows On
		pidd := DllCall("GetCurrentProcessId")
		WinGet, pidToClose, pid, PremeSmall ahk_class PremeforWin
		;if equal, nothing to do.
		if(pidd != pidToClose && pidToClose != "")
		{
			PostMessage, 0x5556, 90, 100,, ahk_class PremeforWin		;close preme.exe
			sleep, 800
			WinGet, pidToClose, pid, PremeSmall ahk_class PremeforWin
			if(pidToClose != "" && pidd != pidToClose)
			{
				Process, Close, %pidToClose%
				if (ErrorLevel == 0)
					ExitApp
				else
					RefreshTray()
			}
			
		}
		;DetectHiddenWindows Off
	}
	else
	{
		pidd := DllCall("GetCurrentProcessId")
		if A_IsCompiled
			Process, Exist, %A_ScriptName%
		else
			Process, Exist, 1_Preme.exe
		
		if(pidd != ErrorLevel) ; && ErrorLevel != 0
		{
			Random, sleepTimeToClose, 50, 1000
			sleep, %sleepTimeToClose%
			Process, Close, %ErrorLevel%
			if (ErrorLevel == 0)	;If there is a problem to terminate it,
			{
				ExitApp		;32 exception
			}
			FormatTime, TimeString,, yyyyMMddHHmmss
			FileAppend , %TimeString% Duplicated process. %A_ScriptName% sleep time %sleepTimeToClose%.`n, %A_AppData%\Preme for Windows\premelog
		}
	}
	RefreshTray()	;important	
	
	
return	;end of closeSameNameMethod




PremeChangeConfig:
	IniRead, DisEachWinR, %A_AppData%\Preme for Windows\premedata.ini, section1, DisEachWinINI, -1
	if(DisEachWinR == -1)
		IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, section1, DisEachWinINI
		
	IfExist, %A_AppData%\Preme for Windows\premeVO0.jpg
	{
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVO0.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOa1.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOa2.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOa3.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOdown.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOleft.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOleftdown.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOleftup.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOright.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOrightdown.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOrightup.jpg
		FileDelete, %A_AppData%\Preme for Windows\VisOpts\premeVOup.jpg

		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVO0.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVO0.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOa1.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOa1.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOa2.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOa2.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOa3.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOa3.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOdown.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOdown.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOleft.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOleft.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOleftdown.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOleftdown.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOleftup.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOleftup.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOright.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOright.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOrightdown.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOrightdown.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOrightup.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOrightup.jpg, 1
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOup.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOup.jpg, 1
	}
return



installGeneralFileMethod:
	IniRead, HoldToBeOnTopR, %A_AppData%\Preme for Windows\premedata.ini, section1, HoldToBeOnTopINI, -1
	if (HoldToBeOnTopR == -1)
		FileInstall, C:\Users\YourName\Desktop\Preme\compressed\premedata.ini, %A_AppData%\Preme for Windows\premedata.ini, 1

	;FileInstall, C:\Users\YourName\Desktop\Preme\compressed\premeMedia.exe, %A_AppData%\Preme for Windows\premeMedia.exe, 1		;if this is web version		;edit here
	
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\premesmall.jpg, %A_AppData%\Preme for Windows\premesmall.jpg, 1       ;1 is overwrite exist file
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\optionsPure.jpg, %A_AppData%\Preme for Windows\optionsPure.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\optionsShadow.jpg, %A_AppData%\Preme for Windows\optionsShadow.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\onPure.jpg, %A_AppData%\Preme for Windows\onPure.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\onGrey.jpg, %A_AppData%\Preme for Windows\onGrey.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\OnShadow.jpg, %A_AppData%\Preme for Windows\OnShadow.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\offPure.jpg, %A_AppData%\Preme for Windows\offPure.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\offGrey.jpg, %A_AppData%\Preme for Windows\offGrey.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\OffShadow.jpg, %A_AppData%\Preme for Windows\OffShadow.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\closeAppPic.jpg, %A_AppData%\Preme for Windows\closeAppPic.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\wait.jpg, %A_AppData%\Preme for Windows\wait.jpg, 1
	
	FileCreateDir, %A_AppData%\Preme for Windows\VisOpts

	;VisOpts
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVO0.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVO0.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOa1.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOa1.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOa2.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOa2.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOa3.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOa3.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOdown.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOdown.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOleft.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOleft.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOleftdown.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOleftdown.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOleftup.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOleftup.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOright.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOright.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOrightdown.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOrightdown.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOrightup.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOrightup.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\VisOpts\premeVOup.jpg, %A_AppData%\Preme for Windows\VisOpts\premeVOup.jpg, 1
	
	FileCreateDir, %A_AppData%\Preme for Windows\interface
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\Microsoft.Expression.Interactions.dll, %A_AppData%\Preme for Windows\interface\Microsoft.Expression.Interactions.dll, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\Microsoft.Expression.Interactions.xml, %A_AppData%\Preme for Windows\interface\Microsoft.Expression.Interactions.xml, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\PremeInterface.exe, %A_AppData%\Preme for Windows\interface\PremeInterface.exe, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\PremeInterface.exe.config, %A_AppData%\Preme for Windows\interface\PremeInterface.exe.config, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\System.Windows.Interactivity.dll, %A_AppData%\Preme for Windows\interface\System.Windows.Interactivity.dll, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\System.Windows.Interactivity.xml, %A_AppData%\Preme for Windows\interface\System.Windows.Interactivity.xml, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\interface\WPFToolkit.dll, %A_AppData%\Preme for Windows\interface\WPFToolkit.dll, 1
	
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\Untitled-23big.ico, %A_AppData%\Preme for Windows\Untitled-23big.ico, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\Untitled-32.ico, %A_AppData%\Preme for Windows\Untitled-32.ico, 1
	
	;uninstallation files
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, DisplayName, Preme for Windows
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, UninstallString, "%A_AppData%\Preme for Windows\bin\prememanage.exe" uninstall
	;RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, ModifyPath, "%A_AppData%\Preme for Windows\bin\prememanage.exe" repairplease
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, DisplayVersion, %versionNum%
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, Publisher, Preme for Windows
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, URLInfoAbout, http://www.premeforwindows.com
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, DisplayIcon, %A_AppData%\Preme for Windows\bin\preme.exe
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, EstimatedSize, 50000
	;RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Uninstall\Preme for Windows, NoModify, 1
	
	IfExist, %A_AppData%\Preme for Windows\premeUpdate.exe
		FileDelete, %A_AppData%\Preme for Windows\premeUpdate.exe
	IfExist, %A_AppData%\premeUpdate.exe
		FileDelete, %A_AppData%\premeUpdate.exe
	
	IniRead, oldVer, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateDurableINI, 0	;versionDateDurableINI is only for deleting old files.
	if(oldVer < 20140815000000)
	{
		IniRead, KeyShortcutR, %A_AppData%\Preme for Windows\premedata.ini, section1, KeyShortcutINI, 0
		if(KeyShortcutR != 0)
		{
			SplashImage, Off
			Msgbox, 48, Preme for Windows, Preme for Windows`nYour Keyboard shortcuts may be changed due to update. Please check!
		}
	}
	
	
	SplitPath, ProgramFiles,,,,, driveSys
	if (A_PtrSize != 8)
	IfExist, %ProgramFiles%\Preme for Windows
	{
		FileRemoveDir, %driveSys%\Program Files\Preme for Windows, 1
		FileCreateDir, %driveSys%\Program Files (x86)\Preme for Windows
	}
	
	if (A_PtrSize == 8)					;A_PtrSize=8 indicates that Preme is 64 bit version.
	IfExist, %driveSys%\Program Files (x86)\Preme for Windows
	{ 
		FileRemoveDir, %driveSys%\Program Files (x86)\Preme for Windows, 1
		FileCreateDir, %ProgramFiles%\Preme for Windows
	}
	
	;control panel
	;Delete before adding is a good idea.
	RegDelete, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903},
	RegDelete, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D1558C01-990A-45F9-8273-D34E3B11B903},
	RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Classes\Wow6432Node\CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903},

	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903},, Preme for Windows
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}, InfoTip, Configure Preme for Windows setting.
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}, System.ApplicationName, Preme for Windows
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}, System.ControlPanel.Category, 8
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}, LocalizedString, Preme for Windows
	RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}\DefaultIcon,, %A_AppData%\Preme for Windows\bin\preme.exe
	if (A_PtrSize == 8)
		RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}\Shell\Open\Command,, %ProgramFiles%\Preme for Windows\preme.exe
	else
	{
		SplitPath, ProgramFiles,,,,, driveSys 
		RegWrite, REG_SZ, HKEY_CLASSES_ROOT, CLSID\{D1558C01-990A-45F9-8273-D34E3B11B903}\Shell\Open\Command,, %driveSys%\Program Files (x86)\Preme for Windows\preme.exe
	}
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D1558C01-990A-45F9-8273-D34E3B11B903},, Preme for Windows

	IniWrite, %versionNum%, %A_AppData%\Preme for Windows\premedata.ini, section1, versionNumINI
	IniWrite, %releaseDate%, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateINI
	IniWrite, %releaseDate%, %A_AppData%\Preme for Windows\premedata.ini, section1, versionDateDurableINI
	lastStr := "An application made for speeding up you window switching`nExpired:		" . expiredDateStr
	lastStr .= "`nCompiled:	" . releaseDateStr . "`n`nYou can comment to the facebook page. Although I have no time, I try to read them all.`n`n"
	lastStr .= "Preme for Windows is designed for using Windows faster. When you move the pointer to the small specific "
	lastStr .= "area to switch windows, it's the effort. With these features, you will feel faster by less aiming and less switching. "
	lastStr .= "Preme for Windows is compiled by Autohotkey. It's fast and tiny."
	lastStr .= "`n`njai_magical"
	;Search aboutText to edit these duplicated Text************************************
	FileDelete, %A_AppData%\Preme for Windows\aboutText.txt
	FileAppend , %lastStr%, %A_AppData%\Preme for Windows\aboutText.txt
	if (A_PtrSize = 8)
		IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, section1, version64INI
	else
		IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, section1, version64INI
		
	IfExist, %A_AppData%\Preme for Windows\premeMedia.exe
		Run, %A_AppData%\Preme for Windows\premeMedia.exe
return		;installGeneralFileMethod



readWinKeepPosMethod:
	IniRead, idtouch1, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch1INI
	IniRead, idtouch3, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch3INI
	IniRead, idtouch5, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch5INI
	IniRead, idtouch6, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch6INI
	
	IniRead, posXkeep1, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep1INI
	IniRead, posYkeep1, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posUkeep1INI
	IniRead, sizeXkeep1, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep1INI
	IniRead, sizeYkeep1, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep1INI
	IniRead, posXkeep3, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep3INI
	IniRead, posYkeep3, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posUkeep3INI
	IniRead, sizeXkeep3, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep3INI
	IniRead, sizeYkeep3, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep3INI
	IniRead, posXkeep5, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep5INI
	IniRead, posYkeep5, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posUkeep5INI
	IniRead, sizeXkeep5, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep5INI
	IniRead, sizeYkeep5, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep5INI
	IniRead, posXkeep6, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep6INI
	IniRead, posYkeep6, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posUkeep6INI
	IniRead, sizeXkeep6, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep6INI
	IniRead, sizeYkeep6, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep6INI
return









;011 Installation page for user.
InstallationType:
	Gui, Destroy
	FileCreateDir, %A_AppData%\Preme for Windows
	
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\installType.jpg, %A_AppData%\Preme for Windows\installType.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\installTypeAgreed.jpg, %A_AppData%\Preme for Windows\installTypeAgreed.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\installTypeMouse1.jpg, %A_AppData%\Preme for Windows\installTypeMouse1.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\installTypeMouse2.jpg, %A_AppData%\Preme for Windows\installTypeMouse2.jpg, 1
	FileInstall, C:\Users\YourName\Desktop\Preme\compressed\premeEULA.txt, %A_AppData%\Preme for Windows\premeEULA.txt, 1
	
	Gui, +AlwaysOnTop +owner +Resize -DPIScale
	Gui, Color, FFFFFF
	if not A_IsAdmin
		Gui, Add, Picture, x0 y0, %A_AppData%\Preme for Windows\installType.jpg
	else
		Gui, Add, Picture, x-689 y0, %A_AppData%\Preme for Windows\installType.jpg
		 
	Gui, Add, Picture, x0 y50, %A_AppData%\Preme for Windows\installTypeMouse1.jpg
	Gui, Add, Picture, x0 y258, %A_AppData%\Preme for Windows\installTypeMouse2.jpg
	Gui, Add, Picture, x202 y342, %A_AppData%\Preme for Windows\installTypeAgreed.jpg
	RegRead, dpivalue, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI  ;96, 120 and 144
	;96 120 144
	dpiV := (dpivalue -96 )/24
	if(dpiV == "" || dpiV == "ERROR")
		dpiV := 0
	fsize8 := 8 - dpiV*(1*(2-dpiV))
	Gui, font, s%fsize8%, Segoe UI Light
	
	Gui, Add, Button, x528 y407 h18 gwithPrivilegeButton default, with Privileges
	Gui, Add, Button, x614 y407 h18 gwithoutPrivilegeButton, without
	Gui, Add, Button, x120 y384 h24 w24 gHelpMeChooseButton,
	Gui, Add, Button, x577 y430 h22 gnoExitAppButton, No.
	Gui, Add, Button, x614 y430 h22 w46 gyesAgreeButton, Yes.			;button5
	Gui, Add, Button, x120 y384 h24 w24 ginstallDetailButton, 			;button6
	
	GuiControl, Hide, static2
	GuiControl, Hide, static3
	GuiControl, Hide, static4
	GuiControl, Hide, button4
	GuiControl, Hide, button5
	
	OnMessage(0x201, "WM_LBUTTONDOWN_InstallationType")
	ScreenWidth  = %A_ScreenWidth%
	ScreenHeight = %A_ScreenHeight%
	WinWidth := 673		
	WinHeight := 380
	ScreenWidth -= %WinWidth%
	ScreenWidth /= 2
	ScreenHeight -= %WinHeight%
	ScreenHeight *= 0.44
	;ScreenHeight -= 40

	Gui, Show, x%ScreenWidth% y%ScreenHeight% h%WinHeight% w%WinWidth%, Preme_select_type_win
	Gui, +MinSize%WinWidth%x%WinHeight%
	Gui, +MaxSize%WinWidth%x%WinHeight%
	WinSet, Style, -0x9480000, Preme_select_type_win	;ahk_class PremeforWin
	PremeEULA := ""
	Gui, Add, Edit, x7 y82 w658 h172 ReadOnly vPremeEULA 
	FileRead, premeEULAfromtxt, %A_AppData%\Preme for Windows\premeEULA.txt
	GuiControl,, PremeEULA, %premeEULAfromtxt%
	
	
	if not A_IsAdmin
	{
		SetTimer, CheckinstallTypeGUI, 100
		GuiControl, Hide, edit1
	}
	else	
		SetTimer, CheckinstallTypeGUI2, 100
Return
;end of InstallationType


CheckinstallTypeGUI:    ;check mouse pos
	IfWinNotExist, Preme_select_type_win	;ahk_class PremeforWin
	{
		SetTimer, CheckinstallTypeGUI, off
		return
	}
	
	CoordMode, Mouse, Relative
	MouseGetPos, XXX, YYY     ;, idsmall
	if (XXX<673 && XXX>0 && YYY<264 && YYY>64)
		GuiControl, Show, static2
	else if !(XXX<673 && XXX>0 && YYY<264 && YYY>64)
		GuiControl, Hide, static2
	if (XXX<673 && XXX>0 && YYY<394 && YYY>264)
		GuiControl, Show, static3
	else if !(XXX<673 && XXX>0 && YYY<394 && YYY>264)
		GuiControl, Hide, static3
Return    ;CheckinstallTypeGUI
	
	
CheckinstallTypeGUI2:
	;IfWinNotActive, Preme_select_type_win ahk_class PremeforWin
	IfWinNotExist, Preme_select_type_win	;ahk_class PremeforWin
	{
		SetTimer, CheckinstallTypeGUI2, off
		return
	}
	CoordMode, Mouse, Relative
	MouseGetPos, XXX, YYY     ;, idsmall
	if (XXX<587 && XXX>195 && YYY<393 && YYY>340)
		GuiControl, Show, static4
	else if !(XXX<587 && XXX>195 && YYY<393 && YYY>340)
		GuiControl, Hide, static4
Return	    ;CheckinstallTypeGUI2

installDetailButton:
	WinGetPos,,,, hidinstall, A
	if(hidinstall < 430)
	{
		Gui, +MaxSize673x512
		Loop, 10
		{
			hidinstall += 11
			SetWinDelay, 20
			WinMove, A,,,,, %hidinstall%
		}
		Gui, +MinSize673x512   ;528
	}
	else
	{
		Gui, +MinSize673x403
		Loop, 10
		{
			hidinstall -= 11
			SetWinDelay, 20
			WinMove, A,,,,, %hidinstall%
		}
		Gui, +MaxSize673x403
	}
return

helpMeChooseButton:
	WinGetPos,,,, hidinstall, A
	if(hidinstall < 430)
	{
		Gui, +MaxSize673x512
		Loop, 4
		{
			hidinstall += 10
			SetWinDelay, 20
			WinMove, A,,,,, %hidinstall%
		}
		Gui, +MinSize673x512   ;528
	}
	else
	{
		Gui, +MinSize673x403
		Loop, 4
		{
			hidinstall -= 10
			SetWinDelay, 20
			WinMove, A,,,,, %hidinstall%
		}
		Gui, +MaxSize673x403
	}
return

withPrivilegeButton:
	SetTimer, CheckinstallTypeGUI, off
	GuiControl, Hide, static2
	GuiControl, Hide, static3
	
	RegRead, dpivalue, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	;if the window is expand at the beneath 
	WinGetPos,,,, hidinstall, A
	if(hidinstall > 430)
	{
		Gui, +MinSize673x403
		Loop, 4
		{
			hidinstall -= 10
			SetWinDelay, 20
			WinMove, A,,,,, %hidinstall%
		}
		Gui, +MaxSize673x403
	}
	sleep, 100
	XPosWin1 := 0
	GuiControl, Hide, button3
	Loop, 10{
		XPosWin1 -= 68
		ControlMove, static1, %XPosWin1% 
	}
	if(dpivalue == 96)
		ControlMove, static4, 211

	global elevatedPrivileges := 1
	GuiControl, Show, button6
	GuiControl, Hide, button1
	GuiControl, Hide, button2
	GuiControl, Show, button4
	GuiControl, Show, button5
	GuiControl, Show, edit1
	SetTimer, CheckinstallTypeGUI2, 100
return

withoutPrivilegeButton:
	SetTimer, CheckinstallTypeGUI, off
	GuiControl, Hide, static2
	GuiControl, Hide, static3
	
	RegRead, dpivalue, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	WinGetPos,,,, hidinstall, A
	if(hidinstall > 430)
	{
		Gui, +MinSize673x403
		Loop, 4
		{
			hidinstall -= 10
			SetWinDelay, 20
			WinMove, A,,,,, %hidinstall%
		}
		Gui, +MaxSize673x403
	}
	sleep, 100
	XPosWin1 := 0
	GuiControl, Hide, button3
	Loop, 10{
		XPosWin1 -= 68
		ControlMove, static1, %XPosWin1% 
	}
	if(dpivalue == 96)
		ControlMove, static4, 211
	
	GuiControl, Show, edit1
	GuiControl, Show, button6
	GuiControl, Hide, button1
	GuiControl, Hide, button2
	GuiControl, Show, button4
	GuiControl, Show, button5
	global elevatedPrivileges := 2
	SetTimer, CheckinstallTypeGUI2, 100
return
	
yesAgreeButton:
	if not A_IsAdmin
	{
		if(elevatedPrivileges == 1)
		{
			DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "eulaAgreed" , str, A_WorkingDir, int, 1)
			ExitApp		;33 exception
		}
		else ;elevatedPrivileges==2
		{
			Gui, Destroy
			;Go on and install in the next if not A_IsAdmin
		}
	}
	else  ;has it own privilege
	{
		Gui, Destroy
	}
return

noExitAppButton:
	ExitApp
return
	
;check position of pointer when the button1 is pushed.
WM_LBUTTONDOWN_InstallationType(wParam, lParam)
{
	CoordMode, Mouse, Relative
	MouseGetPos, XXXILT, YYYILT     ;, idsmall
	ControlGetPos, Xst1,,,, static1, A
	if (Xst1>0 && Xst1<10 && XXXILT<673 && XXXILT>0 && YYYILT<264 && YYYILT>64)
	{
		Gosub withPrivilegeButton
	}
	else if (Xst1>0 && Xst1<10 && XXXILT<673 && XXXILT>0 && YYYILT<394 && YYYILT>264)
	{
		Gosub withoutPrivilegeButton
	}
	else if (Xst1>0 && Xst1<10 && XXXILT<116 && XXXILT>16 && YYYILT<410 && YYYILT>394)  ;show or unshow install details
	{
		Gosub HelpMeChooseButton		
	}
	;clicking Yes I agree.
	else if (Xst1>-685 && Xst1<-675 && XXXILT<587 && XXXILT>195 && YYYILT<393 && YYYILT>340)  ;show or unshow install details
	{
		Gosub yesAgreeButton
	}
	else if (Xst1>-685 && Xst1<-675 && XXXILT<170 && XXXILT>114 && YYYILT<393 && YYYILT>340)  ;show or unshow install details
	{
		ExitApp		;34 exception
	}
	else if (Xst1>-685 && Xst1<-675 && XXXILT<125 && XXXILT>14 && YYYILT<410 && YYYILT>394)  ;show or unshow install details
	{
		Gosub installDetailButton
	}
	
	
}   ;WM_LBUTTONDOWN_InstallationType



















;013 rollBackTSW function (Touch Slide Window)
rollBackTSW:
	Gosub, readWinKeepPosMethod	;id, size and position of sliding window.
	IfWinExist, ahk_id %idtouch1%
	{
		IfWinExist, ahk_id %idtouch3%
		{
			WinGetPos, XposOut1,,,, ahk_id %idtouch1%
			WinGetPos, XposOut3,,,, ahk_id %idtouch3%
			Winset, Enable ,, ahk_id %idtouch1%
			Winset, Enable ,, ahk_id %idtouch3%
			Winset, AlwaysOnTop, Off, ahk_id %idtouch1%
			Winset, AlwaysOnTop, Off, ahk_id %idtouch3%
			Loop, 6
			{
				XposOut1 += 40
				XposOut3 -= 40
				SetWinDelay, 2
				WinMove, ahk_id %idtouch1%,, %XposOut1%
				WinMove, ahk_id %idtouch3%,, %XposOut3%
			}
		}
		else
		{
			WinGetPos, XposOut1,,,, ahk_id %idtouch1%
			Winset, Enable ,, ahk_id %idtouch1%
			Winset, AlwaysOnTop, Off, ahk_id %idtouch1%
			Loop, 6
			{
				XposOut1 += 40
				SetWinDelay, 4
				WinMove, ahk_id %idtouch1%,, %XposOut1%
			}
		}
	}
	else IfWinExist, ahk_id %idtouch3%
	{
		WinGetPos, XposOut3,,,, ahk_id %idtouch3%
		Winset, Enable ,, ahk_id %idtouch3%
		Winset, AlwaysOnTop, Off, ahk_id %idtouch3%
		Loop, 6
		{
			XposOut3 -= 40
			SetWinDelay, 4
			WinMove, ahk_id %idtouch3%,, %XposOut3%
		}
	}
	IfWinExist, ahk_id %idtouch5%
	{
		WinGetPos,, YposOut5,,, ahk_id %idtouch5%
		Winset, Enable ,, ahk_id %idtouch5%
		Winset, AlwaysOnTop, Off, ahk_id %idtouch5%
		destYOut5 := 0
		inSin5 := 0
		realYPosOut5 := YposOut5
	
		Loop, 10
		{
			inSin5 += 0.157
			realYPosOut5 := YposOut5 + Ceil(Sqrt(sin(inSin5))*(destYOut5-YposOut5))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch5%,,, %realYPosOut5%     
		}
	}
	IfWinExist, ahk_id %idtouch6%
	{
		WinGetPos,, YposOut6,,, ahk_id %idtouch6%
		Winset, Enable ,, ahk_id %idtouch6%
		Winset, AlwaysOnTop, Off, ahk_id %idtouch6%
		Loop, 6
		{
			YposOut6 -= 40
			SetWinDelay, 4
			WinMove, ahk_id %idtouch6%,,, %YposOut6%
		}
	}
return      ;rollBackTSW


startForceButtonListener:
	Hotkey, ~vk01, On          ;LButton
	Hotkey, ~Escape, On
	Hotkey, ~vk04, On
	Hotkey, ~*vk02, On        ;RButton
	if(SubStr(A_OSVersion,1,3) == "10.")
	{
		Hotkey, ~vk9e, wheelDownHotkey    ;Wheeldown
		Hotkey, ~vk9f, wheelUpHotkey    ;Wheelup
	}
	else
	{
		Hotkey, vk9e, wheelDownHotkey    ;Wheeldown
		Hotkey, vk9f, wheelUpHotkey    ;Wheelup
	}
	Hotkey, +vk9e, wheelDownWithShift
	Hotkey, +vk9f, wheelUpWithShift
	
	IniRead, KeyShortcutR, %A_AppData%\Preme for Windows\premedata.ini, section1, KeyShortcutINI, 0
	if(KeyShortcutR != 0)
	{
		IniRead, theNumOFhotkeyMM, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutModToMod, theNumOFhotkeyINI, 0
		if(theNumOFhotkeyMM > 8 || theNumOFhotkeyMM < 0)
			theNumOFhotkeyMM := 8
		Loop, %theNumOFhotkeyMM%
		{
			IniRead, shortcutInputModMod, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutModToMod, shortcutInputModMod%A_Index%INI
			IniRead, shortcutOutputModMod%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutModToMod, shortcutOutputModMod%A_Index%INI
			Hotkey, %shortcutInputModMod%, premehotkeyMM%A_Index%, On
			Hotkey, %shortcutInputModMod% Up, premehotkeyMMU%A_Index%, On		;ModModUp	MM means Mod to Mod
		}
		IniRead, theNumOFhotkey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, theNumOFhotkeyINI, 0
		if(theNumOFhotkey > 20 || theNumOFhotkey < 0)
			theNumOFhotkey := 20
		Loop, %theNumOFhotkey%
		{
			IniRead, shortcutInputMod, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutInputMod%A_Index%INI
			IniRead, shortcutInputKey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutInputKey%A_Index%INI
			IniRead, overwritehotR, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, overwritehot%A_Index%INI, 0
			IniRead, ddlshortcutResult, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutResult%A_Index%INI
			IniRead, shortcutParam2, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutParam2%A_Index%INI	
			InputKey := shortcutInputKeyMethod(shortcutInputKey)
			if(shortcutInputKey != "")	;strLen > 0
				modKey := shortcutmodMethod(shortcutInputMod)
			else
				modKey := shortcutInputMod
				
			if(overwritehotR)
				premehotkey = %modKey%%InputKey%
			else
				premehotkey = ~%modKey%%InputKey%
			
			if(modKey != "")
				premehotkey = *%premehotkey%
				
			if(ddlshortcutResult == "Remap Key" && shortcutParam2 == "")	;In case Win+R => Alt, the previous loop is for Win => Alt
			{
				Hotkey, %premehotkey% Up, premehotkey%A_Index%, On
			}
			else
				Hotkey, %premehotkey%, premehotkey%A_Index%, On		;This is the main. Most uses this.
		}
	}

	DetectHiddenWindows, On
return		;startForceButtonListener


startButtonListener:
	#InputLevel 1
	IniRead, HoldToBeOnTopR, %A_AppData%\Preme for Windows\premedata.ini, section1, HoldToBeOnTopINI, 0
	IniRead, PressWheelToCloseR, %A_AppData%\Preme for Windows\premedata.ini, section1, PressWheelToCloseINI, 0
	IniRead, WheelWindowDownR, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelWindowDownINI, 0
	IniRead, TouchSlideWindowR, %A_AppData%\Preme for Windows\premedata.ini, section1, TouchSlideWindowINI, 0
	IniRead, PositionWindowsR, %A_AppData%\Preme for Windows\premedata.ini, section1, PositionWindowsINI, 0
	IniRead, CursorUpR, %A_AppData%\Preme for Windows\premedata.ini, section1, CursorUpINI, 0
	IniRead, EscEscR, %A_AppData%\Preme for Windows\premedata.ini, section1, EscEscINI, 0
	IniRead, ScrollAllWinR, %A_AppData%\Preme for Windows\premedata.ini, section1, ScrollAllWinINI, 0
	IniRead, WheelToMaximizeR, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelToMaximizeINI, 0
	IniRead, WheelTskBarVolR, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelTskBarVolINI, 0
	IniRead, VisibleOpR, %A_AppData%\Preme for Windows\premedata.ini, section1, VisibleOpINI, 0
	IniRead, KeyShortcutR, %A_AppData%\Preme for Windows\premedata.ini, section1, KeyShortcutINI, 0
	;Msgbox, what startButtonListener %HoldToBeOnTopR%
	if(HoldToBeOnTopR == 1 || TouchSlideWindowR == 1 || PositionWindowsR == 1)
		Hotkey, ~vk01, On          ;LButton
	else
		Hotkey, ~vk01, Off
	
	if(EscEscR == 1)
		Hotkey, ~Escape, On
	else
		Hotkey, ~Escape, Off

	if(PressWheelToCloseR == 1)
		Hotkey, ~vk04, On
	else
		Hotkey, ~vk04, Off
	
	if(CursorUpR == 1 || VisibleOpR == 1)
	{
		Hotkey, ~*vk02, On        ;RButton
	}
	else
		Hotkey, ~*vk02, Off        ;RButton

	if(ScrollAllWinR != 1 || SubStr(A_OSVersion,1,3) == "10.") 
	{
		if(WheelToMaximizeR == 1 || WheelTskBarVolR == 1)
		{
			Hotkey, ~vk9f, wheelUpHotkey    ;Wheelup
			Hotkey, +vk9f, wheelUpWithShift
		}
		if(WheelWindowDownR == 1 || WheelTskBarVolR == 1)
		{
			Hotkey, ~vk9e, wheelDownHotkey    ;Wheeldown
			Hotkey, +vk9e, wheelDownWithShift
		}
	}
	else if(ScrollAllWinR == 1)
	{
		Hotkey, vk9e, wheelDownHotkey    ;Wheeldown
		Hotkey, vk9f, wheelUpHotkey    ;Wheelup
		Hotkey, +vk9e, wheelDownWithShift
		Hotkey, +vk9f, wheelUpWithShift
	}
	
	if(KeyShortcutR != 0)
	{
		IniRead, theNumOFhotkeyMM, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutModToMod, theNumOFhotkeyINI, 0
		if(theNumOFhotkeyMM > 8 || theNumOFhotkeyMM < 0)
			theNumOFhotkeyMM := 8
		Loop, %theNumOFhotkeyMM%
		{
			IniRead, shortcutInputModMod, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutModToMod, shortcutInputModMod%A_Index%INI
			IniRead, shortcutOutputModMod%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutModToMod, shortcutOutputModMod%A_Index%INI
			Hotkey, %shortcutInputModMod%, premehotkeyMM%A_Index%, On
			Hotkey, %shortcutInputModMod% Up, premehotkeyMMU%A_Index%, On		;ModModUp
		}
		IniRead, theNumOFhotkey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, theNumOFhotkeyINI, 0
		if(theNumOFhotkey > 20 || theNumOFhotkey < 0)
			theNumOFhotkey := 20
		Loop, %theNumOFhotkey%
		{
			IniRead, shortcutInputMod, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutInputMod%A_Index%INI
			IniRead, shortcutInputKey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutInputKey%A_Index%INI
			IniRead, overwritehotR, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, overwritehot%A_Index%INI, 0
			IniRead, ddlshortcutResult, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutResult%A_Index%INI
			IniRead, shortcutParam2, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutParam2%A_Index%INI	
			InputKey := shortcutInputKeyMethod(shortcutInputKey)
			if(shortcutInputKey != "")	;strLen > 0
				modKey := shortcutmodMethod(shortcutInputMod)
			else
				modKey := shortcutInputMod
				
			if(overwritehotR)
				premehotkey = %modKey%%InputKey%
			else
				premehotkey = ~%modKey%%InputKey%
			
			if(modKey != "")
				premehotkey = *%premehotkey%

			if(ddlshortcutResult == "Remap Key" && shortcutParam2 == "")	;In case Win+R => Alt, the previous loop is for Win => Alt
			{
				Hotkey, %premehotkey% Up, premehotkey%A_Index%, On
			}
			else
				Hotkey, %premehotkey%, premehotkey%A_Index%, On		;This is the main. Most uses this.
		}
	}
	DetectHiddenWindows, On
return	;startButtonListener

;015 reloadpremeengMethod function
reloadpremeengMethod:
	
	IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate		;0 is off, other is on
	Gosub, buildSmallPremeGUI
	
	Gosub, noButtonListener		;important
	Gosub, engineWithINI
	Gosub, runpremeengMethod
	if(wreloadTime != 0)
		SetTimer, runpremeengMethod, %wreloadTime%		;It doesn't do abruptly.
	DetectHiddenWindows, Off
return

runpremeengMethod:	;don't delete
	Process, close, premeeng.exe
	IfNotExist, %A_AppData%\Preme for Windows\bin\premeeng.exe
		FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\premeeng.exe, 1
	run, %A_AppData%\Preme for Windows\bin\premeeng.exe
return

noButtonListener:
	;SetTimer, CheckMouse, off
	Hotkey, ~vk01, Off, UseErrorLevel          ;Lbutton
	Hotkey, vk9e, Off, UseErrorLevel    		;Wheeldown
	Hotkey, vk9f, Off, UseErrorLevel   		;Wheelup
	Hotkey, +vk9e, Off, UseErrorLevel
	Hotkey, +vk9f, Off, UseErrorLevel
	Hotkey, ~Escape, Off, UseErrorLevel
	Hotkey, ~vk04, Off, UseErrorLevel        	;MButton
	Hotkey, ~*vk02, Off, UseErrorLevel        	;RButton
return  ;noButtonListener



	



;018 Poption function (open big window)
Poption:

	WinClose, ahk_class NotifyIconOverflowWindow
	WinGet, tran, Transparent, PremeSmall ahk_class PremeforWin
	if(tran == 255)
	;IfWinExist, PremeSmall ahk_class PremeforWin    ;small window
	{
		Gosub, fullprememethod
	}
	else if WinExist("ahk_exe PremeInterface.exe")
	{
		WinActivate, Preme for Windows  ;, %GUITitle% ahk_class PremeforWin
	}
	else
	{
		Gosub, MainPremeInterface
	}
return  ;Poption

 ;016 Pdisable function (Disable all..)
Pdisable:
	WinGetPos,,, WWW,, ahk_class PremeforWin
	IniWrite, -1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate
	Process, close, premeeng.exe
	SetTimer, CheckMouse, off
	SetTimer, runpremeengMethod, off
	;OnMessage(0x5556, "")		;Waiting for Message of Close, (90, 100)
	Gosub, buildSmallPremeGUI
	;RenameTray("distoclose", versionNum)
return

;014 Pclose function
Pclose:
	OnExit,
	Gosub, rollBackTSW
	Process, close, premeeng.exe
	IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate
	ExitApp		;very exception
return


MainPremeInterface:
	Gosub, WaitWindow
	UseErrorLevel := ""
	if WinExist("ahk_exe PremeInterface.exe")
		WinActivate, Preme for Windows  ;, %GUITitle% ahk_class PremeforWin
	else
		run, %A_AppData%\Preme for Windows\interface\PremeInterface.exe,, UseErrorLevel
	if(UseErrorLevel == "ERROR")
	{
		MsgBox, 48, Preme for Windows, The PremeInterface.exe doesn't exist. This is a problem.
		Gui , 2: Destroy
		return
	}
	else
	{
		TC := A_TickCount
		Loop, {
			WinGetClass, classEveryCheck, A
			Process, Exist, PremeInterface.exe
			;if PremeInterface.exe is not exist. Something is wrong.
			if(ErrorLevel!=0 && A_TickCount-TC > 50000)
			{
				MsgBox, 48, Preme for Windows, You may have some program blocking PremeInterface.exe. Try checking it.
				Gui , 2: Destroy
				break
			}
			else if(InStr(classEveryCheck, "HwndWrapper[PremeInterface.exe;;"))
			{
				Gui , 2: Destroy
				break
			}
			else if(A_TickCount-TC > 90000)
			{
				Process, Close, PremeInterface.exe
				Gui, 2: Destroy
				break
			}
			sleep, 300
		}
	}
	Gosub, buildSmallPremeGUI
	Gosub, submitANDdoBig
	IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate
return

;020 CheckForUpdateMethod function
CheckForUpdateMethod:

	RegRead, firewall_status, HKEY_LOCAL_MACHINE, SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List, %ProgramFiles%\Preme for Windows\preme.exe
	If (!InStr(firewall_status, "Enabled"))
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List, %A_AppData%\Preme for Windows\bin\prememanage.exe, %A_AppData%\Preme for Windows\bin\prememanage.exe:*:Enabled:Preme for Windows
		; if(ErrorLevel!=0)
		; {
			; IfWinExist, smallUpdate ahk_class PremeforWin
				; GuiControl, Text, static2, Fail to request Firewall permission.
			; else
				; GuiControl, 2: Text, static2, Fail to request Firewall permission.
		; }
	}
	

	UrlDownloadToFile, https://s3-ap-northeast-1.amazonaws.com/premeudcheck/updateFile.txt, %a_appdata%\Preme for Windows\update
	if(ErrorLevel!=0)
	{
		IfWinExist, smallUpdate ahk_class PremeforWin
		{	
			GuiControl, Text, static2, Update server not available.
			GuiControl, Text, button1, Website
		}
		internetFail := 1
	}
	
	if(internetFail != 1)
	{
		FileReadLine, updateDate, %A_AppData%\Preme for Windows\update, 1    ;update date format is YYYYMMDD
		;FileReadLine, updateVersion, %A_AppData%\Preme for Windows\update, 2
		
		;the number is the release date. updateDate is the number of the date of new version.
		;so this if is to download update   
		if(updateDate>releaseDate)     ;20101231 the number is the release date        Change this if a new version will be released.
		{
			if (A_Is64bitOS)
			{
				FileReadLine, checksize, %A_AppData%\Preme for Windows\update, 5
				FileReadLine, updateLink, %A_AppData%\Preme for Windows\update, 6	;64 bit
			}
			else
			{
				FileReadLine, checksize, %A_AppData%\Preme for Windows\update, 3	
				FileReadLine, updateLink, %A_AppData%\Preme for Windows\update, 4	;32 bit
			}
			
			IfWinExist, smallUpdate ahk_class PremeforWin
				GuiControl, Text, static2, Update available. Downloading..

			UrlDownloadToFile, http://bit.ly/premeExpireCount, %a_appdata%\Preme for Windows\z_expirecount
			UrlDownloadToFile, %updateLink%, %A_AppData%\Preme for Windows\premeUpdate.exe
			sleep, 100
			FileGetSize, premeUpdateSize, %A_AppData%\Preme for Windows\premeUpdate.exe
			if(ErrorLevel!=0)||(checksize!=premeUpdateSize)
			{
				IfWinExist, smallUpdate ahk_class PremeforWin
				{
					GuiControl, Text, static2, Update fails. 
					GuiControl, Text, button1, Website
				}
			}
			else      ;if download success
			{
				IfWinExist, smallUpdate ahk_class PremeforWin
					GuiControl, Text, static2, Download successful.

				Gosub, rollBackTSW
				Process, close, premeeng.exe
				Run, %A_AppData%\Preme for Windows\premeUpdate.exe premeupdate
				Gui, Destroy
				OnExit,
				ExitApp
			}
		}
		else
		{
			IfWinExist, smallUpdate ahk_class PremeforWin
				GuiControl, Text, static2, Preme for Windows is up to date.
			;else
				;GuiControl, 2: Text, static2, Preme for Windows is up to date. (%updateVersion%)
		}
	}	;if
return    ; CheckForUpdateMethod




























		
		



;read INI and go to engineCode
engineWithINI:
	IniRead, whlc, %A_AppData%\Preme for Windows\premedata.ini, section1, HoldToBeOnTopINI, 0
	;IniRead, PressWheelToCloseR, %A_AppData%\Preme for Windows\premedata.ini, section1, PressWheelToCloseINI, 0
	IniRead, wmin, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelWindowDownINI, 0
	IniRead, weasy0, %A_AppData%\Preme for Windows\premedata.ini, section1, TouchSlideWindowINI, 0
	IniRead, wposwin, %A_AppData%\Preme for Windows\premedata.ini, section1, PositionWindowsINI, 0
	IniRead, wsmartmove, %A_AppData%\Preme for Windows\premedata.ini, section1, CursorUpINI, 0
	IniRead, wdonhold, %A_AppData%\Preme for Windows\premedata.ini, section1, DonHoldINI, 0
	IniRead, wes1, %A_AppData%\Preme for Windows\premedata.ini, section1, EscEscINI, 0
	IniRead, wscrollAW, %A_AppData%\Preme for Windows\premedata.ini, section1, ScrollAllWinINI, 0
	IniRead, wmax, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelToMaximizeINI, 0
	IniRead, wvolum, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelTskBarVolINI, 0
	IniRead, wvisiop, %A_AppData%\Preme for Windows\premedata.ini, section1, VisibleOpINI, 0
	IniRead, wdiseachwin, %A_AppData%\Preme for Windows\premedata.ini, section1, DisEachWinINI, 0
	IniRead, KeyShortcutR, %A_AppData%\Preme for Windows\premedata.ini, section1, KeyShortcutINI, 0
	IniRead, wreloadTime, %A_AppData%\Preme for Windows\premedata.ini, Operation, reloadTimeINI, 5
	weasy := weasy0 || wvisiop
	
	IniRead, TLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TLsliderINI, 0
	IniRead, TRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TRsliderINI, 0
	IniRead, BLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BLsliderINI, 0
	IniRead, BRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BRsliderINI, 0
	
	IniRead, shortcutModTLR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModTLINI
	IniRead, shortcutModTRR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModTRINI
	IniRead, shortcutModBLR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModBLINI
	IniRead, shortcutModBRR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModBRINI

	IniRead, shortcutKeyTLR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyTLINI
	IniRead, shortcutKeyTRR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyTRINI
	IniRead, shortcutKeyBLR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyBLINI
	IniRead, shortcutKeyBRR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyBRINI
	
	IniRead, CornerRunFileTLR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileTLINI
	IniRead, CornerRunFileTRR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileTRINI
	IniRead, CornerRunFileBLR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileBLINI
	IniRead, CornerRunFileBRR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileBRINI

	IniRead, blacklistvar1, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, HoldtobeonTopDDLINI, 0
	IniRead, blacklistvar2, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, PresswheeltcDDLINI, 0
	IniRead, blacklistvar3, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, RollWindownDDLINI, 0
	IniRead, blacklistvar4, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, ESCtwiceDDLINI, 0
	IniRead, blacklistvar5, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, VisiOptsDDLINI, 0
	IniRead, blacklistvar6, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, ScrollUpMaxDDLINI, 0
	
	if(KeyShortcutR != 0)
	{
		IniRead, theNumOFhotkey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, theNumOFhotkeyINI
		if(theNumOFhotkey > 20 || theNumOFhotkey < 0)
			theNumOFhotkey := 20
		Loop, %theNumOFhotkey%
		{
			IniRead, ddlshortcutResult%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutResult%A_Index%INI
			IniRead, shortcutParam1%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutParam1%A_Index%INI
			IniRead, shortcutParam2%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutParam2%A_Index%INI
		}
	}
	
	if(winver == 2)
		wscrollAW = 0
	
	
	;Calculate slide time Cancel button
	TLsleepTime := (TLsliderR*7)+(100*Ceil(TLsliderR/100))
	TRsleepTime := (TRsliderR*7)+(100*Ceil(TRsliderR/100))
	BLsleepTime := (BLsliderR*7)+(100*Ceil(BLsliderR/100))
	BRsleepTime := (TRsliderR*7)+(100*Ceil(TRsliderR/100)) 
	;End Calculate slide time Cancel Button
	
	wshortcutModTL := shortcutModTLR
	wshortcutModTR := shortcutModTRR
	wshortcutModBL := shortcutModBLR
	wshortcutModBR := shortcutModBRR
	
	wshortcutKeyTL := shortcutKeyTLR
	wshortcutKeyTR := shortcutKeyTRR
	wshortcutKeyBL := shortcutKeyBLR
	wshortcutKeyBR := shortcutKeyBRR

	if(wreloadTime == 5)
		wreloadTime := 10*60000
	else if(wreloadTime > 3)
	{
		if(wreloadTime == 4)
			wreloadTime := 5*60000
		else if(wreloadTime == 6)
			wreloadTime := 20*60000
		else if(wreloadTime == 7)
			wreloadTime := 30*60000
		else if(wreloadTime == 8)
			wreloadTime := 60*60000
		else if(wreloadTime == 9)
			wreloadTime := 180*60000
	}

	if(blacklistvar1 != 0)
	{
		Loop, 5
		{
		IniRead, blacklistcls1%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, HoldtobeonTopText%A_Index%INI
		}
	}
	if(blacklistvar2 != 0)
		Loop, 5
		{
		IniRead, blacklistcls2%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, PresswheeltcText%A_Index%INI
		}
	if(blacklistvar3 != 0)
	{
		Loop, 5
		{
		IniRead, blacklistcls3%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, RollWindownText%A_Index%INI
		}
	}
	if(blacklistvar4 != 0)
		Loop, 5
		{
		IniRead, blacklistcls4%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, ESCtwiceText%A_Index%INI
		}
	if(blacklistvar5 != 0)
		Loop, 5
		{
		IniRead, blacklistcls5%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, VisiOptsText%A_Index%INI
		}
	if(blacklistvar6 != 0)
		Loop, 5
		{
		IniRead, blacklistcls6%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, ScrollUpMaxText%A_Index%INI
		}
	;each app section nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
	Loop, 5		;Topleft corner
	{
		IniRead, TLEachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TLEachText%A_Index%INI
		if(TLEachText%A_Index%R == "")
		{
			enableTLeach := A_Index - 1
			break
		}
	}
	Loop, 5		;Topright corner
	{
		IniRead, TREachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TREachText%A_Index%INI
		if(TREachText%A_Index%R == "")
		{
			enableTReach := A_Index - 1
			break
		}
	}
	Loop, 5		;Bottomleft corner
	{
		IniRead, BLEachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BLEachText%A_Index%INI
		;Msgbox, % "text " . BLEachText%A_Index%R
		if(BLEachText%A_Index%R == "")
			{
				enableBLeach := A_Index - 1
				break
			}
	}
	Loop, 5		;Bottomright corner
	{
		IniRead, BREachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BREachText%A_Index%INI
		if(BREachText%A_Index%R == "")
		{
			enableBReach := A_Index - 1
			break
		}
	}
	
	;Topleft (Each app shortcut at corner)
	Loop, %enableTLeach%		;Bottomright corner
	{
		IniRead, TLEachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TLEachModDDL%A_Index%INI
		IniRead, TLEachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TLEachShcutDDL%A_Index%INI
	}

	;Topright
	Loop, %enableTReach%		;Bottomright corner
	{
		IniRead, TREachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TREachModDDL%A_Index%INI
		IniRead, TREachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TREachShcutDDL%A_Index%INI
	}

	;Bottomleft
	Loop, %enableBLeach%		;Bottomright corner
	{
		IniRead, BLEachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BLEachModDDL%A_Index%INI
		IniRead, BLEachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BLEachShcutDDL%A_Index%INI
	}
	
	;Bottomright
	Loop, %enableBReach%		;Bottomright corner
	{
		IniRead, BREachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BREachModDDL%A_Index%INI
		IniRead, BREachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BREachShcutDDL%A_Index%INI
	}
	;END of each app section nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn

	;Gui, Destroy
	Gosub, EngineCode
return   	;engineWithINI



submitANDdoBig:
	;Close premeeng.exe, read INI, then open premeeng.exe
	Process, Close, premeeng.exe
	IniRead, blacklistvar1, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, HoldtobeonTopDDLINI, 0
	IniRead, blacklistvar2, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, PresswheeltcDDLINI, 0
	IniRead, blacklistvar3, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, RollWindownDDLINI, 0
	IniRead, blacklistvar4, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, ESCtwiceDDLINI, 0
	IniRead, blacklistvar5, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, VisiOptsDDLINI, 0
	IniRead, blacklistvar6, %A_AppData%\Preme for Windows\premedata.ini, BlacklistDDL, ScrollUpMaxDDLINI, 0
	IniRead, KeyShortcutR, %A_AppData%\Preme for Windows\premedata.ini, section1, KeyShortcutINI, 0
	if(KeyShortcutR != 0)
	{
		IniRead, theNumOFhotkey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, theNumOFhotkeyINI, 0
		if(theNumOFhotkey > 20 || theNumOFhotkey < 0)
			theNumOFhotkey := 20
		Loop, %theNumOFhotkey%
		{
			IniRead, ddlshortcutResult%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutResult%A_Index%INI
			IniRead, shortcutParam1%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutParam1%A_Index%INI
			IniRead, shortcutParam2%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutParam2%A_Index%INI
		}
	}
	
	if(blacklistvar1 != 0)
	{
		Loop, 5
		{
		IniRead, blacklistcls1%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, HoldtobeonTopText%A_Index%INI
		}
	}
	if(blacklistvar2 != 0)
		Loop, 5
		{
		IniRead, blacklistcls2%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, PresswheeltcText%A_Index%INI
		}
	if(blacklistvar3 != 0)
	{
		Loop, 5
		{
		IniRead, blacklistcls3%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, RollWindownText%A_Index%INI
		}
	}
	if(blacklistvar4 != 0)
		Loop, 5
		{
		IniRead, blacklistcls4%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, ESCtwiceText%A_Index%INI
		}
	if(blacklistvar5 != 0)
		Loop, 5
		{
		IniRead, blacklistcls5%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, VisiOptsText%A_Index%INI
		}
	if(blacklistvar6 != 0)
		Loop, 5
		{
		IniRead, blacklistcls6%A_Index%, %A_AppData%\Preme for Windows\premedata.ini, BlacklistText, ScrollUpMaxText%A_Index%INI
		}
	;each app section nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
	Loop, 5		;Topleft corner
	{
		IniRead, TLEachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TLEachText%A_Index%INI
		if(TLEachText%A_Index%R == "")
		{
			enableTLeach := A_Index - 1
			break
		}
	}
	Loop, 5		;Topright corner
	{
		IniRead, TREachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TREachText%A_Index%INI
		if(TREachText%A_Index%R == "")
		{
			enableTReach := A_Index - 1
			break
		}
	}
	Loop, 5		;Bottomleft corner
	{
		IniRead, BLEachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BLEachText%A_Index%INI
		if(BLEachText%A_Index%R == "")
		{
			enableBLeach := A_Index - 1
			break
		}
	}
	Loop, 5		;Bottomright corner
	{
		IniRead, BREachText%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BREachText%A_Index%INI
		if(BREachText%A_Index%R == "")
		{
			enableBReach := A_Index - 1
			break
		}
	}
	;Topleft (Each app shortcut at corner)
	Loop, %enableTLeach%		;Topleft corner
	{
		IniRead, TLEachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TLEachModDDL%A_Index%INI
		IniRead, TLEachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TLEachShcutDDL%A_Index%INI
	}

	;Topright
	Loop, %enableTReach%		;Topright corner
	{
		IniRead, TREachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TREachModDDL%A_Index%INI
		IniRead, TREachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, TREachShcutDDL%A_Index%INI
	}
	
	;Bottomleft
	Loop, %enableBLeach%		;Bottomleft corner
	{
		IniRead, BLEachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BLEachModDDL%A_Index%INI
		IniRead, BLEachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BLEachShcutDDL%A_Index%INI
	}
	
	;Bottomright
	Loop, %enableBReach%		;Bottomright corner
	{
		IniRead, BREachModDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BREachModDDL%A_Index%INI
		IniRead, BREachShcutDDL%A_Index%R, %A_AppData%\Preme for Windows\premedata.ini, EachAppShortcut, BREachShcutDDL%A_Index%INI
	}
	
	Run, %A_AppData%\Preme for Windows\bin\premeeng.exe UI,, UseErrorLevel
	Gosub submitANDdo	;important
return		;submitANDdoBig

submitANDdo:
	;033a read GUI (Preme Interface) and assign var in no time
	IniRead, whlc, %A_AppData%\Preme for Windows\premedata.ini, section1, HoldToBeOnTopINI, 0
	;IniRead, mb, %A_AppData%\Preme for Windows\premedata.ini, section1, PressWheelToCloseINI, 0
	IniRead, wmin, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelWindowDownINI, 0
	IniRead, weasy0, %A_AppData%\Preme for Windows\premedata.ini, section1, TouchSlideWindowINI, 0
	IniRead, wposwin, %A_AppData%\Preme for Windows\premedata.ini, section1, PositionWindowsINI, 0
	IniRead, wsmartmove, %A_AppData%\Preme for Windows\premedata.ini, section1, CursorUpINI, 0
	IniRead, wdonhold, %A_AppData%\Preme for Windows\premedata.ini, section1, DonHoldINI, 0
	IniRead, wes1, %A_AppData%\Preme for Windows\premedata.ini, section1, EscEscINI, 0
	IniRead, wscrollAW, %A_AppData%\Preme for Windows\premedata.ini, section1, ScrollAllWinINI, 0
	IniRead, wmax, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelToMaximizeINI, 0
	IniRead, wvolum, %A_AppData%\Preme for Windows\premedata.ini, section1, WheelTskBarVolINI, 0
	IniRead, wvisiop, %A_AppData%\Preme for Windows\premedata.ini, section1, VisibleOpINI, 0
	IniRead, wdiseachwin, %A_AppData%\Preme for Windows\premedata.ini, section1, DisEachWinINI, 0
	;KeyShortcutR done in submitANDdoBig
	IniRead, wreloadTime, %A_AppData%\Preme for Windows\premedata.ini, section1, reloadTimeINI, 5
	weasy := weasy0 || wvisiop

	IniRead, TLTslider, %A_AppData%\Preme for Windows\premedata.ini, section1, TLsliderINI, 0
	IniRead, TRTslider, %A_AppData%\Preme for Windows\premedata.ini, section1, TRsliderINI, 0
	IniRead, BLTslider, %A_AppData%\Preme for Windows\premedata.ini, section1, BLsliderINI, 0
	IniRead, BRTslider, %A_AppData%\Preme for Windows\premedata.ini, section1, BRsliderINI, 0
	
	IniRead, wshortcutModTL, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModTLINI
	IniRead, wshortcutModTR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModTRINI
	IniRead, wshortcutModBL, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModBLINI
	IniRead, wshortcutModBR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutModBRINI

	IniRead, wshortcutKeyTL, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyTLINI
	IniRead, wshortcutKeyTR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyTRINI
	IniRead, wshortcutKeyBL, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyBLINI
	IniRead, wshortcutKeyBR, %A_AppData%\Preme for Windows\premedata.ini, section1, shortcutKeyBRINI
	
	IniRead, CornerRunFileTLR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileTLINI
	IniRead, CornerRunFileTRR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileTRINI
	IniRead, CornerRunFileBLR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileBLINI
	IniRead, CornerRunFileBRR, %A_AppData%\Preme for Windows\premedata.ini, CornerRunFile, CornerRunFileBRINI
	
	TLsleepTime := (TLTslider*7)+(100*Ceil(TLTslider/100))
	TRsleepTime := (TRTslider*7)+(100*Ceil(TRTslider/100))
	BLsleepTime := (BLTslider*7)+(100*Ceil(BLTslider/100))
	BRsleepTime := (BRTslider*7)+(100*Ceil(BRTslider/100))
	
	if(wreloadTime == 5)
		wreloadTime := 10
	else if(wreloadTime > 3)
	{
		if(wreloadTime == 4)
			wreloadTime := 5
		else if(wreloadTime == 6)
			wreloadTime := 20
		else if(wreloadTime == 7)
			wreloadTime := 30
		else if(wreloadTime == 8)
			wreloadTime := 60
		else if(wreloadTime == 9)
			wreloadTime := 180
	}
	wreloadTime := wreloadTime*60000

	Gosub, EngineCode
return  ;submitANDdo


shortcutInputKeyMethod(shortcutparam)
{
	if(shortcutparam=="-")   ;shortcutparam==""
		return "vkbd"
	else if(shortcutparam=="=")
		return "vkbb"
	else if(shortcutparam=="[")
		return "vkdb"
	else if(shortcutparam=="]")
		return "vkdd"
	else if(shortcutparam=="\")
		return "vkdc"
	else if(shortcutparam==";")
		return "vkba"
	else if(shortcutparam=="'")
		return "vkde"
	else if(shortcutparam==",")
		return "vkbc"
	else if(shortcutparam==".")
		return "vkbe"
	else if(shortcutparam=="/")
		return "vkbf"
	else if(shortcutparam=="0")
		return "vk30"
	else if(shortcutparam=="1")
		return "vk31"
	else if(shortcutparam=="2")
		return "vk32"
	else if(shortcutparam=="3")
		return "vk33"
	else if(shortcutparam=="4")
		return "vk34"
	else if(shortcutparam=="5")
		return "vk35"
	else if(shortcutparam=="6")
		return "vk36"
	else if(shortcutparam=="7")
		return "vk37"
	else if(shortcutparam=="8")
		return "vk38"
	else if(shortcutparam=="9")
		return "vk39"
	else if(shortcutparam=="a")
		return "vk41"
	else if(shortcutparam=="b")
		return "vk42"
	else if(shortcutparam=="c")
		return "vk43"
	else if(shortcutparam=="d")
		return "vk44"
	else if(shortcutparam=="e")
		return "vk45"
	else if(shortcutparam=="f")
		return "vk46"
	else if(shortcutparam=="g")
		return "vk47"
	else if(shortcutparam=="h")
		return "vk48"
	else if(shortcutparam=="i")
		return "vk49"
	else if(shortcutparam=="j")
		return "vk4a"
	else if(shortcutparam=="k")
		return "vk4b"
	else if(shortcutparam=="l")
		return "vk4c"
	else if(shortcutparam=="m")
		return "vk4d"
	else if(shortcutparam=="n")
		return "vk4e"
	else if(shortcutparam=="o")
		return "vkef"
	else if(shortcutparam=="p")
		return "vk50"
	else if(shortcutparam=="q")
		return "vk51"
	else if(shortcutparam=="r")
		return "vk52"
	else if(shortcutparam=="s")
		return "vk53"
	else if(shortcutparam=="t")
		return "vk54"
	else if(shortcutparam=="u")
		return "vk55"
	else if(shortcutparam=="v")
		return "vk56"
	else if(shortcutparam=="w")
		return "vk57"
	else if(shortcutparam=="x")
		return "vk58"
	else if(shortcutparam=="y")
		return "vk59"
	else if(shortcutparam=="z")
		return "vk5a"
	else
		return shortcutparam
}

shortcutmodMethod(shortcutparam)
{
	if(shortcutparam=="-" || shortcutparam=="")
		return ""
	else if(shortcutparam=="Alt")
		return "!"
	else if(shortcutparam=="LAlt")
		return "<!"
	else if(shortcutparam=="RAlt")
		return ">!"
	else if(shortcutparam=="Ctrl")
		return "^"
	else if(shortcutparam=="LCtrl")
		return "<^"
	else if(shortcutparam=="RCtrl")
		return ">^"
	else if(shortcutparam=="Shift")
		return "+"
	else if(shortcutparam=="LShift")
		return "<+"
	else if(shortcutparam=="RShift")
		return ">+"
	else if(shortcutparam=="Win")
		return "#"
	else if(shortcutparam=="LWin")
		return "<#"
	else if(shortcutparam=="RWin")
		return ">#"
	else if(shortcutparam=="Ctrl+Alt")
		return "^!"
	else if(shortcutparam=="Ctrl+Shift")
		return "^+"
	else if(shortcutparam=="Ctrl+Win")
		return "^#"
	else if(shortcutparam=="Alt+Shift")
		return "!+"
	else if(shortcutparam=="Win+Alt")
		return "#!"
	else if(shortcutparam=="Win+Shift")
		return "#+"
	else if(shortcutparam=="CtrlAltShift")
		return "^!+"
	else
		return shortcutparam . " & "
}


sendInputMethod(modKey0, realKey)
{

	modKey := shortcutmodMethod(modKey0)
	if StrLen(realKey) == 0
	{
		sleep, 100
		sendinput {%modKey0%}
	}
	else if realKey is digit
		sendinput %modKey%{%realKey%}
	else if StrLen(realKey) > 1
		Send, %modKey%{%realKey%}
		;sendinput %modKey%{%realKey%}
	else
	{
		;apbcode := alphabettoSCmethod(realKey)
		;sendinput %modKey%{%apbcode%}
		if(realKey == "a")
			sendinput %modKey%{sc01e}
		else if(realKey == "b")
			sendinput %modKey%{sc030}
		else if(realKey == "c")
			sendinput %modKey%{sc02e}
		else if(realKey == "d")
			sendinput %modKey%{sc020}
		else if(realKey == "e")
			sendinput %modKey%{sc012}
		else if(realKey == "f")
			sendinput %modKey%{sc021}
		else if(realKey == "g")
			sendinput %modKey%{sc022}
		else if(realKey == "h")
			sendinput %modKey%{sc023}
		else if(realKey == "i")
			sendinput %modKey%{sc017}
		else if(realKey == "j")
			sendinput %modKey%{sc024}
		else if(realKey == "k")
			sendinput %modKey%{sc025}
		else if(realKey == "l")
			sendinput %modKey%{sc026}
		else if(realKey == "m")
			sendinput %modKey%{sc032}
		else if(realKey == "n")
			sendinput %modKey%{sc031}
		else if(realKey == "o")
			sendinput %modKey%{sc018}
		else if(realKey == "p")
			sendinput %modKey%{sc019}
		else if(realKey == "q")
			sendinput %modKey%{sc010}
		else if(realKey == "r")
			sendinput %modKey%{sc013}
		else if(realKey == "s")
			sendinput %modKey%{sc01f}
		else if(realKey == "t")
			sendinput %modKey%{sc014}
		else if(realKey == "u")
			sendinput %modKey%{sc016}
		else if(realKey == "v")
			sendinput %modKey%{sc02f}
		else if(realKey == "w")
			sendinput %modKey%{sc011}
		else if(realKey == "x")
			sendinput %modKey%{sc02d}
		else if(realKey == "y")
			sendinput %modKey%{sc015}
		else if(realKey == "z")
			sendinput %modKey%{sc02c}
		else
			sendinput %modKey%{%realKey%}

	}
}

;034 shortcutKeyTL Method
ShortcutKeyAndRunTLMethod:
	if(wuserkey1==1)
		sendInputMethod(wshortcutModTL, wshortcutKeyTL)
	else ;if(wrun1==1)
		Run, %CornerRunFileTLR%,, UseErrorLevel
return

;035 shortcutKeyTR Method
ShortcutKeyAndRunTRMethod:
	if(wuserkey2==1)
		sendInputMethod(wshortcutModTR, wshortcutKeyTR)
	else ;if(wrun2==1)
		Run, %CornerRunFileTRR%,, UseErrorLevel
return

;036 shortcutKeyBL Method
ShortcutKeyAndRunBLMethod:
	if(wuserkey3==1)
		sendInputMethod(wshortcutModBL, wshortcutKeyBL)
	else ;if(wrun3==1)
		Run, %CornerRunFileBLR%,, UseErrorLevel
return

;037 shortcutKeyBR Method
ShortcutKeyAndRunBRMethod:
	if(wuserkey4==1)
		sendInputMethod(wshortcutModBR, wshortcutKeyBR)
	else ;if(wrun4==1)
		Run, %CornerRunFileBRR%,, UseErrorLevel
return


;Top Left Each
ShortcutKeyEachTLMethod:
	WinGetClass, activeC, A
	if(activeC == TLEachText1R)
		sendInputMethod(TLEachModDDL1R, TLEachShcutDDL1R)
	else if(activeC == TLEachText2R)
		sendInputMethod(TLEachModDDL2R, TLEachShcutDDL2R)
	else if(activeC == TLEachText3R)
		sendInputMethod(TLEachModDDL3R, TLEachShcutDDL3R)
	else if(activeC == TLEachText4R)
		sendInputMethod(TLEachModDDL4R, TLEachShcutDDL4R)
	else if(activeC == TLEachText5R)
		sendInputMethod(TLEachModDDL5R, TLEachShcutDDL5R)	
return


;Top Right
ShortcutKeyEachTRMethod:
	WinGetClass, activeC, A
	if(activeC == TREachText1R)
		sendInputMethod(TREachModDDL1R, TREachShcutDDL1R)
	else if(activeC == TREachText2R)
		sendInputMethod(TREachModDDL2R, TREachShcutDDL2R)
	else if(activeC == TREachText3R)
		sendInputMethod(TREachModDDL3R, TREachShcutDDL3R)
	else if(activeC == TREachText4R)
		sendInputMethod(TREachModDDL4R, TREachShcutDDL4R)
	else if(activeC == TREachText5R)
		sendInputMethod(TREachModDDL5R, TREachShcutDDL5R)	
return


;Bottom Left
ShortcutKeyEachBLMethod:
	WinGetClass, activeC, A
	if(activeC == BLEachText1R)
		sendInputMethod(BLEachModDDL1R, BLEachShcutDDL1R)
	else if(activeC == BLEachText2R)
		sendInputMethod(BLEachModDDL2R, BLEachShcutDDL2R)
	else if(activeC == BLEachText3R)
		sendInputMethod(BLEachModDDL3R, BLEachShcutDDL3R)
	else if(activeC == BLEachText4R)
		sendInputMethod(BLEachModDDL4R, BLEachShcutDDL4R)
	else if(activeC == BLEachText5R)
		sendInputMethod(BLEachModDDL5R, BLEachShcutDDL5R)	
return


;Bottom Right
ShortcutKeyEachBRMethod:
	WinGetClass, activeC, A
	if(activeC == BREachText1R)
		sendInputMethod(BREachModDDL1R, BREachShcutDDL1R)
	else if(activeC == BREachText2R)
		sendInputMethod(BREachModDDL2R, BREachShcutDDL2R)
	else if(activeC == BREachText3R)
		sendInputMethod(BREachModDDL3R, BREachShcutDDL3R)
	else if(activeC == BREachText4R)
		sendInputMethod(BREachModDDL4R, BREachShcutDDL4R)
	else if(activeC == BREachText5R)
		sendInputMethod(BREachModDDL5R, BREachShcutDDL5R)	
return




WaitWindow:
	Gui, 2: +AlwaysOnTop +owner -MinimizeBox -DPIScale
	Gui, 2: Color, FFFFFF
	ScreenWidth  = %A_ScreenWidth%
	ScreenHeight = %A_ScreenHeight%
	Widthsmall := 244      ;265
	Heightsmall := 48	;+dpiV*(-5*(2-dpiV))      ;234  239
	posXTB := 0
	WinGetPos, posXTB, posYTB, WidTB, HidTB, ahk_class Shell_TrayWnd
	
	if(posXTB > A_ScreenWidth/3)
		bitTbLo := 2   ;right
	else if(posYTB > A_ScreenHeight/3)
		bitTbLo := 3   ;bottom
	else if(WidTB>2*A_ScreenWidth/3)
		bitTbLo := 1  ;top
	else
		bitTbLo := 0   ;left
	IniWrite, %bitTbLo%, %A_AppData%\Preme for Windows\premedata.ini, Operation, taskbarPos
	if(bitTbLo==2)
	{
		WinSmallPosX := posXTB-(Widthsmall+8+dpiV*(4*(2-dpiV)))
		WinSmallPosY := ScreenHeight-(Heightsmall+8+dpiV*(4*(2-dpiV)))
	}
	else if(bitTbLo==0)
	{
		WinSmallPosX := posXTB+WidTB+8+dpiV*(2*(2-dpiV))
		WinSmallPosY := ScreenHeight-(Heightsmall+8+dpiV*(4*(2-dpiV)))
	}
	else if(bitTbLo==1)
	{
		WinSmallPosX := ScreenWidth-(Widthsmall+8+dpiV*(4*(2-dpiV)))
		WinSmallPosY := posYTB+HidTB+8+dpiV*(2*(2-dpiV))
	}
	else	;if(bitTbLo==3) bottom taskbar position
	{
		WinSmallPosX := ScreenWidth-(Widthsmall+8+dpiV*(4*(2-dpiV)))
		WinSmallPosY := posYTB-(Heightsmall+8+dpiV*(4*(2-dpiV)))
	}
	if(WinSmallPosX < 0 || WinSmallPosX > 5000 || WinSmallPosY < 0 || WinSmallPosY > 4000)
	{
		WinSmallPosX := 800
		WinSmallPosY := 500
	}
	Gui, 2: Add, Picture, x0 y0, %A_AppData%\Preme for Windows\wait.jpg
	Gui, 2: -0xC40000
	Gui, 2: Show, x%WinSmallPosX% y%WinSmallPosY% h%Heightsmall% w%Widthsmall%, PremeWait		;new16
return	;WaitWindow






buildVisOptsGUI:
	MouseGetPos,,, idVO
	Gui, 2: Destroy
	;Tooltip, winver = %winver% dpiV= %dpiV%
	
	Gui, 2: +AlwaysOnTop +owner -MinimizeBox -DPIScale -0xC40000 
	;Gui, 2: 
	Gui, 2: Color, FFFFFF
	Gui, 2: Add, Picture, x0 y0 w200 h256, %A_AppData%\Preme for Windows\VisOpts\premeVO0.jpg								;static1
	Gui, 2: Add, Picture, x0 y0, %A_AppData%\Preme for Windows\VisOpts\premeVOa1.jpg										;static2
	Gui, 2: Add, Picture, x0 y0 galwaysOnTopMethod, %A_AppData%\Preme for Windows\VisOpts\premeVOa2.jpg						;static3
	Gui, 2: Add, Picture, x0 y0 galwaysOnTopMethod, %A_AppData%\Preme for Windows\VisOpts\premeVOa3.jpg						;static4
	Gui, 2: Add, Picture, x0 y74 gTouchSlideWinHotkeyLeftMethod, %A_AppData%\Preme for Windows\VisOpts\premeVOleft.jpg		;static5
	Gui, 2: Add, Picture, x50 y74 gTouchSlideWinHotkeyRightMethod, %A_AppData%\Preme for Windows\VisOpts\premeVOright.jpg	;static6
	Gui, 2: Add, Picture, x100 y74 gTouchSlideWinHotkeyTopMethod, %A_AppData%\Preme for Windows\VisOpts\premeVOup.jpg		;static7
	Gui, 2: Add, Picture, x150 y74 gTouchSlideWinHotkeyBottomMethod, %A_AppData%\Preme for Windows\VisOpts\premeVOdown.jpg	;static8
	Gui, 2: Add, Picture, x0 y154 gPositionWinL, %A_AppData%\Preme for Windows\VisOpts\premeVOleft.jpg						;static9
	Gui, 2: Add, Picture, x50 y154 gPositionWinR, %A_AppData%\Preme for Windows\VisOpts\premeVOright.jpg					;static10
	Gui, 2: Add, Picture, x100 y154 gPositionWinT, %A_AppData%\Preme for Windows\VisOpts\premeVOup.jpg						;static11
	Gui, 2: Add, Picture, x150 y154 gPositionWinB, %A_AppData%\Preme for Windows\VisOpts\premeVOdown.jpg					;static12
	Gui, 2: Add, Picture, x0 y202 gPositionWinTL, %A_AppData%\Preme for Windows\VisOpts\premeVOleftup.jpg					;static13
	Gui, 2: Add, Picture, x50 y202 gPositionWinTR, %A_AppData%\Preme for Windows\VisOpts\premeVOrightup.jpg					;static14
	Gui, 2: Add, Picture, x100 y202 gPositionWinBL, %A_AppData%\Preme for Windows\VisOpts\premeVOleftdown.jpg				;static15
	Gui, 2: Add, Picture, x150 y202 gPositionWinBR, %A_AppData%\Preme for Windows\VisOpts\premeVOrightdown.jpg				;static16
	
	;WinGet, idVO, ID, A
	WinGet, ExStyleVO, ExStyle, ahk_id %idVO%
	;if this window is not on top,
	if !(ExStyleVO & 0x8)
		GuiControl, 2: Hide, static2
	GuiControl, 2: Hide, static3
	GuiControl, 2: Hide, static4
	GuiControl, 2: Hide, static5
	GuiControl, 2: Hide, static6
	GuiControl, 2: Hide, static7
	GuiControl, 2: Hide, static8
	GuiControl, 2: Hide, static9
	GuiControl, 2: Hide, static10
	GuiControl, 2: Hide, static11
	GuiControl, 2: Hide, static12
	GuiControl, 2: Hide, static13
	GuiControl, 2: Hide, static14
	GuiControl, 2: Hide, static15
	GuiControl, 2: Hide, static16

	WinVisOPosX := 500		;in case the var is blank
	WinVisOPosY := 500		;in case the var is blank
	WidthVisO := 200
	HeightVisO := 256
	WinGetPos, posXA, posYA, WidA,, ahk_id %idVO%
	if(posYA == "" || posYA == "ERROR")
		return
	SysGet, MonitorCount, MonitorCount
	SysGet, Mon1, Monitor, 1
	if(MonitorCount == 1)
	{
		leftRes := Mon1Left
		rightRes := Mon1Right
		bottomRes := Mon1Bottom
	}
	else
	{
		SysGet, Mon2, Monitor, 2
		if(MonitorCount > 2)
		{
			SysGet, Mon3, Monitor, 3
			SysGet, Mon4, Monitor, 4
		}
		if(posXA+WidA-36 > Mon1Left && posXA+WidA-36 < Mon1Right && posYA+28 > Mon1Top && posYA+28 < Mon1Bottom)
		{
			leftRes := Mon1Left
			rightRes := Mon1Right
			bottomRes := Mon1Bottom
		}
		else if(posXA+WidA-36 > Mon2Left && posXA+WidA-36 < Mon2Right && posYA+28 > Mon2Top && posYA+28 < Mon2Bottom)
		{
			leftRes := Mon2Left
			rightRes := Mon2Right
			bottomRes := Mon2Bottom
		}
		else if(MonitorCount > 2 && posXA+WidA-36 > Mon3Left && posXA+WidA-36 < Mon3Right && posYA+28 > Mon3Top && posYA+28 < Mon3Bottom)
		{
			leftRes := Mon3Left
			rightRes := Mon3Right
			bottomRes := Mon3Bottom
		}
		else if(MonitorCount > 3 && posXA+WidA-36 > Mon4Left && posXA+WidA-36 < Mon4Right && posYA+28 > Mon4Top && posYA+28 < Mon4Bottom)
		{
			leftRes := Mon4Left
			rightRes := Mon4Right
			bottomRes := Mon4Bottom
		}
		else
			freeFromEdge := 1
	}

	WinGet, MaxOrNot, MinMax, ahk_id %idVO%
	
	if(MaxOrNot == 1)
	{
		WinVisOPosX := rightRes-WidthVisO-8
		WinVisOPosY := posYA+underminmaxcloseMain+4
	}
	else
	{
		if(rightRes-posXA-WidA < (WidthVisO/2)-38 && freeFromEdge != 1)
			WinVisOPosX := rightRes-WidthVisO-8
		else if(posXA+WidA-leftRes-36 < (WidthVisO/2)+8 && freeFromEdge != 1)
			WinVisOPosX := leftRes+8
		else
			WinVisOPosX := posXA+WidA-(WidthVisO/2)-38
		WinVisOPosY := posYA+underminmaxcloseMain+4
	}
	if(bottomRes-posYA < HeightVisO+24)
		WinVisOPosY := posYA-HeightVisO-10
	Gui, 2: Show, x%WinVisOPosX% y%WinVisOPosY% h%HeightVisO% w%WidthVisO% Hide, PremeVisOpts
	Gui, 2: +LastFound
	WinSet, Transparent, 0	;, PremeVisOpts ahk_class PremeforWin
	Gui, 2: Show
	WinGet, idPremeVisOpts, ID	;, PremeVisOpts ahk_class PremeforWin
	
	tran := 0
	Loop, 6
	{
		tran += 43
		sleep, 10
		WinSet, Transparent, %tran%, ahk_id %idPremeVisOpts%
	}
	; IfWinActive, ahk_id %idPremeVisOpts%
		; WinActivate,  ahk_id %idVO%
	oldHoldNum := 0
	SetTimer, CheckVisOptsGUI, 100
return		;buildVisOptsGUI

CloseVisOptsGUInow:
	SetTimer, CheckVisOptsGUI, Off
	WinActivate,  ahk_id %idVO%
	Gui , 2: Destroy
	idVO := ""
return		;CloseVisOptsGUInow

CloseVisOptsGUI:
	SetTimer, CheckVisOptsGUI, Off
	tran := 255
	Loop, 10
	{
		tran -= 26
		sleep, 10
		WinSet, Transparent, %tran%, ahk_id %idPremeVisOpts%
	}
	Gui , 2: Destroy
	idVO := ""
return		;CloseVisOptsGUI

CheckVisOptsGUI:
	CoordMode, Mouse, Screen
	MouseGetPos, XXX, YYY     ;, idsmall
	WinGet, idCVO, ID, A
	
	;if the pointer is outside for 20 px, close window.
	if (XXX<WinVisOPosX-20|| XXX>WinVisOPosX+220 || YYY<WinVisOPosY-50 || YYY>WinVisOPosY+296 || (idCVO != idVO && idCVO != idPremeVisOpts))
	{
		Gosub, CloseVisOptsGUI
	}
	;if it's outside, turn oldHoldNum to 0.
	else if (XXX<WinVisOPosX || XXX>WinVisOPosX+200 || YYY<WinVisOPosY || YYY>WinVisOPosY+256)
	{
		if(oldHoldNum != 0)
		{
			GuiControl, 2: Hide, % "static" . oldHoldNum
			oldHoldNum := 0
		}
	}
	;else if it's inside.
	else
	{
		;Divide case by y axis. the 1st row
		if(YYY<WinVisOPosY+44)
		{
			;if this window is on top,
			if (ExStyleVO & 0x8)
			{
				if(oldHoldNum != 4)
				{
					GuiControl, 2: Show, static4
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 4
				}
			}
			else
			{
				if(oldHoldNum != 3)
				{
					GuiControl, 2: Show, static3
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 3
				}
			}
		}
		;the 2nd row
		else if (YYY>WinVisOPosY+73 && YYY<WinVisOPosY+123)
		{
			if(XXX>WinVisOPosX && XXX<WinVisOPosX+51)
			{
				if(oldHoldNum != 5)
				{
					GuiControl, 2: Show, static5
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 5
				}
			}
			else if(XXX>WinVisOPosX+50 && XXX<WinVisOPosX+101)
			{
				if(oldHoldNum != 6)
				{
					GuiControl, 2: Show, static6
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 6
				}
			}
			else if(XXX>WinVisOPosX+100 && XXX<WinVisOPosX+151)
			{
				if(oldHoldNum != 7)
				{
					GuiControl, 2: Show, static7
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 7
				}
			}
			else ;if(XXX>WinVisOPosX+150 && XXX<WinVisOPosX+201)
			{
				if(oldHoldNum != 8)
				{
					GuiControl, 2: Show, static8
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 8
				}
			}
		}
		;the 3rd row
		else if (YYY>WinVisOPosY+153 && YYY<WinVisOPosY+203)
		{
			if(XXX>WinVisOPosX && XXX<WinVisOPosX+51)
			{
				
				if(oldHoldNum != 9)
				{
					GuiControl, 2: Show, static9
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 9
				}
			}
			else if(XXX>WinVisOPosX+50 && XXX<WinVisOPosX+101)
			{
				
				if(oldHoldNum != 10)
				{
					GuiControl, 2: Show, static10
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 10
				}
			}
			else if(XXX>WinVisOPosX+100 && XXX<WinVisOPosX+151)
			{
				
				if(oldHoldNum != 11)
				{
					GuiControl, 2: Show, static11
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 11
				}
			}
			else ;if(XXX>WinVisOPosX+150 && XXX<WinVisOPosX+201)
			{
				
				if(oldHoldNum != 12)
				{
					GuiControl, 2: Show, static12
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 12
				}
			}
		}
		;the 4th row
		else if (YYY>WinVisOPosY+201) ;&& YYY<WinVisOPosY+203)
		{
			if(XXX>WinVisOPosX && XXX<WinVisOPosX+51)
			{
				
				if(oldHoldNum != 13)
				{
					GuiControl, 2: Show, static13
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 13
				}
			}
			else if(XXX>WinVisOPosX+50 && XXX<WinVisOPosX+101)
			{
				
				if(oldHoldNum != 14)
				{
					GuiControl, 2: Show, static14
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 14
				}
			}
			else if(XXX>WinVisOPosX+100 && XXX<WinVisOPosX+151)
			{
				
				if(oldHoldNum != 15)
				{
					GuiControl, 2: Show, static15
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 15
				}
			}
			else ;if(XXX>WinVisOPosX+150 && XXX<WinVisOPosX+201)
			{
				
				if(oldHoldNum != 16)
				{
					GuiControl, 2: Show, static16
					GuiControl, 2: Hide, % "static" . oldHoldNum
					oldHoldNum := 16
				}
			}
		}
		else
		{
			if(oldHoldNum != 0)
			{
				GuiControl, 2: Hide, % "static" . oldHoldNum
				oldHoldNum := 0
			}
		}
	}
return		;CheckVisOptsGUI



;038 SmallPremeGUI
SmallPremeGUI:
	WinGet, tran, Transparent, PremeSmall ahk_class PremeforWin
	;WinGetPos,,, WWW,, ahk_class PremeforWin
	if(tran == 255)
	{
		;SetTimer, CheckMostGUI, off
		Gosub, writeAssignAndHideSmallWin
		if(A_IsCompiled)
		{
			if(enableVar == 1)
				Gosub, reloadpremeengMethod	;there are run premeeng.exe and reload every 15 minutes.
			else
			{
				Process, Close, premeeng.exe
				Gosub, buildSmallPremeGUI
				OnMessage(0x5556, "")
			}
		}
		return
	}
	else if WinExist("ahk_exe PremeInterface.exe")	; and (WWW > 400)	;big win
	{
		
		WinActivate, Preme for Windows  ;, %GUITitle% ahk_class PremeforWin
		;WinHide, PremeSmall ahk_class PremeforWin
	}
	else if WinExist("PremeWait")
	{}
	else 	;if (smallwinon != 1)  ;There is for no error compiler window.
	{
		WinShow, PremeSmall	ahk_class PremeforWin
		SetTimer, CheckMostGUI, 100
		WinSet, Transparent, 255, PremeSmall ahk_class PremeforWin
		;WinShow, PremeSmall ahk_class PremeforWin
		WinActivate, PremeSmall ahk_class PremeforWin
		SetTimer, CheckMouse, off
		SetTimer, runpremeengMethod, off
		;smallwinon = 1
	}
return	;SmallPremeGUI

buildSmallPremeGUI:
	;038a read INI, add picture, add checkbox, etc.
	
	Gui, Destroy
	IniRead, appstate, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate, 1
	Gui, +AlwaysOnTop +owner -MinimizeBox -DPIScale  
	Gui, Color, FFFFFF
	Gui, Add, Picture, x0 y0, %A_AppData%\Preme for Windows\premesmall.jpg
	Gui, Add, Picture, x0 y184 gfullprememethod, %A_AppData%\Preme for Windows\optionsPure.jpg				;static2
	Gui, Add, Picture, x0 y184 gfullprememethod, %A_AppData%\Preme for Windows\optionsShadow.jpg			;static3	2
	Gui, Add, Picture, x0 y82 genablemethod, %A_AppData%\Preme for Windows\onPure.jpg						;static4	
	Gui, Add, Picture, x0 y82, %A_AppData%\Preme for Windows\onGrey.jpg										;static5	3
	Gui, Add, Picture, x0 y82 genablemethod, %A_AppData%\Preme for Windows\OnShadow.jpg						;static6	4
	Gui, Add, Picture, x136 y82 gdisablemethod, %A_AppData%\Preme for Windows\offPure.jpg					;static7
	Gui, Add, Picture, x136 y82, %A_AppData%\Preme for Windows\offGrey.jpg									;static8	5
	Gui, Add, Picture, x136 y82 gdisablemethod, %A_AppData%\Preme for Windows\OffShadow.jpg					;static9	6
	Gui, Add, Picture, x184 y157 gPclose, %A_AppData%\Preme for Windows\closeAppPic.jpg						;static10	7
	
	GuiControl, Hide, static3
	GuiControl, Hide, static6
	GuiControl, Hide, static9
	GuiControl, Hide, static10
	if(appstate == 1)
	{
		GuiControl, Hide, static5
	}
	else
		GuiControl, Hide, static8

	enableVar := appstate
	;Calculate the position
	ScreenWidth  = %A_ScreenWidth%
	ScreenHeight = %A_ScreenHeight%
	Widthsmall := 271      ;265
	Heightsmall := 267	;+dpiV*(-5*(2-dpiV))      ;234  239
	
	; sleep, 3000
	WinGetPos, posXTB, posYTB, WidTB, HidTB, ahk_class Shell_TrayWnd
	if(posXTB == "" || posXTB == "ERROR")
	{
		TC := A_TickCount
		Loop,{
			sleep, 500
			WinGetPos, posXTB, posYTB, WidTB, HidTB, ahk_class Shell_TrayWnd
			if(posXTB != "")
				break
			else if(A_TickCount-TC > 10000)
			{
				posXTB := 0
				posYTB := ScreenHeight - 40
				break
			}
		}
	}
	
	if(posXTB > A_ScreenWidth/3)
		bitTbLo := 2   ;right
	else if(posYTB > A_ScreenHeight/3)
		bitTbLo := 3   ;bottom
	else if(WidTB>2*A_ScreenWidth/3)
		bitTbLo := 1  ;top
	else
		bitTbLo := 0   ;left
	
	if(bitTbLo==2)
	{
		WinSmallPosX := posXTB-(Widthsmall+8+dpiV*(4*(2-dpiV)))
		WinSmallPosY := ScreenHeight-(Heightsmall+8+dpiV*(4*(2-dpiV)))
	}
	else if(bitTbLo==0)
	{
		WinSmallPosX := posXTB+WidTB+8+dpiV*(2*(2-dpiV))
		WinSmallPosY := ScreenHeight-(Heightsmall+8+dpiV*(4*(2-dpiV)))
	}
	else if(bitTbLo==1)
	{
		WinSmallPosX := ScreenWidth-(Widthsmall+8+dpiV*(4*(2-dpiV)))
		WinSmallPosY := posYTB+HidTB+8+dpiV*(2*(2-dpiV))
	}
	else	;if(bitTbLo==3) bottom taskbar position
	{
		WinSmallPosX := ScreenWidth-(Widthsmall+8+dpiV*(4*(2-dpiV)))
		WinSmallPosY := posYTB-(Heightsmall+8+dpiV*(4*(2-dpiV)))
	}
	
	Gui, -0xC40000
	if(WinSmallPosX < 0 || WinSmallPosX > 5000 || WinSmallPosY < 0 || WinSmallPosY > 4000)
	{
		WinSmallPosX := 800
		WinSmallPosY := 500
	}
	Gui, Show, x%WinSmallPosX% y%WinSmallPosY% h%Heightsmall% w%Widthsmall% Hide, PremeSmall		;new16
	; Gui, +MinSize%Widthsmall%x%Heightsmall%
	; Gui, +MaxSize%Widthsmall%x%Heightsmall%
Return  	;buildSmallPremeGUI




;038b CheckMostGUI function
CheckMostGUI:
	IfWinNotActive, PremeSmall ahk_class PremeforWin
	IfWinNotActive, ahk_class Shell_TrayWnd
	{
		Gosub, writeAssignAndHideSmallWin
		;SetTimer, CheckMostGUI, off
		
		if(A_IsCompiled)
			if(enableVar == 1)
				Gosub, reloadpremeengMethod
			else
			{
				Process, Close, premeeng.exe
				Gosub, buildSmallPremeGUI
				OnMessage(0x5556, "")
			}
		return
	}
	CoordMode, Mouse, Relative
	MouseGetPos, XXX, YYY     ;, idsmall
	;add X is 8, Y is 10.
	
	if (XXX<271 && XXX>0 && YYY<267 && YYY>187)
		GuiControl, Show, static3
	else	;if !(XXX<165 && XXX>91 && YYY<260 && YYY>241)
		GuiControl, Hide, static3	
	
	if (XXX<137 && XXX>0 && YYY<154 && YYY>76)
		GuiControl, Show, static6
	else if (enableVar==1&&!(XXX<137 && XXX>0 && YYY<154 && YYY>76))
	{
		GuiControl, Hide, static5
		GuiControl, Hide, static6
	}
	else if !(XXX<137 && XXX>0 && YYY<154 && YYY>76)
	{
		GuiControl, Show, static5
		GuiControl, Hide, static6	
	}
	
	if (XXX<271 && XXX>137 && YYY<154 && YYY>76)
		GuiControl, Show, static9
	else if (enableVar!=1&&!(XXX<271 && XXX>137 && YYY<154 && YYY>76))
	{
		GuiControl, Hide, static8
		GuiControl, Hide, static9
	}
	else if !(XXX<271 && XXX>137 && YYY<154 && YYY>76)
	{
		GuiControl, Show, static8
		GuiControl, Hide, static9
	}
	
	if (XXX<269 && XXX>184 && YYY<185 && YYY>157)
		GuiControl, Show, static10
	else
		GuiControl, Hide, static10

return  ;CheckMostGUI








;038c writeAssignAndHideSmallWin function
writeAssignAndHideSmallWin:
	;Gui, submit, NoHide
	;smallwinon = 0
	WinHide, PremeSmall ahk_class PremeforWin
	WinSet, Transparent, 0, PremeSmall ahk_class PremeforWin
	SetTimer, CheckMostGUI, off
	IniWrite, %enableVar%, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate            ;0 is off, other is on
return    ;writeAssignAndHideSmallWin   


;038d fullprememethod, enablemethod, disablemethod disableTouchSlide enableTouchSlide
fullprememethod:
	WinHide, PremeSmall ahk_class PremeforWin
	WinSet, Transparent, 0, PremeSmall ahk_class PremeforWin
	SetTimer, CheckMostGUI, off
	Gosub, MainPremeInterface
return   ;fullprememethod

enablemethod:
	enableVar := 1
return    ;enablemethod

disablemethod:
	enableVar := -1
return   ;disablemethod

;9grey   10highblack  11highgrey
disableTouchSlide:
	easy := 0
	GuiControl, Show, static11
	GuiControl, Show, static9
	GuiControl, Hide, static10
return

enableTouchSlide:
	easy := 1
	GuiControl, Show, static10
	GuiControl, Hide, static11
	GuiControl, Hide, static9
return






;039 smallUpdateWin function
smallUpdateWin:
	Gui, Destroy
	if(A_IsCompiled)
		sleep, 3000
	Gui, +AlwaysOnTop +owner +Resize    
	Gui, Color, FFFFFF
	ScreenWidth  = %A_ScreenWidth%
	ScreenHeight = %A_ScreenHeight%
	Widthsmall := 340
	Heightsmall := 115
	WinGetPos, posXTB, posYTB, WidTB, HidTB, ahk_class Shell_TrayWnd
	if(posXTB == "" || posXTB == "ERROR")
	{
		posXTB := 0
		posYTB := ScreenHeight - 40
		HidTB := 40
	}
	
	if(posXTB > A_ScreenWidth/3)
		bitTbLo := 2   ;right
	else if(posYTB > A_ScreenHeight/3)
		bitTbLo := 3   ;bottom
	else if(WidTB>2*A_ScreenWidth/3)
		bitTbLo := 1  ;top
	else 
		bitTbLo := 0   ;left
	
	if(bitTbLo==0)
	{
		WinSmallPosX := posXTB+WidTB+8+dpiV*(2*(2-dpiV))
		WinSmallPosY := ScreenHeight-(Heightsmall+24+dpiV*(4*(2-dpiV)))
	}
	else if(bitTbLo==1)
	{
		WinSmallPosX := ScreenWidth-(Widthsmall+24+dpiV*(4*(2-dpiV)))
		WinSmallPosY := posYTB+HidTB+8+dpiV*(2*(2-dpiV))
	}
	else if(bitTbLo==2)
	{
		WinSmallPosX := posXTB-(Widthsmall+24+dpiV*(4*(2-dpiV)))
		WinSmallPosY := ScreenHeight-(Heightsmall+24+dpiV*(4*(2-dpiV)))
	}
	else 	;if(bitTbLo==3)
	{
		WinSmallPosX := ScreenWidth-(Widthsmall+24+dpiV*(4*(2-dpiV)))
		WinSmallPosY := posYTB-(Heightsmall+24+dpiV*(4*(2-dpiV)))
	}
	;Tooltip, %bitTbLo% x %WinSmallPosX% %ScreenWidth% y %dpiV%
	fsize8 := 8 - dpiV*(2*(2-dpiV))
	fsize9 := 9 - dpiV*(2*(2-dpiV))
	fsize12 := 12 - dpiV*(3*(2-dpiV))
	fsize14 := 14 - dpiV*(2*(2-dpiV))
	fsize15 := 15 - dpiV*(2*(2-dpiV))
	fsize18 := 18 - dpiV*(2*(2-dpiV))
	Gui, font, s%fsize12% w400, Segoe UI Light
	Gui, Add, Text, x0 y8 w%Widthsmall% h30 Center, Preme for Windows needs an update.
	;Gui, font, s%fsize12% w400, Segoe UI Light
	Gui, Add, Text, x0 y38 w%Widthsmall% h26 Center, before the expire date. (%expiredDateStr%)
	FileGetTime, TodayTime, C:\Windows\WindowsUpdate.log, M
	if(TodayTime > expiredDate)  ;real expire date   20110525000000  
	{
			Gui, font, s%fsize8%, Segoe UI Light
			Gui, Add, Text, x272 y92 cNavy gUpdateEndWin, End Process
			Gui, Add, Text, x8 y92 cNavy gDownloadmanual, Download manually
	}
	else   ;near expire
	{
			Gui, font, s%fsize9%, Segoe UI Light
			Gui, Add, Text, x304 y92 w26 h14 cNavy gUpdateLater, Later
	}	
	Gui, font, s%fsize16% w400, Segoe UI Light
	if !InStr(A_ScriptDir, A_Startup)
		Gui, Add, Button, x104 y67 w140 h36 gUpdateButton, Update
	else
		Gui, Add, Button, x104 y67 w140 h36 gDownloadmanual, Website

	if !(WinSmallPosX > 0 && WinSmallPosX < 5000 && WinSmallPosY > 0 && WinSmallPosY < 4000)
	{
		WinSmallPosX := 700
		WinSmallPosY := 500
	}
	Gui, -0xC00000 +0x800000
	Gui, Show, x%WinSmallPosX% y%WinSmallPosY% h%Heightsmall% w%Widthsmall%, smallUpdate ahk_class PremeforWin
	Gui, +MinSize%Widthsmall%x%Heightsmall%
	Gui, +MaxSize%Widthsmall%x%Heightsmall%
	;WinSet, Style, -0x9680000, smallUpdate ahk_class PremeforWin
return             ;smallUpdateWin

;040 UpdateLater, UpdateEndWin, Downloadmanual UpdateButton
UpdateLater:
	Gui, Destroy
return     ;UpdateLater        

UpdateEndWin:
	Process, close, premeeng.exe
	ExitApp		;33 exception
return    ;UpdateEndWin

Downloadmanual:
	Run www.premeforwindows.com
	Process, close, premeeng.exe
	ExitApp		;34 exception
return   ;Downloadmanual

UpdateButton:
	ControlGetText, buttonUpdateString, button1
	ControlGetText, staticUpdateString, static3

	;disable the button if possible.
	if(buttonUpdateString == "Update")
	{
		GuiControl, Text, static2, Checking for update...
		Gosub, CheckForUpdateMethod
	}
	else if(staticUpdateString == "Later")
	{
		Run www.premeforwindows.com
		Gui, Destroy
	}
	else
	{
		Run www.premeforwindows.com
		sleep, 1500
		ExitApp
	}
return    ;UpdateButton




;041 WM_DISPLAYCHANGE(wParam, lParam) function
WM_DISPLAYCHANGE(wParam, lParam)
{
	Global ScWidth  := A_ScreenWidth
	Global ScHeight := A_ScreenHeight
	Global idtouch1, idtouch3, idtouch5, idtouch6
	;MsgBox, changeD%ScWidth%
	WinSet, Transparent, 1, ahk_id %idtouch1%
	WinSet, Transparent, 1, ahk_id %idtouch3%
	WinSet, Transparent, 1, ahk_id %idtouch5%
	WinSet, Transparent, 1, ahk_id %idtouch6%
	sleep, 100

	;041a if MonitorCount =1
	SysGet, MonitorCount, MonitorCount
	if(MonitorCount==1)
	{
		Global topLeftX := 0
		Global topLeftY := 0
		Global topRightX := ScWidth-1
		Global topRightY := 0
		Global lowLeftX := 0
		Global lowLeftY := ScHeight-1
		Global lowRightX := ScWidth-1
		Global lowRightY := ScHeight-1
		Global touchSlideTopX := ScWidth/2
		Global touchSlideTopY := 0
		Global touchSlideLeftX := 0
		Global touchSlideLeftY := ScHeight/2
		Global touchSlideRightX := ScWidth-1
		Global touchSlideRightY := ScHeight/2
		Global touchSlideBottomX := ScWidth/2
		Global touchSlideBottomY := ScHeight-1
	}
	;041b else if MonitorCount =2
	else if(MonitorCount==2)
	{
		;SysGet, MonitorPrimary, MonitorPrimary
		SysGet, Mon1, Monitor, 1 
		SysGet, Mon2, Monitor, 2
		if(Mon1Right == Mon2Left)	;Mon1 is on the left side of Mon2
		{
			Global topLeftX := Mon1Left
			Global topLeftY := Mon1Top
			Global topRightX := Mon2Right-1
			Global topRightY := Mon2Top
			Global lowLeftX := Mon1Left
			Global lowLeftY := Mon1Bottom-1
			Global lowRightX := Mon2Right-1
			Global lowRightY := Mon2Bottom-1
			Global touchSlideTopX := ScWidth/2
			Global touchSlideTopY := 0
			Global touchSlideLeftX := Mon1Left
			Global touchSlideLeftY := (Mon1Top+Mon1Bottom)/2
			Global touchSlideRightX := Mon2Right-1
			Global touchSlideRightY := (Mon2Top+Mon2Bottom)/2
			Global touchSlideBottomX := ScWidth/2
			Global touchSlideBottomY := ScHeight-1
		}
		else if(Mon1Left == Mon2Right) 	;Mon1 is on the right side of Mon2
		{
			Global topLeftX := Mon2Left
			Global topLeftY := Mon2Top
			Global topRightX := Mon1Right-1
			Global topRightY := Mon1Top
			Global lowLeftX := Mon2Left
			Global lowLeftY := Mon2Bottom-1
			Global lowRightX := Mon1Right-1
			Global lowRightY := Mon1Bottom-1
			Global touchSlideTopX := ScWidth/2
			Global touchSlideTopY := 0
			Global touchSlideLeftX := Mon2Left
			Global touchSlideLeftY := (Mon2Top+Mon2Bottom)/2
			Global touchSlideRightX := Mon1Right-1
			Global touchSlideRightY := (Mon1Top+Mon1Bottom)/2
			Global touchSlideBottomX := ScWidth/2
			Global touchSlideBottomY := ScHeight-1
		}
		else if(Mon1Bottom == Mon2Top)		;Mon1 is over Mon2
		{
			Global topLeftX := Mon1Left
			Global topLeftY := Mon1Top
			Global topRightX := Mon1Right-1
			Global topRightY := Mon1Top
			Global lowLeftX := Mon2Left
			Global lowLeftY := Mon2Bottom-1
			Global lowRightX := Mon2Right-1
			Global lowRightY := Mon2Bottom-1
			Global touchSlideTopX := (Mon1Left+Mon1Right)/2
			Global touchSlideTopY := Mon1Top
			Global touchSlideLeftX := 0
			Global touchSlideLeftY := ScHeight/2
			Global touchSlideRightX := ScWidth-1
			Global touchSlideRightY := ScHeight/2
			Global touchSlideBottomX := (Mon2Left+Mon2Right)/2
			Global touchSlideBottomY := Mon2Bottom-1
		}
		else							;Mon1 is under Mon2
		{
			Global topLeftX := Mon2Left
			Global topLeftY := Mon2Top
			Global topRightX := Mon2Right-1
			Global topRightY := Mon2Top
			Global lowLeftX := Mon1Left
			Global lowLeftY := Mon1Bottom-1
			Global lowRightX := Mon1Right-1
			Global lowRightY := Mon1Bottom-1
			Global touchSlideTopX := (Mon2Left+Mon2Right)/2
			Global touchSlideTopY := Mon2Top
			Global touchSlideLeftX := 0
			Global touchSlideLeftY := ScHeight/2
			Global touchSlideRightX := ScWidth-1
			Global touchSlideRightY := ScHeight/2
			Global touchSlideBottomX := (Mon1Left+Mon1Right)/2
			Global touchSlideBottomY := Mon1Bottom-1
		}
		
	}
	;041c else if MonitorCount = 3
	else    ;3 or more
	{
		SysGet, MonitorPrimary, MonitorPrimary
		SysGet, Mon1, Monitor, 1 
		SysGet, Mon2, Monitor, 2 
		SysGet, Mon3, Monitor, 3
		
		Global touchSlideTopX := ScWidth/2
		Global touchSlideTopY := 0
		Global touchSlideBottomX := ScWidth/2
		Global touchSlideBottomY := ScHeight-1
		
		if(Mon1Left<Mon2Left)	;12
		{
			if(Mon1Left<Mon3Left)	;13
			{
				if(Mon2Left<Mon3Left)	;123
				{
					Global topLeftX := Mon1Left
					Global topLeftY := Mon1Top
					Global topRightX := Mon3Right-1
					Global topRightY := Mon3Top
					Global lowLeftX := Mon1Left
					Global lowLeftY := Mon1Bottom-1
					Global lowRightX := Mon3Right-1
					Global lowRightY := Mon3Bottom-1
					Global touchSlideLeftX := Mon1Left
					Global touchSlideLeftY := (Mon1Top+Mon1Bottom)/2
					Global touchSlideRightX := Mon3Right-1
					Global touchSlideRightY := (Mon3Top+Mon3Bottom)/2
				}
				else					;132
				{
					Global topLeftX := Mon1Left
					Global topLeftY := Mon1Top
					Global topRightX := Mon2Right-1
					Global topRightY := Mon2Top
					Global lowLeftX := Mon1Left
					Global lowLeftY := Mon1Bottom-1
					Global lowRightX := Mon2Right-1
					Global lowRightY := Mon2Bottom-1
					Global touchSlideLeftX := Mon1Left
					Global touchSlideLeftY := (Mon1Top+Mon1Bottom)/2
					Global touchSlideRightX := Mon2Right-1
					Global touchSlideRightY := (Mon2Top+Mon2Bottom)/2
				}
			}
			else						;312
			{
				Global topLeftX := Mon3Left
				Global topLeftY := Mon3Top
				Global topRightX := Mon2Right-1
				Global topRightY := Mon2Top
				Global lowLeftX := Mon3Left
				Global lowLeftY := Mon3Bottom-1
				Global lowRightX := Mon2Right-1
				Global lowRightY := Mon2Bottom-1
				Global touchSlideLeftX := Mon3Left
				Global touchSlideLeftY := (Mon3Top+Mon3Bottom)/2
				Global touchSlideRightX := Mon2Right-1
				Global touchSlideRightY := (Mon2Top+Mon2Bottom)/2
			}
		}
		else ;2 1
		{
			if(Mon1Left>Mon3Left)	;3 1
			{
				if(Mon2Left>Mon3Left)	;321
				{
					Global topLeftX := Mon3Left
					Global topLeftY := Mon3Top
					Global topRightX := Mon1Right-1
					Global topRightY := Mon1Top
					Global lowLeftX := Mon3Left
					Global lowLeftY := Mon3Bottom-1
					Global lowRightX := Mon1Right-1
					Global lowRightY := Mon1Bottom-1
					Global touchSlideLeftX := Mon3Left
					Global touchSlideLeftY := (Mon3Top+Mon3Bottom)/2
					Global touchSlideRightX := Mon1Right-1
					Global touchSlideRightY := (Mon1Top+Mon1Bottom)/2
				}
				else					;231
				{
					Global topLeftX := Mon2Left
					Global topLeftY := Mon2Top
					Global topRightX := Mon1Right-1
					Global topRightY := Mon1Top
					Global lowLeftX := Mon2Left
					Global lowLeftY := Mon2Bottom-1
					Global lowRightX := Mon1Right-1
					Global lowRightY := Mon1Bottom-1
					Global touchSlideLeftX := Mon2Left
					Global touchSlideLeftY := (Mon2Top+Mon2Bottom)/2
					Global touchSlideRightX := Mon1Right-1
					Global touchSlideRightY := (Mon1Top+Mon1Bottom)/2
				}
			}
			else			;213
			{
				Global topLeftX := Mon2Left
				Global topLeftY := Mon2Top
				Global topRightX := Mon1Right-1
				Global topRightY := Mon1Top
				Global lowLeftX := Mon2Left
				Global lowLeftY := Mon2Bottom-1
				Global lowRightX := Mon1Right-1
				Global lowRightY := Mon1Bottom-1
				Global touchSlideLeftX := Mon2Left
				Global touchSlideLeftY := (Mon2Top+Mon2Bottom)/2
				Global touchSlideRightX := Mon3Right-1
				Global touchSlideRightY := (Mon3Top+Mon3Bottom)/2
			}
		}

	}

	IfWinExist, ahk_id %idtouch1% 
	{
		WinGetPos, , , Wid, Hid, ahk_id %idtouch1%
		destX := topleftX-Wid+touchSlideXvar
		destY := (ScHeight-Hid-26)/2
		WinMove, ahk_id %idtouch1%,, %destX%, %destY%
		WinSet, Transparent, 255, ahk_id %idtouch1% 
	}
	IfWinExist, ahk_id %idtouch3% 
	{
		WinGetPos, , , , Hid, ahk_id %idtouch3%
		destXIn3 := toprightX-touchSlideXvar
		destYIn3 := (ScHeight-Hid-26)/2
		WinMove, ahk_id %idtouch3%,, %destXIn3%, %destYIn3%
		WinSet, Transparent, 255, ahk_id %idtouch3% 
	}
	IfWinExist, ahk_id %idtouch5% 
	{
		WinGetPos, , , Wid, Hid, ahk_id %idtouch5%
		destXIn6 := (ScWidth-Wid)/2
		destYIn6 := -Hid+touchSlideYvar
		WinMove, ahk_id %idtouch5%,, %destXIn5%, %destYIn5%
		WinSet, Transparent, 255, ahk_id %idtouch5% 
	}

	IfWinExist, ahk_id %idtouch6% 
	{
		WinGetPos, , , Wid, , ahk_id %idtouch6%
		destXIn6 := (ScWidth-Wid)/2
		destYIn6 := ScHeight-touchSlideYvar

		WinMove, ahk_id %idtouch6%,, %destXIn6%, %destYIn6%
		WinSet, Transparent, 255, ahk_id %idtouch6% 
	}


	Global w3d := 0
	Global wTaskSwitcher := 0
	Global wstartButton := 0
	Global whideactive := 0
	Global whideactiveTopRight := 1
	Global wuserkeyrun1 := 0
	Global wuserkeyrun2 := 0
	Global wuserkeyrun3 := 0
	Global wuserkeyrun4 := 0 
	Global wuserkey1 := 0
	Global wuserkey2 := 0
	Global wuserkey3 := 0
	Global wuserkey4 := 0 
	; Global wrun1 := 0
	; Global wrun2 := 0
	; Global wrun3 := 0
	; Global wrun4 := 0
	Global f0x = topRightX
	Global f0y = topRightY

	IfWinExist, ahk_id %idtouch5%
		Global wSlideFromTop := 1
	else
		Global wSlideFromTop := 0

	;Taskbar position detection
	WinGetPos, posXTB, posYTB, WidTB, HidTB, ahk_class Shell_TrayWnd
	if(posXTB > ScWidth/3)
		Global bitTbLo := 2   ;right
	else if(posYTB > ScHeight/3)
		Global bitTbLo := 3   ;buttom
	else if(WidTB>2*ScWidth/3)
		Global bitTbLo := 1  ;top
	else 
		Global bitTbLo := 0   ;left

	if(bitTbLo==3)   ;Bottom  #1
	{
		IniRead, CornerTopLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopLeft3INI
		IniRead, CornerTopRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopRight3INI
		IniRead, CornerBottomLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomLeft3INI
		IniRead, CornerBottomRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomRight3INI
	}
	else if(bitTbLo==1)    ;Top  #2
	{
		IniRead, CornerTopLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopLeft1INI
		IniRead, CornerTopRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopRight1INI
		IniRead, CornerBottomLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomLeft1INI
		IniRead, CornerBottomRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomRight1INI
	}
	else if(bitTbLo==0)   ;Left  #3
	{
		IniRead, CornerTopLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopLeft0INI
		IniRead, CornerTopRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopRight0INI
		IniRead, CornerBottomLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomLeft0INI
		IniRead, CornerBottomRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomRight0INI
	}
	else if(bitTbLo==2)     ;Right  #4
	{
		IniRead, CornerTopLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopLeft2INI
		IniRead, CornerTopRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerTopRight2INI
		IniRead, CornerBottomLeft3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomLeft2INI
		IniRead, CornerBottomRight3R, %A_AppData%\Preme for Windows\premedata.ini, CornerSec, CornerBottomRight2INI
	}
	
	;topLeft3
	if(CornerTopLeft3R=="Touch Start")
	{
		Global wstartButton := 1
		Global b0x = topleftX
		Global b0y = topleftY
		IniRead, TLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TLsliderINI, 0
		Global touchStartsleepTime := (TLsliderR*7)+(100*Ceil(TLsliderR/100))
	}
	else if(CornerTopLeft3R=="Aero Flip 3D")
	{
		Global w3d := 1
		Global a0x = topLeftX
		Global a0y = topLeftY
		IniRead, TLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TLsliderINI, 0
		Global aeroFlipsleepTime := (TLsliderR*7)+(100*Ceil(TLsliderR/100))
	}
	else if(CornerTopLeft3R=="Task Switcher")
	{
		Global wTaskSwitcher := 1
		Global aa0x = topLeftX
		Global aa0y = topLeftY
		IniRead, TLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TLsliderINI, 0
		Global taskSwitchsleepTime := (TLsliderR*7)+(100*Ceil(TLsliderR/100))
	}
	else if(CornerTopLeft3R=="Hide Active")
	{
		Global whideactive := 1
		Global whideactiveTopRight := 0
		Global e0x = topLeftX
		Global e0y = topLeftY
		Global e0x_exten := topLeftX+50
		Global e0y_exten := topLeftY+18
		Global e0x_corner = topLeftX
		Global e0y_corner = topLeftY
	}
	else if(CornerTopLeft3R=="Shortcut Key")
	{
		Global wuserkeyrun1 := 1
		Global wuserkey1 := 1
	}
	else if(CornerTopLeft3R=="Open Any Files")
	{
		Global wuserkeyrun1 := 1
		;Global wrun1 := 1
	}
	
	;TopRight3
	if(CornerTopRight3R=="Touch Start")
	{
		Global wstartButton := 1
		Global b0x = topRightX
		Global b0y = topRightY
		IniRead, TRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TRsliderINI, 0
		Global touchStartsleepTime := (TRsliderR*7)+(100*Ceil(TRsliderR/100))
	}
	else if(CornerTopRight3R=="Aero Flip 3D")
	{
		Global w3d := 1
		Global a0x = topRightX
		Global a0y = topRightY
		IniRead, TRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TRsliderINI, 0
		Global aeroFlipsleepTime := (TRsliderR*7)+(100*Ceil(TRsliderR/100))
	}
	else if(CornerTopRight3R=="Task Switcher")
	{
		Global wTaskSwitcher := 1
		Global aa0x = topRightX
		Global aa0y = topRightY
		IniRead, TRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, TRsliderINI, 0
		Global taskSwitchsleepTime := (TRsliderR*7)+(100*Ceil(TRsliderR/100))
	}
	else if(CornerTopRight3R=="Hide Active")
	{
		Global whideactive := 1
		Global e0x = topRightX-50
		Global e0y = topRightY
		Global e0x_exten := topRightX
		Global e0y_exten := topRightY+18
		Global e0x_corner = topRightX
		Global e0y_corner = topRightY
	}
	else if(CornerTopRight3R=="Shortcut Key")
	{
		Global wuserkeyrun2 := 1
		Global wuserkey2 := 1
	}
	else if(CornerTopRight3R=="Open Any Files")
	{
		Global wuserkeyrun2 := 1
		;Global wrun2 := 1
	}
	
	;LowLeft3
	if(CornerBottomLeft3R=="Touch Start")
	{
		Global wstartButton := 1
		if(Mon1Left<Mon2Left && MonitorPrimary == 2 && Mon1Bottom<Mon2Bottom)
		{
			Global b0x = Mon2Left
			Global b0y = Mon2Bottom - 1
		}
		else if(Mon2Left<Mon1Left && MonitorPrimary == 1 && Mon2Bottom<Mon1Bottom)
		{
			Global b0x = Mon1Left
			Global b0y = Mon1Bottom - 1
		}
		else
		{
			Global b0x = lowleftX
			Global b0y = lowleftY
		}
		IniRead, BLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BLsliderINI, 0
		Global touchStartsleepTime := (BLsliderR*7)+(100*Ceil(BLsliderR/100))
	}
	else if(CornerBottomLeft3R=="Aero Flip 3D")
	{
		Global w3d := 1		
		Global a0x = lowleftX
		Global a0y = lowleftY
		IniRead, BLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BLsliderINI, 0
		Global aeroFlipsleepTime := (BLsliderR*7)+(100*Ceil(BLsliderR/100))
	}
	else if(CornerBottomLeft3R=="Task Switcher")
	{
		Global wTaskSwitcher := 1	
		Global aa0x = lowleftX
		Global aa0y = lowleftY
		IniRead, BLsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BLsliderINI, 0
		Global taskSwitchsleepTime := (BLsliderR*7)+(100*Ceil(BLsliderR/100))
	}
	else if(CornerBottomLeft3R=="Hide Active")
	{
		Global whideactive := 1
		Global whideactiveTopRight := 0
		Global e0x = lowleftX
		Global e0y = lowleftY-18
		Global e0x_exten := lowleftX+50
		Global e0y_exten := lowleftY
		Global e0x_corner = lowleftX
		Global e0y_corner = lowleftY
	}
	else if(CornerBottomLeft3R=="Shortcut Key")
	{
		Global wuserkeyrun3 := 1
		Global wuserkey3 := 1
	}
	else if(CornerBottomLeft3R=="Open Any Files")
	{
		Global wuserkeyrun3 := 1
		;Global wrun3 := 1
	}
	
	;LowRight3
	if(CornerBottomRight3R=="Touch Start")
	{
		Global wstartButton := 1
		Global b0x = lowRightX
		Global b0y = lowRightY
		IniRead, BRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BRsliderINI, 0
		Global touchStartsleepTime := (BRsliderR*7)+(100*Ceil(BRsliderR/100))
	}
	else if(CornerBottomRight3R=="Aero Flip 3D")
	{
		Global w3d := 1	
		Global a0x = lowRightX
		Global a0y = lowRightY
		IniRead, BRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BRsliderINI, 0
		Global aeroFlipsleepTime := (BRsliderR*7)+(100*Ceil(BRsliderR/100))
	}
	else if(CornerBottomRight3R=="Task Switcher")
	{
		Global wTaskSwitcher := 1
		Global aa0x = lowRightX
		Global aa0y = lowRightY
		IniRead, BRsliderR, %A_AppData%\Preme for Windows\premedata.ini, section1, BRsliderINI, 0
		Global taskSwitchsleepTime := (BRsliderR*7)+(100*Ceil(BRsliderR/100))
	}
	else if(CornerBottomRight3R=="Hide Active")
	{
		Global whideactive := 1
		Global whideactiveTopRight := 0
		Global e0x = lowRightX-50
		Global e0y = lowRightY-18
		Global e0x_exten := lowRightX
		Global e0y_exten := lowRightY
		Global e0x_corner = lowRightX
		Global e0y_corner = lowRightY
	}
	else if(CornerBottomRight3R=="Shortcut Key")
	{
		Global wuserkeyrun4 := 1
		Global wuserkey4 := 1
	}
	else if(CornerBottomRight3R=="Open Any Files")
	{
		Global wuserkeyrun4 := 1
		;Global wrun4 := 1
	}
	Gosub buildSmallPremeGUI

}   ;WM_DISPLAYCHANGE



;043 ExitSub function
ExitSub:
	;write log everytime preme is closed.
	FormatTime, TimeString,, yyyyMMddHHmmss
	FileAppend , %TimeString% reason is %A_ExitReason%.`n, %A_AppData%\Preme for Windows\premelog
	
	if (A_ExitReason == "Logoff") || (A_ExitReason == "Shutdown")
	{
		Gosub Pclose
	}
	else if (A_ExitReason == "Exit") 
	{
		SplashImage, Off
		Msgbox, This Preme for Windows process is ordered to be closed. OK to terminate this process.
		;Gosub, rollBackTSW
		;IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate  ;0 is closed.
		;Process, close, premeeng.exe
		ExitApp         ;Menu
	}
	else if (A_ExitReason == "Reload")
	{
		ExitApp         ;Menu
	}
	else if (A_ExitReason == "Single")
	{
		menu, tray, NoIcon
		ExitApp
	}
	else	;(A_ExitReason == "Close") is too.
	{
		FormatTime, TimeStringCl,, yyyyMMddHHmmss
		IniRead, TimeStringRe, %A_AppData%\Preme for Windows\premedata.ini, section3, closeTimeINI, 0
		if(TimeStringCl-TimeStringRe < 10)		;if it happens again within 10 seconds
			MsgBox, 64, Preme for Windows, Preme is subjected to be closed by the reason = %A_ExitReason%
		sleep, 2000
		IniWrite, %TimeStringCl%, %A_AppData%\Preme for Windows\premedata.ini, section3, closeTimeINI
		IniWrite, %A_ExitReason%, %A_AppData%\Preme for Windows\premedata.ini, section3, exitReasonINI
		Run, %A_AppData%\Preme for Windows\bin\preme.exe exitsub,, UseErrorLevel
		ExitApp
		;send to balloon
	}
return    ;ExitSub



TouchSlideWinTop:
	SetTimer, CheckMouse, off
	Winset, Disable ,,ahk_id %idLButton%
	IfWinExist, ahk_id %idtouch5%   
	{
		;Deactivate window out
		WinGet, MaxOrNot, MinMax, ahk_id %idtouch5%
		if(MaxOrNot == -1)  ;-1 is minimized
			WinRestore, ahk_id %idtouch5%
		
		WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch5%
		destX := posXkeep5
		destY := posYkeep5
		Divider := Sqrt(Sqrt(((destX-Xpos)**2)+((destY-Ypos)**2)))//2.2
		PerdestX := (destX-Xpos)/Divider
		PerdestY := (destY-Ypos)/Divider

		Loop, %Divider%
		{
			Xpos += PerdestX
			Ypos += PerdestY
			SetWinDelay, 2
			WinMove, ahk_id %idtouch5%,, %Xpos%, %Ypos%   ;, %Wid%, %Hid%
		}

		if(Wid != sizeXkeep5) || (Hid != sizeYkeep5)
		{
			PersizeX := (sizeXkeep5-Wid)/6
			PersizeY := (sizeYkeep5-Hid)/6
			Loop, 6
			{
				Wid += PersizeX
				Hid += PersizeY
				SetWinDelay, 2
				WinMove, ahk_id %idtouch5%,,,, %Wid%, %Hid%
			}
		}
		Winset, Enable ,,ahk_id %idtouch5%
		if(!winuptop)
			WinSet, AlwaysOnTop, Off, ahk_id %idtouch5%		
		sleep, 40
	}
	
	;remember if the window cursor pointing is Always on top or not.
	WinGet, ExStyleL, ExStyle, ahk_id %idLButton%
	if(ExStyleL & 0x8)
		winuptop := 1
	else
		winuptop := 0
	
	;Activate window in
	WinSet, AlwaysOnTop, On, ahk_id %idLButton%
	wSlideFromTop := 1
	WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idLButton%
	posXkeep5 := Xpos
	posYkeep5 := Ypos
	sizeXkeep5 := Wid
	sizeYkeep5 := Hid

	Widbegin := Wid
	Hidbegin :=	Hid	
	
	if(Wid>(4*ScWidth)/5)
		Wid := 4*ScWidth/5
	if(Hid>(5*ScHeight)/6)
		Hid := 5*ScHeight/6
	
	destX := touchSlideTopX - Wid/2
	destY := touchSlideTopY - Hid + touchSlideYvar
	Divider := Round(Sqrt(Sqrt(((destX-Xpos)**2)+((destY-Ypos)**2)))//2.2)
	PerdestX := (destX-Xpos)/Divider
	PerdestY := (destY-Ypos)/Divider
	
	Loop, %Divider%
	{
		Xpos += PerdestX
		Ypos += PerdestY
		
		SetWinDelay, 2
		WinMove, ahk_id %idLButton%,, %Xpos%, %Ypos% 
	}
	
	if(Wid != sizeXkeep5) || (Hid != sizeYkeep5)
	{
		PersizeX := (sizeXkeep5-Wid)/6
		PersizeY := (sizeYkeep5-Hid)/6
		Loop, 6
		{
			Widbegin -= PersizeX
			Hidbegin -= PersizeY	
			SetWinDelay, 2
			WinMove, ahk_id %idLButton%,,,, %Widbegin%, %Hidbegin%
		}
	}
			
	sleep, 50
	IfWinExist, ahk_id %idtouch5% 
	{
		WinActivate, ahk_id %idtouch5%
	}
	else
	{
		Send !{ESC}
		sleep, 100
		send {Alt Up}
	}
	WinGet, idnow05, ID, A
	if idnow05 in %idLButton%
		WinActivate, Program Manager ahk_class Progman
		
	idtouch5 = %idLButton%
	SetTimer, CheckMouse, 100
	IniWrite, %idLButton%, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch5INI
	IniWrite, %posXkeep5%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep5INI
	IniWrite, %posYkeep5%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posYkeep5INI
	IniWrite, %sizeXkeep5%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep5INI
	IniWrite, %sizeYkeep5%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep5INI
return		;TouchSlideWinTop


TouchSlideWinLeft:
	SetTimer, CheckMouse, off
	Winset, Disable ,,ahk_id %idLButton%
	IfWinExist, ahk_id %idtouch1%   
	{
		;Deactivate window out
		WinGet, MaxOrNot, MinMax, ahk_id %idtouch1%
		if(MaxOrNot == -1)  ;-1 is minimized
			WinRestore, ahk_id %idtouch1%
		
		WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch1%
		destX := posXkeep1
		destY := posYkeep1
		Divider := Sqrt(Sqrt(((destX-Xpos)**2)+((destY-Ypos)**2)))//2.2
		PerdestX := (destX-Xpos)/Divider
		PerdestY := (destY-Ypos)/Divider
		
		Loop, %Divider%
		{
			Xpos += PerdestX
			Ypos += PerdestY
			SetWinDelay, 2
			WinMove, ahk_id %idtouch1%,, %Xpos%, %Ypos% 
		}
		
		if(Wid != sizeXkeep1) || (Hid != sizeYkeep1)
		{
			PersizeX := (sizeXkeep1-Wid)/6
			PersizeY := (sizeYkeep1-Hid)/6
			Loop, 6
			{
				Wid += PersizeX
				Hid += PersizeY
				SetWinDelay, 2
				WinMove, ahk_id %idtouch1%,,,, %Wid%, %Hid%
			}
		}
		
		Winset, Enable ,,ahk_id %idtouch1%
		if(winlefttop != 1)
			WinSet, AlwaysOnTop, Off, ahk_id %idtouch1%
		sleep, 40
		
	}

	;remember if it is Always on top or not.
	WinGet, ExStyleL, ExStyle, ahk_id %idLButton% 
	if(ExStyleL & 0x8)
		winlefttop := 1
	else
		winlefttop := 0
	
	;Activate window in
	WinSet, AlwaysOnTop, On, ahk_id %idLButton%
	WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idLButton%
	posXkeep1 := Xpos
	posYkeep1 := Ypos
	sizeXkeep1 := Wid
	sizeYkeep1 := Hid
	
	Widbegin := Wid
	Hidbegin :=	Hid	
	
	if(Wid>(4*ScWidth)/5)
		Wid := 4*ScWidth/5
	if(Hid>(8*ScHeight)/10)
		Hid := 8*ScHeight/10
	
	destX := touchSlideLeftX-Wid+touchSlideXvar
	destY := touchSlideLeftY - Hid/2
	
	Divider := Round(Sqrt(Sqrt(((destX-Xpos)**2)+((destY-Ypos)**2)))//2.2)
	
	PerdestX := (destX-Xpos)/Divider
	PerdestY := (destY-Ypos)/Divider
	Loop, %Divider%
	{
		Xpos += PerdestX
		Ypos += PerdestY
		
		SetWinDelay, 2
		WinMove, ahk_id %idLButton%,, %Xpos%, %Ypos% 
	}

	if(Wid != sizeXkeep1)		; || (Hid != sizeYkeep1)
	{
		PersizeX := (sizeXkeep1-Wid)/6
		PersizeY := (sizeYkeep1-Hid)/6
		Loop, 6
		{
			Widbegin -= PersizeX
			Hidbegin -= PersizeY	
			SetWinDelay, 2
			WinMove, ahk_id %idLButton%,,,, %Widbegin%, %Hidbegin%
		}
	}	
	sleep, 50
	
	IfWinExist, ahk_id %idtouch1% 
	{
		WinActivate, ahk_id %idtouch1%	
	}
	else
	{
		Send !{ESC}    ;not Bug
		sleep, 100
		send {Alt Up}
	}
	
	WinGet, idnow01, ID, A
	if idnow01 in %idLButton%
		WinActivate, Program Manager ahk_class Progman

	idtouch1 = %idLButton% 
	SetTimer, CheckMouse, 100
	IniWrite, %idLButton%, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch1INI
	IniWrite, %posXkeep1%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep1INI
	IniWrite, %posYkeep1%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posYkeep1INI
	IniWrite, %sizeXkeep1%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep1INI
	IniWrite, %sizeYkeep1%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep1INI
	
return		;TouchSlideWinLeft



TouchSlideWinRight:
	SetTimer, CheckMouse, off
	Winset, Disable ,,ahk_id %idLButton%
	IfWinExist, ahk_id %idtouch3%   
	{	;Move win out
		WinGet, MaxOrNot, MinMax, ahk_id %idtouch3%
			if(MaxOrNot == -1)
			WinRestore, ahk_id %idtouch3%
		WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch3%
		
		destX3 := posXkeep3
		destY3 := posYkeep3
		
		Divider := Sqrt(Sqrt(((destX3-Xpos)**2)+((destY3-Ypos)**2)))//2.2
		
		PerdestX3 := (destX3-Xpos)/Divider
		PerdestY3 := (destY3-Ypos)/Divider
		
		Loop, %Divider%
		{
			Xpos += PerdestX3
			Ypos += PerdestY3
			SetWinDelay, 2
			WinMove, ahk_id %idtouch3%,, %Xpos%, %Ypos%     ;,,%Hid%
		}
		
		if(Wid != sizeXkeep3) || (Hid != sizeYkeep3)
		{
			PersizeX := (sizeXkeep3-Wid)/6
			PersizeY := (sizeYkeep3-Hid)/6
			Loop, 6
			{
				Wid += PersizeX
				Hid += PersizeY
				SetWinDelay, 2
				WinMove, ahk_id %idtouch3%,,,, %Wid%, %Hid%
			}
		}
		
		if(!winrighttop)
			WinSet, AlwaysOnTop, Off, ahk_id %idtouch3%
		Winset, Enable ,,ahk_id %idtouch3%
	}
	WinGet, ExStyleL, ExStyle, ahk_id %idLButton% 
	if(ExStyleL & 0x8)
		winrighttop := 1
	else
		winrighttop := 0

	dddd:= 0
	;Move win in to right
	WinSet, AlwaysOnTop, On, ahk_id %idLButton%
	WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idLButton%
	posXkeep3 := Xpos
	posYkeep3 := Ypos
	sizeXkeep3 := Wid
	sizeYkeep3 := Hid
	
	Widbegin := Wid
	Hidbegin := Hid	
	
	if(Wid>(4*ScWidth)/5)
		Wid := 4*ScWidth/5
	if(Hid>(8*ScHeight)/10)
		Hid := 8*ScHeight/10
	
	destXIn3 := touchSlideRightX-touchSlideXvar
	destYIn3 := touchSlideLeftY - Hid/2
	
	Divider := Sqrt(Sqrt(((destXIn3-Xpos)**2)+((destYIn3-Ypos)**2)))//2.2
	
	PerdestXIn3 := (destXIn3-Xpos)/Divider
	PerdestYIn3 := (destYIn3-Ypos)/Divider
	
	Loop, %Divider%
	{
		Xpos += PerdestXIn3
		Ypos += PerdestYIn3
		SetWinDelay, 2
		WinMove, ahk_id %idLButton%,, %Xpos%, %Ypos%     ;,, %Hidbegin%
	}
	
	if(Wid != sizeXkeep3) || (Hid != sizeYkeep3)
	{
		PersizeX := (sizeXkeep3-Wid)/6
		PersizeY := (sizeYkeep3-Hid)/6
		Loop, 6
		{
			Widbegin -= PersizeX
			Hidbegin -= PersizeY	
			SetWinDelay, 2
			WinMove, ahk_id %idLButton%,,,, %Widbegin%, %Hidbegin%
		}
	}

	IfWinExist, ahk_id %idtouch3% 
	{
		WinActivate, ahk_id %idtouch3%
		;WinSet, AlwaysOnTop, Off, ahk_id %idtouch3%
	}
	else
	{
		Send !{ESC}  ;not Bug
		sleep, 100
		send {Alt Up}
	}
	WinGet, idnow01, ID, A
	if idnow01 in %idLButton%
		WinActivate, Program Manager ahk_class Progman
		
	idtouch3 = %idLButton%
	SetTimer, CheckMouse, 100
	IniWrite, %idLButton%, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch3INI
	IniWrite, %posXkeep3%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep3INI
	IniWrite, %posYkeep3%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posYkeep3INI
	IniWrite, %sizeXkeep3%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep3INI
	IniWrite, %sizeYkeep3%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep3INI
return		;TouchSlideWinRight





TouchSlideWinBottom:
	SetTimer, CheckMouse, off
	Winset, Disable ,,ahk_id %idLButton%				
	IfWinExist, ahk_id %idtouch6%   
	{ ;Move win out
		WinGet, MaxOrNot, MinMax, ahk_id %idtouch6%
		if(MaxOrNot == -1)
			WinRestore, ahk_id %idtouch6%
		WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch6%
		
		destX6 := posXkeep6
		destY6 := posYkeep6
		
		Divider := Sqrt(Sqrt(((destX6-Xpos)**2)+((destY6-Ypos)**2)))//2.2
		
		PerdestX6 := (destX6-Xpos)/Divider
		PerdestY6 := (destY6-Ypos)/Divider
		
		Loop, %Divider%
		{
			Xpos += PerdestX6
			Ypos += PerdestY6
			SetWinDelay, 2
			WinMove, ahk_id %idtouch6%,, %Xpos%, %Ypos%     ;,,%Hid%
		}
		
		if(Wid != sizeXkeep6) || (Hid != sizeYkeep6)
		{
			PersizeX := (sizeXkeep6-Wid)/6
			PersizeY := (sizeYkeep6-Hid)/6
			Loop, 6
			{
				Wid += PersizeX
				Hid += PersizeY
				SetWinDelay, 2
				WinMove, ahk_id %idtouch6%,,,, %Wid%, %Hid%
			}
		}
		if(!winundertop)
			WinSet, AlwaysOnTop, Off, ahk_id %idtouch6%
		Winset, Enable ,,ahk_id %idtouch6%
		
	}
	
	WinGet, ExStyleL, ExStyle, ahk_id %idLButton%
	if(ExStyleL & 0x8)
		winundertop := 1
	else
		winundertop := 0
	
	;Move win in to beneath
	WinSet, AlwaysOnTop, On, ahk_id %idLButton%
	WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idLButton%
	posXkeep6 := Xpos
	posYkeep6 := Ypos
	sizeXkeep6 := Wid
	sizeYkeep6 := Hid
	
	
	Widbegin := Wid
	Hidbegin := Hid	
	
	if(Wid>(4*ScWidth)/5)
		Wid := 4*ScWidth/5
	if(Hid>(5*ScHeight)/6)
		Hid := 5*ScHeight/6
	
	destXIn6 := touchSlideBottomX - Wid/2
	destYIn6 := touchSlideBottomY - touchSlideYvar
	
	Divider := Sqrt(Sqrt(((destXIn6-Xpos)**2)+((destYIn6-Ypos)**2)))//2.2
	
	PerdestXIn6 := (destXIn6-Xpos)/Divider
	PerdestYIn6 := (destYIn6-Ypos)/Divider
	
	Loop, %Divider%
	{
		Xpos += PerdestXIn6
		Ypos += PerdestYIn6
		SetWinDelay, 2
		WinMove, ahk_id %idLButton%,, %Xpos%, %Ypos%
	}
	
	if(Wid != sizeXkeep6) || (Hid != sizeYkeep6)
	{
		PersizeX := (sizeXkeep6-Wid)/6
		PersizeY := (sizeYkeep6-Hid)/6
		Loop, 6
		{
			Widbegin -= PersizeX
			Hidbegin -= PersizeY	
			SetWinDelay, 2
			WinMove, ahk_id %idLButton%,,,, %Widbegin%, %Hidbegin%
		}
		
	}
	
	IfWinExist, ahk_id %idtouch6% 
	{
		WinActivate, ahk_id %idtouch6%
		;WinSet, AlwaysOnTop, Off, ahk_id %idtouch6%
	}
	else
	{
		Send !{ESC}  ;not Bug
		sleep, 100
		send {Alt Up}
	}
	WinGet, idnow01, ID, A
	if idnow01 in %idLButton%
		WinActivate, Program Manager ahk_class Progman
	
	idtouch6 = %idLButton%
	SetTimer, CheckMouse, 100
	IniWrite, %idLButton%, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch6INI
	IniWrite, %posXkeep6%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posXkeep6INI
	IniWrite, %posYkeep6%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, posYkeep6INI
	IniWrite, %sizeXkeep6%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeXkeep6INI
	IniWrite, %sizeYkeep6%, %A_AppData%\Preme for Windows\premedata.ini, WinKeepPos, sizeYkeep6INI
return		;TouchSlideWinBottom





CheckMouse:                   ; check mouse position
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY, idtouch
	;WinGetClass, classEveryCheck, ahk_id %idtouch%
	;WinGet, MaxActiveWin, MinMax, A

	;044a11 if the pointer is at the screen corner
	if((MouseX==topleftX && MouseY==topleftY) || (MouseX==toprightX && MouseY==toprightY) || (MouseX==lowleftX && MouseY==lowleftY) || (MouseX==lowrightX && MouseY==lowrightY))
	{	; all 4 options
		WinGetClass, activeC, A
	
		
		;Top Left
		if(enableTLeach && MouseY==topleftY && MouseX==topleftX && (activeC==TLEachText1R || activeC==TLEachText2R || activeC==TLEachText3R || activeC==TLEachText4R || activeC==TLEachText5R))
		{
			;no need to check full-screen
			sleep, %TLsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")
			WinGet, MaxenTL, MinMax, ahk_class %activeC%
			if(!LDown022 and MouseY==topleftY and MouseX==topleftX and MaxenTL!=-1)
			{
				Gosub, ShortcutKeyEachTLMethod
				sleep, 100
				Loop, {      ;Loop for protecting swapting again and again
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==topleftY and MouseX==topleftX)
						Break
				}
			}
			else	;if(LDown22 and MouseY==topleftY and MouseX==topleftX)
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==topleftY and MouseX==topleftX)
						Break							
				}									
			}
		}
		
		;Top Right
		else if(enableTReach && MouseY==topRightY && MouseX==topRightX && (activeC==TREachText1R || activeC==TREachText2R || activeC==TREachText3R || activeC==TREachText4R || activeC==TREachText5R))
		{
			;no need to check full-screen
			sleep, %TRsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")
			WinGet, MaxenTR, MinMax, ahk_class %activeC%
			if(!LDown022 and MouseY==topRightY and MouseX==topRightX and MaxenTR!=-1)
			{
				Gosub, ShortcutKeyEachTRMethod
				sleep, 100
				Loop, {      ;Loop for protecting swapting again and again
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==topRightY and MouseX==topRightX)
						Break
				}
			}
			else	;if(LDown22 and MouseY==topRightY and MouseX==topRightX)
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==topRightY and MouseX==topRightX)
						Break							
				}									
			}
		}
		
		;Bottom Left
		else if(enableBLeach && MouseY==lowLeftY && MouseX==lowLeftX && (activeC==BLEachText1R || activeC==BLEachText2R || activeC==BLEachText3R || activeC==BLEachText4R || activeC==BLEachText5R))
		{
			;no need to check full-screen
			sleep, %BLsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")
			WinGet, MaxenBL, MinMax, ahk_class %activeC%
			if(!LDown022 and MouseY==lowLeftY and MouseX==lowLeftX and MaxenBL!=-1)
			{
				Gosub, ShortcutKeyEachBLMethod
				sleep, 100
				Loop, {      ;Loop for protecting swapting again and again
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==lowLeftY and MouseX==lowLeftX)
						Break
				}
			}
			else	;if(LDown22 and MouseY==lowLeftY and MouseX==lowLeftX)
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==lowLeftY and MouseX==lowLeftX)
						Break							
				}									
			}
		}
		
		;Bottom Right
		else if(enableBReach && MouseY==lowRightY && MouseX==lowRightX && (activeC==BREachText1R || activeC==BREachText2R || activeC==BREachText3R || activeC==BREachText4R || activeC==BREachText5R))
		{
			;no need to check full-screen
			sleep, %BRsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")
			WinGet, MaxenBR, MinMax, ahk_class %activeC%			
			if(!LDown022 and MouseY==lowRightY and MouseX==lowRightX and MaxenBR!=-1)
			{
				Gosub, ShortcutKeyEachBRMethod
				sleep, 100
				Loop, {      ;Loop for protecting swapting again and again
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==lowRightY and MouseX==lowRightX)
						Break
				}
			}
			else	;if(LDown22 and MouseY==lowRightY and MouseX==lowRightX)
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==lowRightY and MouseX==lowRightX)
						Break							
				}									
			}
		}
		

		;044a112 if pointer is near the Hide active corner(Hide active)
		else if(whideactive && (MouseX == e0x || MouseX == e0x_exten) && (MouseY == e0y || MouseY == e0y_exten))
		{
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
			{						
				e := 0
				Loop, 
				{
					;before this sleep500 and check mouse pos to break or not
					LDown00 := GetKeyState("LButton","P")
					if(e=0 and !LDown00)
					{
						WinGet, idtoplefttran, ID, A
						WinGet, MaxOrNot, MinMax, A
							
						sleep, 300
						;if(MaxOrNot==1) &&(MouseX != e0x_corner || MouseY != e0y_corner)
						;break

						if(whideactiveTopRight)&&(MaxOrNot==1)
							sleep, 200
					}
					MouseGetPos, MouseX, MouseY
					if(MouseX < e0x || MouseY<e0y || MouseX > e0x_exten || MouseY > e0y_exten)    
					{                ;outside show up by increasing tran

						;WinGet, MaxOrNot, MinMax, ahk_id %idtoplefttran%
						WinGet, ExStyletran, ExStyle, ahk_id %idtoplefttran%

						if  !(ExStyletran & 0x100) || (ExStyletran & 0x80)
						{
							;Do nothing
						}
						else if(e==1)
						{
							;tran := 0
							Loop, 8
							{
								tran += 32
								sleep, 10
								WinSet, Transparent, %tran%, ahk_id %idtoplefttran%
							}
							idtoplefttran := 0x
						}

						Break

					}
					else if (e=0)
					{
						e := 1
						WinGet, MaxOrNot, MinMax, ahk_id %idtoplefttran%
						WinGet, ExStyletran, ExStyle, ahk_id %idtoplefttran%

						if  !(ExStyletran & 0x100) || (ExStyletran & 0x80) || (MaxOrNot==1 &&(MouseX != e0x_corner || MouseY != e0y_corner))
						{
							;Do nothing
						}
						else
						{
							;WinGet, idtoplefttran, ID, A
							tran := 255
							Loop, 10
							{
								tran -= 25
								sleep, 20
								WinSet, Transparent, %tran%, ahk_id %idtoplefttran%
							}
						}
					}  ;else if (e=0)
					sleep, 100
				}
			}
			 ;button color
		}


		;044a113 if pointer is near the AeroFlip3D corner(w3d)
		else if (w3d and MouseY==a0y and MouseX==a0x)
		{  ;Win 3D code
		
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			
			if WinActive("ahk_class Flip3D") 
			{
				send, {Enter}					
				Loop, {      ;Loop for protecting swapting again and again
				   MouseGetPos, MouseX, MouseY
				   sleep, 200   ;200 is default.
				   if !(MouseY==a0y and MouseX==a0x)
						Break
				}
			}
			
			else if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
			{	;Checking for full-screen or not 

				sleep, %aeroFlipsleepTime%
				MouseGetPos, MouseX, MouseY
				LDown01:=GetKeyState("LButton","P")
				
				;Protect running RunDll32 DwmApi #105 repeatly and check Position of mouse again
				if (!LDown01 and ((MouseY==a0y and MouseX==a0x) || aeroFlipsleepTime == 0))
				{
					run RunDll32 DwmApi #105
					sleep, 100
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==a0y and MouseX==a0x)
							Break
					}
				}
				else ;if(LDown01 and MouseY==a0y and MouseX==a0x)
				{
					Loop, {
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==a0y and MouseX==a0x)
							Break							
					}									
				}

			}   ;End of Checking for full-screen or not 
			
		}    ;End Win 3D code


		;044a114 if pointer is at the TaskSwitcher corner
		else if (MouseY==aa0y and MouseX==aa0x and wTaskSwitcher)
		{	;Win alt+Tab
			
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			
			if WinActive("ahk_class TaskSwitcherWnd") 
			{
				send, {Enter}
				Loop, {      ;Loop for protecting swapting again and again
				   MouseGetPos, MouseX, MouseY
				   sleep, 200
				   if !(MouseY==aa0y and MouseX==aa0x)
						Break
				}
			}
			else if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
			{
				sleep, %taskSwitchsleepTime%
				MouseGetPos, MouseX, MouseY
				LDown011:=GetKeyState("LButton","P")
				if(!LDown011 && ((MouseY==aa0y && MouseX==aa0x) || taskSwitchsleepTime == 0))
				{
					send !^{Tab}
					sleep, 100
					send {Alt Up}
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==aa0y and MouseX==aa0x)
							Break
					}
				}
				else
				{
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==aa0y and MouseX==aa0x)
							Break
					}
				}
			}
			
		}   ;End wTaskSwitcher code





		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		
		;044a1151 if topleft shortcut key is enable and pointer is at topleft.
		else if (wuserkeyrun1 and MouseY==topleftY and MouseX==topleftX)
		{
			;awuser1 := 0
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			
			sleep, %TLsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")			
			if(!LDown022 and ((MouseY==lowrightY and MouseX==lowrightX) || TLsleepTime == 0))
			{
				if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
				{ 	;Check for full-screen or not 
					Gosub, ShortcutKeyAndRunTLMethod
					sleep, 100
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==topleftY and MouseX==topleftX)
							Break
					}
				}
			}
			else ;LDown022 pushed
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==topleftY and MouseX==topleftX)
						Break							
				}									
			}
		}
		;044a1152 if topright shortcut key is enable and pointer is at topright.
		else if (wuserkeyrun2 and MouseY==toprightY and MouseX==toprightX)
		{
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			LDown022:=GetKeyState("LButton","P")
			
			sleep, %TRsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")			
			if(!LDown022 and ((MouseY==lowrightY and MouseX==lowrightX) || TRsleepTime == 0))
			{
				if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
				{ ;Check for full-screen or not 
					Gosub, ShortcutKeyAndRunTRMethod
					sleep, 100
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==toprightY and MouseX==toprightX)
							Break
					}
				}
			}
			else ;LDown022 pushed
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==toprightY and MouseX==toprightX)
						Break							
				}									
			}
		}
		;044a1153 if lowleft shortcut key is enable and pointer is at lowleft.
		else if (wuserkeyrun3 and MouseY==lowleftY and MouseX==lowleftX)
		{
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			LDown022:=GetKeyState("LButton","P")
			
			sleep, %BLsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")			
			if(!LDown022 and ((MouseY==lowrightY and MouseX==lowrightX) || BLsleepTime == 0))
			{
				if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
				{ ;Check for full-screen or not 
					Gosub, ShortcutKeyAndRunBLMethod
					sleep, 100
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==lowleftY and MouseX==lowleftX)
							Break
					}
				}
			}
			else ;LDown022 pushed
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==lowleftY and MouseX==lowleftX)
						Break							
				}									
			}
		}
		;044a1154 if lowright shortcut key is enable and pointer is at lowright.
		else if (wuserkeyrun4 and MouseY==lowrightY and MouseX==lowrightX)
		{
			WinGet, ExStyleFullS, ExStyle, ahk_id %idtouch%
			WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idtouch%
			LDown022:=GetKeyState("LButton","P")
			
			sleep, %BRsleepTime%
			MouseGetPos, MouseX, MouseY
			LDown022:=GetKeyState("LButton","P")			
			if(!LDown022 and ((MouseY==lowrightY and MouseX==lowrightX) || BRsleepTime == 0))
			{
				if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
				{ ;Check for full-screen or not 
					Gosub, ShortcutKeyAndRunBRMethod
					sleep, 100
					Loop, {      ;Loop for protecting swapting again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY==lowrightY and MouseX==lowrightX)
							Break
					}
				}
			}
			else ;LDown022 pushed
			{
				Loop, {
					MouseGetPos, MouseX, MouseY
					sleep, 200
					if !(MouseY==lowrightY and MouseX==lowrightX)
						Break							
				}									
			}
		}
		
		;044a116 Touch Start corner
		;no GetKeyState checking because the "Click" command will not work if Lbutton is down.
		else if(wstartButton and MouseY == b0y and MouseX == b0x)
		{	;Start wstartButton
			;WinGetClass, class, A
			
			WinGetClass, classEveryCheck, ahk_id %idtouch%
			WinGet, idAb, ID, A
			;if Active window is minimized,
			WinGet, MaxAb, MinMax, ahk_id %idAb%
			if(MaxAb=-1)
				WinGet, idAb, ID, Program Manager ahk_class Progman

			if(winver == 0)	;for Windows 7
			{
				IfWinActive, Start menu ahk_class DV2ControlHost
				{
					Loop, {      ;Loop for protecting swapping again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY == b0y and MouseX == b0x)
							Break
					}
				}
				else if(classEveryCheck == "Shell_TrayWnd")
				{
					sleep, %touchStartsleepTime%
					MouseGetPos, MouseX, Mouse
					if (touchStartsleepTime == 0 || (MouseY == b0y and MouseX == b0x))
					{
						Click
						Loop, {      ;Loop for protecting swapping again and again
							MouseGetPos, MouseX, Mouse
							sleep, 100
							if !(MouseY == b0y and MouseX == b0x)
								Break
						}
						Loop, {
							MouseGetPos, MouseX, MouseY, idid
							WinGetClass, classToClose, ahk_id %idid%
							IfWinNotActive, Start menu ahk_class DV2ControlHost
							{
								Break
							}
							else if ((classToClose != "DV2ControlHost") && (classToClose != "Button") && (classToClose != "Shell_TrayWnd") && (classToClose != "Desktop User Picture") && (classToClose !=  "#32768") && (classToClose != "basebar") && (classToClose != "tooltips_class32") && (classToClose != "MagUIIconClass"))
							{
								WinClose, ahk_class DV2ControlHost
								WinActivate, ahk_id %idAb%
								Break
							}
							else if (MouseY == b0y and MouseX == b0x)
							{
								;WinClose, ahk_class DV2ControlHost
								Click
								sleep, 100
								WinActivate, ahk_id %idAb%
								Break
							}
							else IfWinExist, ahk_class #32768
								Break
							sleep, 100
						}
						if (MouseY == b0y and MouseX == b0x)
						Loop, {      ;Loop for protecting swapting again and again
							MouseGetPos, MouseX, MouseY
							sleep, 100
							if !(MouseY == b0y and MouseX == b0x)
							Break
						}
					}
				}
			}	;win7
			else if(winver == 2)	;for Windows 10
			{
				IfWinActive, Search ahk_class Windows.UI.Core.CoreWindow
				{
					Loop, {      ;Loop for protecting swapping again and again
						MouseGetPos, MouseX, MouseY
						sleep, 200
						if !(MouseY == b0y and MouseX == b0x)
							Break
					}
				}
				else if(classEveryCheck == "Shell_TrayWnd")
				{
					sleep, %touchStartsleepTime%
					MouseGetPos, MouseX, Mouse
					if (touchStartsleepTime == 0 || (MouseY == b0y and MouseX == b0x))
					{
						Click
						Loop, {      ;Loop before checking if start is gonna close
						MouseGetPos, MouseX, Mouse
						sleep, 100
						if !(MouseY == b0y and MouseX == b0x)
							Break
						}
						Loop, {
							MouseGetPos, MouseX, MouseY, idid
							WinGetClass, classToClose, ahk_id %idid%
							;Tooltip, ok %classToClose%, 800, 500
							IfWinNotActive, Search ahk_class Windows.UI.Core.CoreWindow
								Break
							else if ((classToClose != "Windows.UI.Core.CoreWindow") && (classToClose != "Shell_TrayWnd") && (classToClose != "Xaml_WindowedPopupClass") && (classToClose != "TaskListThumbnailWnd"))
							{
								WinClose, ahk_class Windows.UI.Core.CoreWindow
								WinActivate, ahk_id %idAb%
								Break
							}
							else if (MouseY == b0y and MouseX == b0x)
							{
								;WinClose, ahk_class DV2ControlHost
								Click		;to close start menu
								sleep, 100
								WinActivate, ahk_id %idAb%
								Break
							}
							else IfWinExist, ahk_class #32768
								Break

							sleep, 100
						}
						if (MouseY == b0y and MouseX == b0x)
						Loop, {      ;Loop for protecting swapting again and again
							MouseGetPos, MouseX, MouseY
							sleep, 100
							if !(MouseY == b0y and MouseX == b0x)
							Break
						}
					}
				}
			}	;win10
		}  ; End wstartButton

	}   ;all from corner

	
	
	

	
	
	
	
	
	

	;044a12 if the pointer is at the left and there is idtouch1 window.
	if(weasy and MouseX == touchSlideLeftX and (idtouch == idtouch1))
	{  ;Start weasy -------------------------------------------------------------------

		c=0
		ccc=0
		Loop, { ;Loop3
			MouseGetPos, MouseXin1, MouseYin1, idmouseOn1
			WinGetClass, classToSlideOut1, ahk_id %idmouseOn1%
			WinGetPos, posXCheck1, posYCheck1, WXCheck1, WYCheck1, ahk_id %idtouch1%
			WinGet, Maxidtouch1, MinMax, ahk_id %idtouch1%
			LDown03:=GetKeyState("LButton","P")
		
			if (c=0) && LDown03
			{
				c=2
				WinGet, idAc, ID, A
			}
			if (c=0) && !LDown03
			{
				WinGet, idAc, ID, A
				WinGet, MaxAc, MinMax, ahk_id %idAc%
				if(MaxAc=-1)
				WinGet, idAc, ID, Program Manager ahk_class Progman
				
				;In case window is dragged in before sliding in, Preme has to slide out to the old position.
				if(cccc==1)&&(destXOut1tem > touchSlideLeftX - WXCheck1)  ;This is right. Don't worry.
				{
					if(destXOut1tem<touchSlideLeftX - WXCheck1 + 160)
						destXOut1 := touchSlideLeftX - WXCheck1 + 160
					else
						destXOut1 := destXOut1tem
				}
				else
					destXOut1 := touchSlideLeftX+touchSlideXoutVar
				
				inSin1 := 0
				;realXPosOut1 := posXCheck1     ;This line is no need.
				
				Loop, 10
				{
					inSin1 += 0.157
					realXPosOut1 := posXCheck1 + Ceil(Sqrt(sin(inSin1))*(destXOut1-posXCheck1))
					SetWinDelay, 2
					WinMove, ahk_id %idtouch%,, %realXPosOut1%	
				}
				Winset, Enable ,,ahk_id %idtouch1%
				WinActivate , ahk_id %idtouch1%

				c=1
			}
			
			else if(c=1)
			{  ;c=1 is the window has been pulled and seen.
				
				if (!LDown03 && (posXCheck1>touchSlideLeftX+9)) || Maxidtouch1
				{ ;Check if the window is not in the same position(The window is draged)
					if(winlefttop != 1)
						WinSet, AlwaysOnTop, Off, ahk_id %idtouch1%
					idtouch1 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch1INI
					cccc := 0			
					break
				}
				
				else if (idtouch1 == "0x00000")
				{
					cccc := 0
					break
				}
				
				else if !LDown03 && (MouseXin1>posXCheck1+WXCheck1+14 || MouseYin1 < posYCheck1-14 || MouseYin1 > posYCheck1+WYCheck1+14) &&(classToSlideOut1 != "#32768") && (classToSlideOut1 != "ViewControlClass")
				{   ;if cursor is out of area
					; c=2 is that window is invisible
					sleep, 100
					
					MouseGetPos, MouseXin1, MouseYin1
					if(MouseXin1>posXCheck1+WXCheck1+14 || MouseYin1 < posYCheck1-14 || MouseYin1 > posYCheck1+WYCheck1+14)  ;outside
					sleep, 100

					MouseGetPos, MouseXin1, MouseYin1
					if(MouseXin1>posXCheck1+WXCheck1+14 || MouseYin1 < posYCheck1-14 || MouseYin1 > posYCheck1+WYCheck1+14)  ;outside
					{

						; c=2 is that window is in
						c=2
						WinGetPos, XposIn1, YposIn1, WidIn1, HidIn1, ahk_id %idtouch1%
						
						if(YposIn1<ScHeight/20)
							destYIn1 := ScHeight/20
						else if(YposIn1+HidIn1>19*ScHeight/20)
						{
							if(HidIn1>9*ScHeight/10)
							destYIn1 := ScHeight/20
							else
							destYIn1 := (19*ScHeight/20)-HidIn1
						}
						else 
							destYIn1 := YposIn1
						
						if(WidIn1>4*ScWidth/5)
							destXIn1 := touchSlideLeftX-(4*ScWidth/5)+touchSlideXvar
						else			
							destXIn1 := touchSlideLeftX-WidIn1+touchSlideXvar
						
						
						PerdestXIn1 := (destXIn1-XposIn1)/10
						;destYIn1 := (ScHeight-HidIn1-26)/2
						PerdestYIn1 := (destYIn1-YposIn1)/10
						;WinActivate, ahk_id %idAc%
						Winset, Disable ,,ahk_id %idtouch1%
						
						Loop, 10
						{
							XposIn1 += PerdestXIn1
							YposIn1 += PerdestYIn1
							SetWinDelay, 2
							WinMove, ahk_id %idtouch1%,, %XposIn1%, %YposIn1%
						}
						
						if(HidIn1>9*ScHeight/10) || (WidIn1>4*ScWidth/5)
						{
							if(HidIn1>9*ScHeight/10)
								PersizeY := (HidIn1 - 9*ScHeight/10)/6
							else
								PersizeY := 0
							
							if(WidIn1>4*ScWidth/5)
							{
								PersizeX := (WidIn1 - 4*ScWidth/5)/6
							}
							else
								PersizeX := 0
						
							Loop, 6
							{
								WidIn1 -= PersizeX	
								HidIn1 -= PersizeY
								SetWinDelay, 2
								WinMove, ahk_id %idtouch1%,,,, %WidIn1%, %HidIn1%
							}
						}
						
						
						WinGet, MaxOrNotAc, MinMax, ahk_id %idAc%	
						IfWinActive, ahk_id %idtouch1%
							if(MaxOrNotAc != -1)
								WinActivate, ahk_id %idAc%
						
						WinGet, idnow, ID, A
						if idnow in %idtouch1%
							WinActivate, Program Manager ahk_class Progman
						
						cccc := 1
						destXOut1tem := posXCheck1
						
						break
					}
					
				}
				
				if(MouseXin1>touchSlideLeftX)
				{
					ccc = 1
				}
				else if(ccc=1 and MouseXin1 == touchSlideLeftX and LDown03)
					ccc=0
				else if(ccc=1 and MouseXin1 == touchSlideLeftX and !LDown03)
				{
					c=2
					WinGetPos, XposIn1, YposIn1, WidIn1, HidIn1, ahk_id %idtouch1%
					
					if(YposIn1<ScHeight/20)
						destYIn1 := ScHeight/20
					else if(YposIn1+HidIn1>19*ScHeight/20)
					{
						if(HidIn1>9*ScHeight/10)
						destYIn1 := ScHeight/20
						else
						destYIn1 := (19*ScHeight/20)-HidIn1
					}
					else 
						destYIn1 := YposIn1
					
					
					if(WidIn1>4*ScWidth/5)
						destXIn1 := touchSlideLeftX-(4*ScWidth/5)+touchSlideXvar
					else			
						destXIn1 := touchSlideLeftX-WidIn1+touchSlideXvar
						
					
					PerdestXIn1 := (destXIn1-XposIn1)/10

					PerdestYIn1 := (destYIn1-YposIn1)/10
					Winset, Disable ,,ahk_id %idtouch1%
					
					Loop, 10
					{
						XposIn1 += PerdestXIn1
						YposIn1 += PerdestYIn1
						SetWinDelay, 2
						WinMove, ahk_id %idtouch1%,, %XposIn1%, %YposIn1%
					}
					
					
					if(HidIn1>9*ScHeight/10) || (WidIn1>4*ScWidth/5)
					{
						if(HidIn1>9*ScHeight/10)
							PersizeY := (HidIn1 - 9*ScHeight/10)/6
						else
							PersizeY := 0
						
						if(WidIn1>4*ScWidth/5)
						{
							PersizeX := (WidIn1 - 4*ScWidth/5)/6
						}
						else
							PersizeX := 0
					
						Loop, 6
						{
							WidIn1 -= PersizeX	
							HidIn1 -= PersizeY
							SetWinDelay, 2
							WinMove, ahk_id %idtouch1%,,,, %WidIn1%, %HidIn1%
						}
					}
					
					WinGet, MaxOrNotAc, MinMax, ahk_id %idAc%	
					IfWinActive, ahk_id %idtouch1%
						if(MaxOrNotAc != -1)
							WinActivate, ahk_id %idAc%
					
					WinGet, idnow, ID, A
					if idnow in %idtouch1%
						WinActivate, Program Manager ahk_class Progman
					
					cccc := 1
					destXOut1tem := posXCheck1
				}
		
		
				
			} ;else if c=1
			
			else if(c=2)
			{
				if(MouseXin1 > touchSlideLeftX)
				{
					WinGet, MaxOrNotAc, MinMax, ahk_id %idAc%
					IfWinActive, ahk_id %idtouch1%
					if(MaxOrNotAc != -1)
						WinActivate, ahk_id %idAc%
					break
				}
			}
		
		
			sleep, 100  ;sleep for Looping in proper times
		} ;Loop3
		
	}  ; End weasy ---------------------------------------------------------------





	;044a13 if the pointer is at the RIGHT and there is idtouch3 window.
	if(weasy and MouseX > touchSlideRightX-1)	;This can't be used because it won't work in all hidden and (idtouch == idtouch3))
	{  ;Start weasy 
		d=0
		ddd=0
		
		Loop, {  ;Loop for checking a Maximized window
			if (idtouch == idtouch3)
			{
				break
			}
			else IfWinNotExist, ahk_id %idtouch3%
			{
				d=2
				WinGet, idAd, ID, A
				break
			}
			else
			{
				sleep, 400
				MouseGetPos, MouseXin3,,
				LDown05:=GetKeyState("LButton","P")
				if(MouseXin3 > touchSlideRightX-2) && !LDown05
				{
					destXIn3 := touchSlideRightX - 1
					WinMove, ahk_id %idtouch3%,, %destXIn3%
					sleep, 50
					MouseGetPos,,, idmouseOn3	
					if (idmouseOn3 == idtouch3)
						break
					else
					{
						destXIn3 := touchSlideRightX + 1
						WinMove, ahk_id %idtouch3%,, %destXIn3%
						d=2
						break
					}
				}
				else
				{
					d=2
					break
				}
			}
		}
		
		Loop, { ;Loop4
			MouseGetPos, MouseXin3, MouseYin3, idmouseOn3
			WinGetClass, classToSlideOut3, ahk_id %idmouseOn3%
			WinGetPos,posXCheck3, posYCheck3,WXCheck3,WYCheck3, ahk_id %idtouch3%
			WinGet, Maxidtouch3, MinMax, ahk_id %idtouch3%
			LDown05:=GetKeyState("LButton","P")
			if (d=0) && LDown05
			{
				d=2
				WinGet, idAd, ID, A
			}
			if (d=0) && !LDown05
			{
				WinGet, idAd, ID, A
				WinGet, MaxAd, MinMax, ahk_id %idAd%
				if(MaxAd=-1)
					WinGet, idAd, ID, Program Manager ahk_class Progman
				
				if(dddd==1)&&(destXOut3tem<touchSlideRightX)
				{
					if(destXOut3tem>touchSlideRightX-160)
						destXOut3 := touchSlideRightX-160
					else
						destXOut3 := destXOut3tem
				}
				else
					destXOut3 := touchSlideRightX-WXCheck3-touchSlideXoutVar
				
				inSin3 := 0
				realXPosOut3 := posXCheck3
				Loop, 10
				{
					inSin3 += 0.157
					realXPosOut3 := posXCheck3 - Ceil(Sqrt(sin(inSin3))*(posXCheck3-destXOut3))
					SetWinDelay, 2
					WinMove, ahk_id %idtouch3%,, %realXPosOut3%
				}

				Winset, Enable ,,ahk_id %idtouch3%
				;sleep, 2000
				WinActivate , ahk_id %idtouch3%
				;sleep, 100
				d=1
			}
			
			else if(d=1)
			{
				if (!LDown05 && (touchSlideRightX-posXCheck3-WXCheck3 > 9)) || Maxidtouch3
				{ ;Check if the window position is out of edge of screen
					if(!winrighttop)
					WinSet, AlwaysOnTop, Off, ahk_id %idtouch3%
					idtouch3 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch3INI
					dddd := 0
					break
				}
				else if (idtouch3 == "0x00000")
				{
					dddd := 0
					break
				}
				if !LDown05 && (MouseXin3<posXCheck3-14 || MouseYin3 < posYCheck3-14 || MouseYin3 > posYCheck3+WYCheck3+14) && !InStr(classToSlideOut3, "#32768") && !InStr(classToSlideOut3, "ViewControlClass")
				{
					sleep, 100
					MouseGetPos, MouseXin3, MouseYin3
					if(MouseXin3<posXCheck3-14 || MouseYin3 < posYCheck3-14 || MouseYin3 > posYCheck3+WYCheck3+14)  ;outside
						sleep, 100
					MouseGetPos, MouseXin3, MouseYin3
					if(MouseXin3<posXCheck3-14 || MouseYin3 < posYCheck3-14 || MouseYin3 > posYCheck3+WYCheck3+14)  ;outside
					{
						; d=2 is that window is in
						d=2
						WinGetPos, XposIn3, YposIn3, WidIn3, HidIn3, ahk_id %idtouch3%
							
						if(YposIn3<ScHeight/20)
							destYIn3 := ScHeight/20
						else if(YposIn3+HidIn3>19*ScHeight/20)
						{
							if(HidIn3>9*ScHeight/10)
								destYIn3 := ScHeight/20
							else
								destYIn3 := (19*ScHeight/20)-HidIn3	
						}
						else 
							destYIn3 := YposIn3
	
						destXIn3 := touchSlideRightX+1
						WinGet, MaxOrNotAd, MinMax, ahk_id %idAd%
						if(MaxOrNotAd != 1)
							destXIn3 -= touchSlideXvar
						PerdestXIn3 := (destXIn3-XposIn3)/10
						PerdestYIn3 := (destYIn3-YposIn3)/10
						Winset, Disable ,,ahk_id %idtouch3%
						
						Loop, 10
						{
							XposIn3 += PerdestXIn3
							YposIn3 += PerdestYIn3
							SetWinDelay, 2
							WinMove, ahk_id %idtouch3%,, %XposIn3%, %YposIn3%
						}
					
						if(HidIn3>9*ScHeight/10) || (WidIn3>4*ScWidth/5)
						{
							if(HidIn3>9*ScHeight/10)
								PersizeY := (HidIn3 - 9*ScHeight/10)/6
							else
								PersizeY := 0
							
							if(WidIn3>4*ScWidth/5)
							{
								PersizeX := (WidIn3 - 4*ScWidth/5)/6
								posXCheck3 := (ScWidth/5)+10
							}
							else
								PersizeX := 0
						
							Loop, 6
							{
								WidIn3 -= PersizeX		
								HidIn3 -= PersizeY
								SetWinDelay, 2
								WinMove, ahk_id %idtouch3%,,,, %WidIn3%, %HidIn3%
							}
						}

						WinGet, MaxOrNotAd, MinMax, ahk_id %idAd%	
						IfWinActive, ahk_id %idtouch3%
						if(MaxOrNotAd != -1)
							WinActivate, ahk_id %idAd%
						
						WinGet, idnow3, ID, A
						if idnow3 in %idtouch3%
							WinActivate, Program Manager ahk_class Progman
						;These 3 line is for debuging the sliding again and again
						
						dddd := 1
						destXOut3tem := posXCheck3
						break
					}
				}        ;if !LDown05 && (MouseXin3<posXCheck3-14 
				
				
		
		
				if(MouseXin3<touchSlideRightX-1)
					ddd=1
				else if(ddd=1 and MouseXin3 > touchSlideRightX-2 and LDown05)
					ddd=0
				else if(ddd=1 and MouseXin3 > touchSlideRightX-2 and !LDown05)
				{
					d=2
					WinGetPos, XposIn3, YposIn3, WidIn3, HidIn3, ahk_id %idtouch3%
					if(YposIn3<ScHeight/20)
						destYIn3 := ScHeight/20
					else if(YposIn3+HidIn3>19*ScHeight/20)
					{
						if(HidIn3>9*ScHeight/10)
							destYIn3 := ScHeight/20
						else
							destYIn3 := (19*ScHeight/20)-HidIn3	
					}
					else 
						destYIn3 := YposIn3
					
					destXIn3 := touchSlideRightX+1
					WinGet, MaxOrNotAd, MinMax, ahk_id %idAd%
					if(MaxOrNotAd != 1)
						destXIn3 -= touchSlideXvar+1
						
					PerdestXIn3 := (destXIn3-XposIn3)/10
					PerdestYIn3 := (destYIn3-YposIn3)/10
					Winset, Disable ,,ahk_id %idtouch3%
					
					
						
					Loop, 10
					{
						XposIn3 += PerdestXIn3
						YposIn3 += PerdestYIn3
						SetWinDelay, 2
						WinMove, ahk_id %idtouch3%,, %XposIn3%, %YposIn3%
					}
						
					if(HidIn3>9*ScHeight/10) || (WidIn3>4*ScWidth/5)
					{
						if(HidIn3>9*ScHeight/10)
							PersizeY := (HidIn3 - 9*ScHeight/10)/6
						else
							PersizeY := 0
						
						if(WidIn3>4*ScWidth/5)
						{
							PersizeX := (WidIn3 - 4*ScWidth/5)/6
							posXCheck3 := (ScWidth/5)+10
						}
						else
							PersizeX := 0
					
						Loop, 6
						{
							WidIn3 -= PersizeX		
							HidIn3 -= PersizeY
							SetWinDelay, 2
							WinMove, ahk_id %idtouch3%,,,, %WidIn3%, %HidIn3%
						}
					
					}
			
					WinGet, MaxOrNotAd, MinMax, ahk_id %idAd%	
					IfWinActive, ahk_id %idtouch3%
					if(MaxOrNotAd != -1)
						WinActivate, ahk_id %idAd%
							
					WinGet, idnow3, ID, A
					if idnow3 in %idtouch3%
						WinActivate, Program Manager ahk_class Progman
					
					dddd := 1
					destXOut3tem := posXCheck3

				}
				
			} ;else if d=1
			
			else if(d=2)
			{
				if(MouseXin3 < touchSlideRightX-1)
				{
					WinGet, MaxOrNotAd, MinMax, ahk_id %idAd%
					IfWinActive, ahk_id %idtouch3%
					if(MaxOrNotAd != -1)
						WinActivate, ahk_id %idAd%
					break
				}
			}
			
		
			sleep, 100  ;sleep for Looping in a proper time
		} ;Loop4
		
	}  ; End weasy zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz



	
	
	
	;044a14 if the pointer is at the top and there is idtouch=5 window.
	if(weasy and MouseY == touchSlideTopY and (idtouch == idtouch5))
	{	;Start weasy zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
		e=0
		eee=0
		Loop, {		;Loop5
			MouseGetPos, MouseXin5, MouseYin5, idmouseOn5
			WinGetClass, classToSlideOut5, ahk_id %idmouseOn5%
			WinGetPos, posXCheck5, posYCheck5, WXCheck5, WYCheck5, ahk_id %idtouch5%
			WinGet, Maxidtouch5, MinMax, ahk_id %idtouch5%
			LDown05:=GetKeyState("LButton","P")
			if (e=0) && LDown05
			{
				e=2
				WinGet, idAe, ID, A
			}
			if (e=0) && !LDown05
			{
				WinGet, idAe, ID, A
				WinGet, MaxAe, MinMax, ahk_id %idAe%
				
				if(MaxAe=-1)
					WinGet, idAe, ID, Program Manager ahk_class Progman
				
				destYOut5 := touchSlideTopY+touchSlideYoutVar
				inSin5 := 0
				realYPosOut5 := posYCheck5
				
				Loop, 10
				{
					inSin5 += 0.157
					realYPosOut5 := posYCheck5 + Ceil(Sqrt(sin(inSin5))*(destYOut5-posYCheck5))
					SetWinDelay, 2
					WinMove, ahk_id %idtouch5%,,, %realYPosOut5%    
				}
				
				Winset, Enable ,,ahk_id %idtouch5%
				WinActivate , ahk_id %idtouch5%
				e=1
			}
			else if(e=1)
			{
				if (!LDown05 && (posYCheck5-touchSlideTopY > 50)) || Maxidtouch5
				{	;Check if the window is not in the same position, that window will be deactivated.
					if(wintoptop != 1)
						WinSet, AlwaysOnTop, Off, ahk_id %idtouch5%
					idtouch5 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch5INI
					eeee := 0
					break
				}
				else if (idtouch5 == "0x00000")
				{
					eeee := 0
					break
				}
				if !LDown05 && (MouseXin5<posXCheck5-14 || MouseYin5 > posYCheck5+WYCheck5+14 || MouseXin5 > posXCheck5+WXCheck5+14) && (classToSlideOut5 != "#32768") && (classToSlideOut5 != "ViewControlClass")
				{
					sleep, 100
					MouseGetPos, MouseXin5, MouseYin5
					if(MouseXin5<posXCheck5-14 || MouseYin5 > posYCheck5+WYCheck5+14 || MouseXin5 > posXCheck5+WXCheck5+14)  ;outside
						sleep, 100
					MouseGetPos, MouseXin5, MouseYin5
					if(MouseXin5<posXCheck5-14 || MouseYin5 > posYCheck5+WYCheck5+14 || MouseXin5 > posXCheck5+WXCheck5+14)  ;outside
					{
						; e=2 is that window is in
						e=2
						WinGetPos, XposIn5, YposIn5, WidIn5, HidIn5, ahk_id %idtouch5%
						
						if(XposIn5<ScWidth/10)
							destXIn5 := ScWidth/10
						else if(XposIn5+WidIn5>9*ScWidth/10)
						{
							if(WidIn5>4*ScWidth/5)
								destXIn5 := ScWidth/10
							else
								destXIn5 := (9*ScWidth/10)-WidIn5
						}
						else 
							destXIn5 := XposIn5
						
						PerdestXIn5 := (destXIn5-XposIn5)/10
						destYIn5 := touchSlideTopY-WYCheck5+touchSlideYvar
						PerdestYIn5 := (destYIn5-YposIn5)/10
						Winset, Disable ,,ahk_id %idtouch5%
						
						Loop, 10
						{
							XposIn5 += PerdestXIn5
							YposIn5 += PerdestYIn5
							SetWinDelay, 2
							WinMove, ahk_id %idtouch5%,, %XposIn5%, %YposIn5%
						}
						
						if(HidIn5>5*ScHeight/6) || (WidIn5>4*ScWidth/5)
						{
							if(HidIn5>5*ScHeight/6)
							{
								PersizeY := (HidIn5 - 5*ScHeight/6)/6
								posYCheck5 := (ScHeight/6)+10
							}
							else
								PersizeY := 0
							
							if(WidIn5>4*ScWidth/5)
							{
								PersizeX := (WidIn5 - 4*ScWidth/5)/6
							}
							else
								PersizeX := 0
						
							Loop, 6
							{
								WidIn5 -= PersizeX		
								HidIn5 -= PersizeY
								SetWinDelay, 2
								WinMove, ahk_id %idtouch5%,,,, %WidIn5%, %HidIn5%
							}
						
						}
						WinGet, MaxOrNotAe, MinMax, ahk_id %idAe%	
						IfWinActive, ahk_id %idtouch5%
						if(MaxOrNotAe != -1)
							WinActivate, ahk_id %idAe%
						
						WinGet, idnow5, ID, A
						if idnow5 in %idtouch5%
							WinActivate, Program Manager ahk_class Progman
						
						eeee := 1
						;sleep, 100
						break
					}
						
				}   ;if !LDown05 && (MouseXin5<posXCheck5-14
				
					
				if(eee!=1 && MouseYin5>touchSlideTopY)
				{
					eee = 1
				}
				else if(eee=1 and MouseYin5 == touchSlideTopY and LDown05)
					eee = 0
				else if(eee=1 and MouseYin5 == touchSlideTopY and !LDown05)
				{
					e = 2
					WinGetPos, XposIn5, YposIn5, WidIn5, HidIn5, ahk_id %idtouch5%
			
					if(XposIn5<ScWidth/10)
						destXIn5 := ScWidth/10
					else if(XposIn5+WidIn5>9*ScWidth/10)
					{
						if(WidIn5>4*ScWidth/5)
							destXIn5 := ScWidth/10
						else
							destXIn5 := (9*ScWidth/10)-WidIn5
					}
					else 
						destXIn5 := XposIn5

					PerdestXIn5 := (destXIn5-XposIn5)/10			
					destYIn5 := touchSlideTopY-WYCheck5+touchSlideYvar
					PerdestYIn5 := (destYIn5-YposIn5)/10
					
					Winset, Disable ,,ahk_id %idtouch5%
					
					Loop, 10
					{
						XposIn5 += PerdestXIn5
						YposIn5 += PerdestYIn5
						SetWinDelay, 2
						WinMove, ahk_id %idtouch5%,, %XposIn5%, %YposIn5%
					}
					
					if(HidIn5>5*ScHeight/6) || (WidIn5>4*ScWidth/5)
					{
						if(HidIn5>5*ScHeight/6)
						{
							PersizeY := (HidIn5 - 5*ScHeight/6)/6
							posYCheck5 := (ScHeight/6)+10
						}
						else
							PersizeY := 0
						
						if(WidIn5>4*ScWidth/5)
						{
							PersizeX := (WidIn5 - 4*ScWidth/5)/6
						}
						else
							PersizeX := 0
					
						Loop, 6
						{
							WidIn5 -= PersizeX		
							HidIn5 -= PersizeY
							SetWinDelay, 2
							WinMove, ahk_id %idtouch5%,,,, %WidIn5%, %HidIn5%
						}
					
					}
					
					WinGet, MaxOrNotAe, MinMax, ahk_id %idAe%	
					IfWinActive, ahk_id %idtouch5%
						if(MaxOrNotAe != -1)
							WinActivate, ahk_id %idAe%
					
					WinGet, idnow5, ID, A
					if idnow5 in %idtouch5%
						WinActivate, Program Manager ahk_class Progman
				
					eeee := 1
				}
			} ;else if e=1
			
			else if(e=2)
			{
				if(MouseYin5 > touchSlideTopY+1)
				{
					WinGet, MaxOrNotAe, MinMax, ahk_id %idAe%
					IfWinActive, ahk_id %idtouch5%
					if(MaxOrNotAe != -1)
						WinActivate, ahk_id %idAe%
					break
				}
			}
			sleep, 100  ;sleep for Looping in a proper time
		} ;Loop5
		
	}  ; End of if(weasy and MouseY > touchSlideTopY-2 and (idtouch == idtouch5))
	
	
	



	;044a15 if the pointer is at the bottom and there is idtouch6 window.
	if(weasy and MouseY > touchSlideBottomY-1 and (idtouch == idtouch6))
	{	;Start weasy zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
		g=0
		ggg=0
		Loop, { ;Loop6
			MouseGetPos, MouseXin6, MouseYin6, idmouseOn6
			WinGetClass, classToSlideOut6, ahk_id %idmouseOn6%
			WinGetPos, posXCheck6, posYCheck6, WXCheck6, WYCheck6, ahk_id %idtouch6%
			WinGet, Maxidtouch6, MinMax, ahk_id %idtouch6%
			LDown06:=GetKeyState("LButton","P")
			if (g=0) && LDown06
			{
				g=2
				WinGet, idAg, ID, A
			}
			if (g=0) && !LDown06
			{
				WinGet, idAg, ID, A
				WinGet, MaxAg, MinMax, ahk_id %idAg%
				
				if(MaxAg=-1)
					WinGet, idAg, ID, Program Manager ahk_class Progman
				
				if(gggg==1)
					destYOut6 := destYOut6tem
				else
					destYOut6 := touchSlideBottomY-WYCheck6-touchSlideYoutVar
				
				inSin6 := 0
				realYPosOut6 := posYCheck6
				
				Loop, 10
				{
					inSin6 += 0.157
					realYPosOut6 := posYCheck6 - Ceil(Sqrt(sin(inSin6))*(posYCheck6-destYOut6))
					SetWinDelay, 2
					WinMove, ahk_id %idtouch6%,,, %realYPosOut6%    
				}
				
				Winset, Enable ,,ahk_id %idtouch6%
				WinActivate , ahk_id %idtouch6%
				g=1
			}
			else if(g=1)
			{
				if (!LDown06 && (touchSlideBottomY-posYCheck6-WYCheck6 > 9)) || Maxidtouch6
				{ ;Check if the window is not in the same position, that window will be deactivated.
					if(!winundertop)
						WinSet, AlwaysOnTop, Off, ahk_id %idtouch6%
					idtouch6 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch6INI
					gggg := 0
					break
				}
				else if (idtouch6 == "0x00000")
				{
					;gggg := 0
					break
				}
				if !LDown06 && (MouseXin6<posXCheck6-14 || MouseYin6 < posYCheck6-14 || MouseXin6 > posXCheck6+WXCheck6+14) && (classToSlideOut6 != "#32768") && (classToSlideOut6 != "ViewControlClass")
				{
					sleep, 100
					MouseGetPos, MouseXin6, MouseYin6
					if(MouseXin6<posXCheck6-14 || MouseYin6 < posYCheck6-14 || MouseXin6 > posXCheck6+WXCheck6+14)  ;outside
						sleep, 100
					MouseGetPos, MouseXin6, MouseYin6
					if(MouseXin6<posXCheck6-14 || MouseYin6 < posYCheck6-14 || MouseXin6 > posXCheck6+WXCheck6+14)  ;outside
					{
						; g=2 is that window is in
						g=2
						WinGetPos, XposIn6, YposIn6, WidIn6, HidIn6, ahk_id %idtouch6%
						
						if(XposIn6<ScWidth/10)
							destXIn6 := ScWidth/10
						else if(XposIn6+WidIn6>9*ScWidth/10)
						{
							if(WidIn6>4*ScWidth/5)
								destXIn6 := ScWidth/10
							else
								destXIn6 := (9*ScWidth/10)-WidIn6
						}
						else 
							destXIn6 := XposIn6
						
						PerdestXIn6 := (destXIn6-XposIn6)/10
						destYIn6 := touchSlideBottomY-touchSlideYvar
						PerdestYIn6 := (destYIn6-YposIn6)/10
						Winset, Disable ,,ahk_id %idtouch6%
						
						Loop, 10
						{
							XposIn6 += PerdestXIn6
							YposIn6 += PerdestYIn6
							SetWinDelay, 2
							WinMove, ahk_id %idtouch6%,, %XposIn6%, %YposIn6%
						}
						
						if(HidIn6>5*ScHeight/6) || (WidIn6>4*ScWidth/5)
						{
							if(HidIn6>5*ScHeight/6)
							{
								PersizeY := (HidIn6 - 5*ScHeight/6)/6
								posYCheck6 := (ScHeight/6)+10
							}
							else
								PersizeY := 0
							
							if(WidIn6>4*ScWidth/5)
							{
								PersizeX := (WidIn6 - 4*ScWidth/5)/6
							}
							else
								PersizeX := 0
						
							Loop, 6
							{
								WidIn6 -= PersizeX		
								HidIn6 -= PersizeY
								SetWinDelay, 2
								WinMove, ahk_id %idtouch6%,,,, %WidIn6%, %HidIn6%
							}
						
						}
						WinGet, MaxOrNotAg, MinMax, ahk_id %idAg%	
						IfWinActive, ahk_id %idtouch6%
							if(MaxOrNotAg != -1)
								WinActivate, ahk_id %idAg%
						
						WinGet, idnow6, ID, A
						if idnow6 in %idtouch6%
							WinActivate, Program Manager ahk_class Progman
						
						gggg := 1
						destYOut6tem := posYCheck6
						;sleep, 100
						break
					}
						
				}   ;if !LDown06 && (MouseXin6<posXCheck6-14
				
					
				if(ggg!=1 && MouseYin6<touchSlideBottomY-1)
				{
					ggg = 1
				}
				else if(ggg=1 and MouseYin6 > touchSlideBottomY-2 and LDown06)
					ggg=0
				else if(ggg=1 and MouseYin6 > touchSlideBottomY-2 and !LDown06)
				{
					g=2
					WinGetPos, XposIn6, YposIn6, WidIn6, HidIn6, ahk_id %idtouch6%
			
				if(XposIn6<ScWidth/10)
					destXIn6 := ScWidth/10
				else if(XposIn6+WidIn6>9*ScWidth/10)
				{
					if(WidIn6>4*ScWidth/5)
						destXIn6 := ScWidth/10
					else
						destXIn6 := (9*ScWidth/10)-WidIn6
				}
				else 
					destXIn6 := XposIn6

			PerdestXIn6 := (destXIn6-XposIn6)/10			
			destYIn6 := touchSlideBottomY-touchSlideYvar
			PerdestYIn6 := (destYIn6-YposIn6)/10
			
			Winset, Disable ,,ahk_id %idtouch6%
			
			Loop, 10
			{
				XposIn6 += PerdestXIn6
				YposIn6 += PerdestYIn6
				SetWinDelay, 2
				WinMove, ahk_id %idtouch6%,, %XposIn6%, %YposIn6%
			}
				
				if(HidIn6>5*ScHeight/6) || (WidIn6>4*ScWidth/5)
				{
					if(HidIn6>5*ScHeight/6)
					{
						PersizeY := (HidIn6 - 5*ScHeight/6)/6
						posYCheck6 := (ScHeight/6)+10
					}
					else
						PersizeY := 0
					
					if(WidIn6>4*ScWidth/5)
					{
						PersizeX := (WidIn6 - 4*ScWidth/5)/6
					}
					else
						PersizeX := 0
				
					Loop, 6
					{
						WidIn6 -= PersizeX		
						HidIn6 -= PersizeY
						SetWinDelay, 2
						WinMove, ahk_id %idtouch6%,,,, %WidIn6%, %HidIn6%
					}
				
				}
				
				WinGet, MaxOrNotAg, MinMax, ahk_id %idAg%	
				IfWinActive, ahk_id %idtouch6%
					if(MaxOrNotAg != -1)
						WinActivate, ahk_id %idAg%
				
				WinGet, idnow6, ID, A
				if idnow6 in %idtouch6%
					WinActivate, Program Manager ahk_class Progman
			
				gggg := 1
				destYOut6tem := posYCheck6
				}
				
			} ;else if g=1
			
			else if(g=2)
			{
				if(MouseYin6 < touchSlideBottomY-1)
				{
					WinGet, MaxOrNotAg, MinMax, ahk_id %idAg%
					IfWinActive, ahk_id %idtouch6%
					if(MaxOrNotAg != -1)
						WinActivate, ahk_id %idAg%
					break
				}
			}
			sleep, 100  ;sleep for Looping in a proper time
		} ;Loop6
		
	}  ; End (weasy and MouseY > ScHeight-2 and (idtouch == idtouch6))







	  







	;044a15 Check these Windows if it is active, idtouch1,3. If yes, pop out and in.
	IfWinActive, ahk_id %idtouch1% 
	{
		WinGetPos, XLeft1, , WLeft1, , ahk_id %idtouch1%
		;if(XLeft1+WLeft1<touchSlideLeftX+10)
		;{
		destXOut1 := touchSlideLeftX+(ScWidth/8)-(7*WLeft1/8)	;It must be - WLeft1 and + WLeft/8
		inSin1 := 0
		; XposOut1 := XLeft1
		XposOut1 := touchSlideLeftX-WLeft1+touchSlideXvar
		Loop, 13
		{
			inSin1 += 0.121
			realXPosOut1 := XLeft1 + Ceil(Sqrt(sin(inSin1))*(destXOut1-XLeft1))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch1%,, %realXPosOut1%   
		}
		
		Loop, 13
		{
			inSin1 -= 0.121
			realXPosOut1 := XposOut1 - Ceil(Sqrt(sin(inSin1))*(XposOut1-destXOut1))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch1%,, %realXPosOut1%  
		}
		sleep, 100
		Send !{ESC}
		IfWinActive, ahk_id %idtouch1%
			WinActivate, Program Manager ahk_class Progman
		
		sleep, 100
		send {Alt Up}
		
	}




	
		

		
		
	;044a16 Check if the active window is maximized when the %idtouch3% is exist.
	IfWinExist, ahk_id %idtouch3%
	{
		WinGet, MaxActiveWin, MinMax, A	
		WinGetPos, XposIn3,,,, ahk_id %idtouch3%
		if (MaxActiveWin==1) && (XposIn3 < touchSlideRightX-3)
		{
			destXIn3 := touchSlideRightX + 1
			PerdestXIn3 := (destXIn3-XposIn3)/6
			Loop, 6
			{
				XposIn3 += PerdestXIn3
				SetWinDelay, 2
				WinMove, ahk_id %idtouch3%,, %XposIn3%
			}
			WinSet, AlwaysOnTop, On, ahk_id %idtouch3%
		}
		;if A is Max and see edge
		;get loss
		;else if A is not Max and not see edge
		;get seen
		else if (MaxActiveWin!=1) && (XposIn3 > touchSlideRightX-3)	;need all line.
		{
			destXIn3 := touchSlideRightX - touchSlideXvar
			PerdestXIn3 := (destXIn3-XposIn3)/6
			Loop, 6
			{
				XposIn3 += PerdestXIn3
				SetWinDelay, 2
				WinMove, ahk_id %idtouch3%,, %XposIn3%
			}
		}
		
		IfWinActive, ahk_id %idtouch3% 
		{
			WinGetPos, XRight3, , WRight3, , ahk_id %idtouch3%
			;if(XRight3>touchSlideRightX-10)
			;{
			destXOut3 := touchSlideRightX-(ScWidth/8)-(WRight3/8)
			inSin3 := 0
			XposOut3 := touchSlideRightX-touchSlideXvar
			Loop, 13
			{
				inSin3 += 0.121
				realXPosOut3 := XRight3 - Ceil(Sqrt(sin(inSin3))*(XRight3-destXOut3))
				SetWinDelay, 2
				WinMove, ahk_id %idtouch3%,, %realXPosOut3%   
			}
			
			Loop, 13
			{
				inSin3 -= 0.121
				realXPosOut3 := XposOut3 - Ceil(Sqrt(sin(inSin3))*(XposOut3-destXOut3))
				SetWinDelay, 2
				WinMove, ahk_id %idtouch3%,, %realXPosOut3%  
			}
			sleep, 100
			Send !{ESC}
			IfWinActive, ahk_id %idtouch3%
				WinActivate, Program Manager ahk_class Progman
			
			sleep, 100
			send {Alt Up}
			
		}
	}
		
		
		
	
	
	;044a17 Check if the idtouch6 is active	
	IfWinActive, ahk_id %idtouch6% 
	{	
		WinGetPos,, YDown6, , HDown6, ahk_id %idtouch6%
		;if(YDown6>touchSlideBottomY-10)
		;{
		destYOut6 := touchSlideBottomY-(ScHeight/8)-(HDown6/8)
		inSin6 := 0
		YposOut6 := touchSlideBottomY-touchSlideYvar
		Loop, 12
		{
			inSin6 += 0.131
			realYPosOut6 := YDown6 - Ceil(Sqrt(sin(inSin6))*(YDown6-destYOut6))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch6%,,, %realYPosOut6%   
		}
		Loop, 12
		{
			inSin6 -= 0.131
			realYPosOut6 := YposOut6 - Ceil(Sqrt(sin(inSin6))*(YposOut6-destYOut6))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch6%,,, %realYPosOut6%  
		}
		sleep, 100
		Send !{ESC}
		IfWinActive, ahk_id %idtouch6%
			WinActivate, Program Manager ahk_class Progman
		
		sleep, 100
		send {Alt Up}
	}




		
	;044a18 Check if the idtouch5 is active
	IfWinActive, ahk_id %idtouch5% 
	{	
		WinGetPos,, YUp5, , HUp5, ahk_id %idtouch5%

		destYOut5 := touchSlideTopY+(ScHeight/8)-(7*HUp5/8)
		inSin5 := 0
		YposOut5 := touchSlideTopY-HUp5+touchSlideYvar
		Loop, 13
		{
			inSin5 += 0.121
			realYPosOut5 := YUp5 + Ceil(Sqrt(sin(inSin5))*(destYOut5-YUp5))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch5%,,, %realYPosOut5%   
		}
		Loop, 13
		{
			inSin5 -= 0.121
			realYPosOut5 := YposOut5 + Ceil(Sqrt(sin(inSin5))*(destYOut5-YposOut5))
			SetWinDelay, 2
			WinMove, ahk_id %idtouch5%,,, %realYPosOut5%  
		}
		sleep, 100
		Send !{ESC}
		IfWinActive, ahk_id %idtouch5%
			WinActivate, Program Manager ahk_class Progman
		
		sleep, 100
		send {Alt Up}
	}



return   ;end CheckMouse




disableWinMethod:
	MouseGetPos, XX, YY, idDisbleWin
	WinGetClass, classDisbleWin, ahk_id %idDisbleWin%
	if !WinExist("ahk_class #32768") && (classDisbleWin <> "Shell_TrayWnd") && (classDisbleWin <> "Button") && (classDisbleWin <> "WorkerW") && (classDisbleWin <> "Progman")
	{
		
		WinGet, Style, Style, ahk_id %idDisbleWin%
		WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idDisbleWin%
		if (Style & 0x8000000) && (Xpos!=0 || Ypos!=0 || Wid!=ScWidth || Hid!=ScHeight)
		{
			SplashTextOn,,, Enable
			WinMove, Enable, , XX-98, YY+24
			WinSet AlwaysOnTop, On, Enable
			
			tran := 255
			Loop, 18
			{
				tran -= 14
				sleep, 10
				WinSet, Transparent, %tran%, ahk_id %idDisbleWin% 
			}
			
			Winset, Enable ,, ahk_id %idDisbleWin%
			;WinSet AlwaysOnTop, Off, ahk_id %idDisbleWin%
			WinActivate, ahk_id %idDisbleWin%
			
			Loop, 18
			{
				tran += 14
				sleep, 10
				WinSet, Transparent, %tran%, ahk_id %idDisbleWin% 
			}
			sleep, 200
			SplashTextOff
		}
		else if(Xpos!=0 || Ypos!=0 || Wid!=ScWidth || Hid!=ScHeight)
		{
			SplashTextOn,,, Disable
			WinMove, Disable, , XX-98, YY+24
			WinSet AlwaysOnTop, On, Disable
			
			tran := 255
			Loop, 12
			{
				tran -= 18
				sleep, 20
				WinSet, Transparent, %tran%, ahk_id %idDisbleWin% 
			}
			
			Winset, Disable ,, ahk_id %idDisbleWin%		
			;WinSet AlwaysOnTop, On, ahk_id %idDisbleWin%
			
			Loop, 12
			{
				tran += 18
				sleep, 10
				WinSet, Transparent, %tran%, ahk_id %idDisbleWin% 
			}
			sleep, 600
			SplashTextOff
		}
	}
return		;disableWinMethod



alwaysOnTopMethod:
	if(idVO != "")
	{
		idAlwaysOT := idVO
		Gosub, CloseVisOptsGUInow
	}
	else
		WinGet, idAlwaysOT, ID, A	;To check that it is the same window such Task Manager
	WinGetClass, classAlwaysOT, A
	if !WinExist("ahk_class #32768") && (classAlwaysOT <> "Shell_TrayWnd") && (classAlwaysOT <> "Button") && (classAlwaysOT <> "WorkerW") && (classAlwaysOT <> "Progman")
	{
		
		WinGet, ExStyle, ExStyle, ahk_id %idAlwaysOT%
		WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idAlwaysOT%
		if (ExStyle & 0x8) && (Xpos!=0 || Ypos!=0 || Wid!=ScWidth || Hid!=ScHeight)
		{
			Winset, Enable ,, ahk_id %idAlwaysOT%
			if(winver == 0 && dpiV == 1)    ;125% screen win7
			{
				SplashTextOn,,,`r          Not always on top.     ;dpi
				WinMove,`r          Not always on top., , Xpos+(Wid/2)-98, Ypos+(Hid/2)-36   ;dpi ;middle of that window
			}
			else if(winver == 0 && dpiV == 0)    ;100% screen win7
			{
				SplashTextOn,,,`r                 Not always on top.     ;dpi
				WinMove,`r                 Not always on top., , Xpos+(Wid/2)-98, Ypos+(Hid/2)-36
			}
			else
			{
				SplashTextOn,,, Not always on top.     ;dpi
				WinMove, Not always on top., , Xpos+(Wid/2)-98, Ypos+(Hid/2)-36
			}
			
			tran := 255
			Loop, 18
			{
				tran -= 14
				sleep, 10
				WinSet, Transparent, %tran%, ahk_id %idAlwaysOT% 
			}
			
			WinSet AlwaysOnTop, Off, ahk_id %idAlwaysOT% 
			WinActivate, ahk_id %idAlwaysOT%
			
			Loop, 18
			{
				tran += 14
				sleep, 10
				WinSet, Transparent, %tran%, ahk_id %idAlwaysOT% 
			}
			sleep, 200
			SplashTextOff
		}
		else if(Xpos!=0 || Ypos!=0 || Wid!=ScWidth || Hid!=ScHeight)
		{
			Winset, Enable ,, ahk_id %idAlwaysOT%
			if(winver == 0 && dpiV == 1)    ;125% screen win7
			{
				SplashTextOn,,,`r              Always on top.   ;dpi
				WinMove,`r              Always on top., , Xpos+(Wid/2)-98, Ypos+(Hid/2)-36
			}
			else if(winver == 0 && dpiV == 0)    ;100% screen win7
			{
				SplashTextOn,,,`r                    Always on top.   ;dpi									
				WinMove,`r                    Always on top., , Xpos+(Wid/2)-98, Ypos+(Hid/2)-36
			}
			else
			{
				SplashTextOn,,, Always on top.   ;dpi									
				WinMove, Always on top., , Xpos+(Wid/2)-98, Ypos+(Hid/2)-36
			}
			tran := 255
			Loop, 12
			{
				tran -= 18
				sleep, 20
				WinSet, Transparent, %tran%, ahk_id %idAlwaysOT% 
			}
			
			WinSet AlwaysOnTop, On, ahk_id %idAlwaysOT% 		
			if(winver == 0 && dpiV == 1)    ;125% screen win7
				WinSet AlwaysOnTop, On,`r              Always on top.	   ;dpi `t
			else if(winver == 0 && dpiV == 0)    ;100% screen win7
				WinSet AlwaysOnTop, On,`r                    Always on top.	   ;dpi `t
			else
				WinSet AlwaysOnTop, On, Always on top.	   ;dpi `t
			Loop, 12
			{
				tran += 18
				sleep, 10
				WinSet, Transparent, %tran%, ahk_id %idAlwaysOT% 
			}
			sleep, 600
			SplashTextOff
		}
	}
return		;alwaysOnTopMethod



TouchSlideWinHotkeyTopMethod:
	if(!weasy && ! || (bitTbLo == 1 && MonitorCount == 1))
	{
		Gosub, CloseVisOptsGUInow
		if(!weasy)
		{
			Tooltip, You need to enable Touch Slide Window or Visible option before.
			sleep, 1000
			Tooltip,
		}
		else
			bounceGoAndBack(30, "up")
	}
	else
	{
		if(idVO != "")
		{
			idLButton := idVO
			Gosub, CloseVisOptsGUInow
		}
		else
			WinGet, idLButton, ID, A
		WinGet, MaxOrNot, MinMax, ahk_id %idLButton%
		if (MaxOrNot)
			sendinput #{Down}
		if (idtouch5 <> idLButton)
			Gosub TouchSlideWinTop
		else
			WinActivate, ahk_id %idLButton%
	}
return

TouchSlideWinHotkeyLeftMethod:
	if(!weasy || (bitTbLo == 0 && MonitorCount == 1))
	{
		Gosub, CloseVisOptsGUInow
		if(!weasy)
		{
			Tooltip, You need to enable Touch Slide Window or Visible option before.
			sleep, 1000
			Tooltip,
		}
		else
			bounceGoAndBack(30, "left")
	}
	else 
	{
		if(idVO != "")
		{
			idLButton := idVO
			;MsgBox, %idVO% %idLButton%
			Gosub, CloseVisOptsGUInow
		}
		else
			WinGet, idLButton, ID, A
		WinGet, MaxOrNot, MinMax, ahk_id %idLButton%
		if (MaxOrNot)
			sendinput #{Down}
		if (idtouch1 <> idLButton)
			Gosub TouchSlideWinLeft
		else
			WinActivate, ahk_id %idLButton%
	}
return

TouchSlideWinHotkeyRightMethod:

	if(!weasy || (bitTbLo == 2 && MonitorCount == 1))
	{
		Gosub, CloseVisOptsGUInow
		if(!weasy)
		{
			Tooltip, You need to enable Touch Slide Window or Visible option before.
			sleep, 1000
			Tooltip,
		}
		else
			bounceGoAndBack(30, "right")
	}
	else
	{
		if(idVO != "")
		{
			;WinActivate, ahk_id %idVO%
			idLButton := idVO
			Gosub, CloseVisOptsGUInow
		}
		else
			WinGet, idLButton, ID, A
		WinGet, MaxOrNot, MinMax, ahk_id %idLButton%
		if (MaxOrNot)
			sendinput #{Down}
		if (idtouch3 <> idLButton)
			Gosub TouchSlideWinRight
		else
			WinActivate, ahk_id %idLButton%
	}
return

TouchSlideWinHotkeyBottomMethod:
	if(!weasy || (bitTbLo == 3 && MonitorCount == 1))
	{
		Gosub, CloseVisOptsGUInow
		if(!weasy)
		{
			Tooltip, You need to enable Touch Slide Window or Visible option before.
			sleep, 1000
			Tooltip,
		}
		else
			bounceGoAndBack(30, "down")
	}
	else
	{
		if(idVO != "")
		{
			idLButton := idVO
			Gosub, CloseVisOptsGUInow
		}
		else
			WinGet, idLButton, ID, A
		WinGet, MaxOrNot, MinMax, ahk_id %idLButton%
		if (MaxOrNot)
			sendinput #{Down}
		if (idtouch6 <> idLButton)
			Gosub TouchSlideWinBottom
		else
			WinActivate, ahk_id %idLButton%
	}
return

PositionWinL:
	Gosub, CloseVisOptsGUInow
	PositionWindow(5)
return
PositionWinR:
	Gosub, CloseVisOptsGUInow
	PositionWindow(6)
return
PositionWinT:
	Gosub, CloseVisOptsGUInow
	PositionWindow(7)
return
PositionWinB:
	Gosub, CloseVisOptsGUInow
	PositionWindow(8)
return
PositionWinTL:
	Gosub, CloseVisOptsGUInow
	PositionWindow(1)
return
PositionWinTR:
	Gosub, CloseVisOptsGUInow
	PositionWindow(2)
return
PositionWinBL:
	Gosub, CloseVisOptsGUInow
	PositionWindow(3)
return
PositionWinBR:
	Gosub, CloseVisOptsGUInow
	PositionWindow(4)
return


PositionWindow(positionNum)
{
	SysGet, MonitorCount, MonitorCount
	WinGet, posMax, MinMax, A
	WinGetPos, posXA, posYA, WidA, HidA, A
	WinGet, placeWinID, ID, A
	
	VarSetCapacity(WP, 44, 0),  NumPut(44,WP)
	DllCall("GetWindowPlacement", "uint", placeWinID, "uint", &WP)
	posXplm := NumGet(WP, 28, "Int")
	posYplm := NumGet(WP, 32, "Int")
	widXplm := NumGet(WP, 36, "Int")
	hidYplm := NumGet(WP, 40, "Int")

	;if it's not snaping.
	;top tsk, posYA == posYplm+48	(Windows' bug)
	;left tsk, posXA == posXplm+74	(Windows' bug)
	
	if((posXA == posXplm || posXA == posXplm+74) && (posYA == posYplm || posYA == posYplm+48) && widXplm == WidA+posXplm && hidYplm == HidA+posYplm)||(posMax==1)
	{
		;fade the window out
		tran := 255
		Loop, 5
		{
			tran -= 52
			sleep, 10
			WinSet, Transparent, %tran%, ahk_id %placeWinID% 
		}
		
		Send {LWin Down}
		if positionNum in 2,4,6
			Send {Right}
			;sendinput #{Right}
		else
			Send {Left}
			;sendinput #{Left}
		sleep, 50	;Do not delete this line.
	}
	
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	area3 := 0
	SysGet, Mon1, Monitor, 1	;must be out of the block.
	if(MonitorCount>1)			;calculate the area of the window overlapping in each monitor
	{
		
		SysGet, Mon2, Monitor, 2
		
		;mon1 area
		leftX := posXA>Mon1Left ? posXA : Mon1Left						;max
		rightX := posXA+WidA<Mon1Right ? posXA+WidA : Mon1Right			;min
		topY := posYA>Mon1Top ? posYA : Mon1Top							;max
		bottomY := posYA+HidA<Mon1Bottom ? posYA+HidA : Mon1Bottom		;min
		if(rightX-leftX<0 || bottomY-topY <0)
			area1 := 0
		else
		{
			area1 := (rightX-leftX)*(bottomY-topY)
			areaMon := 1
		}
		
		;mon2 area
		leftX := posXA>Mon2Left ? posXA : Mon2Left						;max
		rightX := posXA+WidA<Mon2Right ? posXA+WidA : Mon2Right			;min
		topY := posYA>Mon2Top ? posYA : Mon2Top							;max
		bottomY := posYA+HidA<Mon2Bottom ? posYA+HidA : Mon2Bottom		;min
		if(rightX-leftX<0 || bottomY-topY <0)
			area2 := 0
		else
		{
			area2 := (rightX-leftX)*(bottomY-topY)
			areaMon := 2
		}	
		;Msgbox, %area1% %area2% area %Mon1Left% %Mon2Left%
		if(MonitorCount>2)
		{
			SysGet, Mon3, Monitor, 3
			;mon3 area
			leftX := posXA>Mon3Left ? posXA : Mon3Left						;max
			rightX := posXA+WidA<Mon3Right ? posXA+WidA : Mon3Right			;min
			topY := posYA>Mon3Top ? posYA : Mon3Top							;max
			bottomY := posYA+HidA<Mon3Bottom ? posYA+HidA : Mon3Bottom		;min
			if(rightX-leftX<0 || bottomY-topY <0)
				area3 := 0
			else
			{
				area3 := (rightX-leftX)*(bottomY-topY)	
				areaMon := 3
			}
		}
	}
	
	if(MonitorCount == 1 || (area1>area2 && area1>area3))
	{
		pswTopLeftX := Mon1Left
		pswTopLeftY := Mon1Top
		pswWidth := Mon1Right-Mon1Left
		pswHeight := Mon1Bottom-Mon1Top
	}	;if(MonitorCount == 1 || (area1>area2 && area1>area3))
	else if(area2>area1 && area2>area3)
	{
		pswTopLeftX := Mon2Left
		pswTopLeftY := Mon2Top
		pswWidth := Mon2Right-Mon2Left
		pswHeight := Mon2Bottom-Mon2Top
	}
	else	;the 3rd display
	{
		pswTopLeftX := Mon3Left
		pswTopLeftY := Mon3Top
		pswWidth := Mon3Right-Mon3Left
		pswHeight := Mon3Bottom-Mon3Top
	}
	
	;The window must not overlap the taskbar
	if(!InStr(A_OSVersion, "WIN_7") || (areaMon == MonitorPrimary))
	{
		WinGetPos, posXTB, posYTB, WidTB, HidTB, ahk_class Shell_TrayWnd	;Shell_SecondaryTray
		if(posXTB > A_ScreenWidth/3)		;right
			pswWidth -= WidTB
		else if(posYTB > A_ScreenHeight/3)	;bottom
			pswHeight -= HidTB
		else if(WidTB>2*A_ScreenWidth/3)	;top
		{
			pswHeight -= HidTB
			pswTopLeftY += HidTB
		}
		else								;left
		{
			pswWidth -= WidTB
			pswTopLeftX += WidTB
		}
	}
	
	;indicate the position to go
	if positionNum in 1,2,3,4
	{
		pswWidth := pswWidth/2
		pswHeight := pswHeight/2
	}
	else if positionNum in 5,6
	{
		pswWidth := pswWidth/2
		if(SubStr(A_OSVersion,1,3) == "10.")
			pswHeight -= 10
	}
	else if positionNum in 7,8
		pswHeight := pswHeight/2
	
	;if positionNum in 1,5,7
	if positionNum in 2,4,6
		pswTopLeftX := pswTopLeftX + pswWidth
	if positionNum in 3,4,8
		pswTopLeftY := pswTopLeftY + pswHeight
	
	if(SubStr(A_OSVersion,1,3) == "10.")
	{
		RegRead, dpivalue, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI  ;96, 120 and 144
		dpiV := Round((dpivalue - 96)/24)
		
		;Tooltip, %dpiV% yes count%MonitorCount% %MonitorPrimary% %areaMon% %area1% %area2% %area3%
		if(dpiV == 0)		;100%
		{
			pswTopLeftX -= 7
			pswWidth += 14
			pswHeight += 7
		}
		else if(dpiV == 1)		;125%
		{
			pswTopLeftX -= 8
			pswWidth += 16
			pswHeight += 8
		}
		else		;150% or 175%
		{
			pswTopLeftX -= 10
			pswWidth += 20
			pswHeight += 10
		}
	}
	
	WinMove, A,, %pswTopLeftX%, %pswTopLeftY%, %pswWidth%, %pswHeight%
	
	;if it is transparent, show it.
	if((posXA == posXplm || posXA == posXplm+74) && (posYA == posYplm || posYA == posYplm+48) && widXplm == WidA+posXplm && hidYplm == HidA+posYplm)||(posMax==1)
	{
		tran := 0
		Loop, 5
		{
			tran += 52
			sleep, 10
			WinSet, Transparent, %tran%, A
		}
	}
	Send {LWin Up}
	
	if(SubStr(A_OSVersion,1,3) == "10.")
	if positionNum in 5,6
	{
		pswHeight += 10
		WinMove, A,,,,, %pswHeight%
	}
	return
}



	
hotkeyFunction(hkParam1, hkParam2, hkParam3)
{
	if(hkParam1 == "Remap Key")
	{
		sendInputMethod(hkParam2, hkParam3)
	}
	else if(hkParam1 == "Touch Slide Window")
	{
		if(hkParam2 == "Top")
			Gosub, TouchSlideWinHotkeyTopMethod
		else if(hkParam2 == "Left")
			Gosub, TouchSlideWinHotkeyLeftMethod
		else if(hkParam2 == "Right")
			Gosub, TouchSlideWinHotkeyRightMethod
		else		;if(hkParam2 == "Bottom")
			Gosub, TouchSlideWinHotkeyBottomMethod		
	}
	else if(hkParam1 == "Position Windows")
	{
		PositionWindow(hkParam2)
	}
	else if(hkParam1 == "Open Any Files")
	{
		Run, %hkParam2%,, UseErrorLevel
	}
	else if(hkParam1 == "Keep Window On Top")
	{
		Gosub, alwaysOnTopMethod
	}
	else if(hkParam1 == "Change Input Language")	;Change Input Language
	{
		;I need to use pid because Preme cannot change language in the find window when A is used. Find of notepad and notepad++
		WinGet, pidA, PID, A
		SendMessage, 0x50, 0x02,0,, ahk_pid %pidA%	;0x02 is swich forward. 0x04 is switch back.
	}
	else	;if(hkParam1 == "Turn Off/On Preme")
	{
		;Msgbox, 20140813 msg1
		Gosub, Pdisable
		IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, reloadThen
		;Msgbox, 20140813 msg2	
		;Add turn OffOn hotkey to preme.exe and it will reload itself when user presses this hotkey.
		;See the line:		if(ddlshortcutResult%A_Index% == "Turn Off/On Preme")
		IniRead, theNumOFhotkey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, theNumOFhotkeyINI, 0
		if(theNumOFhotkey > 20 || theNumOFhotkey < 0)
			theNumOFhotkey := 20
		Loop, %theNumOFhotkey%
		{
			IniRead, ddlshortcutResult%A_Index%, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutResult%A_Index%INI
			;Msgbox, % "20140813 " . ddlshortcutResult%A_Index%
			if(ddlshortcutResult%A_Index% == "Turn Off/On Preme")
			{
				IniRead, shortcutInputMod, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutInputMod%A_Index%INI
				IniRead, shortcutInputKey, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, shortcutInputKey%A_Index%INI
				IniRead, overwritehotR, %A_AppData%\Preme for Windows\premehotkey.ini, shortcutInputForUse, overwritehot%A_Index%INI, 0
				InputKey := shortcutInputKeyMethod(shortcutInputKey)
				modKey := shortcutmodMethod(shortcutInputMod)
				if(overwritehotR)
					premehotkey = %modKey%%InputKey%	;no * before modKey
				else
					premehotkey = ~%modKey%%InputKey%
				
				if(modKey != "")
					premehotkey = *%premehotkey%
				;Msgbox, 20140813 msg3 %premehotkey%
				Hotkey, %premehotkey%, reloadThenMethod, On
				break	;important
			}
		}
	}
	sendinput {control up}
	send {Alt Up}
	hkParam2 = ""
	hkParam3 = ""
	return
}	;hotkeyFunction
	
reloadThenMethod:
	;Msgbox, 20140813 msg4
	IniWrite, 1, %A_AppData%\Preme for Windows\premedata.ini, Operation, premestate
	IniRead, reloadThenR, %A_AppData%\Preme for Windows\premedata.ini, Operation, reloadThen
	if(reloadThenR==1)
	{
		IniWrite, 0, %A_AppData%\Preme for Windows\premedata.ini, Operation, reloadThen
		Reload
	}
	;Gosub, reloadpremeengMethod		;Go to reload in this method.
return

;Obsolete
; taskListMethod:
	; MouseGetPos,,,, conWD
	; if(conWD != "MSTaskListWClass1")
	; {
		; send, {Enter}
		; tempTaskListVar = 0
		; SetTimer, taskListMethod, off
	; }
; return		;taskListMethod
splashTextOffMethod:
	SplashTextOff
	SetTimer, splashTextOffMethod, Off
return
			
bounceGoAndBack(distance, direction)
{
	if(direction == "down" || direction == "right")
		backwardL = 1
	else
		backwardL = -1
	
	WinGetPos, XposA, YposA,,, A
	inSin := 0

	if(direction == "down" || direction == "up")
	{
		desYbounce := YposA + distance
		Loop, 10
		{
			inSin += 0.157
			realYPosBounce := YposA + (Ceil(Sqrt(sin(inSin))*(desYbounce-YposA)))*backwardL
			SetWinDelay, 2
			WinMove, A,,, %realYPosBounce%
		}
		Loop, 10
		{
			inSin -= 0.157
			realYPosBounce := YposA - (Ceil(Sqrt(sin(inSin))*(YposA-desYbounce)))*backwardL
			SetWinDelay, 2
			WinMove, A,,, %realYPosBounce%
		}
	}
	else
	{
		desXbounce := XposA + distance
		Loop, 10
		{
			inSin += 0.157
			realXPosBounce := XposA + (Ceil(Sqrt(sin(inSin))*(desXbounce-XposA)))*backwardL
			SetWinDelay, 2
			WinMove, A,, %realXPosBounce%
		}
		Loop, 10
		{
			inSin -= 0.157
			realXPosBounce := XposA - (Ceil(Sqrt(sin(inSin))*(XposA-desXbounce)))*backwardL
			SetWinDelay, 2
			WinMove, A,, %realXPosBounce%
		}
	}
}	;bounceGoAndBack
	
	
	

;Volume functions ############################################
VA_GetMasterVolume(channel="", device_desc="playback")
{
    if ! aev := VA_GetAudioEndpointVolume(device_desc)
        return
    if channel =
        VA_IAudioEndpointVolume_GetMasterVolumeLevelScalar(aev, vol)
    else
		return
        ; VA_IAudioEndpointVolume_GetChannelVolumeLevelScalar(aev, channel-1, vol)
    ObjRelease(aev)
    return Round(vol*100,0)
}

VA_GetAudioEndpointVolume(device_desc="playback")
{
    if ! device := VA_GetDevice(device_desc)
        return 0
    VA_IMMDevice_Activate(device, "{5CDF2C82-841E-4546-9722-0CF74078229A}", 7, 0, endpointVolume)
    ObjRelease(device)
    return endpointVolume
}

VA_GetDevice(device_desc="playback")
{
    static CLSID_MMDeviceEnumerator := "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
        , IID_IMMDeviceEnumerator := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
    if !(deviceEnumerator := ComObjCreate(CLSID_MMDeviceEnumerator, IID_IMMDeviceEnumerator))
        return 0
    ; if (DllCall("ole32\CoCreateInstance"
                ; , "ptr", VA_GUID(CLSID_MMDeviceEnumerator, "{BCDE0395-E52F-467C-8E3D-C4579291692E}")
                ; , "ptr", 0, "uint", 21
                ; , "ptr", VA_GUID(IID_IMMDeviceEnumerator, "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
                ; , "ptr*", deviceEnumerator)) != 0
        ; return 0
    
    device := 0
    
    if VA_IMMDeviceEnumerator_GetDevice(deviceEnumerator, device_desc, device) = 0
        goto VA_GetDevice_Return
    
    if device_desc is integer
    {
        m2 := device_desc
        if m2 >= 4096 ; Probably a device pointer, passed here indirectly via VA_GetAudioMeter or such.
            return m2, ObjAddRef(m2)
    }
    else
        RegExMatch(device_desc, "(.*?)\s*(?::(\d+))?$", m)
    
    if m1 in playback,p
        m1 := "", flow := 0 ; eRender
    else if m1 in capture,c
        m1 := "", flow := 1 ; eCapture
    else if (m1 . m2) = ""  ; no name or number specified
        m1 := "", flow := 0 ; eRender (default)
    else
        flow := 2 ; eAll
    
    if (m1 . m2) = ""   ; no name or number (maybe "playback" or "capture")
    {
        VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(deviceEnumerator, flow, 0, device)
        goto VA_GetDevice_Return
    }

    VA_IMMDeviceEnumerator_EnumAudioEndpoints(deviceEnumerator, flow, 1, devices)
    
    if m1 =
    {
        VA_IMMDeviceCollection_Item(devices, m2-1, device)
        goto VA_GetDevice_Return
    }
    
    VA_IMMDeviceCollection_GetCount(devices, count)
    index := 0
    Loop % count
        if VA_IMMDeviceCollection_Item(devices, A_Index-1, device) = 0
            if InStr(VA_GetDeviceName(device), m1) && (m2 = "" || ++index = m2)
                goto VA_GetDevice_Return
            else
                ObjRelease(device), device:=0

VA_GetDevice_Return:
    ObjRelease(deviceEnumerator)
    if devices
        ObjRelease(devices)
    
    return device ; may be 0
}

VA_IAudioEndpointVolume_GetMasterVolumeLevelScalar(this, ByRef Level) {
    return DllCall(NumGet(NumGet(this+0)+9*A_PtrSize), "ptr", this, "float*", Level)
}

; VA_IAudioEndpointVolume_GetChannelVolumeLevelScalar(this, Channel, ByRef Level) {
    ; return DllCall(NumGet(NumGet(this+0)+13*A_PtrSize), "ptr", this, "uint", Channel, "float*", Level)
; }

VA_IMMDevice_Activate(this, iid, ClsCtx, ActivationParams, ByRef Interface) {
    return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "ptr", VA_GUID(iid), "uint", ClsCtx, "uint", ActivationParams, "ptr*", Interface)
}

VA_IMMDeviceEnumerator_GetDevice(this, id, ByRef Device) {
    return DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "wstr", id, "ptr*", Device)
}

VA_IMMDeviceEnumerator_GetDefaultAudioEndpoint(this, DataFlow, Role, ByRef Endpoint) {
    return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "int", DataFlow, "int", Role, "ptr*", Endpoint)
}

VA_IMMDeviceEnumerator_EnumAudioEndpoints(this, DataFlow, StateMask, ByRef Devices) {
    return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "int", DataFlow, "uint", StateMask, "ptr*", Devices)
}

VA_IMMDeviceCollection_Item(this, Index, ByRef Device) {
    return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", Index, "ptr*", Device)
}

VA_IMMDeviceCollection_GetCount(this, ByRef Count) {
    return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "uint*", Count)
}

VA_GetDeviceName(device)
{
    static PKEY_Device_FriendlyName
    if !VarSetCapacity(PKEY_Device_FriendlyName)
        VarSetCapacity(PKEY_Device_FriendlyName, 20)
        ,VA_GUID(PKEY_Device_FriendlyName :="{A45C254E-DF1C-4EFD-8020-67D146A850E0}")
        ,NumPut(14, PKEY_Device_FriendlyName, 16)
    VarSetCapacity(prop, 16)
    VA_IMMDevice_OpenPropertyStore(device, 0, store)
    ; store->GetValue(.., [out] prop)
    DllCall(NumGet(NumGet(store+0)+5*A_PtrSize), "ptr", store, "ptr", &PKEY_Device_FriendlyName, "ptr", &prop)
    ObjRelease(store)
    VA_WStrOut(deviceName := NumGet(prop,8))
    return deviceName
}

VA_GUID(ByRef guid_out, guid_in="%guid_out%") {
    if (guid_in == "%guid_out%")
        guid_in :=   guid_out
    if  guid_in is integer
        return guid_in
    VarSetCapacity(guid_out, 16, 0)
	DllCall("ole32\CLSIDFromString", "wstr", guid_in, "ptr", &guid_out)
	return &guid_out
}

VA_IMMDevice_OpenPropertyStore(this, Access, ByRef Properties) {
    return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", Access, "ptr*", Properties)
}

VA_WStrOut(ByRef str) {
    str := StrGet(ptr := str, "UTF-16")
    DllCall("ole32\CoTaskMemFree", "ptr", ptr)  ; FREES THE STRING.
}


;Volume functions ############################################
	
premehotkeyMM1:
	sendinput {%shortcutOutputModMod1% Down}
return
premehotkeyMMU1:
	sendinput {%shortcutOutputModMod1% Up}
return
premehotkeyMM2:
	sendinput {%shortcutOutputModMod2% Down}
return
premehotkeyMMU2:
	sendinput {%shortcutOutputModMod2% Up}
return
premehotkeyMM3:
	sendinput {%shortcutOutputModMod3% Down}
return
premehotkeyMMU3:
	sendinput {%shortcutOutputModMod3% Up}
return
premehotkeyMM4:
	sendinput {%shortcutOutputModMod4% Down}
return
premehotkeyMMU4:
	sendinput {%shortcutOutputModMod4% Up}
return
premehotkeyMM5:
	sendinput {%shortcutOutputModMod5% Down}
return
premehotkeyMMU5:
	sendinput {%shortcutOutputModMod5% Up}
return
premehotkeyMM6:
	sendinput {%shortcutOutputModMod6% Down}
return
premehotkeyMMU6:
	sendinput {%shortcutOutputModMod6% Up}
return
premehotkeyMM7:
	sendinput {%shortcutOutputModMod7% Down}
return
premehotkeyMMU7:
	sendinput {%shortcutOutputModMod7% Up}
return
premehotkeyMM8:
	sendinput {%shortcutOutputModMod8% Down}
return
premehotkeyMMU8:
	sendinput {%shortcutOutputModMod8% Up}
return



premehotkey1:
	PostMessage, 0x5556, 80, 21,, ahk_class PremeforWin
return
premehotkey2:
	PostMessage, 0x5556, 80, 22,, ahk_class PremeforWin
return
premehotkey3:
	PostMessage, 0x5556, 80, 23,, ahk_class PremeforWin
return
premehotkey4:
	PostMessage, 0x5556, 80, 24,, ahk_class PremeforWin
return
premehotkey5:
	PostMessage, 0x5556, 80, 25,, ahk_class PremeforWin
return
premehotkey6:
	PostMessage, 0x5556, 80, 26,, ahk_class PremeforWin
return
premehotkey7:
	PostMessage, 0x5556, 80, 27,, ahk_class PremeforWin
return
premehotkey8:
	PostMessage, 0x5556, 80, 28,, ahk_class PremeforWin
return
premehotkey9:
	PostMessage, 0x5556, 80, 29,, ahk_class PremeforWin
return
premehotkey10:
	PostMessage, 0x5556, 80, 30,, ahk_class PremeforWin
return
premehotkey11:
	PostMessage, 0x5556, 80, 31,, ahk_class PremeforWin
return
premehotkey12:
	PostMessage, 0x5556, 80, 32,, ahk_class PremeforWin
return
premehotkey13:
	PostMessage, 0x5556, 80, 33,, ahk_class PremeforWin
return
premehotkey14:
	PostMessage, 0x5556, 80, 34,, ahk_class PremeforWin
return
premehotkey15:
	PostMessage, 0x5556, 80, 35,, ahk_class PremeforWin
return
premehotkey16:
	PostMessage, 0x5556, 80, 36,, ahk_class PremeforWin
return
premehotkey17:
	PostMessage, 0x5556, 80, 37,, ahk_class PremeforWin
return
premehotkey18:
	PostMessage, 0x5556, 80, 38,, ahk_class PremeforWin
return
premehotkey19:
	PostMessage, 0x5556, 80, 39,, ahk_class PremeforWin
return
premehotkey20:
	PostMessage, 0x5556, 80, 40,, ahk_class PremeforWin
return
	

MsgMonitor(wParam, lParam, msg)
{
    ; Since returning quickly is often important, it is better to use a ToolTip than
    ; something like MsgBox that would prevent the function from finishing:
    ;ToolTip Message %msg% arrived:`nWPARAM: %wParam% %lParam%   ;`nLPARAM: %lParam%
	if (wParam == 1)
		Gosub wheelDownButton
	else if (wParam == 2)
		Gosub wheelUpButton
	else if (wParam == 3)
		Gosub leftButton
	else if (wParam == 4)
		Gosub mButton
	else if (wParam == 5)
		Gosub rightButton
	else if (wParam == 6)
		Gosub escButton
	else if (wParam == 80)	;hotkey
	{
		if (lParam == 21)
			Gosub hotkeyLabel1
		else if (lParam == 22)
			Gosub hotkeyLabel2
		else if (lParam == 23)
			Gosub hotkeyLabel3
		else if (lParam == 24)
			Gosub hotkeyLabel4
		else if (lParam == 25)
			Gosub hotkeyLabel5
		else if (lParam == 26)
			Gosub hotkeyLabel6
		else if (lParam == 27)
			Gosub hotkeyLabel7
		else if (lParam == 28)
			Gosub hotkeyLabel8
		else if (lParam == 29)
			Gosub hotkeyLabel9
		else if (lParam == 30)
			Gosub hotkeyLabel10
		else if (lParam == 31)
			Gosub hotkeyLabel11
		else if (lParam == 32)
			Gosub hotkeyLabel12
		else if (lParam ==33)
			Gosub hotkeyLabel13
		else if (lParam == 34)
			Gosub hotkeyLabel14
		else if (lParam == 35)
			Gosub hotkeyLabel15
		else if (lParam == 36)
			Gosub hotkeyLabel16
		else if (lParam == 37)
			Gosub hotkeyLabel17
		else if (lParam == 38)
			Gosub hotkeyLabel18
		else if (lParam == 39)
			Gosub hotkeyLabel19
		else if (lParam == 40)
			Gosub hotkeyLabel20
	}
	else if (wParam == 90)		;some operation
	{
		if(lParam == 91)		;readINIandReload
		{
			Gosub, submitanddo
		}
		else if(lParam == 92)		;readINIandReloadBig
		{
			Gosub, submitanddoBig
		}
		else if(lParam == 93)	;show tray icon
		{
			Gosub, ShowTrayMethod
		}
		else if(lParam == 94)	;hide tray icon
			menu, tray, NoIcon
		else if(lParam == 95)	;buttonOK, Cancel
		{
			if(A_IsCompiled)
				Gosub, reloadpremeengMethod
			else	;!A_IsCompiled
			{
				Gosub, readWinKeepPosMethod	;id, size and position of sliding window.
				Gosub, engineWithINI
				Gosub, startButtonListener
				Gosub, buildSmallPremeGUI
			}
			return
		}
		else if (lParam == 96)	;close premeeng.exe
		{
			Process, Close, premeeng.exe
		}
		else if (lParam == 98)	;for uninstalling from WPF
		{
			menu, tray, NoIcon
			
			IfNotExist, %A_AppData%\Preme for Windows\bin\prememanage.exe
				FileCopy, %A_ScriptFullPath%, %A_AppData%\Preme for Windows\bin\prememanage.exe, 1
			run, %A_AppData%\Preme for Windows\bin\prememanage.exe uninstallplease
			Gosub Pclose
		}
		else if (lParam == 99)
		{
			Gosub Pclose
		}
		else if (lParam == 100)
		{
			;close immediately from closeSameName
			OnExit,
			ExitApp		;very exception
		}	

	}
	return
}


func_WM_POWERBROADCAST(wParam, lParam)  
{
	if(wParam == 4)
	IfExist, %A_WinDir%\System32\Tasks\PremeLogonStart
	{
		OnExit,
		Process, Close, premeeng.exe
		ExitApp
	}
}     ;func_WM_POWER

ShowTrayMethod:
	if(dpiV == 2)
		menu, tray, Icon, %A_AppData%\Preme for Windows\Untitled-23big.ico	
	else if(dpiV == 1)
		menu, tray, Icon, %A_AppData%\Preme for Windows\Untitled-23big.ico
	else ;96
		menu, tray, Icon, %A_AppData%\Preme for Windows\Untitled-32.ico
	menu, tray, Icon
return

writeActiveClassFunc:
	WinGetTitle, smallWinBlendTitle, A
	WinActivate, ahk_class Shell_TrayWnd
	TC := A_TickCount
	Loop, {
		WinGetClass, classEveryCheck, A
		if(classEveryCheck != "PremeforWin" && classEveryCheck != "TaskListThumbnailWnd" && classEveryCheck != "Shell_TrayWnd" && classEveryCheck != "" && classEveryCheck != "Ghost" && !InStr(classEveryCheck, "HwndWrapper"))
		{
			
			FileAppend, %classEveryCheck%, %A_AppData%\Preme for Windows\tempClass.txt
			sleep, 1000
			WinActivate, %smallWinBlendTitle%
			ExitApp
			Break
		}
		Tooltip, Choose the window you want.
		sleep, 100
		if(A_TickCount-TC > 10500)
		{
			WinActivate, %smallWinBlendTitle%
			ExitApp
		}
	}
	
	
	ExitApp
return		;writeActiveClassFunc










;044 EngineCode function
EngineCode:

	WM_DISPLAYCHANGE(wParam, lParam)        ;initiate many variable for sliding windows.
	OnMessage(0x7E, "WM_DISPLAYCHANGE")     ;Check every time display changing(add,decrease or change resolution)
	OnMessage(0x5556, "MsgMonitor")
	if A_IsAdmin
		OnMessage(0x218, "func_WM_POWERBROADCAST")
	
	OnExit, ExitSub
	
	;OnMessage(0x11, "func_WM_POWER")		;obsolete
	;OnMessage(0x4a, "Receive_WM_COPYDATA")
	
	#MaxHotkeysPerInterval 2000      ;Protect for max hotkeysPerInterval
	;044a if (w3d || wTaskSwitcher || wstartButton || weasy || whideactive)
	if (w3d || wTaskSwitcher || wstartButton || weasy || whideactive || wuserkeyrun1 || wuserkeyrun2 || wuserkeyrun3 || wuserkeyrun4 || enableTLeach || enableTReach || enableBLeach || enableBReach)
	{
		SetTimer, CheckMouse, 100
	}
	else
	{
		SetTimer, CheckMouse, off
	}
	




Return   ;EngineCode















;044b ESC twice function
~Escape::
	PostMessage, 0x5556, 6,,, ahk_class PremeforWin
	if(ErrorLevel==1 && A_IsCompiled)
	{
		if(varForRunPremeExe > 5)
		{
			Run, %A_AppData%\Preme for Windows\bin\preme.exe esc,, UseErrorLevel
			;Run, %A_AppData%\Preme for Windows\bin\preme.exe,, UseErrorLevel
			varForRunPremeExe = -1
		}
		varForRunPremeExe += 1
	}
	sleep, 400
return ;end of doubleEsc 

;044c Lbutton function
~vk01::            ;LButton
	PostMessage, 0x5556, 3,,, ahk_class PremeforWin
	if(ErrorLevel==1 && A_IsCompiled)
	{
		if(varForRunPremeExe > 5)
		{
			;Run, %A_AppData%\Preme for Windows\bin\preme.exe,, UseErrorLevel
			Run, %A_AppData%\Preme for Windows\bin\preme.exe vk01,, UseErrorLevel
			varForRunPremeExe = -1
		}
		varForRunPremeExe += 1
	}
return  ;end of LButton

;044d MButton to close the window
~vk04::         ;MButton::
	PostMessage, 0x5556, 4,,, ahk_class PremeforWin
	if(ErrorLevel==1 && A_IsCompiled)
	{
		if(varForRunPremeExe > 5)
		{	
			Run, %A_AppData%\Preme for Windows\bin\preme.exe vk04,, UseErrorLevel
			;Run, %A_AppData%\Preme for Windows\bin\preme.exe,, UseErrorLevel
			varForRunPremeExe = -1
		}
		varForRunPremeExe += 1
	}	
return ;end of MButton

;044e WheelDown to minimize the window (only cursor on top)
wheelDownHotkey:     ;WheelDown::
	PostMessage, 0x5556, 1,,, ahk_class PremeforWin
	;Tooltip, error is %ErrorLevel%
	if(ErrorLevel==1 && A_IsCompiled)
	{
		Sendinput {vk9e}
		if(varForRunPremeExe > 5)
		{
			Run, %A_AppData%\Preme for Windows\bin\preme.exe whd,, UseErrorLevel
			;Run, %A_AppData%\Preme for Windows\bin\preme.exe,, UseErrorLevel
			varForRunPremeExe = -1
		}
		varForRunPremeExe += 1
	}
return ;end of WheelDown

;044f WheelUp to maximize the window (only cursor on top)////////////////////////////////////////////////
wheelUpHotkey:            ;WheelUp::
	PostMessage, 0x5556, 2,,, ahk_class PremeforWin
	if(ErrorLevel==1 && A_IsCompiled)
	{
		Sendinput {vk9f}
		if(varForRunPremeExe > 5)
		{
			Run, %A_AppData%\Preme for Windows\bin\preme.exe whu,, UseErrorLevel
			;Run, %A_AppData%\Preme for Windows\bin\preme.exe,, UseErrorLevel
			varForRunPremeExe = -1
		}
		varForRunPremeExe += 1
	}
return ;end of WheelUp

;044g Right click to move the cursor automatically.
~*vk02::         ;RButton
	PostMessage, 0x5556, 5,,, ahk_class PremeforWin
	if(ErrorLevel==1 && A_IsCompiled)
	{
		if(varForRunPremeExe > 5)
		{
			Run, %A_AppData%\Preme for Windows\bin\preme.exe vk02,, UseErrorLevel
			;Run, %A_AppData%\Preme for Windows\bin\preme.exe,, UseErrorLevel
			varForRunPremeExe = -1
		}
		varForRunPremeExe += 1
	}	
return      ;RButton
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	

;Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, 
;Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, 
;Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, 
;Real button method, Real button method, Real button method, Real button method, Real button method, Real button method, Real button method,  

hotkeyLabel1:
	hotkeyFunction(ddlshortcutResult1, shortcutParam11, shortcutParam21)
return
hotkeyLabel2:
	hotkeyFunction(ddlshortcutResult2, shortcutParam12, shortcutParam22)
return
hotkeyLabel3:
	hotkeyFunction(ddlshortcutResult3, shortcutParam13, shortcutParam23)
return
hotkeyLabel4:
	hotkeyFunction(ddlshortcutResult4, shortcutParam14, shortcutParam24)
return
hotkeyLabel5:
	hotkeyFunction(ddlshortcutResult5, shortcutParam15, shortcutParam25)
return
hotkeyLabel6:
	hotkeyFunction(ddlshortcutResult6, shortcutParam16, shortcutParam26)
return
hotkeyLabel7:
	hotkeyFunction(ddlshortcutResult7, shortcutParam17, shortcutParam27)
return
hotkeyLabel8:
	hotkeyFunction(ddlshortcutResult8, shortcutParam18, shortcutParam28)
return
hotkeyLabel9:
	hotkeyFunction(ddlshortcutResult9, shortcutParam19, shortcutParam29)
return
hotkeyLabel10:
	hotkeyFunction(ddlshortcutResult10, shortcutParam110, shortcutParam210)
return
hotkeyLabel11:
	hotkeyFunction(ddlshortcutResult11, shortcutParam111, shortcutParam211)
return
hotkeyLabel12:
	hotkeyFunction(ddlshortcutResult12, shortcutParam112, shortcutParam212)
return
hotkeyLabel13:
	hotkeyFunction(ddlshortcutResult13, shortcutParam113, shortcutParam213)
return
hotkeyLabel14:
	hotkeyFunction(ddlshortcutResult14, shortcutParam114, shortcutParam214)
return
hotkeyLabel15:
	hotkeyFunction(ddlshortcutResult15, shortcutParam115, shortcutParam215)
return
hotkeyLabel16:
	hotkeyFunction(ddlshortcutResult16, shortcutParam116, shortcutParam216)
return
hotkeyLabel17:
	hotkeyFunction(ddlshortcutResult17, shortcutParam117, shortcutParam217)
return
hotkeyLabel18:
	hotkeyFunction(ddlshortcutResult18, shortcutParam118, shortcutParam218)
return
hotkeyLabel19:
	hotkeyFunction(ddlshortcutResult19, shortcutParam119, shortcutParam219)
return
hotkeyLabel20:
	hotkeyFunction(ddlshortcutResult20, shortcutParam120, shortcutParam220)
return

RefreshTray()	;update tray icon
{
	if(SubStr(A_OSVersion,1,3) == "10.")	;Windows 10
		conReTray := "ToolbarWindow322"
	else
		conReTray := "ToolbarWindow321"
		
	ControlGetPos,,,w,h, %conReTray%, AHK_class Shell_TrayWnd
	width:=w
	height:=h
	While % ((h:=h-16)>0 and w:=width){
		While % ((w:=w-14)>0){
			PostMessage, 0x200,0,% ((height-h) >> 16)+width-w, %conReTray%, AHK_class Shell_TrayWnd
			;Msgbox, error is %ErrorLevel% %h% %w%
		}
	}
	;TrayTip, Preme for Windows, Tray Refreshed wid=%width% height=%height% %conReTray%,, 1		;1 is info, 2 is Warning, 3 is error.
}




















escButton:
	WinGet, idESC, ID, A  ;To check that it is the same window such Task Manager
	WinGetClass, classESC, A
	;IfWinNotExist, ahk_class #32768   ;WinNotExist("ahk_class #32768") && 
	if wes1 && !WinExist("ahk_class #32768") && (classESC <> "Shell_TrayWnd") && (classESC <> "Button") && (classESC <> "WorkerW") && (classESC <> "Progman")
	{
		Loop, {
			EscDown:=GetKeyState("Escape","P") 
			If (!EscDown) 
				  Break 
			sleep, 20
		} 
		TC := A_TickCount

		Loop, {
		
			EscDown:=GetKeyState("Escape","P") 
			IfWinExist , ahk_id %idESC%
				If EscDown {
					WinGet, ExStyleFullS, ExStyle, ahk_id %idESC%
					WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idESC%
					;if (color0 == "0x866215")||(color0 == "0xB2AF2F")||(color0 == "0xA4AB2C")||!wFullSD
					if (Xpos!=0) || !(ExStyleFullS & 0x8) || (Ypos!=0) || (Wid!=ScWidth) || (Hid!=ScHeight)
					{
						if(blacklistvar4!=2||(classESC == blacklistcls41)||(classESC == blacklistcls42)||(classESC == blacklistcls43)||(classESC == blacklistcls44)||(classESC == blacklistcls45))
						if !(blacklistvar4==1 && ((classESC == blacklistcls41)||(classESC == blacklistcls42)||(classESC == blacklistcls43)||(classESC == blacklistcls44)||(classESC == blacklistcls45)))
						{
							Send, {ESC UP} 
							;if (ExStyleMin & 0x100) && !(ExStyleMin & 0x80)
							;WinClose, ahk_id %idESC%
							Send, !{F4}
							
							sleep, 200 
							send {Alt Up}
						}
					} 
					Break 
				}
			If (A_TickCount-TC) > 200 
				Break
			sleep, 50	
			; IfWinExist , ahk_id %idESC%
		}
	}  ;if win not exist

return ;end of escButton 





leftButton:            ;LButton
	CoordMode, Mouse, Screen
	MouseGetPos, XX, YY, idLButton, controlL
	WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idLButton%
	
	;044c1 If the pointer is near the top of window and alwaysontop or TouchSW is enable.
	if (YY<Ypos+58+dpiV*(3*(2-dpiV)))    ;dpi 58,61
	{
		WinGetClass, class, ahk_id %idLButton% 
		WinGet, StyleL, Style, ahk_id %idLButton%	
		WinGet, ExStyleL, ExStyle, ahk_id %idLButton% 
		WinGet, MaxOrNot, MinMax, ahk_id %idLButton%
		
		SendMessage, 0x84,, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %idLButton%
		ErrorKeepL := ErrorLevel
		; XXcloseTR := Xpos+Wid-20	;20
		; YYcloseTR := Ypos+9			;9
		; SendMessage, 0x84,, (XXcloseTR & 0xFFFF) | (YYcloseTR & 0xFFFF) << 16,, ahk_id %idLButton%
		; ErrorKeepTR := ErrorLevel		;check by pointing cursor on the close button and check if it shows 20
		
		;Tooltip, controlL %controlL% and %ErrorKeepL% style %StyleL% Ex %ExStyleL%
		;044c11 if (Wid<215)||!(ExStyleL & 0x100)||(ExStyleL & 0x80), do nothing.
		;if (Wid<215)||!(ExStyleL & 0x100)||(ExStyleL & 0x80)      
		if (Wid<215)||!(ExStyleL & 0x100)||(ExStyleL & 0x80)  ;||(StyleL & 0xF0000 != 983040)
		{
			;Do Nothing
		}
		
		;044c12 else if the pointer selects the idtouch1
		else if (idtouch1 == idLButton) 
		{
			;044c111 if the pointer selects title bar, slide it to posXkeep1 and posYkeep1
			;if(ErrorKeepL==2)||((class == "IEFrame"|| class == "CabinetWClass")&&winver==0&&ErrorKeepL==1&&YY<Ypos+35+dpiV*(7*(2-dpiV)))   ;dpi 35 42
			
			if(ErrorKeepL==2)||(ErrorKeepL==1 && controlL == "ReBarWindow321")
			{   ;If it is that window, Slide window to posXkeep1 and posYkeep1
				KeyWait, LButton, T0.5
				WinGetPos, XposAft, YposAft, , , ahk_id %idLButton% 
				
				if(Xpos==XposAft&&Ypos==YposAft)
				{
					;Deactivate window
		
					CheckLessLeft := Abs(posXkeep1-Xpos)+Abs(posYkeep1-Ypos)
					if(CheckLessLeft<10)
					{
						destX := Xpos + 60
						destY := Ypos + 18
					}
					else
					{
						destX := posXkeep1
						destY := posYkeep1
					}
					
					Divider := Sqrt(Sqrt(((destX-Xpos)**2)+((destY-Ypos)**2)))//2.2     ;// is divide and ignore decimal
					PerdestX := (destX-Xpos)/Divider
					PerdestY := (destY-Ypos)/Divider
					
					Loop, %Divider%
					{
						Xpos += PerdestX
						Ypos += PerdestY
						SetWinDelay, 2
						WinMove, ahk_id %idtouch1%,, %Xpos%, %Ypos% 
					}
					
					if(Wid != sizeXkeep1) || (Hid != sizeYkeep1)
					{
						PersizeX := (sizeXkeep1-Wid)/6
						PersizeY := (sizeYkeep1-Hid)/6
						Loop, 6
						{
							Wid += PersizeX
							Hid += PersizeY
							SetWinDelay, 2
							WinMove, ahk_id %idtouch1%,,,, %Wid%, %Hid%
						}
						
					}
					
					idtouch1 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch1INI
					if(winlefttop != 1)
						WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
				}
			}
		
			;044c112 else if the pointer selects minimize button, slide out to the old position.     dpi  82-101  112-136    21-25
			else if(XX<Xpos+Wid-82-dpiV*(19*(2-dpiV))&&XX>Xpos+Wid-112-dpiV*(24*(2-dpiV))&&YY>Ypos&&YY<Ypos+( 21+dpiV*(4*(2-dpiV)) ))
			;else if(XX<Xpos+Wid-82&&XX>Xpos+Wid-112&&YY>Ypos&&YY<Ypos+21)				
			{
				Winset, Disable ,,ahk_id %idtouch1% ;disable for no minimizing, then enable at the old position(inside screen)
			
				CheckLessLeft := Abs(posXkeep1-Xpos)+Abs(posYkeep1-Ypos)
				if(CheckLessLeft<10)
				{
					destX := Xpos + 60
					destY := Ypos - 18
				}
				else
				{
					destX := posXkeep1
					destY := posYkeep1
				}
				
				Divider := Sqrt(Sqrt(((destX-Xpos)**2)+((destY-Ypos)**2)))//2.2
				PerdestX := (destX-Xpos)/Divider
				PerdestY := (destY-Ypos)/Divider
				
				Loop, %Divider%
				{
					Xpos += PerdestX
					Ypos += PerdestY
					SetWinDelay, 2
					WinMove, ahk_id %idtouch1%,, %Xpos%, %Ypos% 
				}
				
				if(Wid != sizeXkeep1) || (Hid != sizeYkeep1)
				{
					PersizeX := (sizeXkeep1-Wid)/6
					PersizeY := (sizeYkeep1-Hid)/6
					Loop, 6
					{
						Wid += PersizeX
						Hid += PersizeY
						SetWinDelay, 2
						WinMove, ahk_id %idtouch1%,,,, %Wid%, %Hid%
					}
					
				}
				
				Winset, Enable ,, ahk_id %idtouch1%
				
				idtouch1 = 0x00000
				IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch1INI
				if(winlefttop != 1)
					WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
			
			}

		}     ;else if InStr(idtouch1, idLButton)
		
		
		;044c13 else if the pointer select the idtouch3
		else if InStr(idtouch3, idLButton) 
		{
			;044c121 if the pointer selects title bar, slide it to posXkeep3 and posYkeep3
			
			if(ErrorKeepL==2)||(ErrorKeepL==1 && controlL == "ReBarWindow321")
			{ ;If it is that window, Slide window to posXkeep3 and posYkeep3
				KeyWait, LButton, T0.5
				WinGetPos, XposAft, YposAft, , , ahk_id %idLButton% 

				if(Xpos==XposAft&&Ypos==YposAft)
				{
					;Move win out
						
					CheckLessRight := Abs(posXkeep3-Xpos)+Abs(posYkeep3-Ypos)
					if(CheckLessRight<10)
					{
						destXIn3 := Xpos - 60
						destYIn3 := Ypos - 18
					}
					else
					{
						destXIn3 := posXkeep3
						destYIn3 := posYkeep3
					}
						
					Divider := Sqrt(Sqrt(((destXIn3-Xpos)**2)+((destYIn3-Ypos)**2)))//2.2	
					PerdestXIn3 := (destXIn3-Xpos)/Divider
					PerdestYIn3 := (destYIn3-Ypos)/Divider
					
					Loop, %Divider%
					{
						Xpos += PerdestXIn3
						Ypos += PerdestYIn3
						SetWinDelay, 2
						WinMove, ahk_id %idtouch3%,, %Xpos%, %Ypos%
					}
					
					if(Wid != sizeXkeep3) || (Hid != sizeYkeep3)
					{
						PersizeX := (sizeXkeep3-Wid)/6
						PersizeY := (sizeYkeep3-Hid)/6
						Loop, 6
						{
							Wid += PersizeX
							Hid += PersizeY
							SetWinDelay, 2
							WinMove, ahk_id %idtouch3%,,,, %Wid%, %Hid%
						}
						
					}
					
					idtouch3 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch3INI
					if(!winrighttop)
						WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
					;Winset, Enable ,,ahk_id %idLButton%
					
				}
			}
		
			;044c122 else if the pointer selects minimize button, slide out to the old position.
			else if(XX<Xpos+Wid-82-dpiV*(19*(2-dpiV))&&XX>Xpos+Wid-112-dpiV*(24*(2-dpiV))&&YY>Ypos&&YY<Ypos+( 21+dpiV*(4*(2-dpiV)) ))
			{
				Winset, Disable ,,ahk_id %idtouch3%
				
				CheckLessRight := Abs(posXkeep3-Xpos)+Abs(posYkeep3-Ypos)
				if(CheckLessRight<10)
				{
					destXIn3 := Xpos - 60
					destYIn3 := Ypos - 18
				}
				else
				{
					destXIn3 := posXkeep3
					destYIn3 := posYkeep3
				}
					
				Divider := Sqrt(Sqrt(((destXIn3-Xpos)**2)+((destYIn3-Ypos)**2)))//2.2	
				PerdestXIn3 := (destXIn3-Xpos)/Divider
				PerdestYIn3 := (destYIn3-Ypos)/Divider
				
				Loop, %Divider%
				{
					Xpos += PerdestXIn3
					Ypos += PerdestYIn3
					SetWinDelay, 2
					WinMove, ahk_id %idtouch3%,, %Xpos%, %Ypos%    ;,, %Hid%
				}
				
				if(Wid != sizeXkeep3) || (Hid != sizeYkeep3)
				{
					PersizeX := (sizeXkeep3-Wid)/6
					PersizeY := (sizeYkeep3-Hid)/6
					Loop, 6
					{
						Wid += PersizeX
						Hid += PersizeY
						SetWinDelay, 2
						WinMove, ahk_id %idtouch3%,,,, %Wid%, %Hid%
					}
					
				}
				
				Winset, Enable ,,ahk_id %idtouch3%
				idtouch3 = 0x00000
				IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch3INI
				if(!winrighttop)
					WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
				
			}
		
		}	  ;else if InStr(idtouch3, idLButton)
		
		
		;044c14 else if the pointer select the idtouch5
		else if (idtouch5 == idLButton) 
		{
			if(ErrorKeepL==2)||(ErrorKeepL==1 && controlL == "ReBarWindow321")
			{   ;If it is that window, Slide window to posXkeep5 and posYkeep5
				KeyWait, LButton, T0.5
				WinGetPos, XposAft, YposAft, , , ahk_id %idLButton% 

				if(Xpos==XposAft&&Ypos==YposAft)
				{
						;Move win out
						
					CheckLessUp := Abs(posXkeep5-Xpos)+Abs(posYkeep5-Ypos)
					if(CheckLessUp<10)
					{
						destXIn5 := Xpos
						destYIn5 := Ypos + 60
					}
					else
					{
						destXIn5 := posXkeep5
						destYIn5 := posYkeep5
					}
						
					Divider := Sqrt(Sqrt(((destXIn5-Xpos)**2)+((destYIn5-Ypos)**2)))//2.2	
					PerdestXIn5 := (destXIn5-Xpos)/Divider
					PerdestYIn5 := (destYIn5-Ypos)/Divider
					
					Loop, %Divider%
					{
						Xpos += PerdestXIn5
						Ypos += PerdestYIn5
						SetWinDelay, 2
						WinMove, ahk_id %idtouch5%,, %Xpos%, %Ypos%    ;,, %Hid%
					}
					
					if(Wid != sizeXkeep5) || (Hid != sizeYkeep5)
					{
						PersizeX := (sizeXkeep5-Wid)/6
						PersizeY := (sizeYkeep5-Hid)/6
						Loop, 6
						{
							Wid += PersizeX
							Hid += PersizeY
							SetWinDelay, 2
							WinMove, ahk_id %idtouch5%,,,, %Wid%, %Hid%
						}
						
					}
					
					idtouch5 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch5INI
					wSlideFromTop := 0
					if(!winuptop)
						WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
				}
			}
		
			else if(XX<Xpos+Wid-82-dpiV*(19*(2-dpiV))&&XX>Xpos+Wid-112-dpiV*(24*(2-dpiV))&&YY>Ypos&&YY<Ypos+( 21+dpiV*(4*(2-dpiV)) ))
			{
				Winset, Disable ,,ahk_id %idtouch5%
				
				
				CheckLessUp := Abs(posXkeep5-Xpos)+Abs(posYkeep5-Ypos)
				if(CheckLessUp<10)
				{
					destXIn5 := Xpos
					destYIn5 := Ypos + 60
				}
				else
				{
					destXIn5 := posXkeep5
					destYIn5 := posYkeep5
				}
					
				Divider := Sqrt(Sqrt(((destXIn5-Xpos)**2)+((destYIn5-Ypos)**2)))//2.2	
				PerdestXIn5 := (destXIn5-Xpos)/Divider
				PerdestYIn5 := (destYIn5-Ypos)/Divider
				
				Loop, %Divider%
				{
					Xpos += PerdestXIn5
					Ypos += PerdestYIn5
					SetWinDelay, 2
					WinMove, ahk_id %idtouch5%,, %Xpos%, %Ypos%    ;,, %Hid%
				}
				
				if(Wid != sizeXkeep5) || (Hid != sizeYkeep5)
				{
					PersizeX := (sizeXkeep5-Wid)/6
					PersizeY := (sizeYkeep5-Hid)/6
					Loop, 6
					{
						Wid += PersizeX
						Hid += PersizeY
						SetWinDelay, 2
						WinMove, ahk_id %idtouch5%,,,, %Wid%, %Hid%
					}
					
				}
				
				Winset, Enable ,,ahk_id %idtouch5%
				idtouch5 = 0x00000
				IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch5INI
				wSlideFromTop := 0
				if(!winuptop)
					WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
							
			}

		}	  ;else if InStr(idtouch5, idLButton)
			
			
		;044c15 else if the pointer select the idtouch6
		else if (idtouch6 == idLButton) 
		{
			if(ErrorKeepL==2)||(ErrorKeepL==1 && controlL == "ReBarWindow321")
			{ ;If it is that window, Slide window to posXkeep6 and posYkeep6
				KeyWait, LButton, T0.5
				;MouseGetPos, X77, Y77
				WinGetPos, XposAft, YposAft, , , ahk_id %idLButton% 

				if(Xpos==XposAft&&Ypos==YposAft)
				{
						;Move win out
					CheckLessUp := Abs(posXkeep6-Xpos)+Abs(posYkeep6-Ypos)
					if(CheckLessUp<10)
					{
						destXIn6 := Xpos
						destYIn6 := Ypos - 60
					}
					else
					{
						destXIn6 := posXkeep6
						destYIn6 := posYkeep6
					}
						
					Divider := Sqrt(Sqrt(((destXIn6-Xpos)**2)+((destYIn6-Ypos)**2)))//2.2	
					PerdestXIn6 := (destXIn6-Xpos)/Divider
					PerdestYIn6 := (destYIn6-Ypos)/Divider
					
					Loop, %Divider%
					{
						Xpos += PerdestXIn6
						Ypos += PerdestYIn6
						SetWinDelay, 2
						WinMove, ahk_id %idtouch6%,, %Xpos%, %Ypos%
					}
					
					if(Wid != sizeXkeep6) || (Hid != sizeYkeep6)
						{
							PersizeX := (sizeXkeep6-Wid)/6
							PersizeY := (sizeYkeep6-Hid)/6
							Loop, 6
							{
								Wid += PersizeX
								Hid += PersizeY
								SetWinDelay, 2
								WinMove, ahk_id %idtouch6%,,,, %Wid%, %Hid%
							}
							
						}
					
					idtouch6 = 0x00000
					IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch6INI
					if(!winundertop)
						WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
					;Winset, Enable ,,ahk_id %idLButton%
					
				}
			}
		
			else if(XX<Xpos+Wid-82-dpiV*(19*(2-dpiV))&&XX>Xpos+Wid-112-dpiV*(24*(2-dpiV))&&YY>Ypos&&YY<Ypos+( 21+dpiV*(4*(2-dpiV)) ))
			{
				Winset, Disable ,,ahk_id %idtouch6%
				
				CheckLessUp := Abs(posXkeep6-Xpos)+Abs(posYkeep6-Ypos)
				if(CheckLessUp<10)
				{
					destXIn6 := Xpos
					destYIn6 := Ypos - 60
				}
				else
				{
					destXIn6 := posXkeep6
					destYIn6 := posYkeep6
				}
					
				Divider := Sqrt(Sqrt(((destXIn6-Xpos)**2)+((destYIn6-Ypos)**2)))//2.2	
				PerdestXIn6 := (destXIn6-Xpos)/Divider
				PerdestYIn6 := (destYIn6-Ypos)/Divider
				
				Loop, %Divider%
				{
					Xpos += PerdestXIn6
					Ypos += PerdestYIn6
					SetWinDelay, 2
					WinMove, ahk_id %idtouch6%,, %Xpos%, %Ypos%
				}
				
				if(Wid != sizeXkeep6) || (Hid != sizeYkeep6)
				{
					PersizeX := (sizeXkeep6-Wid)/6
					PersizeY := (sizeYkeep6-Hid)/6
					Loop, 6
					{
						Wid += PersizeX
						Hid += PersizeY
						SetWinDelay, 2
						WinMove, ahk_id %idtouch6%,,,, %Wid%, %Hid%
					}
				}
				
				Winset, Enable ,,ahk_id %idtouch6%
				idtouch6 = 0x00000
				IniWrite, 0x00000, %A_AppData%\Preme for Windows\premedata.ini, Operation, idtouch6INI
				if(!winundertop)
					WinSet, AlwaysOnTop, Off, ahk_id %idLButton%
				
			}
		
		}	  ;else if InStr(idtouch6, idLButton)
		
		;044c155 else if the pointer selects min-maximize or close button.
		else if(XX>Xpos+Wid+leftmin-1 && YY<Ypos+underminmaxcloseMain && StyleL & 0xF0000 == 983040)
		{
			if(winver == 2)	;Windows 10
			{
				underminmaxclose := Ypos+underminmaxcloseMain-(1*MaxOrNot)
			}
			else	;Windows 7,8
			{
				underminmaxclose := Ypos+underminmaxcloseMain+(7*MaxOrNot)
			}
			;Msgbox, %weasy% X %XX% X %leftmin% X %leftmax% Y %YY% X %Ypos% X %underminmaxclose%
				
			;044c1552 else if the pointer selects maximize button.
			if(wposwin && XX>Xpos+Wid+leftmax-1 && XX<Xpos+Wid+leftclose && YY>Ypos && YY<underminmaxclose)
			{
				TC := A_TickCount
				Loop, {
					MouseGetPos, XXMaxi, YYMaxi
					LDown:=GetKeyState("LButton","P")
					;044c1611 if the pointer is not on the maximize button or the left button is not pushed, break.    dpi
					if(!LDown || A_TickCount-TC > 1000)
						break
					;else if pointer is far away from old pos for 30 pixels.
					;else if(XX>Xpos+Wid-55-dpiV*(13*(2-dpiV)) || XX<Xpos+Wid-83-dpiV*(19*(2-dpiV)) || YY<Ypos || YY>Ypos+20+dpiV*(5*(2-dpiV)))  ;dpi
					else if(Sqrt((XXMaxi-XX)**2+(YYMaxi-YY)**2) > 20)
					{
						Click up

						;1topleft, 2topright, 3bottomleft, 4bottomright, 5left, 6right, 7top, 8bottom
						;find the angle of the pointer moving.
						if(ATan(abs((YYMaxi-YY)/(XXMaxi-XX))) > 1.16 || XXMaxi-XX == 0)		;1.16 radian is 66.5 degree. (66.5=45+45/2)
						{
							if(YYMaxi-YY < 0)
								PositionWindow(7)	;top
							else
								PositionWindow(8)	;bottom
						}
						else if(ATan(abs((YYMaxi-YY)/(XXMaxi-XX))) < 0.393)		;0.393 radian is 22.5 degree. (22.5=45/2)
						{
							if(XXMaxi-XX > 0)
								PositionWindow(6)	;right
							else
								PositionWindow(5)	;left
						}
						else if(XXMaxi-XX > 0)
						{
							if(YYMaxi-YY < 0)
								PositionWindow(2)	;topright
							else
								PositionWindow(4)	;bottomright
						}
						else
						{
							if(YYMaxi-YY < 0)
								PositionWindow(1)	;topleft
							else
								PositionWindow(3)	;bottomleft
						}
						
						break
					}
					sleep, 100	;Do not delete
				}
				;Loop
			}

			;044c16 else if the pointer selects minimize button.	
			;weasy is enable. coordinate is it's in minimize button area. StyleL is there is minimize button.   ;dpi 82-101   112-136
			else if(weasy0 && XX>Xpos+Wid+leftmin-1 && XX<Xpos+Wid+leftmax && YY>Ypos && YY<underminmaxclose)
			{
				TC := A_TickCount
				;044c161 Loop
				if (!MaxOrNot)
				Loop, {
					MouseGetPos, XXMini, YYMini
					LDown:=GetKeyState("LButton","P")
					;044c1611 if the pointer is not on the minimize button or the left button is not pushed, break.    dpi
					if(!LDown || A_TickCount-TC > 1000)
						break
					;else if pointer is far away from old pos for 20 pixels.
					else if(Sqrt((XXMini-XX)**2+(YYMini-YY)**2) > 20)
					{

						;find the angle of the pointer moving.
						;if the angle is more than 45 degree,
						if(ATan(abs((YYMini-YY)/(XXMini-XX))) > 0.785 || XXMini-XX == 0)	;0.785 radian is 45 degree.
						{
							SysGet, MonitorCount, MonitorCount
							if(YYMini-YY < 0)
							{
								if(bitTbLo<>1 || MonitorCount > 1)
									Gosub TouchSlideWinTop
								else
									bounceGoAndBack(30, "up")
							}
							else if(bitTbLo<>3 || MonitorCount > 1)
								Gosub TouchSlideWinBottom
							else
								bounceGoAndBack(30, "down")
						}
						else
						{
							SysGet, MonitorCount, MonitorCount
							if(XXMini-XX > 0)
							{
								if(bitTbLo<>2 || MonitorCount > 1)
									Gosub TouchSlideWinRight
								else
									bounceGoAndBack(30, "right")
							}
							else if(bitTbLo<>0 || MonitorCount > 1)
								Gosub TouchSlideWinLeft
							else
								bounceGoAndBack(30, "left")
						}
						break	;Do not delete
					}
					sleep, 100	;Do not delete
				}  ;Loop
			
			}  ;END of else if the pointer selects minimize button.
		}	;END of 044c155 else if the pointer selects min-maximize or close button.
			
		
		;044c17 {Start Always on top}
		else if(XX<Xpos+Wid+leftmin && (Wid>215+dpiV*(35*(2-dpiV))) && (ExStyleL & 0x100)&&!(ExStyleL & 0x80))
		{
			; 20-25
			;a&(b| (c&(d|e|f)) |(g&h&i) | (j&k&(l|m|n|o|p)))
			;a=whlc b=ErrorIS2 c=YY>20 d=Err8 e=Err9 f=Err20 g=y<34 h=y>20 i=Cabinet j=YY<30 k=XX<111 l=Opus   dpi
			if(whlc&&(ErrorKeepL==2 || (ErrorKeepL==1 && controlL == "ReBarWindow321") || (YY<Ypos+30+dpiV*(8*(2-dpiV))&&XX<Xpos+Wid+leftmin&&((class == "OpusApp")||(class == "PPTFrameClass")||(class == "XLMAIN")||(class == "rctrl_renwnd32")||(class == "Framework::CFrame")||(class == "VISIOA"))) ))
			{	;(YY<Ypos+30||(class == "IEFrame")||(class == "CabinetWClass"))
				TC := A_TickCount
				
				;calculate delay if it is remoted or it's not Aero
				hr := DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", isEnabledVar)
				if (hr == 0 && isEnabledVar) 
				{
					minDelay = 600
					maxDelay = 900
				} 
				else 
				{
					minDelay = 1200
					maxDelay = 1500
				}
				Loop, {
					MouseGetPos, XXAl, YYAl
					WinGetPos, XposAfter, YposAfter, , , ahk_id %idLButton% 
					LDown:=GetKeyState("LButton","P")
					if(Xpos!=XposAfter || Ypos!=YposAfter || !LDown || XXAl-XX>6 || YYAl-YY >6)   
						break
					else if(A_TickCount-TC > minDelay && A_TickCount-TC < MaxDelay)
					{
						if(blacklistvar1!=2||(class == blacklistcls11)||(class == blacklistcls12)||(class == blacklistcls13)||(class == blacklistcls14)||(class == blacklistcls15))
						if !(blacklistvar1==1 && ((class == blacklistcls11)||(class == blacklistcls12)||(class == blacklistcls13)||(class == blacklistcls14)||(class == blacklistcls15)))
						{
							
							WinGet, ExStyle, ExStyle, ahk_id %idLButton%
							if (ExStyle & 0x8)
							{
								Winset, Enable ,, ahk_id %idLButton%
								if(winver == 0 && dpiV == 1)    ;125% screen win7
								{
									SplashTextOn,,,`r          Not always on top.
									WinMove,`r          Not always on top., , XX-98, YY+24    ;dpi
								}
								else if(winver == 0 && dpiV == 0)    ;100% screen win7
								{
									SplashTextOn,,,`r                 Not always on top.
									WinMove,`r                 Not always on top., , XX-98, YY+24    ;dpi
								}
								else
								{
									SplashTextOn,,, Not always on top.   ;dpi									
									WinMove, Not always on top., , XX-98, YY+24   ;dpi
								}
								tran := 255
								Loop, 30
								{
									tran -= 7
									sleep, 10
									WinSet, Transparent, %tran%, ahk_id %idLButton% 
								}
								
								WinGetPos, XposAfter0, YposAfter0, , , ahk_id %idLButton% 
								;LDown:=GetKeyState("LButton","P")
								if(Abs(XposAfter0-XposAfter)+Abs(YposAfter0-YposAfter)>12)
								{
									WinSet, Transparent, 255, ahk_id %idLButton% 
									if(winver == 0 && dpiV == 1)    ;125% screen win7
									{
										SplashTextOn,,,`r                    Abort         ;dpi
										WinMove,`r                    Abort, , XX-98, YY+24     ;dpi
									}
									else if(winver == 0 && dpiV == 0)    ;100% screen win7
									{
										SplashTextOn,,,`r                           Abort         ;dpi
										WinMove,`r                           Abort, , XX-98, YY+24     ;dpi
									}
									else
									{
										SplashTextOn,,, Abort         ;dpi
										WinMove, Abort, , XX-98, YY+24     ;dpi
									}
									sleep, 1000
									SplashTextOff
									break
								}
								
								WinSet AlwaysOnTop, Off, ahk_id %idLButton% 
								
								Loop, 30
								{
									tran += 7
									sleep, 10
									WinSet, Transparent, %tran%, ahk_id %idLButton% 
								}
								sleep, 200
								SplashTextOff
							}
							else
							{
								Winset, Enable ,, ahk_id %idLButton%
								if(winver == 0 && dpiV == 1)    ;125% screen win7
								{
									SplashTextOn,,,`r              Always on top.   ;dpi
									WinMove,`r              Always on top., , XX-98, YY+24     ;dpi
								}
								else if(winver == 0 && dpiV == 0)    ;100% screen win7
								{
									SplashTextOn,,,`r                    Always on top.   ;dpi									
									WinMove,`r                    Always on top., , XX-98, YY+24     ;dpi
								}
								else
								{
									SplashTextOn,,, Always on top.   ;dpi									
									WinMove, Always on top., , XX-98, YY+24     ;dpi
								}
								tran := 255
								Loop, 10
								{
									tran -= 20
									sleep, 20
									WinSet, Transparent, %tran%, ahk_id %idLButton% 
								}
								
								WinGetPos, XposAfter0, YposAfter0, , , ahk_id %idLButton% 
								;LDown:=GetKeyState("LButton","P")
								if(Abs(XposAfter0-XposAfter)+Abs(YposAfter0-YposAfter)>12)
								{
									WinSet, Transparent, 255, ahk_id %idLButton% 
									if(winver == 0 && dpiV == 1)    ;125% screen win7
									{
										SplashTextOn,,,`r                    Abort   ;dpi
										WinMove,`r                    Abort, , XX-98, YY+24    ;dpi
									}
									else if(winver == 0 && dpiV == 0)    ;100% screen win7
									{
										SplashTextOn,,,`r                           Abort         ;dpi
										WinMove,`r                           Abort, , XX-98, YY+24     ;dpi
									}
									else
									{
										SplashTextOn,,, Abort         ;dpi
										WinMove, Abort, , XX-98, YY+24     ;dpi
									}
									sleep, 1000
									SplashTextOff
									break
								}
								
								WinSet AlwaysOnTop, On, ahk_id %idLButton% 		
								if(winver == 0 && dpiV == 1)    ;125% screen win7
									WinSet AlwaysOnTop, On,`r              Always on top.	   ;dpi `t
								else if(winver == 0 && dpiV == 0)    ;100% screen win7
									WinSet AlwaysOnTop, On,`r                    Always on top.	   ;dpi `t
								else
									WinSet AlwaysOnTop, On, Always on top.	   ;dpi `t
								Loop, 10
								{
									tran += 20
									sleep, 10
									WinSet, Transparent, %tran%, ahk_id %idLButton% 
								}
								sleep, 600
								SplashTextOff
								
							}
						}
					}
					if(A_TickCount-TC > maxDelay)
						break
					sleep, 100
				}
			}

		}	; end of ;044c17 else if {Start Always on top}

	} ; end of 044c1 If the pointer is near the top of window and alwaysontop or TouchSliWin is enable.
;}
return  ;end of leftButton


mButton:         ;MButton::
	CoordMode, Mouse, Screen
	MouseGetPos, XX, YY, idMButton, conM
	WinGetPos, Xpos, Ypos, Wid,, ahk_id %idMButton%
	if (YY<Ypos+58+dpiV*(3*(2-dpiV)))
	{
		SendMessage, 0x84,, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %idMButton%
		ErKeM := ErrorLevel
		;SendMessage, 0x84 produces ErrorLevel as follow.

		TC := A_TickCount 

		WinGetClass, class, ahk_id %idMButton%
		WinGet, ExStyleMBu, ExStyle, ahk_id %idMButton% 
		
		Loop, {
			MDown:=GetKeyState("MButton","P") 
			If (!MDown) 
			{
				MouseGetPos, XX1, YY1, idMButtonPos     ;dpi
				if(idMButton != idMButtonPos) || (YY1>Ypos+58+dpiV*(3*(2-dpiV)))
					break
				else If ((class == "IEFrame")||(class == "CabinetWClass"))
				{
					;if(XX1<Xpos+Wid && XX1>Xpos && YY1>Ypos-1 && YY1<Ypos+34+dpiV*(7*(2-dpiV)) && (blacklistvar2!=2||(class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)) )
					if((ErKeM==2 || ErKeM==12 || ErKeM==8 || ErKeM==9 || ErKeM==20 ||(ErKeM==1 && conM == "ReBarWindow321")) && (blacklistvar2!=2||(class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)))
					{

						if !(blacklistvar2==1 && ((class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)))
						{
							Send !{F4}
							sleep, 100
							send {Alt Up}
							sleep, 100
							break
						}
					}
				}
				else if InStr(class, "Chrome_")
				{
					if ErKeM in 2,3,8,9,12,20
					if (blacklistvar2!=2||(class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25))
					{
						XXleft := XX - 13
						XXright := XX + 13
						SendMessage, 0x84,, (XXleft & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %idMButton%
						Errleft := ErrorLevel
						SendMessage, 0x84,, (XXright & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %idMButton%
						Errright := ErrorLevel
						if(Errleft != 1 || Errright != 1) && !(blacklistvar2==1 && ((class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)))
						{
							Send !{F4}
							sleep, 100
							send {Alt Up}
							break
						}
					}

				}
				else if (class == "OpusApp")||(class == "PPTFrameClass")||(class == "XLMAIN")||(class == "rctrl_renwnd32")||(class == "Framework::CFrame")||(class == "VISIOA")
				{
					;if(YY>Ypos-1&&YY<Ypos+34)  ;dpi YY<Ypos+30+dpiV*(8*(2-dpiV)) 
					if(YY>Ypos-1&&YY<Ypos+30+dpiV*(8*(2-dpiV)) && (blacklistvar2!=2||(class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)))
					{
						if !(blacklistvar2==1 && ((class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)))
						{
							;Send !{F4}
							WinClose, ahk_id %idMButton% 
							sleep, 100
							break
						}
					}
				}

				else if (ExStyleMBu & 0x100) && !(ExStyleMBu & 0x80)
				{
					if ErKeM in 2,3,8,9,12,20
					if (blacklistvar2!=2||(class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25))
					{
						if !(blacklistvar2==1 && ((class == blacklistcls21)||(class == blacklistcls22)||(class == blacklistcls23)||(class == blacklistcls24)||(class == blacklistcls25)))
						{
							Send !{F4}
							sleep, 100
							send {Alt Up}
							break
						}
					}
						
				}               
			} ;if !MDown
			 If (A_TickCount-TC) > 300 
				  Break 
				  sleep, 50
		} ;Loop

	} ;YY<Ypos+53

return		;end of mButton







wheelDownButton:     ;WheelDown::
	CoordMode, Mouse
	MouseGetPos, XX, YY, idWD, conWD
	WinGetPos, Xpos, Ypos, Wid,, ahk_id %idWD%
	WinGet, ExStyleMin, ExStyle, ahk_id %idWD%
	
	if((conWD == "MSTaskListWClass1" || (conWD=="ToolbarWindow321"||conWD=="TrayClockWClass1"||conWD=="TrayShowDesktopWClass1"||conWD=="Button1"||conWD=="Button2"||conWD=="Button3"||conWD=="Button4"||conWD=="ToolbarWindow322")||conWD=="TrayButton2") && wvolum)
	{
		if(conWD == "MSTaskListWClass1")
			sendInput, {Volume_Down 3}
		else
			sendInput, {Volume_Down}
		sleep, 100
		master_volume := VA_GetMasterVolume()
		if(winver == 1)	;for Windows 8
		{
			IfWinNotExist,`rVolume Down (%master_volume%`%)
				SplashTextOn,,,`rVolume Down (%master_volume%`%)
		}
		else if(dpiV == 1)    ;120dpi
		{
			IfWinNotExist,`r         Volume Down (%master_volume%`%)
				SplashTextOn,,,`r         Volume Down (%master_volume%`%)
		}
		else if(dpiV == 0)    ;96dpi
		{
			IfWinNotExist,`r              Volume Down (%master_volume%`%)
				SplashTextOn,,,`r              Volume Down (%master_volume%`%)
		}
		else
		{
			IfWinNotExist,`rVolume Down (%master_volume%`%)
				SplashTextOn,,,`rVolume Down (%master_volume%`%)
		}
		SetTimer, splashTextOffMethod, 500	
	}

	else if (YY<Ypos+58+dpiV*(3*(2-dpiV)) && wmin)
	{
		WinGet, StyleDown, Style, ahk_id %idWD%	
		WinGetClass, class, ahk_id %idWD%
		SendMessage, 0x84,, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %idWD%
		ErKeD := ErrorLevel
		
		if (class == "IEFrame")||(class == "CabinetWClass")
		{
			if((ErKeD==2 || ErKeD==12 || ErKeD==8 || ErKeD==9 || ErKeD==20 ||(ErKeD==1 && conWD == "ReBarWindow321")) && (blacklistvar3!=2||(class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
			{
				if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
				{
					if wscrollAW
						Sendinput {vk9e}
				}
				else
				{
					WinMinimize, ahk_id %idWD%
					Sleep, 100    ;sleep for protecting minimize many windows in short time.
				}
			}
			else if !WinActive("ahk_id" . idWD) && wscrollAW
			{
				hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
				SendMessage, 0x20A, -120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
			}
			else if wscrollAW
			{
				Sendinput {vk9e}
			}
			
		}
		
		;else if (Wid<215)||!(ExStyleMin & 0x100)||(ExStyleMin & 0x80) 
		else if(InStr(class, "Chrome_") && (blacklistvar3!=2||(class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)) )
		{
			WinGet, MaxOrNot, MinMax, ahk_id %idWD%
			;ToolTip, MouseClick
			if(MaxOrNot==1&&YY>Ypos-1&&YY<Ypos+33)      ;96,120dpi are 32pixel     dpi
			{
				sleep, 50
				MouseGetPos, XXXX, YYYY
				if(XX=XXXX&&YY=YYYY)
				{   ;Wheel down is too sensitive for Chrome
					if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
					{	
						if wscrollAW
							Sendinput {vk9e}
					}
					else
					{
						WinMinimize, ahk_id %idWD%
						sleep, 100
					}
				}
			}
			else if(MaxOrNot==0&&YY>Ypos-1)
			{
				if ErKeD in 2,3,8,9,12,20
				{
					if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
					{
						if wscrollAW
							Sendinput {vk9e}
					}
					else
					{
						WinMinimize, ahk_id %idWD%
						Sleep, 100
					}
				}	
			}
			
		}
		else if (class == "MozillaWindowClass") && (blacklistvar3!=2||(class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)) 
		{
			WinGet, MaxOrNot, MinMax, ahk_id %idWD%
			if(MaxOrNot==1&&YY>Ypos-1&&YY<Ypos+34+dpiV*(4*(2-dpiV)))      ;120dpi 38pixel
			{
				if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
				{
					if wscrollAW
						Sendinput {vk9e}
				}
				else
				{
					WinMinimize, ahk_id %idWD%
					sleep, 100
				}
			}
			else if(MaxOrNot==0&&YY>Ypos-1)
			{
				if ErKeD in 2,3,8,9,12,20    ;ErrorLevel from SendMessage, 0x84
				{
					if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
					{
						if wscrollAW
							Sendinput {vk9e}
					}
					else
					{
						WinMinimize, ahk_id %idWD%
						Sleep, 100
					}
				}	
			}
			
		}
		
		else if (class == "OpusApp")||(class == "PPTFrameClass")||(class == "XLMAIN")||(class == "rctrl_renwnd32")||(class == "Framework::CFrame")||(class == "VISIOA")
		{
			if(YY>Ypos-1&&YY<Ypos+30+dpiV*(8*(2-dpiV)) && (blacklistvar3!=2||(class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)) )
			{
				if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
				{
					if wscrollAW
						Sendinput {vk9e}
				}
				else
				{
					WinMinimize, ahk_id %idWD%
					sleep, 100
				}
			}
			else if !WinActive("ahk_id" . idWD) && wscrollAW
			{
				hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
				SendMessage, 0x20A, -120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
			}
			else if wscrollAW
			{
				Sendinput {vk9e}				
			}
			
		}
		else if (ExStyleMin & 0x100) && !(ExStyleMin & 0x80) && (StyleDown & 0xF0000 == 983040) && (blacklistvar3!=2||(class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)) 
		{  ;else for any window
			if ErKeD in 2,3,8,9,12,20    ;ErrorLevel from SendMessage, 0x84
			{
				if(blacklistvar3==1 && ((class == blacklistcls31)||(class == blacklistcls32)||(class == blacklistcls33)||(class == blacklistcls34)||(class == blacklistcls35)))
				{
					if wscrollAW
						Sendinput {vk9e}
				}
				else
				{
					WinMinimize, ahk_id %idWD%
					Sleep, 100
				}
			}
			else if !WinActive("ahk_id" . idWD) && wscrollAW
			{
				hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
				SendMessage, 0x20A, -120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
				
			}
			else if wscrollAW
			{
				Sendinput {vk9e}	
			}
		} ; else for any window
		else if !WinActive("ahk_id" . idWD) && wscrollAW && (ExStyleMin & 0x100) && !(ExStyleMin & 0x80)
		{
			hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
			SendMessage, 0x20A, -120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
				
		}
		else if wscrollAW
		{
			Sendinput {vk9e}
		}
		
	} ;YY<Ypos+53

	else if !WinActive("ahk_id" . idWD) && wscrollAW && (ExStyleMin & 0x100) && !(ExStyleMin & 0x80)
	{
		hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
		SendMessage, 0x20A, -120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
	}
	else if wscrollAW
	{
		Sendinput {vk9e}
	}

return ;end of wheelDownButton



wheelUpButton:            ;WheelUp::
	
	CoordMode, Mouse
	MouseGetPos, XX, YY, idWUp, conWU
	WinGetPos, Xpos, Ypos, Wid,, ahk_id %idWUp%
	WinGet, ExStyleMax, ExStyle, ahk_id %idWUp%
	
		
	if((conWU == "MSTaskListWClass1" || (conWU=="ToolbarWindow321"||conWU=="TrayClockWClass1"||conWU=="TrayShowDesktopWClass1"||conWU=="Button1"||conWU=="Button2"||conWU=="Button3"||conWU=="Button4"||conWU=="ToolbarWindow322")||conWU=="TrayButton2") && wvolum)
	{
		if(conWU == "MSTaskListWClass1")
			sendInput, {Volume_Up 3}
		else
			sendInput, {Volume_Up}
		sleep, 100
		master_volume := VA_GetMasterVolume()
		if(winver == 1)	;for Windows 8
		{
			IfWinNotExist,`rVolume Up (%master_volume%`%)
				SplashTextOn,,,`rVolume Up (%master_volume%`%)
		}
		else if(dpiV == 1)    ;120dpi
		{
			IfWinNotExist,`r           Volume Up (%master_volume%`%)
				SplashTextOn,,,`r           Volume Up (%master_volume%`%)
		}
		else if(dpiV == 0)
		{
			IfWinNotExist,`r                Volume Up (%master_volume%`%)
				SplashTextOn,,,`r                Volume Up (%master_volume%`%)
		}
		else
		{
			IfWinNotExist,`rVolume Up (%master_volume%`%)
				SplashTextOn,,,`rVolume Up (%master_volume%`%)
		}
		SetTimer, splashTextOffMethod, 500	
	}
	
	;else if (YY<Ypos+53 && wmax)
	else if (YY<Ypos+58+dpiV*(3*(2-dpiV)) && wmax)    ;wmax is needed, can't be deleted.
	{
		WinGet, StyleUp, Style, ahk_id %idWUp%	
		WinGetClass, class, ahk_id %idWUp%
		SendMessage, 0x84,, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %idWUp%
		ErKeU := ErrorLevel
		
		if (class == "IEFrame")||(class == "CabinetWClass")
		{
			if(ErKeU==2 || ErKeU==12 || ErKeU==8 || ErKeU==9 || ErKeU==20 ||(ErKeU==1 && conWU == "ReBarWindow321")) && (blacklistvar6!=2||(class == blacklistcls61)||(class == blacklistcls62)||(class == blacklistcls63)||(class == blacklistcls64)||(class == blacklistcls65))
			{
				if(blacklistvar6==1 && ((class == blacklistcls61)||(class == blacklistcls62)||(class == blacklistcls63)||(class == blacklistcls64)||(class == blacklistcls65)))
				{
					if wscrollAW
						Sendinput {vk9f}
				}
				else
				{
					WinMaximize, ahk_id %idWUp%
					Sleep, 100
				}
			}
			else if !WinActive("ahk_id" . idWUp) && wscrollAW
			{
				hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
				SendMessage, 0x20A, 120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
				
			}
			else if wscrollAW
			{
				Sendinput {vk9f}
			}
		}
		;else if (Wid<215)||!(ExStyleMax & 0x100)||(ExStyleMax & 0x80) 	
		else if (class == "OpusApp")||(class == "PPTFrameClass")||(class == "XLMAIN")||(class == "rctrl_renwnd32")||(class == "Framework::CFrame")||(class == "VISIOA")
		{
			if(YY>Ypos-1&&YY<Ypos+30+dpiV*(8*(2-dpiV)) && (blacklistvar6!=2||(class == blacklistcls61)||(class == blacklistcls62)||(class == blacklistcls63)||(class == blacklistcls64)||(class == blacklistcls65)) )
			{
				if(blacklistvar6==1 && ((class == blacklistcls61)||(class == blacklistcls62)||(class == blacklistcls63)||(class == blacklistcls64)||(class == blacklistcls65)))
				{
					if wscrollAW
						Sendinput {vk9f}
				}
				else
				{
					WinMaximize, ahk_id %idWUp%
					sleep, 100
				}
			}
			else if !WinActive("ahk_id" . idWUp) && wscrollAW
			{
				hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
				SendMessage, 0x20A, 120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
			}
			else if wscrollAW
			{
				Sendinput {vk9f}
				
			}
		}
		else if (ExStyleMax & 0x100) && !(ExStyleMax & 0x80) && (StyleUp & 0xF0000 == 983040) && (blacklistvar6!=2||(class == blacklistcls61)||(class == blacklistcls62)||(class == blacklistcls63)||(class == blacklistcls64)||(class == blacklistcls65)) 
		{  ;else for any window
			if ErKeU in 2,3,8,9,12,20
			{
				if(blacklistvar6==1 && ((class == blacklistcls61)||(class == blacklistcls62)||(class == blacklistcls63)||(class == blacklistcls64)||(class == blacklistcls65)))
				{
					if wscrollAW
						Sendinput {vk9f}
				}
				else
				{
					WinMaximize, ahk_id %idWUp%
					Sleep, 100
				}
			}
			else if !WinActive("ahk_id" . idWUp) && wscrollAW
			{
				hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
				SendMessage, 0x20A, 120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
			}
			else if wscrollAW
			{
				Sendinput {vk9f}
			}
		

		} ; else for any decorated window
		else if !WinActive("ahk_id" . idWUp) && wscrollAW && (ExStyleMax & 0x100) && !(ExStyleMax & 0x80)
		{
			hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
			SendMessage, 0x20A, 120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
		}
		else if wscrollAW
		{
			Sendinput {vk9f}
		}
	} ;YY<Ypos+35
	else if !WinActive("ahk_id" . idWUp) && wscrollAW && (ExStyleMax & 0x100) && !(ExStyleMax & 0x80)
	{
		hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
		SendMessage, 0x20A, 120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
	}
	else if wscrollAW
	{
	
		Sendinput {vk9f}

		;if there is snipping tool, check id if it is the same id or not. If not, reload preme.
		Process, Exist, SnippingTool.exe
		if(ErrorLevel!=0)  ;if there is this process.
		{
			Process, Exist, %processidsnippingtool%
			if(ErrorLevel==0)  ;if there is no this process.
			{
				;Reload
				;Run, %A_AppData%\Preme for Windows\bin\premeeng.exe,, UseErrorLevel
				Gosub, runpremeengMethod
				Process, Exist, SnippingTool.exe
				processidsnippingtool := ErrorLevel
			}
		}	

	}

return ;end of wheelUpButton



wheelDownWithShift:
	CoordMode, Mouse
	MouseGetPos, XX, YY, idWD
	WinGet, ExStyleMin, ExStyle, ahk_id %idWD%
	if !WinActive("ahk_id" . idWD) && (ExStyleMin & 0x100) && !(ExStyleMin & 0x80)
	{
	hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
	SendMessage, 0x20E, 120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
	}
	else
		Sendinput +{vk9e}
return

wheelUpWithShift:
	CoordMode, Mouse
	MouseGetPos, XX, YY, idWUp
	WinGet, ExStyleMax, ExStyle, ahk_id %idWUp% 
	if !WinActive("ahk_id" . idWUp) && (ExStyleMax & 0x100) && !(ExStyleMax & 0x80)
	{
		hw_m_target := DllCall("WindowFromPoint", "Int64", (XX & 0xFFFFFFFF) | (YY & 0xFFFFFFFF) << 32)
		SendMessage, 0x20E, -120 << 16, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %hw_m_target%
	}
	else
		Sendinput +{vk9f}
return





rightButton:
	CoordMode, Mouse
	MouseGetPos, XX, YY, idRButton, conRCli
	WinGetPos, Xpos, Ypos, Wid, Hid, ahk_id %idRButton%
	WinGetClass, classRBu, ahk_id %idRButton%
	WinGet, StyleL, Style, ahk_id %idRButton%
	WinGet, MaxOrNot, MinMax, ahk_id %idRButton%
	
	;XX<Xpos+Wid-6 && XX>XPos+Wid-56+2*winver-dpiV*((13-1*winver)*(2-dpiV)) && YY>Ypos && YY<Ypos+21+1*winver+dpiV*((5-2*winver)*(2-dpiV))+(7*MaxOrNot)&&(StyleL & 0xF0000 == 983040))
	if(wvisiop && XX>Xpos+Wid+leftclose-1 && YY<Ypos+underminmaxcloseMain+7 && StyleL & 0xF0000 == 983040)
	{
		if(winver == 2 || YY<Ypos+underminmaxcloseMain+(7*MaxOrNot))
		{
			if(GetKeyState("Shift") && wdiseachwin)
			{
				Gosub, disableWinMethod
			}
			else if (idtouch1 <> idRButton && idtouch3 <> idRButton && idtouch5 <> idRButton && idtouch6 <> idRButton)
			{
				if(blacklistvar5!=2||(classRBu == blacklistcls51)||(classRBu == blacklistcls52)||(classRBu == blacklistcls53)||(classRBu == blacklistcls54)||(classRBu == blacklistcls55))
				if !(blacklistvar5==1 && ((classRBu == blacklistcls51)||(classRBu == blacklistcls52)||(classRBu == blacklistcls53)||(classRBu == blacklistcls54)||(classRBu == blacklistcls55)))			
					Gosub, buildVisOptsGUI
			}
		}
	}
	
	else if(conRCli == "MSTaskListWClass1" && wsmartmove && !GetKeyState("Shift"))
	{

			
		TC := A_TickCount 
		Loop, {
			sleep, 40
			RDown:=GetKeyState("vk02","P")
			
			if((A_TickCount-TC > 700 && RDown && wdonhold) || (!RDown && !wdonhold))
				break
			else IfWinExist, ahk_class #32768
				break
			else if(A_TickCount-TC > 900)
				break

			if ((!RDown && wdonhold) || (A_TickCount-TC > 200 && RDown && !wdonhold))
			{
				if(!wdonhold)
				IfWinNotActive, ahk_class DV2ControlHost
				IfWinNotActive, ahk_class Windows.UI.Core.CoreWindow
				{
					;Send, {vk02 Down} 
					Send, {vk02 UP} 
				}
				;Tooltip, yes2
				if(winver == 2)	;Windows 10
				{
					TC := A_TickCount 
					Loop, {
						sleep, 100
						IfWinActive, ahk_class Windows.UI.Core.CoreWindow
							break
						if(A_TickCount-TC > 800)
							break
					}
					
					MouseGetPos, XX12, YY12
					if(abs(XX12-XX)<8 && abs(YY12-YY)<8)
					{
						WinGetPos, Xj, Yj, XXjj, YYjj, A	;ahk_class Windows.UI.Core.CoreWindow
						;Tooltip, %Xj% %Yj% %XXjj% %YYjj% non
						if(XX<Xj+15)
							XX := Xj + 33
						else if(XX>Xj+XXjj-15)
							XX := Xj + XXjj - 30
							
						Yjj := Yj + YYjj + pointup
						MouseMove, %XX%, %Yjj%, 4
					}
					break
				}
				else
				{
					TC := A_TickCount 
					Loop, {
						sleep, 100
						IfWinActive, ahk_class DV2ControlHost	;Windows 7&8
							break
						if(A_TickCount-TC > 800)
							break
					}
					
					MouseGetPos, XX12, YY12
					if(abs(XX12-XX)<8 && abs(YY12-YY)<8)
					{
						WinGetPos, Xj, Yj, XXjj, YYjj, A	;ahk_class DV2ControlHost can't be used.
						if(XX<Xj+15)
							XX := Xj + 33
						else if(XX>Xj+XXjj-15)
							XX := Xj + XXjj - 30
							
						Yjj := Yj + YYjj - 28 - dpiV*(5*(2-dpiV))
						MouseMove, %XX%, %Yjj%, 3
					}
				}
				break
			}

		}	;loop

	} ;Shell_TrayWnd
return		;end of rightButton

;if no these 2 lines, you will can't use Alt+down 2 times without releasing Alt.
~#!^+F2::
return


	
/*		;edit here
	; This is the testing area.
	
	; I don't detect taskbar position by register because it updates slowly. So I use the direct position instead. Saving it to ini and let WPF read it.
	; RegRead, OutputVar, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2, Settings
	; tbPos := SubStr(OutputVar, 26, 1) 
	; MsgBox, %tbPos% and	%OutputVar%
  
	; if(A_ScriptName != "premeeng.exe")
	; Gosub, smallUpdateWin
	
	^1::
	; DetectHiddenWindows, On
	; WinSet, Transparent, 255, AHK_class NotifyIconOverflowWindow
	; ControlGetPos,,,w,h, ToolbarWindow321, AHK_class NotifyIconOverflowWindow
	; width:=w
	; hight:=h
	; Tooltip, %w% %h%
	; While % ((h:=h-5)>0 and w:=width){
		; While % ((w:=w-5)>0){
			; PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
			
		; }
	; }
	; WinSet, Transparent, 255, AHK_class NotifyIconOverflowWindow
	; DetectHiddenWindows, Off
	Msgbox, ctrl 1
	return
	
	~^2::
	;WinShow, Preme for Windows
	MsgBox, winver= %winver%
	return
	
	~^3::
		IfWinExist, PremeSmall ahk_class PremeforWin
			Tooltip, found %A_ScriptName% detect %A_DetectHiddenWindows% 
		else
			Tooltip, not found %A_ScriptName% detect %A_DetectHiddenWindows% 
		
	return
	
	^4::
	;SysGet, capheight, 4	;Height of a caption area, in pixels.
	CoordMode, Mouse
	MouseGetPos, XX, YY, id, controlN
	WinGetTitle, title, A
	WinGetClass, class, A
	WinGetTitle, titleM, ahk_id %id%
	WinGetClass, classM, ahk_id %id%
	ControlGetFocus, confocus, ahk_id %id%
	ControlGetPos, XXX, YYY, WWW, HHH, %controlN%, ahk_id %id%
	WinGet, Styleye, Style, ahk_id %id%
	WinGet, pidShow, PID, A

	WinGetPos, Xpos, Ypos, Width, Height, ahk_id %id% ;DV2ControlHost
	WinGet, ExStyle, ExStyle, ahk_id %id% 
	PixelGetColor, color0, XX, YY
	SendMessage, 0x84,, (XX & 0xFFFF) | (YY & 0xFFFF) << 16,, ahk_id %id%
	ErrorKeepL := ErrorLevel
	XXcloseTR := Xpos+Width-20
	YYcloseTR := Ypos+9
	SendMessage, 0x84,, (XXcloseTR & 0xFFFF) | (YYcloseTR & 0xFFFF) << 16,, ahk_id %id%
	ErrorKeepL5 := ErrorLevel
	fromRight := Width - XX
	;fromTop := 
	;MsgBox, yes %class%
	Tooltip, %pidShow% %XX% %YY% %fromRight%xR 0x84=%ErrorKeepL% closebut=%ErrorKeepL5% %YY85% ConFo=%confocus% conN=%controlN%`nClassFromA=%class% claMo=%classM%`ntitleFromA=%title% titleMo=%titleM% `nid=%id% %Xpos%x %Ypos%y size %Width% %Height% sty = %Styleye% ExS = %ExStyle% %XXX% %YYY% %WWW% %HHH% dpi=%dpiV%
	;Windows 10 Jump list class, "Windows.UI.Core.CoreWindow"
	;Windows 10 Jump list title, "Jump List for File Explorer"
	;Windows 10 taskbar class,  Shell_TrayWnd
	;Windows 10 taskbar control, Start1, TrayButton1, MSTaskListWClass1(buttons), Button4(up arrow), ToolbarWindow322, 
								;TrayButton2(noti button), Button2(lang), TrayClockWClass1, TrayShowDesktopWClass1
	; IfWinActive, ahk_class Windows.UI.Core.CoreWindow
		; Msgbox, yes ac
	return

	^5::
	bool01 := 0
	bool02 := 0
	bool03 := bool01 || bool02
	Tooltip, %bool01% %bool02% %bool03% 
		
	
	return


	^6::
		; Gui, Destroy
		; Gosub InstallationType
		
		;FileGetTime, TodayTime3, C:\Windows\bootstat.dat, M
		TodayTime3 := 20130510171127
		temp001 := mod(Floor(TodayTime3/1000000),5)
		Msgbox, %TodayTime3% and %temp001%
		IniRead, UpdateSilentlyR, %A_AppData%\Preme for Windows\premedata.ini, section1, UpdateSilentlyINI, 1
		if( (TodayTime3 > warningDate - 10000000 || mod(Floor(TodayTime3/1000000),5)==0) && UpdateSilentlyR != 0)	; && numPara0 == 0
		{
			Msgbox, update
		}
	return
	
	^7::
		Reload
	return
	
	
	~^8::
		Tooltip, 
		; MsgBox, 291, Preme for Windows, Uninstall or Repair?   ;3+32+256(Makes the 2nd button the default )
		
		; sleep, 200
		; WinActivate 
		; ControlSetText, Button1, &Uninstall, Preme for Windows
		; ControlSetText, Button2, &Repair, Preme for Windows
	return
	
	
	~^9::   
		;tyty := 3 | 0xFFFF
		;Gosub shortcutButton	
		; Gui, Destroy
		; Gosub, InstallationType
		;Gui, -0xC40000
		;ClassNN		VideoRenderer1
		; WinGet,ID,ID, ahk_class MCIQTZ_Window
		; WinSet, Style, ^0x40000 , ahk_id %ID% ; can't ReSize 
		; WinSet, Style, ^0xC00000, ahk_id %ID% ; Caption 
	return
	


	

	~^0::
	varEqualTest := "juijui"
	;if (varEqualTest == "juijui")
	;Msgbox, juijui  %varEqualTest%
	test1 := 6**3
	MouseGetPos, , , WhichWindow, WhichControl
	ControlGetPos, x, y, w, h, %WhichControl%, ahk_id %WhichWindow%
	ToolTip, Alt+O con x=%x% y=%y% w=%w% h=%h% wh=%WhichControl% %test1%		
	return


	

^!1::		;ctrl alt
TodayTime3 = 20131026000000
Random, dayPlus, 0, 4
;tempTW := mod(Floor(TodayTime3/1000000),100) + 5 + dayPlus
tempTW := mod(Floor(TodayTime3/1000000),100) - mod(mod(Floor(TodayTime3/1000000),100),5) + 5 + dayPlus
		dateWrite := ( ((Floor(TodayTime3/100000000)+Floor(tempTW/31))*100) + mod(tempTW,31) + Floor(tempTW/31) )*1000000	;ignore the new year.
		Tooltip, %dateWrite% y 
return	



^+1::		;ctrl shift
	RefreshTray()	;important
	;KeyHistory
return

^+2::
	Reload
return

^+3::
	UrlDownloadToFile, http://bit.ly/1i28rX4, %a_appdata%\Preme for Windows\z_premeupgrade
	Tooltip, error is %ErrorLevel%
return
;`n new line
; End Program      End Program      End Program      End Program      End Program      End Program      End Program      
*/		;edit here
