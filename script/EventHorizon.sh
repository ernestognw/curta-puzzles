
#!/bin/bash

ME=<...>
CURTA=0x0000000006bc8d9e5e9d436217b88de704a9f307
for i in {0..65536}
do
  cast send $CURTA --from $ME --gas-limit 377653 "solve(uint32,uint256)" 6 $i
done
