GHC=ghc
STUBDIR=ghc_stubs
HS_FILENAME=Callee
C_FILENAME=caller
BINARY_NAME=call

LIB_LOCATION = $(shell pwd)
all:	link-hs
	$(GHC) -dynamic -I$(STUBDIR) -no-hs-main -l$(HS_FILENAME) -L$(LIB_LOCATION) -optl-Wl,-rpath,$(LIB_LOCATION) $(C_FILENAME).c -o $(BINARY_NAME)

install: all
	# copy the shared library
	echo "Implement installing of shared libraries and includes..."


.PHONY: image
image:
	docker build -t alpine-haskell-ffi:callHaskellFromC .


container: image
	docker run --rm alpine-haskell-ffi:callHaskellFromC

.PHONY: compile-hs
# Compile the haskell file as shared library; produce a header stub to be able to call from c.
compile-hs: *.hs *.c
	$(GHC) --make -dynamic -fPIC -stubdir $(STUBDIR) -c $(HS_FILENAME).hs

# Link the object file as a dynamic shared library.
link-hs: compile-hs
	$(GHC) -dynamic -shared -o lib$(HS_FILENAME).so $(HS_FILENAME).o

.PHONY: clean
clean:	
	rm -rf $(STUBDIR) *.hi *.o a.out *.so $(BINARY_NAME)
	$(shell docker rmi alpine-haskell-ffi:callHaskellFromC 2> /dev/null)
