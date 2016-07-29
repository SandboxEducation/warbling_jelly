
import processing.serial.*;


void setup()
{
    frame.setResizable(true);
    size(600, 500);

    enterViewMode(0);
}

// + View mode {{{

int g_viewMode = -1;

void enterViewMode(int i_modeNo)
{
    switch (g_viewMode)
    {
    case 0:
        portListMode_exit();
        break;
    case 1:
        inputMode_exit();
        break;
    }

    g_viewMode = i_modeNo;

    switch (i_modeNo)
    {
    case 0:
        portListMode_enter();
        break;
    case 1:
        inputMode_enter();
        break;
    }
}

// + }}}

// + Port list {{{

int g_portListMode_listTop;
float g_portListMode_itemHeight;
String[] g_portListMode_portNames;

void portListMode_enter()
{
    frameRate(4);
}

void portListMode_exit()
{
}

void portListMode_draw()
{
    //
    int textHeight;
    float linePitch;
    int y = 0;

    // + Heading {{{

    textHeight = 24;
    linePitch = 1.2;
    textSize(textHeight);

    noStroke();
    fill(128, 128, 255, 255);
    y += int(textHeight * linePitch);
    text("Serial ports found on this system:", 10, y);

    // + }}}

    // + Instruction {{{

    textHeight = 12;
    linePitch = 1.5;
    textSize(textHeight);

    noStroke();
    fill(128, 128, 255, 255);
    y += int(textHeight * linePitch);
    text("[Click to view input]", 10, y);

    // + }}}

    // + Ports {{{

    textHeight = 24;
    linePitch = 1.2;
    textSize(textHeight);

    g_portListMode_listTop = y;
    g_portListMode_itemHeight = textHeight * linePitch;

    noStroke();
    fill(224, 224, 224, 255);
    g_portListMode_portNames = processing.serial.Serial.list();
    for (String portName : g_portListMode_portNames)
    {
        y += g_portListMode_itemHeight;
        text(portName, 10, y);
    }

    // + }}}
}

String portNameAt(int i_y)
{
    int itemNo = floor((mouseY - g_portListMode_listTop) / g_portListMode_itemHeight);
    if (itemNo < 0 || itemNo >= g_portListMode_portNames.length)
        return null;
    return g_portListMode_portNames[itemNo];
}

// + }}}

// + Input {{{

String g_inputMode_portName;
Serial g_inputMode_serialPort;
ArrayList g_inputMode_lines;

boolean portExists(String i_name)
{
    String[] portNames = processing.serial.Serial.list();
    for (String portName : portNames)
    {
        if (portName.equals(i_name))
            return true;
    }
    return false;
}

void inputMode_enter()
{
    g_inputMode_lines = new ArrayList();

    try
    {
        g_inputMode_serialPort = new processing.serial.Serial(this, g_inputMode_portName, 9600);
    }
    catch (Exception e)
    {
        println("Failed to open port " + g_inputMode_portName + ", because: " + e.toString());
        enterViewMode(0);
        return;
    }

    g_inputMode_serialPort.bufferUntil('\n');

    frameRate(30);
}

void inputMode_exit()
{
    if (g_inputMode_serialPort != null)
    {
        g_inputMode_serialPort.stop();
        g_inputMode_serialPort = null;
    }
}

void serialEvent(Serial i_port)
{
    String line = i_port.readString();
    //println(line);

    while (g_inputMode_lines.size() > 100)
        g_inputMode_lines.remove(0);

    g_inputMode_lines.add(line);
}

void inputMode_draw()
{
    // If port being view no longer exists then go back to the port list
    if (!portExists(g_inputMode_portName))
        enterViewMode(0);

    //
    int textHeight;
    float linePitch;
    int y;

    // + Data {{{

    textHeight = 12;
    linePitch = 1.2;
    textSize(textHeight);
    y = height - 10;

    noStroke();
    fill(128, 255, 128, 255);

    //
    for (int itemNo = g_inputMode_lines.size() - 1; itemNo >= 0; --itemNo)
    {
        if (y < 24)
            break;
        text((String)g_inputMode_lines.get(itemNo), 10, y);
        y -= int(textHeight * linePitch);
    }

    // + }}}

    // + Heading {{{

    // Clear background strip
    noStroke();
    fill(0, 0, 0, 255);
    rect(0, 0, width, 55);

    //
    textHeight = 24;
    linePitch = 1.2;
    textSize(textHeight);
    y = 0;

    fill(128, 128, 255, 255);
    y += int(textHeight * linePitch);
    text("Input from serial port:", 10, y);
    fill(224, 224, 224, 255);
    text(g_inputMode_portName, 10 + textWidth("Input from serial port: "), y);

    // + }}}

    // + Instruction {{{

    textHeight = 12;
    linePitch = 1.5;
    textSize(textHeight);

    noStroke();
    fill(128, 128, 255, 255);
    y += int(textHeight * linePitch);
    text("[Click to go back]", 10, y);

    // + }}}
}

// + }}}

void draw()
{
    // Clear background
    noStroke();
    fill(0);
    rect(0, 0, width, height);

    //
    if (g_viewMode == 0)
        portListMode_draw();
    else if (g_viewMode == 1)
        inputMode_draw();
}

void mouseClicked()
{
    if (g_viewMode == 0)
    {
        g_inputMode_portName = portNameAt(mouseY);
        if (g_inputMode_portName != null)
        {
            enterViewMode(1);
        }
    }
    else if (g_viewMode == 1)
    {
        enterViewMode(0);
    }
}
