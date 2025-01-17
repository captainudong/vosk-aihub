#!/usr/bin/env bash

# Copyright 2014  Vassil Panayotov
#           2014  Johns Hopkins University (author: Daniel Povey)
#           2021  Xuechen LIU
# Apache 2.0

prepare_text=true

. ./utils/parse_options.sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <src-dir> <dst-dir>"
  echo "e.g.: $0 /export/a15/vpanayotov/data/LibriSpeech/dev-clean data/dev-clean"
  echo "Options:"
  echo "   --no-text <true|false>           # Decide to disregard text or not."
  echo "                                    # Default false for speech recognition."
  exit 1
fi

src=$1
dst=$2

# all utterances are FLAC compressed
#if ! which flac >&/dev/null; then
#   echo "Please install 'flac' on ALL worker nodes!"
#   exit 1
#fi

spk_file=$src/../SPEAKERS.TXT

mkdir -p $dst || exit 1;

[ ! -d $src ] && echo "$0: no such directory $src" && exit 1;
#[ ! -f $spk_file ] && echo "$0: expected file $spk_file to exist" && exit 1;


wav_scp=$dst/wav.scp; [[ -f "$wav_scp" ]] && rm $wav_scp
trans=$dst/text; [[ -f "$trans" ]] && rm $trans
utt2spk=$dst/utt2spk; [[ -f "$utt2spk" ]] && rm $utt2spk
spk2gender=$dst/spk2gender; [[ -f $spk2gender ]] && rm $spk2gender

###for reader_dir in $(find -L $src -mindepth 1 -maxdepth 1 -type d | sort); do
for reader_dir in $(find -L $src -mindepth 1 -maxdepth 1 -type d | sort); do
  reader=$(basename $reader_dir)
  #if ! [ $reader -eq $reader ]; then  # not integer.
  #  echo "$0: unexpected subdirectory name $reader"
  #  exit 1;
  #fi

  #reader_gender=$(egrep "^$reader[ ]+\|" $spk_file | awk -F'|' '{gsub(/[ ]+/, ""); print tolower($2)}')
  #if [ "$reader_gender" != 'm' ] && [ "$reader_gender" != 'f' ]; then
  #  echo "Unexpected gender: '$reader_gender'"
  #  exit 1;
  #fi

      if [[ "$reader" =~ ^(.*)(_M_)(.*)$ ]];
      then
          reader_gender="m"
      fi
      if [[ "$reader" =~ ^(.*)(_F_)(.*)$ ]];
      then
	  reader_gender="f"
      fi

  for chapter_dir in $(find -L $reader_dir/ -mindepth 1 -maxdepth 1 -type d | sort); do
  ##for chapter_dir in $(find -L $scriptid_dir/  -type d | sort); do
    chapter=$(basename $chapter_dir)
    #if ! [ "$chapter" -eq "$chapter" ]; then
    #  echo "$0: unexpected chapter-subdirectory name $chapter"
    #  exit 1;
    #fi

    #find -L $chapter_dir/ -iname "*.flac" | sort | xargs -I% basename % .flac | \
    #  awk -v "dir=$chapter_dir" '{printf "lbi-%s flac -c -d -s %s/%s.flac |\n", $0, dir, $0}' >>$wav_scp || exit 1;

       echo "= =---------------- $reader_dir/$reader/ \n"
	find -L $chapter_dir/ -iname "*.wav" | sort | xargs -I% basename % .wav | \

		awk -v "dir=$reader_dir" -v "rdr=$reader" '{printf "lbi-%s cat %s/%s/%s.wav |\n", $0, dir, rdr, $0}' >>$wav_scp|| exit 1
    


    chapter_trans=$chapter_dir/${reader}-${chapter}.trans.txt
    if $prepare_text; then
      [ ! -f  $chapter_trans ] && echo "$0: expected file $chapter_trans to exist" && exit 1
      sed -e 's/^/lbi\-/' $chapter_trans >> $trans
    fi

    # NOTE: For now we are using per-chapter utt2spk. That is each chapter is considered
    #       to be a different speaker. This is done for simplicity and because we want
    #       e.g. the CMVN to be calculated per-chapter
    awk -v "reader=$reader" -v "chapter=$chapter" '{printf "lbi-%s lbi-%s-%s\n", $1, reader, chapter}' \
      <$chapter_trans >>$utt2spk || exit 1

    # reader -> gender map (again using per-chapter granularity)
    echo "lbi-${reader}-${chapter} $reader_gender" >>$spk2gender
  done
done

spk2utt=$dst/spk2utt
utils/utt2spk_to_spk2utt.pl <$utt2spk >$spk2utt || exit 1

if $prepare_text; then
  ntrans=$(wc -l <$trans)
  nutt2spk=$(wc -l <$utt2spk)
  ! [ "$ntrans" -eq "$nutt2spk" ] && \
    echo "Inconsistent #transcripts($ntrans) and #utt2spk($nutt2spk)" && exit 1;
fi

utils/validate_data_dir.sh --no-feats $($prepare_text || echo "--no-text") $dst || exit 1;

echo "$0: successfully prepared data in $dst"

exit 0
