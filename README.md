# Battleship Game - Formal B Specification

A formal specification and implementation of the classic Battleship strategy game using the B-Method, developed with Atelier B and ProB tools.

## Overview

This project implements a strategic naval combat game where two players compete to sink each other's fleet. The game is built using formal methods with a complete B specification that ensures corre[...]

## Game Features

### Grid System
- 10x10 playing grid for each player  
- Coordinate system: (column, row) where (6,8) represents column 6, row 8  
- Separate concealed grids for each player's fleet

### Fleet Composition
Each player commands a fleet of 3 ships:
- Submarine: Occupies 1 square  
- Destroyer: Occupies 2 consecutive squares (horizontal or vertical)  
- Cruiser: Occupies 3 consecutive squares (horizontal or vertical)

### Game Rules
- Ships cannot overlap on the same player's grid  
- Players alternate turns shooting at opponent's ships  
- First player to sink all opponent ships wins  
- Ships are sunk when all their squares are hit

## Gameplay

### Setup Phase
- Players deploy their ships in order:  
  - Submarine first  
  - Destroyer second  
  - Cruiser last  
- Deployment can be done in any order between players  
- Ships can be oriented horizontally (across) or vertically (down)

### Combat Phase
- Player 1 shoots at a target square on Player 2's grid  
  - Hit: Target square contains an enemy ship  
  - Sunk: All squares of a ship have been hit  
  - Miss: Target square is empty  
- Player 2 takes their turn  
- Turns alternate until one player's fleet is destroyed

## Technical Specification

### Core Operations
- DeploySubMarine(player, position)  
  - Deploys a player's submarine at the specified position.  
  - Precondition: Submarine not yet deployed  
  - Returns: Success or error message

- DeployDestroyer(player, position, orientation)  
  - Deploys a player's destroyer at the specified position.  
  - Precondition: Submarine deployed, destroyer not yet deployed  
  - Parameters:  
    - position: Top-left cell of the ship  
    - orientation: ACROSS or DOWN  
  - Validates: Position validity and no overlap with existing ships  
  - Returns: Success or error message

- DeployCruiser(player, position, orientation)  
  - Deploys a player's cruiser at the specified position.  
  - Precondition: Destroyer deployed, cruiser not yet deployed  
  - Parameters:  
    - position: Top-left cell of the ship  
    - orientation: ACROSS or DOWN  
  - Validates: Position validity and no overlap with existing ships  
  - Returns: Success or error message

- Shoot(player, target)  
  - Player shoots at opponent's grid.  
  - Precondition: Setup complete (both players' cruisers deployed)  
  - Returns:  
    - hit: Ship damaged but not sunk  
    - sunk: Ship completely destroyed  
    - miss: No ship at target  
  - Error if target outside grid  
  - Game End: Automatically detected when all ships of one player are sunk

### Query Operations
- LocationOfShips(player)  
  - Returns all grid positions occupied by the player's ships.

- ShipsLeft(player)  
  - Returns the count of ships remaining in the player's fleet.

- ShotsTaken(player)  
  - Returns the total number of shots fired by the player.

- GameState()  
  - Returns current game state:  
    - Setting up  
    - Playing  
    - Player 1 win  
    - Player 2 win

## Development Tools
- Atelier B  
  - Used for formal specification development and syntax validation.  
  - Ensures type correctness  
  - Validates B-Method syntax  
  - Provides proof obligations

- ProB  
  - Used for animation and model checking.  
  - Interactive simulation of game states  
  - Operation testing and validation  
  - State space exploration

## Project Structure
The B specification can be organized as:
- Single Machine: All state variables and operations in one B machine  
- Modular Structure: Multiple B machines using SEES, INCLUDES, or other structuring mechanisms

## Getting Started

### Prerequisites
- Atelier B (for specification development)  
- ProB (for animation and validation)

### Running the Specification
1. Load Battleship.mch in Atelier B  
2. Type check the specification  
3. Open in ProB for animation  
4. Initialize the game  
5. Execute operations to play the game

## Example Game Flow
1. DeploySubMarine(Player1, (3,3))  
2. DeployDestroyer(Player1, (7,3), ACROSS)  
3. DeployCruiser(Player1, (4,7), DOWN)  
4. [Player 2 deploys their fleet...]  
5. Shoot(Player1, (8,3)) → hit  
6. Shoot(Player2, (4,4)) → miss  
7. [Continue until victory...]

## Validation
The specification has been validated for:
- ✓ Syntactic correctness  
- ✓ Type correctness  
- ✓ Proper initialization  
- ✓ Operation preconditions and postconditions  
- ✓ State invariant preservation  
- ✓ Complete game simulation capability

## Error Handling
All operations provide comprehensive error reporting:
- Invalid grid positions  
- Ship overlap detection  
- Out-of-sequence deployment  
- Shooting before setup complete  
- Target outside grid boundaries

## License
This project demonstrates formal methods in software engineering using the B-Method for game development.

Built with formal methods for correctness and reliability 🎯
