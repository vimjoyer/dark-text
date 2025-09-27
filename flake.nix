{
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.eb-garamond ]; };
    in
    {
      packages.${system} = rec {
        dark-text = pkgs.writeShellApplication {
          name = "dark-text";
          runtimeInputs = with pkgs; [
            quickshell
            sox
          ];
          bashOptions = [
            "errexit"
            "pipefail"
          ];
          text = ''
            export FONTCONFIG_FILE=${FONTCONFIG_FILE}

            : "''${DARK_TEXT:=Hello, World!}"
            : "''${DARK_COLOR:=#fad049}"
            : "''${DARK_DURATION:=10000}"
            : "''${ACTION:=victory}"
            : "''${PLAY_SOUND:=true}"

            play_sound() {
                play "${./sounds}/$1.mp3" >/dev/null 2>&1 &
            }

            # todo: add more sounds and docs for them
            show_help() {
            if $PLAY_SOUND; then 
              play_sound "help_me"
            fi
            cat <<EOF
            Usage: dark-text [OPTIONS]

            Options:
              -t, --text <TEXT>       Text to display [default: Hello, World!]
              -c, --color <COLOR>     Text color [default: #fad049]
              -d, --duration <MS>     Duration in milliseconds [default: 10000]
              -a, --action            Sound to play [default: victory]
              -n, --no-sound          Don't play sound
              --death                 Dark souls death preset
              -h, --help              Print help
            EOF
            }

            while [[ $# -gt 0 ]]; do
              case "$1" in
                -t|--text)
                  DARK_TEXT="$2"
                  shift 2
                  ;;
                -c|--color)
                  DARK_COLOR="$2"
                  shift 2
                  ;;
                -d|--duration)
                  DARK_DURATION="$2"
                  shift 2
                  ;;
                -a|--action)
                  ACTION="$2"
                  shift 2
                  ;;
                -n|--no-sound)
                  PLAY_SOUND=false
                  shift
                  ;;
                --death)
                  ACTION="death"
                  DARK_DURATION=6500
                  DARK_COLOR="#A01212"
                  shift
                  ;;
                -h|--help)
                  show_help
                  exit 1
                  ;;
              esac
            done

            export DARK_TEXT DARK_COLOR DARK_DURATION

            if [ "$PLAY_SOUND" = true ]; then
                play_sound "$ACTION"
                sleep 0.2
            fi

            exec quickshell -p ${./shell.qml} > /dev/null
          '';
        };

        default = dark-text;

      };

      devShells.${system}.default = pkgs.mkShell {
        DARK_TEXT = "Hello World";
        DARK_DURATION = 1000;

        buildInputs = with pkgs; [
          quickshell
          sox
        ];

        shellHook = ''
          export FONTCONFIG_FILE=${FONTCONFIG_FILE}
        '';
      };
    };
}
