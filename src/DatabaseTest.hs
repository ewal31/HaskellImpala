module DatabaseTest where

import Control.Exception (bracket)
import Control.Monad (void)
import Database.HDBC
import Database.HDBC.ODBC

host = "<insert host>"

port = "<insert port>"

schema = "<insert default schema>"

tableName = "del_me_this_is_a_test_asdf"

commands = [createTestTable, insertSomeData, readTestData, deleteTestTable]

perform :: IO ()
perform = eval_ commands

impala :: IO Connection
impala = connectODBC $ connString host port schema
  where
    connString host port schema =
      "Driver=Cloudera ODBC Driver for Impala 64-bit;Host=" ++
      host ++ ";Port=" ++ port ++ ";Schema=" ++ schema

close :: Connection -> IO ()
close = disconnect

eval :: (Traversable t) => t (Connection -> IO a) -> IO (t a)
eval queries = bracket impala close $ \conn -> mapM ($ conn) queries

eval_ :: [Connection -> IO a] -> IO ()
eval_ = void . eval

createTestTable :: Connection -> IO ()
createTestTable conn = void $ run conn query [] <* print heading
  where
    query = "CREATE TABLE " ++ tableName ++ " (id Integer, something VARCHAR(80))"
    heading = "Creating table " ++ tableName

insertSomeData :: Connection -> IO ()
insertSomeData conn = do
  stmt <- prepare conn query
  print heading
  executeMany
    stmt
    [ [toSql (0 :: Integer), toSql "word"]
    , [toSql (1 :: Integer), toSql "something else"]
    , [toSql (6 :: Integer), toSql "wow"]
    ]
  where
    query = "INSERT INTO " ++ tableName ++ " VALUES (?, ?)"
    heading = "Inserting data into table " ++ tableName

deleteTestTable :: Connection -> IO ()
deleteTestTable conn = void $ run conn query [] <* print heading
  where
    query = "DROP TABLE " ++ tableName
    heading = "Deleting table " ++ tableName

readTestData :: Connection -> IO ()
readTestData conn = quickQuery' conn query [] <* print heading >>= mapM_ (print . convRow)
  where
    query = "select * from " ++ tableName
    heading = "Contents of table " ++ tableName
    convRow :: [SqlValue] -> String
    convRow [id, something] = show (fromSql id :: Int) ++ " : " ++ (fromSql something :: String)
