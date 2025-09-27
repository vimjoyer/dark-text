{
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.eb-garamond ]; };
      SOUNDS = map (f: pkgs.lib.strings.removeSuffix ".mp3" f) (
        builtins.attrNames (builtins.readDir ./sounds)
      );
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

            SOUNDS=(${builtins.concatStringsSep " " (map (s: "\"" + s + "\"") SOUNDS)})

            : "''${DARK_TEXT:=Hello, World!}"
            : "''${DARK_COLOR:=#fad049}"
            : "''${DARK_DURATION:=10000}"
            : "''${SOUND:=victory}"
            : "''${PLAY_SOUND:=true}"
            : "''${SHOW_OVERLAY:=true}"

            play_sound() {
                play "${./sounds}/$1.mp3" >/dev/null 2>&1 &
            }

            contains() {
              local item=$1
              shift
              for x in "$@"; do
                if [[ "$x" == "$item" ]]; then
                  return 0
                fi
              done
              return 1
            }

            # todo: add more sounds and docs for them
            show_help() {
            if $PLAY_SOUND; then 
              play_sound "help"
            fi
            cat <<EOF
            Usage: dark-text [OPTIONS]

            Options:
              -t, --text <TEXT>       Text to display [default: Hello, World!]
              -c, --color <COLOR>     Text color [default: #fad049]
              -d, --duration <MS>     Duration in milliseconds [default: 10000]
              -s, --sound             Sound to play [default: victory]
                                      Available sounds: ${pkgs.lib.concatStringsSep " " SOUNDS}
              -n, --no-sound          Don't play sound
              --no-display            Don't display overlay
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
                -s|--sound)
                  if contains "$2" "''${SOUNDS[@]}"; then
                    SOUND="$2"
                  else
                    echo "Unknown sound. Available sounds: ''${SOUNDS[*]}"
                    exit 1
                  fi
                  shift 2
                  ;;
                -n|--no-sound)
                  PLAY_SOUND=false
                  shift
                  ;;
                --no-display)
                  SHOW_OVERLAY=false
                  shift
                  ;;
                --death)
                  SOUND="death"
                  DARK_DURATION=6500
                  DARK_COLOR="#A01212"
                  shift
                  ;;
                -h|--help)
                  show_help
                  exit 0
                  ;;
                *)
                  echo "Unknown option: $1"
                  show_help
                  exit 1
                  ;;
              esac
            done

            export DARK_TEXT DARK_COLOR DARK_DURATION

            if $PLAY_SOUND; then
                play_sound "$SOUND"
            fi

            if $SHOW_OVERLAY; then
              exec quickshell -p ${./shell.qml} > /dev/null
            fi
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
