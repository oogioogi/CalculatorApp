//
//  ViewController.swift
//  CalculatorApp
//
//  Created by 이용석 on 2021/01/12.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calculatorCollectionView: UICollectionView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var calculatorHeightConstraint: NSLayoutConstraint!
    
    var firstNumber: String = ""
    var secondNumber: String = ""
    var calculatorStatus: CalculatorStatus = .none
    
    
    let numbers = [
        ["C","%","$","÷"],
        ["7","8","9","×"],
        ["4","5","6","-"],
        ["1","2","3","+"],
        ["0",".","="],
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        calculatorCollectionView.delegate = self
        calculatorCollectionView.dataSource = self
        calculatorCollectionView.register(CalculatorViewCell.self, forCellWithReuseIdentifier: "cellId")
        calculatorHeightConstraint.constant = view.frame.width * 1.4
        calculatorCollectionView.backgroundColor = .clear
        calculatorCollectionView.contentInset = .init(top: 0, left: 14, bottom: 0, right: 14)
        
        view.backgroundColor = .black
        
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = calculatorCollectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? CalculatorViewCell else { return UICollectionViewCell() }
        cell.numberLabel.text = self.numbers[indexPath.section][indexPath.row]
        
        self.numbers[indexPath.section][indexPath.row].forEach { (numberString) in
            // if "0" < numberString && "9" > numberString { } 범위 연산자
            if "0"..."9" ~= numberString || numberString.description == "." {
                cell.numberLabel.backgroundColor = .darkGray
            }else if numberString == "C" || numberString == "%" || numberString == "$" {
                cell.numberLabel.backgroundColor = UIColor(white: 1, alpha: 0.7)
                cell.numberLabel.textColor = .black
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let number = numbers[indexPath.section][indexPath.row]
        
        switch calculatorStatus {
        case .none:
            switch number {
            case "0"..."9":
                firstNumber += number
                self.numberLabel.text = firstNumber
                
                if firstNumber.hasPrefix("0") {
                    firstNumber = ""
                }
            case ".":
                if !confirmIncludeDecimalPoint(numberString: firstNumber) {
                    firstNumber += number
                    self.numberLabel.text = firstNumber
                }
            case "+":
                calculatorStatus = .plus
            case "-":
                calculatorStatus = .minus
            case "×":
                calculatorStatus = .multiple
            case "÷":
                calculatorStatus = .divide
            case "C":
                clear()
            default:
                break
            }
        case .plus, .minus, .multiple, .divide:
            switch number {
            case "0"..."9":
                secondNumber += number
                numberLabel.text = secondNumber
                
                if secondNumber.hasPrefix("0") {
                    secondNumber = ""
                }
                
            case ".":
                if !confirmIncludeDecimalPoint(numberString: secondNumber) {
                    secondNumber += number
                    self.numberLabel.text = secondNumber
                }
            case "=":
                let firstNum = Double(firstNumber) ?? 0
                let secondNum = Double(secondNumber) ?? 0
                var resultString: String?
                
                switch calculatorStatus {
                case .plus:
                    resultString = String(firstNum + secondNum)
                case .minus:
                    resultString = String(firstNum - secondNum)
                case .multiple:
                    resultString = String(firstNum * secondNum)
                case .divide:
                    resultString = String(firstNum / secondNum)
                default:
                    break
                }
                
                if let result = resultString, result.hasSuffix(".0") {
                    resultString = result.replacingOccurrences(of: ".0", with: "")
                }
                numberLabel.text = resultString
                firstNumber = ""
                secondNumber = ""
                
                firstNumber += resultString ?? ""
                calculatorStatus = .none
                
            case "C":
                clear()
            default:
                break
            }
        }
        
    }
    
    private func confirmIncludeDecimalPoint(numberString: String) -> Bool {
        if numberString.range(of: ".") != nil || numberString.count == 0 {
            return true
        }
        return false
    }
    
    func clear() {
        firstNumber = ""
        secondNumber = ""
        numberLabel.text = "0"
        calculatorStatus = .none
    }
    

}

enum CalculatorStatus {
    case none
    case plus
    case minus
    case multiple
    case divide
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0
        width = ((collectionView.frame.width - 10) - 14 * 5) / 4
        let height = width
        if indexPath.section == 4 && indexPath.row == 0 {
            width = width * 2 + 22
        }
        return .init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
}

class CalculatorViewCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                numberLabel.alpha = 0.3
            }else {
                numberLabel.alpha = 1.0
            }
        }
    }
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 32)
        label.clipsToBounds = true
        label.backgroundColor = .orange
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(numberLabel)
        
        numberLabel.frame.size = self.frame.size
        numberLabel.layer.cornerRadius = self.frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
