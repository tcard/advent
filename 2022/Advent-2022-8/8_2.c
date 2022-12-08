#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct Input {
    int lines;
    int width;
    char *content;
} Input;

void free_input(Input input) {
    free(input.content);
}

char input_char_at(Input input, int line, int column) {
    return *(input.content + (line * input.width) + column);
}

Input read_lines() {
    char *content = NULL;
    size_t allocated;
    int width_with_nl = getline(&content, &allocated, stdin);
    if (width_with_nl < 0) {
        perror(NULL);
        exit(1);
    }
    int width = width_with_nl - 1;

    // Rather than calling getline for each line, which allocates each time,
    // let's grow the same chunk of memory and add lines there.

    int lines = 1;
    int alloc_per_line = width_with_nl + 1; // with \0

    while (1) {
        content = realloc(content, (lines + 1) * alloc_per_line - 2);
        if (!content) {
            perror(NULL);
            exit(1);
        }
        char *next_line = content + (lines * width);
        if (fgets(next_line, alloc_per_line, stdin) == NULL) {
            return (Input) { lines, width, content };
        }
        lines++;
    }
}

int scenic_score(Input input, int line, int column) {
    int score = 1;

    char height = input_char_at(input, line, column);

    // To the top
    int visibility = 0;
    for (int i = line - 1; i >= 0; i--) {
        visibility++;
        if (input_char_at(input, i, column) >= height) {
            break;
        }
    }
    score *= visibility;
    
    // To the bottom
    visibility = 0;
    for (int i = line + 1; i < input.lines; i++) {
        visibility++;
        if (input_char_at(input, i, column) >= height) {
            break;
        }
    }
    score *= visibility;

    // To the left
    visibility = 0;
    for (int i = column - 1; i >= 0; i--) {
        visibility++;
        if (input_char_at(input, line, i) >= height) {
            break;
        }
    }
    score *= visibility;

    // To the right
    visibility = 0;
    for (int i = column + 1; i < input.width; i++) {
        visibility++;
        if (input_char_at(input, line, i) >= height) {
            break;
        }
    }
    score *= visibility;

    return score;
}

int max_scenic_score(Input input) {
    int max = 0;

    for (int line = 1; line < input.lines; line++) {
        for (int column = 1; column < input.width; column++) {
            int score = scenic_score(input, line, column);
            max = score > max ? score : max;
        }
    }

    return max;
}

int main() {
    Input input = read_lines();
    
    printf("%d\n", max_scenic_score(input));

    free_input(input);
}
