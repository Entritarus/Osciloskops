import processing.serial.*;

final int divLength = 40;
final int topLimit = 20;
final int leftLimit = 40;
final int bottomLimit = topLimit+divLength*10;
final int rightLimit = leftLimit+divLength*20;
final int middleX = leftLimit+divLength*10;
final int middleY = topLimit+divLength*5;
float[] dataArray = new float[101];
float[] positionArray = new float[101];
int dataIndex = 0;
float VDIV = 1.0f;
float TDIV = 1.0f;
int XOFFSET = 0;
int YOFFSET = 0;
long last;
int status = 1;
int frequency = 2;
Serial port;

void setup() {
  size(880,560);
  fill(255);
  
  drawScope();
  for (int i = 0; i < 101; i++) {
    dataArray[i] = 0;
    positionArray[i] = 0;
  }
  printArray(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  frameRate(120);
  last = millis();
}

void draw() {
  background(200);
  drawScope();
  if (status == 1)
    if (millis() - last > TDIV*1000/5)
    {
      getData();
      last = millis();
    }
  
  drawData();
}

void drawData() {
  for(int i = 0; i < 101; i++) {
    positionArray[i] = dataArray[i]*divLength/VDIV+YOFFSET*divLength/5;
  }
  stroke(255,0,0);
  for (int i = 0; i < 100; i++) {
    if(i-XOFFSET < 100 && i-XOFFSET >= 0)
      if (middleY-positionArray[i-XOFFSET] > topLimit && middleY-positionArray[i-XOFFSET] < bottomLimit)
        if (middleY-positionArray[i-XOFFSET+1] > topLimit && middleY-positionArray[i-XOFFSET+1] < bottomLimit)
          line(leftLimit+divLength/5*i, middleY-positionArray[i-XOFFSET], leftLimit+divLength/5*(i+1), middleY-positionArray[i-XOFFSET+1]);
  }
  stroke(0);
}
int reading = 0;
void getData() {
  if(port.available() > 0) {
    reading = port.read();
    dataArray[dataIndex] = reading/256.0f*5;
    dataIndex++;
    if(dataIndex > 100)
      dataIndex = 0;
    port.clear();
  }
}

void drawScope() {
  line(leftLimit, middleY, rightLimit, middleY); // Y axis
  line(middleX, topLimit, middleX, bottomLimit); // X axis
  
  for(int i = 0; i < 20; i++) { // X axis subdivisions
    line(leftLimit + divLength*i, middleY-7, leftLimit + divLength*i, middleY+7);
    for(int j = 0; j < 5; j++) {
      line(leftLimit + divLength*i + divLength/5*j, middleY-3, leftLimit + divLength*i + divLength/5*j, middleY+3);
    }
  }
  line(rightLimit, middleY-7, rightLimit, middleY+7);
  
  for(int i = 0; i < 10; i++) { // Y axis subdivisions
    line(middleX-7, topLimit + divLength*i, middleX+7, topLimit + divLength*i);
    for(int j = 0; j < 5; j++) {
      line(middleX-3, topLimit + divLength*i + divLength/5*j, middleX+3, topLimit + divLength*i + divLength/5*j);
    }
  }
  line(middleX-7, bottomLimit, middleX+7, bottomLimit);
  
  textSize(12);
  textAlign(CENTER, BOTTOM);
  text("U, V", middleX, topLimit);
  
  textAlign(LEFT, CENTER);
  text("t, s", rightLimit+5, middleY);
  
  //buttons 
  textAlign(CENTER,CENTER);
  fill(255);
  for (int i = 0; i < 5; i++) {
    rect(leftLimit+i*100, bottomLimit+45, 50, 25);
    rect(leftLimit+i*100, bottomLimit+95, 50, 25);
  }
  fill(0);
  
  // V/DIV
  text("V/DIV", leftLimit+25, bottomLimit+35);
  text("+", leftLimit+25, bottomLimit+57);
  text("-", leftLimit+25, bottomLimit+107);
  text(VDIV + " V", leftLimit+25, bottomLimit+82);
  
  // T/DIV
  text("T/DIV", leftLimit+125, bottomLimit+35);
  text("+", leftLimit+125, bottomLimit+57);
  text("-", leftLimit+125, bottomLimit+107);
  text(TDIV + " s", leftLimit+125, bottomLimit+82);
  
  // POS X
  text("POS X", leftLimit+225, bottomLimit+35);
  text(">", leftLimit+225, bottomLimit+57);
  text("<", leftLimit+225, bottomLimit+107);
  text((float)XOFFSET/5*TDIV, leftLimit+225, bottomLimit+82);
  
  // POS Y
  text("POS Y", leftLimit+325, bottomLimit+35);
  text("^", leftLimit+325, bottomLimit+57);
  text("v", leftLimit+325, bottomLimit+107);
  text((float)YOFFSET/5*VDIV, leftLimit+325, bottomLimit+82);
  
  text("Frequency", leftLimit+425, bottomLimit+35);
  text("+1 Hz", leftLimit+425, bottomLimit+57);
  text("-1 Hz", leftLimit+425, bottomLimit+107);
  text(frequency + "Hz", leftLimit+425, bottomLimit+82);
  
  if (status == 1) {
    fill(100,255,100);
    rect(leftLimit+500, bottomLimit+45, 75, 75);
    fill(0);
    text("STOP",leftLimit+538, bottomLimit+83);
  }
  if (status == 0) {
    fill(255,100,100);
    rect(leftLimit+500, bottomLimit+45, 75, 75);
    fill(0);
    text("START",leftLimit+538, bottomLimit+83);
  }
}

void mouseClicked() {
  if(mouseY >= bottomLimit+45 && mouseY <= bottomLimit+70) {
    if(mouseX >= leftLimit && mouseX <= leftLimit+50) {
      VDIV *= 2;
    }
    if(mouseX >= leftLimit+100 && mouseX <= leftLimit+150) {
      TDIV *= 2;
    }
    if(mouseX >= leftLimit+200 && mouseX <= leftLimit+250) {
      XOFFSET += 1;
    }
    if(mouseX >= leftLimit+300 && mouseX <= leftLimit+350) {
      YOFFSET += 1;
    }
    if(mouseX >= leftLimit+400 && mouseX <= leftLimit+450) {
      frequency++;
      port.write(50);
    }
  }
  if(mouseY >= bottomLimit+95 && mouseY <= bottomLimit+120) {
    if(mouseX >= leftLimit && mouseX <= leftLimit+50) {
      VDIV /= 2;
    }
    if(mouseX >= leftLimit+100 && mouseX <= leftLimit+150) {
      TDIV /= 2;
    }
    if(mouseX >= leftLimit+200 && mouseX <= leftLimit+250) {
      XOFFSET -= 1;
    }
    if(mouseX >= leftLimit+300 && mouseX <= leftLimit+350) {
      YOFFSET -= 1;
    }
    if(mouseX >= leftLimit+400 && mouseX <= leftLimit+450) {
      frequency--;
      if (frequency <= 0) frequency = 1;
      port.write(100);
    }
  }
  if (mouseY >= bottomLimit+45 && mouseY <= bottomLimit+120) {
    if(mouseX >= leftLimit+500 && mouseX <= leftLimit+575) {
      status = 1 - status;
      port.write(status);
    }
  }
}
