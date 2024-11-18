import 'dart:math'; 
import 'package:flutter/material.dart'; 
import 'package:audioplayers/audioplayers.dart'; // Importing the audio player package for sound effects.

void main() {
  runApp(DiceApp()); 
}

class DiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: DicePage(), 
    );
  }
}

// Stateful widget for the main dice roller functionality
class DicePage extends StatefulWidget {
  @override
  _DicePageState createState() => _DicePageState();
}

// State class for DicePage
class _DicePageState extends State<DicePage> with SingleTickerProviderStateMixin {
  int selectedDiceCount = 1; // Default number of dice to roll.
  List<int> diceResults = []; // Stores the results of the dice rolls.
  bool isRolling = false; // Flag to indicate if dice rolling is in progress.
  final Random random = Random(); // Random number generator instance.
  final AudioPlayer audioPlayer = AudioPlayer(); // Audio player instance for sound effects.

  // Animation-related variables
  late AnimationController _controller; // Controls the animation.
  late Animation<double> _rotationAnimation; // Defines a rotation animation.

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Animation duration.
      vsync: this, // Provides a ticker for animation updates.
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of animation controller
    audioPlayer.dispose(); // Dispose of audio player.
    super.dispose();
  }

  // Function to roll the dice
  void rollDice() async {
    if (isRolling) return; // error handling Ignore input if a roll is already in progress.
    setState(() {
      isRolling = true; // Set the rolling flag.
    });

    try {
      // Play the dice rolling sound effect
      await audioPlayer.play(AssetSource('sounds/sound.mp3'));
    } catch (e) {
      // Handle sound playback errors
      debugPrint('Error playing sound: $e');
    }

    // Start the dice rolling animation
    _controller.repeat();

    try {
      // Simulate rolling for a short duration
      for (int i = 0; i < 10; i++) {
        await Future.delayed(Duration(milliseconds: 400), () {
          setState(() {
            // Generate random results for the selected number of dice.
            diceResults = List.generate(
              selectedDiceCount,
              (_) => random.nextInt(6) + 1, // Random number between 1 and 6.
            );
          });
        });
      }
    } catch (e) {
      // Handle errors during dice roll animation
      debugPrint('Error during dice roll animation: $e');
      setState(() {
        diceResults = []; // Clear results to avoid invalid data.
      });
    } finally {
      // Reset the animation and rolling flag
      setState(() {
        isRolling = false;
      });
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900, // App bar background color.
        title: Text(
          'Dice Roller', 
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, 
      ),
      // Background of the app set to a table image
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/tawla2.PNG'), // Background image of a table.
            fit: BoxFit.cover, // Cover the entire screen.
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20), 
              // Dropdown to select the number of dice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select number of dice:',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<int>(
                    value: selectedDiceCount, // Current value.
                    dropdownColor: Colors.blue.shade200, // Dropdown background color.
                    items: [1, 2, 3]
                        .map((count) => DropdownMenuItem<int>(
                              value: count, // Dropdown item value.
                              child: Text(
                                '$count',
                                style: TextStyle(color: Colors.black),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDiceCount = value!; // Update the selected number of dice.
                        diceResults = []; // Clear previous results.
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Display dice results
              Expanded(
                child: Center(
                  child: diceResults.isEmpty
                      ? Text(
                          'Press "Roll Dice" to start!',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        )
                      : Wrap(
                          spacing: 20, 
                          children: diceResults
                              .map((result) => AnimatedBuilder(
                                    animation: _rotationAnimation,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: isRolling ? _rotationAnimation.value : 0, // Rotate if rolling.
                                        child: Transform.translate(
                                          offset: isRolling
                                              ? Offset(random.nextDouble() * 10 - 5, random.nextDouble() * 10 - 5)
                                              : Offset(0, 0), // Add slight shake effect during rolling.
                                          child: Image.asset(
                                            'images/dice_$result.PNG', // Display the dice image for the result.
                                            width: 100,
                                            height: 100,
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                              .toList(),
                        ),
                ),
              ),
              SizedBox(height: 20),
              // Roll dice button
              ElevatedButton(
                onPressed: rollDice, // Call rollDice on button press.
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color.
                  backgroundColor: Colors.orange.shade700, // Button color.
                  shadowColor: Colors.grey, // Shadow color.
                  elevation: 10, // Elevation for shadow effect.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners.
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Button padding.
                ),
                child: Text(
                  isRolling ? 'Rolling...' : 'Roll Dice', // Update button text during rolling.
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


