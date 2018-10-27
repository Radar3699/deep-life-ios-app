//
//  NeuralNetwork.swift
//
//  Created by Duncan Stothers.
//

import Foundation
import AIToolbox

// MARK: Various helper functions for converting grids to vectors, colvolving, etc.
func convFilter(size: Int) -> [GridPosition] {
    if size % 2 == 1 {
        let convSize = size/2
        var out = [GridPosition]()
        for i in -convSize...convSize {
            for j in -convSize...convSize {
                out.append((row: 0 + i, col: 0 + j))
            }
        }
        return out
    }
    else {
        let lowerbound = size/2 - 1
        let upperbound = size/2
        var out = [GridPosition]()
        for i in -lowerbound...upperbound {
            for j in -lowerbound...upperbound {
                out.append((row: 0 + i, col: 0 + j))
            }
        }
        return out
    }
}

func convolution(_ grid: GridProtocol, pos: GridPosition, size: Int) -> Double {
    guard size % 2 == 1 else { return 0.0 }
    let area = Double(size * size)
    let offsets = convFilter(size: size)
    return offsets
        .map { grid[pos.row + $0.row, pos.col + $0.col] }
        .map { $0 == .alive ? 1.0 : 0.0 }
        .reduce(0.0) { $0 + $1 }
        * (1.0/area)
}

func gridToConvolutionVector(_ grid: GridProtocol, convSize: Int) -> [Double] {
    var out = [Double]()
    for i in 0..<grid.size.rows {
        for j in 0..<grid.size.cols {
            out.append(convolution(grid, pos: (row: i, col: j), size: convSize))
        }
    }
    return out
}

func gridFilter(grid: GridProtocol, pos: GridPosition, convSize: Int) -> GridProtocol {
    var out = Grid(convSize, convSize)
    let offsets = convFilter(size: convSize)
    offsets.forEach { if grid[pos.row + $0.row, pos.col + $0.col] == .alive { out[pos.row + $0.row,pos.col + $0.col] = .alive } }
    return out
}

func gridFilter523(grid: GridProtocol, pos: GridPosition) -> GridProtocol {
    var out = Grid(3,3)
    let offsets = convFilter(size: 3)
    var count = 0
    for i in 0...2 {
        for j in 0...2 {
            let step = offsets[count]
            if grid[pos.row + step.row, pos.col + step.col].isAlive {
                out[i,j] = .alive
            }
            count += 1
        }
    }
    return out
}

func gridToVector(_ grid: GridProtocol) -> [Double] {
    var out = [Double]()
    for i in 0..<grid.size.rows {
        for j in 0..<grid.size.cols {
            grid[i,j].isAlive ? out.append(1.0) : out.append(0.0)
        }
    }
    return out
}

func gridVecToScalar(_ gridVec: [Double]) -> Double {
    for i in 0..<gridVec.count {
        if gridVec[i] == 1.0 {
            return 1.0
        }
    }
    return 0.0
}

func gridVecTo3Grid(_ vec: [Double]) -> GridProtocol {
    var count = 0
    var out = Grid(3,3)
    for i in 0...2 {
        for j in 0...2 {
            if vec[count] == 1.0 {
                out[i,j] = .alive
            }
            count += 1
        }
    }
    return out
}

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

// Simulates 100 game steps
func sim100() {
    for _ in 1...100 {
        StandardEngine.Singleton.grid = StandardEngine.Singleton.step()
    }
}
