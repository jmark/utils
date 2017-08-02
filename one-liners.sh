find /usr/bin -type f -exec stat --print="%x => %n\n" \{\} + | sort -n | less
yaourt -Qqs perl- | xargs yaourt -S 2>&1 | grep error:
convmv --notest -r -f latin1 -t utf-8 "`find .`"
