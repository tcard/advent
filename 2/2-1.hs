-- --- Day 2: Corruption Checksum ---

-- As you walk through the door, a glowing humanoid shape yells in your
-- direction. "You there! Your state appears to be idle. Come help us repair the
-- corruption in this spreadsheet - if we take another millisecond, we'll have to
-- display an hourglass cursor!"

-- The spreadsheet consists of rows of apparently-random numbers. To make sure
-- the recovery process is on the right track, they need you to calculate the
-- spreadsheet's checksum. For each row, determine the difference between the
-- largest value and the smallest value; the checksum is the sum of all of these
-- differences.

-- For example, given the following spreadsheet:

-- 5 1 9 5 7 5 3 2 4 6 8 The first row's largest and smallest values are 9 and 1,
-- and their difference is 8. The second row's largest and smallest values are 7
-- and 3, and their difference is 4. The third row's difference is 6. In this
-- example, the spreadsheet's checksum would be 8 + 4 + 6 = 18.


import Control.Exception.Base (assert)
import System.IO (isEOF)
import Data.String (words)

type Row = [Int]

type Spreadsheet = [Row]

checksum :: Spreadsheet -> Int
checksum sheet =
  foldl (+) 0 (map biggestDiff sheet)

biggestDiff :: Row -> Int
biggestDiff row =
  case (extremes row) of
    Just (smallest, biggest) ->
      biggest - smallest
    Nothing ->
      0

extremes :: Row -> Maybe (Int, Int)
extremes row =
    _extremes row Nothing
  where
    _extremes [] result =
      result
    _extremes (n : rest) Nothing =
      _extremes rest (Just (n, n))
    _extremes (n : rest) (Just (smallest, biggest)) =
      _extremes rest (Just (min smallest n, max biggest n))

main :: IO ()
main = do
    putStrLn . show $ runTests
    checksumInput
  where
    runTests =
      let
        cases = [([
            [5, 1, 9, 5],
            [7, 5, 3],
            [2, 4, 6, 8]
          ], 18)]
        runTest (input, expected) =
          assert ((checksum input) == expected) ()
      in
        map runTest cases

    checksumInput = do
      sheet <- spreadsheetFromInput
      putStrLn . show . checksum $ sheet 

    rowFromLine line =
      map read (words line)

    spreadsheetFromInput =
        _spreadsheetFromInput (return [])
      where
        _spreadsheetFromInput sheet = do
          done <- isEOF
          if done then do
            sheet
          else do
            line <- getLine
            let row = rowFromLine line
            sheet <- spreadsheetFromInput
            _spreadsheetFromInput (return (sheet ++ [row]))
