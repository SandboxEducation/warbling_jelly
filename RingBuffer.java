class RingBuffer
{
    RingBuffer()
    {
    }

    // + The buffer {{{

    private float[] m_buffer;

    public int getCapacity()
    {
        return m_buffer.length;
    }

    public void setCapacity(int i_capacity)
    // Change the buffer capacity.
    // Note that this will clear the buffer.
    {
        m_buffer = new float[i_capacity];
        m_valueCount = 0;
    }

    // + }}}

    // + Values {{{

    private int m_valueCount = 0;
    public int getValueCount()
    {
        return m_valueCount;
    }

    private int m_writePosition = 0;

    public void push(float i_value)
    {
        // Save value
        m_buffer[m_writePosition] = i_value;

        // Increment write position with wrap around
        ++m_writePosition;
        if (m_writePosition >= m_buffer.length)
            m_writePosition = 0;

        // If the ring isn't already eating itself, increment value count
        if (m_valueCount < m_buffer.length)
            ++m_valueCount;
    }

    public float getValue(int i_age)
    {
        // Get most recent value's position
        int readPosition = m_writePosition - 1 - i_age;

        // Wrap position if out of bounds
        while (readPosition < 0)
            readPosition += m_buffer.length;

        // Read and return value
        return m_buffer[readPosition];
    }

    public float getMeanValue(int i_valueCount)
    // Get mean of some number of the most recent values.
    //
    // Params:
    //  i_valueCount:
    //   Either >= 0:
    //    Number of values to average.
    //    Should not be more than the value count; if so, behaviour is undefined.
    //   or -1:
    //    Average all of the values in the buffer (ie. use the value count).
    {
        // Apply default arguments
        if (i_valueCount == -1)
            i_valueCount = getValueCount();

        // Get most recent value's position
        int readPosition = m_writePosition - 1;

        // While we still want more values
        float sum = 0.0f;
        for (int valueNo = 0; valueNo < i_valueCount; ++valueNo)
        {
            // Wrap position if out of bounds
            while (readPosition < 0)
                readPosition += m_buffer.length;

            // Read and add value to sum
            sum += m_buffer[readPosition];

            //
            --readPosition;
        }

        // Divide total to get mean then return it
        return sum / i_valueCount;
    }

    void updateValueExtents(float[] io_minMax)
    // Params:
    //  io_minMax:
    //   Previous minimum and maximum to be modified.
    //   For the first call, you probably want to initialize these to [Float.MAX_VALUE, Float.MIN_VALUE].
    //
    // Returns:
    //  io_minMax:
    //   The new minimum and maximum values, after taking into account all the values in the history.
    {
        for (int valueNo = 0; valueNo < m_valueCount; ++valueNo)
        {
            float value = getValue(valueNo);
            if (value < io_minMax[0])
                io_minMax[0] = value;
            if (value > io_minMax[1])
                io_minMax[1] = value;
        }
    }

    // + }}}

    public void printContents(int i_valueCount)
    // Print some number of the most recent values.
    // For debugging.
    //
    // Params:
    //  i_valueCount:
    //   Either >= 0:
    //    Number of values to print, most recent first.
    //   or -1:
    //    Print all of the values in the buffer.
    {
        // Apply default arguments
        if (i_valueCount == -1)
            i_valueCount = getValueCount();

        // Get most recent value's position
        int readPosition = m_writePosition - 1;

        // While we still want more values
        float sum = 0.0f;
        for (int valueNo = 0; valueNo < i_valueCount; ++valueNo)
        {
            if (valueNo > 0)
                System.out.print(", ");

            // Wrap position if out of bounds
            while (readPosition < 0)
                readPosition += m_buffer.length;

            // Read and print value
            System.out.print(m_buffer[readPosition]);

            //
            --readPosition;
        }

        System.out.println("");
    }
}
