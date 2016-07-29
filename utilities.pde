// Miscellaneous utility functions.


// + Pitch calculations {{{

float midiNoteNumberToFrequency(int i_midiNoteNo)
// Convert a MIDI note number to a frequency.
//
// Example:
//  The MIDI note number of 60 converts to the frequency of 261.63 Hz,
//  which is the pitch of "middle C".
//
//  For a full list, Google "MIDI note number table"
//  or visit: http://newt.phys.unsw.edu.au/jw/notes.html
//
// Params:
//  i_midiNoteNo:
//   A MIDI note number.
//
// Returns:
//  The frequency that the note number represents, in units of Hz.
{
    return pow(2, float(i_midiNoteNo - 69)/12) * 440;
}

// + }}}

// + Helpers for reading sensors {{{

boolean detectButtonPress(float i_previousSensorValue, float i_currentSensorValue)
// Detect a sharp increase in a sensor's value,
// such as what happens when a button control is pressed.
//
// Params:
//  i_previousSensorValue:
//   The previous value that a sensor had.
//  i_currentSensorValue:
//   The value that the same sensor has now.
//
// Returns:
//  true:
//   The sensor has sharply increased in value.
//   If it is a button it has probably just been pressed.
//   (If it is something more precise, eg. a slider, it has perhaps just been moved up very quickly.)
//  false:
//   The sensor has not sharply increased in value.
//
// Example:
//  // Assuming sensor number 2 is a button...
//  if (detectButtonPress(previousSensorValues[2], sensorValues[2]))
//  {
//      // ... if we get here then the button was pressed
//  }
{
    return i_currentSensorValue - i_previousSensorValue > 0.15;
}

boolean detectButtonRelease(float i_previousSensorValue, float i_currentSensorValue)
// Detect a sharp decrease in a sensor's value,
// such as what happens when a button control is released.
//
// Params:
//  i_previousSensorValue:
//   The previous value that a sensor had.
//  i_currentSensorValue:
//   The value that the same sensor has now.
//
// Returns:
//  true:
//   The sensor has sharply decreased in value.
//   If it is a button it has probably just been released.
//   (If it is something more precise, eg. a slider, it has perhaps just been moved down very quickly.)
//  false:
//   The sensor has not sharply decreased in value.
//
// Example:
//  // Assuming sensor number 2 is a button...
//  if (detectButtonRelease(previousSensorValues[2], sensorValues[2]))
//  {
//      // ... if we get here then the button was released
//  }
{
    return i_currentSensorValue - i_previousSensorValue < -0.15;
}

// + }}}

// + Numeric helpers {{{

int wrap(int i_value, int i_upperBound)
{
    if (i_upperBound < 0)
        return -wrap(-i_value, -i_upperBound);

    if (i_value < 0)
    {
        int rv = i_value % i_upperBound;
        if (rv != 0)
            rv += i_upperBound;
        return rv;
    }
    else
        return i_value % i_upperBound;
}

// + }}}

// + Sound file loading {{{

public float loadFileIntoBuffer(String i_diskOrUrlPath, MultiChannelBuffer o_outBuffer)
// In Processing's current stable version, 2.2.1, src.ddf.minim.Minim.loadFileIntoBuffer() has some bugs
// which stop it loading MP3 format files. Using the latest alpha version (3.0a9 at time of writing) may
// avoid this. Alternatively, use this fixed version of that function.
//
// Load into a MultiChannelBuffer from disk or URL.
//
// format/transport compatibility
//  disk, wav: yes
//  disk, mp3: yes
//  url, wav: no
//  url, mp3: yes
//
// Params:
//  i_diskOrUrlPath:
//   (String)
//  o_buffer:
//   (ddf.minim.MultiChannelBuffer)
//   Buffer to load into. Its channel count and buffer size will be adjust to match the source,
//   so it doesn't matter what you constructed it with.
//
// Returns:
//  (float)
//  Sample rate, or 0 if load failed
//
// To play:
//  Construct a ddf.minim.ugens.Sampler with the MultiChannelBuffer
//  Patch it to AudioOutput
//  Call trigger()
{
    // Open file stream
    final int readBufferSize = 4096;
    ddf.minim.spi.AudioRecordingStream stream;
    try {
        stream = minim.loadFileStream(i_diskOrUrlPath, readBufferSize, false);
    }
    catch (NullPointerException e) {
        println("Failed to open file or URL: " + i_diskOrUrlPath);
        throw e;
    }
    if (stream == null)
    {
        debug("Unable to load an AudioRecordingStream for " + i_diskOrUrlPath);
        return 0;
    }

    // Play the stream
    stream.play();

    // Get stream metadata
    float sampleRate = stream.getFormat().getSampleRate();
    final int channelCount = stream.getFormat().getChannels();
    long totalSampleCount = stream.getSampleFrameLength();
    if (totalSampleCount == -1)
    {
        totalSampleCount = org.tritonus.share.sampled.AudioUtils.millis2Frames(stream.getMillisecondLength(), stream.getFormat());
    }
    debug("Total sample count for " + i_diskOrUrlPath + " is " + totalSampleCount);
    //System.out.println(sampleRate);
    //System.out.println(channelCount);
    //System.out.println(totalSampleCount);

    // Adjust output buffer to matching channel and sample count
    o_outBuffer.setChannelCount(channelCount);
    o_outBuffer.setBufferSize((int)totalSampleCount);

    // Via temporary MultiChannelBuffer, read file in chunks
    MultiChannelBuffer readBuffer = new MultiChannelBuffer(channelCount, readBufferSize);
    long totalSamplesRead = 0;
    while (totalSamplesRead < totalSampleCount)
    {
        // If the remainder is smaller than our chunk buffer then shrink our chunk buffer accordingly
        if (totalSampleCount - totalSamplesRead < readBufferSize)
        {
            readBuffer.setBufferSize((int)(totalSampleCount - totalSamplesRead));
        }

        //
        stream.read(readBuffer);
        int samplesRead = readBuffer.getBufferSize();

        // copy data from one buffer to the other
        for (int channelNo = 0; channelNo < channelCount; ++channelNo)
        {
            for (int sampleNo = 0; sampleNo < samplesRead; ++sampleNo)
            {
                o_outBuffer.setSample(channelNo, (int)totalSamplesRead+sampleNo, readBuffer.getSample(channelNo, sampleNo));
            }
        }
        totalSamplesRead += samplesRead;
    }

    if (totalSamplesRead != totalSampleCount)
    {
        o_outBuffer.setBufferSize((int)totalSamplesRead);
    }

    debug("loadSampleIntoBuffer: final output buffer size is " + o_outBuffer.getBufferSize() );

    stream.close();

    return sampleRate;
}

ddf.minim.ugens.Sampler loadSound(String i_diskOrUrlPath)
// Load sound data into a Minim Sampler
//
// To play or replay the returned sound object:
//  .trigger()
{
    // Load file into buffer (using fixed version of loadFileIntoBuffer, not Minim version)
    MultiChannelBuffer buffer = new MultiChannelBuffer(1, 1024);
    float sampleRate = loadFileIntoBuffer(i_diskOrUrlPath, buffer);

    // Make a new Sampler that pulls from this buffer and return it
    ddf.minim.ugens.Sampler sampler = new ddf.minim.ugens.Sampler(buffer, sampleRate, 1);
    sampler.patch(speaker);
    return sampler;
}

ddf.minim.ugens.Oscil loadSoundIntoOscil(String i_diskOrUrlPath)
// Load sound data into a Minim Oscil
{
    // Load file into buffer (using fixed version of loadFileIntoBuffer, not Minim version)
    MultiChannelBuffer buffer = new MultiChannelBuffer(1, 1024);
    float sampleRate = loadFileIntoBuffer(i_diskOrUrlPath, buffer);

    // Mix channels
    int sampleCount = buffer.getChannel(0).length;
    int channelCount = buffer.getChannelCount();
    float[] mixed = new float[sampleCount];
    for (int sampleNo = 0; sampleNo < sampleCount; ++sampleNo)
    {
        mixed[sampleNo] = 0;
        for (int channelNo = 0; channelNo < channelCount; ++channelNo)
        {
            mixed[sampleNo] += buffer.getChannel(channelNo)[sampleNo];
        }
        mixed[sampleNo] /= channelCount;
    }

    // Make a new Wavetable containing the mixed samples
    ddf.minim.ugens.Wavetable w = new ddf.minim.ugens.Wavetable(mixed);

    // Make a new Sampler that pulls from these samples,
    // with frequency calculated to play the samples at their originally recorded speed,
    // and return it
    return new ddf.minim.ugens.Oscil(sampleRate / sampleCount, 1, w);
}

// + }}}
