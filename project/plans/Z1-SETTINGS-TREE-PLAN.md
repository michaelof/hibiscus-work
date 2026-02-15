# Z1-SETTINGS-TREE Plan

## Scope
`Datei -> Einstellungen -> Tab Umsatz-Kategorien`

## Ziele
- Suchbegriff ueber Baum
- Unterkategorien-Option
- Expand/Collapse als Toggle

## Finaler Ist-Stand
1. Der Tab `Umsatz-Kategorien` wird in `hibiscus/src/de/willuhn/jameica/hbci/gui/views/Settings.java` aufgebaut und rendert den Baum weiterhin via `control.getUmsatzTypTree().paint(...)`.
2. Die Komponente `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/UmsatzTypTree.java` wurde lokal um reine Anzeige-Filterung und Expand/Collapse-Methoden erweitert.
3. Finale UX im Tab:
- Label `Suchbegriff` mit Eingabefeld ueber dem Baum.
- Checkbox `Unterkategorien von Treffern anzeigen`.
- Ein Toggle-Button `Alle aufklappen/zuklappen`.
- Kein dedizierter `X`-Reset-Button.

## Fachliche Grenzen (eingehalten)
1. Keine Datenbank-Aenderung.
2. Keine Matching-Logik-Aenderung.
3. Keine Encoding-Migration.
4. Kontextsensitivitaet des Kontextmenues bleibt erhalten (`UmsatzTyp`-Objekte).

## Testabnahme
Interaktive Abnahme wurde vollstaendig erfolgreich durchgefuehrt.

## PR-Readiness
1. Geaenderte Dateien:
- `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/UmsatzTypTree.java`
- `hibiscus/src/de/willuhn/jameica/hbci/gui/views/Settings.java`
2. Leitplanken:
- keine DB-Aenderung
- keine Matching-Aenderung
- keine Encoding-Migration
