# Project Explanation

## FPGA-Based Anti-Drone Security System

This project presents a research-oriented Anti-Drone Security System that uses wireless signal analysis, Physical Layer Security concepts, MATLAB simulation, and FPGA-based Verilog logic to detect and classify suspicious drone activity.

The main goal of this project is to design a decision-making system that can observe different security-related parameters and generate a risk score. Based on this risk score, the system can classify the drone activity as low risk, medium risk, or high risk.

---

## 1. Project Background

Unauthorized drones can create security issues near airports, defense areas, public events, industrial zones, and restricted locations. A drone may enter a protected area without permission, communicate with unknown devices, or behave abnormally in the wireless environment.

To identify such activity, the system needs to observe different parameters related to communication, signal strength, channel behavior, authentication, and anomaly status.

This project focuses on the detection and classification part of an anti-drone system. It does not implement any offensive drone-disruption mechanism. The work is limited to academic research, simulation, FPGA logic design, and threat-level decision making.

---

## 2. Basic Idea of the System

The system collects different input parameters from the drone communication environment. These parameters are then checked using predefined security conditions.

If a condition indicates suspicious behavior, a specific risk weight is added to the total score. Finally, the total score is capped at 100 and used to decide the threat level.

```text
Input Parameters
      |
      v
Security Condition Checking
      |
      v
Risk Score Generation
      |
      v
Threat Classification
      |
      v
FPGA-Based Decision Output
```

---

## 3. Main Technologies Used

The project uses multiple tools and technologies:

| Area               | Tool / Concept                     |
| ------------------ | ---------------------------------- |
| Algorithm Modeling | MATLAB                             |
| Hardware Design    | Verilog HDL                        |
| FPGA Tool          | Xilinx Vivado                      |
| Security Concept   | Physical Layer Security            |
| Wireless Analysis  | CSI and RSSI                       |
| Verification       | Testbench and Simulation Waveforms |
| Documentation      | LaTeX, Markdown, PDF Reports       |

---

## 4. Physical Layer Security Concept

Physical Layer Security focuses on protecting wireless communication by using the properties of the wireless channel itself.

In normal communication, a legitimate transmitter communicates with an authorized receiver. However, an unauthorized drone or eavesdropper may try to receive or interfere with the communication.

The system observes channel-related parameters and checks whether the communication behavior looks normal or suspicious.

Important security indicators include:

* Difference between legitimate and suspicious channel conditions
* Secrecy-related parameters
* Leakage index
* Outage condition
* Requested power level
* Repeated violation behavior

---

## 5. CSI and RSSI in Drone Detection

### CSI

CSI stands for Channel State Information. It describes how a wireless signal travels from transmitter to receiver.

CSI can change due to:

* Distance
* Movement
* Obstacles
* Reflection
* Drone position
* Wireless channel condition

In this project, CSI-related behavior helps in understanding whether the communication channel belongs to a normal authorized drone or a suspicious drone.

### RSSI

RSSI stands for Received Signal Strength Indicator. It shows how strong the received wireless signal is.

RSSI can help in estimating:

* Whether the drone is near or far
* Whether the received signal is unusually strong or weak
* Whether the signal behavior is suspicious

CSI and RSSI together provide useful information for drone detection and classification.

---

## 6. Input Parameters Used in the System

The system considers multiple input parameters for risk-score generation.

| Parameter            | Meaning                                                      |
| -------------------- | ------------------------------------------------------------ |
| `gamma_D`            | Channel/SNR-related value for the legitimate receiver        |
| `gamma_E`            | Channel/SNR-related value for the suspicious receiver or Eve |
| `leakage_index`      | Indicates possible information leakage                       |
| `outage_value`       | Indicates link outage or communication degradation           |
| `P_auth`             | Authorized power level                                       |
| `P_req`              | Requested power level                                        |
| `can_abnormal`       | Indicates abnormal CAN-related behavior                      |
| `repeated_violation` | Indicates repeated suspicious activity                       |
| `csi_mismatch`       | Indicates mismatch in expected CSI behavior                  |
| `rssi_abnormal`      | Indicates abnormal received signal strength                  |

---

## 7. Risk Score Generation

The main decision logic of the system is based on risk-score generation.

Each suspicious condition contributes a specific score. The final score is calculated by adding all triggered risk contributions.

```text
Raw Risk Score = Sum of all triggered risk weights
```

The score is then limited to a maximum value of 100.

```text
Final Risk Score = min(100, Raw Risk Score)
```

This prevents the score from exceeding the maximum threat range.

---

## 8. Threat Classification

After generating the final risk score, the system classifies the drone activity into different levels.

| Risk Score Range | Threat Level | Meaning                                           |
| ---------------- | ------------ | ------------------------------------------------- |
| 0 to 30          | Low Risk     | Normal or less suspicious activity                |
| 31 to 70         | Medium Risk  | Suspicious activity detected                      |
| 71 to 100        | High Risk    | Strong possibility of unauthorized drone behavior |

This classification helps the controller decide how serious the detected activity is.

---

## 9. MATLAB Role in the Project

MATLAB is used for algorithm-level modeling and simulation.

It helps in:

* Testing the threat-classification logic
* Observing risk-score behavior
* Analyzing CSI/RSSI-based detection concepts
* Generating plots and results
* Checking the system behavior before hardware implementation

MATLAB allows quick testing of different drone scenarios before converting the logic into Verilog HDL.

---

## 10. Verilog HDL Role in the Project

Verilog HDL is used to design the FPGA-based controller logic.

The Verilog design performs:

* Input parameter checking
* Risk-score calculation
* Threat-level classification
* Decision-code generation
* Alert output generation

The Verilog logic makes the system suitable for FPGA implementation.

---

## 11. Vivado Role in the Project

Xilinx Vivado is used for FPGA design, simulation, and analysis.

Vivado is used for:

* Adding RTL Verilog files
* Adding testbench files
* Running behavioral simulation
* Observing simulation waveforms
* Generating RTL schematic
* Running synthesis
* Checking utilization report
* Checking timing report
* Checking power report

This helps verify whether the Verilog design is suitable for FPGA-based implementation.

---

## 12. Wrapper Module

A wrapper module is used to connect the internal controller logic with external input and output signals.

The wrapper helps in:

* Making the design easier to connect with FPGA pins
* Organizing input and output ports
* Testing the main controller in a structured way
* Preparing the design for top-level integration

The wrapper is not the main logic itself. It acts like an outer layer around the main controller.

---

## 13. Testbench

A testbench is used to verify the Verilog design without using actual hardware.

The testbench provides sample input values and observes the output behavior.

It helps in checking:

* Whether the risk score is calculated correctly
* Whether the threat level changes correctly
* Whether alert outputs are generated properly
* Whether different input scenarios produce expected results

---

## 14. Expected Outputs

The system mainly produces the following outputs:

| Output          | Description                                  |
| --------------- | -------------------------------------------- |
| `risk_score`    | Final calculated threat score                |
| `threat_level`  | Low, medium, or high-risk classification     |
| `decision_code` | Encoded decision generated by the controller |
| `alert_signal`  | Indicates suspicious or dangerous activity   |

These outputs make the system useful for further integration with a larger anti-drone monitoring framework.

---

## 15. Complete Project Flow

```text
Start
 |
 v
Define drone security parameters
 |
 v
Model detection logic in MATLAB
 |
 v
Analyze risk-score behavior
 |
 v
Convert decision logic into Verilog HDL
 |
 v
Write testbench for verification
 |
 v
Simulate design in Vivado
 |
 v
Observe waveform outputs
 |
 v
Generate RTL schematic and reports
 |
 v
Prepare documentation and GitHub repository
```

---

## 16. Project Applications

This project can be useful in:

* Anti-drone surveillance research
* FPGA-based security controller design
* Wireless threat detection
* Physical Layer Security studies
* UAV communication security
* Restricted-zone monitoring
* Academic project demonstration
* Research paper support work

---

## 17. Future Scope

The project can be improved further by adding:

* Real-time FPGA board implementation
* Real drone signal dataset testing
* RF sensor integration
* Machine learning-based classification
* Real-time CSI/RSSI extraction
* More advanced threat scoring
* Dashboard-based monitoring
* Multi-drone scenario analysis

---

## 18. Conclusion

This project demonstrates a complete academic framework for an FPGA-based Anti-Drone Security System. It combines MATLAB simulation, CSI/RSSI-based wireless analysis, Physical Layer Security concepts, Verilog HDL design, and Vivado verification.

The main contribution of the project is the development of a risk-score-based decision controller that can classify drone activity into different threat levels. This makes the project useful for research, simulation, documentation, and future FPGA hardware implementation.

---

## Disclaimer

This project is developed only for academic, research, and educational purposes. It focuses on drone detection, threat classification, simulation, and FPGA-based decision logic. It does not include any offensive drone-control, drone-jamming, or drone-disruption mechanism.
