# Test-Workflow mit produktiven Nutzerdaten (sicher, reproduzierbar)

## Ziel
Code-Änderungen in Hibiscus testen, ohne das produktive Benutzerverzeichnis zu riskieren.

## Grundlage aus `jameica/build/jameica.sh`
- Das Startskript startet Java und reicht alle Parameter durch (`$@`).
- Damit kann ein abweichendes Benutzerverzeichnis direkt über `-f <Verzeichnis>` verwendet werden.
- Konsequenz: Das gleiche Jameica/Hibiscus-Binary kann mit verschiedenen Datenbeständen gestartet werden.

## Wichtige Fakten aus dem Code
- Standard-Backup-Verzeichnis ist das Benutzerverzeichnis (Workdir), sofern nicht explizit anders gesetzt:
  - `jameica/src/de/willuhn/jameica/system/Config.java` (`getBackupDir()`).
- Automatische Backups sind ZIP-Dateien `jameica-backup-*.zip`.
- Inhalt der Backups:
  - Es werden Unterverzeichnisse aus dem Workdir gesichert.
  - `plugins` und `updates` werden absichtlich nicht gesichert.
  - Quelle: `jameica/src/de/willuhn/jameica/backup/BackupEngine.java`.

## Einziger Ablauf
1. Einmalige Initialisierung aus produktivem Backup.
2. Danach immer gleicher DEV-Benutzerordner.
3. Start aus VS Code über `Run and Debug -> Start H`.
4. Lokaler Hibiscus-Projektpfad wird automatisch als Plugin-Pfad gesetzt.
5. Dieser Workspace ist bewusst Linux-only für SWT: `jameica/.classpath` nutzt `lib/swt/linux64/swt.jar`.

## Praktische Schritte

### 1) Einmalige Initialisierung
```bash
./project/scripts/start-h-test.sh --init
```

Das Skript:
- nimmt automatisch das neueste Backup aus `PROD_WORKDIR`,
- initialisiert einen persistenten DEV-Benutzerordner (`TEST_WORKDIR`),
- setzt in `cfg/de.willuhn.jameica.system.Config.properties` den lokalen Plugin-Pfad:
  - `jameica.plugin.dir.0=<workspace>/hibiscus`
- fuer produktive Laufzeit ggf. `JAMEICA_SCRIPT` setzen (Pfad zu deiner installierten Jameica):
  - `export JAMEICA_SCRIPT="/pfad/zu/deiner/prod/jameica.sh"`
  - oder einmalig: `./project/scripts/start-h-test.sh -j "/pfad/zu/deiner/prod/jameica.sh"`

VS Code (einziger Weg):
- `Run and Debug` -> Launch-Konfiguration `Start H`.
- Diese startet Jameica direkt via Java-Main-Klasse `de.willuhn.jameica.Main`.
- Breakpoints in Java-Code sind damit möglich.

### 2) Normaler Start nach Coding-Session
- In Visual Studio Code: `Run and Debug` -> `Start H`.

### 3) Nach Klassenpfad-Änderungen in Visual Studio Code
- `Java: Clean Java Language Server Workspace`
- Fenster neu laden
- `Java: Force Java Compilation` (falls vorhanden), sonst einfach Projekt neu indexieren lassen

## Re-Init (wenn du frische Daten aus prod willst)
```bash
./project/scripts/start-h-test.sh --init
```
