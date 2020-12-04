(* --- Day 6: Memory Reallocation ---

A debugger program here is having an issue:
it is trying to repair a memory reallocation routine, but it keeps getting stuck
in an infinite loop.

In this area, there are sixteen memory banks; each memory bank can hold any
number of blocks. The goal of the reallocation routine is to balance the blocks
between the memory banks.

The reallocation routine operates in cycles. In each cycle, it finds the memory
bank with the most blocks (ties won by the lowest-numbered memory bank) and
redistributes those blocks among the banks. To do this, it removes all of the
blocks from the selected bank, then moves to the next (by index) memory bank and
inserts one of the blocks. It continues doing this until it runs out of blocks;
if it reaches the last memory bank, it wraps around to the first one.

The debugger would like to know how many redistributions can be done before a
blocks-in-banks configuration is produced that has been seen before.

For example, imagine a scenario with only four memory banks:

The banks start with 0, 2, 7, and 0 blocks. The third bank has the most blocks,
so it is chosen for redistribution.

Starting with the next bank (the fourth bank) and then continuing to the first
bank, the second bank, and so on, the 7 blocks are spread out over the memory
banks. The fourth, first, and second banks get two blocks each, and the third
bank gets one back. The final result looks like this: 2 4 1 2.

Next, the second bank is chosen because it contains the most blocks (four).
Because there are four memory banks, each gets one block. The result is: 3 1 2
3.

Now, there is a tie between the first and fourth memory banks, both of which
have three blocks. The first bank wins the tie, and its three blocks are
distributed evenly over the other three banks, leaving it with none: 0 2 3 4.

The fourth bank is chosen, and its four blocks are distributed such that each of
the four banks receives one: 1 3 4 1.

The third bank is chosen, and the same thing happens: 2 4 1 2.

At this point, we've reached a state we've seen before: 2 4 1 2 was already
seen. The infinite loop is detected after the fifth block redistribution cycle,
and so the answer in this example is 5.

Given the initial block counts in your puzzle input, how many redistribution
cycles must be completed before a configuration is produced that has been seen
before? *)

type bank = int

type banks = bank array

let realloc_step (banks: banks) : unit =
  let busiest =
    let rec find_busiest i busiest =
      if i >= Array.length banks then
        busiest
      else
        let next_busiest =
          match busiest with
            None ->
              i
          | Some(old_i) ->
              if banks.(i) > banks.(old_i) then
                i
              else
                old_i
        in
          find_busiest (i + 1) (Some next_busiest)
    in
      find_busiest 0 None

  in let redistribute_from i =
    let amount_to_redistribute = banks.(i) in
    banks.(i) <- 0;
    for j = i + 1 to amount_to_redistribute + i do
      let j = j mod Array.length banks in
      banks.(j) <- banks.(j) + 1
    done

  in
    match busiest with
      None ->
        ()
    | Some(i) ->
        redistribute_from i

module Banks = struct
  type t = bank array
  let compare a b =
    let rec compare' i =
      let reached_end arr = i >= Array.length arr in
      match (reached_end a, reached_end b) with
        (true, false) ->
          -1
      | (false, true) ->
          1
      | (true, true) ->
          0
      | (false, false) ->
          match (Pervasives.compare a.(i) b.(i)) with
            0 ->
              compare' (i + 1)
          | x ->
              x
    in compare' 0
end

module BanksSet = Set.Make(Banks)

let realloc_steps_until_loop (banks: banks) : int =
  let seen = ref BanksSet.empty in
  let steps = ref 0 in

  while not (BanksSet.mem banks !seen) do
    seen := BanksSet.add (Array.copy banks) !seen;
    realloc_step banks;
    incr steps;
  done;

  !steps

let () =
  let run_tests _ =
    let cases = [|
      ([| 0; 2; 7; 0 |], 5)
    |] in
    for i = 0 to (Array.length cases) - 1 do
      let (input, expected) = cases.(i) in
      let got = realloc_steps_until_loop input in
      if expected <> got then
        failwith (Printf.sprintf "%d: expected %d, got %d" i expected got)
    done

  in let process_stdin _ =
    let numbers = String.split_on_char '\t' (read_line ()) in
    let banks = Array.make (List.length numbers) 0 in
    List.iteri (fun i -> fun n -> banks.(i) <- int_of_string n) numbers;
    print_int (realloc_steps_until_loop banks); print_newline ();

  in
    run_tests ();
    process_stdin ();
