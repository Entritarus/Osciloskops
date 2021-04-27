int frequency = 2;
long last;
void setup() {
  // put your setup code here, to run once:
  pinMode(A5, INPUT);
  DDRD |= 4;
  ADMUX = 0;
  ADCSRA = 0;
  ADCSRB = 0;
  ADMUX |= 0b01000101;
  ADCSRA |= 0b11100111;
  ADCSRB |= 0b00000000;
  Serial.begin(9600);
  last = millis();
}
int reading, status = 1;
void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    reading = Serial.read();
    switch(reading) {
      case 0:
      case 1:
      status = reading;
      break;
      case 50:
      frequency += 1;
      break;
      case 100:
      frequency -= 1;
      if(frequency == 0) frequency = 1;
      break;
    }
  }
  if(status == 1) {
    reading = ADC/4;
    Serial.write(reading);
  }
  if (millis() - last >= 1000/frequency/2) {
    PORTD ^= 4;
    last = millis();
  }
}
