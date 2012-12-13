#! /bin/bash

echo 'Note: the script should be run after sent-align.sh'

source ../set-env.sh

echo 'Splitting sentences into sub-sentences...'
./sent-segment.scala --subsent shiji.sent.aligned.classical shiji.subsent.classical || { exit 1; }
./sent-segment.scala --subsent shiji.sent.aligned.modern shiji.subsent.modern || { exit 1; }

echo 'Performing sub-sentence alignment...'

./hunalign-partial.scala --max-line-num 46000 hunalign-batch-jobs \
  shiji.subsent.classical shiji.subsent.modern shiji.subsent classical modern

touch null.dict
$HUNALIGN_BIN -text -realign -utf -cautious -thresh=0 -batch null.dict hunalign-batch-jobs
rm null.dict

cat shiji.subsent_*.aligned > shiji.subsent.aligned

echo 'Formatting result as bitext...'
./hunaligned-to-bitext.scala shiji.subsent.aligned shiji.subsent.aligned.classical shiji.subsent.aligned.modern

sed -i "s/\s//g" shiji.subsent.aligned.classical
sed -i "s/\s//g" shiji.subsent.aligned.modern
