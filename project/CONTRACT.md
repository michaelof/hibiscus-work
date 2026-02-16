# CONTRACT: Umsatzkategorien-UI (minimalinvasiv, zielspezifisch)

## Ziel
1. Im Bereich `Datei -> Einstellungen -> Umsatz-Kategorien` die Bedienbarkeit großer Kategorie-Bäume verbessern, ohne fachliche Logik zu verändern.
2. Pro Vorkommen von „Simple Kategoriebaum-Dropdown“ eine zielspezifische Verbesserung bewerten und ggf. umsetzen.

## Nicht verhandelbare Leitplanken
`minimalinvasiv` ist oberstes Gebot.

1. Keine Datenbank-Änderungen.
2. Keine Änderungen im ENCODING.
3. Kein Änderung von existierenden Bezeichnern, Strings aus "Settings" etc. 
4. Keine Änderung der Matching-Logik für Umsatzkategorien.
5. Nur UI-Anpassung:
   `statt immer kompletter Baum -> Baumansicht mit Filterfeld + Expand/Collapse`.
6. Möglichst keine neuen Dependencies:
   nur SWT/JFace verwenden, die in Jameica ohnehin vorhanden sind.
7. Best effort Umsetzung ohne tiefe Eingriffe in Jameica-Kern.

## Arbeitsstruktur (zielspezifisch)
Jedes Ziel wird als eigener Workstream geführt, mit eigener Scope-Definition und eigenen Artefakten:

1. Plan-Datei: `project/plans/<ziel-id>-PLAN.md`
2. ToDo-Datei: `project/plans/<ziel-id>-TODO.md`

Empfohlene Ziel-IDs:
1. `Z1-SETTINGS-TREE` (Einstellungen-Tab Umsatzkategorien)
2. `Z2-DROPDOWNS` (Simple Kategoriebaum-Dropdowns, pro Vorkommen)
3. `UK1-SICHERHEITSABFRAGE-LOESCHEN` (Loeschwarnung in Umsatzkategorien)

## Scope Z1-SETTINGS-TREE
Betroffen:
1. `Datei -> Einstellungen -> Tab Umsatz-Kategorien`.

Nicht betroffen:
1. Kategorie-Matching in Umsatzzuordnung.
2. Datenmodell/DB.
3. Import/Export.
4. Andere Views/Dialoge, außer optional Wiederverwendung bestehender UI-Patterns.

## Scope Z2-DROPDOWNS
Betroffen sind nur konkrete Vorkommen von `UmsatzTypInput` in der GUI, jeweils als eigenes Sub-Ziel.
Die Reihenfolge entspricht der bestätigten Priorität.

1. `Z2.1` (Priorität 1):
   Umsätze-Übersicht, Filter „Kategorie“ mit `<Alle Kategorien>`
   (`Konto/Kategorie/Zeitraum`), Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/KontoauszugList.java`.
2. `Z2.2` (Priorität 2):
   Umsatz-Detailansicht, Feld „Kategorie“, Code:
   `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`.
3. `Z2.3` (Priorität 3):
   Umsatzkategorie-Detail, Feld „Übergeordnete Kategorie“, Code:
   `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzTypControl.java`.

Für jedes Sub-Ziel gilt:
1. Eigener Scope im jeweiligen Plan/TODO.
2. Entscheidung „umsetzen / nicht umsetzen“ mit kurzer Begründung.
3. Keine Sammeländerung ohne klare Trennung pro Vorkommen.

## Scope UK1-SICHERHEITSABFRAGE-LOESCHEN
Betroffen:
1. `Einstellungen -> Umsatz-Kategorien -> Kontextmenue -> Loeschen`.
2. Loesch-Rueckfrage in `hibiscus/src/de/willuhn/jameica/hbci/gui/action/DBObjectDelete.java`.

Nicht betroffen:
1. Datenmodell/DB-Schema.
2. Matching-Logik.
3. Encoding.
4. Zusatzfunktion „Zeige Umsaetze“.

## Konkrete UX-Definition (Abnahme) für Z1
1. Über dem Baum steht ein Textfeld: `Filter...`.
2. Der Filter blendet Äste ohne Treffer aus.
3. Treffer-Nodes sind sichtbar; Pfade bleiben navigierbar (Kontext bleibt erhalten).
4. Es gibt zwei Buttons:
   `Alles einklappen` und `Alles ausklappen`.
5. Optional:
   `Filter zurücksetzen (X)`.

## Technischer Ansatz (High-Level)
1. Bestehende Kategorienansicht in den Einstellungen beibehalten.
2. Baumdarstellung auf eine filterbare Baum-UI umstellen (SWT/JFace Tree/TreeViewer-Pattern).
3. Filter nur auf Anzeigeebene anwenden.
4. Vorhandene Aktionen/Kontextmenüs unverändert weiterverwenden.
5. Bestehende Persistenz/Objektmodell unverändert lassen.

## Qualitäts- und Änderungsgrenzen
1. Kleine, lokal nachvollziehbare Commits.
2. Keine „Nebenbei-Refactorings“ außerhalb des betroffenen UI-Bereichs.
3. Keine Änderung bestehender Nutzerdaten.
4. Bestehende Funktionen der Kategorienpflege bleiben erhalten.

## Definition of Done
1. Für jedes aktive Ziel existieren `PLAN` und `TODO` mit zielspezifischem Scope.
2. Änderungen sind pro Ziel/Vorkommen nachvollziehbar getrennt.
3. Für Z1 gilt: Einstellungen-Tab Umsatz-Kategorien enthält Filterfeld und Expand/Collapse gemäß UX-Definition.
4. Keine Änderungen an DB-Schema oder Matching-Logik.
5. Build/Start der Anwendung weiterhin möglich.
6. Kurze Vorher/Nachher-Beschreibung dokumentiert.

## PR-Zielbild (5-Minuten-Review für Olaf)
Die Pull-Request soll enthalten:

1. Sehr kurze Problem-/Lösungsbeschreibung (max. 10 Zeilen).
2. Exakte Liste geänderter Dateien mit Begründung pro Datei.
3. Hinweis „Keine DB-Änderung, keine Matching-Änderung“.
4. Mini-Testprotokoll:
   Filter leer, Filter mit Treffer, Filter ohne Treffer, Expand/Collapse.
5. Optional 1-2 Screenshots (vorher/nachher) nur vom betroffenen Tab.

## Git/PR-Workflow (verbindlich)
1. Pro Ziel ein eigener Branch und ein eigener PR:
   `Z1`, `Z2.1`, `Z2.2`, `Z2.3`, `UK1` getrennt.
2. PRs werden als `Draft` vorbereitet und erst gesammelt finalisiert.
3. Commit-Messages in Deutsch.
4. Commit-Body ohne Literal-`\n`-Zeichen:
   echte Zeilenumbrüche verwenden.
5. Keine Sammel-Commits über mehrere Ziele.
6. Repo-spezifisch arbeiten:
   Feature-Commits in `hibiscus`, keine unbeabsichtigten Top-Level-Git-Änderungen.
