# UK1-SICHERHEITSABFRAGE-LOESCHEN Plan

## Basisstand fuer Folgeumsetzung
1. Das Refactoring nach Olaf (UmsatzTypDelete) wird auf dem jeweils aktuellen `origin/master` im Fork umgesetzt.
2. Vor Umsetzung:
   - `git -C hibiscus fetch origin master`
   - UK1-Branch von `origin/master` neu ausrichten, falls ein Recut noetig ist.

## Scope
`Einstellungen -> Umsatz-Kategorien -> Kontextmenue -> Loeschen`

## Ziele
- Spezielle Loeschwarnung bei vorhandenen Umsatz-Zuordnungen
- Gilt fuer Einzel- und Mehrfachauswahl
- Keine Aenderung am eigentlichen Loeschablauf

## Finaler Ist-Stand
1. `DBObjectDelete` ist wieder typ-neutral und enthaelt nur generische Loeschlogik.
2. UmsatzTyp-spezifische Warnlogik liegt in `UmsatzTypDelete` (abgeleitet von `DBObjectDelete`).
3. Das Kontextmenue `UmsatzTypList` verwendet fuer "Loeschen..." jetzt `UmsatzTypDelete`.
4. Falls mindestens eine gewaehlte Kategorie Umsaetze zugeordnet hat, wird Spezialtext verwendet.
5. Einzel-Auswahl mit Zuordnung:
- `Es existieren Umsaetze zu <Kategorie>. Wirklich loeschen?`
6. Mehrfach-Auswahl mit mindestens einer Zuordnung:
- `Es existieren Umsaetze zu mindestens einer der ausgewaehlten Kategorien. Wirklich loeschen?`
7. Die Pruefung beruecksichtigt auch Unterkategorien rekursiv.
8. Ohne Zuordnungen bleiben die bisherigen Standardtexte erhalten.

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
1. Geaenderte Codedateien:
- `hibiscus/src/de/willuhn/jameica/hbci/gui/action/DBObjectDelete.java`
- `hibiscus/src/de/willuhn/jameica/hbci/gui/action/UmsatzTypDelete.java`
- `hibiscus/src/de/willuhn/jameica/hbci/gui/menus/UmsatzTypList.java`
2. Leitplanken:
- keine DB-Aenderung
- keine Matching-Aenderung
- keine Encoding-Migration

## Review-Feedback (Olaf)
1. Fachlich/UX-seitig ist UK1 nachvollziehbar, aber die Platzierung des UmsatzTyp-spezifischen Codes in `DBObjectDelete` ist aus Architektursicht unguenstig.
2. Vorschlag Olaf:
- neue Klasse `UmsatzTypDelete` (abgeleitet von `DBObjectDelete`)
- UmsatzTyp-spezifische Warnlogik dort kapseln
- `DBObjectDelete` bleibt typ-neutral/generisch

## Follow-up-Status
1. Der Olaf-Vorschlag wurde umgesetzt:
- `UmsatzTypDelete` ist eingefuehrt
- `UmsatzTypList` ist auf `UmsatzTypDelete` umgestellt
- `DBObjectDelete` bleibt typ-neutral
2. Prozesshinweis:
- Der bestehende Upstream-PR `#153` wurde als Draft aktualisiert.
- Finale Umstellung auf `Ready for review` erfolgt im Sammelabschluss.
