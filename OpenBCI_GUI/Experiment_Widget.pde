
//////////////////////////////////////////////////////////////
//
// This class creates and manages the head-shaped plot used by the GUI.
// The head includes circles representing the different EEG electrodes.
// The color (brightness) of the electrodes can be adjusted so that the
// electrodes' brightness values dynamically reflect the intensity of the
// EEG signal.  All EEG processing must happen outside of this class.
//
// Created: Irene Vigue Guix, August 2016
//
// Note: This routine uses aliasing to know which data should be used to
// set the brightness of the electrodes.
//
///////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
//                       Global Variables & Instances
//------------------------------------------------------------------------

//------------------------------------------------------------------------
//                       Global Functions
//------------------------------------------------------------------------

//void toggleShowPolarity() {
//  gui.headPlot1.use_polarity = !gui.headPlot1.use_polarity;
//  //update the button
//  gui.showPolarityButton.but_txt = "Polarity\n" + gui.headPlot1.getUsePolarityTrueFalse();
//}

//------------------------------------------------------------------------
//                            Classes
//------------------------------------------------------------------------

Experiment_Widget experiment_widget;
ControlP5 cp5_Experiment_Widget;

// Dropdown Lists
List CueTimeList = Arrays.asList("1", "2", "3", "4", "5");
List SessionList = Arrays.asList("New Experiment", "Motor Imagery", "MI vs ME", "Emotion Recognition");
List NumTrialsList = Arrays.asList("10", "20", "30", "40", "50", "75", "100");
List IntertrialList = Arrays.asList("None", "1", "2");
List RandomList = Arrays.asList("Random", "Non Random");
List EmotionList = Arrays.asList("Anger", "Disgust", "Fear", "Happiness", "Sadness", "Surprise");

// Experiment
int NumberTrials = 10;
int IntertrialTime = 1;
int Cue = 2;
boolean Randomness;
int Session = 0;
boolean Session_NE = false;
boolean Session_MI = false;
boolean Session_MIvsME = false;
boolean Session_ER = false;
boolean b = false;
boolean open = true;
boolean close = false;
int CueTiming;
int IntertrialTiming;
int i = 0;

// Buttons
Button Start;
Button Stop;
boolean StartButtonPressed = false;
boolean StopButtonPressed = false;

//Tasks
StringList MI_task;
int random_MI_task;
StringList MIvsME_task;
int random_MIvsME_task;
int count = 1;

//Send Serial Char
char serialchar_f;
char serialchar_g;
char serialchar_k;
char serialchar_l;
boolean sendf = false;
boolean sendg = false;
boolean sendk = false;
boolean sendl = false;

// Text and Colors
color green;
color red;
color softgray;
color darkgray;
PFont myFont;
color darkred;
color darkgreen;

// Timing
boolean TestRunning = false;
int startingTime;
int seconds;
int minutes;
int onlysecs; 
int ThisTime;
int bonusTime = 0;
int sec;
int min;
int countdown;

class Experiment_Widget {

  int x, y, w, h; 
  int parentContainer = 3;

  // Fonts
  PFont f = createFont("Arial Bold", 24); //for "FFT Plot" Widget Title
  PFont f2 = createFont("Arial", 18); //for dropdown name titles (above dropdown widgets)

  //constructor 1
  Experiment_Widget(PApplet _parent) {
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    cp5_Experiment_Widget = new ControlP5(_parent);

    //setup dropdown menus
    setupDropdownMenus(_parent);
    setupButtons(_parent);
    setupExperiment(_parent);
  }

  void setupButtons(PApplet _parent) {
    darkred = color(150, 0, 0);
    darkgreen = color(0, 160, 100);
    softgray = color(240, 240, 240);
    darkgray = color(200, 200, 200);
    textFont(f2);
    Start = new Button(int(x+50), int(y+50), 60, 25, "Start", 12);
    Stop = new Button(int(x+100), int(y+50), 60, 25, "Stop", 12);
    Start.setColorPressed(darkgray);
    Start.setColorNotPressed(darkgreen);
    Stop.setColorPressed(darkgray);
    Stop.setColorNotPressed(darkred);
  }

  public void setupExperiment(PApplet _parent) {
    //Tasks
    MI_task = new StringList();
    MI_task.append("Move Right Finger"); //(0)
    MI_task.append("Move Left Finger"); //(1)
    MI_task.append("Imagine moving Right Finger"); //(2)
    MI_task.append("Imagine moving Left Finger"); //(3)
    random_MI_task = int(random(0, 4));

    MIvsME_task = new StringList();
    MIvsME_task.append("Imagine moving Right Finger"); //(0)
    MIvsME_task.append("Imagine moving Left Finger"); //(1)
    MIvsME_task.append("Imagine moving Right Hand"); //(2)
    MIvsME_task.append("Imagine moving Left Hand"); //(3)
    MIvsME_task.append("Imagine moving Right Arm"); //(4)
    MIvsME_task.append("Imagine moving Left Arm"); //(5)
    MIvsME_task.append("Imagine moving Right Foot"); //(6)
    MIvsME_task.append("Imagine moving Left Foot"); //(7)
    random_MIvsME_task = int(random(0, 8));
  }


  void setupDropdownMenus(PApplet _parent) {
    //ControlP5 Stuff
    int dropdownPos;
    int dropdownWidth = 60;
    cp5_colors = new CColor();
    cp5_colors.setActive(color(150, 170, 200)); //when clicked
    cp5_colors.setForeground(color(125)); //when hovering
    cp5_colors.setBackground(color(255)); //color of buttons
    cp5_colors.setCaptionLabel(color(1, 18, 41)); //color of text
    cp5_colors.setValueLabel(color(0, 0, 255));

    cp5_Experiment_Widget.setColor(cp5_colors);
    cp5_Experiment_Widget.setAutoDraw(false);

    //-------------------------------------------------------------
    //EXPERIMENT: NEW EXPERIMENT OR OTHERS BY DEFAULT
    //-------------------------------------------------------------
    //dropdownPos = 4; //work down from 4 since we're starting on the right side now...
    //cp5_Experiment_Widget.addScrollableList("Experiment")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-((dropdownWidth)*(dropdownPos+1))-(2*(dropdownPos+1))-50, navHeight+(y+2)) //float right
    //  .setOpen(false)
    //  .setSize(dropdownWidth + 50, (maxFreqList.size()+1)*(navBarHeight-4))
    //  .setScrollSensitivity(0.0)
    //  .setBarHeight(navHeight - 4)
    //  .setItemHeight(navHeight - 4)
    //  .addItems(ExperimentList)
    //  // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    //  ;

    //cp5_Experiment_Widget.getController("Experiment")
    //  .getCaptionLabel()
    //  //.setPosition(x+w-((dropdownWidth)*(dropdownPos+1))-(2*(dropdownPos+1))-40, navHeight+(y+2)) //float right
    //  .setText("New Experiment")
    //  //.setFont(controlFonts[0])
    //  .setSize(12)
    //  .getStyle()
    //  //.setPaddingTop(4)
    //  ;
    //-------------------------------------------------------------
    //TYPE OF SESSION
    //-------------------------------------------------------------
    dropdownPos = 4;
    cp5_Experiment_Widget.addScrollableList("Session")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))-50, navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth +50, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(SessionList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_Experiment_Widget.getController("Session")
      .getCaptionLabel()
      .setText("Select")
      //.setPosition(x+w-((dropdownWidth)*(dropdownPos+1))-(2*(dropdownPos+1))-40, navHeight+(y+2)) //float right
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;

    //-------------------------------------------------------------
    // NUMBER OF TRIALS
    //-------------------------------------------------------------
    dropdownPos = 3;
    cp5_Experiment_Widget.addScrollableList("NumTrials")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(NumTrialsList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_Experiment_Widget.getController("NumTrials")
      .getCaptionLabel()
      .setText("10")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;

    //-------------------------------------------------------------
    // CUE TIME
    //-------------------------------------------------------------
    dropdownPos = 2;
    cp5_Experiment_Widget.addScrollableList("CueTime")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(CueTimeList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_Experiment_Widget.getController("CueTime")
      .getCaptionLabel()
      .setText("2")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;

    //-------------------------------------------------------------
    // INTERTRIAL
    //-------------------------------------------------------------
    dropdownPos = 1;
    cp5_Experiment_Widget.addScrollableList("Intertrial")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(IntertrialList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_Experiment_Widget.getController("Intertrial")
      .getCaptionLabel()
      .setText("1")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;
    //-------------------------------------------------------------
    // RANDOM VS NON RANDOM
    //-------------------------------------------------------------
    dropdownPos = 0;
    cp5_Experiment_Widget.addScrollableList("Emotion")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
      .setOpen(false)
      //.setBarVisible(false)
      .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      .setScrollSensitivity(0.0)
      .setBarHeight(navHeight - 4)
      .setItemHeight(navHeight - 4)
      .addItems(EmotionList)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    cp5_Experiment_Widget.getController("Emotion")
      .getCaptionLabel()
      .setText("Select")
      //.setFont(controlFonts[0])
      .setSize(12)
      .getStyle()
      //.setPaddingTop(4)
      ;

    //-------------------------------------------------------------
    // EMOTION
    //-------------------------------------------------------------
    //dropdownPos = 0;
    //cp5_Experiment_Widget.addScrollableList("Emotion")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2))
    //  .setOpen(false)
    //  //.setBarVisible(false)
    //  .setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
    //  .setScrollSensitivity(0.0)
    //  .setBarHeight(navHeight - 4)
    //  .setItemHeight(navHeight - 4)
    //  .addItems(EmotionList)
    //  // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    //  ;

    //cp5_Experiment_Widget.getController("Emotion")
    //  .getCaptionLabel()
    //  .setText("Select")
    //  //.setFont(controlFonts[0])
    //  .setSize(12)
    //  .getStyle()
    //  //.setPaddingTop(4)
    //  ;
    //-------------------------------------------------------------
  }

  void update() {

    //update position/size of FFT Plot
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    //experiment_widget.update();
  }

  void draw() {
    pushStyle();
    noStroke();

    //*********************************************** Dropdown buttons *******************************************

    fill(255);
    rect(x, y, w, h); //widget background
    fill(150, 150, 150);
    rect(x, y, w, navHeight); //top bar
    fill(200, 200, 200);
    rect(x, y+navHeight, w, navHeight); //button bar
    fill(255);
    rect(x+2, y+2, navHeight-4, navHeight-4);
    fill(240, 240, 240);
    rect(x, y+navHeight+20, w, navHeight+20); //Trial bar
    fill(bgColor, 100);
    //rect(x+3,y+3, (navHeight-7)/2, navHeight-10);
    rect(x+4, y+4, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+4, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+((navHeight-10)/2)+5, y+4, (navHeight-10)/2, (navHeight-10)/2);
    rect(x+((navHeight-10)/2)+5, y+((navHeight-10)/2)+5, (navHeight-10)/2, (navHeight-10 )/2);
    //text("FFT Plot", x+w/2, y+navHeight/2)
    fill(bgColor);
    textAlign(LEFT, CENTER);
    textFont(f);
    textSize(18);
    text("Experiment", x+navHeight+2, y+navHeight/2 - 2); //left

    //draw dropdown titles
    int dropdownPos = 4; //used to loop through drop down titles ... should use for loop with titles in String array, but... laziness has ensued. -Conor
    int dropdownWidth = 60;
    textFont(f2);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    fill(bgColor);
    //text("Start", x+w-(dropdownWidth), y+(navHeight-2));
    dropdownPos = 2;
    text("Cue Time", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 4;
    text("Session", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    //dropdownPos = 3;
    //text("# Chan.", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 3;
    text("Num Trials", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    dropdownPos = 1;
    text("Intertrial", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    //if (Session.getItem(1)) {
    //if (NoRandomness){
    dropdownPos = 0;
    text("Emotion", x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1))+dropdownWidth/2, y+(navHeight-2));
    //}
    //************************************************ Experiment ************************************************



    // ********************************** Test is not running ********************************

    // TEST IS NOT RUNNING YET
    if (!TestRunning) {
      //textFont(f1);
      textSize(20);
      textAlign(LEFT, TOP);
      text("Time " + " " + "-" + " " + "00" + ":" + "00", x+230, y+50);
      text("Trial" + " " + "-" + " " + "00" + "/" + "00", x+380, y+50);
    } // End Test not Running

    // Timing
    ThisTime = (millis() - startingTime);
    seconds = ThisTime / 1000;
    minutes = seconds / 60;
    onlysecs = seconds - 60*minutes;
    sec = 60 - onlysecs;
    min = (countdown - minutes);
    countdown = 2;
    CueTiming = Cue*1000 + 4000;
    IntertrialTiming = IntertrialTime*1000 + CueTiming;

    // ********************************** Test is running ********************************

    if (TestRunning) {            
      textSize(20);
      textAlign(LEFT, TOP);

      // Time and Trials 
      if (onlysecs < 10) {
        text("Time " + " " + "-" + " " + ((minutes) + ":" + "0" + (onlysecs)), x+230, y+50);
      } else {
        text("Time " + " " + "-" + " " + ((minutes) + ":" + (onlysecs)), x+230, y+50);
      }
      if (count < 10) {
        text("Trial" + " " + "-" + " " + "0" + (count) + "/" + (NumberTrials), x+380, y+50);
      } else {
        text("Trial" + " " + "-" + " " + (count) + "/" + (NumberTrials), x+380, y+50);
      }

      //************************************************TRIALS******************************************************+

      //READY - 1000 ms
      //3 - 1000 ms
      //2 - 1000 ms
      //1 - 1000 ms
      //CUE (CueTime) - CueTime*1000 ms
      //REST (Intertrial) - Intertrial*1000 ms
      //count (NumTrials)  

      if (ThisTime < 1000) {
        textAlign(CENTER);   
        textSize(30);
        fill(darkgreen);
        text("READY", x+250, y+210);
      }

      if ((1000 < ThisTime) && (ThisTime < 2000)) {
        textAlign(CENTER);
        textSize(30);
        fill(darkgray);
        text("3", x+250, y+210);
      }

      if ((2000 < ThisTime) && (ThisTime < 3000)) {
        textAlign(CENTER);
        textSize(30);
        fill(darkgray);
        text("2", x+250, y+210);
      }

      if ((3000 < ThisTime) && (ThisTime < 4000)) {
        textAlign(CENTER);
        textSize(30);
        fill(darkgray);
        text("1", x+250, y+210);
      }

      if ((4000 < ThisTime) && (ThisTime < CueTiming)) {
        textAlign(CENTER);
        fill(0);

        if (Session_NE) { // Sessions New Experiment or Emotion Recognition
          textSize(30);
          text("CUE", x+250, y+210);
        }

        if (Session_MI) { // Start MI session

          String item = MI_task.get(random_MI_task);
          textSize(20);
          text(item, x+250, y+210);
          //switch (random_MI_task) {
          //case 0:
          //  text(item, x+240, y+190);
          //  break;
          //case 1:
          //  text(item, x+240, y+190);
          //  break;
          //case 2:
          //  text(item, x+240, y+190);
          //  break;
          //case 3:
          //  text(item, x+240, y+190);
          //  break;
          //}
        } // End MI session

        if (Session_MIvsME) { // Start MIvsME session
          String item = MIvsME_task.get(random_MIvsME_task);
          textSize(20);
          text(item, x+250, y+210);
          //switch (random_MIvsME_task) {
          //case 0:
          //  text(item, x+240, y+190);
          //  break;
          //case 1:
          //  text(item, x+240, y+190);
          //  break;
          //case 2:
          //  text(item, x+240, y+190);
          //  break;
          //case 3:
          //  text(item, x+240, y+190);
          //  break;
          //case 4:
          //  text(item, x+240, y+190);
          //  break;
          //case 5:
          //  text(item, x+240, y+190);
          //  break;
          //case 6:
          //  text(item, x+240, y+190);
          //  break;
          //case 7:
          //  text(item, x+240, y+190);
          //  break;
          //}
        }

        if (Session_ER) { // Sessions New Experiment or Emotion Recognition
          textSize(30);
          text("CUE", x+250, y+210);
        }
      } // End MIvsME session

      if ((CueTiming < ThisTime) && (ThisTime < IntertrialTiming)) {
        textAlign(CENTER);
        fill(darkgray);
        textSize(30);
        text("REST", x+250, y+210);
      }

      if (ThisTime > IntertrialTiming) {
        count ++;
        i = i+1;
        bonusTime = 0;

        if (count < NumberTrials+1) {
          startingTime = millis();
          //sendf = true;
          //sendg = true;
          //sendk = true;
          //sendl = true;

          println("Back to beginning...");
        } else {
          TestRunning = false;
          println("Final trial finished...");
        }
      }
    } // End Test Running

    Start.draw(int(x+15), int(y+50));
    Stop.draw(int(x+90), int(y+50));

    cp5_Experiment_Widget.draw(); //draw all dropdown menus

    popStyle();
  }

  void screenResized(PApplet _parent, int _winX, int _winY) {
    //when screen is resized...
    //update Head Plot widget position/size
    x = (int)container[parentContainer].x;
    y = (int)container[parentContainer].y;
    w = (int)container[parentContainer].w;
    h = (int)container[parentContainer].h;

    //update position of headplot
    //experiment_widget.setPositionSize(x, y, w, h, width, height);

    cp5_Experiment_Widget.setGraphics(_parent, 0, 0); //remaps the cp5 controller to the new PApplet window size

    //update dropdown menu positions
    int dropdownPos;
    int dropdownWidth = 60;
    dropdownPos = 2; //work down from 4 since we're starting on the right side now...
    cp5_Experiment_Widget.getController("CueTime")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 4; //work down from 4 since we're starting on the right side now...
    cp5_Experiment_Widget.getController("Session")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    //dropdownPos = 3;
    //cp5_Experiment_Widget.getController("NumChan")
    //  //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
    //  .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
    //  //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
    //  ;
    dropdownPos = 3;
    cp5_Experiment_Widget.getController("NumTrials")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 1;
    cp5_Experiment_Widget.getController("Intertrial")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
    dropdownPos = 0;
    cp5_Experiment_Widget.getController("Emotion")
      //.setPosition(w-(dropdownWidth*dropdownPos)-(2*(dropdownPos+1)), navHeight+(y+2)) // float left
      .setPosition(x+w-(dropdownWidth*(dropdownPos+1))-(2*(dropdownPos+1)), navHeight+(y+2)) //float right
      //.setSize(dropdownWidth, (maxFreqList.size()+1)*(navBarHeight-4))
      ;
  }

  void mousePressed() {

    if (Start.isMouseHere()) {
      Start.setIsActive(true);
      StartButtonPressed = true;
      Stop.setIsActive(false);
      if (!TestRunning) {
        TestRunning = true;
        startingTime = millis();
      }
    }
    if (Stop.isMouseHere()) {
      Stop.setIsActive(true);
      StopButtonPressed = true;
      Start.setIsActive(false);
      if (TestRunning) {
        TestRunning = false;
        startingTime = millis();
        count = 0;
      }
    }
  }
}
//}



//triggered when there is an event in the Headset Dropdown
void Session (int n) {
  println(n, cp5_Experiment_Widget.get(ScrollableList.class, "Session").getItem(n));
  switch (n) {
  case 0:
    cp5_Experiment_Widget.get(ScrollableList.class, "Emotion").setBarVisible(false);
    Session_NE = true;
    Session_MI = false;
    Session_MIvsME = false;
    Session_ER = false;
    break;
  case 1:
    cp5_Experiment_Widget.get(ScrollableList.class, "Emotion").setBarVisible(false);
    Session_NE = false;
    Session_MI = true;
    Session_MIvsME = false;
    Session_ER = false;
    break;
  case 2:
    cp5_Experiment_Widget.get(ScrollableList.class, "Emotion").setBarVisible(false);
    Session_NE = false;
    Session_MI = false;
    Session_MIvsME = true;
    Session_ER = false;
    break;
  case 3:
    cp5_Experiment_Widget.get(ScrollableList.class, "Emotion").setBarVisible(true);
    Session_NE = false;
    Session_MI = false;
    Session_MIvsME = false;
    Session_ER = true;
    break;
  }
}

//triggered when there is an event in the NumChan Dropdown
void NumTrials (int n) {
  println(n, cp5_Experiment_Widget.get(ScrollableList.class, "NumTrials").getItem(n));
  switch (n) {
  case 0:
    NumberTrials = 10;
    break;
  case 1:
    NumberTrials = 20;
    break;
  case 2:
    NumberTrials = 30;
    break;
  case 3:
    NumberTrials = 40;
    break;
  case 4:
    NumberTrials = 50;
    break;
  case 5:
    NumberTrials = 75;
    break;
  case 6:
    NumberTrials = 100;
    break;
  }
}

void CueTime (int n) {
  println(n, cp5_Experiment_Widget.get(ScrollableList.class, "CueTime").getItem(n));
  //CueTime = n+1;
  switch (n) {
  case 0:
    Cue = 1;
    break;
  case 1:
    Cue = 2;
    break;
  case 2:
    Cue = 3;
    break;
  case 3:
    Cue = 4;
    break;
  case 4:
    Cue = 5;
    break;
  }
  //println(Cue);
}

//triggered when there is an event in the Polarity Dropdown
void Intertrial(int n) {
  println(n, cp5_Experiment_Widget.get(ScrollableList.class, "Intertrial").getItem(n));
  switch (n) {
  case 0:
    IntertrialTime = 0;
    break;
  case 1:
    IntertrialTime = 1;
    break;
  case 2:
    IntertrialTime = 2;
    break;
  }
}

void Random (int n) {
  println(n, cp5_Experiment_Widget.get(ScrollableList.class, "Random").getItem(n));
  switch (n) {
  case 0:
    Randomness = true;
    break;
  case 1:
    Randomness = false;
    break;
  }
  //if (n==0) {
  //  Randomness = true;
  //} else {
  //  if (n==1) {
  //    Randomness = false;
  //  }
  //}
}

void Emotion (int n) {
  println(n, cp5_Experiment_Widget.get(ScrollableList.class, "Emotion").getItem(n));
  //switch (n) {
  //case 0:
  //  E = true;
  //  break;
  //case 1:
  //  E = false;
  //  break;
  //}
}