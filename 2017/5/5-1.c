// --- Day 5: A Maze of Twisty Trampolines, All Alike ---

// An urgent interrupt arrives from the CPU: it's trapped in a maze of jump
// instructions, and it would like assistance from any programs with spare cycles
// to help find the exit.

// The message includes a list of the offsets for each jump. Jumps are relative: -1
// moves to the previous instruction, and 2 skips the next one. Start at the first
// instruction in the list. The goal is to follow the jumps until one leads outside
// the list.

// In addition, these instructions are a little strange; after each jump, the
// offset of that instruction increases by 1. So, if you come across an offset of
// 3, you would move three instructions forward, but change it to a 4 for the next
// time it is encountered.

// For example, consider the following list of jump offsets:

// 0
// 3
// 0
// 1
// -3

// Positive jumps ("forward") move downward; negative jumps move upward. For
// legibility in this example, these offset values will be written all on one line,
// with the current instruction marked in parentheses. The following steps would be
// taken before an exit is found:

// (0) 3  0  1  -3  - before we have taken any steps.

// (1) 3  0  1  -3  - jump with offset 0 that is, don't jump at all). Fortunately,
// the instruction is then incremented to 1.

// 2 (3) 0  1  -3  - step forward because of the instruction we just modified. The
// first instruction is incremented again, now to 2.

// 2  4  0  1 (-3) - jump all the way to the end; leave a 4 behind.

// 2 (4) 0  1  -2  - go back to where we just were; increment -3 to -2.

// 2  5  0  1  -2  - jump 4 steps forward, escaping the maze.

// In this example, the exit is reached in 5 steps.

// How many steps does it take to reach the exit?

#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>

typedef struct program_t {
	int length;
	int *instructions;
} program_t;

typedef struct state_t {
	int current;
	program_t program;
} state_t;

void advance_state(state_t *state) {
	int prev = state->current;
	state->current += state->program.instructions[prev];
	state->program.instructions[prev]++;
}

bool state_done(state_t *state) {
	return state->current >= state->program.length || state->current < 0;
}

int steps(program_t program){
	state_t state = {
		.program = program,
		.current = 0
	};

	int steps = 0;

	while (!state_done(&state)) {
		advance_state(&state);
		steps++;
	}

	return steps;
}

int main() {
	typedef struct test_case_t {
		int expected;
		program_t program;
	} test_case_t;

	const int num_test_cases = 1;
	test_case_t test_cases[num_test_cases];

	test_cases[0].expected = 5;
	test_cases[0].program.instructions = ((int[]) {0, 3, 0, 1, -3});
	test_cases[0].program.length = 5;

	for (int i = 0; i < num_test_cases; i++) {
		assert(steps(test_cases[i].program) == test_cases[i].expected);
	}

	int instructions_cap = 10;
	int *instructions = (int *) malloc(sizeof(int) * instructions_cap);
	if (!instructions) {
		exit(1);
	}
	int instructions_len = 0;


	int next_instruction = 0;
	int num_digits = 0;
	bool is_negative = false;

	int c;
	do {
		c = getchar();

		if (c == ' ' || c == '\n' || c == EOF) {
			if (num_digits == 0) {
				continue;
			}

			instructions_len++;

			// Grow array if needed.
			if (instructions_len >= instructions_cap) {
				instructions_cap *= 2;
				instructions = (int *) realloc(instructions, sizeof(int) * instructions_cap);
				if (!instructions) {
					exit(1);
				}
			}

			if (is_negative) {
				next_instruction = -next_instruction;
			}
			instructions[instructions_len - 1] = next_instruction;

			next_instruction = 0;
			num_digits = 0;
			is_negative = false;
		} else if (c >= '0' && c <= '9') {
			num_digits++;
			next_instruction *= 10;
			next_instruction += c - '0';
		} else if (c == '-' && num_digits == 0) {
			is_negative = true;
		} else if (c != '\n') {
			fprintf(stderr, "bad digit: %c\n", (char) c);
			exit(1);
		}
	} while (c != EOF);

	program_t input = { instructions_len, instructions };
	printf("%d\n", steps(input));

	return 0;
}
