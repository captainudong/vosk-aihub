#!/usr/bin/env bash
#
# Based mostly on the WSJ/Librispeech recipe. 
# The training/testing database is described in http://www.openslr.org/40/
# This corpus consists of 51hrs korean speech with cleaned automatic transcripts:
#
# Copyright  2018  Atlas Guide (Author : Lucas Jo)
#            2018  Gridspace Inc. (Author: Wonkyum Lee)
#
# Apache 2.0
#

# Check list before start
# 1. required software: Morfessor-2.0.1 (see tools/extras/install_morfessor.sh)

stage=0
db_dir=./db/
data_dir=./data/
nj=16

chain_train=true
decode=true # set false if you don't want to decode each GMM model
decode_rescoring=true # set false if you don't want to rescore with large language model
test_set="test_clean"

. ./cmd.sh
. ./path.sh
. utils/parse_options.sh  # e.g. this parses the --stage option if supplied.

### 훈련 데이터 디렉토리 생성 및 초기화 
perl sel1_vosk.pl

# format the data as Kaldi data directories

###for part in train_data_01 test_data_01; do
###for part in aihub1 aihub1test; do
/bin/rm -f new_bad_wav_files
for part in aihub1 ; do
  	# use underscore-separated names in data directories.

  	###local/data_prep.sh $db_dir $part
  	echo local/data_prep_vosk.sh $db_dir/$part $data_dir/$part
  	local/data_prep_vosk.sh $db_dir/$part $data_dir/$part
        if [ -f "new_bad_wav_files" ]; then
		echo "BAD WAV FOUND: FILTER and REDO ******************"
	fi
done

###### 데이터 밸리데이션 까지만 수행하고 종료 
exit 0
