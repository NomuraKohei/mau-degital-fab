import processing.serial.*;
// 動画を扱うためのライブラリをインポート
import processing.video.*;

// 動画
Movie myMovie;

 Serial myPort;
 float nowRole = 0;
 void setup()
 {
   size(600, 600);
   // Arduinoと通信
   printArray(Serial.list());
   String portName = Serial.list()[2];
   myPort = new Serial(this, portName, 9600);
   // 動画の準備
   myMovie = new Movie(this, "sample.mp4");
   myMovie.play();
 }
 
 void serialEvent(Serial myPort) {
   int newLine = 13; // 改行文字のASCIIコード（CR）
   String message;
 do {
     message = myPort.readStringUntil(newLine); // 1行分のデータを読み取る
     if (message != null) {
       String[] list = split(trim(message), ",");
       nowRole = float(list[0]);
       print(nowRole/255/myMovie.duration());
       //print("  ");
       //print(list[1]);
       //print("  ");
       //println(list[2]);
     }
  }  while (message != null);
}

void draw()
 {
   // Arduinoの情報を取得
    serialEvent(myPort);
   // 動画の表示
   if (myMovie.available()) {
    myMovie.read();
   }
   image(myMovie, 0, 0);
 }
 
 void movieEvent(Movie m) {
  m.read();
}

void mousePressed() {
  myMovie.jump(random(myMovie.duration()));
  print(myMovie.duration());
}
