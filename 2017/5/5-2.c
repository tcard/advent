// --- Part Two ---

// Now, the jumps are even stranger: after each jump, if the offset was three or
// more, instead decrease it by 1. Otherwise, increase it by 1 as before.

// Using this rule with the above example, the process now takes 10 steps, and the
// offset values after finding the exit are left as 2 3 2 3 -1.

// How many steps does it now take to reach the exit?

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
	int jump = state->program.instructions[state->current];
	state->current += jump;
	if (jump >= 3) {
		state->program.instructions[prev]--;
	}  else {
		state->program.instructions[prev]++;
	}
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

	test_cases[0].expected = 10;
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

			/* grow if needed */
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
	} while(c != EOF);

	program_t input = { instructions_len, instructions };
	printf("%d\n", steps(input));

	return 0;
}
