# Covid-19
Covid-19 MySQL data analysis project

If you would like to install the MySql tables, views and stored procedures used in this app, 
you can run the scripts in following script file: Covid19_Database_install.sql, in any MySql Database.

Then update these three tables as follows:

• covid_process_date – Contains 1 record, the parameters for processing the current cycle

    Run the following script to load the one record it needs:

    Insert into covid_process_date(Process_ID, date_begin, date_end, period, period_days)
    VALUES(1, "2020-01-01", "2020-01-02", "1 DAY", 1);

• coviddata_state – Holds data imported from NY Times covid-19 data repository.  
    Run MySql’s Table Data Import Wizard and import this file, from the NY Times:  us-states.csv

• covid_statedata – Holds state date, like the name, abbreviation, population, etc.
    Run MySql’s Table Data Import Wizard and import this file: statedata.csv


And run this stored procedure:  CALL Covid_LoadNewCycles();


After running the stored procedure the table, coviddata_state_chg, will contain all the details for the current day.  
There will be 3 cycles representing changes over 1 day, 7 days and 14 days.  
The table, coviddata_state_history, will contain historical data.  
﻿
