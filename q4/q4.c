#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

#define MAX_OP_LEN 5
#define MAX_LINE_LEN 256

int main() {
    char line[MAX_LINE_LEN];
    
    while (fgets(line, sizeof(line), stdin)) {
        // Remove trailing newline
        line[strcspn(line, "\n")] = '\0';
        
        char op[MAX_OP_LEN + 1];
        int num1, num2;
        
        // Parse the line: <op> <num1> <num2>
        if (sscanf(line, "%5s %d %d", op, &num1, &num2) != 3) {
            // Invalid line, skip (or could print error, but not required)
            continue;
        }
        
        // Construct library name: lib<op>.so
        char libname[64];
        snprintf(libname, sizeof(libname), "lib%s.so", op);
        
        // Load the shared library
        void *handle = dlopen(libname, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error loading %s: %s\n", libname, dlerror());
            continue;
        }
        
        // Clear any existing error
        dlerror();
        
        // Get the function pointer
        typedef int (*op_func)(int, int);
        op_func func = (op_func) dlsym(handle, op);
        const char *error = dlerror();
        if (error) {
            fprintf(stderr, "Error finding symbol %s: %s\n", op, error);
            dlclose(handle);
            continue;
        }
        
        // Call the function and print result
        int result = func(num1, num2);
        printf("%d\n", result);
        
        // Close the library to free memory
        dlclose(handle);
    }
    
    return 0;
}