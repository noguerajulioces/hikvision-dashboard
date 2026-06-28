' Multicarnes desktop launcher (no visible console window).
' The desktop / Start Menu shortcut points here.
Option Explicit
Dim shell, appDir, rubyw, script
Set shell = CreateObject("WScript.Shell")
appDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
rubyw  = appDir & "..\ruby\bin\rubyw.exe"
script = appDir & "launch.rb"
' 0 = hidden window, False = do not wait for it to finish.
shell.Run """" & rubyw & """ """ & script & """", 0, False
