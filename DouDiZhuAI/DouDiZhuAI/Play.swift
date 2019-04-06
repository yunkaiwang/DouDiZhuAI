//
//  Play.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

enum playError: Error {
    case invalidPlay
}

class Play: Comparable {
    static func < (lhs: Play, rhs: Play) -> Bool {
        if lhs.playType() == .rocket {
            return false
        } else if rhs.playType() == .rocket {
            return true
        } else if lhs.playType() == .bomb && rhs.playType() != .bomb {
            return false
        } else if rhs.playType() == .bomb && lhs.playType() != .bomb {
            return true
        }
        
        let c1 = lhs.getPrimalCard(), c2 = rhs.getPrimalCard()
        if c1 is NullCard && c2 is NullCard {
            return lhs.playType() == rhs.playType() && lhs.getSerialLength() == rhs.getSerialLength()
        } else if c1 is NullCard || c2 is NullCard {
            return false
        } else if c1 is JokerCard || c2 is JokerCard {
            return c1 < c2
        }
        
        return lhs.playType() == rhs.playType() && lhs.getSerialLength() == rhs.getSerialLength() && (c1 as! NumCard).getNum() < (c2 as! NumCard).getNum()
    }
    
    static func == (lhs: Play, rhs: Play) -> Bool {
        let c1 = lhs.getPrimalCard(), c2 = rhs.getPrimalCard()
        if c1 is NullCard && c2 is NullCard {
            return lhs.playType() == rhs.playType() && lhs.getSerialLength() == rhs.getSerialLength()
        } else if c1 is NullCard || c2 is NullCard {
            return false
        } else if c1 is JokerCard || c2 is JokerCard {
            return c1 == c2
        }
        
        return lhs.playType() == rhs.playType() && lhs.getSerialLength() == rhs.getSerialLength() && (c1 as! NumCard).getNum() == (c2 as! NumCard).getNum()
    }
    
    private var type: PlayType = .none
    private var primalCard: Card? = nil // primal card of the play, if previous play is a chain play, then this will be set to the smallest card of the last play for simplicity
    private var serialLength: Int = 0
    
    private func findCardWithNum(_ cards: [NumCard], num: CardNum) -> Card? {
        for card in cards {
            if card.getNum() == num {
                return card
            }
        }
        return nil
    }
    
    private func findMinCardWithCount(_ card_count: [CardNum: Int], cards: [NumCard], count: Int) -> Card {
        var minCard: Card = cards[0]
        
        for card in cards {
            if (card_count[card.getNum()] ?? 0) == count && card < minCard {
                minCard = card
            }
        }
        
        return minCard
    }
    
    private func countCards(_ card_count: [CardNum: Int]) -> (soloCount: Int, pairCount: Int, trioCount: Int, bombCount: Int) {
        var solo: Int = 0, pair: Int = 0, trio: Int = 0, bomb: Int = 0
        for (_, count) in card_count {
            if count == 1 {
                solo += 1
            } else if count == 2 {
                pair += 1
            } else if count == 3 {
                trio += 1
            } else {
                bomb += 1
            }
        }
        return (solo, pair, trio, bomb)
    }
    
    private func findMaxMinCardNumWithCount(_ card_count: [CardNum: Int], count: Int) -> (min: CardNum, max: CardNum) {
        var min = CardNum(num: 2), max = CardNum(num: 3)
        for (num, c) in card_count {
            if c == count {
                if num < min {
                    min = num
                }
                if num > max {
                    max = num
                }
            }
        }
        return (min:min, max:max)
    }
    
    public init () { }
    
    public init(_ cards: [Card]) throws {
        // nothing need to be checked for a play with 0 or 1 card, it's always a none or solo
        if cards.count == 0 {
            return
        } else if cards.count == 1 {
            self.type = .solo
            self.primalCard = cards[0]
            return
        }
        
        let cards_parsed = parseCards(cards: cards)
        var jokerCards = cards_parsed.jokerCards, min = cards_parsed.min, max = cards_parsed.max, max_card_count = cards_parsed.max_card_count, card_count = cards_parsed.card_count, numCards = cards_parsed.numCards
        
        if cards.count == 2 {
            if jokerCards.count == 2 { // only 2 cards and both are JokerCard, so it's a rocket play, we don't needd to specify the primal card, since rocket it's the largest card by default
                self.type = .rocket
                return
            } else if max_card_count == 2 { // two cards are the same, so it's a pair play
                self.type = .pair
                self.primalCard = cards[0]
                return
            } else {
                throw playError.invalidPlay
            }
        } else if cards.count == 3 { // only valid play for 3 cards is trio
            if max_card_count == 3 {
                self.type = .trio
                self.primalCard = cards[0]
                return
            } else {
                throw playError.invalidPlay
            }
        } else if cards.count == 4 { // for a play with 4 cards, it can be a bomb or a trio plus solo
            if max_card_count == 4 { // bomb play
                self.type = .bomb
                self.primalCard = cards[0]
                return
            } else if max_card_count == 3 { // 3 + 1 play
                self.type = .trioPlusSolo
                self.primalCard = findMinCardWithCount(card_count, cards: numCards, count: 3)
                return
            } else {
                throw playError.invalidPlay
            }
        } else { // >= 5 cards, many possible cases
            if max_card_count == 1 { // all single cards, so it can only be a chain play
                if jokerCards.count > 0 || max == 2 { // single cards cannot be played with Joker card, and 2 cannot be used in a chain
                    throw playError.invalidPlay
                }
                
                let rangeSize = max - min
                
                if rangeSize == cards.count {
                    self.type = .soloChain
                    self.serialLength = rangeSize
                    self.primalCard = findCardWithNum(numCards, num: min)
                    if self.primalCard == nil {
                        throw playError.invalidPlay
                    }
                    
                    return
                } else {
                    throw playError.invalidPlay
                }
            } else if max_card_count == 2 {
                if jokerCards.count > 0 || max == 2 || card_count.values.contains(1) || cards.count % 2 == 1 { // pair chain cannot be played with Joker card, 2 cannot be used in a pair chain, pair chain cannot be played with solo card, and there must be even number of cards
                    throw playError.invalidPlay
                }
                
                let rangeSize = max - min
                
                if rangeSize == cards.count / 2 {
                    self.type = .pairChain
                    self.serialLength = rangeSize
                    self.primalCard = findCardWithNum(numCards, num: min)
                    if self.primalCard == nil {
                        throw playError.invalidPlay
                    }
                    return
                } else {
                    throw playError.invalidPlay
                }
            } else if max_card_count == 3 {
                // a lot of cases here, 3 + 2, airplane, airplane + 1, airplane + 2
                if cards.count == 5 { // check if it's 3+2 play
                    if card_count.values.contains(2) { // if there is another pair, then it's a valid 3+2 play
                        self.type = .trioPlusPair
                        self.primalCard = findMinCardWithCount(card_count, cards: numCards, count: 3)
                        return
                    } else {
                        throw playError.invalidPlay
                    }
                } else if cards.count % 3 == 0 { // check if it's airplane play
                    if jokerCards.count > 0 || max == 2 { // 2 cannot be used in airplane, jokerCards cannot be used with airplane
                        throw playError.invalidPlay
                    }
                    
                    let rangeSize = max - min
                    if rangeSize == cards.count / 3 {
                        self.type = .airplane
                        self.serialLength = rangeSize
                        self.primalCard = findMinCardWithCount(card_count, cards: numCards, count: 3)
                        return
                    } else {
                        throw playError.invalidPlay
                    }
                } else if cards.count % 4 == 0 { // check if it's airplane + 1 play
                    if jokerCards.count > 0 { // Joker card cannot be used in airplane
                        throw playError.invalidPlay
                    }
                    
                    let count = countCards(card_count)
                    if count.trioCount == (count.soloCount + 2 * count.pairCount) { // same number of trio and solo, so valid 3+1 play
                        self.type = .airplanePlusSolo
                        self.serialLength = count.trioCount
                        self.primalCard = findMinCardWithCount(card_count, cards: numCards, count: 3)
                        return
                    } else {
                        throw playError.invalidPlay
                    }
                } else if cards.count % 5 == 0 { // check if it's airplane + 2 play
                    if jokerCards.count > 0 { // Joker card cannot be used in airplane
                        throw playError.invalidPlay
                    }
                    
                    let count = countCards(card_count)
                    if count.trioCount == count.pairCount { // same number of trio and pair, so valid 3+2 play
                        self.type = .airplanePlusPair
                        self.serialLength = count.trioCount
                        self.primalCard = findMinCardWithCount(card_count, cards: numCards, count: 3)
                        return
                    } else {
                        throw playError.invalidPlay
                    }
                }
            } else if max_card_count == 4 {
                // we don't need to check if there is any joker cards since joker cards can be used in these kind of plays
                
                if cards.count == 5 || cards.count == 7 { // there is no case when there will be 5 or 7 cards
                    throw playError.invalidPlay
                }
                if cards.count == 6 { // 6 cards in total, and 4 of them are same, so only possible case is 4+2 solo
                    self.type = .bombPlusDualSolo
                    self.primalCard = findMinCardWithCount(card_count, cards: numCards, count: 4)
                    return
                } else { // >= 8 cards
                    let count = countCards(card_count)
                    
                    if count.trioCount != 0 {
                        throw playError.invalidPlay
                    } else if (count.soloCount + jokerCards.count) == 0 {
                        if count.pairCount == 0 { // only bombs, so there are > 1 bomb
                            if max == 2 {
                                throw playError.invalidPlay
                            }
                            
                            let rangeSize = max - min
                            if rangeSize == count.bombCount {
                                self.type = .spaceShuttle
                                self.serialLength = rangeSize
                                self.primalCard = self.findMinCardWithCount(card_count, cards: numCards, count: 4)
                                return
                            } else {
                                throw playError.invalidPlay
                            }
                        } else {
                            if count.pairCount == count.bombCount * 2 {
                                if count.bombCount > 1 {
                                    let minMax = findMaxMinCardNumWithCount(card_count, count: 4)
                                    let rangeSize = minMax.max - minMax.min
                                    if max == 2 || rangeSize != count.bombCount {
                                        throw playError.invalidPlay
                                    } else {
                                        self.type = .spaceShuttlePlusFourPair
                                        self.serialLength = rangeSize
                                        self.primalCard = self.findMinCardWithCount(card_count, cards: numCards, count: 4)
                                        return
                                    }
                                } else {
                                    self.type = .bombPlusDualPair
                                    self.primalCard = self.findMinCardWithCount(card_count, cards: numCards, count: 4)
                                    return
                                }
                            } else if count.pairCount == count.bombCount {
                                let minMax = findMaxMinCardNumWithCount(card_count, count: 4)
                                let rangeSize = minMax.max - minMax.min
                                if max == 2 || rangeSize != count.bombCount {
                                    throw playError.invalidPlay
                                } else {
                                    self.type = .bombPlusDualPair
                                    self.serialLength = rangeSize
                                    self.primalCard = self.findMinCardWithCount(card_count, cards: numCards, count: 4)
                                    return
                                }
                            } else {
                                throw playError.invalidPlay
                            }
                        }
                    } else {
                        let soloCount = count.soloCount + 2 * count.pairCount
                        
                        if soloCount == count.bombCount * 2 {
                            let minMax = findMaxMinCardNumWithCount(card_count, count: 4)
                            let rangeSize = minMax.max - minMax.min
                            
                            if max == 2 || rangeSize != count.bombCount {
                                throw playError.invalidPlay
                            } else {
                                self.type = .spaceShuttlePlusFourSolo
                                self.serialLength = rangeSize
                                self.primalCard = self.findMinCardWithCount(card_count, cards: numCards, count: 4)
                                return
                            }
                        } else {
                            throw playError.invalidPlay
                        }
                    }
                }
            }
        }
        
        throw playError.invalidPlay
    }
    
    public func playType() -> PlayType {
        return self.type
    }
    
    public func getSerialLength() -> Int {
        return self.serialLength
    }
    
    public func getPrimalCard() -> Card {
        return self.primalCard ?? NullCard.shared
    }
}
