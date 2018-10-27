//
//  Initialize.swift
//
//  Created by Duncan Stothers.
//

import Foundation
import AIToolbox


// MARK: Initialization functions for the test set used during testing time for Kevin
func initializeX() {
    for a in 0...1 {
        for b in 0...1 {
            for c in 0...1 {
                for d in 0...1 {
                    for e in 0...1 {
                        for f in 0...1 {
                            for g in 0...1 {
                                for h in 0...1 {
                                    for i in 0...1 {
                                        X.append([Double(a),Double(b),Double(c),Double(d),Double(e),Double(f),Double(g),Double(h),Double(i)])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    print(X)
    print("size is \(X.count)")
}

func initializeY() {
    for i in 0..<X.count {
        let g = gridVecTo3Grid(X[i])
        let y = g.nextState(of: (row: 1, col: 1))
        y.isAlive ? Y.append(1.0) : Y.append(0.0)
    }
    print(Y)
    print("size is \(Y.count)")
}

func initializeGOLDataSet() {
    for i in 0..<Y.count {
        let input = X[i]
        do {
            if Y[i] == 1.0 {
                try GOLDataSet.addDataPoint(input: input, dataClass:1)
            }
            else {
                try GOLDataSet.addDataPoint(input: input, dataClass:0)
            }
        }
        catch {
            print("error creating GOL training data: \(error)")
        }
    }
}
