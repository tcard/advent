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

int mark_visible_once(Input input, bool* visible_set, int line, int column) {
    bool *visible = visible_set + (line * input.width) + column;
    if (*visible) {
        return 0;
    }
    *visible = true;
    return 1;
}

int find_visibles(
    Input input,
    bool* visible_set,
    int line, int column,
    int line_delta, int column_delta
) {
    int marked = 0;
    char max = -1;
    while (line >= 0 && line < input.lines && column >= 0 && column < input.width) {
        char c = input_char_at(input, line, column);
        if (c > max) {
            max = c;
            marked += mark_visible_once(input, visible_set, line, column);
        }
        line += line_delta;
        column += column_delta;
    }
    return marked;
}

int amount_visible(Input input) {
    bool *visible_set = malloc(sizeof(bool) * input.width * input.lines);
    if (visible_set == NULL) {
        perror(NULL);
        exit(1);
    }

    int result = 0;

    for (int line = 0; line < input.lines; line++) {
        result += find_visibles(input, visible_set, line, 0, 0, 1);
        result += find_visibles(input, visible_set, line, input.width - 1, 0, -1);
    }
    for (int column = 0; column < input.width; column++) {
        result += find_visibles(input, visible_set, 0, column, 1, 0);
        result += find_visibles(input, visible_set, input.lines - 1, column, -1, 0);
    }
    
    free(visible_set);
    return result;
}

int main() {
    Input input = read_lines();
    
    printf("%d\n", amount_visible(input));

    free_input(input);
}
