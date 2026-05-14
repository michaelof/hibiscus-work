# UK1-SICHERHEITSABFRAGE-LOESCHEN ToDo

## Basisstand
- [x] Vor UK1-Refactoring den aktuellen Stand von `origin/master` fetchen und als Basis verwenden

- [x] Ist-Verhalten der Loeschabfrage dokumentieren
- [x] Erkennung von Zuordnungen fuer Einzel- und Mehrfachauswahl spezifizieren
- [x] Spezialwarntext fuer Einzel-/Mehrfachfall festlegen
- [x] Standarddialog fuer alle anderen Faelle unveraendert lassen
- [x] Interaktive Tests durchfuehren (Einzel/Mehrfach, mit/ohne Zuordnung)
- [x] PR-Readiness dokumentieren (nur UI/Action, keine DB/Matching/Encoding)

## Follow-up nach Review (Olaf)
- [x] UK1-Implementierung architektonisch bereinigen: `UmsatzTypDelete` statt UmsatzTyp-Sonderlogik in `DBObjectDelete`
- [x] Kontextmenue `UmsatzTypList` auf `UmsatzTypDelete` umstellen
- [ ] Regressionstest fuer Loeschwarnung nach Refactoring
- [x] PR #153 nach Refactoring aktualisieren (Draft bleibt bis zum finalen Sammel-Review gesetzt)
