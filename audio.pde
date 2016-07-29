// Audio system.


// This file is not supposed to be changed (unless you are particularly adventurous).
// But please do read the "How to use" notes.


// How to use:
//
// - Customize g_audioBufferBits (in Setup section) if needed.
//
// - Call setupAudio() from the main Processing setup() function.


// + Setup {{{

// If the sound is choppy or clicky try increasing this number, adding 1 at a time.
// However, go too high (more than about 12) and there will be lag.
final int g_audioBufferBits = 10;


import ddf.minim.*;
import ddf.minim.ugens.*;

ddf.minim.Minim minim;
ddf.minim.AudioOutput g_audioOutput_lineOut, speaker;

void setupAudio()
{
    minim = new ddf.minim.Minim(this);
    //minim.debugOn();
  
    int samplesPerSecond = 44100;
    g_audioOutput_lineOut = minim.getLineOut(ddf.minim.Minim.MONO, 1 << (g_audioBufferBits - 1), samplesPerSecond);
    speaker = g_audioOutput_lineOut;

    setupAudioOutputLogging();
}

// + }}}

// + Output logging {{{

AudioOutputLogger g_audioOutput_logger;
float[] g_audioOutput_history;
int g_audioOutput_historyPos;

private class AudioOutputLogger implements ddf.minim.AudioListener
{
    public void samples(float[] i_samples)
    {
        //System.out.println(i_samples.length);
        for (int sampleNo = 0; sampleNo < i_samples.length; ++sampleNo)
        {
            g_audioOutput_history[g_audioOutput_historyPos] = i_samples[sampleNo];

            ++g_audioOutput_historyPos;
            if (g_audioOutput_historyPos >= g_audioOutput_history.length)
                g_audioOutput_historyPos = 0;
        }
    }

    public void samples(float[] i_leftSamples, float[] i_rightSamples)
    {
        samples(i_leftSamples);
    }
}

void setupAudioOutputLogging()
{
    g_audioOutput_logger = new AudioOutputLogger();
    g_audioOutput_history = new float[width * 2];
    g_audioOutput_historyPos = 0;
    g_audioOutput_lineOut.addListener(g_audioOutput_logger);
}

// + }}}

/*
static int globaltest()
{
    return 2;
}

//static ddf.minim.UGen initializeUGen(ddf.minim.UGen i_ugen)
static Oscil initializeUGen(Oscil i_ugen)
{
    i_ugen.setSampleRate(speaker.sampleRate());
    i_ugen.setChannelCount(speaker.type());
    return i_ugen;
}
*/
