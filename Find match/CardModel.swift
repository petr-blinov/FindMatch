//
//  CardModel.swift
//  Find match
//
//  Created by Петр Блинов on 02.09.2020.
//  Copyright © 2020 Петр Блинов. All rights reserved.
//

import Foundation

class CardMogel {
    
    func getCards() -> [Card] {
        
        // Declare an empty array to store all cards
        var generatedCards = [Card]()
        
        // and the array to store card numbers to prevent duplicates
        var generatedNumbers = [Int]()
        
        //Randomly generate 8 pairs of cards
        while generatedCards.count < 16 {
            
            //Create a random number
            let randomNumber = Int.random(in: 1...13)
            
            // check if it is not already exist
            if generatedNumbers.contains(randomNumber) == false {
            
                //Save number to array to prevent duplicates
                generatedNumbers += [randomNumber]
            
                //Create two new card objects
                let cardOne = Card()
                let cardTwo = Card()
            
                //Set their image names
                cardOne.imageName = "card\(randomNumber)"
                cardTwo.imageName = "card\(randomNumber)"
            
                //Add them to the array
                generatedCards += [cardOne, cardTwo]
                
                print(randomNumber)

            }
        }
        //Randomise the cards within the array
        generatedCards.shuffle()
        
        
        //Return the array
        return generatedCards
    }
}
