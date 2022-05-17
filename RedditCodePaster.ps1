# save as eg CodePaster.ps1
# Author u/jimb2 2022-05-18 
$code = @'
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
'@
Add-Type $code -Name Utils -Namespace Win32
$hwnd0 = [Win32.Utils]::GetForegroundWindow()  # get current powershell window 

Add-Type -AssemblyName System.Windows.Forms

'Reddit Code Paster'
''
'1.  Run this script (you have done this!)'
'2.  Start Reddit post with a codeblock'
'3.  Copy code to clipboard'
'4.  Press enter to continue'
'5.  Click in Reddit code block'
''

$x = Read-Host 'Press Enter when the text (code) is in the clipboard'
''
'Text will be typed when the window focus changes!'

do {
    Start-Sleep 1
    Write-Host '.' -NoNewline
  } until ( $hwnd0 -ne [Win32.Utils]::GetForegroundWindow() )

$text = Get-Clipboard

foreach ( $t in $text ) {
    [System.Windows.Forms.SendKeys]::SendWait($t)
    [System.Windows.Forms.SendKeys]::SendWait("`r")
    Start-Sleep -Milliseconds 100
}
'.done!'
Start-Sleep 2 
