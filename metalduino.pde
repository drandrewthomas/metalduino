/*************************************************/
/* Android metal detector in Processing.         */
/* Copyright Andrew Thomas, March 2014.          */
/*                                               */
/* This program is free software: you can        */
/* redistribute it and/or modify it under the    */
/* terms of the GNU General Public License       */
/* as published by the Free Software Foundation, */
/* either version 3 of the License, or (at your  */
/* option) any later version.                    */
/*                                               */
/* This program is distributed in the hope that  */
/* it will be useful, but WITHOUT ANY            */
/* WARRANTY; without even the implied            */
/* warranty of MERCHANTABILITY or FITNESS        */
/* FOR A PARTICULAR PURPOSE.  See the            */
/* GNU General Public License for more details.  */
/*                                               */
/* See http://www.gnu.org/licenses/ for full     */
/* details of licenses.                          */
/*************************************************/

import processing.serial.*;
Serial myPort;
int linefeed=10;
String btString="";
long ltime;
boolean connected=false;
int buffer[]=new int[256];
int calib[]=new int[40];
boolean goneround=false,docalib=true,needcalib=true;
int ind=0,calibcnt=0,offset=0,gmax=100,scale=0;
int freq=0,curval=0,oldpot=-99,maxf=0;
float gx,gy,gw,gh;
float endy=0,scl=1;
boolean gotbut=false;
long buttime=0;

void setup()
{
  size(640,480);
  background(0,0,0);
  println(Serial.list());
  myPort=new Serial(this, Serial.list()[2],9600);
  myPort.bufferUntil(linefeed);
  scl=PApplet.parseFloat(width)/1280;
  textSize(36*scl);
  gx=10; gy=10;
  gw=width-20; gh=height-20;
  ltime=millis()-5000;
}

void draw()
{
  background(0,0,0);
  if((millis()-ltime)<1000) connected=true;
  else connected=false;
  if(connected==true)
  {
    background(0,0,0);
    if(docalib==false)
    {
      drawtimegraph();
      stroke(0,150,0);
      fill(0,150,0);
      textAlign(LEFT,BOTTOM);
      textSize(36*scl);
      text(freq+"Hz",gx+10,gh+gy-5);
      textAlign(LEFT,TOP);
      text("Scale: "+scale,gx+10,gy+10);
      stroke(255,0,0);
      fill(255,0,0);
      textAlign(RIGHT,CENTER);
      textSize(45*scl);
      if(curval>=0)
        text("+"+curval*20+"Hz",gx+gw-15-30,endy);
      else
        text(curval*20+"Hz",gx+gw-15-30,endy);
      line(gx+gw-10-30,endy,gx+gw,endy);
    }
    else
    {
      stroke(255,255,0);
      fill(255,255,0);
      textAlign(CENTER,CENTER);
      textSize(36*scl);
      text("Calibrating...",gx+gw/2,int(gy+gh*0.75f));
    }
  }
  if(connected==false)
  {
    stroke(255,255,0);
    fill(255,255,0);
    textAlign(CENTER,CENTER);
    textSize(36*scl);
    text("Connecting...",gx+gw/2,int(gy+gh*0.75f));
  }
  if(needcalib==true && docalib==false)
  {
    stroke(255,0,0);
    fill(255,0,0);
    textAlign(CENTER,CENTER);
    textSize(24*scl);
    text("Calibration needed",gx+gw/2,int(gy+gh*0.75f));
  }
}

void drawtimegraph()
{
  boolean ft=true;
  int c,os=0,num=0,xp=0,numneg=0;
  float ax1=0,ay1=0,ax2=0,ay2=0;
  maxf=-99999;
  strokeWeight(1);
  stroke(0,255,0);
  if(goneround==true)
  {
    num=buffer.length;
    os=0;
  }
  else
  {
    num=ind;
    os=buffer.length-ind;
  }
  for(c=0;c<num;c++)
  {
    if(buffer[c]<0 && abs(buffer[c])>20) numneg++;
    if(buffer[c]>maxf) maxf=buffer[c];
    if(goneround==true) xp=c+ind;
    else xp=c;
    if(xp>=buffer.length) xp-=buffer.length;
    if(ft==true)
    {
      ax1=gx+(map((float)(c+os),0,(float)(buffer.length-1),0,gw));
      ay1=map(constrain(buffer[xp],0,gmax),0,gmax,0,gh);
      ft=false;
    }
    else
    {
      ax2=gx+(map((float)(c+os),0,(float)(buffer.length-1),0,gw));
      ay2=map(constrain(buffer[xp],0,gmax),0,gmax,0,gh);
      strokeWeight(3);
      stroke(255,200,0);
      line(ax1,gy+gh-ay1,ax2,gy+gh-ay2);
      ax1=ax2;
      ay1=ay2;
    }
  }
  endy=gy+gh-ay2;
  if(endy<(gy+20)) endy=gy+20;
  if(endy>(gy+gh-20)) endy=gy+gh-20;
  if(numneg>10) needcalib=true;
  maxf*=20;
}

void dobtline()
{
  int bits[];
  int dir,l,c,t=0;
  float rv=0,tv=0,cv=0;
  if(btString!=null)
  {
    bits=int(split(btString,","));
    if(bits.length==5)
    {
      if(docalib==true)
      {
        rv=float(bits[0]);
        tv=float(bits[1]);
        cv=rv*(50000/tv);
        freq+=cv;
        calib[calibcnt]=int(cv);
        calibcnt++;
        if(calibcnt==calib.length)
        {
          for(c=0;c<calib.length;c++) t+=calib[c];
          offset=t/calib.length;
          goneround=false;
          ind=0;
          freq=(freq/calib.length)*20;
          docalib=false;
          needcalib=false;
          calibcnt=0;
        }
      }
      else
      {
        rv=float(bits[0]);
        tv=float(bits[1]);
        cv=rv*(50000/tv);
        buffer[ind]=int(cv)-offset;
        curval=buffer[ind];
        if(abs(bits[3]-oldpot)>2)
        {
          oldpot=bits[3];
          gmax=int(map(bits[3],0,1023,50,500));
          scale=int(map(bits[3],0,1023,1,100));
        }
        ind++;
        if(ind>=buffer.length)
        {
          goneround=true;
          ind=0;
        }
        if(bits[2]==0 && gotbut==false)
        {
          gotbut=true;
          buttime=millis();
        }
        if(bits[2]==1 && gotbut==true)
        {
          if((millis()-buttime)>2000)
          {
            docalib=true;
            freq=0;
          }
          gotbut=false;
        }
      }
    }
  }
  ltime=millis();
}

void keyPressed()
{
  if(key=='s') saveFrame("metalduino.png");
}


void serialEvent(Serial myPort)
{
  btString=myPort.readStringUntil(linefeed);
  if(btString != null)
  {
    dobtline();
  }
}




