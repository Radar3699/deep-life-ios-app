//
//  Tests.swift
//
//  Created by Duncan Stothers.
//

import Foundation
import AIToolbox

// Tests that the neural network can learn a non-linearly seprepable function
func testXOR() {
    
    // Training data
    let trainData = DataSet(dataType: .classification, inputDimension: 2, outputDimension: 1)
    do {
        try trainData.addDataPoint(input: [0.0,0.0], dataClass:0)
        try trainData.addDataPoint(input: [1.0,0.0], dataClass:1)
        try trainData.addDataPoint(input: [0.0,1.0], dataClass:1)
        try trainData.addDataPoint(input: [1.0,1.0], dataClass:0)
    }
    catch {
        print("error creating training data")
    }
    
    
    // Initialize network
    var neuralNetwork : NeuralNetwork
    neuralNetwork = NeuralNetwork(numInputs: 2, layerDefinitions: [(layerType: .simpleFeedForward, numNodes: 2, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),(layerType: .simpleFeedForward, numNodes: 2, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
                                                                   (layerType: .simpleFeedForward, numNodes: 1, activation:NeuralActivationFunction.sigmoid, auxiliaryData: nil)])
    
    neuralNetwork.initializeWeights(nil)
    
    
    // Train network
    do {
        try neuralNetwork.classificationSGDBatchTrain(trainData, epochSize: trainData.size, epochCount : 10000, trainingRate: 3.0, weightDecay: 10.0)
        print("trained")
        print(neuralNetwork)
    }
    catch {
        print("\(error)")
    }
    
    print(neuralNetwork.predictOne([0.0,0.0]))
    print(neuralNetwork.predictOne([1.0,0.0]))
    print(neuralNetwork.predictOne([0.0,1.0]))
    print(neuralNetwork.predictOne([1.0,1.0]))
}

// Trains the neural network on a set of all possible (3,3) grids to test it can learn the game of life rules
func deterministicTrain() {
    let batchSize = 512
    let epochCount: Int = 1000
    let trainingRate = 10.0
    let weightDecay = 10.0
    
    
    print("Training NN")
    do {
        try StandardEngine.Singleton.neuralNetwork.classificationSGDBatchTrain(GOLDataSet, epochSize: batchSize, epochCount : epochCount, trainingRate: trainingRate, weightDecay: weightDecay)
    }
    catch {
        print("\(error)")
    }
    print("Neural Net trained")
}
