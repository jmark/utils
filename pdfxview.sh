#!/bin/bash  
Filename="z:${1//\//\\}"
wine "C:\Program Files\Tracker Software\PDF Viewer\PDFXCview.exe" $Filename
