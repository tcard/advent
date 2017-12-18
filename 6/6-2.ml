(* --- Part Two ---

Out of curiosity, the debugger would also like to know the size of the loop:
starting from a state that has already been seen, how many block redistribution
cycles must be performed before that same state is seen again?

In the example above, 2 4 1 2 is seen again after four cycles, and so the answer
in that example would be 4.

How many cycles are in the infinite loop that arises from the configuration in
your puzzle input? *)

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

module BanksMap = Map.Make(Banks)

let realloc_loop_size (banks: banks) : int =
  let seen_after = ref BanksMap.empty in
  let steps = ref 0 in
  let found = ref 0 in

  while (
    match BanksMap.find_opt banks !seen_after with
      None ->
        true
    | Some(after) ->
        found := after;
        false
  ) do
    seen_after := BanksMap.add (Array.copy banks) !steps !seen_after;
    realloc_step banks;
    incr steps;
  done;

  !steps - !found

let () =
  let run_tests _ =
    let cases = [|
      ([| 0; 2; 7; 0 |], 4)
    |] in
    for i = 0 to (Array.length cases) - 1 do
      let (input, expected) = cases.(i) in
      let got = realloc_loop_size input in
      if expected <> got then
        failwith (Printf.sprintf "%d: expected %d, got %d" i expected got)
    done

  in let process_stdin _ =
    let numbers = String.split_on_char '\t' (read_line ()) in
    let banks = Array.make (List.length numbers) 0 in
    List.iteri (fun i -> fun n -> banks.(i) <- int_of_string n) numbers;
    print_int (realloc_loop_size banks); print_newline ();

  in
    run_tests ();
    process_stdin ();
