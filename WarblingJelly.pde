
// This is the main file for playing and hacking.

// If you are already familiar with Processing, and are looking for the 'real'
// setup() and loop() functions, look at the 'main' tab.


Warble warble;
// A variable to hold the Warble sound synthesizer


void _setup()
// This function is automatically executed once, when the program starts.
// So, it contains things that need to be done only once.
{
    // Create the Warble sound synthesizer and store it in the variable above,
    // giving it the computer speaker as the place for it to output its sound to
    warble = new Warble(speaker);


    // Setup the Warble sound synthesizer
    warblePreset_cricket_setup();
    //warblePreset_frog_setup();
    //warblePreset_prettyTweetingBird_setup();
    //warblePreset_helicopterComingThrough_setup();
    //warblePreset_choppedBird_setup();
    //warblePreset_bouncingRemains_setup();
    //warblePreset_almostMusical_setup();
}


void control()
// This function is automatically executed every time a new sensor reading comes in.
{
    // Apply current sensor values to the Warble sound synthesiser
    warblePreset_cricket_control();
    //warblePreset_frog_control();
    //warblePreset_prettyTweetingBird_control();
    //warblePreset_helicopterComingThrough_control();
    //warblePreset_choppedBird_control();
    //warblePreset_bouncingRemains_control();
    //warblePreset_almostMusical_control();
}


void _draw()
// This function is automatically executed repeatedly, about 60 times per second.
// So, it contains things that need to be done repeatedly or continuously for as long as the program runs,
// eg. reading the capacitive sensors and updating the characteristics of the sound.
//
// If you know Processing, you can also draw extra graphics in here.
// See: https://processing.org/reference/
{
}
