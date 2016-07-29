// Function for drawing an oscilloscope.


// This file is not supposed to be changed (unless you are particularly adventurous).
// But please do read the "How to use" notes.


// How to use:
//
// - Call drawOscilloscope() from the main Processing draw() function,
//   to draw a graph of the currently audible sound wave.


int g_oscilloscope_windowLeft, g_oscilloscope_windowTop, g_oscilloscope_windowWidth, g_oscilloscope_windowHeight;

void positionOscilloscope(int i_atLeft, int i_atTop, int i_atWidth, int i_atHeight)
{
    g_oscilloscope_windowLeft = i_atLeft;
    g_oscilloscope_windowTop = i_atTop;
    g_oscilloscope_windowWidth = i_atWidth;
    g_oscilloscope_windowHeight = i_atHeight;
}

boolean g_oscilloscope_isVisible;

void showOscilloscope()
{
    g_oscilloscope_isVisible = true;
}

void hideOscilloscope()
{
    g_oscilloscope_isVisible = false;
}

void drawOscilloscope()
{
    // If the oscilloscope isn't supposed to be visible then return without doing anything
    if (!g_oscilloscope_isVisible)
        return;

    // Clear background
    fill(0, 40);
    noStroke();
    rect(g_oscilloscope_windowLeft, g_oscilloscope_windowTop, g_oscilloscope_windowWidth, g_oscilloscope_windowHeight);

    // Find zero crossing in sample history to start drawing from there
    float alignmentPoint = 0.0;  // (To centre-align the waveforms - it's prettier - change this to 0.5)
    int audioOutputHistoryPos = wrap(g_audioOutput_historyPos - int(g_oscilloscope_windowWidth * (1.0 - alignmentPoint)), g_audioOutput_history.length);
    while (audioOutputHistoryPos != g_audioOutput_historyPos)
    {
        int previousAudioOutputHistoryPos = wrap(audioOutputHistoryPos - 1, g_audioOutput_history.length);
        if (g_audioOutput_history[audioOutputHistoryPos] >= 0 && g_audioOutput_history[previousAudioOutputHistoryPos] < 0)
            break;  

        audioOutputHistoryPos = previousAudioOutputHistoryPos;
    }
    audioOutputHistoryPos = wrap(audioOutputHistoryPos - int(g_oscilloscope_windowWidth * alignmentPoint), g_audioOutput_history.length);
    //audioOutputHistoryPos = 0;
  
    // Draw graph
    stroke(192, 255, 192);
    for (int x = 0; x < g_oscilloscope_windowWidth - 1; ++x)
    {
        int nextAudioOutputHistoryPos = wrap(audioOutputHistoryPos + 1, g_audioOutput_history.length);
        line(g_oscilloscope_windowLeft + x, g_oscilloscope_windowTop + g_oscilloscope_windowHeight/2 * (1 - g_audioOutput_history[audioOutputHistoryPos]),
             g_oscilloscope_windowLeft + x + 1, g_oscilloscope_windowTop + g_oscilloscope_windowHeight/2 * (1 - g_audioOutput_history[nextAudioOutputHistoryPos]));

        audioOutputHistoryPos = nextAudioOutputHistoryPos;
    }
}
