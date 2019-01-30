//
//  utilities.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-01-13.
//  Copyright © 2019 yunkai wang. All rights reserved.
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
    
    let playerCards_parsed = parseCards(cards: playerCards)
    var smallest_cards: [Card] = []
    var smallest_card_num: CardNum = CardNum(num: -1)
    let lastPlayedCard = lastPlayedCards[0] as! NumCard
    let limit = play == Play.solo ? 0 : (play == Play.pair ? 1 : 2)
    
    var min_card_count: Int = 4
    for num in playerCards_parsed.card_count.values {
        if num > limit {
            min_card_count = min(min_card_count, num)
        }
    }
    
    for card in playerCards {
        if let converted_card = card as? NumCard {
            if smallest_card_num == converted_card.getNum() && smallest_cards.count < limit + 1 {
                smallest_cards.append(converted_card)
            } else if playerCards_parsed.card_count[converted_card.getNum()]! == min_card_count {
                if converted_card.getNum() > lastPlayedCard.getNum() && (smallest_cards.count == 0 || converted_card.getNum() < smallest_card_num) {
                    smallest_cards = [card]
                    smallest_card_num = converted_card.getNum()
                }
            }
        }
    }
    
    if smallest_cards.count != 0 {
        return smallest_cards
    } else if playerCards_parsed.max_card_count < 4 && playerCards_parsed.jokerCards.count < 2 {
        return []
    }
    
    // find the smallest bomb that player have
    var found_bomb: Bool = false
    var smallest_bomb_num = CardNum(num: 2)
    for (num, count) in playerCards_parsed.card_count {
        if count == 4 {
            found_bomb = true
            if num < smallest_bomb_num {
                smallest_bomb_num = num
            }
        }
    }
    
    if found_bomb {
        // find the group of cards that makes up the bomb
        var bomb:[Card] = []
        for card in playerCards_parsed.numCards {
            if card.getNum() == smallest_bomb_num {
                bomb.append(card)
            }
        }
        return bomb
    } else {
        return playerCards_parsed.jokerCards
    }

}

func suggestPlay(playerCards: [Card], currentPlay: Play, lastPlayedCards: [Card])->[Card] {
    switch currentPlay {
    case .solo:
        return suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: currentPlay)
    case .pair:
        return suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: currentPlay)
    case .trio:
        return suggestSPTPlay(playerCards: playerCards, lastPlayedCards: lastPlayedCards, play: currentPlay)
    default:
        return []
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
                    } else if count == 2 { // 3+1 cannot be played with pair
                        return Play.invalid
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
