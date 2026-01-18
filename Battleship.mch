MACHINE Battleship

SETS
    PLAYER = {P1, P2};
    ORIENTATION = {ACROSS, DOWN};
    GAME_STATE = {SETUP, PLAYING, P1_WIN, P2_WIN};
    REPORT = {OK, HIT, MISS, SUNK,
              ERR_NOT_SETUP, ERR_NOT_PLAYING,
              ERR_SUB_DEPLOYED, ERR_DEST_DEPLOYED, ERR_CRUISE_DEPLOYED,
              ERR_SUB_NOT_DEPLOYED, ERR_DEST_NOT_DEPLOYED,
              ERR_OUT_OF_BOUNDS, ERR_OVERLAP,
              ERR_NOT_YOUR_TURN, ERR_GAME_OVER, ERR_ALREADY_HIT}

CONSTANTS
    GRID

PROPERTIES
    GRID = (1..10) * (1..10)

VARIABLES
    gameState,
    currentTurn,
    submarine,
    destroyer,
    cruiser,
    subDeployed,
    destDeployed,
    cruiseDeployed,
    shipHits,
    shotsTaken,
    shotsFired

INVARIANT
    gameState : GAME_STATE &
    currentTurn : PLAYER &
    submarine : PLAYER --> POW(GRID) &
    destroyer : PLAYER --> POW(GRID) &
    cruiser : PLAYER --> POW(GRID) &
    subDeployed : PLAYER --> BOOL &
    destDeployed : PLAYER --> BOOL &
    cruiseDeployed : PLAYER --> BOOL &
    shipHits : PLAYER --> POW(GRID) &
    shotsTaken : PLAYER --> NAT &
    shotsFired : PLAYER --> POW(GRID) &
    !(pp).(pp : PLAYER => card(submarine(pp)) <= 1) &
    !(pp).(pp : PLAYER => card(destroyer(pp)) <= 2) &
    !(pp).(pp : PLAYER => card(cruiser(pp)) <= 3) &
    /* shipHits only contains positions that are on ships */
    !(pp).(pp : PLAYER => shipHits(pp) <: (submarine(pp) \/ destroyer(pp) \/ cruiser(pp))) &
    /* shotsFired contains all squares fired at by each player */
    !(pp).(pp : PLAYER => shotsFired(pp) <: GRID)

INITIALISATION
    gameState := SETUP ||
    currentTurn := P1 ||
    submarine := {P1 |-> {}, P2 |-> {}} ||
    destroyer := {P1 |-> {}, P2 |-> {}} ||
    cruiser := {P1 |-> {}, P2 |-> {}} ||
    subDeployed := {P1 |-> FALSE, P2 |-> FALSE} ||
    destDeployed := {P1 |-> FALSE, P2 |-> FALSE} ||
    cruiseDeployed := {P1 |-> FALSE, P2 |-> FALSE} ||
    shipHits := {P1 |-> {}, P2 |-> {}} ||
    shotsTaken := {P1 |-> 0, P2 |-> 0} ||
    shotsFired := {P1 |-> {}, P2 |-> {}}

OPERATIONS
    report <-- DeploySubMarine(player, position) =
    PRE
        player : PLAYER &
        position : GRID &
        gameState = SETUP &
        subDeployed(player) = FALSE
    THEN
        IF position : (submarine(player) \/ destroyer(player) \/ cruiser(player))
        THEN 
            report := ERR_OVERLAP
        ELSE
            submarine := submarine <+ {player |-> {position}} ||
            subDeployed := subDeployed <+ {player |-> TRUE} ||
            report := OK
        END
    END;

    report <-- DeployDestroyer(player, position, orientation) =
    PRE
        player : PLAYER &
        position : GRID &
        orientation : ORIENTATION &
        gameState = SETUP &
        subDeployed(player) = TRUE &
        destDeployed(player) = FALSE
    THEN
        LET xx BE xx = prj1(1..10, 1..10)(position) IN
        LET yy BE yy = prj2(1..10, 1..10)(position) IN
            IF orientation = ACROSS & xx + 1 > 10
            THEN 
                report := ERR_OUT_OF_BOUNDS
            ELSIF orientation = DOWN & yy + 1 > 10
            THEN 
                report := ERR_OUT_OF_BOUNDS
            ELSIF orientation = ACROSS & 
                  ({(xx, yy), (xx + 1, yy)} /\ (submarine(player) \/ destroyer(player) \/ cruiser(player))) /= {}
            THEN 
                report := ERR_OVERLAP
            ELSIF orientation = DOWN & 
                  ({(xx, yy), (xx, yy + 1)} /\ (submarine(player) \/ destroyer(player) \/ cruiser(player))) /= {}
            THEN 
                report := ERR_OVERLAP
            ELSE
                IF orientation = ACROSS
                THEN
                    destroyer := destroyer <+ {player |-> {(xx, yy), (xx + 1, yy)}} ||
                    destDeployed := destDeployed <+ {player |-> TRUE} ||
                    report := OK
                ELSE
                    destroyer := destroyer <+ {player |-> {(xx, yy), (xx, yy + 1)}} ||
                    destDeployed := destDeployed <+ {player |-> TRUE} ||
                    report := OK
                END
            END
        END
        END
    END;

    report <-- DeployCruiser(player, position, orientation) =
    PRE
        player : PLAYER &
        position : GRID &
        orientation : ORIENTATION &
        gameState = SETUP &
        destDeployed(player) = TRUE &
        cruiseDeployed(player) = FALSE
    THEN
        LET xx BE xx = prj1(1..10, 1..10)(position) IN
        LET yy BE yy = prj2(1..10, 1..10)(position) IN
            IF orientation = ACROSS & xx + 2 > 10
            THEN 
                report := ERR_OUT_OF_BOUNDS
            ELSIF orientation = DOWN & yy + 2 > 10
            THEN 
                report := ERR_OUT_OF_BOUNDS
            ELSIF orientation = ACROSS & 
                  ({(xx, yy), (xx + 1, yy), (xx + 2, yy)} /\ (submarine(player) \/ destroyer(player) \/ cruiser(player))) /= {}
            THEN 
                report := ERR_OVERLAP
            ELSIF orientation = DOWN & 
                  ({(xx, yy), (xx, yy + 1), (xx, yy + 2)} /\ (submarine(player) \/ destroyer(player) \/ cruiser(player))) /= {}
            THEN 
                report := ERR_OVERLAP
            ELSIF orientation = ACROSS & player = P1 & cruiseDeployed(P2) = TRUE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx + 1, yy), (xx + 2, yy)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                gameState := PLAYING ||
                report := OK
            ELSIF orientation = ACROSS & player = P1 & cruiseDeployed(P2) = FALSE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx + 1, yy), (xx + 2, yy)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                report := OK
            ELSIF orientation = ACROSS & player = P2 & cruiseDeployed(P1) = TRUE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx + 1, yy), (xx + 2, yy)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                gameState := PLAYING ||
                report := OK
            ELSIF orientation = ACROSS & player = P2 & cruiseDeployed(P1) = FALSE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx + 1, yy), (xx + 2, yy)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                report := OK
            ELSIF orientation = DOWN & player = P1 & cruiseDeployed(P2) = TRUE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx, yy + 1), (xx, yy + 2)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                gameState := PLAYING ||
                report := OK
            ELSIF orientation = DOWN & player = P1 & cruiseDeployed(P2) = FALSE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx, yy + 1), (xx, yy + 2)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                report := OK
            ELSIF orientation = DOWN & player = P2 & cruiseDeployed(P1) = TRUE
            THEN
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx, yy + 1), (xx, yy + 2)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                gameState := PLAYING ||
                report := OK
            ELSE
                cruiser := cruiser <+ {player |-> {(xx, yy), (xx, yy + 1), (xx, yy + 2)}} ||
                cruiseDeployed := cruiseDeployed <+ {player |-> TRUE} ||
                report := OK
            END
        END
        END
    END;

    /* P1 shoots at P2's ships */
    report <-- ShootP1(target) =
    PRE
        target : GRID &
        gameState = PLAYING &
        currentTurn = P1 &
        target /: shotsFired(P1)
    THEN
        LET xx BE xx = prj1(1..10, 1..10)(target) IN
        LET yy BE yy = prj2(1..10, 1..10)(target) IN
        LET targetSet BE targetSet = {(xx, yy)} IN
        LET newFired BE newFired = shotsFired(P1) \/ targetSet IN
        LET newHits BE newHits = shipHits(P2) \/ targetSet IN
        LET opponentShips BE opponentShips = submarine(P2) \/ destroyer(P2) \/ cruiser(P2) IN
            IF target : opponentShips
            THEN
                /* Check if all ships are now sunk */
                IF submarine(P2) <: newHits & destroyer(P2) <: newHits & cruiser(P2) <: newHits
                THEN
                    shipHits := shipHits <+ {P2 |-> newHits} ||
                    shotsFired := shotsFired <+ {P1 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P1 |-> shotsTaken(P1) + 1} ||
                    gameState := P1_WIN ||
                    report := SUNK
                ELSIF target : submarine(P2) & submarine(P2) <: newHits
                THEN
                    shipHits := shipHits <+ {P2 |-> newHits} ||
                    shotsFired := shotsFired <+ {P1 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P1 |-> shotsTaken(P1) + 1} ||
                    currentTurn := P2 ||
                    report := SUNK
                ELSIF target : destroyer(P2) & destroyer(P2) <: newHits
                THEN
                    shipHits := shipHits <+ {P2 |-> newHits} ||
                    shotsFired := shotsFired <+ {P1 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P1 |-> shotsTaken(P1) + 1} ||
                    currentTurn := P2 ||
                    report := SUNK
                ELSIF target : cruiser(P2) & cruiser(P2) <: newHits
                THEN
                    shipHits := shipHits <+ {P2 |-> newHits} ||
                    shotsFired := shotsFired <+ {P1 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P1 |-> shotsTaken(P1) + 1} ||
                    currentTurn := P2 ||
                    report := SUNK
                ELSE
                    shipHits := shipHits <+ {P2 |-> newHits} ||
                    shotsFired := shotsFired <+ {P1 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P1 |-> shotsTaken(P1) + 1} ||
                    currentTurn := P2 ||
                    report := HIT
                END
            ELSE
                shotsFired := shotsFired <+ {P1 |-> newFired} ||
                shotsTaken := shotsTaken <+ {P1 |-> shotsTaken(P1) + 1} ||
                currentTurn := P2 ||
                report := MISS
            END
        END
        END
        END
        END
        END
        END
    END;

    /* P2 shoots at P1's ships */
    report <-- ShootP2(target) =
    PRE
        target : GRID &
        gameState = PLAYING &
        currentTurn = P2 &
        target /: shotsFired(P2)
    THEN
        LET xx BE xx = prj1(1..10, 1..10)(target) IN
        LET yy BE yy = prj2(1..10, 1..10)(target) IN
        LET targetSet BE targetSet = {(xx, yy)} IN
        LET newFired BE newFired = shotsFired(P2) \/ targetSet IN
        LET newHits BE newHits = shipHits(P1) \/ targetSet IN
        LET opponentShips BE opponentShips = submarine(P1) \/ destroyer(P1) \/ cruiser(P1) IN
            IF target : opponentShips
            THEN
                /* Check if all ships are now sunk */
                IF submarine(P1) <: newHits & destroyer(P1) <: newHits & cruiser(P1) <: newHits
                THEN
                    shipHits := shipHits <+ {P1 |-> newHits} ||
                    shotsFired := shotsFired <+ {P2 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P2 |-> shotsTaken(P2) + 1} ||
                    gameState := P2_WIN ||
                    report := SUNK
                ELSIF target : submarine(P1) & submarine(P1) <: newHits
                THEN
                    shipHits := shipHits <+ {P1 |-> newHits} ||
                    shotsFired := shotsFired <+ {P2 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P2 |-> shotsTaken(P2) + 1} ||
                    currentTurn := P1 ||
                    report := SUNK
                ELSIF target : destroyer(P1) & destroyer(P1) <: newHits
                THEN
                    shipHits := shipHits <+ {P1 |-> newHits} ||
                    shotsFired := shotsFired <+ {P2 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P2 |-> shotsTaken(P2) + 1} ||
                    currentTurn := P1 ||
                    report := SUNK
                ELSIF target : cruiser(P1) & cruiser(P1) <: newHits
                THEN
                    shipHits := shipHits <+ {P1 |-> newHits} ||
                    shotsFired := shotsFired <+ {P2 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P2 |-> shotsTaken(P2) + 1} ||
                    currentTurn := P1 ||
                    report := SUNK
                ELSE
                    shipHits := shipHits <+ {P1 |-> newHits} ||
                    shotsFired := shotsFired <+ {P2 |-> newFired} ||
                    shotsTaken := shotsTaken <+ {P2 |-> shotsTaken(P2) + 1} ||
                    currentTurn := P1 ||
                    report := HIT
                END
            ELSE
                shotsFired := shotsFired <+ {P2 |-> newFired} ||
                shotsTaken := shotsTaken <+ {P2 |-> shotsTaken(P2) + 1} ||
                currentTurn := P1 ||
                report := MISS
            END
        END
        END
        END
        END
        END
        END
    END;

    shipSquares <-- LocationOfShips(player) =
    PRE
        player : PLAYER
    THEN
        shipSquares := submarine(player) \/ destroyer(player) \/ cruiser(player)
    END;

    shipsCount <-- ShipsLeft(player) =
    PRE
        player : PLAYER
    THEN
        shipsCount := 
            card({xx | xx : {1} & subDeployed(player) = TRUE & not(submarine(player) <: shipHits(player))}) +
            card({xx | xx : {1} & destDeployed(player) = TRUE & not(destroyer(player) <: shipHits(player))}) +
            card({xx | xx : {1} & cruiseDeployed(player) = TRUE & not(cruiser(player) <: shipHits(player))})
    END;

    shotCount <-- ShotsTaken(player) =
    PRE
        player : PLAYER
    THEN
        shotCount := shotsTaken(player)
    END;

    report <-- GameState =
    BEGIN
        report := gameState
    END

END
    