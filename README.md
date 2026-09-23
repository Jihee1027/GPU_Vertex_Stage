# GPU Vertex Stage

This repo is for our GPU Vertex Stage project.

The main goal of this stage is to take vertex data, transform it with the matrix, do perspective division, convert it to screen space, and send the result to the rasterizer.

## Folder Structure

```text
source/       RTL modules
testbench/    Testbenches
scripts/      Questa waveform scripts
include/      Header files if we need them later
mapped/       Generated synthesis files
fpga/         FPGA build files
```

## Source Modules

`controller.sv`  
Controls the main flow of the Vertex Stage.

`fixed_point_divider.sv`  
Does signed fixed point division.

`matrix_register_bank.sv`  
Stores the transformation matrix values used by the vertex stage.

`matrix_vector_mul.sv`  
Handles the full matrix vector multiplication.

`normal_transform.sv`  
Transforms the normal vector.

`perspective_divide.sv`  
Divides x, y, and z by w after the matrix transformation.

`primitive_input_fifo.sv`  
Buffers incoming primitive data before processing.

`primitive_output_fifo.sv`  
Buffers transformed primitive data before sending it to the next stage.

`row_mac.sv`  
Calculates one row of the matrix vector multiplication.

`screen_space_transform.sv`  
Converts normalized coordinates into screen coordinates and depth.

`top.sv`  
Top level module for the Vertex Stage.

`transform.sv`  
Connects the main transformation steps for vertex processing.

`vertex_pkg.sv`  
Contains shared types, parameters, or definitions used by the Vertex Stage.

Some modules are still being worked on, so the interfaces may change as we integrate everything.

## Running Simulation

To run a testbench in the terminal:

```bash
make row_mac.sim
make fixed_point_divider.sim
```

To open the waveform:

```bash
make row_mac.wav
make fixed_point_divider.wav
```

Waveform setup files are in the `scripts` folder.

The general format is:

```bash
make <module>.sim
make <module>.wav
```

## Synthesis

For functional synthesis:

```bash
make <module>.syn
```

For timing synthesis:

```bash
make <module>.syntp
```

The current target frequency is 100 MHz.

Example:

```bash
make fixed_point_divider.syntp
```

## Branches

```text
main
vertex_jihee
vertex_benjamin
vertex_noah
```

Work on your own branch and push your changes there. Once something is working, we can merge it into `main`.
