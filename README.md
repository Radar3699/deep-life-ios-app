# DeepLife: IOS App

DeepLife is a game where the goal is to teach an AI named Kevin the axioms of Conway's Game of Life with as few examples as possible. This repo contains the backend pieces, in particular the Models, Views, Controllers, and tests, to impliment DeepLife in an MVC based ios App in Swift. 

There are two grids, a "Training" grid which Kevin watches you use and has the nomal rules programmed in. The "Kevin" grid is a Game of Life grid implimenting Kevin's current conception of the rules. Use the AI grid to monitor it's progress: E.g. Kevin doesn't understand infinate loop patterns properly? Show it some infinate loop patterns in the normal grid! The more nuanced the pattern, the more Kevin will learn from the pattern. 

## Example

Below is an example of a 'glider' - a famous infinate loop pattern in Conways's Game of Life. 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V0.gif)

Kevin starts with a random conception of the rules. We can see he updates the grid with a random set of rules. 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V1.gif)

We can start by showing him how the pattern is supposed to work on the training grid. 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V2.gif)

We can see after we've demonstrated the pattern - he thinks for a moment - then becomes smarter and more experienced. 

Experience is a measure of the number of subpatterns Kevin has seen.

Intelligence is how close Kevin's conception of the rules are to the real rules. 

The goal is to show him patterns that bring his intelligence to 100% with the lowest amount of experience. The more nuanced the patterns, the more he will learn from a given experience. 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V3.gif)

In the test grid we can see he's much better than before, he has learned a set of rules that make a glider pattern go infinate but is still isn't quite right. 

This is because he doesn't just memorize patterns, he's trying to learn generalizable rules from the patterns he has seen. This is ultimately why he can reach 100% intelligence with less than 100% experience. 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V4.gif)

We can go back to the training grid and show him another infinate loop pattern (these patterns tend to contain a lot of generalizable information) 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V5.gif)

We can see the behavior is closer qualitatively to the real thing but overall activity seems to die out a bit to quickly. 

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/V6.gif)

After showing him a little more info he's reached 100%, with only 36% experience, not bad! We can see in the test grid he now correctly knows how gliders work and qualitatively his behavior is the same as the real thing. 

We can then reset his mind with the reset button and he'll learn an entirely new conception of the rules with a new initialization. 

## Other Functionality

Changing the grid size:

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/E1.gif)

Auto-stepping the grid:

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/E2.gif)

Saving patterns:

![alt text](https://github.com/Radar3699/DeepLife/blob/master/Demos/E3.gif)

## How it works

Kevin is powered by a 9x16x16x1 fully connected neural network courtesy of Kevin Coble's AI Toolbox. The standard grid impliments a function Update(3x3 grid) -> [1,0], mapping to 1 if the cell in the middle is alive in the next generation and 0 if it isn't. This depends only on the cell's immediate surroundings, per Conway's Game of Life rules. This function is then convolved over the grid to update it between steps. 

Kevin's grid replaces this update function with a function FeedForward(3x3 grid) -> (probability cell is alive in next generation). This network is convolved over the grid, and 0.5 is used as a threshold for killing or generating cells for the next generation. 

As the user inputs patterns into the main grid, the (3x3) -> (1 or 0) subpatterns are saved to a dataset which Kevin trains on while the face is thinking. We have a test set of size 2^9=512 examples enumerating all possible cell surroundings and outcomes which is populated by the standard game rules. The fraction of (3x3) subpatterns correct in this set is what we call intelligence. It's also how we can inductively prove when intelligence is 100% kevin is implimenting the exact same rules as Conway's Game of Life. The total size of the training set divided by 512 is what we call experience. 

## Files

### Model

```
NeuralNetwork.swift
```

Contains the functions for convertng grids to input vectors for the network, convolving over the grid, etc. 

```
Initialize.swift
```

Initialies the test set used to evaluate Kevin's intelligence. Should be called once during app startup in `AppDelegate.swift`

```
TrainAndTest.swift
```

Contains the primary two functions for training kevin on a dataset, and evaluating his intelligence and experience. 

```
AdditionalHelpers.swift
```

Contains some other experiments combining deep learning with conways game of life, such as attempting to predict the lifespan of patterns. Also contains helper functions for these experiments. Nothing in this file was used in the final demo above but was very helpful during development.

### View

```
KevinView.swift
```

Contains the view for the animated face, including the draw functions for happy Kevin and thinking Kevin. 

### Controller

```
KevinViewController.swift
```

Contains the veiwcontroller for interfacing the neural network with an object conforming to a gird protocol. 

## Built with 

* [Kevin Coble's AI Toolbox](https://github.com/KevinCoble/AIToolbox) - The Swift neural network implimentation used
* [Swift](https://github.com/apple/swift) - The excellent programming language used
* [XCode](https://developer.apple.com/xcode/) - The development environment and simulator used 