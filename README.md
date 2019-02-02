This repository demonstrates how to compile and link a Haskell source
with a C source to produce a native binary. More specifically, a Haskell
method exported via the Foreign Function Interface (FFI) is compiled
into a dynamic shared library that is called from a main method written in C.
GHC is used to compile both the Haskell and C sources, producing a binary
that links with the Haskell shared library and the Haskell runtime system.

# Building and running the example

### With GHC and (g)make

Build the project with `make` and run the example with `./Callee`. 

### With Docker

Create the image with `docker build -t alpine-haskell-ffi:callHaskellFromC .` and
run it with `docker run --rm alpine-haskell-ffi:callHaskellFromC`.
Alternatively, if (g)make is installed, just run `make container`.

# Explanation

## Haskell

The command to compile the Haskell source appropriately is as follows:

	ghc --make -dynamic -shared -fPIC -stubdir ghc_stubs -o libCallee.so Callee.hs

This instructs GHC to compile the Haskell source containing FFI exports, `Callee.hs` into 
a dynamically shared library. Of all the flags, `-dynamic` and `-shared` are self explanatory. 
The `-fPIC` instructs GHC to compile process independent code, or code that can be used anywhere
in memory [1]. This is required since the location of the library in memory may vary from process to process.
The `-stubdir` flag directs GHC to place all FFI stubs it creates (only *.h files in this case, since
we are creating a shared library) into the `ghc_stubs` subdirectory [2].

## C
The command to compile the C source to produce a binary linking with the Haskell shared library
is as follows:

	ghc -Ighc_stubs -no-hs-main -lCallee -L$(pwd) -Optl-Wl,-rpath=. caller.c -o call

This command is easiest to explain by working through an example. Consider the following command:

	ghc caller.c -o call

This results in a compilation error since ghc cannot find the header file `Callee_stub.h`.
Passing  the directory containing *stub.h to gcc with the `-I` flag ensures
that it passes compilation: 

	ghc -Ighc_stubs caller.c -o call
			
However, this results in errors at the linking stage. Firstly, ghc complains that there are two
mains defined - one in Haskell and one in C. Secondly, GHC cannot find the definition of the
exported function since it is defined in the shared library and not in the header.

The first problem is caused by the linker, which links to a Haskell main by default.  Passing
the `-no-hs-main` flag instructs the linker to override this default behaviour and allow the program
entrypoint to be defined elsewhere [3]. The second problem is solved by passing the shared library
to the linker using the `-l` flag, therefore enabling the stub definitions to be found. By convention,
all UNIX shared libraries begin with `lib` and end with `.so`. For succinctness, the prefix and suffix
are discarded when using the `-l` flag. To refer to a shared library `libfoo.so`, one would therefore
pass `-lfoo` to the compiler [4]. The example now becomes:

	ghc -Ighc_stubs -no-hs-main -lCallee caller.c -o call
			
Although the linker is now aware of the shared library, it does not know where to find it, since it
is not in a standard location. The `-L` flag allows the location of a shared library to be given:

	ghc -Ighc_stubs -no-hs-main -lCallee -L$(pwd) caller.c -o call

Finally, this results in a binary file, `call`, which we run with the following command:

	./call

Running the binary results in a runtime error - the shared library cannot be found again. However,
this time it is the dynamic linker complaining that it cannot find the shared library.
This can be solved by moving the shared library to a common location, e.g. `/usr/lib` or /usr/local/lib`,
adding the path of the shared library to the `LD_LIBRARY_PATH` environment variable, or using the
`rpath` mechanism (see [5] for a summary of each). In this example, the `rpath` mechanism is used,
via the `-Optl` (linker option) flag:

	ghc -Ighc_stubs -no-hs-main -lCallee -L$(pwd) -Optl-Wl,-rpath=. caller.c -o call

And finally, the binary runs as expected:

	"Hello C, from Haskell!"

# References

[1] https://downloads.haskell.org/~ghc/7.6.3/docs/html/users_guide/using-shared-libs.html

[2] https://downloads.haskell.org/~ghc/7.6.3/docs/html/users_guide/separate-compilation.html#options-output

[3] https://downloads.haskell.org/~ghc/7.6.3/docs/html/users_guide/ffi-ghc.html#ffi-library

[4] https://downloads.haskell.org/~ghc/7.6.3/docs/html/users_guide/options-phases.html#options-linker

[5] https://www.cprogramming.com/tutorial/shared-libraries-linux-gcc.html
