# ghh demo — VHS tape file
# Run: vhs demo/ghh-demo.tape

Output demo/ghh-demo.gif

Set Shell "bash"
Set FontSize 16
Set Width 900
Set Height 600
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 60ms

# Source ghh silently and clear
Hide
Type "source bin/ghh && clear"
Enter
Sleep 1s
Show

# Scene 1: Launch ghh and search "diff"
Type "ghh"
Sleep 600ms
Enter
Sleep 1.5s
Type "diff"
Sleep 2s

Escape
Sleep 500ms

# Scene 2: Search "worktree"
Type "ghh"
Sleep 600ms
Enter
Sleep 1.5s
Type "worktree"
Sleep 2s

Escape
Sleep 500ms

# Scene 3: Search "tag"
Type "ghh"
Sleep 600ms
Enter
Sleep 1.5s
Type "tag"
Sleep 2s

Escape
Sleep 500ms

# Scene 4: Search "cherry"
Type "ghh"
Sleep 600ms
Enter
Sleep 1.5s
Type "cherry"
Sleep 2s

Escape
Sleep 500ms

# Scene 5: Show gc
Type "gc"
Sleep 600ms
Enter
Sleep 2s

Escape
Sleep 1s
