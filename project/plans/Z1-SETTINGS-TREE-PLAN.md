# Z1-SETTINGS-TREE Plan

## Scope
`Datei -> Einstellungen -> Tab Umsatz-Kategorien`

## Ziele
- Filterfeld über Baum
- Expand/Collapse

## Ist-Zustand (Analyse)
1. Der Tab `Umsatz-Kategorien` wird in `hibiscus/src/de/willuhn/jameica/hbci/gui/views/Settings.java` aufgebaut und rendert den Baum via `control.getUmsatzTypTree().paint(...)`.
2. Der Tree kommt aus `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/SettingsControl.java` als `new UmsatzTypTree(new UmsatzTypNew())`.
3. Die konkrete Komponente ist `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/UmsatzTypTree.java` (basierend auf `jameica/src/de/willuhn/jameica/gui/parts/TreePart.java`).
4. Bereits vorhanden:
- Mehrspaltiger Baum mit Kontextmenü und Persistenz für Spalten/Sortierung/State.
- Rekursives Expand/Collapse ist technisch in `TreePart` vorhanden (`setExpanded(..., recursive=true)`), wird im Settings-Tab aber noch nicht per Button angeboten.
5. Wichtige Nebenbedingung:
- Kontextmenü-Aktionen erwarten `UmsatzTyp`-Objekte (`hibiscus/src/de/willuhn/jameica/hbci/gui/menus/UmsatzTypList.java`).

## Referenzmuster für Filter
1. Der Dialog `hibiscus/src/de/willuhn/jameica/hbci/gui/dialogs/UmsatzTypListDialog.java` enthält ein Suchfeld + verzögerte Aktualisierung + Teilbaum-Logik (Treffer plus optional Unterkategorien).
2. Dieses Muster ist fachlich passend als UX-Vorbild, nutzt aber Tabelle statt Baum.

## Minimalinvasiver Ansatz (für Umsetzung)
1. `Settings` ergänzt oberhalb des Baums ein `TextInput` plus zwei Buttons `Alles einklappen`/`Alles ausklappen`.
2. `UmsatzTypTree` wird um UI-seitigen Filterzustand und Refresh erweitert (ohne DB-Schema- oder Matching-Änderung).
3. Expand/Collapse nutzt bestehende `TreePart`-Mechanik über Root-Items und rekursives Setzen.
4. Filter arbeitet rein auf Anzeigeebene; fachliche Zuordnung/Matching bleibt unverändert.

## Risiken
1. Wenn für Filter ein Wrapper-Datentyp verwendet wird, müssen Selektions-/Kontextobjekte weiter als `UmsatzTyp` an Aktionen durchgereicht werden.
2. Bei sehr großen Bäumen kann aggressives Neuladen pro Tastendruck teuer werden; daher verzögerte Suche (`DelayedListener`) einplanen.

## Offene Entscheidungen
1. Filter-Semantik final:
- A: nur Treffer + Pfad (ohne automatische Unterkategorien)
- B: Treffer + Pfad + Unterkategorien analog Dialog
2. Optionaler UX-Punkt: dedizierter `X`-Reset-Button oder nur Leeren des Textfelds.
