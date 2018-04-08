#include <stdio.h>
#include <malloc.h>

/*
 * (int -> int) createSumBy(int x) {
 *     int sumBy(int y) {
 *         return x + y;
 *     }
 *     return sumBy;
 * }
 */

typedef struct {
    int params_size;
    int (*function_ptr)(int *params, int *args);
    int *params;
} Closure;

int execute_closure(Closure closure, int *args) {
    return closure.function_ptr(closure.params, args);
}

Closure create_closure(int (*function_ptr)(int*, int*), int params_size, int *params) {
    Closure c;
    c.function_ptr = function_ptr;
    c.params_size = params_size;
    c.params = params;
    return c;
}

int sum(int x, int y) {
    return x + y;
}

int sumBy(int *params, int *remaining_params) {
    return sum(params[0], remaining_params[0]);
}

Closure createSumBy(int x) {
    int *param = malloc(sizeof(int));
    *param = x;
    Closure sumByClosure = create_closure(sumBy, 1, param);
    return sumByClosure;
}

int main() {
    Closure sumByFive = createSumBy(5);

    int params[] = {1};
    int six = execute_closure(sumByFive, params);
    printf("5+1 = %i\n", six);

    params[0] = 5;
    int ten = execute_closure(sumByFive, params);
    printf("5+5 = %i\n", ten);

    return 0;
}