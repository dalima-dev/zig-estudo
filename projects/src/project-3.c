#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct
{
    int *items;
    int capacity;
    int length;
} Stack;

void push(Stack *stack, int item)
{
    if (stack->length >= stack->capacity)
    {
        const int capacity = stack->capacity * 2;

        stack->items = (int *)realloc(stack->items, capacity * sizeof(int));
        stack->capacity = capacity;
    }

    stack->items[stack->length] = item;
    stack->length += 1;
}

void pop(Stack *stack)
{
    if (stack->length == 0)
        return;

    stack->length -= 1;
    stack->items[stack->length] = -1;
}

void initialize_stack(Stack *stack, int capacity)
{
    stack->items = (int *)malloc(capacity * sizeof(int));
    stack->capacity = capacity;
    stack->length = 0;
}

void deinitialize_stack(Stack *stack)
{
    free(stack->items);
}

void print_stack_items(Stack *stack)
{
    printf("Items: ");
    for (int i = 0; i < stack->length; i++)
        printf("%d ", stack->items[i]);

    printf("\n");
}

int main()
{
    Stack stack;
    initialize_stack(&stack, 10);

    while (stack.length < 15)
    {
        push(&stack, stack.length + 1);

        printf("Length: %d\n", stack.length);
        printf("Capacity: %d\n", stack.capacity);
    }

    print_stack_items(&stack);

    while (stack.length > 3)
    {
        pop(&stack);

        printf("Length: %d\n", stack.length);
        printf("Capacity: %d\n", stack.capacity);
    }

    print_stack_items(&stack);

    deinitialize_stack(&stack);
    return 0;
}
