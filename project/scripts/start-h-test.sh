#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Startet Jameica/Hibiscus mit einem persistenten DEV-Benutzerverzeichnis.

Verwendung:
  start-h-test.sh [Optionen] [-- <weitere Jameica-Parameter>]

Optionen:
  -i, --init                DEV-Benutzerverzeichnis neu aus Backup initialisieren.
  -b, --backup <datei>      Explizite Backup-ZIP verwenden.
  -d, --test-dir <ordner>   Pfad fuer das DEV-Benutzerverzeichnis.
  -j, --jameica <datei>     Pfad zu jameica.sh der zu startenden Installation.
  -n, --no-start            Nur Initialisierung/Pruefung, danach nicht starten.
  -h, --help                Hilfe anzeigen.

Umgebungsvariablen:
  PROD_WORKDIR              Produktives Benutzerverzeichnis (Default: ~/.jameica)
  TEST_BASE                 Basisordner fuer DEV-Workdir (Default: ~/.jameica-test-runs)
  TEST_WORKDIR              Konkreter DEV-Workdir (Default: $TEST_BASE/jh-dev)
  HIBISCUS_PLUGIN_DIR       Lokaler Hibiscus-Projektpfad (Default: <workspace>/hibiscus)
  JAMEICA_SCRIPT            Pfad zu jameica.sh (Default: <workspace>/jameica/build/jameica.sh)
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PROD_WORKDIR="${PROD_WORKDIR:-$HOME/Hibiscus/Userdaten/.jameica}"
TEST_BASE="${TEST_BASE:-$HOME/Hibiscus-TEST/.jameica-test-runs}"
TEST_WORKDIR="${TEST_WORKDIR:-$TEST_BASE/jh-dev}"
HIBISCUS_PLUGIN_DIR="${HIBISCUS_PLUGIN_DIR:-$WORKSPACE_DIR/hibiscus}"
JAMEICA_SCRIPT="${JAMEICA_SCRIPT:-$WORKSPACE_DIR/jameica/build/jameica.sh}"
INIT_MARKER=".initialized-from-backup"

backup_file=""
test_dir=""
start_app=1
reinit=0
extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--init)
      reinit=1
      shift
      ;;
    -b|--backup)
      backup_file="${2:-}"
      shift 2
      ;;
    -d|--test-dir)
      test_dir="${2:-}"
      shift 2
      ;;
    -j|--jameica)
      JAMEICA_SCRIPT="${2:-}"
      shift 2
      ;;
    -n|--no-start)
      start_app=0
      shift
      ;;
    --)
      shift
      extra_args+=("$@")
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unbekannter Parameter: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$test_dir" ]]; then
  TEST_WORKDIR="$test_dir"
fi

need_init=0
if [[ "$reinit" -eq 1 ]]; then
  need_init=1
elif [[ ! -d "$TEST_WORKDIR" || ! -f "$TEST_WORKDIR/$INIT_MARKER" ]]; then
  need_init=1
fi

if [[ "$need_init" -eq 1 ]]; then
  if [[ -z "$backup_file" ]]; then
    backup_file="$(ls -1t "$PROD_WORKDIR"/jameica-backup-*.zip 2>/dev/null | head -n 1 || true)"
  fi

  if [[ -z "$backup_file" ]]; then
    echo "Kein Backup gefunden unter: $PROD_WORKDIR/jameica-backup-*.zip" >&2
    exit 1
  fi

  if [[ ! -f "$backup_file" ]]; then
    echo "Backup-Datei nicht gefunden: $backup_file" >&2
    exit 1
  fi

  if ! command -v unzip >/dev/null 2>&1; then
    echo "'unzip' wurde nicht gefunden. Bitte installieren und erneut ausfuehren." >&2
    exit 1
  fi

  rm -rf "$TEST_WORKDIR"
  mkdir -p "$TEST_WORKDIR"
  unzip -q "$backup_file" -d "$TEST_WORKDIR"
  touch "$TEST_WORKDIR/$INIT_MARKER"

  echo "Initialisierung    : neu aus Backup"
  echo "Backup-Datei       : $backup_file"
else
  echo "Initialisierung    : bestehender DEV-Stand wird verwendet"
fi

mkdir -p "$TEST_WORKDIR/cfg"
cfg_file="$TEST_WORKDIR/cfg/de.willuhn.jameica.system.Config.properties"
touch "$cfg_file"

if [[ ! -d "$HIBISCUS_PLUGIN_DIR" ]]; then
  echo "Lokaler Hibiscus-Pfad nicht gefunden: $HIBISCUS_PLUGIN_DIR" >&2
  exit 1
fi

if [[ ! -d "$HIBISCUS_PLUGIN_DIR/bin" && ! -d "$HIBISCUS_PLUGIN_DIR/target/classes" ]]; then
  echo "Hinweis: Kein $HIBISCUS_PLUGIN_DIR/bin oder target/classes gefunden." >&2
  echo "Lokale Code-Aenderungen sind erst wirksam, wenn Class-Dateien gebaut wurden." >&2
fi

tmp_cfg="$(mktemp)"
awk '
  !/^jameica\.plugin\.dir(\.[0-9]+)?=/
' "$cfg_file" > "$tmp_cfg"
printf "jameica.plugin.dir.0=%s\n" "$HIBISCUS_PLUGIN_DIR" >> "$tmp_cfg"
mv "$tmp_cfg" "$cfg_file"

echo "DEV-Benutzerordner : $TEST_WORKDIR"
echo "Plugin-Pfad (H)    : $HIBISCUS_PLUGIN_DIR"
echo "Startskript (J)    : $JAMEICA_SCRIPT"

if [[ "$start_app" -eq 0 ]]; then
  exit 0
fi

if [[ ! -x "$JAMEICA_SCRIPT" ]]; then
  echo "Startskript nicht ausfuehrbar: $JAMEICA_SCRIPT" >&2
  exit 1
fi

launcher_dir="$(cd "$(dirname "$JAMEICA_SCRIPT")" && pwd)"
arch="$(uname -m)"
if [[ "$arch" == "aarch64" ]]; then
  expected_jar="$launcher_dir/jameica-linuxarm64.jar"
elif [[ "$arch" == *64* ]]; then
  expected_jar="$launcher_dir/jameica-linux64.jar"
else
  expected_jar="$launcher_dir/jameica-linux.jar"
fi

if [[ ! -f "$expected_jar" ]]; then
  cat >&2 <<EOF
Runtime-JAR nicht gefunden: $expected_jar

Das gewaehlte Startskript verweist vermutlich auf ein Quell-Checkout statt auf
eine installierte Jameica-Laufzeit.

Loesung:
  1) Setze JAMEICA_SCRIPT auf dein produktives jameica.sh, z.B.:
     export JAMEICA_SCRIPT="/pfad/zu/deiner/prod/jameica.sh"
  2) Oder starte einmalig mit:
     ./project/scripts/start-h-test.sh -j "/pfad/zu/deiner/prod/jameica.sh"
EOF
  exit 1
fi

exec "$JAMEICA_SCRIPT" -f "$TEST_WORKDIR" "${extra_args[@]}"
