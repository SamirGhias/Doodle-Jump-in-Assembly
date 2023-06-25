# Doodle Jump Assembly Project Overview
In this University project, we implemented the popular mobile game Doodle Jump (https://en.wikipedia.org/wiki/Doodle_Jump) from scratch using MIPS assembly. 
We run our implementation in a simulated environment within MARS, i.e., a simulated bitmap display and a simulated keyboard input.

Description:

The player presses the key "j" to make the Doodler move to the left and pressed the key "k" to move to the right, When no key is pressed, the Doodler falls straight down until it hits a platform or the bottom of the screen. If it hits a platform, the Doodler bounces up high into the air, but if the Doodler hits the bottom of the screen, the game ends.

Demo:

<p align="center">
  <img src="https://github.com/SamirGhias/Doodle-Jump-in-Assembly/blob/main/doodlejumpMedia/demo.gif" alt="animated" />
</p>

# Tasks/Features Completed:
- The Doodler and the platforms are properly drawn (statically) on the screen.
- The movement controls of the Doodler and the platforms (by the keyboard and timers) are properly implemented.
- The Doodler can overlap and reappear on the opposite end of the screen.
- collision detection for platforms and obstacles to progress or end the game.
- Display the score in the console. The score should be constantly updated as the game progresses.
- Moving blocks (we implemented clouds) Different types of clouds are distinguished by different colors.
- Opponents / lethal creatures that can move and hurt the Doodler. (Storm Clouds).
- Dynamic background: dynamically changing background during the game (e.g., clouds moving horizontally). The movement must be different from that of the platforms.
- Changing difficulty as the game progresses: gradually increase the difficulty of the game by shrinking the platforms as the game progresses.
- Display GG (good game) upon game over.



# How to Setup and Run Mars Simulator

- Download and install Mars Simulator: https://courses.missouristate.edu/kenvollmar/mars/download.htm
- run the .Jar file with a JDK installed and open the doodlejump.s file above.
- To open and connect the bitmap display in MARS, click on "Tools" in the menu bar then select "Bitmap Display". In the opened window, choose the appropriate configuration values (e.g., the values shown in the video Below), and click on "Connect to MIPS" to plug the display into your simulated MIPS computer.

<p align="center">
  <img src="https://github.com/SamirGhias/Doodle-Jump-in-Assembly/blob/main/doodlejumpMedia/DisplaySetup.gif" alt="animated" />
</p>

- To connect the keyboard in MARS, click on "Tools" in the menu bar and select "Keyboard and Display MMIO Simulator". Then, click on the "Connect to MIPS" button on the bottom-left to plug in the simulated keyboard.

<p align="center">
  <img src="https://github.com/SamirGhias/Doodle-Jump-in-Assembly/blob/main/doodlejumpMedia/keyboardSetup.gif" alt="animated" />
</p>

- Once the display and keyboard are correctly configured as above, click the 'Assemble' button near the center of the tool bar.
- Press the green play button, and click in the text box in the "Keyboard and Display MMIO Simulator" to start registering inputs correctly.
- Move left and right Using keys J and K.

