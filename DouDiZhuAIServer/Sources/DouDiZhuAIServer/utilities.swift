//
//  utilities.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

func parseCards(cards:[Card])->(numCards:[NumCard], jokerCards:[JokerCard], max:CardNum, min:CardNum, max_card_count: Int, card_count:[CardNum:Int]) {
    // convert all cards into its corresponding card type
    var numCards: [NumCard] = []
    var jokerCards: [JokerCard] = []
    for card in cards {
        if let converted_card = card as? NumCard {
            numCards.append(converted_card);
        } else {
            jokerCards.append(card as! JokerCard)
        }
    }
    
    var min: CardNum = CardNum.max, max: CardNum = CardNum.min, max_card_count = 0
    var card_count = [CardNum: Int]()
    for card in numCards {
        if card_count.keys.contains(card.getNum()) {
            card_count[card.getNum()] = 1 + card_count[card.getNum()]!
        } else {
            card_count[card.getNum()] = 1
        }
        if card_count[card.getNum()]! > max_card_count {
            max_card_count = card_count[card.getNum()]!
        }
        
        if card.getNum() < min {
            min = card.getNum()
        }
        if card.getNum() > max {
            max = card.getNum()
        }
    }
    
    return (numCards, jokerCards, max, min, max_card_count, card_count)
}

func suggestSPTPlay(playerCards: [Card], lastPlay: Play, play: PlayType)->[Card] {
    let lastPrimalCard = lastPlay.getPrimalCard()
    var remaining_cards:[Card] = []
    for card in playerCards {
        if lastPrimalCard is NullCard {
            remaining_cards.append(card)
        } else {
            if card is NumCard && lastPrimalCard is NumCard {
                let card_c = card as! NumCard
                if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {
                    remaining_cards.append(card)
                }
            } else if card > lastPrimalCard {
                remaining_cards.append(card)
            }
        }
    }
    if remaining_cards.count == 0 {
        return []
    }
    
    let playerCards_parsed = parseCards(cards: remaining_cards)
    var smallest_cards: [Card] = []
    var smallest_card_num: CardNum = CardNum(num: -1)
    let limit = play == .solo ? 0 : (play == .pair ? 1 : 2)
    
    var min_card_count: Int = 4
    for num in playerCards_parsed.card_count.values {
        if num > limit {
            min_card_count = min(min_card_count, num)
        }
    }
    
    if play == .solo && (min_card_count == 2 || remaining_cards.count == 1) && playerCards_parsed.jokerCards.count == 1 {
        return [playerCards_parsed.jokerCards[0]]
    }
    
    for card in playerCards_parsed.numCards {
        if smallest_card_num == card.getNum() && smallest_cards.count < limit + 1 {
            smallest_cards.append(card)
        } else if playerCards_parsed.card_count[card.getNum()]! == min_card_count {
            if smallest_cards.count == 0 || card.getNum() < smallest_card_num {
                smallest_cards = [card]
                smallest_card_num = card.getNum()
            }
        }
    }
    
    return smallest_cards
}

func findBomb(playerCards:[Card], lastPlay: Play)->[Card] {
    let limit = lastPlay.getPrimalCard()
    var remaining_cards: [NumCard] = []
    var remaining_joker_cards: [JokerCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if card > limit {
            remaining_cards.append(card as! NumCard)
        }
    }
    
    let playerCards_parsed = parseCards(cards: remaining_cards)
    
    if playerCards_parsed.max_card_count < 4 {
        if remaining_joker_cards.count < 2 {
            return []
        } else {
            return remaining_joker_cards
        }
    }
    
    var bomb:[Card] = []
    var i = 0
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - i - 1]
        if playerCards_parsed.card_count[card.getNum()]! == 4 {
            bomb.append(card)
            bomb.append(remaining_cards[remaining_cards.count - i - 2])
            bomb.append(remaining_cards[remaining_cards.count - i - 3])
            bomb.append(remaining_cards[remaining_cards.count - i - 4])
            break
        }
        i += playerCards_parsed.card_count[card.getNum()]!
    }
    
    return bomb
}

func suggestTrioPlusPlay(playerCards: [Card], lastPlay: Play)->[Card] {
    let suggestedTrio = suggestSPTPlay(playerCards: playerCards, lastPlay: lastPlay, play: .trio)
    if suggestedTrio.count == 0 {
        return []
    }
    
    var leftCards: [Card] = []
    for i in 0..<playerCards.count {
        var isInSuggestedCard = false
        for card in suggestedTrio {
            if card == playerCards[i] {
                isInSuggestedCard = true
            }
        }
        
        if !isInSuggestedCard {
            leftCards.append(playerCards[i])
        }
    }
    
    let suggestAddonCard = suggestSPTPlay(playerCards:leftCards, lastPlay: Play(), play: lastPlay.playType() == .trioPlusSolo ? .solo : .pair)
    if suggestAddonCard.count == 0 {
        return []
    }
    
    return suggestedTrio + suggestAddonCard
}

func suggestSoloChainPlay(playerCards: [Card], lastPlay: Play)->[Card] {
    let minLength = lastPlay.getSerialLength() > 4 ? lastPlay.getSerialLength() : 5
    let lastPrimalCard = lastPlay.getPrimalCard()
    var remaining_cards:[NumCard] = []
    
    for card in playerCards {
        if card is JokerCard {
            continue
        } else if lastPrimalCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {
                remaining_cards.append(card_c)
            }
        }
    }
    
    if remaining_cards.count < minLength {
        return []
    }
    
    remaining_cards.sort()
    var sugggestCards: [NumCard] = []
    var longestChain: [NumCard] = []
    for i in 0..<remaining_cards.count {
        var nextCardNum = -1
        if sugggestCards.count != 0 {
            nextCardNum = sugggestCards.last!.getNum().getNum() + 1
            if nextCardNum > 13 {
                nextCardNum = nextCardNum - 13
            }
        }
        if remaining_cards[remaining_cards.count - i - 1].getNum().getNum() == 2 {
            break
        } else if sugggestCards.count == 0 || remaining_cards[remaining_cards.count - i - 1].getNum().getNum() ==  nextCardNum {
            sugggestCards.append(remaining_cards[remaining_cards.count - i - 1])
            if lastPlay.playType() == .none {
                if sugggestCards.count > 4 && sugggestCards.count > longestChain.count {
                    longestChain = sugggestCards
                }
            } else {
                if sugggestCards.count == minLength {
                    return sugggestCards
                }
            }
            
        } else if remaining_cards[remaining_cards.count - i - 1].getNum() == sugggestCards.last!.getNum() {
            continue
        } else {
            sugggestCards = [remaining_cards[remaining_cards.count - i - 1]]
        }
    }
    
    return longestChain
}

func suggestPairChain(playerCards:[Card], lastPlay: Play)->[Card] {
    let minLength = lastPlay.getSerialLength() > 1 ? lastPlay.getSerialLength() : 3
    let lastPrimalCard = lastPlay.getPrimalCard()
    var remaining_cards:[NumCard] = []
    
    for card in playerCards {
        if card is JokerCard {
            continue
        } else if lastPrimalCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {
                remaining_cards.append(card_c)
            }
        }
    }
    
    if playerCards.count < minLength * 2 {
        return []
    }
    
    remaining_cards.sort()
    
    var sugggestCards: [NumCard] = []
    var longestChain: [NumCard] = []
    var i = 0
    while i < remaining_cards.count - 1 {
        var nextCardNum = -1
        if sugggestCards.count != 0 {
            nextCardNum = sugggestCards.last!.getNum().getNum() + 1
            if nextCardNum > 13 {
                nextCardNum = nextCardNum - 13
            }
        }
        
        if remaining_cards[remaining_cards.count - i - 1].getNum().getNum() == 2 {
            break
        } else if remaining_cards[remaining_cards.count - i - 1].getNum() == remaining_cards[remaining_cards.count - i - 2].getNum() {
            if sugggestCards.count != 0 && remaining_cards[remaining_cards.count - i - 1].getNum().getNum() != nextCardNum {
                sugggestCards = []
            }
            sugggestCards.append(remaining_cards[remaining_cards.count - i - 1])
            sugggestCards.append(remaining_cards[remaining_cards.count - i - 2])
            
            while i < remaining_cards.count - 1 && remaining_cards[remaining_cards.count - i - 1].getNum() == remaining_cards[remaining_cards.count - i - 2].getNum() {
                i += 1
            }
            if lastPlay.playType() == .none {
                if sugggestCards.count > 5 && sugggestCards.count > longestChain.count {
                    longestChain = sugggestCards
                }
            } else {
                if sugggestCards.count == minLength * 2 {
                    return sugggestCards
                }
            }
        } else {
            sugggestCards = []
        }
        i += 1
    }
    
    return longestChain
}

func suggestAirplanePlay(playerCards: [Card], lastPlay: Play) -> [Card] {
    let lastPrimalCard = lastPlay.getPrimalCard()
    let numTrioCard: Int = lastPlay.getSerialLength()
    var remaining_cards:[NumCard] = []
    var remaining_joker_cards: [JokerCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if lastPrimalCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {
                remaining_cards.append(card_c)
            }
        }
    }
    
    var numAirplane: Int = 0, curAirplane: [NumCard] = []
    var maxAirplane: Int = 0, longestAirplane: [NumCard] = []
    var suggestAddOnCard: [Card] = []
    var playerCard_parsed = parseCards(cards: remaining_cards)
    remaining_cards.sort()
    var i = 0;
    while true {
        if i >= remaining_cards.count {
            break
        }
        let card = remaining_cards[remaining_cards.count - 1 - i]
        if card.getNum() == 2 {
            break
        }
        if playerCard_parsed.card_count[card.getNum()]! > 2 {
            var nextCardNum = -1
            if curAirplane.count != 0 {
                nextCardNum = curAirplane.last!.getNum().getNum() + 1
                if nextCardNum > 13 {
                    nextCardNum = nextCardNum - 13
                }
            }
            
            if card.getNum() != nextCardNum {
                curAirplane = []
                numAirplane = 0
            }
            
            curAirplane.append(card)
            curAirplane.append(remaining_cards[remaining_cards.count - 2 - i])
            curAirplane.append(remaining_cards[remaining_cards.count - 3 - i])
            numAirplane += 1
            
            i += playerCard_parsed.card_count[card.getNum()]! - 1
            
            if numAirplane > 1 {
                if curAirplane.count > longestAirplane.count {
                    maxAirplane = numAirplane
                    longestAirplane = curAirplane
                }
                if !(lastPrimalCard is NullCard) && numAirplane == numTrioCard {
                    break
                }
            }
        }
        i += 1
    }
    
    if !(lastPrimalCard is NullCard) {
        if numAirplane == numTrioCard {
            if lastPlay.playType() == .airplane {
                return longestAirplane
            }
        } else {
            return []
        }
    } else {
        if maxAirplane < 2 {
            return []
        }
    }
    
    for card in longestAirplane {
        for i in 0..<remaining_cards.count {
            if card.getIdentifier() == remaining_cards[i].getIdentifier() {
                remaining_cards.remove(at: i)
                break
            }
        }
    }
    
    if lastPrimalCard is NullCard && remaining_cards.count + remaining_joker_cards.count < maxAirplane && maxAirplane < 5 {
        return longestAirplane
    }
    
    if maxAirplane == 5 {
        if remaining_cards.count == 5 {
            return playerCards
        } else {
            remaining_cards.append(longestAirplane.popLast()!)
            remaining_cards.append(longestAirplane.popLast()!)
            remaining_cards.append(longestAirplane.popLast()!)
            remaining_cards.sort()
            
            for i in 0..<maxAirplane - 1 {
                suggestAddOnCard.append(remaining_cards[i])
            }
            return suggestAddOnCard + longestAirplane
        }
    } else if maxAirplane == 6 {
        if remaining_cards.count == 1 {
            return longestAirplane
        } else {
            return playerCards
        }
    }
    
    var currentSolo:[Card] = [], currentPair:[Card] = [], currentTrio:[Card] = [], currentBomb:[Card] = []
    i = 0
    playerCard_parsed = parseCards(cards: remaining_cards)
    remaining_cards.sort()
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - 1 - i]
        
        if lastPlay.playType() == .airplanePlusPair {
            if playerCard_parsed.card_count[card.getNum()]! % 2 == 2 {
                suggestAddOnCard.append(card)
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 2 - i])
                i += 1
                if suggestAddOnCard.count / 2 == numTrioCard {
                    return longestAirplane + suggestAddOnCard
                }
            } else if playerCard_parsed.card_count[card.getNum()]! % 2 == 4 {
                suggestAddOnCard.append(card)
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 2 - i])
                if suggestAddOnCard.count / 2 == numTrioCard {
                    return longestAirplane + suggestAddOnCard
                }
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 3 - i])
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 4 - i])
                i += 3
                if suggestAddOnCard.count / 2 == numTrioCard {
                    return longestAirplane + suggestAddOnCard
                }
            }
        } else if lastPlay.playType() == .airplanePlusSolo {
            var j = 0
            while j < playerCard_parsed.card_count[card.getNum()]! {
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 1 - j - i])
                if suggestAddOnCard.count == numTrioCard {
                    return longestAirplane + suggestAddOnCard
                }
                j += 1
            }
            i += j
        } else {
            if playerCard_parsed.card_count[card.getNum()]! == 1 {
                currentSolo.append(card)
            } else if playerCard_parsed.card_count[card.getNum()]! == 2 {
                currentPair.append(card)
                currentPair.append(remaining_cards[remaining_cards.count - 2 - i])
                i += 1
            } else if playerCard_parsed.card_count[card.getNum()]! == 3 {
                currentTrio.append(card)
                currentTrio.append(remaining_cards[remaining_cards.count - 2 - i])
                currentTrio.append(remaining_cards[remaining_cards.count - 3 - i])
                i += 2
            } else {
                currentBomb.append(card)
                currentBomb.append(remaining_cards[remaining_cards.count - 2 - i])
                currentBomb.append(remaining_cards[remaining_cards.count - 3 - i])
                currentBomb.append(remaining_cards[remaining_cards.count - 4 - i])
                i += 3
            }
            
            if currentPair.count / 2 == maxAirplane {
                return longestAirplane + currentPair
            }
        }
        i += 1
    }
    
    if lastPrimalCard is NullCard {
        if currentSolo.count < maxAirplane {
            currentSolo += currentPair
        }
        if currentSolo.count < maxAirplane {
            currentSolo += currentTrio
        }
        if currentSolo.count < maxAirplane {
            currentSolo += currentBomb
        }
        
        currentSolo.sort()
        i = 0
        while i < maxAirplane {
            suggestAddOnCard.append(currentSolo.popLast()!)
            i += 1
        }
        return longestAirplane + suggestAddOnCard
    } else if lastPlay.playType() == .airplanePlusSolo {
        if remaining_joker_cards.count == numTrioCard - suggestAddOnCard.count {
            var cards: [Card] = []
            cards += suggestAddOnCard
            for card in longestAirplane {
                cards.append(card)
            }
            for card in remaining_joker_cards {
                cards.append(card)
            }
            return cards
        }
    }
    return []
}

func suggestBombPlusPlay(playerCards: [Card], lastPlay: Play)->[Card] {
    let lastPrimalCard = lastPlay.getPrimalCard()
    
    var remaining_cards:[NumCard] = []
    var remaining_joker_cards: [JokerCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if lastPrimalCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {remaining_cards.append(card_c)
            }
        }
    }
    
    var playerCard_parsed = parseCards(cards: remaining_cards)
    if playerCard_parsed.max_card_count < 4 {
        return []
    }
    
    var bomb:[Card] = [], addOn:[Card] = []
    remaining_cards.sort()
    var i = 0
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - i - 1]
        
        if playerCard_parsed.card_count[card.getNum()]! == 4 {
            bomb.append(card)
            bomb.append(remaining_cards[remaining_cards.count - i - 2])
            bomb.append(remaining_cards[remaining_cards.count - i - 3])
            bomb.append(remaining_cards[remaining_cards.count - i - 4])
            remaining_cards.remove(at: remaining_cards.count - i - 1)
            remaining_cards.remove(at: remaining_cards.count - i - 1)
            remaining_cards.remove(at: remaining_cards.count - i - 1)
            remaining_cards.remove(at: remaining_cards.count - i - 1)
            break
        }
        i += 1
    }
    
    var soloArr: [Card] = [], pairArr: [Card] = [], trioArr: [Card] = [], bombArr: [Card] = []
    playerCard_parsed = parseCards(cards: remaining_cards)
    remaining_cards.sort()
    i = 0
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - 1 - i]
        
        if lastPrimalCard is NullCard {
            if playerCard_parsed.card_count[card.getNum()]! == 1 {
                if soloArr.count < 2 {
                    soloArr.append(card)
                }
            } else if playerCard_parsed.card_count[card.getNum()]! == 2 {
                pairArr.append(card)
                pairArr.append(remaining_cards[remaining_cards.count - 2 - i])
                i += 1
                if pairArr.count == 4 {
                    return bomb + pairArr
                }
            } else if playerCard_parsed.card_count[card.getNum()]! == 3 {
                trioArr.append(card)
                trioArr.append(remaining_cards[remaining_cards.count - 2 - i])
                trioArr.append(remaining_cards[remaining_cards.count - 3 - i])
                i += 2
            } else {
                bombArr.append(card)
                bombArr.append(remaining_cards[remaining_cards.count - 2 - i])
                bombArr.append(remaining_cards[remaining_cards.count - 3 - i])
                bombArr.append(remaining_cards[remaining_cards.count - 4 - i])
            }
        } else {
            if lastPlay.playType() == .bombPlusDualPair {
                if playerCard_parsed.card_count[card.getNum()]! % 2 == 2 {
                    addOn.append(card)
                    addOn.append(remaining_cards[remaining_cards.count - 2 - i])
                    i += 1
                    if addOn.count == 4 {
                        return bomb + addOn
                    }
                } else if playerCard_parsed.card_count[card.getNum()]! % 2 == 3 {
                    addOn.append(card)
                    addOn.append(remaining_cards[remaining_cards.count - 2 - i])
                    i += 2
                    if addOn.count == 4 {
                        return bomb + addOn
                    }
                } else if playerCard_parsed.card_count[card.getNum()]! % 2 == 4 {
                    addOn.append(card)
                    addOn.append(remaining_cards[remaining_cards.count - 2 - i])
                    if addOn.count == 4{
                        return bomb + addOn
                    }
                    addOn.append(remaining_cards[remaining_cards.count - 3 - i])
                    addOn.append(remaining_cards[remaining_cards.count - 4 - i])
                    
                    return bomb + addOn
                }
            } else if lastPlay.playType() == .bombPlusDualSolo {
                var j = 0
                while j < playerCard_parsed.card_count[card.getNum()]! {
                    addOn.append(remaining_cards[remaining_cards.count - 1 - j - i])
                    if addOn.count == 2 {
                        return bomb + addOn
                    }
                    j += 1
                }
                i += j
            }
        }
        i += 1
    }
    
    if !(lastPrimalCard is NullCard) {
        return []
    }
    
    if pairArr.count / 2 + trioArr.count / 3 > 1 {
        trioArr.sort()
        pairArr.append(trioArr.popLast()!)
        pairArr.append(trioArr.popLast()!)
        return pairArr + bomb
    } else if bombArr.count > 0 {
        return bombArr + bomb
    }
    
    soloArr += pairArr
    soloArr.sort()
    addOn = []
    addOn.append(soloArr.popLast()!)
    addOn.append(soloArr.popLast()!)
    
    return bomb + addOn
}

func suggestSpaceShuttlePlay(playerCards: [Card], lastPlay: Play) -> [Card] {
    let lastPrimalCard = lastPlay.getPrimalCard()
    var remaining_cards:[NumCard] = []
    var remaining_joker_cards:[JokerCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if lastPrimalCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {
                remaining_cards.append(card_c)
            }
        }
    }
    
    remaining_cards.sort()
    var numShuttle: Int = 0, curShuttle: [NumCard] = []
    var maxShuttle: Int = 0, longestShuttle: [NumCard] = []
    var suggestAddOnCard: [Card] = []
    var playerCard_parsed = parseCards(cards: remaining_cards)
    if playerCard_parsed.max_card_count < 4 {
        return []
    }
    
    var i = 0;
    while true {
        if i >= remaining_cards.count {
            break
        }
        let card = remaining_cards[remaining_cards.count - 1 - i]
        if card.getNum() == 2 {
            break
        }
        if playerCard_parsed.card_count[card.getNum()]! > 3 {
            var nextCardNum = -1
            if curShuttle.count != 0 {
                nextCardNum = curShuttle.last!.getNum().getNum() + 1
                if nextCardNum > 13 {
                    nextCardNum = nextCardNum - 13
                }
            }
            if card.getNum().getNum() != nextCardNum {
                curShuttle = []
                numShuttle = 0
            }
            
            curShuttle.append(card)
            curShuttle.append(remaining_cards[remaining_cards.count - 2 - i])
            curShuttle.append(remaining_cards[remaining_cards.count - 3 - i])
            curShuttle.append(remaining_cards[remaining_cards.count - 4 - i])
            numShuttle += 1
            
            i += playerCard_parsed.card_count[card.getNum()]! - 1
            
            if numShuttle > 1 {
                if curShuttle.count > longestShuttle.count {
                    maxShuttle = numShuttle
                    longestShuttle = curShuttle
                }
                if !(lastPrimalCard is NullCard) && numShuttle == lastPlay.getSerialLength() {
                    break
                }
            }
        }
        i += 1
    }
    
    if numShuttle < lastPlay.getSerialLength() {
        return []
    }
    if !(lastPrimalCard is NullCard) {
        if numShuttle == lastPlay.getSerialLength() {
            if lastPlay.playType() == .spaceShuttle {
                return longestShuttle
            }
        }
    }
    
    for card in longestShuttle {
        for i in 0..<remaining_cards.count {
            if card.getIdentifier() == remaining_cards[i].getIdentifier() {
                remaining_cards.remove(at: i)
                break
            }
        }
    }
    
    if lastPrimalCard is NullCard && remaining_cards.count + remaining_joker_cards.count < maxShuttle * 2 {
        return longestShuttle
    }
    
    var currentSolo:[Card] = [], currentPair:[Card] = [], currentTrio:[Card] = [], currentBomb:[Card] = []
    i = 0
    playerCard_parsed = parseCards(cards: remaining_cards)
    remaining_cards.sort()
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - 1 - i]
        
        if lastPlay.playType() == .spaceShuttlePlusFourPair {
            if playerCard_parsed.card_count[card.getNum()]! % 2 == 2 {
                suggestAddOnCard.append(card)
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 2 - i])
                i += 1
                if suggestAddOnCard.count == lastPlay.getSerialLength() * 4 {
                    return longestShuttle + suggestAddOnCard
                }
            } else if playerCard_parsed.card_count[card.getNum()]! % 2 == 4 {
                suggestAddOnCard.append(card)
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 2 - i])
                if suggestAddOnCard.count == lastPlay.getSerialLength() * 4 {
                    return longestShuttle + suggestAddOnCard
                }
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 3 - i])
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 4 - i])
                i += 3
                if suggestAddOnCard.count == lastPlay.getSerialLength() * 4 {
                    return longestShuttle + suggestAddOnCard
                }
            }
        } else if lastPlay.playType() == .spaceShuttlePlusFourSolo {
            var j = 0
            while j < playerCard_parsed.card_count[card.getNum()]! {
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 1 - j - i])
                if suggestAddOnCard.count == lastPlay.getSerialLength() * 2 {
                    return longestShuttle + suggestAddOnCard
                }
                j += 1
            }
            i += j
        } else {
            if playerCard_parsed.card_count[card.getNum()]! == 1 {
                currentSolo.append(card)
            } else if playerCard_parsed.card_count[card.getNum()]! == 2 {
                currentPair.append(card)
                currentPair.append(remaining_cards[remaining_cards.count - 2 - i])
                i += 1
            } else if playerCard_parsed.card_count[card.getNum()]! == 3 {
                currentTrio.append(card)
                currentTrio.append(remaining_cards[remaining_cards.count - 2 - i])
                currentTrio.append(remaining_cards[remaining_cards.count - 3 - i])
                i += 2
            } else {
                currentBomb.append(card)
                currentBomb.append(remaining_cards[remaining_cards.count - 2 - i])
                currentBomb.append(remaining_cards[remaining_cards.count - 3 - i])
                currentBomb.append(remaining_cards[remaining_cards.count - 4 - i])
                i += 3
            }
            
            if currentPair.count == maxShuttle * 2 {
                return longestShuttle + currentPair
            }
        }
        i += 1
    }
    
    if lastPrimalCard is NullCard {
        if currentSolo.count < maxShuttle * 2 {
            currentSolo += currentPair
        }
        if currentSolo.count < maxShuttle * 2 {
            currentSolo += currentTrio
        }
        if currentSolo.count < maxShuttle * 2 {
            currentSolo += currentBomb
        }
        if currentSolo.count < maxShuttle * 2 {
            return []
        }
        
        currentSolo.sort()
        i = 0
        while i < maxShuttle * 2 {
            suggestAddOnCard.append(currentSolo.popLast()!)
            i += 1
        }
        return longestShuttle + suggestAddOnCard
    } else if lastPlay.playType() == .airplanePlusSolo {
        if remaining_joker_cards.count == numShuttle * 2 - suggestAddOnCard.count {
            var cards: [Card] = []
            cards += suggestAddOnCard
            for card in longestShuttle {
                cards.append(card)
            }
            for card in remaining_joker_cards {
                cards.append(card)
            }
            return cards
        }
    }
    return []
}

func suggestNewPlay(playerCards: [Card])->[Card] {
    let dummy = Play()
    var maxPlay: [Card] = []
    
    var curPlay: [Card] = []
    curPlay = suggestSpaceShuttlePlay(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count != 0 {
        maxPlay = curPlay
    }
    curPlay = suggestBombPlusPlay(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestAirplanePlay(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestPairChain(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSoloChainPlay(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestTrioPlusPlay(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = findBomb(playerCards: playerCards, lastPlay: dummy)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSPTPlay(playerCards: playerCards, lastPlay: dummy, play: PlayType.trio)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSPTPlay(playerCards: playerCards, lastPlay: dummy, play: PlayType.pair)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSPTPlay(playerCards: playerCards, lastPlay: dummy, play: PlayType.solo)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    
    return maxPlay
}

func suggestPlay(playerCards: [Card], lastPlay: Play)->[Card] {
    let currentPlay = lastPlay.playType()
    
    if currentPlay == .none {
        return suggestNewPlay(playerCards: playerCards)
    }
    
    var suggestedCards: [Card] = []
    switch currentPlay {
    case .solo, .pair, .trio:
        suggestedCards = suggestSPTPlay(playerCards: playerCards, lastPlay: lastPlay, play: currentPlay)
    case .soloChain:
        suggestedCards = suggestSoloChainPlay(playerCards: playerCards, lastPlay: lastPlay)
    case .pairChain:
        suggestedCards = suggestPairChain(playerCards: playerCards, lastPlay: lastPlay)
    case .trioPlusSolo, .trioPlusPair:
        suggestedCards = suggestTrioPlusPlay(playerCards: playerCards, lastPlay: lastPlay)
    case .airplane, .airplanePlusSolo, .airplanePlusPair:
        suggestedCards = suggestAirplanePlay(playerCards: playerCards, lastPlay: lastPlay)
    case .bombPlusDualSolo, .bombPlusDualPair:
        suggestedCards = suggestBombPlusPlay(playerCards: playerCards, lastPlay: lastPlay)
    case .spaceShuttle, .spaceShuttlePlusFourSolo, .spaceShuttlePlusFourPair:
        suggestedCards = suggestSpaceShuttlePlay(playerCards: playerCards, lastPlay: lastPlay)
    case .bomb:
        return findBomb(playerCards: playerCards, lastPlay: lastPlay)
    case .rocket: // nothing can be greater than rocket
        return []
    default:
        return []
    }
    
    if suggestedCards.count == 0 {
        return findBomb(playerCards: playerCards, lastPlay: Play())
    } else {
        return suggestedCards
    }
}

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            self.swapAt(i, j)
        }
    }
    
    mutating func sort() {
        if count < 2 { return }
        
        for i in 0..<(count - 1) {
            for j in i+1..<(count) {
                let card1 = self[i] as! Card
                let card2 = self[j] as! Card
                if card1 < card2 {
                    self.swapAt(i, j)
                }
            }
        }
    }
}
