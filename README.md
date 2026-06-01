# Breakout Game

## Overview

This repository contains a team-based FPGA implementation of the classic **Breakout** arcade game. The project was developed as part of a Computer Engineering course CECS 361 Digital Design Techniques and Verification.

The game recreates the core behavior of Breakout, including paddle control, ball movement, brick collision, scoring, and win/loss conditions. Beyond gameplay, the project emphasizes modular digital design, deterministic timing, collision logic, and clean system integration on FPGA hardware.

---
## Project Goals

The main goal of this project was to design a playable Breakout-style game:

* Modular hardware design
* Finite state machine logic
* Real-time input handling
* Clock-driven game updates
* Collision detection
* VGA/display-oriented rendering logic
* FPGA project organization and implementation

This project demonstrates how a familiar arcade game can be broken down into smaller hardware modules that work together to create a responsive interactive system.

---
## Features

* Paddle movement with real-time user input

* Ball motion and boundary handling

* Brick collision detection and removal

* Score tracking and win/lose conditions

* Modular Verilog design for easier debugging and extension

---
## Technical Highlights

* Implemented game logic using clearly separated modules for input handling, collision detection, rendering, and game state control

* Designed deterministic update logic to ensure consistent gameplay behavior

* Focused on readable, maintainable code to support team collaboration and future enhancements

---
## Project Requirements

| Category                      | Technology             |
| ----------------------------- | ---------------------- |
| Hardware Description Language | Verilog                |
| FPGA Toolchain                | Xilinx Vivado          |
| Target Board                  | Digilent Nexys A7-100T |
| Constraint File               | `NexysA7-100t.xdc`     |
| Version Control               | Git and GitHub         |

---

## Repository Structure

```text
Breakout-Game/
├── FinalProj_Breakout.hw/       # Vivado hardware-related project files
├── FinalProj_Breakout.srcs/     # Verilog source and project source files
├── FinalProj_Breakout.xpr       # Vivado project file
├── NexysA7-100t.xdc             # FPGA constraints file for Nexys A7-100T
├── .gitignore
└── README.md
```

---

## How to Open the Project

1. Clone the repository:

```bash
git clone https://github.com/Retiredknight7/Breakout-Game.git
```

2. Open **Xilinx Vivado**.

3. Select:

```text
Open Project
```

4. Open the Vivado project file:

```text
FinalProj_Breakout.xpr
```

5. Verify that the constraint file is included:

```text
NexysA7-100t.xdc
```

6. Run synthesis, implementation, and bitstream generation.

7. Program the Nexys A7-100T FPGA board.

###  Expected Gameplay
The player controls a paddle and attempts to keep the ball in play while breaking bricks. The ball bounces off walls, the paddle, and bricks. When a brick is hit, it is removed and the score updates. The game continues until the player clears the bricks or loses based on the game-over condition.

---

## Skills Demonstrated

This project demonstrates practical experience with:

* FPGA development
* Verilog hardware design
* Digital logic organization
* Game state management
* Timing and clock-driven updates
* Collision detection logic
* Hardware debugging
* Team-based engineering workflow
* Git/GitHub version control

---

## Team Contributions

This project was developed collaboratively. Team members contributed to system design, Verilog implementation, debugging, testing, and final integration.

Special thanks to my teammates:

### Yshi Blanco

[yshi.blanco01@student.csulb.edu](mailto:yshi.blanco01@student.csulb.edu)

### Paris Talebi

[paris.talebi01@student.csulb.edu](mailto:paris.talebi01@student.csulb.edu)

---

## Future Improvements

Potential improvements for future versions include:

* Adding multiple levels
* Improving paddle and ball physics
* Adding lives or difficulty scaling
* Enhancing visual output
* Adding sound effects
* Creating a start screen and pause state
* Refactoring modules for easier simulation and testing

---
## Hardware Reminders
* Requires an external VGA monitor for display
* Designed for the Nexys A7-100T FPGA board
* VGA output pixels at 640×480 resolution at 60 Hz refresh rate
  
