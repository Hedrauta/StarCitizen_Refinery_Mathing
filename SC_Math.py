import itertools
import time
import mysql.connector

# Verbindung zur Datenbank herstellen

while True:
    conn = mysql.connector.connect(
        host="",
        port="",
        user="",
        password="",
        database=""
    )
    c = conn.cursor()
    print("Checking time")
    c.execute("SELECT last_combo, last_entry FROM timestamps")
    last_combi, last_entry = c.fetchone()
    if last_combi < last_entry:
        print("Checking combinations")
        c.execute("SELECT DbID, SumSCU FROM SumSCU")
        print("Selected Data")
        data = [(row[0], row[1]) for row in c.fetchall()]
        if data:
            ids, ertrag_values = zip(*data)
            c.execute("TRUNCATE TABLE combinations")
            
            cache = []
            for r in range(2, min(6, len(ertrag_values) + 1)):
                for indices in itertools.combinations(range(len(ertrag_values)), r):
                    combi = [ertrag_values[i] for i in indices]
                    combi_sum = sum(combi)
                    combi_ids = [ids[i] for i in indices]
                    combi_ids += [None] * (5 - len(combi_ids))
                    cache.append((*combi_ids, combi_sum))
            
            if cache:
                query = "INSERT INTO combinations (DbI1, DbI2, DbI3, DbI4, DbI5, SCU) VALUES (%s, %s, %s, %s, %s, %s)"
                c.executemany(query, cache)
                print("Combinations inserted and timestamp Updated")
            else:
                print("No combinations to insert")
        else:
            print("Keine Daten vorhanden, Überspringe Prüfung")
        
        c.execute("UPDATE timestamps SET last_combo = %s", (int(time.time()),))
        conn.commit()
        conn.close()
        time.sleep(10)
    else:
        print("sleep")
        conn.close()
        time.sleep(10)
    

