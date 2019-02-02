#include <stdio.h>
#include "HsFFI.h"

#ifdef __GLASGOW_HASKELL__
#include "Callee_stub.h"
#include "Rts.h"
#endif

int main(int argc, char *argv[]) {

#if __GLASGOW_HASKELL__ >= 703
  {
    RtsConfig conf = defaultRtsConfig;
    conf.rts_opts_enabled = RtsOptsAll;
    hs_init_ghc(&argc, &argv, conf);
  }
#else
  hs_init(&argc, &argv);
#endif
  helloFromHaskell();
  hs_exit();
  return 0;
}

