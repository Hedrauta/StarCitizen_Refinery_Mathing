# RefinerySlotCombiner

RefinerySlotCombiner ist ein zweiteiliges Script für erfahrene Benutzer, das Kenntnisse in MySQL sowie die Installation von Paketen voraussetzt. Es ermöglicht Benutzern, ihre Raffinerie-Slots aus dem Spiel Star Citizen einzutragen und verschiedene Kombinationen dieser Slots zu errechnen.

## Inhaltsverzeichnis
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Nutzung](#nutzung)
- [Lizenz](#lizenz)
- [Beiträge](#beiträge)
- [Kontakt](#kontakt)

## Voraussetzungen

### Python
- `mysql.connector`

### PowerShell
- MySQL Connector Net 8.4

## Installation

1. **Connector auf beiden Seiten bereitstellen:**
   - Installiere den MySQL Connector für Python (`mysql.connector`).
   - Installiere MySQL Connector Net 8.4 für PowerShell.

2. **MySQL-Datenbank einrichten:**
   - Richte eine MySQL-Datenbank auf der Python-Seite ein und stelle den Nutzern Zugang bereit.
   - Die Struktur-SQL-Datei für die Tabellen ist in [SC_Ref.sql](SC_Ref.sql) vorhanden.

3. **Zugangsdaten anpassen:**
   - Passen Sie die Zugangsdaten in der Python-Seite an und starten Sie das Python-Script.
   - Die Zugangsdaten der PowerShell-Seite befinden sich in einer separaten Datei (MySQL-server.json) . Das Passwort für den Zugang wird separat abgefragt und verschlüsselt gespeichert.

4. **Hinweis zu Powershell:**
   - Möglicherweise muss die ExecutionPolicy in Powershell angepasst werden, da der Zugriff auf die benötigte DLL für den MySQL-Connector dadurch gestört werden kann.

## Nutzung

Nach der Installation ist das Script selbsterklärend, wenn es gestartet wird. Der Benutzer kann mit der PowerShell-Seite des Scripts ähnlich wie mit einem MySQL-Client seine Raffinerie-Slots eintragen. Die Python-Seite errechnet serverseitig verschiedene Kombinationen aus diesen Slots.

## Lizenz

Dieses Projekt steht unter der [MIT-Lizenz](LICENSE).

## Beiträge

Beiträge zum Projekt sind willkommen. Bitte stelle sicher, dass du eine ausführliche Beschreibung der Änderung beifügst.

## Kontakt

Für Fragen oder Unterstützung kannst du mich über Discord erreichen: `h3draut3r`

