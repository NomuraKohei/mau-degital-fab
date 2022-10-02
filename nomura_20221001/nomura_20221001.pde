// arduinoとの通信
import processing.serial.*;
Serial myPort;

// 動画
import processing.video.*;
Movie myMovie;

// 音声
import ddf.minim.*;
Minim minim;
AudioPlayer player;

// 利用する変数の初期化
float nowRole = 0;
float currentTime = 0.0;
float cuttedTime = 0.0;
float rollCounter = 0.0;
int pausingMiliSeconds = 0;
float reverseTime = 0;
Boolean isRevese = false;
Boolean isPlay20cm = false;
Boolean isPlay70cm = false;
Boolean isPlay80cm = false;
Boolean isPlay90cm = false;
 
 void setup() {
   fullScreen(2);
   // Arduinoと通信
   String portName = Serial.list()[2];
   myPort = new Serial(this, portName, 9600);
   // 動画の準備
   myMovie = new Movie(this, "broken.mp4");
   myMovie.play();
   // 音声の準備
   minim = new Minim(this);
   player = minim.loadFile("./data/sounds/20cm.mp3");
   // 背景の補完
   background(31,31,36);
 }
 
 void serialEvent(Serial myPort) {
   int newLine = 13; // 改行文字のASCIIコード（CR）
   String message;
   do {
     message = myPort.readStringUntil(newLine); // 1行分のデータを読み取る
     if (message != null) {
       String[] list = split(trim(message), ",");
       rollCounter = float(list[0]);
       nowRole = rollCounter - cuttedTime;
       print("今まで使ったイレットペーパーの長さ(mm): ");
       println(rollCounter);
       print("現在使ったトイレットペーパーの長さ(mm): ");
       println(nowRole);
       myMovie.play();
       myMovie.jump(myMovie.duration() * nowRole/900);
       myMovie.pause();
       
       // sound判定
       if(nowRole > 200 && isPlay20cm == false){
         player = minim.loadFile("./data/sounds/20cm.mp3");
         player.play();
         player.rewind();
         isPlay20cm = true;
       } else if(nowRole > 700 && isPlay70cm == false){
         player = minim.loadFile("./data/sounds/70cm.mp3");
         player.play();
         player.rewind();
         isPlay70cm = true;
       } else if(nowRole > 800 && isPlay80cm == false){
         player = minim.loadFile("./data/sounds/80cm.mp3");
         player.play();
         player.rewind();
         isPlay80cm = true;
       } else if(nowRole > 900 && isPlay90cm == false){
         player = minim.loadFile("./data/sounds/90cm.mp3");
         player.play();
         player.rewind();
         isPlay90cm = true;
       }
     }
  } while (message != null);
}

void draw() { 
 // Arduinoの情報を取得し、植物を枯れされる
  serialEvent(myPort);
  
 // 動画の読み込み
 if (myMovie.available()) {
    myMovie.read();
 }
 
 // トイレットペーパーを引いてない時の処理
 if(myMovie.time() > 0.0){
    myMovie.pause();
    // 動画の時間が変化がないときは、pausingMiliSecondsを+1する
    if(currentTime == myMovie.time()){
      pausingMiliSeconds = pausingMiliSeconds + 1;
    } else {
      currentTime = myMovie.time();
      pausingMiliSeconds = 0;
    }
 }
 
 // 待機時間が150を超えた時、逆再生フラグを建てる
 println(pausingMiliSeconds);
 if(pausingMiliSeconds > 100){
   pausingMiliSeconds = 0;
   cuttedTime = rollCounter;
   reverseTime = myMovie.time();
   isRevese = true;
 }
 
 // 巻き戻せなくなったら、逆再生を解除
 if(reverseTime <= 0.2 && isRevese == true){
   isRevese = false;
   isPlay20cm = false;
   isPlay70cm = false;
   isPlay80cm = false;
   isPlay90cm = false;
   player = minim.loadFile("./data/sounds/20cm.mp3");
   player.rewind();
   myMovie.jump(0.0);
 } 
 
 // 逆再生
 if(reverseTime >= 0.4 && isRevese == true){
   reverseTime = reverseTime - 0.4;
   myMovie.play();
   myMovie.jump(reverseTime);
 }
 
 // 画面幅に応じて拡大・縮小
 scale( float(width) / float(myMovie.width) * 0.81 );
 translate(130, 110);
 
 // 動画の表示
 image(myMovie, 0, 0);
}
 
void movieEvent(Movie m) {
  m.read();
}

void stop() {
  player.close();
  minim.stop();
  super.stop();
}
