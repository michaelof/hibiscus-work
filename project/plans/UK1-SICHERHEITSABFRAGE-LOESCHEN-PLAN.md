# UK1-SICHERHEITSABFRAGE-LOESCHEN Plan

## Scope
`Einstellungen -> Umsatz-Kategorien -> Kontextmenue -> Loeschen`

## Ziele
- Spezielle Loeschwarnung bei vorhandenen Umsatz-Zuordnungen
- Gilt fuer Einzel- und Mehrfachauswahl
- Keine Aenderung am eigentlichen Loeschablauf

## Finaler Ist-Stand
1. Die Loesch-Action bleibt zentral in `hibiscus/src/de/willuhn/jameica/hbci/gui/action/DBObjectDelete.java`.
2. Vor dem Yes/No-Dialog wird geprueft, ob es sich um `UmsatzTyp`-Objekte handelt.
3. Falls mindestens eine gewaehlte Kategorie Umsaetze zugeordnet hat, wird Spezialtext verwendet.
4. Einzel-Auswahl mit Zuordnung:
- `Es existieren Umsaetze zu <Kategorie>. Wirklich loeschen?`
5. Mehrfach-Auswahl mit mindestens einer Zuordnung:
- `Es existieren Umsaetze zu mindestens einer der ausgewaehlten Kategorien. Wirklich loeschen?`
6. Die Pruefung beruecksichtigt auch Unterkategorien rekursiv.
7. Ohne Zuordnungen bleiben die bisherigen Standardtexte erhalten.

## Fachliche Grenzen
1. Keine Datenbank-Aenderung.
2. Keine Matching-Logik-Aenderung.
3. Keine Encoding-Migration.
4. Keine Zusatzfunktion "Zeige Umsaetze".

## Testabnahme
Interaktive Abnahme wurde vollstaendig erfolgreich durchgefuehrt:
1. Einzelkategorie mit Zuordnungen -> Spezialwarnung mit Kategoriename.
2. Einzelkategorie ohne Zuordnungen -> Standardwarnung.
3. Mehrfachauswahl mit mindestens einer Zuordnung -> Spezialwarnung.
4. Rekursiver Fall (Umsaetze in Unterkategorie) -> Spezialwarnung.
5. Loeschverhalten bleibt fachlich unveraendert (Umsaetze bleiben, Zuordnung wird entfernt).

## PR-Readiness
1. Geaenderte Codedatei:
- `hibiscus/src/de/willuhn/jameica/hbci/gui/action/DBObjectDelete.java`
2. Leitplanken:
- keine DB-Aenderung
- keine Matching-Aenderung
- keine Encoding-Migration
