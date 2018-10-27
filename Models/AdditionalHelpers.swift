//
//  AdditionalHelpers.swift
//
//  Created by Duncan Stothers.
//

import Foundation
import AIToolbox

// MARK: Additional helper functions and experiments.

// Tests the average long term life expectancy of random patterns
func calcLongTermLifeAverage() {
    let sampSize = 20
    let epochsPerRun = 50
    var count = 0
    
    for _ in 1...sampSize {
        let seed = arc4random_uniform(2)
        //clear grid
        StandardEngine.Singleton.grid = Grid(StandardEngine.Singleton.grid.size.rows,StandardEngine.Singleton.grid.size.cols)
        
        if seed == 1 {
            print("init random")
            //init random state
            for i in 0..<StandardEngine.Singleton.grid.size.rows {
                for j in 0..<StandardEngine.Singleton.grid.size.cols {
                    StandardEngine.Singleton.grid[i,j] = arc4random_uniform(2) == 1 ? .alive : .empty
                }
            }
        }
        
        if seed == 0 {
            print("init with fewer")
            //init rand state with fewer cells
            let numAlive = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.rows * StandardEngine.Singleton.grid.size.cols)))
            for _ in 1...(numAlive + 1) {
                let randCol = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.cols - 1)))
                let randRow = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.rows - 1)))
                if StandardEngine.Singleton.grid[randRow,randCol] == .empty {
                    StandardEngine.Singleton.grid[randRow,randCol] = .alive
                }
                
            }
        }
        
        //step through epochs
        for _ in 1...epochsPerRun {
            StandardEngine.Singleton.grid = StandardEngine.Singleton.step()
        }
        
        //calc num alive
        for i in 0..<StandardEngine.Singleton.grid.size.rows {
            for j in 0..<StandardEngine.Singleton.grid.size.cols {
                if StandardEngine.Singleton.grid[i,j] == .alive {
                    count += 1
                }
            }
        }
        print(count)
    }
    print("Average alive after \(epochsPerRun) epochs with sample size of \(sampSize) was \(Float(count) / Float(sampSize))")
}

// End to end test to see if can learn full-pattern predictability (fails for grids larger than 5x5)
func convolutionReinforcementAlgorithm() {
    //subNeural Net info
    let convolutionSize = 4 //must comply with nn
    let CnumInputs = 16
    let Clayer1 = 32
    //let Clayer2 = 10
    let CoutputLayer = 1
    let Theta : [[Double]] = [
        [-0.24624845727656849, -0.35297247396839648, -0.36332841460710458, -0.082921349911419098, 0.084720987075740189, -0.37539506089728891, 0.234666770894435, -0.41766160908239691, 0.013833718285406634, 0.047568717221156347, -0.082997512543587823, -0.12899836284878302, -0.41523095369322427, 0.32715315782013088, -0.0022727025019083471, -0.29240453378752346, -0.18248822647317242, -0.27322958877741593, -0.015293926119286939, -0.29631287293699787, 0.16856192048798938, -0.27595588104748514, 0.25076644344503773, 0.10122652629988456, 0.19403511559111711, -0.71645493321473031, -0.20234967981337995, -0.92869376259873582, -0.49171439632501218, -0.018654096535081453, 0.086684701712767515, -0.01786391864426343, 0.13802100152703189, -0.051796622384436025, 0.25890272531339587, -0.12151053099432881, 0.19861998873189868, -0.40294850396085191, -0.51971520991710562, 0.10501410988283841, -0.16742864311638725, 0.089368848282392319, 0.050356923332440219, -0.29806603051032082, -0.19567320519772252, -0.39564346461085426, 0.1273913048167275, 0.030100728413459472, -0.25604142035026672, -0.46026743620670546, -0.3565185126694787, 0.29992508361793802, -0.41039028607627154, 0.5613521793082874, -0.32419859324899275, -0.15097985023550156, 0.19924276275073707, 0.070005884083752482, -0.17111164776658924, -0.44179172998928362, -0.29812978639344218, -0.11711327018891697, -0.31358505696035965, -0.56321189724725318, -0.19913666212261671, 0.26378866143996965, -0.48323917961410057, -0.61536758632501987, 0.088660294966675351, -0.027181166919825188, -0.14513969012710487, -0.23354220392285083, -0.1242646470586822, -0.24881099709288759, -0.20197089650488098, -0.089704863852043293, -0.017099478679099701, -0.35113040868027268, 0.070110675020415111, -0.053067866512338198, -0.55987384530079698, -0.40517004639459087, -0.10860409574011701, -0.032515867272453418, -0.14184807790650936, -0.027212314590845145, -0.070151914753506753, 0.034119334687112299, -0.17087278656953114, 0.42319405023302209, 0.46111406194309862, 0.12666999555015226, 0.20577458908753535, -0.65491292135859835, -0.54930417208739546, -0.50333678897267797, 0.16506027781872659, -0.26806577523908637, -0.23002523003374167, -0.38105240182779476, -0.14024386783904191, -0.34375865221388802, -0.18933863032778175, 0.005151845841432294, 0.46484205177711119, -0.329309799937063, -0.71615890508288282, -0.042155733749231518, -0.2683042300140227, -0.12561114328385942, -0.62174770951359293, -0.29109984803290839, -0.14271838826138625, -0.47733025749614971, 0.13762284631296215, 0.1856845436472653, 0.42316218875926515, -0.39765875680832075, -0.48968135403949181, -0.45270516969828006, 0.18940628750214769, 0.12167843685971964, -0.099917081909162958, -0.15166479057283547, 0.017813284565379998, -0.48199985456680811, -0.14276852512743957, -0.10696088898008853, -0.17821625077362263, -0.088024368118199081, -0.19901447227348118, -0.45485901455243682, 0.092878340075316049, -0.33569879778319117, -0.19580916381522442, -0.18282883963539889, -0.067953232796114593, -0.097540921887151869, 0.032521690704940313, -0.40439828328439792, 1.1740890765230212, -0.03453255998831032, 0.51097004500054133, 0.012257693943374531, -0.47720159860937389, -1.0440472726536234, 0.15387708218723115, -0.59993965362303314, -0.38605496381107407, -1.0295871347275389, 0.17379919997727908, 0.10778662369385307, -0.6351666841759851, -1.2490044466692254, 0.090553262534656037, -0.27109396525205004, 0.31714422392970543, 0.83261765955907374, 1.9361847471781943, 0.41475637159873496, 0.61943460808761186, -1.0738219845620138, -0.18286766433568588, -0.46517430353789457, -0.23138451180139727, 0.31838329831778989, 0.8231393400203596, 0.31691152190538058, 1.4197340960883458, 0.37543105794291903, -0.18266259311184432, -0.30354707723510721, -0.1448687756129467, -0.08194918151778216, -0.57950478263312288, 0.073512116621742105, -0.39834451786867564, 0.19583221782918742, -0.39264293978429837, -0.091560665226987858, -0.26876347087370756, -0.21476897438790918, 0.0021552739885348218, -0.073376987240645369, 0.048657205258314663, 0.043612194897615093, -0.28139029022235129, 0.49420629282741196, -0.1194543201842842, -0.26171152304874529, 0.52807694957938989, -0.78548494278438485, 0.18116234805628337, -0.42262402302320934, -0.43974602443141458, 0.054655108072521122, -0.34133603371672744, -0.11855638055330529, -0.40356521518138982, -0.11593562879838268, -0.033514983735243378, 0.0047100533240875195, -0.58479353635479836, -0.31062846498040109, 0.37380004490019264, 0.19013795722798027, 0.42296057363313971, 0.17673967193835202, -0.49741764815630773, -0.091231934403494891, -0.20446341121196027, -0.056170818950431252, -0.2724504094100838, 0.021830389549032016, 0.013409415935912028, 0.24295949991915866, 0.28261886866498337, 0.19004501848528693, 0.24311766204702134, -0.52329580122171104, -0.48197425146481032, -0.44229637840291874, 0.020048812283796978, 0.047317399706349697, -0.14806572286766909, -0.54667120793413837, -0.32762534821337913, 0.044265416153698597, 0.17225012986743704, 0.10248692623537903, -0.54931829642752628, -0.045466358423319177, 0.24359404012246488, 0.028337710663482146, 0.074350126331124686, -0.052062845880289782, -0.22256978208260542, -0.82797060369882247, -0.32345066736648675, -0.3382877039386003, -0.65816011450533429, -0.10031729506074759, -0.40305664583613138, -0.20534074772328834, -0.1547016907286273, 0.0011028779029552092, 0.023837786910517956, 0.32789671311417706, 0.0062356308494482043, -0.27478514359617062, -0.059723868053589139, 0.42090509060106635, -0.30299801215705646, -0.054904377167339244, -0.39248762114918595, -0.80213421433375287, 0.5698824258274896, -0.72782549130125429, 0.28968996106460632, 0.29677939039344764, -0.24317392681633657, -0.37444374709651645, 0.15664381594935006, -0.2130905367642279, -0.13856824474526594, 0.24342061732498749, -0.063449308659764919, -0.26650890538896332, 0.22501894843800277, -0.95193479729055974, -0.018180455254976486, -0.28383609631290274, -0.28501190608174709, 0.18395482083877612, -0.041379795137894526, -0.25519746776596836, 0.11860375293768034, 0.25442518587657575, 0.12793296180779121, 0.30645592528701771, -0.40793591000132001, 0.12064842803866424, 0.37609258947267105, -0.095948944421058946, 0.84877608593871468, -0.44417907732311052, 0.16247993289231499, -1.0076168890017234, -0.77059359412024186, -0.48104726850509338, -0.26343178278853385, -0.037148130493559105, 0.60883839537113715, -0.38126222824699657, -0.044974540024874533, 0.12883663736439882, 0.13226965072762825, -0.13697756242995157, -0.27908106655329373, -0.043348187946083444, -0.2915053835500192, 0.21804525017466914, 0.15583742278738705, 0.23862091676863656, -0.0029847196425956245, -0.46425575448206524, -0.25302516189050062, -0.41492982624079106, -0.08087233598788697, -0.26447291026279068, -0.17923578628291981, 0.14830892704993504, -0.4912767217319452, 0.18164750825258302, -0.52104955402468323, -0.13078597548958243, -0.3234644316743463, -0.13302071778796445, 0.17493888271653099, 0.19836520758309978, 0.020710842246667371, -0.077838408880619644, -0.41547038033701872, -0.27234788342342264, 0.93071611317719716, 0.30287449410786804, 0.46575137636276287, -0.32939213606940848, -0.43730420211105703, -2.1291290148743856, -1.1099134286948624, 0.16025572658306136, 0.12956277606176286, 0.72883400810144394, 0.87087190646132451, -0.40550821867923859, 0.43719336195968844, -1.5323591383732262, -1.7848650408295095, -0.99255748904066055, -0.16586284694629319, 0.019883081284138952, 0.058802990418897132, -0.46821606298308516, -0.26306766292386657, -0.15510653059692722, -0.22547371313059203, 0.11373917497369544, -0.47877636770947407, -0.28850808043283888, -0.09210605315923473, -0.21745223680350848, 0.13967060201682135, -0.46893953736614769, -0.10198428464240929, 0.071018442336058502, -0.18588875122347617, -0.19858102437803593, -0.27048002968676066, -0.36563531699719609, -0.38486992220393079, 0.25616395356941923, -0.21612714295617397, -0.40844661458632942, -0.088067496505594423, -0.16243188125234459, -0.23381703107066618, 0.17389871453712841, -0.096181662760690248, 0.17252027766267866, -0.2495647800266311, -0.12270141363982434, -0.3073856280119357, -0.25544478431077444, -1.787606833237402, -0.49239194523393875, -1.3948248100906941, 0.0092209799326355719, 0.12890639237129886, 1.3691791668421101, -0.34199540126867278, -0.013573288817397569, -1.1539981200647915, 0.0023300712836554095, -1.4994362101430634, -0.10611704294940222, 0.39298696081275608, 0.43768412635013659, -0.82341271576489539, 1.4200654622877695, -1.0745493870714118, -0.063421830029868481, -0.33091581459464042, 0.25962923589755094, -0.56003697093947835, -0.61367565522473522, 0.046336728812336386, -0.10810506143232131, 0.34281850246577134, -0.80353695762908273, -0.016512780710041416, -0.31202001740518176, -0.89859590051936022, 0.11962569741050585, -0.79616422243109652, 0.61703545199985332, 0.32238712418571946, -0.2919864198695139, -0.51055207206119946, -0.06618124973437936, -0.3631888052361007, 0.67272399841747754, -0.22596147391713403, 1.1062633043290677, -0.19414482647049572, 0.27312193432656295, 0.0306941327083089, -0.09551403215885694, -0.3910833998971841, -0.16510753945020631, 0.51004794358955807, 0.24950739993647209, -0.034315460182497821, 0.13066966178395345, -0.072291367832891071, -0.098638358928108627, -0.38600515682808584, -0.32616912926206693, -0.22249328236674479, -0.458076622212086, -0.23043677854551731, 0.058467868107450499, -0.18942763060476531, 0.45842289965671251, -0.12669637108308937, 0.071131590105560402, -0.18811513524482198, -0.055703147754342403, 0.16176989935880082, -0.21907259860008629, -0.67384446440206747, -0.30953912248634163, -0.68949368386834431, -0.87674323955091182, -0.80615344324952753, -0.18480238850241038, 0.24708130309386034, -0.16498221569466795, 0.58368882675055611, -0.24086626173371087, 0.028740294311392838, -0.099251965615209339, 0.018381932367601543, -0.16401380526224685, 0.10808242312031066, -0.47783443849152302, 0.22557584400030112, 0.44998101635097265, -0.079501260133243948, -0.17775139637384449, 0.010372174157245036, -0.8127332543931467, 0.078049536676796344, 0.075659652037995392, 0.014364631483350229, -0.22251023239605375, -0.15139442804043554, 0.0065037716899114997, 0.16821827522738025, -0.3623871757606707, 0.05595202518925136, -0.12317687761171814, 0.16682892015265616, -0.28000091865811472, -0.19608207408173925, -0.49071294354541167, -0.32255038906592737, 0.15421002254473121, -0.25205007489958342, -0.31792511459551148, -0.49554939519667457, -0.50504295203175265, -0.6542910804011014, -0.33381457023232081, 0.16146133565528928, -0.26583387320675367, -0.31556631697777054, -0.10617410725839962, -0.056520486965908522, 0.013673307651268349, 0.30233542829924531, 0.2504609319767685, -0.49074593892565355, -0.14892990114325505, 0.1535309473427437, -0.15759132887923255, -0.1762397070864698, 0.094485359429035784, 0.019026818987600135, -0.11215075253188123, 0.087429044051704263, -0.21697914815102259, -0.37725795074546292, -0.1164369998290926, -0.58467738142917469, 0.38621662415856972, -0.090747684596599085, -0.10461267017571127, -0.32072858265341037, -0.52554568762101639, -1.5633025156864879, 0.51447725611034867, -0.3991908413388407, 0.56452800126322589, 0.84682074110605199, 0.76918320539881546, -0.17222449836736456, 0.11884860445125707, 0.55709367649857011, 0.19146870339607147, 0.73038765344484924, 0.51775082636102854, 0.46374468973498539, 0.078712840993200139, -0.92976341737593304, 0.84210523273111515, 0.34945877164092459, -0.11178966050862779, -0.35793637617402979, -0.066378274848998414, 0.27011471978406731, -0.37200452094838549, -0.2146489833161293, 0.11750265400144036, -0.16526092971596587, -0.55023911351995602, 0.31633426538105341, 0.032351137257916204, 0.038080500669822034, 0.24658963685145732, -0.50896058500977848, -0.00038584102033696176, -0.11517812079145565, -0.54346649052142149],
        
        [0.32598174241476435, 0.78766981403338421, 0.082450778914767278, 0.43334101973922684, 0.040104388644792918, 0.36162379652608251, 0.4629051983511559, 0.046633637824399984, 1.2500117260548664, -1.926639128445174, 0.27486918793995813, 0.32817648451341636, -0.46197512497696758, -0.35487050280427956, 0.24898785498186046, 0.80835731007846745, -0.56693827988506607, -0.12052687949605048, 0.15795109907755808, 2.6672215520774585, 0.26224200285664839, 0.0019178636665302326, 2.8098630091605141, 0.99871707260499964, -0.65286499623832239, 0.088480718404551587, 0.84656191498077715, 0.25228119387842729, -0.49351361806764221, 0.07493857276217715, -1.5521452456902782, -0.42940181040394121, 0.19176830337512465]
    ]
    
    //Grid info
    let gridSize: Int = 10
    
    //Neural net info
    let numInputs = 100
    let layer1 = 100
    //let layer2 = 10
    let outputLayer = 1
    
    //Dataset/Exploration info
    let explorationLength = 100
    
    //Training info
    let batchSize = 50
    let epochCount: Int = 1000
    let trainingRate = 10.0
    let weightDecay = 1.0
    
    //Testing info
    let threshold = 0.5
    
    //0. Initialize Subnet
    
    //Initialize network
    let nn = NeuralNetwork(numInputs: CnumInputs, layerDefinitions: [
        (layerType: .simpleFeedForward, numNodes: Clayer1, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        //(layerType: .simpleFeedForward, numNodes: Clayer2, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        (layerType: .simpleFeedForward, numNodes: CoutputLayer, activation:NeuralActivationFunction.sigmoid, auxiliaryData: nil)])
    
    //Initialize
    for i in 0..<nn.layers.count {
        nn.layers[i].initWeights(Theta[i])
    }
    
    StandardEngine.Singleton.neuralNetwork = NeuralNetwork(numInputs: numInputs, layerDefinitions: [
        (layerType: .simpleFeedForward, numNodes: layer1, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        //(layerType: .simpleFeedForward, numNodes: layer2, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        //(layerType: .simpleFeedForward, numNodes: layer3, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        (layerType: .simpleFeedForward, numNodes: outputLayer, activation:NeuralActivationFunction.sigmoid, auxiliaryData: nil)])
    
    let trainData = DataSet(dataType: .classification, inputDimension: (gridSize * gridSize), outputDimension: 1)
    StandardEngine.Singleton.neuralNetwork.initializeWeights(nil)
    
    print("1. Exploring statespace")
    //For every reinforcement cycle
    for i in 1...explorationLength {
        print("Exploring epoch: \(i) of \(explorationLength)")
        
        
        //Randomize grid
        let seed = arc4random_uniform(2)
        //clear grid
        StandardEngine.Singleton.grid = Grid(gridSize,gridSize)
        StandardEngine.Singleton.rows = gridSize
        StandardEngine.Singleton.cols = gridSize
        
        if seed == 1 {
            print("init random")
            //init random state
            for i in 0..<StandardEngine.Singleton.grid.size.rows {
                for j in 0..<StandardEngine.Singleton.grid.size.cols {
                    StandardEngine.Singleton.grid[i,j] = arc4random_uniform(2) == 1 ? .alive : .empty
                }
            }
        }
        
        if seed == 0 {
            print("init with fewer")
            //init rand state with fewer cells
            let numAlive = Int(arc4random_uniform(UInt32(13)))
            for _ in 1...(numAlive + 1) {
                let randCol = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.cols - 1)))
                let randRow = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.rows - 1)))
                if StandardEngine.Singleton.grid[randRow,randCol] == .empty {
                    StandardEngine.Singleton.grid[randRow,randCol] = .alive
                }
                
            }
        }
        
        
        /*
         //Randomize the grid
         StandardEngine.Singleton.grid = Grid(gridSize,gridSize)
         StandardEngine.Singleton.rows = gridSize
         StandardEngine.Singleton.cols = gridSize
         for i in 0..<StandardEngine.Singleton.grid.size.rows {
         for j in 0..<StandardEngine.Singleton.grid.size.cols {
         StandardEngine.Singleton.grid[i,j] = arc4random_uniform(UInt32(seed)) == 1 ? .alive : .empty
         }
         }
         */
        
        //Save the grid as convulved grid vector
        var convulvedGrid = [Double]()
        for i in 0..<StandardEngine.Singleton.rows {
            for j in 0..<StandardEngine.Singleton.cols {
                let smallGridVec = gridToVector(gridFilter(grid: StandardEngine.Singleton.grid, pos: (row: i, col: j), convSize: convolutionSize))
                
                let prediction = nn.predictOne(smallGridVec).first!
                convulvedGrid.append(prediction)
            }
        }
        
        let input = convulvedGrid
        
        var lastGrid = gridToVector(StandardEngine.Singleton.grid)
        //Step grid a lot
        for _ in 0...100 {
            StandardEngine.Singleton.grid = StandardEngine.Singleton.step()
            if gridToVector(StandardEngine.Singleton.grid) == lastGrid {
                break
            }
            lastGrid = gridToVector(StandardEngine.Singleton.grid)
        }
        
        //See if is alive
        let output = gridVecToScalar(gridToVector(StandardEngine.Singleton.grid))
        
        do {
            if output == 1.0 {
                try trainData.addDataPoint(input: input, dataClass:1)
            }
            else {
                try trainData.addDataPoint(input: input, dataClass:0)
            }
        }
        catch {
            print("error creating training data: \(error)")
        }
    }
    
    print("2. Training NN")
    do {
        try StandardEngine.Singleton.neuralNetwork.classificationSGDBatchTrain(trainData, epochSize: batchSize, epochCount : epochCount, trainingRate: trainingRate, weightDecay: weightDecay)
    }
    catch {
        print("\(error)")
    }
    print("Neural Net trained")
    
    var truePositives: Int = 0
    var falsePositives: Int = 0
    var trueNegatives: Int = 0
    var falseNegatives: Int = 0
    
    var posCount: Double = 0
    var posNum: Int = 0
    var negCount: Double = 0
    var negNum: Int = 0
    
    print("3. Computing F score and accuracy")
    for _ in 1...100 {
        
        //randomize grid
        let seed = arc4random_uniform(2)
        //clear grid
        StandardEngine.Singleton.grid = Grid(gridSize,gridSize)
        StandardEngine.Singleton.rows = gridSize
        StandardEngine.Singleton.cols = gridSize
        
        if seed == 1 {
            print("init random")
            //init random state
            for i in 0..<StandardEngine.Singleton.grid.size.rows {
                for j in 0..<StandardEngine.Singleton.grid.size.cols {
                    StandardEngine.Singleton.grid[i,j] = arc4random_uniform(2) == 1 ? .alive : .empty
                }
            }
        }
        
        if seed == 0 {
            print("init with fewer")
            //init rand state with fewer cells
            let numAlive = Int(arc4random_uniform(UInt32(13)))
            for _ in 1...(numAlive + 1) {
                let randCol = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.cols - 1)))
                let randRow = Int(arc4random_uniform(UInt32(StandardEngine.Singleton.grid.size.rows - 1)))
                if StandardEngine.Singleton.grid[randRow,randCol] == .empty {
                    StandardEngine.Singleton.grid[randRow,randCol] = .alive
                }
                
            }
        }
        
        
        /*
         //randomize grid
         StandardEngine.Singleton.grid = Grid(gridSize,gridSize)
         StandardEngine.Singleton.rows = gridSize
         StandardEngine.Singleton.cols = gridSize
         for i in 0..<StandardEngine.Singleton.grid.size.rows {
         for j in 0..<StandardEngine.Singleton.grid.size.cols {
         StandardEngine.Singleton.grid[i,j] = arc4random_uniform(UInt32(seed)) == 1 ? .alive : .empty
         }
         }
         */
        
        var convulvedGrid = [Double]()
        for i in 0..<StandardEngine.Singleton.rows {
            for j in 0..<StandardEngine.Singleton.cols {
                let smallGridVec = gridToVector(gridFilter(grid: StandardEngine.Singleton.grid, pos: (row: i, col: j), convSize: convolutionSize))
                
                let prediction = nn.predictOne(smallGridVec).first!
                convulvedGrid.append(prediction)
            }
        }
        
        var prediction = StandardEngine.Singleton.neuralNetwork.predictOne(convulvedGrid).first!
        
        if prediction >= threshold {
            posCount = posCount + prediction
            posNum += 1
            prediction = 1.0
            
        }
        if prediction < threshold {
            negCount = negCount + prediction
            negNum += 1
            prediction = 0.0
        }
        
        var lastGrid = gridToVector(StandardEngine.Singleton.grid)
        //Step grid a lot
        for _ in 0...100 {
            StandardEngine.Singleton.grid = StandardEngine.Singleton.step()
            if gridToVector(StandardEngine.Singleton.grid) == lastGrid {
                break
            }
            lastGrid = gridToVector(StandardEngine.Singleton.grid)
        }
        
        //See if is alive
        let output = gridVecToScalar(gridToVector(StandardEngine.Singleton.grid))
        
        if output == 1.0 && prediction == 1.0 {
            truePositives += 1
        }
        if output == 1.0 && prediction == 0.0 {
            falseNegatives += 1
        }
        if output == 0.0 && prediction == 0.0 {
            trueNegatives += 1
        }
        if output == 0.0 && prediction == 1.0 {
            falsePositives += 1
        }
    }
    
    let avgNeg = negCount / Double(negNum)
    let avgPos = posCount / Double(posNum)
    let F1: Float = (Float(truePositives)/(Float(truePositives) + Float(falseNegatives) + Float(falsePositives))) * 100.0
    let accuracy: Float = (Float(truePositives) + Float(trueNegatives)) / 10.0
    print("-----Results-----")
    print("Average negative output = \(avgNeg)")
    print("Average positive output = \(avgPos)")
    print("True positives = \(truePositives)")
    print("True negatives = \(trueNegatives)")
    print("False Positives = \(falsePositives)")
    print("False Negatives = \(falseNegatives)")
    print("F1 score is \(F1)")
    print("Accuracy is \(accuracy)")
}

// Tries to predict long term life expectancy of patters (fails for grids larger than 5x5)
func reinforcementAlgorithm() {
    //Grid info
    let gridSize: Int = 3
    
    //Neural Net info
    let numInputs = 9
    let layer1 = 9
    let outputLayer = 1
    
    //Dataset/Exploration info
    let explorationLength = 1000
    let seed = 2
    
    //Training info
    let batchSize = 500
    let epochCount: Int = 1000
    let trainingRate = 10.0
    let weightDecay = 10.0
    
    //Testing info
    let threshold = 0.5
    
    StandardEngine.Singleton.neuralNetwork = NeuralNetwork(numInputs: numInputs, layerDefinitions: [
        (layerType: .simpleFeedForward, numNodes: layer1, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        //(layerType: .simpleFeedForward, numNodes: layer2, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        //(layerType: .simpleFeedForward, numNodes: layer3, activation: NeuralActivationFunction.sigmoid, auxiliaryData: nil),
        (layerType: .simpleFeedForward, numNodes: outputLayer, activation:NeuralActivationFunction.sigmoid, auxiliaryData: nil)])
    
    
    let trainData = DataSet(dataType: .classification, inputDimension: (gridSize * gridSize), outputDimension: 1)
    StandardEngine.Singleton.neuralNetwork.initializeWeights(nil)
    
    print("1. Exploring statespace")
    //For every reinforcement cycle
    for i in 1...explorationLength {
        print("Exploring epoch: \(i) of \(explorationLength)")
        //Randomize the grid
        StandardEngine.Singleton.grid = Grid(gridSize,gridSize)
        StandardEngine.Singleton.rows = gridSize
        StandardEngine.Singleton.cols = gridSize
        for i in 0..<StandardEngine.Singleton.grid.size.rows {
            for j in 0..<StandardEngine.Singleton.grid.size.cols {
                StandardEngine.Singleton.grid[i,j] = arc4random_uniform(UInt32(seed)) == 1 ? .alive : .empty
            }
        }
        
        //Save the grid as vector
        let input = gridToVector(StandardEngine.Singleton.grid)
        
        var lastGrid = gridToVector(StandardEngine.Singleton.grid)
        //Step grid a lot
        for _ in 0...100 {
            StandardEngine.Singleton.grid = StandardEngine.Singleton.step()
            if gridToVector(StandardEngine.Singleton.grid) == lastGrid {
                break
            }
            lastGrid = gridToVector(StandardEngine.Singleton.grid)
        }
        
        //See if is alive
        let output = gridVecToScalar(gridToVector(StandardEngine.Singleton.grid))
        
        do {
            if output == 1.0 {
                try trainData.addDataPoint(input: input, dataClass:1)
            }
            else {
                try trainData.addDataPoint(input: input, dataClass:0)
            }
        }
        catch {
            print("error creating training data: \(error)")
        }
    }
    
    print("2. Training NN")
    do {
        try StandardEngine.Singleton.neuralNetwork.classificationSGDBatchTrain(trainData, epochSize: batchSize, epochCount : epochCount, trainingRate: trainingRate, weightDecay: weightDecay)
    }
    catch {
        print("\(error)")
    }
    print("Neural Net trained")
    
    var truePositives: Int = 0
    var falsePositives: Int = 0
    var trueNegatives: Int = 0
    var falseNegatives: Int = 0
    
    var posCount: Double = 0
    var posNum: Int = 0
    var negCount: Double = 0
    var negNum: Int = 0
    
    print("3. Computing F score and accuracy")
    for _ in 1...1000 {
        
        //randomize grid
        StandardEngine.Singleton.grid = Grid(gridSize,gridSize)
        StandardEngine.Singleton.rows = gridSize
        StandardEngine.Singleton.cols = gridSize
        for i in 0..<StandardEngine.Singleton.grid.size.rows {
            for j in 0..<StandardEngine.Singleton.grid.size.cols {
                StandardEngine.Singleton.grid[i,j] = arc4random_uniform(UInt32(seed)) == 1 ? .alive : .empty
            }
        }
        
        var prediction = StandardEngine.Singleton.neuralNetwork.predictOne(gridToVector(StandardEngine.Singleton.grid)).first!
        
        if prediction >= threshold {
            posCount = posCount + prediction
            posNum += 1
            prediction = 1.0
            
        }
        if prediction < threshold {
            negCount = negCount + prediction
            negNum += 1
            prediction = 0.0
        }
        
        var lastGrid = gridToVector(StandardEngine.Singleton.grid)
        //Step grid a lot
        for _ in 0...100 {
            StandardEngine.Singleton.grid = StandardEngine.Singleton.step()
            if gridToVector(StandardEngine.Singleton.grid) == lastGrid {
                break
            }
            lastGrid = gridToVector(StandardEngine.Singleton.grid)
        }
        
        //See if is alive
        let output = gridVecToScalar(gridToVector(StandardEngine.Singleton.grid))
        
        if output == 1.0 && prediction == 1.0 {
            truePositives += 1
        }
        if output == 1.0 && prediction == 0.0 {
            falseNegatives += 1
        }
        if output == 0.0 && prediction == 0.0 {
            trueNegatives += 1
        }
        if output == 0.0 && prediction == 1.0 {
            falsePositives += 1
        }
    }
    
    let avgNeg = negCount / Double(negNum)
    let avgPos = posCount / Double(posNum)
    let F1: Float = (Float(truePositives)/(Float(truePositives) + Float(falseNegatives) + Float(falsePositives))) * 100.0
    let accuracy: Float = (Float(truePositives) + Float(trueNegatives)) / 10.0
    print("-----Results-----")
    print("Average negative output = \(avgNeg)")
    print("Average positive output = \(avgPos)")
    print("True positives = \(truePositives)")
    print("True negatives = \(trueNegatives)")
    print("False Positives = \(falsePositives)")
    print("False Negatives = \(falseNegatives)")
    print("F1 score is \(F1)")
    print("Accuracy is \(accuracy)")
}
