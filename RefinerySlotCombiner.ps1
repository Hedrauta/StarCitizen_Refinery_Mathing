"1722765935" | Out-Null
$sum_c = 46
$undone = $false
Add-Type -Path 'C:\Program Files (x86)\MySQL\MySQL Connector NET 8.4\MySql.Data.dll'
$sqld = Get-Content .\mysql-server.json | ConvertFrom-Json
[string] $PasswordFile = ".\\password.txt"
$MyConnection = New-Object MySql.Data.MySqlClient.MySqlConnection

if (!(Test-Path -Path $PasswordFile)) {
    $securePassword = Read-Host "Bitte gebe das Passwort der SQL-Verbindung ein:" -AsSecureString
    $securePassword | ConvertFrom-SecureString | Out-File $PasswordFile
} else {
    $securePassword = Get-Content $PasswordFile | ConvertTo-SecureString
}
$credentials = New-Object System.Management.Automation.PSCredential ($($sqld.User), $securePassword)

$MyConnection.ConnectionString = "server=$($sqld.Server);port=$($sqld.Port);uid=$($sqld.User);pwd=$($credentials.GetNetworkCredential().Password);database=$($sqld.Database)"
# Verbindung testen
$MyConnection.Open()
$MyConnection.Close()

# Funktionen definieren
function script_update() {
    $req = Invoke-WebRequest -Uri https://raw.githubusercontent.com/Hedrauta/StarCitizen_Refinery_Mathing/main/RefinerySlotCombiner.ps1
    $latest_version = [int]$($($req.Content)[1..10] -join "")
    $current_version = [int]$($(Get-Content $PSCommandPath)[0][1..10] -join "")
    if ($latest_version -gt $current_version) {
        $loop = $true
        while ($loop) {
            "Ein Update ist verfügbar."
            $rs = Read-Host "Möchtest du es installieren? [J/N]:"
            if ($rs.ToLower() -eq "n") {
                $loop = $false
            } elseif ($rs.ToLower() -eq "j") {
                Set-Content $PSCommandPath -Value $req.Content
                "Script geupdated, bitte erneut starten!"
                Pause
                exit
            }
        }
    }
}
function sql_sel($table, $column) {
    $col_string = $column -join (', ')
    $resultArray = @()

    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            return
        }

        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT $col_string FROM $($sqld.Database).$table;", $script:MyConnection)
        $result = $command.ExecuteReader()
        $counter = 1
        while ($result.Read()) {
            $row = @{}
            if ($table -ne "combinations" -and $table -ne "timestamps") {
                $row["Raf.-Slot"] = $counter
            }
            for ($i = 0; $i -lt $result.FieldCount; $i++) {
                $row[$result.GetName($i)] = $result.GetValue($i)
            }
            $counter++
            $resultArray += $row
        }
        $result.Close()
    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
        }
    }

    return $resultArray
}
function sql_com_sel_lim($summax) {
    $resultArray = @()
    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            Pause
            return
        }
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT * FROM combinations WHERE SCU<=$summax ORDER BY SCU DESC, DbID LIMIT 10;", $script:MyConnection)
        $result = $command.ExecuteReader()
        $counter = 1
        while ($result.Read()) {
            $row = @{}
            if ($table -ne "combinations" -and $table -ne "timestamps") {
                $row["Raf.-Slot"] = $counter
            }
            for ($i = 0; $i -lt $result.FieldCount; $i++) {
                $row[$result.GetName($i)] = $result.GetValue($i)
            }
            $counter++
            $resultArray += $row
        }
        $result.Close()
    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
        }
    }

    return $resultArray
}
function sql_com_d_sel_lim($summax) {
    $resultArray = @()
    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            Pause
            return
        }
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT * FROM combi_done WHERE SCU<=$summax ORDER BY SCU DESC, DbID LIMIT 10;", $script:MyConnection)
        $result = $command.ExecuteReader()
        $counter = 1
        while ($result.Read()) {
            $row = @{}
            if ($table -ne "combinations" -and $table -ne "timestamps") {
                $row["Raf.-Slot"] = $counter
            }
            for ($i = 0; $i -lt $result.FieldCount; $i++) {
                $row[$result.GetName($i)] = $result.GetValue($i)
            }
            $counter++
            $resultArray += $row
        }
        $result.Close()
    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
        }
    }

    return $resultArray
}
function sql_ins($table, $column, $values) {
    $col_string = $column -join (', ')
    $val_string = $values -join (', ')

    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            Pause
            return
        }

        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("INSERT INTO $($sqld.Database).$table ($col_string) VALUES ($val_string);", $script:MyConnection)
        $result = $command.ExecuteReader()
        $result.Close()

    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
            Write-Host "Werte eingetragen"
        }
    }
}
function sql_tru($table) {
    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            Pause
            return
        }

        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("TRUNCATE TABLE $($sqld.Database).$table;", $script:MyConnection)
        $result = $command.ExecuteReader()
        $result.Close()

    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
            Write-Host "Tabelle $table geleert"
        }
    }
}
function sql_del($table, $id) {
    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            Pause
            return
        }

        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("DELETE FROM $($sqld.Database).$table WHERE DbID=$id;", $script:MyConnection)
        $result = $command.ExecuteReader()
        $result.Close()

    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
            Write-Host "Eintrag $id aus $table entfert"
        }
    }
}
function sql_upd_t() {
    try {
        $script:MyConnection.Open()
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
        } else {
            Write-Host "Verbindung konnte nicht geöffnet werden."
            Pause
            return
        }
        $time = Get-Date -UFormat %s
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand("UPDATE $($sqld.Database).timestamps SET last_entry = $time", $script:MyConnection)
        $command.ExecuteNonQuery() | Out-Null

    } catch {
        Write-Error "Es ist ein Fehler aufgetreten: $_"
    } finally {
        if ($MyConnection.State -eq [System.Data.ConnectionState]::Open) {
            $MyConnection.Close()
            Write-Host "Zeitstempel geupdated"
        }
    }
}
function ConvertFrom-HashTable {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.IDictionary] $HashTable
    )
    process {
        $oht = [ordered] @{} # Aux. ordered hashtable for collecting property values.
        foreach ($entry in $HashTable.GetEnumerator()) {
            if ($entry.Value -is [System.Collections.IDictionary]) {
                # Nested dictionary? Recurse.
                $oht[[object] $entry.Key] = ConvertFrom-HashTable -HashTable $entry.Value # NOTE: Casting to [object] prevents problems with *numeric* hashtable keys.
            } else {
                # Copy value as-is.
                $oht[[object] $entry.Key] = $entry.Value
            }
        }
        [pscustomobject] $oht # Convert to [pscustomobject] and output.
    }
}

$script:prices_req = $null
$script:prices = $null
function update_prices() {
    #Keine Daten > Updaten
    if ($null -eq $script:prices_req) {
        $script:prices_req = Invoke-WebRequest -Uri https://uexcorp.space/api/2.0/commodities_prices_all
        $script:prices = $($script:prices_req.Content | ConvertFrom-Json).Data
    }
    #Wenn Daten älter als 30 minuten, updaten
    elseif (($(Get-Date -UFormat %s) - $($($([DateTimeOffset]::parseexact($script:prices_req.Headers.Date, "ddd, dd MMM yyyy HH:mm:ss 'GMT'", $(New-Object System.Globalization.CultureInfo("en-uk")))).AddHours(2)).ToUnixTimeSeconds()) -ge 1800)) {
        $script:prices_req = Invoke-WebRequest -Uri https://uexcorp.space/api/2.0/commodities_prices_all
        $script:prices = $($script:prices_req.Content | ConvertFrom-Json).Data
    }
    
}
#Script-Update-Check
script_update

Clear-Host
# Loop starten
While ($True) {
    "Hauptmenü"
    "Verfügbare Optionen:"
    "--------------------------------"
    "Raffinerie"
    "E = RaffinerieSlot eintragen"
    "L = RaffinerieSlot entfernen"
    "A = RaffinerieSlots anzeigen"
    "--------------------------------"
    "Touren"
    "C = Kombinationen"
    ""; ""
    
    $option = Read-Host "Option wählen:"
    Clear-Host
    if ($option.ToLower() -eq "e") {
        while ($option.ToLower() -eq "e") {
            $reset = $true
            "Raffinerie-Slot eintragen gewählt"
            $data = New-Object psobject
            $data | Add-Member -MemberType NoteProperty -Name 'Quantanium' -Value 0
            $data | Add-Member -MemberType NoteProperty -Name 'Gold' -Value 0
            $data | Add-Member -MemberType NoteProperty -Name 'Bexalite' -Value 0
            $data | Add-Member -MemberType NoteProperty -Name 'Taranite' -Value 0
            $data | Add-Member -MemberType NoteProperty -Name 'DateFin' -Value $(Get-Date)
            $current_time = $(Get-Date -UFormat %s)
            $data_value = @(0, 0, 0, 0, $current_time)
            $data_order = @("Quantanium", "Gold", "Bexalite", "Taranite", "DateFin")
            while ($reset) {
                Clear-Host
                "Raffinerie-Slot eintragen"
                "--------------------------"
                "Verfügbare Optionen:"
                "Q = Quantanium"
                "G = Gold"
                "B = Bexalite"
                "T = Taranite"
                "D = Zeit der Fertigstellung ändern"
                "--------------------------"
                "E = Eintragen"
                "L = Liste leeren"
                "Z = Zurück ins Hauptmenü"
                "--------------------------"
                "Aktuelle Liste:"
                $data | Format-Table Quantanium, Gold, Bexalite, Taranite, @{Name="Finished Date";Expression={$_.DateFin.ToString("dd.MM.yyyy HH:mm")}}
                ""
                Start-Sleep -Milliseconds 200
                ""
                $rs = Read-Host "Option wählen:"
                [int]$rs_value = 0
                if ($rs.ToLower() -eq 'q') {
                    "Quantanium ausgewählt."
                    [int]$rs_value = Read-Host "Wert in cSCU angeben (ohne Buchstaben):"
                    $data.Quantanium = $rs_value
                    $data_value[0] = $rs_value
                } elseif ($rs.ToLower() -eq 'g') {
                    "Gold ausgewählt."
                    [int]$rs_value = Read-Host "Wert in cSCU angeben (ohne Buchstaben):"
                    $data.Gold = $rs_value
                    $data_value[1] = $rs_value
                } elseif ($rs.ToLower() -eq 'b') {
                    "Bexalite ausgewählt."
                    [int]$rs_value = Read-Host "Wert in cSCU angeben (ohne Buchstaben):"
                    $data.Bexalite = $rs_value
                    $data_value[2] = $rs_value
                } elseif ($rs.ToLower() -eq 't') {
                    "Taranite ausgewählt."
                    [int]$rs_value = Read-Host "Wert in cSCU angeben (ohne Buchstaben):"
                    $data.Taranite = $rs_value
                    $data_value[3] = $rs_value
                } elseif ($rs.ToLower() -eq 'd') {
                    $d = $true
                    while ($d) {
                        Clear-Host
                        "Zeit der Fertigstellung ändern."
                        "H = Dauer in Stunden"
                        "M = Dauer in Minuten"
                        "-------------------------"
                        "Aktuelle Fertigstellung"
                        "$($data.DateFin.ToString("dd.MM.yyyy HH:mm"))"
                        "-------------------------"
                        "Z = Zurück zur Liste";""
                        "-------------------------"
                        "Wähle die nächste Aktion, und trage danach den Wert ein"
                        "Dieser Wert kann auch negativ sein"
                        "(H, gefolgt von -1 = 1 Tag in der Vergangenheit)"
                        $read_t = Read-Host "Aktion:"
                        if ($read_t.ToLower() -eq 'h') {
                            $read_d = Read-Host "Dauer in Stunden:"
                            $data.DateFin = $data.DateFin.AddHours($read_d)
                        } elseif ($read_t.ToLower() -eq 'm') {
                            $read_d = Read-Host "Dauer in Minuten:"
                            $data.DateFin = $data.DateFin.AddMinutes($read_d)
                        } elseif ($read_t.ToLower() -eq 'z') {
                            $data_value[4] = [int][double]($data.DateFin.ToUniversalTime() - [DateTime]::UnixEpoch).TotalSeconds
                            $d = $false
                        }
                    }

                }
                elseif ($rs.ToLower() -eq 'e') {
                    "Werte eintragen..."; ""
                    sql_ins "refinery" $data_order $data_value
                    ""
                    $q = $true
                    while ($q) {
                        $res = Read-Host "Neuen Eintrag? [J/N]"
                        if ($res.ToLower() -eq 'j') {
                            $data_value = @(0, 0, 0, 0)
                            $data.Quantanium = $data.Bexalite = $data.Gold = $data.Taranite = 0
                            $q = $false
                        } elseif ($res.ToLower() -eq "n") {
                            sql_upd_t
                            $reset = $false
                            $option = ""
                            $q = $fals
                        }
                    }
                } elseif ($rs.ToLower() -eq "l") {
                    $data_value = @(0, 0, 0, 0)
                    $data.Quantanium = $data.Bexalite = $data.Gold = $data.Taranite = 0
                } elseif ($rs.ToLower() -eq "z") {
                    sql_upd_t
                    $reset = $false
                    $option = ""
                }
            }
            
        }
        Clear-Host
    } elseif ($option.ToLower() -eq "l") {
        while ($option.ToLower() -eq "l") {
            $reset = $true
            Clear-Host
            sql_sel "refinery" "*" | ConvertFrom-HashTable | Select-Object DbID, Quantanium, Gold, Bexalite, Taranite, Raf.-Slot | Format-Table
            ""
            Start-Sleep -Milliseconds 400
            "--------------------------------"
            "A = Alles löschen"
            "Z = Zurück zum Hauptmenü"
            $rs = Read-Host "Wähle die DbID, welchen du enfernen möchtest:"
            if ($rs.ToLower() -ne "z" -and $rs.ToLower() -ne "a" -and [int]$rs -is [int]) {
                sql_del "refinery" $rs
                while ($reset) {
                    $res = Read-Host "Möchtest du noch einen Eintrag entfernen? [J/N]"
                    if ($res.ToLower() -eq "j") {
                        $reset = $false
                    } elseif ($res.ToLower() -eq "n") {
                        sql_upd_t
                        $option = ""
                        $reset = $false
                    }
                }
            } elseif ($rs.ToLower() -eq "z") {
                sql_upd_t
                $option = ""
            } elseif ($rs.ToLower() -eq "a") {
                "Es werden ALLE Raffinery-Einträge aus der Datenbank entfernt"
                $rsl = Read-Host "Bist du dir sicher?[J/N]"
                if ($rsl.ToLower() -eq "j") {
                    sql_tru "refinery"
                    sql_tru "combinations"
                    sql_upd_t
                    "---------------------"
                    Start-Sleep -Seconds 2
                    $option = ""
                    $reset = $false
                }
            }
        }
        Clear-Host
    } elseif ($option.ToLower() -eq "a") {
        $ref_table = sql_sel "refinery" "*"
        $math_table = sql_sel "Maths" "*"
        update_prices
        $sum_min = $sum_max = 0
        $prices_quan = $prices | Where-Object { $_.commodity_name -eq "Quantanium" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 21500 }
        $prices_gold = $prices | Where-Object { $_.commodity_name -eq "Gold" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 7000 }
        $prices_bexa = $prices | Where-Object { $_.commodity_name -eq "Bexalite" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 7000 }
        $prices_tara = $prices | Where-Object { $_.commodity_name -eq "Taranite" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 7000 }

        $price_quan = $prices_quan | Measure-Object -Property price_sell -AllStats
        $price_gold = $prices_gold | Measure-Object -Property price_sell -AllStats
        $price_bexa = $prices_bexa | Measure-Object -Property price_sell -AllStats
        $price_tara = $prices_tara | Measure-Object -Property price_sell -AllStats
        if ($ref_table.Length -gt 1) {
            for ($i = 0; $i -lt $ref_table.Length; $i++) {
                $ref_table[$i]['wmi'] = [Int][Math]::Floor(($math_table[$i].Quantanium * $price_quan.Minimum) + ($math_table[$i].Gold * $price_gold.Minimum) + ($math_table[$i].Bexalite * $price_bexa.Minimum) + ($math_table[$i].Taranite * $price_tara.Minimum))
                $ref_table[$i]['Wert_min'] = "{0:N0}" -f $ref_table[$i].wmi
                $sum_min += $ref_table[$i].wmi
                $ref_table[$i]['wma'] = [Int][Math]::Floor(($math_table[$i].Quantanium * $price_quan.Maximum) + ($math_table[$i].Gold * $price_gold.Maximum) + ($math_table[$i].Bexalite * $price_bexa.Maximum) + ($math_table[$i].Taranite * $price_tara.Maximum))
                $ref_table[$i]['Wert_max'] = "{0:N0}" -f $ref_table[$i].wma
                $sum_max += $ref_table[$i].wma
            }
        } elseif ($ref_table.Length -eq 1) {
            $ref_table['wmi'] = [Int][Math]::Floor(($math_table.Quantanium * $price_quan.Minimum) + ($math_table.Gold * $price_gold.Minimum) + ($math_table.Bexalite * $price_bexa.Minimum) + ($math_table.Taranite * $price_tara.Minimum))
            $ref_table['Wert_min'] = "{0:N0}" -f $ref_table.wmi
            $sum_min = $ref_table.wmi
            $ref_table['wma'] = [Int][Math]::Floor(($math_table.Quantanium * $price_quan.Maximum) + ($math_table.Gold * $price_gold.Maximum) + ($math_table.Bexalite * $price_bexa.Maximum) + ($math_table.Taranite * $price_tara.Maximum))
            $ref_table['Wert_max'] = "{0:N0}" -f $ref_table.wma
            $sum_max = $ref_table.wma
        }

        $ref_view = $ref_table | 
            ConvertFrom-HashTable | 
            Select-Object -Property Raf.-Slot, Quantanium, Gold, Bexalite, Taranite, Wert_min, Wert_max, DateFin | 
            Format-Table Raf.-Slot, Quantanium, Gold, Bexalite, Taranite, Wert_min, Wert_max, @{Name="Datum Ende"; Expression={[DateTime]::UnixEpoch.AddSeconds($_.DateFin)}}
        $ref_view
        Start-Sleep -Milliseconds 400
        "-------------------------"
        "Summenwert aller Raffinerie-Slots:"
        "Min: $("{0:N0}" -f $sum_min) aUEC"
        "Max: $("{0:N0}" -f $sum_max) aUEC"
        ""

        Pause
        Clear-Host
    } elseif ($option.ToLower() -eq "c") {
        $sum_c = 46
        while ($option.ToLower() -eq "c") {
            $com_table = if($undone) {sql_com_sel_lim $sum_c} else {sql_com_d_sel_lim $sum_c}
            $ref_table = sql_sel "refinery" "*"
            $times = sql_sel "timestamps" "*"
            Clear-Host
            "Kombinationen"
            "Nur die 10 ersten Einträge werden angezeigt"
            "Werte der Erze sind in SCU angegeben"
            "--------------------------------"
            if ($com_table.Length -gt 0 -and $times.last_combo -ge $times.last_entry) {
                $math_table = sql_sel "Maths" "*"
                update_prices

                $prices_quan = $prices | Where-Object { $_.commodity_name -eq "Quantanium" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 21500 }
                $prices_gold = $prices | Where-Object { $_.commodity_name -eq "Gold" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 7000 }
                $prices_bexa = $prices | Where-Object { $_.commodity_name -eq "Bexalite" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 7000 }
                $prices_tara = $prices | Where-Object { $_.commodity_name -eq "Taranite" -and $($(Get-Date -UFormat '%s') - $_.date_modified) -lt 604800 -and $_.status_sell -ge 1 -and $_.price_sell -ge 7000 }

                $price_quan = $prices_quan | Measure-Object -Property price_sell -AllStats
                $price_gold = $prices_gold | Measure-Object -Property price_sell -AllStats
                $price_bexa = $prices_bexa | Measure-Object -Property price_sell -AllStats
                $price_tara = $prices_tara | Measure-Object -Property price_sell -AllStats
                
                for ($i = 0; $i -lt $com_table.Length; $i++) {
                    $com_w_min = 0
                    $com_w_max = 0
                    $com_q = 0
                    $com_g = 0
                    $com_b = 0
                    $com_t = 0
                    #Wert für DbI1 errechnen
                    if ($com_table.Length -gt 1) { $math_q = $math_table | Where-Object { $_.DbID -eq $com_table[$i].DbI1 } }
                    else { $math_q = $math_table | Where-Object { $_.DbID -eq $com_table.DbI1 } }
                    $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                    $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                    $com_q += [int]($math_q.Quantanium)
                    $com_g += [int]($math_q.Gold)
                    $com_b += [int]($math_q.Bexalite)
                    $com_t += [int]($math_q.Taranite)
                    #Wert für DbI2 errechnen
                    if ($com_table.Length -gt 1) { $math_q = $math_table | Where-Object { $_.DbID -eq $com_table[$i].DbI2 } }
                    else { $math_q = $math_table | Where-Object { $_.DbID -eq $com_table.DbI2 } }
                    $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                    $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                    $com_num = 2
                    $com_q += [int]($math_q.Quantanium)
                    $com_g += [int]($math_q.Gold)
                    $com_b += [int]($math_q.Bexalite)
                    $com_t += [int]($math_q.Taranite)
                    #Wert für DbI3 errechnen, wenn vorhanden
                    if ($com_table.Length -gt 1) {
                        if (-not ("" -eq $com_table[$i].DbI3)) {
                            $math_q = $math_table | Where-Object { $_.DbID -eq $com_table[$i].DbI3 }
                            $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                            $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                            $com_num++
                            $com_q += [int]($math_q.Quantanium)
                            $com_g += [int]($math_q.Gold)
                            $com_b += [int]($math_q.Bexalite)
                            $com_t += [int]($math_q.Taranite)
                        }
                    } else {
                        if (-not ("" -eq $com_table.DbI3)) {
                            $math_q = $math_table | Where-Object { $_.DbID -eq $com_table.DbI3 }
                            $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                            $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                            $com_num++
                            $com_q += [int]($math_q.Quantanium)
                            $com_g += [int]($math_q.Gold)
                            $com_b += [int]($math_q.Bexalite)
                            $com_t += [int]($math_q.Taranite)
                        }
                    }
                    #Wert für DbI4 errechnen, wenn vorhanden
                    if ($com_table.Length -gt 1) {
                        if (-not ("" -eq $com_table[$i].DbI4)) {
                            $math_q = $math_table | Where-Object { $_.DbID -eq $com_table[$i].DbI4 }
                            $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                            $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                            $com_num++
                            $com_q += [int]($math_q.Quantanium)
                            $com_g += [int]($math_q.Gold)
                            $com_b += [int]($math_q.Bexalite)
                            $com_t += [int]($math_q.Taranite)
                        }
                    } else {
                        if (-not ("" -eq $com_table.DbI4)) {
                            $math_q = $math_table | Where-Object { $_.DbID -eq $com_table.DbI4 }
                            $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                            $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                            $com_num++
                            $com_q += [int]($math_q.Quantanium)
                            $com_g += [int]($math_q.Gold)
                            $com_b += [int]($math_q.Bexalite)
                            $com_t += [int]($math_q.Taranite)
                        }
                    }
                    #Wert für DbI5 errechnen, wenn vorhanden
                    if ($com_table.Length -gt 1) {
                        if (-not ("" -eq $com_table[$i].DbI5)) {
                            $math_q = $math_table | Where-Object { $_.DbID -eq $com_table[$i].DbI5 }
                            $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                            $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                            $com_num++
                            $com_q += [int]($math_q.Quantanium)
                            $com_g += [int]($math_q.Gold)
                            $com_b += [int]($math_q.Bexalite)
                            $com_t += [int]($math_q.Taranite)
                        }
                    } else {
                        if (-not ("" -eq $com_table.DbI5)) {
                            $math_q = $math_table | Where-Object { $_.DbID -eq $com_table.DbI5 }
                            $com_w_min += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Minimum) + ($math_q.Gold * $price_gold.Minimum) + ($math_q.Bexalite * $price_bexa.Minimum) + ($math_q.Taranite * $price_tara.Minimum))
                            $com_w_max += [Int][Math]::Floor(($math_q.Quantanium * $price_quan.Maximum) + ($math_q.Gold * $price_gold.Maximum) + ($math_q.Bexalite * $price_bexa.Maximum) + ($math_q.Taranite * $price_tara.Maximum))
                            $com_num++
                            $com_q += [int]($math_q.Quantanium)
                            $com_g += [int]($math_q.Gold)
                            $com_b += [int]($math_q.Bexalite)
                            $com_t += [int]($math_q.Taranite)
                        }
                    }
                    if ($com_table.Length -gt 1) {
                        $com_table[$i]["Wert_Min"] = "{0:N0}" -f [int]$com_w_min
                        $com_table[$i]["Wert_Max"] = "{0:N0}" -f [int]$com_w_max
                        $com_table[$i]["#Slots"] = [int]$com_num
                        $com_table[$i]["Quan"] = [int]$com_q
                        $com_table[$i]["Gold"] = [int]$com_g
                        $com_table[$i]["Bexa"] = [int]$com_b
                        $com_table[$i]["Tara"] = [int]$com_t
                    } else {
                        $com_table["Wert_Min"] = "{0:N0}" -f [int]$com_w_min
                        $com_table["Wert_Max"] = "{0:N0}" -f [int]$com_w_max
                        $com_table["#Slots"] = [int]$com_num
                        $com_table["Quan"] = [int]$com_q
                        $com_table["Gold"] = [int]$com_g
                        $com_table["Bexa"] = [int]$com_b
                        $com_table["Tara"] = [int]$com_t
                    }
                }
                $com_table | ConvertFrom-HashTable | Select-Object -Property DbID, Wert_Min, Wert_Max, SCU, '#Slots', Quan, Gold, Bexa, Tara | Format-Table
                "--------------------------------"
                "S = Limit Ändern"
                "Z = Zurück zum Hauptmenü"
                $rs = Read-Host "Wähle die DbID der Kombination, die du verladen möchstest:"
                if ($rs.ToLower() -ne "z" -and $rs.ToLower() -ne "s") {
                    if ([int]$rs -is [int] -and [int]$rs -gt 0) {
                        $loop = $true
                        while ($loop) {
                            Clear-Host
                            "Gewählte Tour:"
                            if ($com_table.Length -gt 1) {
                                $com_sel = $com_table | Where-Object { $_.DbID -eq [int]$rs }
                            } else {
                                $com_sel = $com_table
                            }
                            $com_sel | ConvertFrom-HashTable | Select-Object -Property Wert_Min, Wert_Max, Quan, Gold, Bexa, Tara | Format-Table
                            $babb_sell = ($com_sel.Quan * $($prices_quan | Where-Object { $_.terminal_name -eq "TDD New Babbage" }).price_sell) + ($com_sel.Gold * $($prices_gold | Where-Object { $_.terminal_name -eq "TDD New Babbage" }).price_sell) + ($com_sel.Bexa * $($prices_bexa | Where-Object { $_.terminal_name -eq "TDD New Babbage" }).price_sell) + ($com_sel.Tara * $($prices_tara | Where-Object { $_.terminal_name -eq "TDD New Babbage" }).price_sell)
                            $oris_sell = ($com_sel.Quan * $($prices_quan | Where-Object { $_.terminal_name -eq "TDD Orison" }).price_sell) + ($com_sel.Gold * $($prices_gold | Where-Object { $_.terminal_name -eq "TDD Orison" }).price_sell) + ($com_sel.Bexa * $($prices_bexa | Where-Object { $_.terminal_name -eq "TDD Orison" }).price_sell) + ($com_sel.Tara * $($prices_tara | Where-Object { $_.terminal_name -eq "TDD Orison" }).price_sell)
                            $area_sell = ($com_sel.Quan * $($prices_quan | Where-Object { $_.terminal_name -eq "TDD Area 18" }).price_sell) + ($com_sel.Gold * $($prices_gold | Where-Object { $_.terminal_name -eq "TDD Area 18" }).price_sell) + ($com_sel.Bexa * $($prices_bexa | Where-Object { $_.terminal_name -eq "TDD Area 18" }).price_sell) + ($com_sel.Tara * $($prices_tara | Where-Object { $_.terminal_name -eq "TDD Area 18" }).price_sell)
                            $lorv_sell = ($com_sel.Quan * $($prices_quan | Where-Object { $_.terminal_name -eq "CBD Lorville" }).price_sell) + ($com_sel.Gold * $($prices_gold | Where-Object { $_.terminal_name -eq "CBD Lorville" }).price_sell) + ($com_sel.Bexa * $($prices_bexa | Where-Object { $_.terminal_name -eq "CBD Lorville" }).price_sell) + ($com_sel.Tara * $($prices_tara | Where-Object { $_.terminal_name -eq "CBD Lorville" }).price_sell)
                            Start-Sleep -Milliseconds 200
                            "--------------------------------"
                            "Verkaufsorte: (zum aktuellen Stand der Daten durch Nutzer)"
                            "[MIC]New Babage: $("{0:N0}" -f $babb_sell) aUEC"
                            "[CRU]Orison: $("{0:N0}" -f $oris_sell) aUEC"
                            "[ARC]Area 18: $("{0:N0}" -f $area_sell) aUEC"
                            "[HUR]Lorville: $("{0:N0}" -f $lorv_sell) aUEC"
                            Start-Sleep -Milliseconds 200
                            "--------------------------------"
                            "Optionen:"
                            "V = Tour Verladen"
                            "A = Andere Tour wählen"
                            "Z = Zurück zum Hauptmenü "
                            $rs2 = Read-Host "Option wählen:"
                            if ($rs2.ToLower() -eq "v") {
                                $rfs1 = $rfs2 = $rfs3 = $rfs4 = $rfs5 = ""
                                $rfs1 = $($ref_table | Where-Object { $_.DbID -eq $com_sel.DbI1 })
                                $rfs2 = $($ref_table | Where-Object { $_.DbID -eq $com_sel.DbI2 })
                                if (-not ("" -eq $com_sel.DbI3)) {
                                    $rfs3 = $($ref_table | Where-Object { $_.DbID -eq $com_sel.DbI3 })
                                }
                                if (-not ("" -eq $com_sel.DbI4)) {
                                    $rfs4 = $($ref_table | Where-Object { $_.DbID -eq $com_sel.DbI4 })
                                }
                                if (-not ("" -eq $com_sel.DbI5)) {
                                    $rfs5 = $($ref_table | Where-Object { $_.DbID -eq $com_sel.DbI5 })
                                }
                                "--------------------------------"
                                "Raffinerie-Slots sind wie folgt" 
                                "(von links nach rechts wählend in der Raffinerie)"
                                "$($rfs1.'Raf.-Slot') + $($rfs2.'Raf.-Slot' - 1)" + $(if ($com_sel.'#Slots' -ge 3) { " + $($rfs3.'Raf.-Slot' - 2)" }) + $(if ($com_sel.'#Slots' -ge 4) { " + $($rfs4.'Raf.-Slot' - 3)" }) + $(if ($com_sel.'#Slots' -ge 5) { " + $($rfs5.'Raf.-Slot' - 4)" })
                                $rfs = @{}
                                $rfs[0] = $rfs1
                                $rfs2.'Raf.-Slot' = $rfs2.'Raf.-Slot' - 1
                                $rfs[1] = $rfs2
                                if (-not ("" -eq $com_sel.DbI3)) {
                                    $rfs3.'Raf.-Slot' = $rfs3.'Raf.-Slot' - 2
                                    $rfs[2] = $rfs3
                                }
                                if (-not ("" -eq $com_sel.DbI4)) {
                                    $rfs4.'Raf.-Slot' = $rfs4.'Raf.-Slot' - 3
                                    $rfs[3] = $rfs4
                                }
                                if (-not ("" -eq $com_sel.DbI5)) {
                                    $rfs5.'Raf.-Slot' = $rfs5.'Raf.-Slot' - 4
                                    $rfs[4] = $rfs5
                                }
                                $rfs.Values | 
                                ConvertFrom-HashTable | 
                                Sort-Object DbID | 
                                Select-Object 'Raf.-Slot', Quantanium, Gold, Bexalite, Taranite | 
                                Format-Table

                                Start-Sleep -Milliseconds 200
                                ""
                                "Bitte die Verladung mit der Eingabetaste bestätigen, "
                                "es werden danach die RaffinerieSlots aus der Datenbank entfernt!"
                                $rsv = Read-Host "Mit 'z' den vorgang abbrechen"
                                if (-not $($rsv.ToLower() -eq 'z')) {
                                    sql_del "refinery" $com_sel.DbI1
                                    sql_del "refinery" $com_sel.DbI2
                                    if (-not ("" -eq $com_sel.DbI3)) {
                                        sql_del "refinery" $com_sel.DbI3
                                    }
                                    if (-not ("" -eq $com_sel.DbI4)) {
                                        sql_del "refinery" $com_sel.DbI4
                                    }
                                    if (-not ("" -eq $com_sel.DbI5)) {
                                        sql_del "refinery" $com_sel.DbI5
                                    }
                                    sql_tru "combinations"
                                    sql_upd_t
                                    $rs2 = ""
                                    $rs = ""
                                    $loop = $false
                                    $option = ""
                                    Pause
                                }
                                Clear-Host
                            } elseif ($rs2.ToLower() -eq "a") {
                                $rs2 = ""
                                $rs = ""
                                $loop = $false
                                Clear-Host
                            } elseif ($rs2.ToLower() -eq "z") {
                                $rs2 = ""
                                $rs = ""
                                $loop = $false
                                $option = ""
                                Clear-Host
                            }
                        }
                    }
                } elseif ($rs.ToLower() -eq "z") {
                    $option = ""
                    Clear-Host
                } elseif ($rs.ToLower() -eq "s") {
                    while ($rs.ToLower() -eq "s") {
                        $rs3 = Read-Host "Gebe den neuen Schwellenwert für die Kombinationen an [1-∞]"
                        $rs4 = Read-Host "Sollen unfertige Slots mit einbezogen werden? [J/N]"
                        if ([int]$rs3 -is [int]) {
                            $sum_c = [int]$rs3
                            $rs = ""
                        } else {
                            "Nur Zahlen eingeben, bitte!"
                        }
                        if ($rs4.ToLower() -eq "j") {
                            $undone = $true
                        }
                        else {
                            $undone = $false
                        }
                    }
                }

            } elseif ($times.last_combo -ge $times.last_entry) {
                Write-Warning "Es sind keine Kombinationen möglich, die den Wert $sum_c oder niedriger erzeugen"
                "Wert wird auf $($sum_c+25) gesetzt"
                $sum_c = $sum_c +46
                Pause
                Clear-Host
            } elseif ($times.last_entry -ge $times.last_combo) {
                Write-Warning "Es sind noch keine Berechnungen durchgeführt worden. Später erneut versuchen"
                $option = ""
                Pause
                Clear-Host
            }
        }
    }
}