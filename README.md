Displays the dark souls like text in the middle of the screen and plays a sound. Made with quickshell.

Run with:

```bash
nix run github:vimjoyer/dark-text -- "YOUR TEXT"
```

add -d flag to show death text and play death sound

```bash
nix run github:vimjoyer/dark-text -- -d "YOUR TEXT"
```

to disable sound use -n flag

```bash
nix run github:vimjoyer/dark-text -- -n "YOUR TEXT"
```

To set your own parameters use
```bash
nix run github:vimjoyer/dark-text#dark-text -- -t "YOUR TEXT" --color "#ffffff" --duration 2000
```

Thanks [Raf](https://github.com/NotAShelf/) for the idea
