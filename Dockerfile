FROM alpine:3.8 as builder
RUN mkdir -p /usr/local/callHaskellFromC
COPY . /usr/local/callHaskellFromC
WORKDIR /usr/local/callHaskellFromC

RUN apk update && apk add libc-dev ghc make
RUN mkdir -p /usr/local/callHaskellFromC/ghc_stubs
RUN make 

###############################################
FROM alpine:3.8 as runner
RUN mkdir -p /usr/local/callHaskellFromC
WORKDIR /usrc/local/callHaskellFromC
COPY --from=builder /usr/local/callHaskellFromC .

# Create the necessary directories to copy to
RUN mkdir -p /usr/lib/ghc-8.4.3/base-4.11.1.0
RUN mkdir -p /usr/lib/ghc-8.4.3/integer-gmp-1.0.2.0
RUN mkdir -p /usr/lib/ghc-8.4.3/ghc-prim-0.5.2.0
RUN mkdir -p /usr/lib/ghc-8.4.3/rts

# Copy the necessary libraries from the builder container to the runner container.
COPY --from=builder /usr/lib/ghc-8.4.3/base-4.11.1.0 /usr/lib/ghc-8.4.3/base-4.11.1.0
COPY --from=builder /usr/lib/ghc-8.4.3/integer-gmp-1.0.2.0 /usr/lib/ghc-8.4.3/integer-gmp-1.0.2.0
COPY --from=builder /usr/lib/ghc-8.4.3/ghc-prim-0.5.2.0 /usr/lib/ghc-8.4.3/ghc-prim-0.5.2.0
COPY --from=builder /usr/lib/ghc-8.4.3/rts /usr/lib/ghc-8.4.3/rts
COPY --from=builder /usr/lib/libffi.so.6 /usr/lib/libffi.so.6
COPY --from=builder /usr/lib/libgmp.so.10 /usr/lib/libgmp.so.10 
COPY --from=builder /usr/local/callHaskellFromC/libCallee.so /usr/lib/libCallee.so

CMD ./call
