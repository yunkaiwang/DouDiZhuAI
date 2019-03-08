//
//  utilities.swift
//  COpenSSL
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
    
    var min: CardNum = CardNum(num: 2), max: CardNum = CardNum(num: 3), max_card_count = 0
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

func suggestSPTPlay(playerCards: [Card], lastPlayedCards: [Card], play: Play)->[Card] {
    if play != Play.solo && play != Play.pair && play != Play.trio {
        return []
    }
    
    var remaining_cards:[Card] = []
    for card in playerCards {
        if lastPlayedCards[0] is NullCard {
            remaining_cards.append(card)
        } else {
            if card is NumCard && lastPlayedCards[0] is NumCard {
                let card_c = card as! NumCard
                let lcard_c = lastPlayedCards[0] as! NumCard
                if card_c.getNum() > lcard_c.getNum() {
                    remaining_cards.append(card)
                }
            } else if card > lastPlayedCards[0] {
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
    let limit = play == Play.solo ? 0 : (play == Play.pair ? 1 : 2)
    
    var min_card_count: Int = 4
    for num in playerCards_parsed.card_count.values {
        if num > limit {
            min_card_count = min(min_card_count, num)
        }
    }
    
    if play == Play.solo && (min_card_count == 2 || remaining_cards.count == 1) && playerCards_parsed.jokerCards.count == 1 {
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

func findBomb(playerCards:[Card], lastBomb: [Card])->[Card] {
    let limit = lastBomb[0]
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

func suggestTrioPlusPlay(playerCards: [Card], play: Play, lastPlayedCards: [Card])->[Card] {
    if (play == Play.trioPlusPair && playerCards.count < 5) ||
        (play == Play.trioPlusSolo && playerCards.count < 4) {
        return []
    }
    
    var suggestedTrio: [Card] = []
    if lastPlayedCards[0] is NullCard {
        suggestedTrio = suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: Play.trio)
    } else {
        let lastPlayedCard_parsed = parseCards(cards: lastPlayedCards)
        var lastTrio: [Card] = []
        for card in lastPlayedCard_parsed.numCards {
            if lastPlayedCard_parsed.card_count[card.getNum()]! == 3 {
                lastTrio.append(card)
            }
        }
        
        suggestedTrio = suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastTrio, play: Play.trio)
    }
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
    
    let suggestAddonCard = suggestSPTPlay(playerCards:leftCards, lastPlayedCards: [NullCard.shared], play: play == Play.trioPlusSolo ? Play.solo : Play.pair)
    if suggestAddonCard.count == 0 {
        return []
    }
    
    return suggestedTrio + suggestAddonCard
}

func suggestSoloChainPlay(playerCards: [Card], lastPlayedCards: [Card])->[Card] {
    let min_card = lastPlayedCards.count > 4 ? lastPlayedCards.count : 5
    var remaining_cards:[NumCard] = []
    var smallestCard: Card = lastPlayedCards[0]
    for card in lastPlayedCards {
        if card < smallestCard {
            smallestCard = card
        }
    }
    
    for card in playerCards {
        if card is JokerCard {
            continue
        } else if smallestCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            let lcard_c = lastPlayedCards[0] as! NumCard
            if card_c.getNum() > lcard_c.getNum() {
                remaining_cards.append(card_c)
            }
        }
    }
    
    if remaining_cards.count < min_card {
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
            if lastPlayedCards[0] is NullCard {
                if sugggestCards.count > 4 && sugggestCards.count > longestChain.count {
                    longestChain = sugggestCards
                }
            } else {
                if sugggestCards.count == min_card {
                    return sugggestCards
                }
            }
            
        } else if remaining_cards[remaining_cards.count - i - 1].getNum().getNum() == sugggestCards.last!.getNum().getNum() {
            continue
        } else {
            sugggestCards = [remaining_cards[remaining_cards.count - i - 1]]
        }
    }
    
    return longestChain
}

func suggestPairChain(playerCards:[Card], lastPlayedCards: [Card])->[Card] {
    var remaining_cards:[NumCard] = []
    var smallestCard: Card = lastPlayedCards[0]
    for card in lastPlayedCards {
        if card < smallestCard {
            smallestCard = card
        }
    }
    
    for card in playerCards {
        if card is JokerCard {
            continue
        } else if smallestCard is NullCard {
            remaining_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            let lcard_c = lastPlayedCards[0] as! NumCard
            if card_c.getNum() > lcard_c.getNum() {
                remaining_cards.append(card_c)
            }
        }
    }
    
    let min_card = lastPlayedCards.count > 5 ? lastPlayedCards.count : 6
    if playerCards.count < min_card {
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
            
            while i < remaining_cards.count - 1 && remaining_cards[remaining_cards.count - i - 1].getNum().getNum() == remaining_cards[remaining_cards.count - i - 2].getNum().getNum() {
                i += 1
            }
            if lastPlayedCards[0] is NullCard {
                if sugggestCards.count > 5 && sugggestCards.count > longestChain.count {
                    longestChain = sugggestCards
                }
            } else {
                if sugggestCards.count == min_card {
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

func suggestAirplanePlay(playerCards: [Card], currentPlay: Play, lastPlayedCards: [Card]) -> [Card] {
    if currentPlay != Play.airplane && currentPlay != Play.airplanePlusSolo && currentPlay != Play.airplanePlusPair {
        return []
    }
    
    var numCardReq: Int;
    var numTrioCard: Int;
    switch currentPlay {
    case .airplane:
        numTrioCard = lastPlayedCards[0] is NullCard ? 2 : lastPlayedCards.count / 3
        numCardReq = max(6, lastPlayedCards.count)
    case .airplanePlusSolo:
        numTrioCard = lastPlayedCards[0] is NullCard ? 2 : lastPlayedCards.count / 4
        numCardReq = max(8, lastPlayedCards.count)
    default:
        numTrioCard = lastPlayedCards[0] is NullCard ? 2 : lastPlayedCards.count / 5
        numCardReq = max(10, lastPlayedCards.count)
    }
    
    
    var lastLargestAirplaneCard: Card?
    if lastPlayedCards[0] is NullCard {
        numCardReq = 6
        lastLargestAirplaneCard = nil
    } else {
        let lastPlayedCards_parsed = parseCards(cards: lastPlayedCards)
        for card in lastPlayedCards {
            if let card_c = card as? NumCard {
                if lastPlayedCards_parsed.card_count[card_c.getNum()]! > 2 {
                    if lastLargestAirplaneCard == nil || card > lastLargestAirplaneCard! {
                        lastLargestAirplaneCard = card
                    }
                }
            }
        }
    }
    
    var remaining_cards:[NumCard] = []
    var remaining_joker_cards: [JokerCard] = []
    var available_airplane_cards: [NumCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if lastLargestAirplaneCard == nil {
            available_airplane_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            let lcard_c = lastPlayedCards[0] as! NumCard
            if card_c.getNum() > lcard_c.getNum() {
                available_airplane_cards.append(card_c)
            } else {
                remaining_cards.append(card_c)
            }
        }
    }
    
    if remaining_joker_cards.count + remaining_cards.count + available_airplane_cards.count < numCardReq {
        return []
    }
    
    available_airplane_cards.sort()
    var numAirplane: Int = 0, curAirplane: [NumCard] = []
    var maxAirplane: Int = 0, longestAirplane: [NumCard] = []
    var suggestAddOnCard: [Card] = []
    var playerCard_parsed = parseCards(cards: available_airplane_cards)
    var i = 0;
    while true {
        if i >= available_airplane_cards.count {
            break
        }
        let card = available_airplane_cards[available_airplane_cards.count - 1 - i]
        if card.getNum().getNum() == 2 {
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
            
            if card.getNum().getNum() != nextCardNum {
                curAirplane = []
                numAirplane = 0
            }
            
            curAirplane.append(card)
            curAirplane.append(available_airplane_cards[available_airplane_cards.count - 2 - i])
            curAirplane.append(available_airplane_cards[available_airplane_cards.count - 3 - i])
            numAirplane += 1
            
            i += playerCard_parsed.card_count[card.getNum()]! - 1
            
            if numAirplane > 1 {
                if curAirplane.count > longestAirplane.count {
                    maxAirplane = numAirplane
                    longestAirplane = curAirplane
                }
                if !(lastPlayedCards[0] is NullCard) && numAirplane == numTrioCard {
                    break
                }
            }
        }
        i += 1
    }
    
    if !(lastPlayedCards[0] is NullCard) {
        if numAirplane == numTrioCard {
            if currentPlay == Play.airplane {
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
        for i in 0..<available_airplane_cards.count {
            if card.getIdentifier() == available_airplane_cards[i].getIdentifier() {
                available_airplane_cards.remove(at: i)
                break
            }
        }
    }
    
    remaining_cards += available_airplane_cards
    if lastPlayedCards[0] is NullCard && remaining_cards.count + remaining_joker_cards.count < maxAirplane && maxAirplane < 5 {
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
        
        if currentPlay == Play.airplanePlusPair {
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
        } else if currentPlay == Play.airplanePlusSolo {
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
    
    if lastPlayedCards[0] is NullCard {
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
    } else if currentPlay == Play.airplanePlusSolo {
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

func suggestBombPlusPlay(playerCards: [Card], currentPlay: Play, lastPlayedCards: [Card])->[Card] {
    if currentPlay != Play.bombPlusDualSolo && currentPlay != Play.bombPlusDualPair {
        return []
    }
    
    var lastLargestAirplaneCard: Card?
    if lastPlayedCards[0] is NullCard {
        lastLargestAirplaneCard = nil
    } else {
        let lastPlayedCards_parsed = parseCards(cards: lastPlayedCards)
        for card in lastPlayedCards {
            if let card_c = card as? NumCard {
                if lastPlayedCards_parsed.card_count[card_c.getNum()]! > 2 {
                    if lastLargestAirplaneCard == nil || card > lastLargestAirplaneCard! {
                        lastLargestAirplaneCard = card
                    }
                }
            }
        }
    }
    
    var remaining_cards:[NumCard] = []
    var remaining_joker_cards: [JokerCard] = []
    var available_bomb_cards: [NumCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if lastLargestAirplaneCard == nil {
            available_bomb_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            let lcard_c = lastPlayedCards[0] as! NumCard
            if card_c.getNum() > lcard_c.getNum() {
                available_bomb_cards.append(card_c)
            } else {
                remaining_cards.append(card_c)
            }
        }
    }
    
    var playerCard_parsed = parseCards(cards: available_bomb_cards)
    if playerCard_parsed.max_card_count < 4 {
        return []
    }
    
    var bomb:[Card] = [], addOn:[Card] = []
    
    available_bomb_cards.sort()
    var i = 0
    while i < available_bomb_cards.count {
        let card = available_bomb_cards[available_bomb_cards.count - i - 1]
        
        if playerCard_parsed.card_count[card.getNum()]! == 4 {
            bomb.append(card)
            bomb.append(available_bomb_cards[available_bomb_cards.count - i - 2])
            bomb.append(available_bomb_cards[available_bomb_cards.count - i - 3])
            bomb.append(available_bomb_cards[available_bomb_cards.count - i - 4])
            available_bomb_cards.remove(at: available_bomb_cards.count - i - 1)
            available_bomb_cards.remove(at: available_bomb_cards.count - i - 1)
            available_bomb_cards.remove(at: available_bomb_cards.count - i - 1)
            available_bomb_cards.remove(at: available_bomb_cards.count - i - 1)
            break
        }
        i += 1
    }
    
    var soloArr: [Card] = [], pairArr: [Card] = [], trioArr: [Card] = [], bombArr: [Card] = []
    remaining_cards += available_bomb_cards
    playerCard_parsed = parseCards(cards: remaining_cards)
    remaining_cards.sort()
    i = 0
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - 1 - i]
        
        if lastPlayedCards[0] is NullCard {
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
            if currentPlay == Play.airplanePlusPair {
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
            } else if currentPlay == Play.airplanePlusSolo {
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
    
    if !(lastPlayedCards[0] is NullCard) {
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

func suggestSpaceShuttlePlay(playerCards: [Card], currentPlay: Play, lastPlayedCards: [Card]) -> [Card] {
    if currentPlay != Play.spaceShuttle && currentPlay != Play.spaceShuttlePlusFourSolo && currentPlay != Play.spaceShuttlePlusFourPair {
        return []
    }
    
    var numShuttleNeed: Int;
    switch currentPlay {
    case .airplane:
        numShuttleNeed = lastPlayedCards[0] is NullCard ? 2 : lastPlayedCards.count / 8
    case .airplanePlusSolo:
        numShuttleNeed = lastPlayedCards[0] is NullCard ? 2 : lastPlayedCards.count / 12
    default:
        numShuttleNeed = lastPlayedCards[0] is NullCard ? 2 : lastPlayedCards.count / 16
    }
    
    var lastLargestAirplaneCard: Card?
    if lastPlayedCards[0] is NullCard {
        lastLargestAirplaneCard = nil
    } else {
        let lastPlayedCards_parsed = parseCards(cards: lastPlayedCards)
        for card in lastPlayedCards {
            if let card_c = card as? NumCard {
                if lastPlayedCards_parsed.card_count[card_c.getNum()]! > 2 {
                    if lastLargestAirplaneCard == nil || card > lastLargestAirplaneCard! {
                        lastLargestAirplaneCard = card
                    }
                }
            }
        }
    }
    
    var remaining_cards:[NumCard] = []
    var remaining_joker_cards: [JokerCard] = []
    var available_bomb_cards: [NumCard] = []
    for card in playerCards {
        if card is JokerCard {
            remaining_joker_cards.append(card as! JokerCard)
        } else if lastLargestAirplaneCard == nil {
            available_bomb_cards.append(card as! NumCard)
        } else {
            let card_c = card as! NumCard
            let lcard_c = lastPlayedCards[0] as! NumCard
            if card_c.getNum() > lcard_c.getNum() {
                available_bomb_cards.append(card_c)
            } else {
                remaining_cards.append(card_c)
            }
        }
    }
    
    available_bomb_cards.sort()
    var numShuttle: Int = 0, curShuttle: [NumCard] = []
    var maxShuttle: Int = 0, longestShuttle: [NumCard] = []
    var suggestAddOnCard: [Card] = []
    var playerCard_parsed = parseCards(cards: available_bomb_cards)
    if playerCard_parsed.max_card_count < 4 {
        return []
    }
    var i = 0;
    while true {
        if i >= available_bomb_cards.count {
            break
        }
        let card = available_bomb_cards[available_bomb_cards.count - 1 - i]
        if card.getNum().getNum() == 2 {
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
            curShuttle.append(available_bomb_cards[available_bomb_cards.count - 2 - i])
            curShuttle.append(available_bomb_cards[available_bomb_cards.count - 3 - i])
            curShuttle.append(available_bomb_cards[available_bomb_cards.count - 4 - i])
            numShuttle += 1
            
            i += playerCard_parsed.card_count[card.getNum()]! - 1
            
            if numShuttle > 1 {
                if curShuttle.count > longestShuttle.count {
                    maxShuttle = numShuttle
                    longestShuttle = curShuttle
                }
                if !(lastPlayedCards[0] is NullCard) && numShuttle == numShuttleNeed {
                    break
                }
            }
        }
        i += 1
    }
    
    if numShuttle < numShuttleNeed {
        return []
    }
    if !(lastPlayedCards[0] is NullCard) {
        if numShuttle == numShuttleNeed {
            if currentPlay == Play.spaceShuttle {
                return longestShuttle
            }
        }
    }
    
    for card in longestShuttle {
        for i in 0..<available_bomb_cards.count {
            if card.getIdentifier() == available_bomb_cards[i].getIdentifier() {
                available_bomb_cards.remove(at: i)
                break
            }
        }
    }
    
    remaining_cards += available_bomb_cards
    if lastPlayedCards[0] is NullCard && remaining_cards.count + remaining_joker_cards.count < maxShuttle * 2 {
        return longestShuttle
    }
    
    var currentSolo:[Card] = [], currentPair:[Card] = [], currentTrio:[Card] = [], currentBomb:[Card] = []
    i = 0
    playerCard_parsed = parseCards(cards: remaining_cards)
    remaining_cards.sort()
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - 1 - i]
        
        if currentPlay == Play.spaceShuttlePlusFourPair {
            if playerCard_parsed.card_count[card.getNum()]! % 2 == 2 {
                suggestAddOnCard.append(card)
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 2 - i])
                i += 1
                if suggestAddOnCard.count == numShuttleNeed * 4 {
                    return longestShuttle + suggestAddOnCard
                }
            } else if playerCard_parsed.card_count[card.getNum()]! % 2 == 4 {
                suggestAddOnCard.append(card)
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 2 - i])
                if suggestAddOnCard.count == numShuttleNeed * 4 {
                    return longestShuttle + suggestAddOnCard
                }
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 3 - i])
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 4 - i])
                i += 3
                if suggestAddOnCard.count == numShuttleNeed * 4 {
                    return longestShuttle + suggestAddOnCard
                }
            }
        } else if currentPlay == Play.airplanePlusSolo {
            var j = 0
            while j < playerCard_parsed.card_count[card.getNum()]! {
                suggestAddOnCard.append(remaining_cards[remaining_cards.count - 1 - j - i])
                if suggestAddOnCard.count == numShuttleNeed * 2 {
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
    
    if lastPlayedCards[0] is NullCard {
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
    } else if currentPlay == Play.airplanePlusSolo {
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
    let lastPlayedCards: [Card] = [NullCard.shared]
    var maxPlay: [Card] = []
    
    var curPlay: [Card] = []
    curPlay = suggestSpaceShuttlePlay(playerCards: playerCards, currentPlay: Play.spaceShuttle, lastPlayedCards: lastPlayedCards)
    if curPlay.count != 0 {
        maxPlay = curPlay
    }
    curPlay = suggestBombPlusPlay(playerCards: playerCards, currentPlay: Play.bombPlusDualSolo, lastPlayedCards: lastPlayedCards)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestAirplanePlay(playerCards: playerCards, currentPlay: Play.airplane, lastPlayedCards: lastPlayedCards)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestPairChain(playerCards: playerCards, lastPlayedCards: lastPlayedCards)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSoloChainPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestTrioPlusPlay(playerCards: playerCards, play: Play.trioPlusSolo, lastPlayedCards: lastPlayedCards)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = findBomb(playerCards: playerCards, lastBomb: lastPlayedCards)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: Play.trio)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: Play.pair)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    curPlay = suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: Play.solo)
    if curPlay.count > maxPlay.count {
        maxPlay = curPlay
    }
    
    return maxPlay
}

func suggestPlay(playerCards: [Card], currentPlay: Play, lastPlayedCards: [Card])->[Card] {
    if currentPlay == Play.none {
        return suggestNewPlay(playerCards: playerCards)
    }
    
    var suggestedCards: [Card] = []
    switch currentPlay {
    case .solo, .pair, .trio:
        suggestedCards = suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: currentPlay)
    case .soloChain:
        suggestedCards = suggestSoloChainPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards)
    case .pairChain:
        suggestedCards = suggestPairChain(playerCards: playerCards, lastPlayedCards: lastPlayedCards)
    case .trioPlusSolo, .trioPlusPair:
        suggestedCards = suggestTrioPlusPlay(playerCards: playerCards, play: currentPlay, lastPlayedCards: lastPlayedCards)
    case .airplane, .airplanePlusSolo, .airplanePlusPair:
        suggestedCards = suggestAirplanePlay(playerCards: playerCards, currentPlay: currentPlay, lastPlayedCards: lastPlayedCards)
    case .bombPlusDualSolo, .bombPlusDualPair:
        suggestedCards = suggestBombPlusPlay(playerCards: playerCards, currentPlay: currentPlay, lastPlayedCards: lastPlayedCards)
    case .spaceShuttle, .spaceShuttlePlusFourSolo, .spaceShuttlePlusFourPair:
        suggestedCards = suggestSpaceShuttlePlay(playerCards: playerCards, currentPlay: currentPlay, lastPlayedCards: lastPlayedCards)
    case .bomb:
        return findBomb(playerCards: playerCards, lastBomb: lastPlayedCards)
    case .rocket: // nothing can be greater than rocket
        return []
    default:
        return []
    }
    
    if suggestedCards.count == 0 {
        return findBomb(playerCards: playerCards, lastBomb: [NullCard.shared])
    } else {
        return suggestedCards
    }
}

func checkPlay(cards:[Card])->Play {
    // nothing need to be checked for a play with 0 or 1 card, it's always a none or solo
    if cards.count == 0 {
        return Play.none
    } else if cards.count == 1 {
        return Play.solo
    }
    
    let cards_parsed = parseCards(cards: cards)
    var jokerCards = cards_parsed.jokerCards, min = cards_parsed.min, max = cards_parsed.max, max_card_count = cards_parsed.max_card_count, card_count = cards_parsed.card_count
    
    if cards.count == 2 {
        if jokerCards.count == 2 { // only 2 cards and both are JokerCard, so it's a rocket play
            return Play.rocket
        } else if max_card_count == 2 { // two cards are the same, so it's a pair play
            return Play.pair
        } else {
            return Play.invalid
        }
    } else if cards.count == 3 { // only valid play for 3 cards is trio
        if max_card_count == 3 {
            return Play.trio
        } else {
            return Play.invalid
        }
    } else if cards.count == 4 { // for a play with 4 cards, it can be a bomb or a trio plus solo
        if max_card_count == 4 { // bomb play
            return Play.bomb
        } else if max_card_count == 3 { // 3 + 1 play
            return Play.trioPlusSolo
        } else {
            return Play.invalid
        }
    } else { // >= 5 cards, many possible cases
        if max_card_count == 1 { // all single cards, so it can only be a chain play
            if jokerCards.count > 0 || max == 2 { // single cards cannot be played with Joker card, and 2 cannot be used in a chain
                return Play.invalid
            }
            
            let rangeSize = max - min
            
            if rangeSize == cards.count {
                return Play.soloChain
            } else {
                return Play.invalid
            }
        } else if max_card_count == 2 {
            if jokerCards.count > 0 || max == 2 || card_count.values.contains(1) || cards.count % 2 == 1 { // pair chain cannot be played with Joker card, 2 cannot be used in a pair chain, pair chain cannot be played with solo card, and there must be even number of cards
                return Play.invalid
            }
            
            let rangeSize = max - min
            
            if rangeSize == cards.count / 2 {
                return Play.pairChain
            } else {
                return Play.invalid
            }
        } else if max_card_count == 3 {
            // a lot of cases here, 3 + 2, airplane, airplane + 1, airplane + 2
            if cards.count == 5 { // check if it's 3+2 play
                if card_count.values.contains(2) { // if there is another pair, then it's a valid 3+2 play
                    return Play.trioPlusPair
                } else {
                    return Play.invalid
                }
            } else if cards.count % 3 == 0 { // check if it's airplane play
                if jokerCards.count > 0 || max == 2 { // 2 cannot be used in airplane, jokerCards cannot be used with airplane
                    return Play.invalid
                }
                
                let rangeSize = max - min
                
                if rangeSize == cards.count / 3 {
                    return Play.airplane
                } else {
                    return Play.invalid
                }
            } else if cards.count % 4 == 0 { // check if it's airplane + 1 play
                if jokerCards.count > 0 { // Joker card cannot be used in airplane
                    return Play.invalid
                }
                
                var single_count: Int = 0, trio_count: Int = 0
                for (_, count) in card_count {
                    if count == 1 {
                        single_count += 1
                    } else if count == 2 {
                        single_count += 2
                    } else {
                        trio_count += 1
                    }
                }
                
                if trio_count == single_count { // same number of trio and solo, so valid 3+1 play
                    return Play.airplanePlusSolo
                } else {
                    return Play.invalid
                }
            } else if cards.count % 5 == 0 { // check if it's airplane + 2 play
                if jokerCards.count > 0 { // Joker card cannot be used in airplane
                    return Play.invalid
                }
                
                var pair_count: Int = 0, trio_count: Int = 0
                for (_, count) in card_count {
                    if count == 1 { // 3+2 cannot be played with solo
                        return Play.invalid
                    } else if count == 2 {
                        pair_count += 1
                    } else {
                        trio_count += 1
                    }
                }
                
                if trio_count == pair_count { // same number of trio and solo, so valid 3+1 play
                    return Play.airplanePlusPair
                } else {
                    return Play.invalid
                }
            }
        } else if max_card_count == 4 {
            // we don't need to check if there is any joker cards since joker cards can be used in these kind of plays
            
            if cards.count == 5 || cards.count == 7 { // there is no case when there will be 5 or 7 cards
                return Play.invalid
            }
            if cards.count == 6 { // 6 cards in total, and 4 of them are same, so only possible case is 4+2 solo
                return Play.bombPlusDualSolo
            } else { // >= 8 cards
                var solo_count: Int = 0, pair_count: Int = 0, bomb_count: Int = 0
                for (_, count) in card_count {
                    if count == 1 {
                        solo_count += 1
                    } else if count == 2 {
                        pair_count += 1
                    } else if count == 3 {
                        return Play.invalid
                    } else {
                        bomb_count += 1
                    }
                }
                solo_count += jokerCards.count
                
                if solo_count == 0 {
                    if pair_count == 0 { // only bombs, so there are > 1 bomb
                        if max == 2 {
                            return Play.invalid
                        }
                        
                        let rangeSize = max - min
                        
                        if rangeSize == bomb_count {
                            return Play.spaceShuttle
                        } else {
                            return Play.invalid
                        }
                    } else {
                        if pair_count == bomb_count * 2 {
                            if bomb_count > 1 {
                                min = CardNum(num: 2); max = CardNum(num: 3)
                                for (num, count) in card_count {
                                    if count == 4 {
                                        if num < min {
                                            min = num
                                        }
                                        if num > max {
                                            max = num
                                        }
                                    }
                                }
                                
                                if max == 2 {
                                    return Play.invalid
                                }
                                let rangeSize = max - min
                                
                                if rangeSize == bomb_count {
                                    return Play.spaceShuttlePlusFourPair
                                } else {
                                    return Play.invalid
                                }
                            } else {
                                return Play.bombPlusDualPair
                            }
                        } else if pair_count == bomb_count {
                            min = CardNum(num: 2); max = CardNum(num: 3)
                            for (num, count) in card_count {
                                if count == 4 {
                                    if num < min {
                                        min = num
                                    }
                                    if num > max {
                                        max = num
                                    }
                                }
                            }
                            
                            if max == 2 {
                                return Play.invalid
                            } else {
                                return Play.spaceShuttlePlusFourSolo
                            }
                        } else {
                            return Play.invalid
                        }
                    }
                } else {
                    solo_count += 2 * pair_count // all pairs are treated as solos
                    
                    if solo_count == bomb_count * 2 {
                        if bomb_count > 1 {
                            min = CardNum(num: 2); max = CardNum(num: 3)
                            for (num, count) in card_count {
                                if count == 4 {
                                    if num < min {
                                        min = num
                                    }
                                    if num > max {
                                        max = num
                                    }
                                }
                            }
                            
                            if max == 2 {
                                return Play.invalid
                            }
                            let rangeSize = max - min
                            
                            if rangeSize == bomb_count {
                                return Play.spaceShuttlePlusFourSolo
                            } else {
                                return Play.invalid
                            }
                        } else {
                            return Play.bombPlusDualSolo
                        }
                    } else {
                        return Play.invalid
                    }
                }
            }
        }
    }
    
    
    return Play.invalid
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
