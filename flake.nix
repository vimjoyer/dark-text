{
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    {
      packages.${system} = rec {
        dark-text = pkgs.writeShellApplication {
          name = "dark-shell";
          runtimeInputs = with pkgs; [
            quickshell
          ];
          text = ''
            # Usage: dark-shell -t "Hello" -c "#ff0000" -d 1500

            DARK_TEXT="Hello, World!"
            DARK_COLOR="#fad049"
            DARK_DURATION="1000"

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
                *)
                  echo "Unknown option: $1"
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
            # Usage dark-souls [ -d | --death ] [ -n | --no-sound ] TEXT
            ACTION="victory"
            DURATION=10000
            COLOR="#fad049"
            PLAY_SOUND=true

            case "''${1:-}" in
                -d|--death)
                    ACTION="death"
                    DURATION=6500
                    COLOR="#A01212"
                    shift
                    ;;
            esac

            case "''${1:-}" in
                -n|--no-sound)
                    PLAY_SOUND=false
                    shift
                    ;;
            esac

            DARK_TEXT="$*"

            if [ "$PLAY_SOUND" = true ]; then
                play "${./.}/$ACTION.mp3" >/dev/null 2>&1 &
                sleep 0.2
            fi

            ${lib.getExe dark-text} -t "$DARK_TEXT" -d $DURATION -c $COLOR
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
      };
    };
}
