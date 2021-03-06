public class OneShotEnvelope implements IEnvelope
{
    // + Construction {{{

    public OneShotEnvelope(float[] i_breakpoints)
                           //i_duration, i_scaler, i_offset, i_lineShape)
    // Params:
    //  i_breakpoints:
    //   Envelope break points.
    //   Pairs of numbers, where in each pair:
    //    0: (integer) The sample number at which this envelope stage starts
    //    1: (float) The amplitude of the envelope at the start of this envelope stage
    {
        m_breakpoints = i_breakpoints;

        restart();
    }

    public static OneShotEnvelope withPrescale(float[] i_breakpoints, float i_scalingFactor)
    {
        return new OneShotEnvelope(OneShotEnvelope.scaleBreakpointsBy(i_breakpoints, i_scalingFactor));
    }

    // + }}}

    // + Breakpoints {{{

    private float[] m_breakpoints;

    public float[] getBreakpoints()
    {
        return m_breakpoints;
    }
    /*
    public setBreakpoints(float[] i_breakpoints)
    {
        m_breakpoints = i_breakpoints;
    }
    */

    public void printBreakpoints()
    // For debugging.
    {
        System.out.print("breakpoints: ");
        for (int breakpointNo = 0; breakpointNo < m_breakpoints.length/2; ++breakpointNo)
        {
            if (breakpointNo != 0)
                System.out.print(", ");

            System.out.print("[");
            System.out.print(m_breakpoints[breakpointNo*2]);
            System.out.print(", ");
            System.out.print(m_breakpoints[breakpointNo*2 + 1]);
            System.out.print("]");
        }
        System.out.println("");
    }

    public OneShotEnvelope scaleTimesBy(float i_scalingFactor)
    // Scale all time values (ie. breakpoints)
    // by some factor.
    //
    // Params:
    //  i_scalingFactor:
    //   The factor to multiply each time value by.
    //
    // Returns:
    //  this.
    {
        // Scale breakpoints
        OneShotEnvelope.m_scaleBreakpointsBy(m_breakpoints, i_scalingFactor);

        // If envelope has ended,
        // no current stage to adjust, so return
        if (m_currentStage_sampleCount == -1.0f)
            return this;

        // Scale current stage sample count,
        // current position within stage,
        // and amplitude increment (which behaves inversely to the length of the stage)
        m_currentStage_sampleCount *= i_scalingFactor;
        m_currentStage_sampleNo *= i_scalingFactor;
        m_amplitudeIncrement /= i_scalingFactor;

        //
        return this;
    }

    public OneShotEnvelope scaleBreakpointDurationTo(float i_newDuration)
    // Scale all time values (ie. breakpoints)
    // so that the last breakpoint falls at a specified time.
    //
    // Params:
    //  i_newDuration:
    //   The new length that the envelope should be after scaling,
    //   ie. the new time value of the last breakpoint.
    //
    // Returns:
    //  this.
    {
        return scaleTimesBy(i_newDuration / m_breakpoints[m_breakpoints.length - 2]);
    }

    // + }}}

    // + Overall progress {{{

    private float m_currentAmplitude;

    // + }}}

    // + Current stage {{{

    public void restart()
    {
        startStage(0, 0.0f);
    }

    private int m_currentStage_no;

    private float m_currentStage_sampleCount;
    // -1.0:
    //  Envelope has ended (the real signifier of this is m_currentStage_no >= m_breakpoints.length/2,
    //  in which case we'll set this to -1.0 for quicker checks subsequently)

    private float m_currentStage_sampleNo;

    private float m_amplitudeIncrement;

    public void startStage(int i_stageNo, float i_atSampleNo)
    // Params:
    //  i_stageNo:
    //   Must be in half-open range [0 .. m_breakpoints.length / 2)
    //  i_atSampleNo:
    //   Must be less than the sample count of the stage
    //   Normally 0.
    {
        // Save new stage number
        m_currentStage_no = i_stageNo;

        // Make the amplitude at the start of this stage be current
        // (fix any accumulated imprecision in counting up from the previous stage start)
        m_currentAmplitude = m_breakpoints[i_stageNo*2 + 1];
        // If there is another breakpoint after this one,
        // get the stage's length, and the increment for changing the amplitude over that length,
        // then move the current amplitude according to where we're starting in the new stage
        // (in case it's not right at the beginning)
        if (m_currentStage_no < m_breakpoints.length/2 - 1)
        {
            m_currentStage_sampleCount = m_breakpoints[(i_stageNo + 1)*2] - m_breakpoints[i_stageNo*2];
            m_amplitudeIncrement = (m_breakpoints[(i_stageNo + 1)*2 + 1] - m_currentAmplitude) / m_currentStage_sampleCount;
            m_currentAmplitude += m_amplitudeIncrement * i_atSampleNo;
        }
        // Else if this is the last breakpoint,
        // set a symbolic dummy length, and don't change the amplitude anymore
        else
        {
            m_currentStage_sampleCount = -1.0f;
            m_amplitudeIncrement = 0.0f;
        }
        //
        m_currentStage_sampleNo = i_atSampleNo;
    }

    public boolean ended()
    {
        return m_currentStage_sampleCount == -1.0f;
    }

    // + }}}

    // + Run {{{

    public float play()
    {
        // Get amplitude which is current for now, which we will return no matter what
        float rv = m_currentAmplitude;

        // The rest of this function updates the envelope state for next time

        // If not reached end
        if (m_currentStage_sampleCount != -1.0f)
        {
            // If reached end of stage, switch to next one
            while (m_currentStage_sampleNo >= m_currentStage_sampleCount
                   && m_currentStage_sampleCount != -1.0f)
            {
                m_currentStage_sampleNo -= m_currentStage_sampleCount;
                startStage(m_currentStage_no + 1, m_currentStage_sampleNo);
            }

            // Update current amplitude and position in stage
            m_currentAmplitude += m_amplitudeIncrement;
            ++m_currentStage_sampleNo;
        }

        // Finally return the current amplitude which we saved at the beginning
        return rv;
    }

    // + }}}

    // + Utilities {{{

    public static float[] scaleBreakpointsBy(float[] i_breakpoints, float i_scalingFactor)
    // Scale envelope breakpoints in time by some factor.
    //
    // Params:
    //  i_breakpoints:
    //   Envelope break points.
    //   Pairs of numbers, where in each pair:
    //    0: (integer) The sample number at which this envelope stage starts
    //    1: (float) The amplitude of the envelope at the start of this envelope stage
    //  i_scalingFactor:
    //   The factor to multiply each time value by.
    //
    // Returns:
    //  A copy of i_breakpoints with the time values scaled by i_scalingFactor.
    {
        float[] rv = new float[i_breakpoints.length];

        for (int breakpointNo = 0; breakpointNo < i_breakpoints.length/2; ++breakpointNo)
        {
            rv[breakpointNo*2] = i_breakpoints[breakpointNo*2] * i_scalingFactor;
            rv[breakpointNo*2 + 1] = i_breakpoints[breakpointNo*2 + 1];
        }

        return rv;
    }

    public static float[] m_scaleBreakpointsBy(float[] io_breakpoints, float i_scalingFactor)
    // Scale envelope breakpoints in time by some factor.
    //
    // Params:
    //  io_breakpoints:
    //   (array)
    //   Envelope break points.
    //   Pairs of numbers, where in each pair:
    //    0: (integer) The sample number at which this envelope stage starts
    //    1: (float) The amplitude of the envelope at the start of this envelope stage
    //  i_scalingFactor:
    //   The factor to multiply each time value by.
    //
    // Returns:
    //  io_breakpoints:
    //   (array)
    //   The time values in this array will have been scaled by i_scalingFactor.
    //   (Note that the input array *is* modified.)
    //  Function return value:
    //   io_breakpoints.
    {
        for (int breakpointNo = 0; breakpointNo < io_breakpoints.length/2; ++breakpointNo)
        {
            io_breakpoints[breakpointNo*2] *= i_scalingFactor;
        }

        return io_breakpoints;
    }

    public static float[] scaleBreakpointsTo(float[] i_breakpoints, float i_newLength)
    // Scale envelope breakpoints in time to a new target length.
    //
    // Params:
    //  i_breakpoints:
    //   Envelope break points.
    //   Pairs of numbers, where in each pair:
    //    0: (integer) The sample number at which this envelope stage starts
    //    1: (float) The amplitude of the envelope at the start of this envelope stage
    //  i_newLength:
    //   The new length that the envelope should be after scaling,
    //   ie. the new time value of the last breakpoint.
    //
    // Returns:
    //  A copy of i_breakpoints with the time values scaled to the range [0 .. i_newLength].
    {
        return OneShotEnvelope.scaleBreakpointsBy(i_breakpoints,
                                                  i_newLength / i_breakpoints[i_breakpoints.length - 2]);
    }

    public static float[] m_scaleBreakpointsTo(float[] io_breakpoints, float i_newLength)
    // Scale envelope breakpoints in time to a new target length.
    //
    // Params:
    //  io_breakpoints:
    //   (array)
    //   Envelope break points.
    //   Pairs of numbers, where in each pair:
    //    0: (integer) The sample number at which this envelope stage starts
    //    1: (float) The amplitude of the envelope at the start of this envelope stage
    //  i_newLength:
    //   The new length that the envelope should be after scaling,
    //   ie. the new time value of the last breakpoint.
    //
    // Returns:
    //  io_breakpoints:
    //   (array)
    //   The time values in this array will have been scaled to the range [0 .. i_newLength].
    //   (Note that the input array *is* modified.)
    //  Function return value:
    //   io_breakpoints.
    {
        return OneShotEnvelope.m_scaleBreakpointsBy(io_breakpoints,
                                                    i_newLength / io_breakpoints[io_breakpoints.length - 2]);
    }

    // + }}}
}


/*
import ddf.minim.UGen;

public class OneShotEnvelope extends ddf.minim.UGen
{
    @Override
    protected void uGenerate(float[] o_channels)
    {
    }
}
*/
