$tmpf = [System.IO.Path]::GetTempFileName()
Get-WmiObject -class win32_networkadapterconfiguration -filter "ipenabled = true" | % { $_ | format-list | out-string >> $tmpf }
notepad $tmpf
