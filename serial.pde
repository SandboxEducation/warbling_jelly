// Serial port communications (with the Arduino).


// This file is not supposed to be changed (unless you are particularly adventurous).
// But please do read the "How to use" notes.


// How to use:
//
// - Customize g_serialPortName (in Setup section) if needed.
//
// - Call setupSerial() from the main Processing setup() function,
//   and doSerial() from the main Processing draw() function.


// + Setup {{{

// The program will try to auto-detect the name of the serial port, if using OSX or Linux.
// To choose a port manually instead, enter its name between the quotes on the next line:
String g_serialPortName = "";
// (Note: If using Windows, you must do this, as the auto-detection does not work there.)
// To see all port names available for choosing, leave the above blank and start the program;
// it will print a list at the top of the log.
//
// Typical port name example on Linux:
//     /dev/ttyACM0
//     (Note: last character may vary)
// Typical port name examples on OSX:
//     /dev/tty.usbmodem1B21
//     /dev/tty.usbserial53A8
//     (Note: last 4 characters may vary)
// Typical port name example on Windows:
//     COM12
//     (Note: last 2 characters may vary)


import processing.serial.*;

Serial g_serialPort;
boolean g_receivedReinitializeAck;

void setupSerial()
{
    String[] portNames = Serial.list();
    println("Serial port");
    println(" Ports found on this system:");
    for (String portName : portNames)
    {
        println("  " + portName);
        if (g_serialPortName == "")
        {
            if (// Typical port name on Linux
                portName.startsWith("/dev/ttyACM0") ||
                // Typical port name prefixes on OSX
                portName.startsWith("/dev/tty.usbmodem") ||
                portName.startsWith("/dev/tty.usbserial")
                // Typical port name prefix on Windows would be COM, but hard to disambiguate
                )
                g_serialPortName = portName;
        }
    }
    if (g_serialPortName == "")
    {
        g_serialPortName = portNames[0];
    }
    println(" Going to try and use port:");
    println("  " + g_serialPortName);

    g_serialPort = new Serial(this, g_serialPortName, 9600);
    g_serialPort.bufferUntil('\n');

    //
    finishAllocatingCapacitiveSensorStructures();
    resetCapacitiveSensors();

    //
    g_needReinitialization = true;
}

boolean g_needReinitialization;

void reinitializeArduino()
{
    // Tell program on Arduino to reinitialize
    g_serialPort.clear();
    g_receivedReinitializeAck = false;
    System.out.println("Requesting Arduino reinitialization...");
    g_serialPort.write("~RR 30 30000 2 2000\n");

    /*
    // Tell program on Arduino to reinitialize,
    // repeatedly until receive reinitialization acknowledgement message
    g_serialPort.clear();
    g_receivedReinitializeAck = false;
    while (!g_receivedReinitializeAck)
    {
        System.out.println("Requesting Arduino reinitialization...");
        //g_serialPort.write("~RR 30 30000 30 30000\n");
        g_serialPort.write("~RR 30 30000 5 5000\n");
        delay(1000);
    }
    */
}

// + }}}

// + Running {{{

// + + General serial {{{

// Change this to true to print all received sensor readings to the Processing console,
// for debugging purposes.
boolean g_logSerialMessages = false;

String g_messageInProgress = "";

void doSerial()
// Call from every draw().
{
    if (g_needReinitialization)
    {
        g_needReinitialization = false;
        reinitializeArduino();
    }
}

void serialEvent(Serial i_port)
// This is called when serial data is received.
{
    // Append new chars to any previous ones
    g_messageInProgress += i_port.readString();

    // Look for last message start delimiter
    // If not found, then throw away the useless between-message or unterminated-message chars and return
    int messageStartPos = g_messageInProgress.lastIndexOf('~');
    if (messageStartPos == -1)
    {
        g_messageInProgress = "";
        return;
    }

    // Look for message end delimiter
    // If not found, then return (keeping the partial message chars for next time)
    int messageEndPos = g_messageInProgress.indexOf("\r\n");
    if (messageEndPos == -1)
    {
        return;
    }

    // Extract message from in-progress stream, dropping delimiters
    String message = g_messageInProgress.substring(messageStartPos + 1, messageEndPos);
    g_messageInProgress = g_messageInProgress.substring(messageEndPos + 2);

    // Log message if desired
    if (g_logSerialMessages)
        println("~" + message);

    // Branch according to first two characters,
    // and send message content to handler function without those characters and the following space
    if (message.length() >= 3)
    {
        if (message.charAt(0) == 'C')
        {
            if (message.charAt(1) == 'V')
                processCapacitiveValuesMessage(message.substring(3));
            else if (message.charAt(1) == 'A')
                processCapacitiveActiveMessage(message.substring(3));
        }
    }
    else if (message.length() >= 2)
    {
        // ~BR: Booted and ready
        if (message.charAt(0) == 'B')
        {
            if (message.charAt(1) == 'R')
            {
                g_needReinitialization = true;
            }
        }
        // ~RA: Reinitialization acknowledgement
        else if (message.charAt(0) == 'R')
        {
            if (message.charAt(1) == 'A')
            {
                g_receivedReinitializeAck = true;
            }
        }
    }
}

// + + }}}

// + + Capacitive sensors {{{

// Which capacitive sensors are active, and how many of them there are.
boolean[] g_capacitiveSensors_active = new boolean[k_capacitiveSensors_maxCount];
int g_capacitiveSensors_count;

// + + + Raw values {{{

// Current
float[] g_capacitiveSensors_rawValues_current = new float[k_capacitiveSensors_maxCount];
// Minimums and maximums over time
float[] g_capacitiveSensors_rawValues_minimums = new float[k_capacitiveSensors_maxCount];
float[] g_capacitiveSensors_rawValues_maximums = new float[k_capacitiveSensors_maxCount];

// + + + }}}

// + + + Smoothed values {{{

// The number of values of each capacitive sensor to average to smooth the changes in it,
// and the buffers which hold them all.
int[] g_capacitiveSensors_smoothingAmount = new int[]{ 10, 10, 10, 10, 10, 10 };
RingBuffer[] g_capacitiveSensors_valueHistoriesForSmoothing = new RingBuffer[k_capacitiveSensors_maxCount];

// Current and previous
float[] g_capacitiveSensors_smoothedValues_current = new float[k_capacitiveSensors_maxCount];
float[] g_capacitiveSensors_smoothedValues_previous = new float[k_capacitiveSensors_maxCount];
// Minimums and maximums over time
float[] g_capacitiveSensors_smoothedValues_minimums = new float[k_capacitiveSensors_maxCount];
float[] g_capacitiveSensors_smoothedValues_maximums = new float[k_capacitiveSensors_maxCount];

// + + + }}}

// + + + Touch detection {{{

// Highest not-touching levels seen so far
float[] g_capacitiveSensors_maxNonTouchLevels = new float[k_capacitiveSensors_maxCount];
// Touch states, current and previous
boolean[] g_capacitiveSensors_touchStates_current = new boolean[k_capacitiveSensors_maxCount];
boolean[] g_capacitiveSensors_touchStates_previous = new boolean[k_capacitiveSensors_maxCount];

// + + + }}}

// Where this is not 0, this is a base to take the logarithm of the reading to before saving it.
// Use higher values to flatten out the response curve more.
float[] g_capacitiveSensors_logBases = new float[]{ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 };

// Normalized sensor readings, current and previous.
float[] g_capacitiveSensors_normalizedValues_current = new float[k_capacitiveSensors_maxCount];
float[] g_capacitiveSensors_normalizedValues_previous = new float[k_capacitiveSensors_maxCount];

// Total number of capacitive sensor reading messages that have been successfully processed so far.
int g_capacitiveSensors_processedMessageCount;

void finishAllocatingCapacitiveSensorStructures()
{
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        g_capacitiveSensors_valueHistoriesForSmoothing[sensorNo] = new RingBuffer();
    }
}

void resetCapacitiveSensors()
{
    // Active sensors
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        g_capacitiveSensors_active[sensorNo] = false;
    }
    g_capacitiveSensors_count = 0;

    // Raw values
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        g_capacitiveSensors_rawValues_minimums[sensorNo] = Float.MAX_VALUE;
        g_capacitiveSensors_rawValues_maximums[sensorNo] = Float.MIN_VALUE;
    }

    // Smoothed values
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        g_capacitiveSensors_valueHistoriesForSmoothing[sensorNo].setCapacity(g_capacitiveSensors_smoothingAmount[sensorNo]);
        g_capacitiveSensors_smoothedValues_minimums[sensorNo] = Float.MAX_VALUE;
        g_capacitiveSensors_smoothedValues_maximums[sensorNo] = Float.MIN_VALUE;
    }

    // Touch detection
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        // -1 meaning uninitialized
        g_capacitiveSensors_maxNonTouchLevels[sensorNo] = -1;

        g_capacitiveSensors_touchStates_current[sensorNo] = false;
        g_capacitiveSensors_touchStates_previous[sensorNo] = false;
    }

    //
    for (int sensorNo = 0; sensorNo < k_capacitiveSensors_maxCount; ++sensorNo)
    {
        g_capacitiveSensors_normalizedValues_current[sensorNo] = 0;
    }

    g_capacitiveSensors_processedMessageCount = 0;
}

void processCapacitiveActiveMessage(String i_message)
{
    resetCapacitiveSensors();
    resetGraphValueHistoriesAndExtents();

    try
    {
        String[] incomingArrayEntries = splitTokens(i_message, " ");

        g_capacitiveSensors_count = 0;
        for (String incomingArrayEntry : incomingArrayEntries)
        {
            if (g_capacitiveSensors_count >= k_capacitiveSensors_maxCount)
                break;

            g_capacitiveSensors_active[g_capacitiveSensors_count] = incomingArrayEntry.equals("1");
            ++g_capacitiveSensors_count;
        }
    }
    catch (Exception e)
    {
        println("Failed to parse Capacitive active message: " + i_message + ", because: " + e.toString());
    }

    //
    updateCapacitiveGraphButtonColours();
}


final float k_maxNonTouchRise = 10.0f;

void processCapacitiveValuesMessage(String i_message)
{
    try
    {
        String[] incomingArrayEntries = splitTokens(i_message, " ");

        // Parse current values
        int sensorNo = 0;
        for (String incomingArrayEntry : incomingArrayEntries)
        {
            // Convert string to number
            if (Float.isNaN(float(incomingArrayEntry)))
                throw new Exception("NaN in capacitive number parse");
            float reading = float(Integer.parseInt(incomingArrayEntry));

            // Save/plot raw reading
            g_capacitiveSensors_rawValues_current[sensorNo] = reading;
            giveValueToGraph(sensorNo, 0, reading);

            // Update raw minimum and maximum values
            if (reading < g_capacitiveSensors_rawValues_minimums[sensorNo])
                g_capacitiveSensors_rawValues_minimums[sensorNo] = reading;
            if (reading > g_capacitiveSensors_rawValues_maximums[sensorNo])
                g_capacitiveSensors_rawValues_maximums[sensorNo] = reading;

            // Save value in smoothing history, then read back smoothed value
            g_capacitiveSensors_valueHistoriesForSmoothing[sensorNo].push(reading);
            reading = g_capacitiveSensors_valueHistoriesForSmoothing[sensorNo].getMeanValue(-1);

            // Wait until we've received at least enough values to fill up the smoothing history
            // as we don't want to use any values that aren't fully smoothed,
            // plus 5 more because I'm suspicious about the first few readings that might be
            // distorted by the various activities of initialization
            if (g_capacitiveSensors_processedMessageCount >= g_capacitiveSensors_valueHistoriesForSmoothing[sensorNo].getCapacity() + 5)
            {
                // Update smoothed minimum and maximum values
                if (reading < g_capacitiveSensors_smoothedValues_minimums[sensorNo])
                    g_capacitiveSensors_smoothedValues_minimums[sensorNo] = reading;
                if (reading > g_capacitiveSensors_smoothedValues_maximums[sensorNo])
                    g_capacitiveSensors_smoothedValues_maximums[sensorNo] = reading;

                // If don't have a touch level yet then start with the minimum value
                if (g_capacitiveSensors_maxNonTouchLevels[sensorNo] == -1)
                    g_capacitiveSensors_maxNonTouchLevels[sensorNo] = g_capacitiveSensors_smoothedValues_minimums[sensorNo];

                // Save/plot smoothed value, advancing single-value history
                g_capacitiveSensors_smoothedValues_previous[sensorNo] = g_capacitiveSensors_smoothedValues_current[sensorNo];
                g_capacitiveSensors_smoothedValues_current[sensorNo] = reading;
                giveValueToGraph(sensorNo, 1, reading);

                // Advance touch state history
                g_capacitiveSensors_touchStates_previous[sensorNo] = g_capacitiveSensors_touchStates_current[sensorNo];

                // If sensor isn't already touched
                if (!g_capacitiveSensors_touchStates_current[sensorNo])
                {
                    // If reading exceeds previous touch level
                    if (reading > g_capacitiveSensors_maxNonTouchLevels[sensorNo])
                    {
                        float changeInSmoothedValue = reading - g_capacitiveSensors_smoothedValues_previous[sensorNo];

                        // If it's a large rise, it's a touch
                        if (changeInSmoothedValue > k_maxNonTouchRise)
                        {
                            g_capacitiveSensors_touchStates_current[sensorNo] = true;
                        }
                        // Else if it's a small rise, raise the touch level
                        else if (changeInSmoothedValue > 0)
                        {
                            g_capacitiveSensors_maxNonTouchLevels[sensorNo] = reading;
                        }
                    }
                }
                // else if sensor is already considered touched
                else
                {
                    if (reading <= g_capacitiveSensors_maxNonTouchLevels[sensorNo])
                    {
                        g_capacitiveSensors_touchStates_current[sensorNo] = false;
                    }
                }

                // Stretch/normalize value
                if (g_capacitiveSensors_logBases[sensorNo] != 0)
                {
                    reading = newMapExpToLin(
                        reading,
                        g_capacitiveSensors_logBases[sensorNo],
                        g_capacitiveSensors_smoothedValues_minimums[sensorNo], g_capacitiveSensors_maxNonTouchLevels[sensorNo],
                        0, 1);
                }
                else // if (g_capacitiveSensors_logBases[sensorNo] == 0)
                {
                    reading = mapLinToLin(
                        reading,
                        g_capacitiveSensors_smoothedValues_minimums[sensorNo], g_capacitiveSensors_maxNonTouchLevels[sensorNo],
                        0, 1);
                }
                giveValueToGraph(sensorNo, 2, reading);

                // Save final value
                g_capacitiveSensors_normalizedValues_current[sensorNo] = reading;
            }

            //
            ++sensorNo;
        }

        //
        g_capacitiveSensors_count = sensorNo;

        //
        ++g_capacitiveSensors_processedMessageCount;

        //
        control();
    }
    catch (Exception e)
    {
        println("Failed to parse capacitive values message: " + i_message + ", because: " + e.toString());
    }
}

// + + }}}

// + }}}
