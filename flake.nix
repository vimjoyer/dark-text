{
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.eb-garamond ]; };
    in
    {
      packages.${system} = rec {
        dark-text = pkgs.writeShellApplication {
          name = "dark-text";
          runtimeInputs = with pkgs; [
            quickshell
          ];
          bashOptions = [
            "errexit"
            "pipefail"
          ];
          text = ''
            export FONTCONFIG_FILE=${FONTCONFIG_FILE}

            : "''${DARK_TEXT:=Victory!}"
            : "''${DARK_COLOR:=#fad049}"
            : "''${DARK_DURATION:=1000}"

            show_help() {
            cat <<EOF
            Usage: dark-text [OPTIONS]

            Options:
              -t, --text <TEXT>       Text to display [default: Hello, World!]
              -c, --color <COLOR>     Text color [default: #fad049]
              -d, --duration <MS>     Duration in milliseconds [default: 1000]
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
                -h|--help)
                  show_help
                  exit 1
                  ;;
              esac
            done

            export DARK_TEXT DARK_COLOR DARK_DURATION

            exec quickshell -p ${./shell.qml} > /dev/null
          '';
        };

        dark-souls = pkgs.writeShellApplication {
          name = "dark-souls";
          runtimeInputs = with pkgs; [
            quickshell
            sox
          ];

          bashOptions = [
            "errexit"
            "pipefail"
          ];

          text = ''
            : "''${DARK_TEXT:=Victory!}"
            : "''${DARK_COLOR:=#fad049}"
            : "''${DARK_DURATION:=10000}"
            : "''${ACTION:=victory}"
            : "''${PLAY_SOUND:=true}"

            case "''${1:-}" in
                -d|--death)
                    ACTION="death"
                    DARK_DURATION=6500
                    DARK_COLOR="#A01212"
                    shift
                    ;;
            esac

            case "''${1:-}" in
                -n|--no-sound)
                    PLAY_SOUND=false
                    shift
                    ;;
            esac

            export DARK_TEXT DARK_COLOR DARK_DURATION

            if [ "$PLAY_SOUND" = true ]; then
                play "${./.}/$ACTION.mp3" >/dev/null 2>&1 &
                sleep 0.2
            fi

            ${lib.getExe dark-text} "$@"
          '';
        };

        default = pkgs.symlinkJoin {
          name = "dark-souls";
          paths = [
            dark-text
            dark-souls
          ];
        };

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
