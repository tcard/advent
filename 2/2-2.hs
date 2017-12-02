-- --- Part Two ---

-- "Great work; looks like we're on the right track after all. Here's a star for
-- "your effort. However, the program seems a little worried. Can programs be
-- "worried?

-- "Based on what we're seeing, it looks like all the User wanted is some
-- "information about the evenly divisible values in the spreadsheet.
-- "Unfortunately, none of us are equipped for that kind of calculation - most of
-- "us specialize in bitwise operations.

-- It sounds like the goal is to find the only two numbers in each row where one
-- evenly divides the other - that is, where the result of the division operation
-- is a whole number. They would like you to find those numbers on each line,
-- divide them, and add up each line's result.

-- For example, given the following spreadsheet:

-- 5 9 2 8 9 4 7 3 3 8 6 5 In the first row, the only two numbers that evenly
-- divide are 8 and 2; the result of this division is 4. In the second row, the
-- two numbers are 9 and 3; the result is 3. In the third row, the result is 2.
-- In this example, the sum of the results would be 4 + 3 + 2 = 9.


import Control.Exception.Base (assert)
import System.IO (isEOF)
import Data.String (words)
import System.IO.Unsafe (unsafePerformIO)

type Row = [Int]

type Spreadsheet = [Row]

checksum :: Spreadsheet -> Int
checksum sheet =
  foldl (+) 0 (map cleanDiv sheet)

cleanDiv :: Row -> Int
cleanDiv row =
    head [x `div` y | (x, i) <- enumRow, (y, j) <- enumRow, x `mod` y == 0, i /= j]
  where
    enumRow = zip row [1..]

main :: IO ()
main = do
    putStrLn . show $ runTests
    checksumInput
  where
    runTests =
      let
        cases = [([
            [5, 9, 2, 8],
            [9, 4, 7, 3],
            [3, 8, 6, 5]
          ], 9)]
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
