//
//  utilities2.swift
//
//  Created by yunkai wang on 2019-03-24.
//

import Foundation

func suggestRocketPlay(playerCards: [Card]) -> [Card] {
    var jokers: [Card] = []
    for card in playerCards {
        if card is JokerCard {
            jokers.append(card)
        }
    }
    return jokers.count == 2 ? jokers : []
}

func suggestAllPossibleSPTBPlay(playerCards: [Card], lastPlay: Play, play: PlayType) -> [[Card]] {
    var req: Int
    switch play {
    case .solo:
        req = 1
    case .pair:
        req = 2
    case .trio:
        req = 3
    default:
        req = 4
    }
    
    var possibles: [[Card]] = []
    
    let lastPrimalCard = lastPlay.getPrimalCard()
    var remaining_cards: [NumCard] = []
    var remaining_jokerCard: [JokerCard] = []
    for card in playerCards {
        if lastPrimalCard is NullCard {
            if card is NumCard {
                remaining_cards.append(card as! NumCard)
            } else {
                remaining_jokerCard.append(card as! JokerCard)
            }
        } else if lastPrimalCard is NumCard && card is NumCard {
            let card_c = card as! NumCard
            if card_c.getNum() > (lastPrimalCard as! NumCard).getNum() {
                remaining_cards.append(card_c)
            }
        } else {
            if card > lastPrimalCard {
                remaining_jokerCard.append(card as! JokerCard)
            }
        }
    }
    
    let playerCards_parsed = parseCards(cards: remaining_cards)
    
    if playerCards_parsed.max_card_count < req && play != .solo {
        return possibles
    }
    
    remaining_cards.sort()
    var i = 0
    while i < remaining_cards.count {
        let card = remaining_cards[remaining_cards.count - i - 1]
        if playerCards_parsed.card_count[card.getNum()]! == req {
            var arr: [Card] = [card]
            for j in 0..<req-1 {
                arr.append(remaining_cards[remaining_cards.count - i - j - 2])
            }
            possibles.append(arr)
        }
        i += playerCards_parsed.card_count[card.getNum()]!
    }
    
    if play == .solo {
        let possiblePairs = suggestAllPossibleSPTBPlay(playerCards: remaining_cards, lastPlay: lastPlay, play: .pair)
        for p in possiblePairs {
            possibles.append([p[0]])
        }
        for c in remaining_jokerCard {
            possibles.append([c])
        }
    } else if play == .pair {
        let possiblePairs = suggestAllPossibleSPTBPlay(playerCards: remaining_cards, lastPlay: lastPlay, play: .trio)
        for p in possiblePairs {
            possibles.append(Array(p[0...1]))
        }
    } else if play == .trio {
        let possiblePairs = suggestAllPossibleSPTBPlay(playerCards: remaining_cards, lastPlay: lastPlay, play: .bomb)
        for p in possiblePairs {
            possibles.append(Array(p[0...2]))
        }
    }
    
    return possibles
}

func suggestAllPossibleSoloChainPlay(playerCards: [Card], lastPlay: Play) -> [[Card]] {
    var possibles: [[Card]] = []
    
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
                if sugggestCards.count > 4 {
                    possibles.append(sugggestCards)
                    
                    for i in 0..<(sugggestCards.count-5) {
                        possibles.append(Array(sugggestCards[(i+1)...(sugggestCards.count-1)]))
                    }
                }
            } else {
                if sugggestCards.count == minLength {
                    possibles.append(sugggestCards)
                    sugggestCards.remove(at: 0)
                }
            }
            
        } else if remaining_cards[remaining_cards.count - i - 1].getNum() == sugggestCards.last!.getNum() {
            continue
        } else {
            sugggestCards = [remaining_cards[remaining_cards.count - i - 1]]
        }
    }
    
    return possibles
}

func suggestAllPossibleTrioPlusPlay(playerCards: [Card], lastPlay: Play)->[[Card]] {
    var possibles: [[Card]] = []
    
    let possibleTrios = suggestAllPossibleSPTBPlay(playerCards: playerCards, lastPlay: lastPlay, play: .trio)
    if possibleTrios.count == 0 {
        return possibles
    }
    
    for trio in possibleTrios {
        var leftCards: [Card] = []
        for i in 0..<playerCards.count {
            var isInSuggestedCard = false
            for card in trio {
                if card == playerCards[i] {
                    isInSuggestedCard = true
                    break
                }
            }
            
            if !isInSuggestedCard {
                leftCards.append(playerCards[i])
            }
        }
        
        var possibleAddOn: [[Card]] = []
        if lastPlay.playType() == .none {
            possibleAddOn += suggestAllPossibleSPTBPlay(playerCards:leftCards, lastPlay: Play(), play: .solo)
            possibleAddOn += suggestAllPossibleSPTBPlay(playerCards:leftCards, lastPlay: Play(), play: .pair)
        } else {
            possibleAddOn = suggestAllPossibleSPTBPlay(playerCards:leftCards, lastPlay: Play(), play: lastPlay.playType() == .trioPlusSolo ? .solo : .pair)
        }

        for addOn in possibleAddOn {
            possibles.append(trio + addOn)
        }
    }
    
    return possibles
}

func suggestAllPossiblePairChainPlay(playerCards: [Card], lastPlay: Play)->[[Card]] {
    var possibles: [[Card]] = []
    
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
                if sugggestCards.count > 5 {
                    possibles.append(sugggestCards)
                    
                    for i in 0..<(sugggestCards.count-6)/2 {
                        possibles.append(Array(sugggestCards[(i*2+2)...(sugggestCards.count-1)]))
                    }
                }
            } else {
                if sugggestCards.count == minLength * 2 {
                    possibles.append(sugggestCards)
                    sugggestCards.remove(at: 0)
                    sugggestCards.remove(at: 1)
                }
            }
        } else {
            sugggestCards = []
        }
        i += 1
    }
    
    return possibles
}

