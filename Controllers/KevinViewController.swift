//
//  KevinViewController.swift
//
//  Created by Duncan Stothers.
//

import UIKit
import AIToolbox

class KevinViewController: UIViewController, GridViewDelegate {
    
    @IBOutlet weak var IntelligenceLabel: UILabel!
    @IBOutlet weak var LifeExperienceLabel: UILabel!
    @IBOutlet weak var gridView: GridView!

    @IBAction func ResetKevinTapped(_ sender: Any) {
        //Resets the neural net powering kevin
        StandardEngine.Singleton.neuralNetwork = NeuralNetwork(numInputs: 9, layerDefinitions: [
            (layerType: .simpleFeedForward, numNodes: 16, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
            (layerType: .simpleFeedForward, numNodes: 16, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
            (layerType: .simpleFeedForward, numNodes: 1, activation:NeuralActivationFunction.sigmoid, auxiliaryData: nil)])
        StandardEngine.Singleton.neuralNetwork.initializeWeights(nil)
        StandardEngine.Singleton.localX = [[Double]]()
        StandardEngine.Singleton.localY = [Double]()
        StandardEngine.Singleton.localDataset = DataSet(dataType: .classification, inputDimension: 9, outputDimension: 1)
        StandardEngine.Singleton.intelligence = 0
        StandardEngine.Singleton.lifeExperience = 0
        IntelligenceLabel.text = "\(0) %"
        LifeExperienceLabel.text = "\(0) %"
    }
    
    @IBAction func StepButtonPressed(_ sender: Any) {
        //Step the grid using Kevin's learned intuition instead of the .step() function
        var newGrid = Grid(gridView.grid.size.rows,gridView.grid.size.cols)
        for i in 0..<gridView.grid.size.rows {
            for j in 0..<gridView.grid.size.cols {
                let input = gridToVector(gridFilter523(grid: gridView.grid, pos: (row: i, col: j)))
                let output = StandardEngine.Singleton.neuralNetwork.predictOne(input).first!
                print(output)
                if output >= 0.5 {
                    newGrid[i,j] = .alive
                }
                if output < 0.5 {
                    newGrid[i,j] = .empty
                }
            }
        }
        gridView.grid = newGrid
        gridView.setNeedsDisplay()
    }
    
    @IBAction func ResetButtonTapped(_ sender: Any) {
        gridView.grid = Grid(gridView.grid.size.rows,gridView.grid.size.cols)
        gridView.setNeedsDisplay()
    }
    
    func gridDidChange(grid: GridProtocol) {
        gridView.grid = grid as! Grid
        gridView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        IntelligenceLabel.text = "\(StandardEngine.Singleton.intelligence) %"
        LifeExperienceLabel.text = "\(StandardEngine.Singleton.lifeExperience) %"
    }

}
