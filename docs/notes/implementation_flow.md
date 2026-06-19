# Implementation Flow

## FPGA-Based Anti-Drone Security System

This document explains the step-by-step implementation flow of the FPGA-Based Anti-Drone Security System. The flow covers the complete path from concept development to MATLAB simulation, Verilog HDL design, Vivado verification, and final documentation.

---

## 1. Project Concept

The project starts with the idea of detecting and classifying suspicious drone activity using wireless security parameters and FPGA-based decision logic.

The system does not directly control or disturb any drone. It focuses only on:

* Detection
* Classification
* Risk-score generation
* FPGA-based decision output
* Research and simulation-based validation

---

## 2. Overall Implementation Flow

```text
Problem Definition
        |
        v
Parameter Selection
        |
        v
MATLAB Algorithm Modeling
        |
        v
Risk-Score Logic Design
        |
        v
Verilog HDL Conversion
        |
        v
Testbench Creation
        |
        v
Vivado Simulation
        |
        v
RTL and Synthesis Analysis
        |
        v
Result Documentation
```

---

## 3. Step 1: Problem Definition

The first step is to define the problem statement.

Unauthorized drones may enter restricted areas or behave abnormally in a wireless environment. Therefore, a security controller is required to evaluate the drone behavior and classify the threat level.

The main goal is to design a system that can take multiple security-related inputs and generate a final risk score.

---

## 4. Step 2: Selection of Input Parameters

Different parameters are selected to evaluate the drone activity.

Important parameters include:

| Parameter            | Purpose                                                     |
| -------------------- | ----------------------------------------------------------- |
| `gamma_D`            | Represents legitimate receiver channel/SNR condition        |
| `gamma_E`            | Represents suspicious receiver or Eve channel/SNR condition |
| `leakage_index`      | Indicates possible information leakage                      |
| `outage_value`       | Indicates communication outage or degradation               |
| `P_auth`             | Authorized power level                                      |
| `P_req`              | Requested power level                                       |
| `can_abnormal`       | Indicates abnormal CAN-related behavior                     |
| `repeated_violation` | Indicates repeated suspicious activity                      |
| `csi_mismatch`       | Indicates mismatch in expected CSI behavior                 |
| `rssi_abnormal`      | Indicates abnormal received signal strength                 |

These inputs are used to check whether the drone behavior is normal or suspicious.

---

## 5. Step 3: MATLAB-Based Algorithm Modeling

MATLAB is used to model the initial logic of the system.

In this stage, the system behavior is tested using different input values and drone scenarios.

MATLAB is used for:

* Defining input parameters
* Creating threat-classification logic
* Calculating risk score
* Testing multiple cases
* Plotting results
* Understanding system behavior before FPGA implementation

This step helps verify the concept before converting the logic into Verilog HDL.

---

## 6. Step 4: Risk-Score Logic Design

The risk-score logic is the main decision-making part of the system.

Each suspicious condition is checked separately. If a condition is true, a fixed risk weight is added to the score.

The basic formula is:

```text
Raw Risk Score = Sum of all triggered risk weights
```

The final risk score is capped at 100:

```text
Final Risk Score = min(100, Raw Risk Score)
```

This ensures that the risk score always remains within the range of 0 to 100.

---

## 7. Step 5: Threat-Level Classification

After calculating the risk score, the system classifies the drone activity into different threat levels.

| Risk Score Range | Threat Level | Meaning                                           |
| ---------------- | ------------ | ------------------------------------------------- |
| 0 to 30          | Low Risk     | Normal or less suspicious behavior                |
| 31 to 70         | Medium Risk  | Suspicious behavior detected                      |
| 71 to 100        | High Risk    | Strong possibility of unauthorized drone activity |

This classification makes the output easier to understand and use in a larger anti-drone monitoring system.

---

## 8. Step 6: Verilog HDL Implementation

After validating the logic in MATLAB, the decision logic is implemented in Verilog HDL.

The Verilog module performs:

* Input reading
* Condition checking
* Risk-score calculation
* Threat classification
* Decision-code generation
* Alert-signal generation

The Verilog implementation makes the design suitable for FPGA-based realization.

---

## 9. Step 7: Wrapper Module Design

A wrapper module is created to connect the main controller with external input and output ports.

The wrapper is useful because it:

* Organizes the top-level design
* Makes FPGA pin mapping easier
* Connects internal logic with external signals
* Helps in hardware-oriented integration
* Keeps the main controller clean and modular

The wrapper does not replace the main controller. It simply acts as an outer connection layer.

---

## 10. Step 8: Testbench Development

A testbench is created to verify the Verilog design without using actual FPGA hardware.

The testbench provides sample input values to the controller and observes the outputs.

The testbench is used to check:

* Risk-score calculation
* Threat-level output
* Decision-code output
* Alert behavior
* Different low, medium, and high-risk cases

This step is important before moving toward synthesis or FPGA implementation.

---

## 11. Step 9: Vivado Project Creation

The Verilog files are added into Xilinx Vivado.

The Vivado project generally includes:

```text
RTL Files
Testbench Files
Constraint File
Simulation Settings
Synthesis Settings
Implementation Settings
```

The main files may include:

```text
anti_drone_controller.v
risk_score_controller.v
top_wrapper.v
tb_anti_drone_controller.v
tb_top_wrapper.v
board_constraints.xdc
```

---

## 12. Step 10: Behavioral Simulation

Behavioral simulation is performed in Vivado to check the logical correctness of the design.

During simulation, the waveform is observed to verify whether the output changes correctly according to the input conditions.

Important outputs observed in simulation include:

* `risk_score`
* `threat_level`
* `decision_code`
* `alert_signal`

If the waveform matches the expected behavior, the design is considered logically correct.

---

## 13. Step 11: RTL Schematic Analysis

After simulation, RTL elaboration is performed in Vivado.

The RTL schematic shows the hardware-level structure of the Verilog design before synthesis.

It helps in understanding:

* Module connections
* Signal flow
* Input-output relationship
* Internal logic structure
* Controller hierarchy

---

## 14. Step 12: Synthesis

Synthesis converts the Verilog HDL design into FPGA-level logic components.

During synthesis, Vivado checks:

* Syntax correctness
* Logical structure
* Resource usage
* Hardware mapping feasibility

After synthesis, the synthesized schematic and synthesis reports are generated.

---

## 15. Step 13: Report Analysis

Vivado generates different reports that help evaluate the design.

Important reports include:

| Report             | Purpose                                     |
| ------------------ | ------------------------------------------- |
| Utilization Report | Shows FPGA resource usage                   |
| Timing Report      | Shows timing behavior and delay information |
| Power Report       | Shows estimated power consumption           |
| Synthesis Report   | Shows synthesis results and warnings        |

These reports are useful for academic documentation and hardware-oriented analysis.

---

## 16. Step 14: Result Collection

After simulation and synthesis, all important results are collected.

Result files may include:

* Simulation waveform screenshots
* RTL schematic screenshots
* Synthesized schematic screenshots
* Device view
* Power report
* Timing report
* Utilization report
* MATLAB plots
* Risk-score output tables

These results are used in the final report and presentation.

---

## 17. Step 15: Documentation

The final step is project documentation.

Documentation includes:

* Project report
* Presentation slides
* GitHub README
* Project explanation notes
* Implementation flow notes
* Viva preparation material
* Figures and block diagrams

Good documentation makes the project easier to understand, present, and evaluate.

---

## 18. Complete Technical Flow

```text
Start
 |
 v
Define anti-drone detection problem
 |
 v
Select CSI, RSSI, secrecy, power, and anomaly parameters
 |
 v
Develop MATLAB logic for risk-score calculation
 |
 v
Test multiple drone threat scenarios
 |
 v
Convert the logic into Verilog HDL
 |
 v
Create wrapper module for top-level design
 |
 v
Write Verilog testbench
 |
 v
Run behavioral simulation in Vivado
 |
 v
Verify waveform output
 |
 v
Generate RTL schematic
 |
 v
Run synthesis
 |
 v
Analyze utilization, timing, and power reports
 |
 v
Collect results and screenshots
 |
 v
Prepare documentation and GitHub repository
 |
 v
End
```

---

## 19. Expected Final Outputs

The final implementation provides the following outputs:

| Output          | Description                                                |
| --------------- | ---------------------------------------------------------- |
| `risk_score`    | Final score representing the seriousness of drone activity |
| `threat_level`  | Low, medium, or high threat classification                 |
| `decision_code` | Encoded controller decision                                |
| `alert_signal`  | Indicates whether suspicious drone activity is detected    |

---

## 20. Summary

The implementation flow starts from the anti-drone security problem and ends with FPGA-oriented verification and documentation.

The project first uses MATLAB to model and test the algorithm. Then the logic is implemented using Verilog HDL and verified using Vivado simulation. After that, RTL schematic, synthesis results, timing report, utilization report, and power report are analyzed.

This flow makes the project suitable for academic demonstration, research documentation, and future FPGA hardware implementation.

---

## Disclaimer

This implementation is intended only for academic, research, and educational purposes. It focuses on drone detection, classification, simulation, and FPGA-based decision logic. It does not include any offensive drone-control, drone-jamming, or drone-disruption technique.
