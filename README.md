1. VOSK 디렉토리 설명
 
zeroth 와 훈련 데이터 디렉토리 구조 차이:
    vosk: speaker/chapter/wav
    zeroth: speaker/wav
    trans.txt 파일 이름에 하이픈(-)이 사용되는 점 외에는 zeroth 와 동일 

/home/ubuntu/vosk-api/training/train_data: aihub 원천 데이터 
/home/ubuntu/vosk-api/training/db:   훈련 데이터 서브디렉토리가 들어갈 자리 
/home/ubuntu/vosk-api/training/data: 훈련 데이터 후처리 정보(wav 길이,성별) 서브디렉토리가 들어갈 자리 

2. 훈련용 데이터 디렉토리 설명: 생성 및 검증됨 

zeroth recipie 의 경우와 같은 서브디렉토리 구조를 가짐 

./db/aihub1 : (수도권 , 나이 10살 )
./db/aihub2 : (수도권 , 나이 3 ~ 10살, 즉 전체 연령군 )

검증용 데이터 디렉토리 설명 : 생성 및 검증됨 

./db/aihub1test : (수도권 , 나이 9살 )
./db/aihub2test : (수도권 , 나이 8,9살 )


3. 추가된 스크립트 설명 

아래 이외의 vosk 스크립트 파일들은 변경되지 않음 
/home/ubuntu/vosk-api/training/ 에 위치하는 스크립트들 

./untar_text.sh : aihub .json 파일들 압축해제 
./untar_wav.sh : aihub .wav 파일들 압축해제
./wav.pl : 원천 데이터의 json 파일에서 stt text 정보를 얻어서, .trans.txt 를 각 스피커 디렉토리 밑에 하나씩 만드는 역할, 오류있는 .wav 검출
./sel1_vosk.pl : db/aihub1 훈련 데이터 준비 ( 수도권 전체  나이 10살), prepare_aihub1.sh 에 의해 호출됨
./sel1_test_vosk.pl : db/aihub1test 검증 데이터 준비 ( 수도권 나이 9살), prepare_aihub1test.sh 에 의해 호출됨 
./sel2_vosk.pl : db/aihub2 훈련 데이터 준비 ( 수도권 전체  나이 3 ~ 10살, 즉 수도권 전체), prepare_aihub2.sh 에 의해 호출됨 
./sel2_test_vosk.pl : db/aihub2test 검증 데이터 준비 ( 수도권 나이 8,9살), prepare_aihub2test.sh 에 의해 호출됨 
./prepare_aihub1.sh : 데이터 준비, 밸리데이션 수행 
./prepare_aihub1test.sh : 데이터 준비, 밸리데이션 수행 
./prepare_aihub2.sh : 데이터 준비, 밸리데이션 수행 
./prepare_aihub2test.sh : 데이터 준비, 밸리데이션 수행 
./local/data_prep_vosk.sh : db/aihub[12] 데이터 디렉토리를 처리하여 data/aihub[12] 후처리 정보 디렉토리 채움 (wav 길이, 성별 데이터 등)
./run_1_vosk.sh : aihub1, aihub1test 로 훈련 및 검증 수행 
./run_2_vosk.sh : aihub2, aihub2test 로 훈련 및 검증 수행 

