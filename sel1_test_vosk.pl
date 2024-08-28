
$SDIR="/home/ubuntu/vosk-api/training/train_data";
$DDIR="/home/ubuntu/vosk-api/training/db/aihub1test";
$DDIR2="/home/ubuntu/vosk-api/training/data/aihub1test";
system("/bin/rm -rf $DDIR; mkdir $DDIR;");
system("/bin/rm -rf $DDIR2; mkdir $DDIR2;");

$bad_spk=`cat $SDIR/exclude_speakers`;

chdir $SDIR;
@done=();


for $dir (<*>) {
  if($dir =~/\./) { next; };
  if($dir !~/_(수도권)_/) { next; };
  if($dir!~/_(9)_/) { next;}; ### 9 세 연령군 

  #if($dir!~/-(2|3)_/) { next;}; ## 전체의 1/20 로 데이터 사이즈 줄이기 위함 

  if($bad_spk=~/$dir/) { next;};
  if(( -f "$dir/bad_wav_files")) { next;};

  unshift(@done,$dir);
}

print join("\n",@done),"\n";

system("mkdir -p $DDIR");

$i=0;
for $dir (@done) {
 $spk_dir="$DDIR/$dir";
 $chap_dir="$DDIR/$dir/$dir";
 system("mkdir -p $spk_dir");
 print "/bin/ln -s $SDIR/$dir $chap_dir \n";
 #print "/bin/cp -rp $SDIR/$dir $DDIR/ \n";
 ## 원천 데이터로부터 훈련 데이터 디렉토리로의  화자 디렉토리를 심볼링 링크로 연결함 
 system("/bin/ln -s $SDIR/$dir $chap_dir ");
 system("/bin/ln -s $chap_dir/${dir}_${dir}.trans.txt $chap_dir/${dir}-${dir}.trans.txt ");
 $i++;
};

print "DONE: $i speakers\n";
