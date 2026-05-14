# Z2-DROPDOWNS Plan

## Basisstand fuer Umsetzung
1. Branch-Neuzuschnitte fuer PR-Autarkie basieren auf dem jeweils aktuellen `origin/master` im Fork `michaelof/hibiscus`.
2. Vor jedem Recut:
   - `git -C hibiscus fetch origin master`
   - Branch von `origin/master` neu ableiten (kein `branch auf branch`).

## Scope
Pro Vorkommen von `UmsatzTypInput` separat bewerten.
GUI-Bezeichnung ist führend, Code-Stelle dient nur der Zuordnung.
Bearbeitungsreihenfolge: `Z2.1 -> Z2.2 -> Z2.3`.

## Sub-Ziele
1. `Z2.1` Umsätze-Übersicht: Filter „Kategorie“ (`<Alle Kategorien>`)
   Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/KontoauszugList.java`
2. `Z2.2` Umsatz-Detailansicht: Feld „Kategorie“
   Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`
3. `Z2.3` Umsatzkategorie-Detail: Feld „Übergeordnete Kategorie“
   Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzTypControl.java`

## Z2.1 Verhaltens-Invarianten (muss unverändert bleiben)
1. Filter-Verknüpfung bleibt AND-basiert:
   Kategorie-Filter wirkt zusätzlich zu Konto/Kontogruppe/Zeitraum/Gegenkonto/Betrag/Zweck/Suchbegriff.
2. Auto-Reload bleibt erhalten:
   UI-Änderungen an den Filtern triggern weiterhin die Aktualisierung über den bestehenden Listener-Mechanismus (kein neuer separater „Suchen“-Button).
3. Checkbox-Verhalten bleibt erhalten:
   `Untergeordnete Kategorien einbeziehen` triggert weiterhin ein Reload und beeinflusst ausschließlich die Kategorie-Matchlogik.
4. Enable/Disable-Regel bleibt erhalten:
   Checkbox ist nur aktiv, wenn eine konkrete Kategorie gewählt ist; bei `<Alle Kategorien>` bleibt sie deaktiviert.
5. Semantik bleibt erhalten:
   - Ohne Checkbox: exakte Kategorie.
   - Mit Checkbox: gewählte Kategorie plus untergeordnete Kategorien (über Parent-Kette).
6. Cache-/Persistenzverhalten bleibt erhalten:
   bestehende Werte für Kategorie und Unterkategorien-Option werden wie bisher verwendet.

## Testfälle (für Z2.1 Plan ergänzen)
1. Kategorie gesetzt, Checkbox aus: nur exakte Kategorie.
2. Kategorie gesetzt, Checkbox an: Kategorie + Unterkategorien.
3. Checkbox umschalten: Ergebnisliste aktualisiert sich ohne manuellen Such-Button.
4. Kategorie auf `<Alle Kategorien>`: Checkbox deaktiviert, kein Kategorie-Matchfilter aktiv.
5. Kombination mit anderem Filter (z. B. Zeitraum): Ergebnis entspricht AND-Verknüpfung.
6. Kategorie auf `<nicht zugeordnet>`: nur Umsätze ohne zugeordnete Kategorie.

## Annahmen
1. Z2.1 ändert nur die Kategorie-Auswahl-UI, nicht die bestehende Reload-/Filterlogik.
2. Bestehender Debounce/Delayed-Listener bleibt unverändert aktiv.

## Z2.1 Ist-Stand (umgesetzt)
1. Das lange Kategorie-Dropdown wurde ersetzt durch ein read-only Anzeigefeld mit `...`-Button.
2. Die Auswahl erfolgt über das bestehende Muster aus dem Dialog „Auswahl der Kategorie“.
3. Pseudokategorien sind verfügbar:
   - `<Alle Kategorien>`
   - `<nicht zugeordnet>`
4. Die Anzeige nutzt einen gekürzten Pfad mit sichtbarem Basename.
5. Filterlogik bleibt unverändert:
   - AND-Verknüpfung mit den übrigen Filtern
   - Auto-Reload über den bestehenden Listener-Mechanismus
   - bestehende Checkbox-Semantik für Unterkategorien bleibt erhalten

## Z2.1 Testabnahme
1. Testmodus: interaktiv.
2. Ergebnis: alle Testfälle erfolgreich.
3. Geprüft:
   - exakte Kategorie (Checkbox aus)
   - Kategorie plus Unterkategorien (Checkbox an)
   - `<Alle Kategorien>`
   - `<nicht zugeordnet>`
   - AND-Kombinationen mit Zeitraum/Suchbegriff
   - Auto-Reload ohne separaten Such-Button
   - Regression der übrigen Filterfunktionen

## PR-Readiness (Z2.1)
1. Geänderte Datei:
   - `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/KontoauszugList.java`
2. Leitplanken erfüllt:
   - keine DB-Änderung
   - keine Matching-Änderung
   - keine Encoding-Migration
3. Hinweis:
   - `hibiscus/.project` bleibt bewusst unstaged und außerhalb des Z2.1-PR-Scope.

## PR-Struktur / Autarkie (Review-Follow-up)
1. Feststellung:
   - `Z2.1` war PR-seitig bereits autark.
   - `Z2.2` und `Z2.3` waren branch-seitig gestapelt (nicht autark gegen `master`).
2. Ziel:
   - alle Z2-PRs autark gegen `master` / `upstream/master`.
3. Strategie:
   - `Z2.2` und `Z2.3` Branches neu zuschneiden und die bestehenden PRs `#151` und `#152` per `--force-with-lease` aktualisieren.
4. Hinweis:
   - Die PRs wurden vorübergehend auf `Draft` gesetzt (On Hold).

## PR-Struktur / Autarkie (Ist-Stand)
1. Umsetzung erfolgt:
   - PR `#150` (`Z2.1`) ist autark gegen `master`.
   - PR `#151` (`Z2.2`) ist autark gegen `master` und enthaelt nur `UmsatzDetailControl`.
   - PR `#152` (`Z2.3`) ist autark gegen `master` und enthaelt nur `UmsatzTypControl`.
2. Dialog-Positionierung wurde ausgelagert:
   - neuer Draft-PR `#154` (`Z2.4`) mit nur `UmsatzTypListDialog`.
3. Kommunikation:
   - In den PRs `#150` bis `#152` wurden Kommentare zum Autarkie-Neuzuschnitt hinterlegt.

## Z2.2 Plan (Umsatz-Detailansicht: Feld "Kategorie")
1. Ziel:
   - Die lange Dropdown-Auswahl im Feld `Kategorie` der Umsatz-Detailansicht wird UI-seitig analog zu Z2.1 verbessert.
   - Bedienmuster: read-only Anzeigefeld plus `...`-Button und Dialog "Auswahl der Kategorie".
2. Scope:
   - In Scope: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`.
   - Out of Scope: DB, Matching-Logik, weitere Views/Controller, Encoding.
3. Wichtige Abweichung zu Z2.1:
   - Kein Sonderfall `<nicht zugeordnet>` als zusätzlicher UI-Eintrag.
4. Umsetzung:
   - Bisheriges `UmsatzTypInput` im Feld `Kategorie` durch lokales read-only Input mit `...` ersetzen.
   - `...` öffnet `UmsatzTypListDialog` unter Beibehaltung der bisherigen Typ-Filterlogik.
   - Null-/Leerfall bleibt fachlich als "keine Kategorie" möglich.
   - Pfadanzeige wie bei Z2.1 gekürzt, Basename bleibt sichtbar.
5. Invarianten:
   - Speichern bleibt unverändert über `u.setUmsatzTyp((UmsatzTyp)getUmsatzTyp().getValue())`.
   - Disable-Regel bei `Umsatz.FLAG_NOTBOOKED` bleibt unverändert.
   - Keine Änderung an fachlicher Zuordnung/Filterung.
6. Testfälle:
   - Kategorie ändern bei bereits zugeordnetem Umsatz.
   - Kategorie setzen bei bislang leerer Kategorie.
   - Kategorie entfernen (`null`) und speichern.
   - Kein `<nicht zugeordnet>`-Sonderpunkt sichtbar.
   - Notbooked-Umsatz bleibt nicht editierbar.
   - Regressionstest: übrige Felder/Speichern unverändert.
7. PR-Readiness (Z2.2):
   - Erwartete Ziel-Dateien:
     - `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`
   - Leitplanken: keine DB-Änderung, keine Matching-Änderung, keine Encoding-Migration.
   - Hinweis für PR-Autarkie:
     - Die Dialog-Positionierung in `UmsatzTypListDialog.java` wird in `Z2.4` ausgelagert.

## Z2.2 Ist-Stand (umgesetzt)
1. Das Kategorie-Feld in der Umsatz-Detailansicht wurde von langem Dropdown auf read-only Anzeigefeld mit `...`-Button umgestellt.
2. Die Auswahl erfolgt über den bestehenden Dialog „Auswahl der Kategorie“.
3. Kein zusätzlicher Sonderpunkt `<nicht zugeordnet>` in Z2.2.
4. Null-/Leerfall bleibt fachlich als „keine Kategorie“ möglich.
5. Die Anzeige nutzt einen gekürzten Pfad mit sichtbarem Basename.
6. Zusätzliche Usability-Verbesserung im Dialog (ursprünglich in Z2.2 mit umgesetzt):
   - bei vorausgewählter Kategorie wird auf die markierte Zeile positioniert (Scroll-Position wird gesetzt).
   - diese Dialog-Positionierung wird für autarke PR-Zuschnitte als eigenes Sub-Ziel `Z2.4` geführt.
7. Fachliche Logik bleibt unverändert:
   - Speicherung weiterhin über `setUmsatzTyp(...)`
   - Disable-Verhalten bei `Umsatz.FLAG_NOTBOOKED` unverändert

## Z2.2 Testabnahme
1. Testmodus: interaktiv.
2. Ergebnis: alle Testfälle erfolgreich.
3. Geprüft:
   - Kategorie ändern bei bereits zugeordnetem Umsatz
   - Kategorie setzen bei leerer Kategorie
   - Kategorie entfernen (`Keine Kategorie`)
   - kein `<nicht zugeordnet>`-Sonderpunkt in Z2.2
   - Feld bei `FLAG_NOTBOOKED` weiterhin nicht editierbar
   - Dialog positioniert auf die vorausgewählte Kategorie
   - Regression: Speichern/Zurück und übrige Felder unverändert

## Z2.3 Plan (Umsatzkategorie-Detail: Feld "Übergeordnete Kategorie")
1. Ziel:
   - Das lange Dropdown im Feld `Übergeordnete Kategorie` wird analog zu Z2.2 durch ein read-only Anzeigefeld mit `...`-Button ersetzt.
   - Die Auswahl erfolgt über den bestehenden Dialog „Auswahl der Kategorie“.
2. Scope:
   - In Scope: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzTypControl.java`.
   - Out of Scope: DB, Matching-Logik, weitere Views/Controller, Encoding.
3. Wichtige Abweichung:
   - Kein zusätzlicher Sonderpunkt `<nicht zugeordnet>`.
4. Umsetzung:
   - Bisheriges `UmsatzTypInput` in `getParent()` durch lokales read-only Input mit `...` ersetzen.
   - `...` öffnet `UmsatzTypListDialog` mit bestehender Vorauswahl.
   - Null-/Leerfall bleibt über „Keine Kategorie“ möglich.
   - Anzeige als gekürzter Pfad mit sichtbarem Basename.
5. Invarianten:
   - Speichern bleibt unverändert über `ut.setParent((UmsatzTyp)getParent().getValue())`.
   - Schutz vor Selbstreferenz bleibt erhalten.
   - Keine Änderung an fachlicher Zuordnung oder Persistenz.
6. Testfälle:
   - Parent ändern und speichern.
   - Parent entfernen (`Keine Kategorie`) und speichern.
   - Kein `<nicht zugeordnet>`-Sonderpunkt sichtbar.
   - Selbstreferenz weiterhin ausgeschlossen.
   - Regressionstest: übrige Felder/Speichern unverändert.
7. Akzeptanzkriterien:
   - Lange Dropdown-Navigation entfällt im Feld „Übergeordnete Kategorie“.
   - Auswahl über Dialog stabil.
   - Fachliches Verhalten unverändert.
8. PR-Readiness (Z2.3):
   - Erwartete Ziel-Datei: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzTypControl.java`.
   - Leitplanken: keine DB-Änderung, keine Matching-Änderung, keine Encoding-Migration.

## Z2.3 Ist-Stand (umgesetzt)
1. Das Feld „Übergeordnete Kategorie“ wurde von langem Dropdown auf read-only Anzeigefeld mit `...`-Button umgestellt.
2. Die Auswahl erfolgt über den bestehenden Dialog „Auswahl der Kategorie“.
3. Kein zusätzlicher Sonderpunkt `<nicht zugeordnet>` in Z2.3.
4. Null-/Leerfall bleibt fachlich über „Keine Kategorie“ möglich.
5. Die Anzeige nutzt einen gekürzten Pfad mit sichtbarem Basename.
6. Die bestehende Dialog-Positionierung auf die vorausgewählte Kategorie wird mitgenutzt (UX-Komfort).
   - Z2.3 ist funktional nicht hart davon abhängig, da der Dialog weiterhin über den bestehenden `preselected`-Parameter arbeitet (keine Signaturänderung).
   - Die Positionierung wird für autarke PR-Zuschnitte als separates Sub-Ziel `Z2.4` geführt.
7. Fachliche Logik bleibt unverändert:
   - Speicherung weiterhin über `setParent(...)`
   - bestehender Schutz vor Selbstauswahl bleibt erhalten (inkl. bestehender Meldung beim Speichern)

## Z2.3 Testabnahme
1. Testmodus: interaktiv.
2. Ergebnis: alle Testfälle erfolgreich.
3. Geprüft:
   - Parent ändern und speichern
   - Parent entfernen (`Keine Kategorie`) und speichern
   - kein `<nicht zugeordnet>`-Sonderpunkt
   - Selbstauswahl wird weiterhin abgefangen
   - Dialog positioniert auf die vorausgewählte Kategorie
   - Regression: übrige Felder/Speichern unverändert

## PR-Readiness (Z2.3)
1. Geänderte Datei:
   - `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzTypControl.java`
2. Leitplanken erfüllt:
   - keine DB-Änderung
   - keine Matching-Änderung
   - keine Encoding-Migration
3. Hinweis:
   - `hibiscus/.project` bleibt bewusst unstaged und außerhalb des Z2.3-PR-Scope.
   - Dialog-Positionierung in `UmsatzTypListDialog.java` wird in `Z2.4` ausgelagert.

## Z2.4 Plan (Dialog "Auswahl der Kategorie": Positionierung auf Vorauswahl)
1. Ziel:
   - Im Dialog „Auswahl der Kategorie“ wird bei vorhandener Vorauswahl die markierte Zeile sichtbar positioniert.
2. Scope:
   - In Scope: `hibiscus/src/de/willuhn/jameica/hbci/gui/dialogs/UmsatzTypListDialog.java`
   - Out of Scope: Controller-Umstellungen in Z2.1/Z2.2/Z2.3, DB, Matching, Encoding
3. Umsetzung:
   - bestehende Vorauswahl (`preselected`) weiterverwenden
   - nach `select(...)` die Tabellenansicht auf die ausgewählte Zeile positionieren (`setTopIndex(...)`)
4. API/Kompatibilität:
   - keine neue API
   - keine Signaturänderung
   - bestehender Konstruktor `UmsatzTypListDialog(int position, UmsatzTyp preselected, int typ)` bleibt unverändert
5. Testfälle:
   - Dialog mit Vorauswahl öffnet mit sichtbarer markierter Zeile
   - Dialog ohne Vorauswahl unverändert
   - kein Verhaltensbruch bei Suche/Checkbox/Übernehmen/Abbrechen
6. PR-Readiness (Z2.4 / PR6):
   - Erwartete Ziel-Datei:
     - `hibiscus/src/de/willuhn/jameica/hbci/gui/dialogs/UmsatzTypListDialog.java`
   - Leitplanken: keine DB-Änderung, keine Matching-Änderung, keine Encoding-Migration
