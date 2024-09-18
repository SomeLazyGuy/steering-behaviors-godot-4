# Steering Behaviors in Godot 4

This project demonstrates various steering behaviors for autonomous agent movement in the Godot 4 game engine, using GDScript. The purpose is to provide clear examples of how artificial movement can be implemented in Godot, specifically targeting AI-based movement patterns for games and simulations.

The project follows the examples laid out in *"Programming Game AI by Example"* by Mat Buckland, originally published by Wordware Publishing Inc. in 2004. This classic text serves as the foundation for many of the behaviors featured here.

## Features

The repository includes the following behaviors:

- **Seek & Flee**: Basic movement toward or away from a target.
- **Arrive**: Smoothly decelerates as the agent approaches its destination.
- **Pursuit & Evasion**: Predictive movement, where agents either chase or avoid a moving target.
- **Wander**: Simulates random movement with slight steering bias.
- **Obstacle Avoidance**: Agents steer around obstacles in their path.
- **Wall Avoidance**: Agents steer away from walls in there path.
- **Interpose**: Agents move to the predicted position of two other nodes / agents.
- **Hide**: Agents hide behind an obstacle to escape direkt line of sight of another agent.
- **Path Following**: Agents follow or loop around a predifined path.
- **Offset Pursuit**: Agents pursue a target agent while keeping a specific offset to this agent.
- **Group Behaviors**: Basic group behaviors like **Cohesion**, **Seperation** and **Alignment**.

Additional behaviors may be added in future updates, such as **Flocking**, **Spacial Partitioning**, **Smoothing**, and more.

## Getting Started

To run the project:

1. Install [Godot Engine 4.x](https://godotengine.org/download) if you haven't already.
2. Clone or download the repository.
3. Open the project in Godot by selecting the project.godot file.
4. Play the different scenes to see some demos of the steering behaviors in action.

The scripts are organized under the `scripts/` folder, with each behavior represented by its own script file for easy reference. There are also predifined nodes under the `steering_behavior/` folder to just attach as a child and configure in the editor. To get an overview over every steering behavior take a look at the example scenes under `scenes/`.

### Prerequisites

- Godot 4.x (tested on version 4.0 and later)
- Basic familiarity with GDScript

## Project Status

🚧 **Work in Progress**: This project is a learning tool, and as such, the code quality is not always consistent with best practices in terms of formatting, naming conventions, or optimization. The current state of the project includes some known bugs, and not all behaviors function exactly as intended. Additional features and steering behaviors will be added over time.

### Known Issues

- Inconsistent formatting and naming conventions
- Some steering behaviors may not perform as expected due to bugs or incomplete implementations
- Occasional performance issues when dealing with many agents in the scene

Feel free to open an issue if you encounter specific bugs, or if you have suggestions for improvement.

## Contributing

Contributions are welcome! If you'd like to improve the codebase, fix bugs, or add new behaviors, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Submit a pull request with a detailed description of your changes.

All contributions—whether it's fixing a typo, refactoring the code, or adding new behaviors—are appreciated!

### Contribution Ideas:

- Refactor code to improve consistency and readability.
- Add new steering behaviors, such as group-based behaviors (e.g., flocking, cohesion).
- Optimize the performance of agents when navigating large scenes.
- Improve agent interaction with dynamic obstacles or environments.

## References

This project draws heavily from:

- *Programming Game AI by Example* by Mat Buckland (Wordware Publishing, 2004)

For additional learning materials and resources on steering behaviors, artificial intelligence in games, and GDScript, check out:

- [Godot Engine Official Documentation](https://docs.godotengine.org/en/stable/)
- [Programming Game AI by Example on Amazon](https://www.amazon.com/Programming-Game-AI-Example-Wordware/dp/1556220782)

## Disclaimer

This project was created primarily as a learning exercise for Godot 4 and GDScript. It is not intended to represent production-quality code. Use it as a reference for learning, but please keep in mind that the code may contain bugs and is not guaranteed to function perfectly in all scenarios.

I will continue to improve the project as time allows, but fixes, improvements, and refactoring are always welcome from the community.

## License

This project is open-source under the MIT License. See the [LICENSE](LICENSE) file for details.
