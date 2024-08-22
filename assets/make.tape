# Where should we write the GIF?
Output assets/make.gif

Set WindowBar Colorful
Set FontSize 12
Set Padding 4
Set Width 680
Set Height 960
Set TypingSpeed 30ms

Sleep 1s
Type "make"
Enter
Sleep 5s
Type "make all"
Enter
Sleep 25s
Type "make docker-run"
Enter
Sleep 5s
Type "carbonyl http://127.0.0.1:8080"
Enter
Sleep 10s
Ctrl+C
Sleep 2s
Type "make docker-stop"
Enter
Sleep 5s
