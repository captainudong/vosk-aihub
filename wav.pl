
$SDIR="/home/ubuntu/vosk-api/training/train_data";
$bad_wav_dir=`cat bad_wav_files`;
chdir $SDIR;
@bad_json=();
@bad_wav=();

$dir_count-9;
for $dir (<*>) {
  if ($dir =~/\./) { next; };
  $dir_count=$dir_count+1;
}

$index=0;
for $dir (<*>) {
  if ($dir =~/\./) { next; };
  $index++;

  print "doing $index/$dir_count $dir\n";
  #if($bad_wav_dir=~/$dir/) { print "BAD WAV SEPAKER: $dir\n"; next;};

  $trans_file= $SDIR."/$dir/".$dir."_".$dir.".trans.txt";
  $trans_file_comma= $SDIR."/$dir/".$dir."-".$dir.".trans.txt"; ### hyphen instead underbar: for vosk recipe
  $trans_file_doing= $trans_file.".doing";
  
  chdir $dir;

  if (!( -f $trans_file) || ( -s $trans_file) == 0 || 1) { 
  	print "making .trans.txt file ========================\n"; 

	  $t1=`fgrep -H '"stt" :' *json` ;
	  open(F,">$trans_file_doing");
	  $valid_json_count=0;
	  for $line (split(/\n/,$t1)) {
	    print "/";
		 #print $line,"\n";
	    if ($line=~/^(.*)\.json:.*stt.*: *"(.*)"/) {
		    $fbase=$1; $chat=$2; 
		      $chat=~s/ $//;
		      $chat=~s/\([A-Z][A-Z]:(.*)\)/$1/g;
		      $chat=~s/ +$//;
		      $chat=~s/^ +//;
		      #print $fbase,"-->",$chat,"\n";
		    print F ($fbase." ".$chat."\n");
		    $valid_json_count=$valid_json_count+1;
	    };
	  };
	  close(F);
	  $sz= -s $trans_file_doing;
	  if($sz > 0) {
		  rename $trans_file_doing, $trans_file;
		  system("/bin/cp $trans_file $trans_file_comma");
	  } else {
		  open(F,">no_trans_file");
		  close(F);
		  unshift(@bad_json,$dir);
	  };
  } else {
  	print "skipping .trans.txt file\n"; 
  };
  print "\n";

  print "making .dur file\n"; 

  $wav_count=0;

  for $wav (<*.wav>) {
    $scp_file="$wav.scp";
    $dur_file="$wav.dur";
    $wav_count=$wav_count+1;
    if( (! -f $dur_file) || (-s $dur_file) == 0 || 0) {
	    open(F,">$scp_file");
	    print F "$wav cat ./$wav |\n";
	    close(F);
	    system("wav-to-duration --read-entire-file=false scp:$scp_file ark,t:$dur_file  > /tmp/0000 2>&1");
	    $sz2= -s $dur_file;
	    if($sz2 < length($wav) ) {
		    open(X,">>bad_wav_files");
		    print X "$dir/$wav\n";
		    close(X);
		    unshift(@bad_wav,"$dir/$wav");
	    };
	    print "!";
    } else {
	    print ".";
    }
  };

  for $wav_old (<*.wavp>) {
    $wav=$wav_old;
    $wav=~s/wavp/wav/;
    rename $wav_old,$wav;

    $scp_file="$wav.scp";
    $dur_file="$wav.dur";
    $wav_count=$wav_count+1;
    if( (! -f $dur_file) || (-s $dur_file) == 0 || 0) {
	    open(F,">$scp_file");
	    print F "$wav cat ./$wav |\n";
	    close(F);
	    system("wav-to-duration --read-entire-file=false scp:$scp_file ark,t:$dur_file  > /tmp/0000 2>&1");
	    $sz2= -s $dur_file;
	    if($sz2 < length($wav) ) {
		    open(X,">>bad_wav_files");
		    print X "$dir/$wav\n";
		    close(X);
		    unshift(@bad_wav,"$dir/$wav");
	    };
	    print "!";
    } else {
	    print ".";
    }
  };
  print "\n";

  if($wav_count != $valid_json_count && $valid_json_count>0) {
	  print  " has_bad_json_or_wav_files $dir ************************************** $wav_count != $valid_json_count \n";
	  open(F,">has_bad_json_or_wav_files");
	  close(F);
  };

  chdir "..";

}

print "bad_json\n";
print join("\n",@bad_json),"\n";
print "bad_wav\n";
print join("\n",@bad_wav),"\n";

