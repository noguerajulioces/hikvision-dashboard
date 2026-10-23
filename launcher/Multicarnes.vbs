' Multicarnes desktop launcher (no visible console window).
' The desktop / Start Menu shortcut points here.
Option Explicit
Dim shell, appDir, rubyw, script, extra
Set shell = CreateObject("WScript.Shell")
appDir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
rubyw  = appDir & "..\ruby\bin\rubyw.exe"
script = appDir & "launch.rb"
extra = ""
If WScript.Arguments.Count > 0 Then extra = " " & WScript.Arguments(0)
' 0 = hidden window, False = do not wait for it to finish.
shell.Run """" & rubyw & """ """ & script & """" & extra, 0, False
