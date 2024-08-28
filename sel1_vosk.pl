
# 원천 데이터 (.wav, .json) 디렉토리 
$SDIR="/home/ubuntu/vosk-api/training/train_data";

# 훈련 데이터 디렉토리: ./db 밑에 위치 
$DDIR="/home/ubuntu/vosk-api/training/db/aihub1/";
# 훈련 데이터의  .wav duration, gender 등의 부가적 정보 디렉토리: ./data 밑에 위치 
$DDIR2="/home/ubuntu/vosk-api/training/data/aihub1/";

## 훈련데이터 초기화: 원천 데이터는 삭제되지 않고,  단지 심볼링링크만 삭제함 
system("/bin/rm -rf $DDIR; mkdir -p $DDIR;");
system("/bin/rm -rf $DDIR2; mkdir -p $DDIR2;");

$bad_spk=`cat $SDIR/exclude_speakers`;

chdir $SDIR;
@done=();


for $dir (<*>) {
  if($dir =~/\./) { next; };
  if($dir !~/_(수도권)_/) { next; }; ### 지역명으로 필터링 
  if($dir!~/_(10)_/) { next;}; ### 스피커의 나이로 필터링 : 10세 연령군 

  #if($dir!~/-(2|3)_/) { next;}; ## 전체의 1/20 로 데이터 사이즈 줄이기 위함 

  #if($dir!~/_M_/) { next;}; ### 스피커의 성별(M) 로 필터링 : 현재 사용치 않음 
  #if($dir!~/_F_/) { next;}; ### 스피커의 성별(F) 로 필터링 : 현재 사용치 않음 
  if($bad_spk=~/$dir/) { next;}; ## 배제해야 할 스퍼커가 있다면 $$DIR/exclude_speakers 에 넣어두면 됨 
  if(( -f "$dir/bad_wav_files")) { next;}; ## 오류가 있는 wav 파일을 포함하는 화자의 서브디렉토리는 무시함 

  unshift(@done,$dir);
}

print join("\n",@done),"\n";

## 훈련 데이터 디렉토리 생성 
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
