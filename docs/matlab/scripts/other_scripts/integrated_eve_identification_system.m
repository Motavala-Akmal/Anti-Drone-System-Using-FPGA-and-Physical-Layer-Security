clc;
clear;
close all;

% ============================================================
% INTEGRATED EVE IDENTIFICATION SYSTEM
% Anti-Drone Physical Layer Security
%
% FULL WORKFLOW:
%
% Stage 0:
%   Boundary presence detection
%   Mobility classification: Static / Hovering / Dynamic
%
% Stage 1:
%   Eve situation category classification
%   Activity category, identity category, number category,
%   special case detection
%
% Stage 2:
%   Detailed Eve identification using:
%   RSSI, CSI, location, RF fingerprint, authentication,
%   SNR, BER, secrecy capacity, jamming, relay, collusion
%
% Stage 3:
%   Final decision and visualization
%
% NOTE:
% This is PART 1 of 4.
% Do not run the file until all four parts are pasted.
% ============================================================


%% ============================================================
% SELECT TEST SCENARIO
% ============================================================
%
% scenarioType = 1  --> No drone present
% scenarioType = 2  --> Verified authorized Bob
% scenarioType = 3  --> Static passive unknown drone
% scenarioType = 4  --> Hovering active unknown drone
% scenarioType = 5  --> Dynamic transmitting-receiving drone
% scenarioType = 6  --> Jamming Eve
% scenarioType = 7  --> Static Eve acting as Bob
% scenarioType = 8  --> Eve very close to Bob, difficult case
% scenarioType = 9  --> Multiple independent Eves
% scenarioType = 10 --> Multiple colluding Eves
% scenarioType = 11 --> Intermittent Eve
% scenarioType = 12 --> Drone entering and leaving boundary
%
% Start with scenarioType = 2 to verify Bob.
% Then use scenarioType = 7 to verify static Eve acting as Bob.
% ============================================================

cfg.enablePlots = enablePlots;


%% ============================================================
% SIMULATION TIME SETTINGS
% ============================================================

cfg.tStart = 0;          % seconds
cfg.tStop  = 120;        % seconds
cfg.tStep  = 1;          % seconds

cfg.t = cfg.tStart:cfg.tStep:cfg.tStop;
cfg.N = length(cfg.t);


%% ============================================================
% STAGE-0: SQUARE BOUNDARY SETTINGS
% ============================================================

% Protected square boundary
cfg.xMin = 0;
cfg.xMax = 100;
cfg.yMin = 0;
cfg.yMax = 100;

% Four authorized monitoring nodes placed at four corners
cfg.monitorNodes = [
    cfg.xMin, cfg.yMin;      % Monitor-1
    cfg.xMax, cfg.yMin;      % Monitor-2
    cfg.xMax, cfg.yMax;      % Monitor-3
    cfg.xMin, cfg.yMax       % Monitor-4
];

% Sensing range of each monitoring node
cfg.sensingRange = 80;       % meters


%% ============================================================
% EXPECTED LEGITIMATE BOB PROFILE
% ============================================================

cfg.expectedBobID = "BOB_01";

% Expected physical position of Bob inside the square boundary
cfg.expectedBobPosition = [70 50];       % [x y] in meters

% Expected RSSI of Bob
cfg.expectedBobRSSI_dBm = -55;           % dBm

% Expected mobility behavior of Bob
cfg.expectedBobMobility = "Static";

% Expected RF fingerprint distance of Bob should be low
cfg.expectedBobRFFingerprintDistance = 0.10;


%% ============================================================
% STAGE-0: MOBILITY CLASSIFICATION THRESHOLDS
% ============================================================

% Static drone:
% Almost no movement, very small position fluctuation
cfg.staticMeanSpeedMax = 0.15;       % m/s
cfg.staticPositionStdMax = 0.50;     % meters
cfg.staticNetDispMax = 1.00;         % meters

% Hovering drone:
% Small oscillation around a fixed region
cfg.hoverMeanSpeedMax = 1.20;        % m/s
cfg.hoverPositionStdMax = 3.00;      % meters
cfg.hoverNetDispMax = 6.00;          % meters

% If the drone exceeds the hovering limits, it is treated as dynamic.


%% ============================================================
% STAGE-1: CATEGORY CLASSIFICATION THRESHOLDS
% ============================================================

% Link degradation / jamming related thresholds
cfg.interferenceHighTh = -75;        % dBm
cfg.snrBobLowTh = 10;                % dB
cfg.berHighTh = 1e-2;                % BER

% Identity and channel mismatch thresholds
cfg.csiMismatchTh = 0.35;            % normalized value between 0 and 1
cfg.rssiMismatchTh = 8;              % dB
cfg.locationErrorTh = 10;            % meters

% Relay detection threshold
cfg.latencyRelayTh = 25;             % ms

% Collusion and intermittent behavior thresholds
cfg.collusionCorrTh = 0.85;
cfg.intermittentDutyMin = 0.10;
cfg.intermittentDutyMax = 0.70;


%% ============================================================
% STAGE-2: DETAILED IDENTIFICATION THRESHOLDS
% ============================================================

% RF fingerprint mismatch threshold
cfg.rfFingerprintTh = 0.30;          % normalized value between 0 and 1

% Required secrecy rate
cfg.secrecyRateRequired = 1.0;       % bits/s/Hz

% Final decision score thresholds
cfg.needsVerificationScore = 20;
cfg.suspiciousScore = 40;
cfg.likelyEveScore = 65;
cfg.highRiskEveScore = 80;


%% ============================================================
% STAGE-3: PLOT SETTINGS
% ============================================================

% Plots will be created in Part 4.
% Keep this true if you want final figures.
cfg.enablePlots = true;


%% ============================================================
% CREATE SCENARIO DATA
% ============================================================
% This function will be provided in Part 2.
% It creates the drone/node data for the selected scenario.

situation = createIntegratedScenario(scenarioType, cfg);


%% ============================================================
% RUN COMPLETE SYSTEM
% ============================================================
% This function will be provided in Part 3.
% It internally runs:
%   Stage 0: Boundary + mobility
%   Stage 1: Situation category
%   Stage 2: Detailed Eve identification

[stage0Table, stage1Table, stage2Table, scoreTable, ...
    monitorTable, globalSummary] = runIntegratedEveSystem(situation, cfg);


%% ============================================================
% DISPLAY STAGE-0 OUTPUT
% ============================================================

disp('============================================================');
disp('                    STAGE-0 OUTPUT');
disp('        Boundary Presence and Mobility Classification');
disp('============================================================');
disp(stage0Table);


%% ============================================================
% DISPLAY STAGE-1 OUTPUT
% ============================================================

disp(' ');
disp('============================================================');
disp('                    STAGE-1 OUTPUT');
disp('             Eve Situation Category Classification');
disp('============================================================');
disp(stage1Table);


%% ============================================================
% DISPLAY STAGE-2 OUTPUT
% ============================================================

disp(' ');
disp('============================================================');
disp('                    STAGE-2 OUTPUT');
disp('              Detailed Eve Identification Result');
disp('============================================================');
disp(stage2Table);


%% ============================================================
% DISPLAY SCORE BREAKDOWN
% ============================================================

disp(' ');
disp('============================================================');
disp('                    SCORE BREAKDOWN');
disp('============================================================');
disp(scoreTable);


%% ============================================================
% DISPLAY MONITOR NODE SUMMARY
% ============================================================

disp(' ');
disp('============================================================');
disp('              MONITOR NODE DETECTION SUMMARY');
disp('============================================================');
disp(monitorTable);


%% ============================================================
% DISPLAY GLOBAL SUMMARY
% ============================================================

disp(' ');
disp('============================================================');
disp('                    GLOBAL SUMMARY');
disp('============================================================');
disp(globalSummary);


%% ============================================================
% PLOT FINAL RESULTS
% ============================================================
% Plotting function will be provided in Part 4.

if cfg.enablePlots == true
    plotIntegratedEveResults(situation, cfg, ...
        stage0Table, stage1Table, stage2Table, scoreTable, monitorTable);
end


% ============================================================
% END OF PART 1
% Paste Part 2 directly below this line.
% ============================================================
% ============================================================
% PART 2 OF 4
% SCENARIO GENERATION FUNCTIONS
%
% This part creates different drone/Eve/Bob situations.
% Paste this directly below Part 1.
% Do not run the file until Parts 1, 2, 3, and 4 are complete.
% ============================================================


function situation = createIntegratedScenario(scenarioType, cfg)

    t = cfg.t;
    N = cfg.N;

    situation.t = t;
    situation.description = "";

    % ------------------------------------------------------------
    % Default normal Bob link condition
    % This represents the legitimate Alice-to-Bob channel.
    % ------------------------------------------------------------
    situation.link.snrBob_dB = 18 + 0.5*randn(1,N);
    situation.link.berBob = 1e-4 + 1e-5*rand(1,N);
    situation.link.interference_dBm = -92 + 2*randn(1,N);

    switch scenarioType

        case 1
            % ========================================================
            % SCENARIO 1: No drone present
            % ========================================================
            situation.description = "No Drone Present";
            drones = [];

        case 2
            % ========================================================
            % SCENARIO 2: Verified authorized Bob
            %
            % This is the clean legitimate case.
            % The drone is Bob, registered, authenticated,
            % located near expected Bob position, and has low mismatch.
            % ========================================================
            situation.description = "Verified Authorized Bob";

            drones(1) = makeDrone( ...
                "Drone-1", ...                         % name
                "BOB_01", ...                          % claimed ID
                true, ...                              % registered
                true, ...                              % authentication passed
                true, ...                              % tx detected
                true, ...                              % rx detected
                true, ...                              % external detection
                false, ...                             % pilot mismatch
                false, ...                             % relay evidence
                [70 + 0.05*randn(N,1), ...
                 50 + 0.05*randn(N,1)], ...            % position
                -55 + 1.0*randn(1,N), ...              % RSSI
                0.12 + 0.02*randn(1,N), ...            % CSI mismatch
                8 + 0.5*randn(1,N), ...                % possible node SNR
                7 + randn(1,N), ...                    % latency
                1e-4 + 1e-5*rand(1,N), ...             % BER
                ones(1,N), ...                         % activity pattern
                0.10);                                 % RF fingerprint distance

        case 3
            % ========================================================
            % SCENARIO 3: Static passive unknown drone
            %
            % Passive Eve does not transmit.
            % Therefore, direct RSSI and CSI from Eve are unavailable.
            % It is assumed to be detected by external monitoring,
            % such as radar, camera, or sensing node.
            % ========================================================
            situation.description = "Static Passive Unknown Drone";

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "NO_ID", ...
                false, ...
                false, ...
                false, ...                             % no transmission
                true, ...                              % only receiving/listening
                true, ...
                false, ...
                false, ...
                [55 + 0.05*randn(N,1), ...
                 45 + 0.05*randn(N,1)], ...
                nan(1,N), ...                          % RSSI unavailable
                nan(1,N), ...                          % CSI unavailable
                21 + 0.8*randn(1,N), ...               % estimated Eve SNR
                nan(1,N), ...
                nan(1,N), ...
                ones(1,N), ...
                0.80);

        case 4
            % ========================================================
            % SCENARIO 4: Hovering active unknown drone
            %
            % The drone stays in a small region but moves slightly.
            % It is unauthorized and transmits actively.
            % ========================================================
            situation.description = "Hovering Active Unknown Drone";

            pos = [
                60 + 1.5*sin(0.20*t') + 0.30*randn(N,1), ...
                50 + 1.2*cos(0.20*t') + 0.30*randn(N,1)
            ];

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "UNKNOWN_01", ...
                false, ...
                false, ...
                true, ...
                false, ...
                true, ...
                true, ...
                false, ...
                pos, ...
                -48 + 1.5*randn(1,N), ...
                0.55 + 0.04*randn(1,N), ...
                16 + randn(1,N), ...
                10 + randn(1,N), ...
                4e-3 + 1e-3*rand(1,N), ...
                ones(1,N), ...
                0.65);

        case 5
            % ========================================================
            % SCENARIO 5: Dynamic transmitting-receiving drone
            %
            % The drone moves from one region to another inside
            % the protected square boundary.
            % ========================================================
            situation.description = "Dynamic Transmitting-Receiving Drone";

            pos = [
                linspace(15,85,N)' + 0.60*randn(N,1), ...
                linspace(20,75,N)' + 0.60*randn(N,1)
            ];

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "UNKNOWN_DYNAMIC", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                pos, ...
                -50 + 3*sin(0.12*t) + randn(1,N), ...
                0.60 + 0.05*randn(1,N), ...
                17 + 2*sin(0.10*t) + randn(1,N), ...
                12 + 2*randn(1,N), ...
                3e-3 + 8e-4*rand(1,N), ...
                ones(1,N), ...
                0.70);

        case 6
            % ========================================================
            % SCENARIO 6: Jamming Eve
            %
            % Bob's SNR decreases, BER increases, and interference
            % level becomes high.
            % ========================================================
            situation.description = "Jamming Eve";

            situation.link.snrBob_dB = 7 + 1.5*randn(1,N);
            situation.link.berBob = 2e-2 + 5e-3*rand(1,N);
            situation.link.interference_dBm = -62 + 3*randn(1,N);

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "UNKNOWN_JAMMER", ...
                false, ...
                false, ...
                true, ...
                false, ...
                true, ...
                true, ...
                false, ...
                [65 + 0.15*randn(N,1), ...
                 55 + 0.15*randn(N,1)], ...
                -32 + 1.5*randn(1,N), ...
                0.82 + 0.03*randn(1,N), ...
                8 + randn(1,N), ...
                6 + randn(1,N), ...
                3e-2 + 5e-3*rand(1,N), ...
                ones(1,N), ...
                0.90);

        case 7
            % ========================================================
            % SCENARIO 7: Static Eve acting as Bob
            %
            % Eve claims Bob's ID, but it is not registered and
            % authentication fails.
            % ========================================================
            situation.description = "Static Eve Acting as Bob";

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "BOB_01", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [45 + 0.08*randn(N,1), ...
                 35 + 0.08*randn(N,1)], ...
                -38 + 1.2*randn(1,N), ...
                0.72 + 0.04*randn(1,N), ...
                24 + randn(1,N), ...
                8 + randn(1,N), ...
                1e-3 + 2e-4*rand(1,N), ...
                ones(1,N), ...
                0.85);

        case 8
            % ========================================================
            % SCENARIO 8: Eve very close to Bob
            %
            % This is a difficult case.
            % RSSI and location look similar to Bob.
            % Authentication and RF fingerprint are very important here.
            % ========================================================
            situation.description = "Eve Close to Bob: Difficult Case";

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "BOB_01", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [70 + 0.10*randn(N,1), ...
                 50 + 0.10*randn(N,1)], ...
                -55 + 1.0*randn(1,N), ...
                0.22 + 0.03*randn(1,N), ...
                18 + 0.8*randn(1,N), ...
                8 + randn(1,N), ...
                1e-3 + 2e-4*rand(1,N), ...
                ones(1,N), ...
                0.75);

        case 9
            % ========================================================
            % SCENARIO 9: Multiple independent Eves
            %
            % Multiple unauthorized drones are present, but their
            % activity patterns are not strongly correlated.
            % ========================================================
            situation.description = "Multiple Independent Eves";

            activity1 = ones(1,N);
            activity2 = double(rand(1,N) > 0.35);

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "UNKNOWN_A", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [35 + 0.10*randn(N,1), ...
                 40 + 0.10*randn(N,1)], ...
                -45 + randn(1,N), ...
                0.60 + 0.04*randn(1,N), ...
                18 + randn(1,N), ...
                11 + randn(1,N), ...
                2e-3 + 5e-4*rand(1,N), ...
                activity1, ...
                0.70);

            drones(2) = makeDrone( ...
                "Drone-2", ...
                "UNKNOWN_B", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [80 + 0.20*randn(N,1), ...
                 70 + 0.20*randn(N,1)], ...
                -50 + randn(1,N), ...
                0.57 + 0.04*randn(1,N), ...
                15 + randn(1,N), ...
                13 + randn(1,N), ...
                3e-3 + 5e-4*rand(1,N), ...
                activity2, ...
                0.68);

        case 10
            % ========================================================
            % SCENARIO 10: Multiple colluding Eves
            %
            % Their activity patterns are strongly correlated,
            % indicating possible cooperation.
            % ========================================================
            situation.description = "Multiple Colluding Eves";

            baseActivity = double(sin(0.15*t) > -0.2);

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "EVE_A", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [30 + 0.10*randn(N,1), ...
                 35 + 0.10*randn(N,1)], ...
                -42 + 2*baseActivity + randn(1,N), ...
                0.65 + 0.04*randn(1,N), ...
                19 + 2*baseActivity + randn(1,N), ...
                12 + randn(1,N), ...
                2e-3 + 5e-4*rand(1,N), ...
                baseActivity, ...
                0.76);

            drones(2) = makeDrone( ...
                "Drone-2", ...
                "EVE_B", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [75 + 0.10*randn(N,1), ...
                 65 + 0.10*randn(N,1)], ...
                -47 + 2*baseActivity + randn(1,N), ...
                0.62 + 0.04*randn(1,N), ...
                17 + 2*baseActivity + randn(1,N), ...
                14 + randn(1,N), ...
                2.5e-3 + 5e-4*rand(1,N), ...
                baseActivity, ...
                0.72);

        case 11
            % ========================================================
            % SCENARIO 11: Intermittent Eve
            %
            % Eve appears only during selected time intervals.
            % This helps test intermittent activity detection.
            % ========================================================
            situation.description = "Intermittent Eve";

            activity = zeros(1,N);
            activity(15:35) = 1;
            activity(70:95) = 1;

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "UNKNOWN_INTERMITTENT", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                [60 + 0.10*randn(N,1), ...
                 45 + 0.10*randn(N,1)], ...
                -85 + 35*activity + randn(1,N), ...
                0.70 + 0.04*randn(1,N), ...
                4 + 18*activity + randn(1,N), ...
                10 + randn(1,N), ...
                1e-2 + 1e-3*rand(1,N), ...
                activity, ...
                0.78);

        case 12
            % ========================================================
            % SCENARIO 12: Drone entering and leaving boundary
            %
            % The drone starts outside, enters the square, and exits.
            % This tests boundary presence percentage.
            % ========================================================
            situation.description = "Drone Entering and Leaving Boundary";

            pos = [
                linspace(-30,130,N)' + 0.60*randn(N,1), ...
                50 + 3*sin(0.12*t') + 0.40*randn(N,1)
            ];

            drones(1) = makeDrone( ...
                "Drone-1", ...
                "UNKNOWN_ENTRY_EXIT", ...
                false, ...
                false, ...
                true, ...
                true, ...
                true, ...
                true, ...
                false, ...
                pos, ...
                -52 + 4*sin(0.10*t) + randn(1,N), ...
                0.58 + 0.04*randn(1,N), ...
                15 + 2*sin(0.08*t) + randn(1,N), ...
                12 + randn(1,N), ...
                4e-3 + 1e-3*rand(1,N), ...
                ones(1,N), ...
                0.69);

        otherwise
            error('Invalid scenarioType selected.');
    end

    situation.drones = drones;
end



function drone = makeDrone(name, claimedID, registered, authPassed, ...
    txDetected, rxDetected, externalDetection, pilotMismatch, relayEvidence, ...
    position, rssi_dBm, csiMismatch, snr_dB, latency_ms, ber, ...
    activityPattern, rfFingerprintDistance)

    drone.name = string(name);
    drone.claimedID = string(claimedID);

    drone.registered = registered;
    drone.authPassed = authPassed;

    drone.txDetected = txDetected;
    drone.rxDetected = rxDetected;
    drone.externalDetection = externalDetection;

    drone.pilotMismatch = pilotMismatch;
    drone.relayEvidence = relayEvidence;

    drone.position = position;

    drone.rssi_dBm = rssi_dBm;
    drone.csiMismatch = csiMismatch;
    drone.snr_dB = snr_dB;
    drone.latency_ms = latency_ms;
    drone.ber = ber;

    drone.activityPattern = activityPattern;
    drone.rfFingerprintDistance = rfFingerprintDistance;
end


% ============================================================
% END OF PART 2
% Paste Part 3 directly below this line.
% ============================================================
% ============================================================
% PART 3 OF 4
% CORE DECISION LOGIC
%
% This part contains:
%
%   1. Integrated system controller
%   2. Stage-0 boundary and mobility classification
%   3. Stage-1 Eve situation category classification
%   4. Stage-2 detailed Eve identification
%   5. Risk-score and final-decision logic
%
% Paste this directly below Part 2.
% Do not run the file until Part 4 is also pasted,
% because plotting functions are added in Part 4.
% ============================================================


function [stage0Table, stage1Table, stage2Table, scoreTable, ...
    monitorTable, globalSummary] = runIntegratedEveSystem(situation, cfg)

    % ------------------------------------------------------------
    % Stage 0:
    % Boundary presence + mobility classification
    % ------------------------------------------------------------
    [stage0Table, monitorTable, stage0Summary] = ...
        runStage0BoundaryMobility(situation, cfg);

    % ------------------------------------------------------------
    % Stage 1:
    % Situation category classification
    % ------------------------------------------------------------
    [stage1Table, stage1Summary] = ...
        runStage1CategoryClassifier(situation, cfg, stage0Table);

    % ------------------------------------------------------------
    % Stage 2:
    % Detailed Eve identification
    % ------------------------------------------------------------
    [stage2Table, scoreTable, stage2Summary] = ...
        runStage2DetailedIdentifier(situation, cfg, stage0Table, stage1Table);

    % ------------------------------------------------------------
    % Global summary:
    % Final combined result from all stages
    % ------------------------------------------------------------
    globalSummary = createGlobalSummary( ...
        situation, stage0Summary, stage1Summary, stage2Summary);
end



function [stage0Table, monitorTable, stage0Summary] = ...
    runStage0BoundaryMobility(situation, cfg)

    drones = situation.drones;
    t = situation.t;

    numMonitors = size(cfg.monitorNodes,1);

    % ------------------------------------------------------------
    % No drone case
    % ------------------------------------------------------------
    if isempty(drones)

        stage0Table = table( ...
            "No detected drone", ...
            "No drone present inside boundary", ...
            "Not applicable", ...
            0, 0, 0, 0, 0, 0);

        stage0Table.Properties.VariableNames = { ...
            'Drone', ...
            'Boundary_Presence_Status', ...
            'Mobility_Category', ...
            'Presence_Percentage', ...
            'Mean_Speed_mps', ...
            'Max_Speed_mps', ...
            'Position_Std_m', ...
            'Net_Displacement_m', ...
            'Path_Length_m'};

        monitorTable = table( ...
            ["Monitor-1"; "Monitor-2"; "Monitor-3"; "Monitor-4"], ...
            cfg.monitorNodes(:,1), ...
            cfg.monitorNodes(:,2), ...
            zeros(numMonitors,1));

        monitorTable.Properties.VariableNames = { ...
            'Monitor_Node', ...
            'X_Position_m', ...
            'Y_Position_m', ...
            'Detection_Count'};

        stage0Summary = table( ...
            string(situation.description), ...
            false, ...
            0, ...
            "No drone is present inside the predefined square boundary.");

        stage0Summary.Properties.VariableNames = { ...
            'Scenario', ...
            'Any_Drone_Inside_Boundary', ...
            'Number_of_Drones_Inside', ...
            'Stage0_Statement'};

        return;
    end

    % ------------------------------------------------------------
    % Initialize variables
    % ------------------------------------------------------------
    numDrones = length(drones);

    droneName = strings(numDrones,1);
    boundaryStatus = strings(numDrones,1);
    mobilityCategory = strings(numDrones,1);

    presencePercentage = zeros(numDrones,1);
    meanSpeed = zeros(numDrones,1);
    maxSpeed = zeros(numDrones,1);
    positionStd = zeros(numDrones,1);
    netDisplacement = zeros(numDrones,1);
    pathLength = zeros(numDrones,1);

    monitorDetectionCount = zeros(numMonitors,1);
    droneInsideFlag = false(numDrones,1);

    % ------------------------------------------------------------
    % Analyze each drone
    % ------------------------------------------------------------
    for k = 1:numDrones

        currentDrone = drones(k);
        droneName(k) = currentDrone.name;

        pos = currentDrone.position;

        x = pos(:,1);
        y = pos(:,2);

        % --------------------------------------------------------
        % Boundary check:
        % A drone is geometrically inside if x and y are inside
        % the predefined square boundary.
        % --------------------------------------------------------
        insideSquare = x >= cfg.xMin & x <= cfg.xMax & ...
                       y >= cfg.yMin & y <= cfg.yMax;

        % --------------------------------------------------------
        % Monitoring-node detection:
        % A drone is considered detected if it lies within the
        % sensing range of at least one authorized monitoring node.
        % --------------------------------------------------------
        detectedByAnyMonitor = false(length(t),1);

        for m = 1:numMonitors

            monitorPosition = cfg.monitorNodes(m,:);

            distanceToMonitor = sqrt( ...
                (x - monitorPosition(1)).^2 + ...
                (y - monitorPosition(2)).^2 );

            detectedByThisMonitor = distanceToMonitor <= cfg.sensingRange;

            monitorDetectionCount(m) = monitorDetectionCount(m) + ...
                sum(detectedByThisMonitor & insideSquare);

            detectedByAnyMonitor = detectedByAnyMonitor | detectedByThisMonitor;
        end

        % --------------------------------------------------------
        % Final presence condition:
        % The drone must be inside the square and detected by at
        % least one monitoring node.
        % --------------------------------------------------------
        presentInsideBoundary = insideSquare & detectedByAnyMonitor;

        presencePercentage(k) = 100 * mean(presentInsideBoundary);

        if presencePercentage(k) == 0
            boundaryStatus(k) = "Not present inside boundary";
            mobilityCategory(k) = "Not applicable";
            droneInsideFlag(k) = false;
            continue;

        elseif presencePercentage(k) < 90
            boundaryStatus(k) = "Intermittently present inside boundary";
            droneInsideFlag(k) = true;

        else
            boundaryStatus(k) = "Present inside boundary";
            droneInsideFlag(k) = true;
        end

        % --------------------------------------------------------
        % Mobility calculation is done only for samples where the
        % drone is present inside the monitored square boundary.
        % --------------------------------------------------------
        validPosition = pos(presentInsideBoundary,:);
        validTime = t(presentInsideBoundary);

        if size(validPosition,1) < 3
            mobilityCategory(k) = "Insufficient samples";
            continue;
        end

        dx = diff(validPosition(:,1));
        dy = diff(validPosition(:,2));
        dt = diff(validTime(:));

        speed = sqrt(dx.^2 + dy.^2) ./ dt;

        meanSpeed(k) = mean(speed);
        maxSpeed(k) = max(speed);

        positionStd(k) = sqrt( ...
            std(validPosition(:,1))^2 + ...
            std(validPosition(:,2))^2 );

        netDisplacement(k) = norm(validPosition(end,:) - validPosition(1,:));

        pathLength(k) = sum(sqrt(dx.^2 + dy.^2));

        % --------------------------------------------------------
        % Mobility category decision
        % --------------------------------------------------------
        if meanSpeed(k) <= cfg.staticMeanSpeedMax && ...
           positionStd(k) <= cfg.staticPositionStdMax && ...
           netDisplacement(k) <= cfg.staticNetDispMax

            mobilityCategory(k) = "Static";

        elseif meanSpeed(k) <= cfg.hoverMeanSpeedMax && ...
               positionStd(k) <= cfg.hoverPositionStdMax && ...
               netDisplacement(k) <= cfg.hoverNetDispMax

            mobilityCategory(k) = "Hovering";

        else
            mobilityCategory(k) = "Dynamic";
        end
    end

    % ------------------------------------------------------------
    % Stage-0 output table
    % ------------------------------------------------------------
    stage0Table = table( ...
        droneName, ...
        boundaryStatus, ...
        mobilityCategory, ...
        presencePercentage, ...
        meanSpeed, ...
        maxSpeed, ...
        positionStd, ...
        netDisplacement, ...
        pathLength);

    stage0Table.Properties.VariableNames = { ...
        'Drone', ...
        'Boundary_Presence_Status', ...
        'Mobility_Category', ...
        'Presence_Percentage', ...
        'Mean_Speed_mps', ...
        'Max_Speed_mps', ...
        'Position_Std_m', ...
        'Net_Displacement_m', ...
        'Path_Length_m'};

    % ------------------------------------------------------------
    % Monitor-node detection table
    % ------------------------------------------------------------
    monitorTable = table( ...
        ["Monitor-1"; "Monitor-2"; "Monitor-3"; "Monitor-4"], ...
        cfg.monitorNodes(:,1), ...
        cfg.monitorNodes(:,2), ...
        monitorDetectionCount);

    monitorTable.Properties.VariableNames = { ...
        'Monitor_Node', ...
        'X_Position_m', ...
        'Y_Position_m', ...
        'Detection_Count'};

    % ------------------------------------------------------------
    % Stage-0 summary
    % ------------------------------------------------------------
    anyDroneInside = any(droneInsideFlag);
    numberInside = sum(droneInsideFlag);

    if anyDroneInside == false
        statement = "No drone is present inside the predefined square boundary.";
    elseif numberInside == 1
        statement = "One drone is present inside the predefined square boundary.";
    else
        statement = "Multiple drones are present inside the predefined square boundary.";
    end

    stage0Summary = table( ...
        string(situation.description), ...
        anyDroneInside, ...
        numberInside, ...
        string(statement));

    stage0Summary.Properties.VariableNames = { ...
        'Scenario', ...
        'Any_Drone_Inside_Boundary', ...
        'Number_of_Drones_Inside', ...
        'Stage0_Statement'};
end



function [stage1Table, stage1Summary] = ...
    runStage1CategoryClassifier(situation, cfg, stage0Table)

    drones = situation.drones;
    t = situation.t;

    % ------------------------------------------------------------
    % No drone case
    % ------------------------------------------------------------
    if isempty(drones)

        stage1Table = table( ...
            "No detected drone", ...
            "Not applicable", ...
            "Not applicable", ...
            "Not applicable", ...
            "Not applicable", ...
            "Not applicable", ...
            "No situation category", ...
            NaN, NaN, NaN, 0, 0, ...
            "No Eve classification required");

        stage1Table.Properties.VariableNames = { ...
            'Drone', ...
            'Mobility_Category', ...
            'Activity_Category', ...
            'Identity_Category', ...
            'Number_Category', ...
            'Special_Case', ...
            'Final_Situation_Category', ...
            'Mean_RSSI_dBm', ...
            'Mean_CSI_Mismatch', ...
            'Mean_Latency_ms', ...
            'Activity_Duty_Cycle', ...
            'Stage1_Risk_Score', ...
            'Next_Recommended_Stage'};

        stage1Summary = table( ...
            string(situation.description), ...
            false, ...
            0, ...
            "Not Applicable", ...
            0, ...
            "No drone present. Stage-1 classification is not required.");

        stage1Summary.Properties.VariableNames = { ...
            'Scenario', ...
            'Any_Drone_Inside_Boundary', ...
            'Number_of_Drones_Inside', ...
            'Collusion_Status', ...
            'Maximum_Stage1_Risk_Score', ...
            'Stage1_Statement'};

        return;
    end

    % ------------------------------------------------------------
    % Initialize variables
    % ------------------------------------------------------------
    numDrones = length(drones);
    insideFlags = stage0Table.Presence_Percentage > 0;
    numInside = sum(insideFlags);

    droneName = strings(numDrones,1);
    mobilityCategory = strings(numDrones,1);
    activityCategory = strings(numDrones,1);
    identityCategory = strings(numDrones,1);
    numberCategory = strings(numDrones,1);
    specialCase = strings(numDrones,1);
    finalSituationCategory = strings(numDrones,1);
    nextStage = strings(numDrones,1);

    meanRSSI = nan(numDrones,1);
    meanCSI = nan(numDrones,1);
    meanLatency = nan(numDrones,1);
    dutyCycle = zeros(numDrones,1);
    stage1RiskScore = zeros(numDrones,1);

    % ------------------------------------------------------------
    % Global jamming condition from Bob's link quality
    % ------------------------------------------------------------
    meanBobSNR = mean(situation.link.snrBob_dB);
    meanBobBER = mean(situation.link.berBob);
    meanInterference = mean(situation.link.interference_dBm);

    jammingCondition = ...
        meanInterference > cfg.interferenceHighTh || ...
        meanBobSNR < cfg.snrBobLowTh || ...
        meanBobBER > cfg.berHighTh;

    % ------------------------------------------------------------
    % Collusion analysis:
    % If more than one drone is inside the boundary, compare their
    % activity patterns. Highly correlated activity may indicate
    % collusion.
    % ------------------------------------------------------------
    collusionStatus = "Not Applicable";
    collusionDetected = false;

    if numInside > 1

        insideIndex = find(insideFlags);
        activityMatrix = zeros(length(insideIndex), length(t));

        for q = 1:length(insideIndex)
            activityMatrix(q,:) = drones(insideIndex(q)).activityPattern;
        end

        corrMatrix = corrcoef(activityMatrix');
        upperValues = corrMatrix(triu(true(size(corrMatrix)),1));
        upperValues = upperValues(~isnan(upperValues));

        if ~isempty(upperValues) && any(upperValues > cfg.collusionCorrTh)
            collusionDetected = true;
            collusionStatus = "Possible Colluding Eves";
        else
            collusionStatus = "Multiple Independent Drones";
        end
    end

    % ------------------------------------------------------------
    % Classify each drone
    % ------------------------------------------------------------
    for k = 1:numDrones

        currentDrone = drones(k);

        droneName(k) = currentDrone.name;
        mobilityCategory(k) = stage0Table.Mobility_Category(k);

        if stage0Table.Presence_Percentage(k) == 0

            activityCategory(k) = "Outside Boundary / Not Considered";
            identityCategory(k) = "Not Considered";
            numberCategory(k) = "Outside Boundary";
            specialCase(k) = "Not Applicable";
            finalSituationCategory(k) = "Drone outside monitoring boundary";
            nextStage(k) = "No Eve identification needed unless drone enters boundary";
            stage1RiskScore(k) = 0;
            continue;
        end

        % --------------------------------------------------------
        % Activity category
        % --------------------------------------------------------
        if currentDrone.txDetected == false && currentDrone.rxDetected == true

            activityCategory(k) = "Passive / Listening Drone";

        elseif currentDrone.txDetected == true && ...
               currentDrone.rxDetected == true && ...
               jammingCondition == true

            activityCategory(k) = "Transmitting-Receiving + Possible Jamming";

        elseif currentDrone.txDetected == true && jammingCondition == true

            activityCategory(k) = "Jamming Eve";

        elseif currentDrone.txDetected == true && currentDrone.rxDetected == true

            activityCategory(k) = "Transmitting and Receiving Drone";

        elseif currentDrone.txDetected == true

            activityCategory(k) = "Active Transmitting Drone";

        else
            activityCategory(k) = "Silent / Not Directly Observable";
        end

        % --------------------------------------------------------
        % Identity category
        % --------------------------------------------------------
        if currentDrone.claimedID == cfg.expectedBobID && ...
           currentDrone.registered == true && ...
           currentDrone.authPassed == true

            identityCategory(k) = "Likely Authorized Bob";

        elseif currentDrone.claimedID == cfg.expectedBobID && ...
               currentDrone.registered == false

            identityCategory(k) = "Eve Acting as Bob";

        elseif currentDrone.registered == true && ...
               currentDrone.authPassed == false

            identityCategory(k) = "Possible Compromised Bob";

        elseif currentDrone.relayEvidence == true || ...
               mean(currentDrone.latency_ms,'omitnan') > cfg.latencyRelayTh

            identityCategory(k) = "Possible Relay Eve";

        elseif currentDrone.registered == false

            identityCategory(k) = "Unknown / Unauthorized Drone";

        else
            identityCategory(k) = "Identity Uncertain";
        end

        % --------------------------------------------------------
        % Number category
        % --------------------------------------------------------
        if numInside == 1
            numberCategory(k) = "Single Drone Situation";
        else
            numberCategory(k) = collusionStatus;
        end

        % --------------------------------------------------------
        % Special case
        % --------------------------------------------------------
        dutyCycle(k) = mean(currentDrone.activityPattern);

        if numInside == 1
            specialCase(k) = "Only One Drone Present";

        elseif dutyCycle(k) > cfg.intermittentDutyMin && ...
               dutyCycle(k) < cfg.intermittentDutyMax

            specialCase(k) = "Intermittent Eve";

        else
            specialCase(k) = "No Special Case";
        end

        % --------------------------------------------------------
        % Measurements for Stage-1
        % --------------------------------------------------------
        meanRSSI(k) = mean(currentDrone.rssi_dBm, 'omitnan');
        meanCSI(k) = mean(currentDrone.csiMismatch, 'omitnan');
        meanLatency(k) = mean(currentDrone.latency_ms, 'omitnan');

        % --------------------------------------------------------
        % Stage-1 risk score
        % This is not the final Eve score. It only measures how
        % suspicious the situation category is.
        % --------------------------------------------------------
        score = 0;

        if currentDrone.registered == false
            score = score + 20;
        end

        if currentDrone.claimedID == cfg.expectedBobID && ...
           currentDrone.registered == false
            score = score + 25;
        end

        if currentDrone.authPassed == false
            score = score + 15;
        end

        if currentDrone.pilotMismatch == true
            score = score + 10;
        end

        if meanCSI(k) > cfg.csiMismatchTh
            score = score + 10;
        end

        if contains(activityCategory(k), "Passive")
            score = score + 10;
        end

        if contains(activityCategory(k), "Jamming")
            score = score + 25;
        end

        if contains(numberCategory(k), "Colluding")
            score = score + 20;
        elseif contains(numberCategory(k), "Multiple")
            score = score + 10;
        end

        if contains(specialCase(k), "Intermittent")
            score = score + 10;
        end

        stage1RiskScore(k) = min(score, 100);

        % --------------------------------------------------------
        % Final situation category
        % --------------------------------------------------------
        finalSituationCategory(k) = ...
            mobilityCategory(k) + " + " + ...
            activityCategory(k) + " + " + ...
            identityCategory(k);

        % --------------------------------------------------------
        % Next recommended stage
        % --------------------------------------------------------
        if mobilityCategory(k) == "Static"
            nextStage(k) = "Static Eve detailed check: RSSI + CSI + location + secrecy capacity";

        elseif mobilityCategory(k) == "Hovering"
            nextStage(k) = "Hovering Eve detailed check: micro-movement + CSI variation + authentication";

        elseif mobilityCategory(k) == "Dynamic"
            nextStage(k) = "Dynamic Eve detailed check: trajectory + Doppler + time-varying CSI";

        else
            nextStage(k) = "Continue monitoring";
        end
    end

    % ------------------------------------------------------------
    % Stage-1 output table
    % ------------------------------------------------------------
    stage1Table = table( ...
        droneName, ...
        mobilityCategory, ...
        activityCategory, ...
        identityCategory, ...
        numberCategory, ...
        specialCase, ...
        finalSituationCategory, ...
        meanRSSI, ...
        meanCSI, ...
        meanLatency, ...
        dutyCycle, ...
        stage1RiskScore, ...
        nextStage);

    stage1Table.Properties.VariableNames = { ...
        'Drone', ...
        'Mobility_Category', ...
        'Activity_Category', ...
        'Identity_Category', ...
        'Number_Category', ...
        'Special_Case', ...
        'Final_Situation_Category', ...
        'Mean_RSSI_dBm', ...
        'Mean_CSI_Mismatch', ...
        'Mean_Latency_ms', ...
        'Activity_Duty_Cycle', ...
        'Stage1_Risk_Score', ...
        'Next_Recommended_Stage'};

    % ------------------------------------------------------------
    % Stage-1 summary
    % ------------------------------------------------------------
    maxStage1Risk = max(stage1RiskScore);

    if numInside == 0
        statement = "No drone is present inside the boundary.";
    elseif maxStage1Risk >= 75
        statement = "High-risk Eve situation category detected.";
    elseif maxStage1Risk >= 45
        statement = "Suspicious Eve situation category detected.";
    elseif maxStage1Risk >= 20
        statement = "Drone requires verification before being accepted.";
    else
        statement = "No strong Eve category detected at Stage-1.";
    end

    stage1Summary = table( ...
        string(situation.description), ...
        any(insideFlags), ...
        numInside, ...
        string(collusionStatus), ...
        maxStage1Risk, ...
        string(statement));

    stage1Summary.Properties.VariableNames = { ...
        'Scenario', ...
        'Any_Drone_Inside_Boundary', ...
        'Number_of_Drones_Inside', ...
        'Collusion_Status', ...
        'Maximum_Stage1_Risk_Score', ...
        'Stage1_Statement'};
end



function [stage2Table, scoreTable, stage2Summary] = ...
    runStage2DetailedIdentifier(situation, cfg, stage0Table, stage1Table)

    drones = situation.drones;
    t = situation.t;

    % ------------------------------------------------------------
    % No drone case
    % ------------------------------------------------------------
    if isempty(drones)

        stage2Table = table( ...
            "No detected drone", ...
            "No drone inside boundary", ...
            "Not applicable", ...
            "Not applicable", ...
            "Not applicable", ...
            "Not applicable", ...
            false, false, ...
            NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
            "Not applicable", ...
            "Not applicable", ...
            "Not applicable", ...
            0, ...
            "No Eve Identification Required", ...
            "Continue boundary monitoring");

        stage2Table.Properties.VariableNames = { ...
            'Drone', ...
            'Boundary_Status', ...
            'Mobility_Category', ...
            'Activity_Category', ...
            'Identity_Status', ...
            'Claimed_ID', ...
            'Registered', ...
            'Authentication_Passed', ...
            'Mean_RSSI_dBm', ...
            'RSSI_Mismatch_dB', ...
            'Mean_CSI_Mismatch', ...
            'Location_Error_m', ...
            'RF_Fingerprint_Distance', ...
            'Mean_Node_SNR_dB', ...
            'Mean_Node_BER', ...
            'Mean_Secrecy_Capacity', ...
            'Secrecy_Status', ...
            'Jamming_Status', ...
            'Collusion_Status', ...
            'Risk_Score', ...
            'Final_Identification', ...
            'Recommended_Action'};

        scoreTable = table( ...
            "No detected drone", ...
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

        scoreTable.Properties.VariableNames = { ...
            'Drone', ...
            'Identity_Score', ...
            'Authentication_Score', ...
            'RSSI_Score', ...
            'CSI_Score', ...
            'Location_Score', ...
            'RF_Fingerprint_Score', ...
            'Secrecy_Score', ...
            'Activity_Score', ...
            'Jamming_Score', ...
            'Relay_Score', ...
            'Collusion_Score', ...
            'Total_Risk_Score'};

        stage2Summary = table( ...
            string(situation.description), ...
            false, ...
            0, ...
            0, ...
            "No drone present. Detailed Eve identification is not required.");

        stage2Summary.Properties.VariableNames = { ...
            'Scenario', ...
            'Any_Drone_Inside_Boundary', ...
            'Number_of_Drones_Inside', ...
            'Maximum_Stage2_Risk_Score', ...
            'Stage2_Statement'};

        return;
    end

    % ------------------------------------------------------------
    % Initialize variables
    % ------------------------------------------------------------
    numDrones = length(drones);
    insideFlags = stage0Table.Presence_Percentage > 0;
    numInside = sum(insideFlags);

    droneName = strings(numDrones,1);
    boundaryStatus = strings(numDrones,1);
    mobilityCategory = strings(numDrones,1);
    activityCategory = strings(numDrones,1);
    identityStatus = strings(numDrones,1);
    claimedID = strings(numDrones,1);
    registered = false(numDrones,1);
    authPassed = false(numDrones,1);

    meanRSSI = nan(numDrones,1);
    rssiMismatch = nan(numDrones,1);
    meanCSI = nan(numDrones,1);
    locationError = nan(numDrones,1);
    rfDistance = nan(numDrones,1);
    meanNodeSNR = nan(numDrones,1);
    meanNodeBER = nan(numDrones,1);
    meanSecrecyCapacity = nan(numDrones,1);

    secrecyStatus = strings(numDrones,1);
    jammingStatus = strings(numDrones,1);
    collusionColumn = strings(numDrones,1);
    finalIdentification = strings(numDrones,1);
    recommendedAction = strings(numDrones,1);

    identityScore = zeros(numDrones,1);
    authenticationScore = zeros(numDrones,1);
    rssiScore = zeros(numDrones,1);
    csiScore = zeros(numDrones,1);
    locationScore = zeros(numDrones,1);
    rfFingerprintScore = zeros(numDrones,1);
    secrecyScore = zeros(numDrones,1);
    activityScore = zeros(numDrones,1);
    jammingScore = zeros(numDrones,1);
    relayScore = zeros(numDrones,1);
    collusionScore = zeros(numDrones,1);
    totalRiskScore = zeros(numDrones,1);

    % ------------------------------------------------------------
    % Bob channel capacity
    % ------------------------------------------------------------
    snrBobLinear = 10.^(situation.link.snrBob_dB/10);
    CB = log2(1 + snrBobLinear);

    % ------------------------------------------------------------
    % Jamming condition based on Bob link degradation
    % ------------------------------------------------------------
    meanBobSNR = mean(situation.link.snrBob_dB);
    meanBobBER = mean(situation.link.berBob);
    meanInterference = mean(situation.link.interference_dBm);

    globalJammingCondition = ...
        meanInterference > cfg.interferenceHighTh || ...
        meanBobSNR < cfg.snrBobLowTh || ...
        meanBobBER > cfg.berHighTh;

    % ------------------------------------------------------------
    % Collusion analysis
    % ------------------------------------------------------------
    collusionDetected = false;
    collusionStatus = "Not Applicable";

    if numInside > 1

        insideIndex = find(insideFlags);
        activityMatrix = zeros(length(insideIndex), length(t));

        for q = 1:length(insideIndex)
            activityMatrix(q,:) = drones(insideIndex(q)).activityPattern;
        end

        corrMatrix = corrcoef(activityMatrix');
        upperValues = corrMatrix(triu(true(size(corrMatrix)),1));
        upperValues = upperValues(~isnan(upperValues));

        if ~isempty(upperValues) && any(upperValues > cfg.collusionCorrTh)
            collusionDetected = true;
            collusionStatus = "Possible Colluding Eves";
        else
            collusionStatus = "Multiple Independent Drones";
        end
    end

    % ------------------------------------------------------------
    % Detailed identification for each drone
    % ------------------------------------------------------------
    for k = 1:numDrones

        currentDrone = drones(k);

        droneName(k) = currentDrone.name;
        boundaryStatus(k) = stage0Table.Boundary_Presence_Status(k);
        mobilityCategory(k) = stage0Table.Mobility_Category(k);
        activityCategory(k) = stage1Table.Activity_Category(k);
        claimedID(k) = currentDrone.claimedID;
        registered(k) = currentDrone.registered;
        authPassed(k) = currentDrone.authPassed;
        collusionColumn(k) = collusionStatus;

        % --------------------------------------------------------
        % If drone is outside boundary, do not perform detailed Eve
        % identification. It is only monitored.
        % --------------------------------------------------------
        if stage0Table.Presence_Percentage(k) == 0

            identityStatus(k) = "Not considered";
            secrecyStatus(k) = "Not considered";
            jammingStatus(k) = "Not considered";
            finalIdentification(k) = "Outside Boundary";
            recommendedAction(k) = "Continue monitoring until drone enters boundary";

            continue;
        end

        % --------------------------------------------------------
        % Identity analysis
        % --------------------------------------------------------
        if currentDrone.claimedID == cfg.expectedBobID && ...
           currentDrone.registered == true && ...
           currentDrone.authPassed == true

            identityStatus(k) = "Verified Authorized Bob Candidate";

        elseif currentDrone.claimedID == cfg.expectedBobID && ...
               currentDrone.registered == false

            identityStatus(k) = "Fake Bob Identity / Eve Acting as Bob";
            identityScore(k) = 25;

        elseif currentDrone.registered == true && ...
               currentDrone.authPassed == false

            identityStatus(k) = "Possible Compromised Bob";
            identityScore(k) = 20;

        elseif currentDrone.relayEvidence == true || ...
               mean(currentDrone.latency_ms,'omitnan') > cfg.latencyRelayTh

            identityStatus(k) = "Possible Relay Eve";
            identityScore(k) = 20;

        elseif currentDrone.registered == false

            identityStatus(k) = "Unknown / Unauthorized Drone";
            identityScore(k) = 20;

        else
            identityStatus(k) = "Identity Uncertain";
            identityScore(k) = 10;
        end

        % --------------------------------------------------------
        % Authentication and pilot verification
        % --------------------------------------------------------
        if currentDrone.authPassed == false
            authenticationScore(k) = authenticationScore(k) + 20;
        end

        if currentDrone.pilotMismatch == true
            authenticationScore(k) = authenticationScore(k) + 10;
        end

        % --------------------------------------------------------
        % RSSI mismatch
        % --------------------------------------------------------
        if all(isnan(currentDrone.rssi_dBm))

            meanRSSI(k) = NaN;
            rssiMismatch(k) = NaN;

        else
            meanRSSI(k) = mean(currentDrone.rssi_dBm, 'omitnan');
            rssiMismatch(k) = abs(meanRSSI(k) - cfg.expectedBobRSSI_dBm);

            if rssiMismatch(k) > cfg.rssiMismatchTh
                rssiScore(k) = 10;
            end
        end

        % --------------------------------------------------------
        % CSI mismatch
        % --------------------------------------------------------
        if all(isnan(currentDrone.csiMismatch))

            meanCSI(k) = NaN;

        else
            meanCSI(k) = mean(currentDrone.csiMismatch, 'omitnan');

            if meanCSI(k) > cfg.csiMismatchTh
                csiScore(k) = 15;
            end
        end

        % --------------------------------------------------------
        % Location verification
        % --------------------------------------------------------
        meanPosition = mean(currentDrone.position,1);
        locationError(k) = norm(meanPosition - cfg.expectedBobPosition);

        if locationError(k) > cfg.locationErrorTh
            locationScore(k) = 15;
        end

        % --------------------------------------------------------
        % RF fingerprint verification
        % --------------------------------------------------------
        rfDistance(k) = currentDrone.rfFingerprintDistance;

        if rfDistance(k) > cfg.rfFingerprintTh
            rfFingerprintScore(k) = 15;
        end

        % --------------------------------------------------------
        % Node SNR and BER
        % --------------------------------------------------------
        meanNodeSNR(k) = mean(currentDrone.snr_dB, 'omitnan');
        meanNodeBER(k) = mean(currentDrone.ber, 'omitnan');

        % --------------------------------------------------------
        % Jamming evidence
        % --------------------------------------------------------
        if globalJammingCondition == true
            jammingStatus(k) = "Jamming / Bob link degradation observed";
            jammingScore(k) = 20;
        else
            jammingStatus(k) = "No strong jamming evidence";
        end

        % --------------------------------------------------------
        % Relay evidence
        % --------------------------------------------------------
        if currentDrone.relayEvidence == true || ...
           mean(currentDrone.latency_ms,'omitnan') > cfg.latencyRelayTh

            relayScore(k) = 15;
        end

        % --------------------------------------------------------
        % Secrecy capacity observation
        %
        % CB = capacity of Bob channel
        % CE = estimated capacity of suspicious node channel
        % CS = [CB - CE]^+
        % --------------------------------------------------------
        snrNodeLinear = 10.^(currentDrone.snr_dB/10);
        CE = log2(1 + snrNodeLinear);

        CS = max(CB - CE, 0);

        meanSecrecyCapacity(k) = mean(CS, 'omitnan');

        if meanSecrecyCapacity(k) < cfg.secrecyRateRequired
            secrecyStatus(k) = "Secrecy Outage / Unsafe";
            secrecyScore(k) = 20;
        else
            secrecyStatus(k) = "Secrecy Acceptable";
        end

        % --------------------------------------------------------
        % Activity score
        % --------------------------------------------------------
        if contains(activityCategory(k), "Passive")
            activityScore(k) = activityScore(k) + 10;
        end

        if contains(activityCategory(k), "Transmitting")
            activityScore(k) = activityScore(k) + 10;
        end

        if contains(activityCategory(k), "Jamming")
            activityScore(k) = activityScore(k) + 15;
        end

        dutyCycle = mean(currentDrone.activityPattern);

        if dutyCycle > cfg.intermittentDutyMin && ...
           dutyCycle < cfg.intermittentDutyMax

            activityScore(k) = activityScore(k) + 10;
        end

        % --------------------------------------------------------
        % Collusion score
        % --------------------------------------------------------
        if collusionDetected == true
            collusionScore(k) = 15;
        end

        % --------------------------------------------------------
        % Mobility consistency check
        % If a node claims to be Bob but its movement does not match
        % the expected Bob mobility, add extra suspicion.
        % --------------------------------------------------------
        if currentDrone.claimedID == cfg.expectedBobID && ...
           mobilityCategory(k) ~= cfg.expectedBobMobility

            identityScore(k) = identityScore(k) + 10;
        end

        % --------------------------------------------------------
        % Final detailed risk score
        % --------------------------------------------------------
        totalRiskScore(k) = ...
            identityScore(k) + ...
            authenticationScore(k) + ...
            rssiScore(k) + ...
            csiScore(k) + ...
            locationScore(k) + ...
            rfFingerprintScore(k) + ...
            secrecyScore(k) + ...
            activityScore(k) + ...
            jammingScore(k) + ...
            relayScore(k) + ...
            collusionScore(k);

        totalRiskScore(k) = min(totalRiskScore(k), 100);

        % --------------------------------------------------------
        % Verified Bob condition
        % A drone is accepted as Bob only when the logical identity
        % and physical-layer evidence both match.
        % --------------------------------------------------------
        verifiedBobCondition = ...
            currentDrone.claimedID == cfg.expectedBobID && ...
            currentDrone.registered == true && ...
            currentDrone.authPassed == true && ...
            rssiScore(k) == 0 && ...
            csiScore(k) == 0 && ...
            locationScore(k) == 0 && ...
            rfFingerprintScore(k) == 0 && ...
            secrecyScore(k) == 0 && ...
            jammingScore(k) == 0;

        % --------------------------------------------------------
        % Final identification decision
        % --------------------------------------------------------
        if verifiedBobCondition

            finalIdentification(k) = "Verified Authorized Bob";
            recommendedAction(k) = "Allow communication and continue monitoring";

        elseif totalRiskScore(k) >= cfg.highRiskEveScore

            finalIdentification(k) = "High-Risk Eve Identified";
            recommendedAction(k) = "Block access, stop confidential transmission, alert monitoring system";

        elseif totalRiskScore(k) >= cfg.likelyEveScore

            finalIdentification(k) = "Likely Eve";
            recommendedAction(k) = "Do not trust node; perform strict re-authentication";

        elseif totalRiskScore(k) >= cfg.suspiciousScore

            finalIdentification(k) = "Suspicious Drone";
            recommendedAction(k) = "Continue tracking and apply detailed authentication";

        elseif totalRiskScore(k) >= cfg.needsVerificationScore

            finalIdentification(k) = "Needs Verification";
            recommendedAction(k) = "Request identity, RF fingerprint, and channel verification";

        else
            finalIdentification(k) = "Low-Risk Drone";
            recommendedAction(k) = "Monitor normally";
        end
    end

    % ------------------------------------------------------------
    % Stage-2 output table
    % ------------------------------------------------------------
    stage2Table = table( ...
        droneName, ...
        boundaryStatus, ...
        mobilityCategory, ...
        activityCategory, ...
        identityStatus, ...
        claimedID, ...
        registered, ...
        authPassed, ...
        meanRSSI, ...
        rssiMismatch, ...
        meanCSI, ...
        locationError, ...
        rfDistance, ...
        meanNodeSNR, ...
        meanNodeBER, ...
        meanSecrecyCapacity, ...
        secrecyStatus, ...
        jammingStatus, ...
        collusionColumn, ...
        totalRiskScore, ...
        finalIdentification, ...
        recommendedAction);

    stage2Table.Properties.VariableNames = { ...
        'Drone', ...
        'Boundary_Status', ...
        'Mobility_Category', ...
        'Activity_Category', ...
        'Identity_Status', ...
        'Claimed_ID', ...
        'Registered', ...
        'Authentication_Passed', ...
        'Mean_RSSI_dBm', ...
        'RSSI_Mismatch_dB', ...
        'Mean_CSI_Mismatch', ...
        'Location_Error_m', ...
        'RF_Fingerprint_Distance', ...
        'Mean_Node_SNR_dB', ...
        'Mean_Node_BER', ...
        'Mean_Secrecy_Capacity', ...
        'Secrecy_Status', ...
        'Jamming_Status', ...
        'Collusion_Status', ...
        'Risk_Score', ...
        'Final_Identification', ...
        'Recommended_Action'};

    % ------------------------------------------------------------
    % Score breakdown table
    % ------------------------------------------------------------
    scoreTable = table( ...
        droneName, ...
        identityScore, ...
        authenticationScore, ...
        rssiScore, ...
        csiScore, ...
        locationScore, ...
        rfFingerprintScore, ...
        secrecyScore, ...
        activityScore, ...
        jammingScore, ...
        relayScore, ...
        collusionScore, ...
        totalRiskScore);

    scoreTable.Properties.VariableNames = { ...
        'Drone', ...
        'Identity_Score', ...
        'Authentication_Score', ...
        'RSSI_Score', ...
        'CSI_Score', ...
        'Location_Score', ...
        'RF_Fingerprint_Score', ...
        'Secrecy_Score', ...
        'Activity_Score', ...
        'Jamming_Score', ...
        'Relay_Score', ...
        'Collusion_Score', ...
        'Total_Risk_Score'};

    % ------------------------------------------------------------
    % Stage-2 summary
    % ------------------------------------------------------------
    anyDroneInside = any(insideFlags);
    maxStage2Risk = max(totalRiskScore);

    if anyDroneInside == false
        statement = "No drone is inside the boundary.";
    elseif maxStage2Risk >= cfg.highRiskEveScore
        statement = "High-risk Eve is identified inside the protected boundary.";
    elseif maxStage2Risk >= cfg.likelyEveScore
        statement = "Likely Eve detected. Communication should not be trusted.";
    elseif maxStage2Risk >= cfg.suspiciousScore
        statement = "Suspicious drone detected. Further verification is required.";
    elseif maxStage2Risk >= cfg.needsVerificationScore
        statement = "Drone is present but requires verification.";
    else
        statement = "No strong Eve behavior detected.";
    end

    stage2Summary = table( ...
        string(situation.description), ...
        anyDroneInside, ...
        numInside, ...
        maxStage2Risk, ...
        string(statement));

    stage2Summary.Properties.VariableNames = { ...
        'Scenario', ...
        'Any_Drone_Inside_Boundary', ...
        'Number_of_Drones_Inside', ...
        'Maximum_Stage2_Risk_Score', ...
        'Stage2_Statement'};
end



function globalSummary = createGlobalSummary( ...
    situation, stage0Summary, stage1Summary, stage2Summary)

    % ------------------------------------------------------------
    % The global summary is the final high-level statement of the
    % complete integrated system.
    % ------------------------------------------------------------

    scenario = string(situation.description);

    anyDroneInside = stage0Summary.Any_Drone_Inside_Boundary;
    numberInside = stage0Summary.Number_of_Drones_Inside;

    maxStage1Risk = stage1Summary.Maximum_Stage1_Risk_Score;
    maxStage2Risk = stage2Summary.Maximum_Stage2_Risk_Score;

    if anyDroneInside == false

        finalDecision = "No drone inside boundary";
        finalStatement = "The protected square boundary is clear. Continue monitoring.";

    elseif maxStage2Risk >= 80

        finalDecision = "High-Risk Eve Identified";
        finalStatement = "An unauthorized high-risk Eve is identified. Communication should be blocked and the monitoring system should be alerted.";

    elseif maxStage2Risk >= 65

        finalDecision = "Likely Eve";
        finalStatement = "The detected drone has strong Eve-like behavior. It should not be trusted without strict re-authentication.";

    elseif maxStage2Risk >= 40

        finalDecision = "Suspicious Drone";
        finalStatement = "The detected drone is suspicious and requires detailed authentication, tracking, and channel verification.";

    elseif maxStage2Risk >= 20

        finalDecision = "Needs Verification";
        finalStatement = "The drone is inside the boundary but must be verified before being treated as Bob.";

    else

        finalDecision = "Low-Risk / Likely Authorized";
        finalStatement = "No strong Eve behavior is detected under the current threshold settings.";
    end

    globalSummary = table( ...
        scenario, ...
        anyDroneInside, ...
        numberInside, ...
        maxStage1Risk, ...
        maxStage2Risk, ...
        string(finalDecision), ...
        string(finalStatement));

    globalSummary.Properties.VariableNames = { ...
        'Scenario', ...
        'Any_Drone_Inside_Boundary', ...
        'Number_of_Drones_Inside', ...
        'Maximum_Stage1_Risk_Score', ...
        'Maximum_Stage2_Risk_Score', ...
        'Final_Decision', ...
        'Final_Statement'};
end


% ============================================================
% END OF PART 3
% Paste Part 4 directly below this line.
% ============================================================
% ============================================================
% PART 4 OF 4
% FINAL VISUALIZATION FUNCTIONS
%
% This part contains all figures for the integrated Eve
% identification system.
%
% Figures included:
%   Figure 1: Square boundary, monitoring nodes, Bob, and drone paths
%   Figure 2: Boundary presence with time
%   Figure 3: Speed profile and mobility threshold
%   Figure 4: Stage-1 risk score
%   Figure 5: Stage-2 final risk score
%   Figure 6: Detailed score breakdown
%   Figure 7: RSSI observation
%   Figure 8: CSI mismatch observation
%   Figure 9: Secrecy capacity observation
%   Figure 10: Bob link quality and interference observation
%
% Paste this directly below Part 3.
% After pasting this part, run the full file.
% ============================================================


function plotIntegratedEveResults(situation, cfg, ...
    stage0Table, stage1Table, stage2Table, scoreTable, monitorTable)

    drones = situation.drones;
    t = situation.t;

    % ------------------------------------------------------------
    % FIGURE 1: Square boundary, monitoring nodes, and drone paths
    % ------------------------------------------------------------
    figure('Name','Figure 1 - Protected Boundary and Drone Observation', ...
           'Color','w');

    hold on;
    grid on;
    box on;

    squareX = [cfg.xMin cfg.xMax cfg.xMax cfg.xMin cfg.xMin];
    squareY = [cfg.yMin cfg.yMin cfg.yMax cfg.yMax cfg.yMin];

    hBoundary = plot(squareX, squareY, 'k-', 'LineWidth', 2.8);

    hMonitor = plot(cfg.monitorNodes(:,1), cfg.monitorNodes(:,2), ...
        'ks', 'MarkerSize', 11, 'MarkerFaceColor','k');

    for m = 1:size(cfg.monitorNodes,1)
        text(cfg.monitorNodes(m,1)+2, cfg.monitorNodes(m,2)+2, ...
            ['Monitor-', num2str(m)], ...
            'FontSize', 10, ...
            'FontWeight','bold');
    end

    theta = linspace(0,2*pi,300);
    hRange = gobjects(size(cfg.monitorNodes,1),1);

    for m = 1:size(cfg.monitorNodes,1)

        cx = cfg.monitorNodes(m,1);
        cy = cfg.monitorNodes(m,2);

        rangeX = cx + cfg.sensingRange*cos(theta);
        rangeY = cy + cfg.sensingRange*sin(theta);

        hRange(m) = plot(rangeX, rangeY, '--', 'LineWidth', 1.1);
    end

    hBob = plot(cfg.expectedBobPosition(1), cfg.expectedBobPosition(2), ...
        'bp', 'MarkerSize', 15, 'MarkerFaceColor','b');

    text(cfg.expectedBobPosition(1)+2, cfg.expectedBobPosition(2)+2, ...
        'Expected Bob', ...
        'FontSize', 10, ...
        'FontWeight','bold');

    legendHandles = [hBoundary; hMonitor; hRange(1); hBob];
    legendLabels = {'Protected Square Boundary', ...
                    'Authorized Monitoring Nodes', ...
                    'Monitoring Range', ...
                    'Expected Bob Position'};

    if ~isempty(drones)

        for k = 1:length(drones)

            pos = drones(k).position;

            hPath = plot(pos(:,1), pos(:,2), 'LineWidth', 2.2);

            hStart = plot(pos(1,1), pos(1,2), ...
                'go', 'MarkerSize', 8, 'MarkerFaceColor','g');

            hEnd = plot(pos(end,1), pos(end,2), ...
                'rx', 'MarkerSize', 10, 'LineWidth', 2);

            text(pos(end,1)+2, pos(end,2)+2, ...
                char(drones(k).name), ...
                'FontSize', 10, ...
                'FontWeight','bold');

            legendHandles = [legendHandles; hPath; hStart; hEnd];

            legendLabels = [legendLabels, ...
                {[char(drones(k).name), ' Path'], ...
                 [char(drones(k).name), ' Start'], ...
                 [char(drones(k).name), ' End']}];
        end
    end

    xlabel('X Position (m)', 'FontSize', 12, 'FontWeight','bold');
    ylabel('Y Position (m)', 'FontSize', 12, 'FontWeight','bold');

    title('Protected Square Boundary with Four Authorized Monitoring Nodes', ...
        'FontSize', 13, 'FontWeight','bold');

    legend(legendHandles, legendLabels, 'Location','bestoutside');

    axis equal;
    xlim([cfg.xMin-40 cfg.xMax+40]);
    ylim([cfg.yMin-40 cfg.yMax+40]);

    % ------------------------------------------------------------
    % If no drone is present, remaining drone-specific figures
    % are not required.
    % ------------------------------------------------------------
    if isempty(drones)
        return;
    end


    % ------------------------------------------------------------
    % FIGURE 2: Boundary presence with time
    % ------------------------------------------------------------
    figure('Name','Figure 2 - Boundary Presence With Time', ...
           'Color','w');

    hold on;
    grid on;
    box on;

    presenceHandles = gobjects(length(drones),1);

    for k = 1:length(drones)

        pos = drones(k).position;
        x = pos(:,1);
        y = pos(:,2);

        insideSquare = x >= cfg.xMin & x <= cfg.xMax & ...
                       y >= cfg.yMin & y <= cfg.yMax;

        detectedByAnyMonitor = false(length(t),1);

        for m = 1:size(cfg.monitorNodes,1)

            monitorPosition = cfg.monitorNodes(m,:);

            distanceToMonitor = sqrt( ...
                (x - monitorPosition(1)).^2 + ...
                (y - monitorPosition(2)).^2 );

            detectedByThisMonitor = distanceToMonitor <= cfg.sensingRange;

            detectedByAnyMonitor = detectedByAnyMonitor | detectedByThisMonitor;
        end

        presentInsideBoundary = insideSquare & detectedByAnyMonitor;

        presenceHandles(k) = plot(t, presentInsideBoundary, 'LineWidth', 2.2);
    end

    xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');
    ylabel('Boundary Presence Status', 'FontSize', 12, 'FontWeight','bold');

    yticks([0 1]);
    yticklabels({'Outside / Not Detected','Inside / Detected'});

    ylim([-0.15 1.15]);

    title('Drone Presence Inside the Protected Boundary', ...
        'FontSize', 13, 'FontWeight','bold');

    legend(presenceHandles, cellstr(stage0Table.Drone), 'Location','best');


    % ------------------------------------------------------------
    % FIGURE 3: Speed profile and mobility thresholds
    % ------------------------------------------------------------
    figure('Name','Figure 3 - Speed Profile and Mobility Classification', ...
           'Color','w');

    hold on;
    grid on;
    box on;

    speedHandles = gobjects(length(drones),1);

    for k = 1:length(drones)

        pos = drones(k).position;

        dx = diff(pos(:,1));
        dy = diff(pos(:,2));
        dt = diff(t(:));

        speed = sqrt(dx.^2 + dy.^2) ./ dt;

        speedHandles(k) = plot(t(2:end), speed, 'LineWidth', 2.2);
    end

    hStaticLimit = yline(cfg.staticMeanSpeedMax, '--', ...
        'Static Speed Limit', 'LineWidth', 1.5);

    hHoverLimit = yline(cfg.hoverMeanSpeedMax, '--', ...
        'Hovering Speed Limit', 'LineWidth', 1.5);

    xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');
    ylabel('Speed (m/s)', 'FontSize', 12, 'FontWeight','bold');

    title('Speed-Based Mobility Observation', ...
        'FontSize', 13, 'FontWeight','bold');

    legend([speedHandles; hStaticLimit; hHoverLimit], ...
        [cellstr(stage0Table.Drone); ...
        {'Static Speed Limit'}; ...
        {'Hovering Speed Limit'}], ...
        'Location','best');


    % ------------------------------------------------------------
    % FIGURE 4: Stage-1 situation risk score
    % ------------------------------------------------------------
    figure('Name','Figure 4 - Stage-1 Situation Category Risk Score', ...
           'Color','w');

    bar(stage1Table.Stage1_Risk_Score);

    grid on;
    box on;

    yline(20, '--', 'Needs Verification', 'LineWidth', 1.4);
    yline(45, '--', 'Suspicious Category', 'LineWidth', 1.4);
    yline(75, '--', 'High-Risk Category', 'LineWidth', 1.4);

    xticks(1:height(stage1Table));
    xticklabels(stage1Table.Drone);

    ylim([0 100]);

    ylabel('Stage-1 Risk Score (%)', ...
        'FontSize', 12, 'FontWeight','bold');

    title('Stage-1 Eve Situation Category Risk Score', ...
        'FontSize', 13, 'FontWeight','bold');


    % ------------------------------------------------------------
    % FIGURE 5: Stage-2 final risk score
    % ------------------------------------------------------------
    figure('Name','Figure 5 - Stage-2 Detailed Eve Identification Risk Score', ...
           'Color','w');

    bar(stage2Table.Risk_Score);

    grid on;
    box on;

    yline(cfg.needsVerificationScore, '--', ...
        'Needs Verification', 'LineWidth', 1.4);

    yline(cfg.suspiciousScore, '--', ...
        'Suspicious Drone', 'LineWidth', 1.4);

    yline(cfg.likelyEveScore, '--', ...
        'Likely Eve', 'LineWidth', 1.4);

    yline(cfg.highRiskEveScore, '--', ...
        'High-Risk Eve', 'LineWidth', 1.4);

    xticks(1:height(stage2Table));
    xticklabels(stage2Table.Drone);

    ylim([0 100]);

    ylabel('Stage-2 Risk Score (%)', ...
        'FontSize', 12, 'FontWeight','bold');

    title('Final Detailed Eve Identification Risk Score', ...
        'FontSize', 13, 'FontWeight','bold');


    % ------------------------------------------------------------
    % FIGURE 6: Detailed score breakdown
    % ------------------------------------------------------------
    scoreMatrix = [
        scoreTable.Identity_Score, ...
        scoreTable.Authentication_Score, ...
        scoreTable.RSSI_Score, ...
        scoreTable.CSI_Score, ...
        scoreTable.Location_Score, ...
        scoreTable.RF_Fingerprint_Score, ...
        scoreTable.Secrecy_Score, ...
        scoreTable.Activity_Score, ...
        scoreTable.Jamming_Score, ...
        scoreTable.Relay_Score, ...
        scoreTable.Collusion_Score
    ];

    figure('Name','Figure 6 - Detailed Evidence Score Breakdown', ...
           'Color','w');

    hBar = bar(scoreMatrix, 'stacked');

    grid on;
    box on;

    xticks(1:height(scoreTable));
    xticklabels(scoreTable.Drone);

    ylabel('Score Contribution', ...
        'FontSize', 12, 'FontWeight','bold');

    title('Evidence-Based Risk Score Breakdown', ...
        'FontSize', 13, 'FontWeight','bold');

    legendLabels = { ...
        'Identity', ...
        'Authentication', ...
        'RSSI', ...
        'CSI', ...
        'Location Evidence', ...
        'RF Fingerprint', ...
        'Secrecy', ...
        'Activity', ...
        'Jamming', ...
        'Relay', ...
        'Collusion'};

    legend(hBar, legendLabels, 'Location','bestoutside');


    % ------------------------------------------------------------
    % FIGURE 7: RSSI observation
    % ------------------------------------------------------------
    figure('Name','Figure 7 - RSSI Observation', ...
           'Color','w');

    hold on;
    grid on;
    box on;

    rssiHandles = gobjects(0);
    rssiLabels = {};

    for k = 1:length(drones)

        if all(isnan(drones(k).rssi_dBm))
            continue;
        end

        h = plot(t, drones(k).rssi_dBm, 'LineWidth', 2.2);

        rssiHandles(end+1,1) = h;
        rssiLabels{end+1} = char(drones(k).name);
    end

    hExpectedRSSI = yline(cfg.expectedBobRSSI_dBm, '--', ...
        'Expected Bob RSSI', 'LineWidth', 1.7);

    hUpperRSSI = yline(cfg.expectedBobRSSI_dBm + cfg.rssiMismatchTh, ':', ...
        'Upper RSSI Threshold', 'LineWidth', 1.4);

    hLowerRSSI = yline(cfg.expectedBobRSSI_dBm - cfg.rssiMismatchTh, ':', ...
        'Lower RSSI Threshold', 'LineWidth', 1.4);

    xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');
    ylabel('RSSI (dBm)', 'FontSize', 12, 'FontWeight','bold');

    title('RSSI-Based Physical Layer Observation', ...
        'FontSize', 13, 'FontWeight','bold');

    if isempty(rssiHandles)
        text(0.10, 0.50, ...
            'RSSI is not available for the observed passive drone because it does not transmit.', ...
            'Units','normalized', ...
            'FontSize', 11, ...
            'FontWeight','bold');
    else
        legend([rssiHandles; hExpectedRSSI; hUpperRSSI; hLowerRSSI], ...
            [rssiLabels, ...
            {'Expected Bob RSSI'}, ...
            {'Upper Threshold'}, ...
            {'Lower Threshold'}], ...
            'Location','best');
    end


    % ------------------------------------------------------------
    % FIGURE 8: CSI mismatch observation
    % ------------------------------------------------------------
    figure('Name','Figure 8 - CSI Mismatch Observation', ...
           'Color','w');

    hold on;
    grid on;
    box on;

    csiHandles = gobjects(0);
    csiLabels = {};

    for k = 1:length(drones)

        if all(isnan(drones(k).csiMismatch))
            continue;
        end

        h = plot(t, drones(k).csiMismatch, 'LineWidth', 2.2);

        csiHandles(end+1,1) = h;
        csiLabels{end+1} = char(drones(k).name);
    end

    hCSIThreshold = yline(cfg.csiMismatchTh, '--', ...
        'CSI Mismatch Threshold', 'LineWidth', 1.7);

    xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');
    ylabel('CSI Mismatch', 'FontSize', 12, 'FontWeight','bold');

    title('CSI Mismatch-Based Channel Fingerprint Observation', ...
        'FontSize', 13, 'FontWeight','bold');

    if isempty(csiHandles)
        text(0.10, 0.50, ...
            'CSI is not available for the observed passive drone because it does not transmit.', ...
            'Units','normalized', ...
            'FontSize', 11, ...
            'FontWeight','bold');
    else
        legend([csiHandles; hCSIThreshold], ...
            [csiLabels, {'CSI Threshold'}], ...
            'Location','best');
    end


    % ------------------------------------------------------------
    % FIGURE 9: Secrecy capacity observation
    % ------------------------------------------------------------
    snrBobLinear = 10.^(situation.link.snrBob_dB/10);
    CB = log2(1 + snrBobLinear);

    figure('Name','Figure 9 - Secrecy Capacity Observation', ...
           'Color','w');

    hold on;
    grid on;
    box on;

    secrecyHandles = gobjects(length(drones),1);

    for k = 1:length(drones)

        snrNodeLinear = 10.^(drones(k).snr_dB/10);
        CE = log2(1 + snrNodeLinear);

        CS = max(CB - CE, 0);

        secrecyHandles(k) = plot(t, CS, 'LineWidth', 2.2);
    end

    hRequiredSecrecy = yline(cfg.secrecyRateRequired, '--', ...
        'Required Secrecy Rate', 'LineWidth', 1.7);

    xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');

    ylabel('Secrecy Capacity, C_s (bits/s/Hz)', ...
        'FontSize', 12, 'FontWeight','bold');

    title('Secrecy Capacity Observation for Detected Drone Scenario', ...
        'FontSize', 13, 'FontWeight','bold');

    legend([secrecyHandles; hRequiredSecrecy], ...
        [cellstr(stage2Table.Drone); {'Required Secrecy Rate'}], ...
        'Location','best');


    % ------------------------------------------------------------
    % FIGURE 10: Bob link quality and interference observation
    % ------------------------------------------------------------
    figure('Name','Figure 10 - Bob Link Quality and Interference', ...
           'Color','w');

    yyaxis left;

    hSNR = plot(t, situation.link.snrBob_dB, 'LineWidth', 2.2);
    hold on;
    grid on;
    box on;

    hSNRThreshold = yline(cfg.snrBobLowTh, '--', ...
        'Low Bob SNR Threshold', 'LineWidth', 1.4);

    ylabel('Bob SNR (dB)', ...
        'FontSize', 12, 'FontWeight','bold');

    yyaxis right;

    hInterference = plot(t, situation.link.interference_dBm, ...
        'LineWidth', 2.2);

    hInterferenceThreshold = yline(cfg.interferenceHighTh, '--', ...
        'High Interference Threshold', 'LineWidth', 1.4);

    ylabel('Interference Power (dBm)', ...
        'FontSize', 12, 'FontWeight','bold');

    xlabel('Time (s)', 'FontSize', 12, 'FontWeight','bold');

    title('Legitimate Bob Link Quality and Interference Monitoring', ...
        'FontSize', 13, 'FontWeight','bold');

    legend([hSNR; hSNRThreshold; hInterference; hInterferenceThreshold], ...
        {'Bob SNR', ...
         'Low Bob SNR Threshold', ...
         'Interference Power', ...
         'High Interference Threshold'}, ...
        'Location','best');


    % ------------------------------------------------------------
    % Professional command-window summary after plots
    % ------------------------------------------------------------
    disp(' ');
    disp('============================================================');
    disp('                    PLOT SUMMARY');
    disp('============================================================');
    disp('Figure 1  : Protected boundary, monitoring nodes, Bob, and drone path');
    disp('Figure 2  : Drone presence inside boundary with time');
    disp('Figure 3  : Speed profile for mobility classification');
    disp('Figure 4  : Stage-1 situation category risk score');
    disp('Figure 5  : Stage-2 detailed Eve risk score');
    disp('Figure 6  : Evidence-based score breakdown');
    disp('Figure 7  : RSSI observation');
    disp('Figure 8  : CSI mismatch observation');
    disp('Figure 9  : Secrecy capacity observation');
    disp('Figure 10 : Bob SNR and interference monitoring');
end


% ============================================================
% END OF PART 4
% COMPLETE MATLAB CODE IS NOW READY TO RUN.
% ============================================================
