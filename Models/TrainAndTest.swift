//
//  TrainAndTest.swift
//
//  Created by Duncan Stothers.
//

import Foundation
import AIToolbox

// MARK: Test set - initialized on app startup
var X = [[Double]]()
var Y = [Double]()
var GOLDataSet = DataSet(dataType: .classification, inputDimension: 9, outputDimension: 1)

// MARK: Training / testing functions for Kevin
// Trains the network
func trainKevin() {
    
    //Train kevin
    let batchSize = StandardEngine.Singleton.localX.count
    let epochCount: Int = 400
    let trainingRate = 7.0
    let weightDecay = 10.0
    
    print("Training NN")
    do {
        try StandardEngine.Singleton.neuralNetwork.classificationSGDBatchTrain(StandardEngine.Singleton.localDataset, epochSize: batchSize, epochCount : epochCount, trainingRate: trainingRate, weightDecay: weightDecay)
    }
    catch {
        print("\(error)")
    }
    print("Neural Net trained")
}

// Tests the network, returns an (intelligence, experience) tuple
func testKevin() -> (Int,Int) {
    var correct = 0
    var wrong = 0
    for i in 0..<X.count {
        let groundTruth = Y[i]
        var prediction = StandardEngine.Singleton.neuralNetwork.predictOne(X[i]).first!
        if prediction >= 0.5 {
            prediction = 1.0
        }
        if prediction < 0.5 {
            prediction = 0
        }
        
        if prediction == groundTruth {
            correct += 1
        }
        
        if prediction != groundTruth {
            wrong += 1
        }
        
    }
    print("correct: \(correct)")
    print("wrong: \(wrong)")
    print(StandardEngine.Singleton.localX.count)
    return (Int((Float(correct) / 512.0) * 100.0), Int((Float(StandardEngine.Singleton.localX.count) / 512.0) * 100.0))
}
