
void setup()
// The special Processing setup() function.
// This function is automatically executed once by Processing, when the program starts.
{
    // Set the size of the window
    frame.setResizable(true);
    size(600, 500);

    // Setup serial communication with the Arduino,
    // the audio output system,
    // and the graph that shows current sensor readings
    setupSerial();
    setupAudio();
    setupSensorGraph();

    // Initially show the oscilloscope (instead of the sensor graph)
    showOscilloscope();
    hideSensorGraph();

    // Execute our own 'setup' function, back on the WarblingJelly tab.
    _setup();
}


void draw()
// The special Processing draw() function.
// This function is automatically executed repeatedly by Processing, about 60 times per second.
//
// Both graphics drawing and sound updating can be done in here.
{
    // Keep up to date with Arduino communications
    doSerial();
    // In case the window was resized, update all the graphics to fit
    relayoutWindow();
    // Draw the sound wave that is currently being sent out to the computer speakers
    drawOscilloscope();
    // Draw the sensor graph
    drawSensorGraph();

    // Execute our own 'draw' function, back on the WarblingJelly tab.
    _draw();
}


void relayoutWindow()
{
    if (g_oscilloscope_isVisible && g_sensorGraph_isVisible)
    {
        positionSensorGraph(0, 0, 600, height);
        positionOscilloscope(600, 0, width - 600, height);
    }
    else if (g_oscilloscope_isVisible && !g_sensorGraph_isVisible)
    {
        positionOscilloscope(0, 0, width, height);
    }
    else if (!g_oscilloscope_isVisible && g_sensorGraph_isVisible)
    {
        positionSensorGraph(0, 0, width, height);
    }
}


void keyPressed()
{
    //println("keyPressed: " + key + ", " + keyCode);

    if (keyCode == 16)  // 16 is the shift key
    {
        warble.noteOn();
    }

    if (keyCode == 'E')
    {
        warble.pulse_envelope.printState();
    }

    if (keyCode == ' ')
    {
        warble.noteToggle();
    }

    if (keyCode == '1')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 0.05, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '2')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 0.1, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '3')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 0.25, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '4')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 0.5, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '5')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 0.75, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '6')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 1.0, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '7')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 1.5, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '8')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 2.0, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '9')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 4.0, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }
    else if (keyCode == '0')
    {
        Warble newWarble = warble.duplicate();
        speaker.playNote(0, 8.0, newWarble);
        if (!warble.noteInProgress())
            warble = newWarble;
    }


    if (keyCode == 'O')
    {
        showOscilloscope();
        hideSensorGraph();
        relayoutWindow();
    }
    else if (keyCode == 'S')
    {
        hideOscilloscope();
        showSensorGraph();
        relayoutWindow();
    }
    else if (keyCode == 'B')
    {
        if (width <= 600)
        {
            frame.setSize(1200, frame.getSize().height);
            width = 1200;
        }
        showSensorGraph();
        showOscilloscope();
        relayoutWindow();
    }
    else if (keyCode == 'L')
    {
        g_logSerialMessages = !g_logSerialMessages;
    }
}

void keyReleased()
{
    //println("keyReleased: " + key + ", " + keyCode);

    if (keyCode == 16)  // 16 is the shift key
    {
        warble.noteOff();
    }
}
