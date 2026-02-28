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

# Source ghh silently
Hide
Type "source bin/ghh && clear"
Enter
Sleep 1s
Show

# Scene 1: Search "status" and run it
Type "ghh"
Sleep 500ms
Enter
Sleep 1s
Type "short status"
Sleep 1s
Enter
Sleep 800ms
# Default handler prompts "Run it? [Y/n/copy]" — confirm
Enter
Sleep 2s

# Scene 2: Search "log" and run the graph
Type "ghh"
Sleep 500ms
Enter
Sleep 1s
Type "commit graph"
Sleep 1s
Enter
Sleep 800ms
Enter
Sleep 2s

# Scene 3: Show worktree section
Type "ghh"
Sleep 500ms
Enter
Sleep 1s
Type "worktree"
Sleep 2s
Escape
Sleep 500ms

# Scene 4: Show tag section
Type "ghh"
Sleep 500ms
Enter
Sleep 1s
Type "tag"
Sleep 2s
Escape
Sleep 500ms

# Scene 5: gc conventional commit flow
Type "gc"
Sleep 500ms
Enter
Sleep 1.5s
# Pick "feat"
Type "feat"
Sleep 800ms
Enter
Sleep 1.5s

Escape
Sleep 1s
