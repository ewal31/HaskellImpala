# Haskell Impala Test

## Requirements

* Impala ODBC Driver from [here](https://www.cloudera.com/downloads/connectors/impala/jdbc/2-6-4.html)

## Setup

1. Make sure unixODBC is installed (`odbcinst -j`)
2. Extract the driver to `/opt/cloudera/impalaodbc/`
3. Add `/opt/cloudera/impalaodbc/Setup/odbc.ini` to `USER DATA SOUCE` (In my case `/home/edward/.odbc.ini`)
4. Add `/opt/cloudera/impalaodbc/Setup/odbcinst.ini` to `DRIVERS` (In my case `/etc/odbcinst.ini`)
5. Fill in template values in `src/DatabaseTest.hs`
6. `stack build`
7. `stack run`
