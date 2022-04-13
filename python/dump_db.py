#!/usr/bin/python3
import os, time, pymysql, subprocess
from datetime import datetime

# Если указано True, то будет делать бэкап всех таблиц. Если указана False делат бэкап только БД
dump_tables = False 
db_name = 'db_test'
db_user = 'web'
db_passwd = 'passwd'
dump_path = './dumps'
# Количество дней, если файл старше этого значения, будет удален
dump_days = 2 

if (os.path.isdir(dump_path) != True):
    os.makedirs (dump_path, mode=0o755)

def check_time_livein():
    seconds = time.time()
    list_files = os.listdir(dump_path)
    for i in list_files:
        time_create = int((seconds - os.stat(os.path.join(dump_path, i)).st_atime) // 60) # Время создания в минутах 
        day_check = (time_create / 60) / 24 # Время создания в днях
        if (day_check > dump_days):
            os.remove(os.path.join(dump_path, i))

try:
    conn = pymysql.connect(
    host = 'localhost',
    port = 3306,
    user = db_user,
    passwd = db_passwd,
    db = db_name
    )

    current_datetime = datetime.now()
    db_Info = conn.get_server_info()
    cursor = conn.cursor()
    
    if (dump_tables == True):
        cursor.execute("show tables;")
        row = cursor.fetchone()
        list_tables = []
        while row is not None:
            list_tables.append(row)
            row = cursor.fetchone()
        for element in list_tables:
            for table in element:
                subprocess.Popen(f'mysqldump -h localhost -P 3306 -u {db_user} -p{db_passwd} {db_name} {table} | gzip -9 > {dump_path}/{db_name}_{table}_{current_datetime.strftime("%d.%m.%Y")}.sql.gz', shell=True)
    else:
        subprocess.Popen(f'mysqldump -h localhost -P 3306 -u {db_user} -p{db_passwd} {db_name} | gzip -9 > {dump_path}/{db_name}_{current_datetime.strftime("%d.%m.%Y")}.sql.gz', shell=True)
    
    check_time_livein()
    
except Error as e:
    print("Error while connecting to MySQL", e)

finally:
    cursor.close()
    conn.close()
