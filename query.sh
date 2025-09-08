#!/bin/bash

NODE_N=${1}
DATA=${2}

echo "Running parallel node ${NODE_N}"
split -l 100 ${DATA}
if [ ! -f "xa${NODE_N}" ]
then
  echo "ignored"
else
  node --version
  split -l 10 "xa${NODE_N}" chunk
  for i in chunkx*
  do
    cat ${i}
    ./blacklight-query < ${i}
  done
fi

rm -f xa* chunk*

