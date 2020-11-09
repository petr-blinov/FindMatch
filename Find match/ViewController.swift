//
//  ViewController.swift
//  Find match
//
//  Created by Петр Блинов on 02.09.2020.
//  Copyright © 2020 Петр Блинов. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
    let model = CardMogel()
    var cardsArray = [Card]()
    
    var timer:Timer?
    var milliseconds:Int = 100 * 1000
    
    var firstFlippedCardIndex:IndexPath?
    
    var soundPlayer:SoundManager = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cardsArray = model.getCards()
        
        // Set the view controller as the data source and the delegate of the controller view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Initialize the timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Play shuffle sound
        soundPlayer.playSound(effect: .shuffle)
    }
    
    
    
    // MARK: - Timer methods
    
    @objc func timerFired() {
        
        // Decrement the counter
        milliseconds -= 1
        
        
        // Update the label
        let seconds:Double = Double(milliseconds)/1000.0
        timerLabel.text = String(format: "Time remaining: %.2f", seconds)
        
        // Stop the timer when it reaches zero
        if milliseconds == 0 {
            
            timerLabel.textColor = UIColor.red
            timer?.invalidate()
            
            // Check if the user has cleared all the pairs
            checkForGameEnd()

        }
        
    }
    
    
    
    // MARK: - Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return number of cards
        return cardsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Return it
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Configure the state of the cell based on the properties of the Card that it represents
        let cardCell = cell as? CardCollectionViewCell
        
        // Get the card from the card array
        let card = cardsArray[indexPath.row]
        
        // Finish configuring the cell
        cardCell?.configureCell(card: card)
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if there's any time remaining. Don't let the user interact if the time is 0
        
        if milliseconds <= 0 {
            return
        }
        
        // Get a reference to the cell that was tapped
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        
        // Check the status of the card to determine how to flip it
        if cell?.card?.isFlipped == false && cell?.card?.isMatched == false {
           
            // Flip the card up
            cell?.flipUp()
            
            // Play flip sound
            soundPlayer.playSound(effect: .flip)
            
            //Check if this is the first card that was fliped, or the second one
            if firstFlippedCardIndex == nil {
                
                // Nil - means this was the first card flipped over
                firstFlippedCardIndex = indexPath
            }
            else {
                // Means it was the second card flipped
                
                // Run the comparasion logic
                checkForMatch(indexPath)
                
                
            }
        }
    }
    
    
    //MARK: Game Logic Methods
    
    func checkForMatch(_ secondFlippedCardIndex:IndexPath) {
        
        // Get the two card objects for the two indexes and see if they match
        
        let cardOne = cardsArray[firstFlippedCardIndex!.row]
        let cardTwo = cardsArray[secondFlippedCardIndex.row]
        
        // Get the two collection view cells that represent card one and two
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        
        // Compare the two cards
        if cardOne.imageName == cardTwo.imageName {
            
            // It's a match
            
            // Play match sound
            soundPlayer.playSound(effect: .match)
            
            // Set the status and remove them
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Was that the last pair?
            checkForGameEnd()
            
        }
        else {
            
            // It's not a match
            
            // Play nomatch sound
            soundPlayer.playSound(effect: .nomatch)
            
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            
            // Flip them back over
            cardOneCell?.flipDown()
            cardTwoCell?.flipDown()
        }
        
        // Reset the firstFlippedCardIndex property
        firstFlippedCardIndex = nil
        
    }
    
    func checkForGameEnd() {
        
        // Check if there is any cards that is unmatched
        // Assume the user has won, loop through all the cards to see if all of them are matched
        var hasWon = true
        
        for card in cardsArray {
            
            if card.isMatched == false {
                // Means we've found a card that is unmatched
                hasWon = false
                break
            }
        }
        
        if hasWon == true {
            
            // User has won, show an alert
            showAlert(title: "You're the winner!", message: "Congratulations!")
            
            // And stop the timer
            timer?.invalidate()
        }
        else {
            // User hasn't won yet, check if there's any time left
            if milliseconds <= 0 {
                showAlert(title: "Time's Up!", message: "Better luck next time")
            }
        }
        
    }
    
    func showAlert(title:String, message:String) {
        
        // Create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a button for the user to restart the game
        let playAgainAction = UIAlertAction(title: "Play again", style: .default, handler: {action -> Void in self.resetApp()})
        
        alert.addAction(playAgainAction)
        
        // Show the alert
        present(alert, animated: true, completion: nil)
        
    }
    
    // Restart a game (by "Play again" button)
    
    func resetApp() {
        cardsArray = [Card]()
        cardsArray = model.getCards()
        milliseconds = 100 * 1000
        soundPlayer.playSound(effect: .shuffle)
        timerLabel.textColor = UIColor.black
        collectionView.reloadData()
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
}

