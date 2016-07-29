
import controlP5.*;


controlP5.ControlP5 g_cp5;

controlP5.Group g_sensorGraph_group;

controlP5.Toggle[] g_visibleCapacitiveSensors_toggles;

controlP5.ScrollableList g_valueProcessingStage_scrollableList;

// Colours
//  "foreground" ie. hovered, "background" ie. inactive, "active" ie. selected, caption label, value label
CColor activeBlueColour = new controlP5.CColor(0xFF0074D9, 0xFF003D6A, 0xFF00AAFF, 0xFF00AAFF, 0xFFFFFFFF);
CColor inactiveBlueColour = new controlP5.CColor(0xFF0074D9, 0xFF404040, 0xFF00AAFF, 0xFF808080, 0xFFFFFFFF);
CColor activeYellowColour = new controlP5.CColor(0xFFA9A400, 0xFF5A4D00, 0xFFFFEE00, 0xFFFFEE00, 0xFFFFFFFF);
CColor inactiveYellowColour = new controlP5.CColor(0xFFA9A400, 0xFF404040, 0xFFFFEE00, 0xFF808080, 0xFFFFFFFF);

PFont g_font;

// Value histories (ie. copies of further previous sensor readings, for graphing).
RingBuffer[] g_graph_values = new RingBuffer[k_capacitiveSensors_maxCount];
// Minimum and maximum readings graphed over time.
float[] g_graph_minimums = new float[k_capacitiveSensors_maxCount];
float[] g_graph_maximums = new float[k_capacitiveSensors_maxCount];

void setupSensorGraph()
{
    g_font = createFont("SansSerif", 12);

    g_cp5 = new controlP5.ControlP5(this);

    g_cp5.getTooltip().setDelay(500);

    g_sensorGraph_group = g_cp5.addGroup("sensorGraph_group")
        .setPosition(0, 0)
        .hideBar();

    int x = 14;

    controlP5.Textlabel visibleCapacitiveSensors_headingTextlabel = g_cp5.addLabel("Capacitive sensors: ");
    visibleCapacitiveSensors_headingTextlabel.setGroup(g_sensorGraph_group);
    visibleCapacitiveSensors_headingTextlabel.setPosition(x, 20 + 5);
    visibleCapacitiveSensors_headingTextlabel.setColor(0xFF00AAFF);
    x += 90;

    g_visibleCapacitiveSensors_toggles = new controlP5.Toggle[k_capacitiveSensors_maxCount];
    for (int toggleNo = 0; toggleNo < k_capacitiveSensors_maxCount; ++toggleNo)
    {
        g_visibleCapacitiveSensors_toggles[toggleNo] = g_cp5.addToggle("C" + toggleNo);
        g_visibleCapacitiveSensors_toggles[toggleNo].setGroup(g_sensorGraph_group);
        g_visibleCapacitiveSensors_toggles[toggleNo].setPosition(x, 20);
        g_visibleCapacitiveSensors_toggles[toggleNo].setSize(20, 20);
        g_visibleCapacitiveSensors_toggles[toggleNo].setColor(inactiveBlueColour);

        g_visibleCapacitiveSensors_toggles[toggleNo].setLabelVisible(false);
        controlP5.Textlabel textLabel = g_cp5.addLabel("CL" + toggleNo);
        textLabel.setGroup(g_sensorGraph_group);
        String labelText = String.valueOf(toggleNo * 2 + 2) + "\n    ";
        if (toggleNo < 5)
            labelText += " ";
        labelText += String.valueOf(toggleNo * 2 + 3);
        textLabel.setText(labelText);
        textLabel.setPosition(x - 2, 20 + 1);
        textLabel.setColor(#000000);

        x += 30;
    }

    x += 20;

    controlP5.Textlabel visibleCapacitiveSensors_valueProcessingStageTextlabel = g_cp5.addLabel("Values to plot: ");
    visibleCapacitiveSensors_valueProcessingStageTextlabel.setGroup(g_sensorGraph_group);
    visibleCapacitiveSensors_valueProcessingStageTextlabel.setPosition(x, 20 + 5);
    visibleCapacitiveSensors_valueProcessingStageTextlabel.setColor(0xFF00AAFF);
    x += 70;

    g_valueProcessingStage_scrollableList = g_cp5.addScrollableList("dropdown")
        .setGroup(g_sensorGraph_group)
        .setType(ControlP5.DROPDOWN)
        .close()
        .setPosition(x, 20)
        .setSize(90, 100)
        .setBarHeight(20)
        .setItemHeight(20)
        .setItems(new String[]{ "Raw",
                                "Smoothed",
                                "Stretched" })
        .setValue(2);
    //g_valueProcessingStage_scrollableList.getValueLabel().toUpperCase(false);

    //
    resetGraphValueHistoriesAndExtents();
}

void updateCapacitiveGraphButtonColours()
{
    for (int toggleNo = 0; toggleNo < k_capacitiveSensors_maxCount; ++toggleNo)
    {
        if (g_capacitiveSensors_active[toggleNo])
        {
            g_visibleCapacitiveSensors_toggles[toggleNo].setColor(activeBlueColour);
            g_visibleCapacitiveSensors_toggles[toggleNo].setValue(true);
        }
        else
        {
            g_visibleCapacitiveSensors_toggles[toggleNo].setColor(inactiveBlueColour);
            g_visibleCapacitiveSensors_toggles[toggleNo].setValue(false);
        }
    }
}


int g_sensorGraph_windowLeft, g_sensorGraph_windowTop, g_sensorGraph_windowWidth, g_sensorGraph_windowHeight;

void positionSensorGraph(int i_atLeft, int i_atTop, int i_atWidth, int i_atHeight)
{
    g_sensorGraph_windowLeft = i_atLeft;
    g_sensorGraph_windowTop = i_atTop;
    g_sensorGraph_windowWidth = i_atWidth;
    g_sensorGraph_windowHeight = i_atHeight;
    g_sensorGraph_group.setPosition(g_sensorGraph_windowLeft, g_sensorGraph_windowTop);
}

boolean g_sensorGraph_isVisible;

void showSensorGraph()
{
    g_sensorGraph_isVisible = true;
    g_sensorGraph_group.show();
}

void hideSensorGraph()
{
    g_sensorGraph_isVisible = false;

    g_sensorGraph_group.hide();
}

void resetGraphValueHistoriesAndExtents()
{
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        g_graph_values[sensorNo] = new RingBuffer();
        g_graph_values[sensorNo].setCapacity(80);

        g_graph_minimums[sensorNo] = Float.MAX_VALUE;
        g_graph_maximums[sensorNo] = Float.MIN_VALUE;
    }
}

int g_currentlyGraphingValueProcessingStage = -1;

void giveValueToGraph(int i_sensorNo, int i_processingStage, float i_value)
{
    if (i_processingStage == g_currentlyGraphingValueProcessingStage)
    {
        //print("sensor ");
        //print(i_sensorNo);
        //print(", saving stage ");
        //println(i_processingStage);
        //print(", value ");
        //println(i_value);

        g_graph_values[i_sensorNo].push(i_value);

        if (i_value < g_graph_minimums[i_sensorNo])
            g_graph_minimums[i_sensorNo] = i_value;
        if (i_value > g_graph_maximums[i_sensorNo])
            g_graph_maximums[i_sensorNo] = i_value;
    }
}

void drawSensorGraph()
{
    // If the sensor graph isn't supposed to be visible then return without doing anything
    if (!g_sensorGraph_isVisible)
        return;

    // If changed the processing stage that we want to graph,
    // take note of the new setting and clear the value histories for the new values
    if (g_currentlyGraphingValueProcessingStage != (int)g_valueProcessingStage_scrollableList.getValue())
    {
        g_currentlyGraphingValueProcessingStage = (int)g_valueProcessingStage_scrollableList.getValue();
        resetGraphValueHistoriesAndExtents();
    }

    // Layout
    int margin_left = 0;
    int margin_top = 58;
    int margin_right = 120;
    int margin_bottom = 12;
    int canvas_left = g_sensorGraph_windowLeft + margin_left;
    int canvas_top = g_sensorGraph_windowTop + margin_top;
    int canvas_right = g_sensorGraph_windowLeft + g_sensorGraph_windowWidth - margin_right;
    int canvas_bottom = g_sensorGraph_windowTop + g_sensorGraph_windowHeight - margin_bottom;

    // Clear background
    noStroke();
    fill(0, 0, 0, 255);
    rect(g_sensorGraph_windowLeft, g_sensorGraph_windowTop, g_sensorGraph_windowWidth, g_sensorGraph_windowHeight);

    fill(48, 48, 48, 255);
    rect(canvas_left, canvas_top, canvas_right - canvas_left, canvas_bottom - canvas_top);

    // Draw touch highlights around buttons
    stroke(255, 192, 192, 255);
    strokeWeight(2);
    noFill();
    int x = 14 + 90;
    for (int historyNo = 0; historyNo < g_graph_values.length; ++historyNo)
    {
        if (g_capacitiveSensors_touchStates_current[historyNo])
        {
            rect(x - 2, 18, 23, 23);
        }

        x += 30;
    }
    strokeWeight(1);

    // Count how many sensors are on for drawing
    int sensorsOn = 0;
    for (int historyNo = 0; historyNo < g_graph_values.length; ++historyNo)
    {
        if (g_visibleCapacitiveSensors_toggles[historyNo].getBooleanValue())
            ++sensorsOn;
    }
    // If none, stop here
    if (sensorsOn == 0)
        return;

    // Get extents
    float[] minMax = new float[2];
    //  If viewing raw values,
    //  use the extents taken by the serial code
    if (g_currentlyGraphingValueProcessingStage == 0)
    {
        minMax[0] = Float.MAX_VALUE;
        minMax[1] = Float.MIN_VALUE;
        for (int historyNo = 0; historyNo < g_graph_values.length; ++historyNo)
        {
            if (g_visibleCapacitiveSensors_toggles[historyNo].getBooleanValue())
            {
                if (g_capacitiveSensors_rawValues_minimums[historyNo] < minMax[0])
                    minMax[0] = g_capacitiveSensors_rawValues_minimums[historyNo];
                if (g_capacitiveSensors_rawValues_maximums[historyNo] > minMax[1])
                    minMax[1] = g_capacitiveSensors_rawValues_maximums[historyNo];
            }
        }
    }
    //  Else if viewing raw values,
    //  use the extents taken by the serial code
    else if (g_currentlyGraphingValueProcessingStage == 1)
    {
        minMax[0] = Float.MAX_VALUE;
        minMax[1] = Float.MIN_VALUE;
        for (int historyNo = 0; historyNo < g_graph_values.length; ++historyNo)
        {
            if (g_visibleCapacitiveSensors_toggles[historyNo].getBooleanValue())
            {
                if (g_capacitiveSensors_smoothedValues_minimums[historyNo] < minMax[0])
                    minMax[0] = g_capacitiveSensors_smoothedValues_minimums[historyNo];
                if (g_capacitiveSensors_smoothedValues_maximums[historyNo] > minMax[1])
                    minMax[1] = g_capacitiveSensors_smoothedValues_maximums[historyNo];
            }
        }
    }
    //  Else if viewing flattened values,
    //  use normalized extents
    else
    {
        minMax[0] = 0.0;
        minMax[1] = 1.0;
    }

    //
    noStroke();
    fill(192, 192, 192, 255);
    textSize(12);
    textFont(g_font);

    text("top: " + nfp(minMax[1], 0, 3), canvas_left + 3, canvas_top + 13);
    text("bottom: " + nfp(minMax[0], 0, 3), canvas_left + 3, canvas_bottom - 4);

    // If graphing in a mode where all lines have the same touch level (ie. stretched)
    // or if only one sensor is on, draw the touch level line
    if (g_currentlyGraphingValueProcessingStage == 2 || sensorsOn == 1)
    {
        //
        float touchLevel;
        if (g_currentlyGraphingValueProcessingStage == 2)
        {
            touchLevel = 1.0;
        }
        else
        {
            // Find which single sensor is being graphed
            int sensorNo = 0;
            while (sensorNo < g_graph_values.length)
            {
                if (g_visibleCapacitiveSensors_toggles[sensorNo].getBooleanValue())
                    break;

                ++sensorNo;
            }

            // Get its specific touch level
            touchLevel = g_capacitiveSensors_maxNonTouchLevels[sensorNo];
        }

        //
        int y = (int)map(touchLevel, minMax[0], minMax[1], canvas_bottom, canvas_top);

        String touchLevelStr = "touch level: " + nfp(touchLevel, 0, 3);
        float stringHalfWidth = textWidth(touchLevelStr) / 2;

        float canvasMiddle = (canvas_left + canvas_right) / 2;

        stroke(255, 128, 128, 255);
        line(canvas_left, y, canvasMiddle - stringHalfWidth - 3, y);
        line(canvasMiddle + stringHalfWidth + 2, y, canvas_right, y);

        noStroke();
        fill(255, 128, 128, 255);
        textSize(12);
        textFont(g_font);

        text(touchLevelStr, canvasMiddle - stringHalfWidth, y + 4);
    }

    // Draw lines
    for (int historyNo = 0; historyNo < g_graph_values.length; ++historyNo)
    {
        if (g_visibleCapacitiveSensors_toggles[historyNo].getBooleanValue())
        {
            float touchLevel;
            if (g_currentlyGraphingValueProcessingStage == 0 || g_currentlyGraphingValueProcessingStage == 1)
                touchLevel = g_capacitiveSensors_maxNonTouchLevels[historyNo];
            else
                touchLevel = 1.0;

            String labelText = String.valueOf(historyNo * 2 + 2) + "/" + String.valueOf(historyNo * 2 + 3) + ": ";

            drawValueHistory(
                g_graph_values[historyNo], labelText,
                touchLevel, 0xFF00FFFF, 0xFFFFC0C0,
                false, minMax[0], false, minMax[1],
                canvas_left, canvas_top, canvas_right, canvas_bottom);
        }
    }
}

void drawValueHistory(RingBuffer i_valueHistory, String i_label,
                      float i_data_colourThreshold, int i_colourBelowThreshold, int i_colourAboveThreshold,
                      boolean i_data_bottomAuto, float i_data_bottomValue, boolean i_data_topAuto, float i_data_topValue,
                      int i_canvas_left, int i_canvas_top, int i_canvas_right, int i_canvas_bottom)
{
    //
    int valueCount = i_valueHistory.getValueCount();
    if (valueCount == 0)
        return;

    //
    float data_top = i_data_topValue;
    float data_bottom = i_data_bottomValue;

    //
    float x = i_canvas_right;

    int valueNo = 0;
    float dataValue = i_valueHistory.getValue(valueNo);
    float y = map(dataValue, data_bottom, data_top, i_canvas_bottom, i_canvas_top);

    noStroke();
    if (dataValue > i_data_colourThreshold)
        fill(i_colourAboveThreshold);
    else
        fill(i_colourBelowThreshold);
    arc(x, y, 7, 7, 0, TWO_PI);

    textSize(12);
    textFont(g_font);
    text(i_label + nfp(dataValue, 0, 3), x + 8, y + 5);
    //System.out.println("x: " + x + ", y: " + y + ", dataValue: " + dataValue);

    float xStep = (float)(i_canvas_right - i_canvas_left) / (i_valueHistory.getCapacity() - 1);

    float previousX, previousY;
    float previousDataValue;
    for (valueNo = 1; valueNo < valueCount; ++valueNo)
    {
        previousX = x;
        previousY = y;
        previousDataValue = dataValue;

        x -= xStep;
        dataValue = i_valueHistory.getValue(valueNo);
        y = map(dataValue, data_bottom, data_top, i_canvas_bottom, i_canvas_top);

        // If values are both above or both below colour threshold,
        // draw single line segment in one colour
        if ((dataValue > i_data_colourThreshold && previousDataValue > i_data_colourThreshold) ||
            (dataValue <= i_data_colourThreshold && previousDataValue <= i_data_colourThreshold))
        {
            if (dataValue > i_data_colourThreshold)
                stroke(i_colourAboveThreshold);
            else
                stroke(i_colourBelowThreshold);

            line(previousX, previousY, x, y);
        }
        // Else if one value is above and the other is below
        // draw two line segments in different colours
        else
        {
            float intersectionY = map(i_data_colourThreshold, data_bottom, data_top, i_canvas_bottom, i_canvas_top);
            float intersectionX = map(intersectionY, previousY, y, previousX, x);

            if (previousDataValue > i_data_colourThreshold)
                stroke(i_colourAboveThreshold);
            else
                stroke(i_colourBelowThreshold);

            line(previousX, previousY, intersectionX, intersectionY);

            if (dataValue > i_data_colourThreshold)
                stroke(i_colourAboveThreshold);
            else
                stroke(i_colourBelowThreshold);

            line(intersectionX, intersectionY, x, y);
        }
    }
}
