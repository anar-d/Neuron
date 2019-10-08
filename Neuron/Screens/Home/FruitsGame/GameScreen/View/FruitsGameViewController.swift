//
//  FruitsGameViewController.swift
//  Neuron
//
//  Created by Anar on 14/08/2019.
//  Copyright © 2019 Commodo. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol FruitsGameViewDelegate {
  var fruitsIsHidden: Bool { get set }
  
  var gamePassed: Bool? { get set }
  
  var gameFruits: [Fruits] { get set }
  var gameFruitsViews: [UIView] { get set }
  var menuFruitsViews: [UIView] { get set }
  
  var timer: Timer { get set }
  var minutes: Int { get set }
  var seconds: Int { get set }
  var milliseconds: Int { get set }
  
  var globalCurrentFruitIndex: Int { get set }
  var gameFruitsFillingJump: Int { get set }
  var gameFruitsFillingTerm: Int { get set }
  
  var popUp: FluidCardView? { get set }
  var visualEffectNavBarView: CustomIntensityVisualEffectView? { get set }
  var visualEffectView: CustomIntensityVisualEffectView? { get set }
  
  func makeRestartButtonImage()
  func makeNavBarTitle()
  func makeMenuElements(typesCount: Int)
  func makeGameFruits(typesCount: Int)
  func makeFruitMenuView()
  func makeTimerLabel()
  func makeStarsStackView(rate: Int)
  func startTimer(seconds: Int)
  func switchMenuFruitsViewsUserInteractionState(for views: [UIView])
  func clearFruits()
  
  func makeBlur()
  func makeRedCrosses()
  func changeTimerLabel()
  func invalidateTimer()
}

// MARK: - View
final class FruitsGameViewController: UIViewController, FruitsGameViewDelegate {
  var configurator = FruitsGameConfiguratorImplementation()
  var presenter: FruitsGamePresenterDelegate!
  
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var restartButton: UIBarButtonItem!
  @IBOutlet var stars: [UIImageView]!
  @IBOutlet weak var fruitsMenuView: UIImageView!

  static var levelNumber = 0

  var fruitsIsHidden = false
  
  var gamePassed: Bool? = nil

  var gameFruits      = [Fruits]()
  var gameFruitsViews = [UIView]()
  var menuFruitsViews = [UIView]()

  var timer        = Timer()
  var minutes      = 0
  var seconds      = 0
  var milliseconds = 0

  var globalCurrentFruitIndex = 0
  var gameFruitsFillingJump   = 7
  var gameFruitsFillingTerm   = 7

  var popUp: FluidCardView? = nil
  var visualEffectNavBarView: CustomIntensityVisualEffectView? = nil
  var visualEffectView: CustomIntensityVisualEffectView? = nil
}

// MARK: - FruitsGameViewController Life Cycle

extension FruitsGameViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configurator.configure(self)
    self.presenter.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if #available(iOS 13.0, *) {
      navigationController?.navigationBar.setNeedsLayout()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
//    self.presenter.viewDidDisappear()
  }
}

// MARK: - RestartNavBarButton

extension FruitsGameViewController {
  @IBAction func restartButton(_ sender: UIBarButtonItem) {
    self.presenter.restartGame()
  }
}

// MARK: - Timer

extension FruitsGameViewController {
  
  // MARK: - startTimer
  func startTimer(seconds: Int) {
    self.minutes = 0
    self.seconds = seconds
    self.milliseconds = 0
    self.timer = Timer.scheduledTimer(timeInterval: 1/60,
                                      target: self,
                                      selector: #selector(self.timerSelectorMethod),
                                      userInfo: nil,
                                      repeats: true)
  }
  
  // MARK: - @objc timer
  @objc func timerSelectorMethod() {
    if !self.fruitsIsHidden {
      self.milliseconds -= self.milliseconds > 0 ? 1 : 0
      
      let milliseconds = self.milliseconds < 10 ? "0\(self.milliseconds)" : "\(self.milliseconds)"
      
      self.timerLabel.text = "00.0\(self.seconds).\(milliseconds)"
      
      if self.seconds == 0 && self.milliseconds == 0 {
        self.fruitsIsHidden = true
        self.makeGrayCrosses()
        /*
         * Как только фрукты скрылись
         * даем пользователю возможность
         * вводить фрукты
         */
        self.switchMenuFruitsViewsUserInteractionState(for: self.menuFruitsViews)
        return
      }
      
      if self.milliseconds == 0 {
        self.seconds -= 1
        self.milliseconds = 60
      }
    } else {
      
      self.milliseconds += 1
      
      let minutes      = self.minutes < 10 ? "0\(self.minutes)" : "\(self.minutes)"
      let seconds      = self.seconds < 10 ? "0\(self.seconds)" : "\(self.seconds)"
      let milliseconds = self.milliseconds < 10 ? "0\(self.milliseconds)" : "\(self.milliseconds)"
      
      self.timerLabel.text = "\(minutes).\(seconds).\(milliseconds)"
      self.timerLabel.textColor = UIColor(red: 0.15, green: 0.24, blue: 0.32, alpha: 0.9)
      
      if self.milliseconds == 60 {
        self.seconds += 1
        self.milliseconds = 0
      }
      
      if self.seconds == 60 {
        self.minutes += 1
        self.seconds = 0
      }
      
      if self.minutes == 60 {
        self.invalidateTimer()
        self.makeRedCrosses()
        self.changeTimerLabel()
      }
    }
  }
  
  // MARK: - makeGrayCrosses
  func makeGrayCrosses() {
    self.gameFruitsViews.forEach { (fruitView) in
      let unsolvedFruitView = UIImageView()
      unsolvedFruitView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
      unsolvedFruitView.image = #imageLiteral(resourceName: "Неразгаданный фрукт")
      
      fruitView.backgroundColor = .clear
      fruitView.shadowOpacity   = 0
      fruitView.borderWidth     = 0
      fruitView.subviews.last?.isHidden = true
      fruitView.addSubview(unsolvedFruitView)
    }
  }
}

// MARK: - Customize

extension FruitsGameViewController {

  // MARK: - makeTimerLabel
  func makeTimerLabel() {
    self.timerLabel.textColor = UIColor(red: 0.92, green: 0.34, blue: 0.34, alpha: 0.9)
  }

  // MARL - makeRestartButtonImage
  func makeRestartButtonImage() {
    self.restartButton.image = #imageLiteral(resourceName: "Рестарт").withRenderingMode(.alwaysOriginal)
  }

  // MARK: - switchMenuFruitsViewsUserInteractionState
  func switchMenuFruitsViewsUserInteractionState(for views: [UIView]) {
    views.forEach { fruit in
      fruit.isUserInteractionEnabled = !fruit.isUserInteractionEnabled
    }
  }

  // MARK: - makeFruitMenuView
  func makeFruitMenuView() {
    let fruitMenuImage = FruitsGameViewController.levelNumber >= 1 && FruitsGameViewController.levelNumber <= 20 ? #imageLiteral(resourceName: "ФонФрукты1-20") : #imageLiteral(resourceName: "ФонФрукты21-50")
    self.fruitsMenuView.image = fruitMenuImage
  }

  // MARK: - makeNavBarTitle
  func makeNavBarTitle() {
    let navBarTitleFont      = UIFont(name: "NotoSans-Bold", size: 23)!
    let navBarTitleFontColor = UIColor(red: 0.15, green: 0.24, blue: 0.32, alpha: 0.9)

    self.navigationItem.title = "Level \(FruitsGameViewController.levelNumber)"
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: navBarTitleFont,
                                                                    NSAttributedString.Key.foregroundColor: navBarTitleFontColor]
  }

  // MARK: - makeMenuElements
  func makeMenuElements(typesCount: Int) {
    var mainStackView = UIStackView()

    for i in 0..<typesCount {
      let fruitView = Fruits.allCases[i].getFruitView(width: 59, height: 59)
      self.menuFruitsViews.append(fruitView)
    }

    self.menuFruitsViews.enumerated().forEach { (index, fruit) in
      self.addTapGesture(for: fruit, fruit: Fruits.allCases[index])
    }

    switch typesCount {
    case 3...6:
      let stackView          = UIStackView(arrangedSubviews: self.menuFruitsViews)
      stackView.axis         = .horizontal
      stackView.distribution = .equalSpacing

      mainStackView = stackView

      self.view.addSubview(mainStackView)

      var edgesConstraintsConstant: CGFloat

      switch typesCount {
      case 3, 4:
        edgesConstraintsConstant = 36
      case 5:
        edgesConstraintsConstant = 23
      case 6:
        edgesConstraintsConstant = 3
      default: return
      }

      let leadingConstraint = stackView.leadingAnchor.constraint(equalTo: fruitsMenuView.leadingAnchor, constant: edgesConstraintsConstant)
      let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: fruitsMenuView.trailingAnchor, constant: -edgesConstraintsConstant)

      stackView.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([leadingConstraint,
                                   trailingConstraint])
    case 7...12:
      let topStackView          = UIStackView(arrangedSubviews: Array(self.menuFruitsViews[0..<typesCount/2]))
      topStackView.axis         = .horizontal
      topStackView.distribution = .equalSpacing

      let bottomStackView          = UIStackView(arrangedSubviews: Array(self.menuFruitsViews[Int(typesCount/2)..<typesCount]))
      bottomStackView.axis         = .horizontal
      bottomStackView.distribution = .equalSpacing

      let stackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
      stackView.axis = .vertical
      stackView.spacing = 7

      mainStackView = stackView

      self.view.addSubview(mainStackView)

      var edgesConstraintsConstant: CGFloat

      switch typesCount {
      case 7, 8:
        edgesConstraintsConstant = 36
      case 9, 10:
        edgesConstraintsConstant = 23
      case 11, 12:
        edgesConstraintsConstant = 3
      default: return
      }

      let leadingConstraint = stackView.leadingAnchor.constraint(equalTo: fruitsMenuView.leadingAnchor, constant: edgesConstraintsConstant)
      let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: fruitsMenuView.trailingAnchor, constant: -edgesConstraintsConstant)

      stackView.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([leadingConstraint,
                                   trailingConstraint])
    default: return
    }

    mainStackView.topAnchor.constraint(equalTo: fruitsMenuView.topAnchor, constant: 21).isActive = true
  }
  
  // MARK: - makeGameFruits
  // FIXME: - Take in Fruits enum
  #warning("Take in Fruits enum")
  func makeGameFruits(typesCount: Int) {
    let fruitsTypes: [Fruits] = Array(Fruits.allCases[0..<typesCount])

    let preFruitsCount = FruitsGameViewController.levelNumber + 7
    let fruitsCount = preFruitsCount <= 53 ? preFruitsCount : 53

    var mainStackViewArrangedSubviews = [UIStackView]() // [gameFruitsStackSubviews]

    for i in getGameFruitsList {
      var intermediateGameFruits = [UIView]()

      // Создание вью фруктов
      for _ in 0..<i {
        let gameFruit = fruitsTypes.randomElement()
        let gameFruitView = gameFruit?.getFruitView(width: 40, height: 40)
        self.gameFruits.append(gameFruit!)
        self.gameFruitsViews.append(gameFruitView!)
        intermediateGameFruits.append(gameFruitView!)
      }

      // Create gameFruitsStackSubview
      let gameFruitsStackSubview = UIStackView(arrangedSubviews: intermediateGameFruits)
      gameFruitsStackSubview.axis = .horizontal
      gameFruitsStackSubview.spacing = 2

      // Add gameFruitsStackSubview in mainStackViewArrangedSubviews
      mainStackViewArrangedSubviews.append(gameFruitsStackSubview)
    }

    var groupedMainStackViewArrangedSubviews = [UIStackView]()

    // FIXME: - Take out in a separate function
    if fruitsCount % 9 == 0 {
      var alignment = UIStackView.Alignment.trailing

      for i in stride(from: 0, to: mainStackViewArrangedSubviews.count, by: 2) {
        let groupedStackView = UIStackView(arrangedSubviews: [mainStackViewArrangedSubviews[i], mainStackViewArrangedSubviews[i+1]])
        groupedStackView.axis = .vertical
        groupedStackView.alignment = alignment
        groupedStackView.spacing = 2

        groupedMainStackViewArrangedSubviews.append(groupedStackView)
        alignment = alignment == .trailing ? .leading : .trailing
      }
    } else {
      groupedMainStackViewArrangedSubviews.append(mainStackViewArrangedSubviews.first!)

      var alignment = UIStackView.Alignment.trailing

      for i in stride(from: 1, to: mainStackViewArrangedSubviews.count, by: 2) {
        let groupedStackView = UIStackView(arrangedSubviews: [mainStackViewArrangedSubviews[i], mainStackViewArrangedSubviews[i+1]])
        groupedStackView.axis = .vertical
        groupedStackView.alignment = alignment
        groupedStackView.spacing = 2

        groupedMainStackViewArrangedSubviews.append(groupedStackView)
        alignment = alignment == .trailing ? .leading : .trailing
      }
    }

    let mainStackView = UIStackView(arrangedSubviews: groupedMainStackViewArrangedSubviews)
    mainStackView.axis = .vertical
    mainStackView.spacing = 2
    mainStackView.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(mainStackView)

    NSLayoutConstraint.activate([mainStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                 mainStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20)])
  }

  // MARK: - var getGameFruitsList
  // [8, 1, 8, 1, 5]
  var getGameFruitsList: [Int] {
    var gameFruitsList = [Int]()
    let preFruitsCount = FruitsGameViewController.levelNumber + 7
    var fruitsCount = preFruitsCount <= 53 ? preFruitsCount : 53
    while fruitsCount >= 9 {
      fruitsCount -= 9
      gameFruitsList.append(contentsOf: [8, 1])
    }
    guard fruitsCount > 0 else { return gameFruitsList }
    gameFruitsList.append(fruitsCount)

    return gameFruitsList
  }

  // MARK: - makeStarsStackView
  func makeStarsStackView(rate: Int) {
    var stars = [UIImage]()

    for _ in 0..<rate {
      stars.append(#imageLiteral(resourceName: "БольшаяЗолотаяЗвезда"))
    }

    for _ in 0..<5 - rate {
      stars.append(#imageLiteral(resourceName: "БольшаяПустаяЗвезда"))
    }

    self.stars.enumerated().forEach { (index, view) in
      view.image = stars[index]
    }
  }
  
  // MARK: - clearFruits
  func clearFruits() {
    self.gameFruitsViews.forEach { (fruitView) in
      fruitView.removeFromSuperview()
    }
  }
}

// MARK: - Gesture

extension FruitsGameViewController {
  func addTapGesture(for view: UIView, fruit: Fruits) {
    var gestureAction: Selector? = nil

    switch fruit {
    case .apple:      gestureAction = #selector(appleSelector)
    case .banana:     gestureAction = #selector(bananaSelector)
    case .broccoli:   gestureAction = #selector(broccoliSelector)
    case .carrot:     gestureAction = #selector(carrotSelector)
    case .corn:       gestureAction = #selector(cornSelector)
    case .grape:      gestureAction = #selector(grapeSelector)
    case .lemon:      gestureAction = #selector(lemonSelector)
    case .onion:      gestureAction = #selector(onionSelector)
    case .orange:     gestureAction = #selector(orangeSelector)
    case .pear:       gestureAction = #selector(pearSelector)
    case .tomato:     gestureAction = #selector(tomatoSelector)
    case .watermelon: gestureAction = #selector(watermelonSelector)
    }

    let gesture = UITapGestureRecognizer(target: self, action: gestureAction)
    gesture.numberOfTapsRequired = 1
    view.addGestureRecognizer(gesture)
  }

  @objc func appleSelector()      { presenter.fillGameFruits(for: .apple) }

  @objc func bananaSelector()     { presenter.fillGameFruits(for: .banana) }

  @objc func broccoliSelector()   { presenter.fillGameFruits(for: .broccoli) }

  @objc func carrotSelector()     { presenter.fillGameFruits(for: .carrot) }

  @objc func cornSelector()       { presenter.fillGameFruits(for: .corn) }

  @objc func grapeSelector()      { presenter.fillGameFruits(for: .grape) }

  @objc func lemonSelector()      { presenter.fillGameFruits(for: .lemon) }

  @objc func onionSelector()      { presenter.fillGameFruits(for: .onion) }

  @objc func orangeSelector()     { presenter.fillGameFruits(for: .orange) }

  @objc func pearSelector()       { presenter.fillGameFruits(for: .pear) }

  @objc func tomatoSelector()     { presenter.fillGameFruits(for: .tomato) }

  @objc func watermelonSelector() { presenter.fillGameFruits(for: .watermelon) }
}

// MARK: - Blur/PopUp

extension FruitsGameViewController {
  
  // MARK: - makeBlur
  func makeBlur() {
    let blurEffect = UIBlurEffect(style: .light)

    // NavBar Blur
    let visualEffectNavBarView = CustomIntensityVisualEffectView(effect: blurEffect, intensity: 0.2)
    visualEffectNavBarView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectNavBarView.alpha = 0

    self.navigationController?.navigationBar.addSubview(visualEffectNavBarView)

    let topNavBarConstraint    = visualEffectNavBarView.topAnchor.constraint(equalTo: self.view.topAnchor)
    let rightNavBarConstraint  = visualEffectNavBarView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
    let bottomNavBarConstraint = visualEffectNavBarView.bottomAnchor.constraint(equalTo: self.navigationController!.navigationBar.bottomAnchor)
    let leftNavBarConstraint   = visualEffectNavBarView.leftAnchor.constraint(equalTo: self.view.leftAnchor)

    NSLayoutConstraint.activate([topNavBarConstraint,
                                 rightNavBarConstraint,
                                 bottomNavBarConstraint,
                                 leftNavBarConstraint])

    self.visualEffectNavBarView = visualEffectNavBarView

    // View Blur Without NavBar
    let visualEffectView = CustomIntensityVisualEffectView(effect: blurEffect, intensity: 0.2)
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.alpha = 0

    self.view.addSubview(visualEffectView)

    let topViewConstraint    = visualEffectView.topAnchor.constraint(equalTo: self.navigationController!.navigationBar.bottomAnchor)
    let rightViewConstraint  = visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
    let bottomViewConstraint = visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    let leftViewConstraint   = visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor)

    NSLayoutConstraint.activate([topViewConstraint,
                                 rightViewConstraint,
                                 bottomViewConstraint,
                                 leftViewConstraint])
    
    self.visualEffectView = visualEffectView

    UIView.animate(withDuration: 0.6, animations: {
      visualEffectNavBarView.alpha = 1
      visualEffectView.alpha = 1
    }, completion: { finished in
      self.makePopUp()
    })
  }

  // MARK: - makePopUp
  func makePopUp() {
    let popUp = FluidCardView(frame: CGRect(x: 0, y: 0, width: 297, height: 297))
    
    popUp.translatesAutoresizingMaskIntoConstraints = false
    
    let topView = PopUpTopView(frame: CGRect(x: 0, y: 0, width: 297, height: 189))
    let bottomView = PopUpBottomView(frame: CGRect(x: 0, y: 0, width: 297, height: 104))
    
    popUp.topContentView = topView
    popUp.bottomContentView = bottomView
    
    configurator.configure(topView)
    
    self.popUp = popUp
    
    view.addSubview(popUp)

    let topViewConstraint     = popUp.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 204)
    let widthViewConstraint   = popUp.widthAnchor.constraint(equalToConstant: 297)
    let centerXViewConstraint = popUp.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)

    NSLayoutConstraint.activate([topViewConstraint, widthViewConstraint, centerXViewConstraint])
  }

  // MARK: - makeRedCrosses
  func makeRedCrosses() {
    let preFruitsCount = FruitsGameViewController.levelNumber + 7
    let fruitsCount = preFruitsCount <= 53 ? preFruitsCount : 53
    let lastFruitsCount = fruitsCount - self.globalCurrentFruitIndex

    for _ in 0..<lastFruitsCount {
      var localCurrentFruitIndex = 0

      // Корректируем значение указателя (currentFruitIndex) так чтобы можно было двигаться по фруктам справа налево
      // Проверяем входит ли индекс текущего фрукта в диапазоны [9...16], [27...34], [45...52]
      print(self.globalCurrentFruitIndex, -7, self.gameFruitsFillingTerm)
      if [9, 27, 45].contains(self.globalCurrentFruitIndex - 7 + self.gameFruitsFillingTerm) {
        // В зависимости от оставшегося количества фруктов задаем размер прыжка
        if [9, 27, 45].contains(self.globalCurrentFruitIndex) {
          let preFruitsCount = FruitsGameViewController.levelNumber + 7
          let fruitsCount = preFruitsCount <= 53 ? preFruitsCount : 53
          let lastFruitsCount = fruitsCount - self.globalCurrentFruitIndex

          self.gameFruitsFillingJump = lastFruitsCount > 8 ? 7 : lastFruitsCount - 1
        }
        // Присваиваем currentFruitIndex нужное значение
        print(self.globalCurrentFruitIndex, self.gameFruitsFillingJump)
        localCurrentFruitIndex = self.globalCurrentFruitIndex + self.gameFruitsFillingJump
        // Уменьшаем шаг на 2 во всех случаях
        self.gameFruitsFillingJump -= 2
        // Чтобы не выходить за рамки [9...16], [27...34], [45...52] останавливаем вычитание в проверке выше
        self.gameFruitsFillingTerm -= self.gameFruitsFillingTerm > 0 ? 1 : 0
      } else if [17, 35].contains(self.globalCurrentFruitIndex) {
        // Присваиваем currentFruitIndex нужное значение
        localCurrentFruitIndex = self.globalCurrentFruitIndex
        // Установка значений
        self.gameFruitsFillingJump = 7
        self.gameFruitsFillingTerm = 7
      } else {
        // Присваиваем currentFruitIndex нужное значение
        localCurrentFruitIndex = self.globalCurrentFruitIndex
      }

//            print(localCurrentFruitIndex)

      print(localCurrentFruitIndex)
      let currentGameFruit = self.gameFruitsViews[localCurrentFruitIndex]

      let errorFruitView = UIImageView()
      errorFruitView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
      errorFruitView.image = #imageLiteral(resourceName: "Неправильный фрукт")

      currentGameFruit.subviews.last?.removeFromSuperview()
      currentGameFruit.addSubview(errorFruitView)

      self.globalCurrentFruitIndex += 1
    }

//        self.gameFruitsViews[self.globalCurrentFruitIndex...].forEach { (fruit) in
//            let errorFruitView = UIImageView()
//            errorFruitView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//            errorFruitView.image = #imageLiteral(resourceName: "Неправильный фрукт")
//
//            fruit.subviews.last?.removeFromSuperview()
//            fruit.addSubview(errorFruitView)
//        }
  }
  
  // MARK: - changeTimerLabel
  func changeTimerLabel() {
    self.timerLabel.text = "Wrong!"
    self.timerLabel.textColor = UIColor(red: 0.92, green: 0.34, blue: 0.34, alpha: 0.9)
  }

  // MARK: - invalidateTimer
  func invalidateTimer() {
    self.timer.invalidate()
  }
}
