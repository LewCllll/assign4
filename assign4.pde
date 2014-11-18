Ship ship;
PowerUp ruby;
Bullet[] bList;
Laser[] lList;
Alien[] aList;

//Game Status
final int GAME_START   = 0;
final int GAME_PLAYING = 1;
final int GAME_PAUSE   = 2;
final int GAME_WIN     = 3;
final int GAME_LOSE    = 4;
int status;              //Game Status
int point;               //Game Score
int expoInit;            //Explode Init Size
int countBulletFrame;    //Bullet Time Counter
int bulletNum;           //Bullet Order Number
int laserNum;            //Laser Order Number
int alienCount = 0;      //Num of dead alien

/*--------Put Variables Here---------*/


void setup() {
  status = GAME_START; 

  bList = new Bullet[30];
  lList = new Laser[30];
  aList = new Alien[100];

  size(640, 480);
  background(0, 0, 0);
  rectMode(CENTER);      

  ship = new Ship(width/2, 460, 3);
  ruby = new PowerUp(int(random(width)), -10);

  reset();
}

void draw() {
  background(50, 50, 50);
  noStroke();

  switch(status) {

  case GAME_START:
    printText(60, 20, 240, 280);
    break;

  case GAME_PLAYING:
    background(50, 50, 50);
    
    drawHorizon();
    drawScore();
    drawLife();
    ship.display(); //Draw Ship on the Screen
    drawAlien();
    drawBullet();
    drawLaser();

    /*---------Call functions---------------*/
    //cheatKeys();
    checkRubyDrop(200);
    alienShoot(50);
    checkAlienDead();/*finish this function*/
    checkShipHit();  /*finish this function*/

    countBulletFrame+=1;
    break;

  case GAME_PAUSE:
    /*---------Print Text-------------*/
    printText(40, 20, 240, 280);
    /*--------------------------------*/
    break;

  case GAME_WIN:
    /*---------Print Text-------------*/
    printText(40, 20, 300, 340);    
    /*--------------------------------*/
    winAnimate();
    break;

  case GAME_LOSE:
    loseAnimate();
    /*---------Print Text-------------*/
    printText(40, 20, 240, 280);
    /*--------------------------------*/
    break;
  }
}

void drawHorizon() {
  stroke(153);
  line(0, 420, width, 420);
}

void drawScore() {
  noStroke();
  fill(95, 194, 226);
  textAlign(CENTER, CENTER);
  textSize(23);
  text("SCORE:"+point, width/2, 16);
}

void keyPressed() {
  if (status == GAME_PLAYING) {
    ship.keyTyped();
    cheatKeys();
    shootBullet(30);
  }
  statusCtrl();
}

/*---------Make Alien Function-------------*/
void alienMaker(int aNum, int aCol) {
  for(int i = 0; i < aNum; i++){
    for(int j = 0; j < aCol; j++){
      int x = 50 + i % aCol * 40;
      int y = 50 + i / aCol * 50;
      aList[i] = new Alien(x, y);
    }
  }
}

void drawLife() {
  fill(230, 74, 96);
  text("LIFE:", 36, 455);
  /*---------Draw Ship Life---------*/
  switch(ship.life){
  case 3:
  ellipse(78, 459, 15, 15);
  ellipse(103, 459, 15, 15);
  ellipse(128, 459, 15, 15);
  break;
  
  case 2:
  ellipse(78, 459, 15, 15);
  ellipse(103, 459, 15, 15);
  break;
  
  case 1:
  ellipse(78, 459, 15, 15);
  break;
  
  case 0:
  status = GAME_LOSE;
  break;
  }
  
}

void drawBullet() {
  for (int i=0; i<bList.length-1; i++) {
    Bullet bullet = bList[i];
    if (bullet!=null && !bullet.gone) { // Check Array isn't empty and bullet still exist
      bullet.move();     //Move Bullet
      bullet.display();  //Draw Bullet on the Screen
      if (bullet.bY<0 || bullet.bX>width || bullet.bX<0) {
        removeBullet(bullet); //Remove Bullet from the Screen
      }
    }
  }
}

void drawLaser() {
  for (int i=0; i<lList.length-1; i++) { 
    Laser laser = lList[i];
    if (laser!=null && !laser.gone) { // Check Array isn't empty and Laser still exist
      laser.move();      //Move Laser
      laser.display();   //Draw Laser
      if (laser.lY>480) {
        removeLaser(laser); //Remove Laser from the Screen
      }
    }
  }
}

void drawAlien() {
  for (int i=0; i<aList.length-1; i++) {
    Alien alien = aList[i];
    if (alien!=null && !alien.die) { // Check Array isn't empty and alien still exist
      alien.move();    //Move Alien
      alien.display(); //Draw Alien
      /*---------Call Check Line Hit---------*/
      checkLineHit();
      /*--------------------------------------*/
    }
  }
}

/*--------Check Line Hit---------*/

void checkLineHit(){
  for (int i=0; i<aList.length-1; i++) {
    Alien alien = aList[i];
    if(alien != null && !alien.die){
      if(aList[i].aY > 420){
      status = GAME_LOSE;
    }else{
    }
    }
  }
}

/*---------Ship Shoot-------------*/
void shootBullet(int frame) {
  if ( key == ' ' && countBulletFrame>frame) {
    if (!ship.upGrade) {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, 0);
      if (bulletNum<bList.length-2) {
        bulletNum+=1;
      } else {
        bulletNum = 0;
      }
    } 
    /*---------Ship Upgrade Shoot-------------*/
    else {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, -1);
      bList[bulletNum+1]= new Bullet(ship.posX, ship.posY, -3, 0);
      bList[bulletNum+2]= new Bullet(ship.posX, ship.posY, -3, 1);
      if (bulletNum<bList.length-6) {
        bulletNum += 3;
      } else {
        bulletNum = 0;
      }      
    }
    countBulletFrame = 0;
  }
}

/*---------Check Alien Hit-------------*/
void checkAlienDead() {
  for (int i=0; i<bList.length-1; i++) {
    Bullet bullet = bList[i];
    for (int j=0; j<aList.length-1; j++) {
      Alien alien = aList[j];
      if (bullet != null && alien != null && !bullet.gone && !alien.die &&// Check Array isn't empty and bullet / alien still exist
      bList[i].bX <= aList[j].aX + aList[j].aSize/2 && bList[i].bX >= aList[j].aX - aList[j].aSize/2 &&
      bList[i].bY <= aList[j].aY + aList[j].aSize/2 && bList[i].bY >= aList[j].aY - aList[j].aSize/2) {
      removeBullet(bullet);
      removeAlien(alien);
      point += 10;
      alienCount += 1;
      }
    }
  }
  if(alienCount == 53){
    status = GAME_WIN;
  }
}

/*---------Alien Drop Laser-----------------*/
void alienShoot(int frame) {
  int random = int(random(aList.length - 1));
    if(frameCount % frame == 0){
      Alien alien = aList[random];
      if(alien != null && !alien.die){
        lList[laserNum] = new Laser(aList[random].aX, aList[random].aY);
        if (laserNum<lList.length - 2) {
          laserNum += 1;
        }else{
          laserNum = 0;
        }
      }
    }
}
/*---------Check Laser Hit Ship-------------*/
void checkShipHit() {
  for (int i=0; i<lList.length-1; i++) {
    Laser laser = lList[i];
    if (laser!= null && !laser.gone &&// Check Array isn't empty and laser still exist
    lList[i].lY >= ship.posY - ship.shipSize/4 * 6.6 &&
    lList[i].lX <= ship.posX + ship.shipSize/2 && lList[i].lX >= ship.posX - ship.shipSize/2) {
      removeLaser(laser);
      ship.life -= 1;
    }
  }
}

/*---------Check Win Lose------------------*/

void winAnimate() {
  int x = int(random(128))+70;
  fill(x, x, 256);
  ellipse(width/2, 200, 136, 136);
  fill(50, 50, 50);
  ellipse(width/2, 200, 120, 120);
  fill(x, x, 256);
  ellipse(width/2, 200, 101, 101);
  fill(50, 50, 50);
  ellipse(width/2, 200, 93, 93);
  ship.posX = width/2;
  ship.posY = 200;
  ship.display();
}

void loseAnimate() {
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+200, expoInit+200);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+150, expoInit+150);
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+100, expoInit+100);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+50, expoInit+50);
  fill(50, 50, 50);
  ellipse(ship.posX, ship.posY, expoInit, expoInit);
  expoInit+=5;
}

/*---------Check Ruby Hit Ship-------------*/
void checkRubyDrop(int score){
  if(point >= score){
    ruby.display();
    ruby.move();
  }
  if(ruby.pY >= ship.posY - ship.shipSize/4 * 6.6 &&
     ruby.pX <= ship.posX + ship.shipSize/2 && ruby.pX >= ship.posX - ship.shipSize/2) {
       ruby.pY = 1000;
       ship.upGrade = true;
     }
  
}

/*---------Check Level Up------------------*/


/*---------Print Text Function-------------*/
void printText(int aSize, int bSize, int aY, int bY) {
  
  switch(status){ 
    
    case GAME_START:
    fill(95, 194, 226);
    textAlign(CENTER, CENTER);
    textSize(aSize);
    text("GALIXIAN", 320, aY); 
    textSize(bSize);
    text("Press ENTER to Start", 320, bY);
    break;
    
    case GAME_PAUSE:
    fill(95, 194, 226);
    textSize(aSize);
    text("PAUSE", 320, aY); 
    textSize(bSize);
    text("Press ENTER to Presume", 320, bY);
    break;
    
    case GAME_LOSE:
    fill(95, 194, 226);
    textSize(aSize);
    text("BOOOM", 320, aY); 
    textSize(bSize);
    text("You are dead!!", 320, bY);
    break;
      
    case GAME_WIN:
    fill(95, 194, 226);
    textSize(aSize);
    text("WINNER", 320, aY); 
    textSize(bSize);
    text("Score:"+point, 320, bY);      
    break;
    
  }
  
}

void removeBullet(Bullet obj) {
  obj.gone = true;
  obj.bX = 2000;
  obj.bY = 2000;
}

void removeLaser(Laser obj) {
  obj.gone = true;
  obj.lX = 2000;
  obj.lY = 2000;
}

void removeAlien(Alien obj) {
  obj.die = true;
  obj.aX = 1000;
  obj.aY = 1000;
}

/*---------Reset Game-------------*/
void reset() {
  for (int i=0; i<bList.length-1; i++) {
    bList[i] = null;
    lList[i] = null;
  }

  for (int i=0; i<aList.length-1; i++) {
    aList[i] = null;
  }

  point = 0;
  expoInit = 0;
  countBulletFrame = 30;
  bulletNum = 0;
  laserNum = 0;
  alienCount = 0;

  /*--------Init Variable Here---------*/
  

  /*-----------Call Make Alien Function--------*/
  alienMaker(53, 12);

  ship.posX = width/2;
  ship.posY = 460;
  ship.upGrade = false;
  ruby.show = false;
  ruby.pX = int(random(width));
  ruby.pY = -10;
}

/*-----------finish statusCtrl--------*/
void statusCtrl() {
  
  if (key == ENTER) {
    switch(status) {
      
    case GAME_START:
    status = GAME_PLAYING;
    break;
    case GAME_PLAYING:
    status = GAME_PAUSE;
    break;
    case GAME_PAUSE:
    status = GAME_PLAYING;
    break;
    case GAME_WIN:
    reset();
    status = GAME_PLAYING;
    break;
    case GAME_LOSE:
    reset();
    status = GAME_PLAYING;
    break;
    }
  }  
  
}

void cheatKeys() {

  if (key == 'R'||key == 'r') {
    ruby.show = true;
    ruby.pX = int(random(width));
    ruby.pY = -10;
  }
  if (key == 'Q'||key == 'q') {
    ship.upGrade = true;
  }
  if (key == 'W'||key == 'w') {
    ship.upGrade = false;
  }
  if (key == 'S'||key == 's') {
    for (int i = 0; i<aList.length-1; i++) {
      if (aList[i]!=null) {
        aList[i].aY+=50;
      }
    }
  }
}
