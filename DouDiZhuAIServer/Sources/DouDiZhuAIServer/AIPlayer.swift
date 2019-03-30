//
//  ComputerPlayer.swift
//  DouDiZhuAIServer
//
//  Created by yunkai wang on 2019-03-04.
//

import PerfectWebSockets
import Foundation

class AIPlayer: Player {
    private var player2: String = ""
    private var player3: String = ""
    private var landlordID: String = ""
    private var player2PlayedCards: [Card] = []
    private var player3PlayedCards: [Card] = []
    private var landlordCards: [Card] = []
    private var currentPlay: Play? = nil
    private var lastPlayedPlayer: String = ""
    private var nextPlayer: String = ""
    private var cardsLeft: [Card] = [] // all cards that other players may have
    private var bestPlay: [Card] = []
    public var dump: Bool = false
    
    convenience init(dump: Bool) {
        self.init(nil)
        self.dump = dump
    }
    
    private override init(_ socket: WebSocket?) {
        super.init(socket)
        self.cardsLeft = Deck.initializeDeckOfCards()
    }
    
    public func makeBeLandlordDecision(_ pillage: Bool)-> Bool {
        if self.dump {
            return Int.random(in: 0...1) == 0
        }
        
        if pillage {
            return self.calculateHeuristic(self.getCards()) > 88.44
        }
        return Double(self.calculateHeuristic(self.getCards())) > 90
    }
    
    public func receiveMessage(_ message: Message) {
        DispatchQueue.global(qos: .background).async {
            if message.type == .abortGame {
                return
            }
            
            guard let playerID = message.playerID else {
                print("AI player received an unknown message, ignoring the message..")
                return
            }
        
            switch message.type {
            case .joinGameSucceded:
                return
            case .newUserJoined:
                self.addNewPlayer(playerID)
            case .gameStarted:
                // may be start a new thread and start computing whether or not the AI should be the landlord or not
                self.removeCardsFromRemainingCards(self.getCards())
            case .makePlay:
                self.playerMakePlay(playerID, cards: message.cards)
            case .informLandlord:
                self.landlordID = playerID
                self.landlordCards = message.cards
            case .playerTurn:
                self.playerTurn(playerID)
            case .playerDecisionTurn, .playerPillageTurn:
                self.playerDecisionTurn(playerID, message.type == .playerPillageTurn ? true: false)
            case .playerWantToBeLandlord, .playerWantToBeFarmer, .gameEnd, .abortGame:
                return
            default:
                print("\(message.type) received by AI, this should not be received by AI")
                return
            }
        }
    }
    
    private func removeCardsFromRemainingCards(_ cards: [Card]) {
        for card in cards {
            for i in 0..<self.cardsLeft.count {
                if self.cardsLeft[i].getIdentifier() == card.getIdentifier() {
                    self.cardsLeft.remove(at: i)
                    break
                }
            }
        }
    }
    
    private func addNewPlayer(_ id: String) {
        if self.player2 == "" {
            self.player2 = id
        } else {
            self.player3 = id
        }
    }
    
    private func playerMakePlay(_ id: String, cards: [Card]) {
        if id != self.id {
            if id == self.player2 {
                self.player2PlayedCards += cards
            } else {
                self.player3PlayedCards += cards
            }
            self.removeCardsFromRemainingCards(cards)
        }
        if cards.count != 0 {
            do {
                try self.currentPlay = Play(cards)
            } catch {
                exit(1)
            }
            self.lastPlayedPlayer = id
        }
    }
    
    private func playerDecisionTurn(_ id: String, _ pillage: Bool) {
        if id != self.id { // it's other players turn, so ignore
            return
        }
        
        do {
            try DouDiZhuGame.shared.playerMadeDecision(playerID: self.id, decision: makeBeLandlordDecision(pillage))
        } catch {
            print("AI player cannot make the decision due to some unknown error...")
            DouDiZhuGame.shared.handleError()
        }
    }
    
    public func calculateHeuristic(_ cards: [Card]) -> Double {
        let rank = calculateAverageCardRank(cards)
        let numTurn = calculateNumTurnNeeded(cards)
        return Double((20 - numTurn)) * rank
    }
    
    private func calculateAverageCardRank(_ cards: [Card]) -> Double {
        var totalRank: Int = 0
        
        for card in cards {
            totalRank += card.getRank()
        }

        return Double(totalRank) / Double(cards.count)
    }
    
    private func calculateNumTurnNeeded(_ cards: [Card]) -> Int {
        let parsed = parseCards(cards: cards)
        
        if cards.count == 0 {
            return 0
        } else if cards.count == 1 {
            return 1
        } else if cards.count == 2 {
            if parsed.jokerCards.count == 2 { // rocket play
                return 1
            } else if parsed.max_card_count == 2 { // pair play
                return 1
            }
            
            // two different cards, so need 2 turns to play
            return 2
        } else if cards.count == 3 {
            if parsed.max_card_count == 3 { // trio play
                return 1;
            } else if parsed.max_card_count == 2 || parsed.jokerCards.count == 2 { // has a pair or rocket
                return 2;
            }
            return 3
        } else if cards.count == 4 {
            if parsed.max_card_count == 4 || parsed.max_card_count == 3 { // bomb, trio + 1
                return 1
            } else if parsed.jokerCards.count == 2 { // has a rocket, still need to check how to play the rest of the cards, if a pair is left, then we need 2 turns, otherwise we need 3 turns
                return 1 + parsed.max_card_count == 2 ? 1 : 2
            } else if parsed.max_card_count == 1 { // has to make four solo plays
                return 4
            }
            
            var leftCards: [Card] = []
            for card in parsed.jokerCards {
                leftCards.append(card)
            }
            
            for card in parsed.numCards {
                if (parsed.card_count[card.getNum()] ?? 0) != 2 {
                    leftCards.append(card)
                }
            }
            
            // if no card is left, then it means we have two pairs, otherwise, we have a pair plus two other cards and they cannot be played together, so we need 3 turn
            return leftCards.count == 0 ? 2 : 3
        } else if cards.count == 5 {
            if parsed.max_card_count == 4 { // bomb and a solo card
                return 2
            } else if parsed.jokerCards.count == 2 { // has a rocket, think about how to play the rest
                return 1 + calculateNumTurnNeeded(parsed.numCards)
            } else if parsed.max_card_count == 3 {
                if parsed.jokerCards.count != 0 { // has a joker card, so need to play a 3+1 and a solo play
                    return 2
                } else {
                    var leftCards: [NumCard] = []
                    
                    for card in parsed.numCards {
                        if (parsed.card_count[card.getNum()] ?? 0) != 3 {
                            leftCards.append(card)
                        }
                    }
                    
                    if leftCards[0].getNum() == leftCards[1].getNum() { // left is a pair, make a 3+2 play
                        return 1
                    } else { // 2 solo cards are left, can make a 3+1 and solo play
                        return 2
                    }
                }
            } else if parsed.max_card_count == 2 {
                var leftCards: [NumCard] = []
                
                for card in parsed.numCards {
                    if (parsed.card_count[card.getNum()] ?? 0) != 2 {
                        leftCards.append(card)
                    }
                }
                if leftCards.count == 0 || leftCards.count == 1 { // we have 2 pairs
                    return 3
                } else {
                    return 4
                }
            } else {
                // no joker cards, no 2, and is a chain of length 5, so we need only 1 turn
                if parsed.max.getNum() - parsed.min.getNum() == 5 && parsed.max.getNum() != 2 && parsed.jokerCards.count == 0 {
                    return 1
                }
                
                // all other cases, we have 5 solo cards, so we need 5 turns
                return 5
            }
        }
        
        var contained: [Bool] = [Bool](repeating: false, count: cards.count)
        let maxPlay = suggestNewPlay(playerCards: cards)
        for card in maxPlay {
            for i in 0..<cards.count {
                if cards[i] == card {
                    contained[i] = true
                    break
                }
            }
        }
        
        var remainingCards: [Card] = []
        for i in 0..<cards.count {
            if !contained[i] {
                remainingCards.append(cards[i])
            }
        }
        
        return 1 + calculateNumTurnNeeded(remainingCards)
    }
    
    private func playerTurn(_ id: String) {
        if id != self.id { // it's other players turn, so ignore
            return
        }
        
        do {
            try DouDiZhuGame.shared.playerMakePlay(self.id, cards: findBestPlay())
        } catch {
            print("AI player cannot make a play due to some unknown error...")
            DouDiZhuGame.shared.handleError()
        }
    }
    
    private func findAllPossiblePlays(cards: [Card], lastPlay: Play?) -> [[Card]] {
        var listPlays: [[Card]] = []
        let rocket = suggestRocketPlay(playerCards: cards)
        if rocket.count != 0 {
            listPlays.append(rocket)
        }
        
        if lastPlay == nil {
            let dum = Play()
            listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: dum, play: .solo)
            listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: dum, play: .pair)
            listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: dum, play: .trio)
            listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: dum, play: .bomb)
            listPlays += suggestAllPossibleSoloChainPlay(playerCards: cards, lastPlay: dum)
            listPlays += suggestAllPossiblePairChainPlay(playerCards: cards, lastPlay: dum)
            listPlays += suggestAllPossibleTrioPlusPlay(playerCards: cards, lastPlay: dum)
            var play = suggestBombPlusPlay(playerCards: cards, lastPlay: dum)
            if play.count != 0 {
                listPlays.append(play)
            }
            play = suggestAirplanePlay(playerCards: cards, lastPlay: dum)
            if play.count != 0 {
                listPlays.append(play)
            }
            play = suggestSpaceShuttlePlay(playerCards: cards, lastPlay: dum)
            if play.count != 0 {
                listPlays.append(play)
            }
        } else {
            switch lastPlay!.playType() {
            case .solo:
                listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: lastPlay!, play: .solo)
            case .pair:
                listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: lastPlay!, play: .pair)
            case .trio:
                listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: lastPlay!, play: .trio)
            case .bomb:
                listPlays += suggestAllPossibleSPTBPlay(playerCards: cards, lastPlay: lastPlay!, play: .bomb)
            case .soloChain:
                listPlays += suggestAllPossibleSoloChainPlay(playerCards: cards, lastPlay: lastPlay!)
            case .pairChain:
                listPlays += suggestAllPossiblePairChainPlay(playerCards: cards, lastPlay: lastPlay!)
            case .trioPlusSolo, .trioPlusPair:
                listPlays += suggestAllPossibleTrioPlusPlay(playerCards: cards, lastPlay: lastPlay!)
            case .airplane, .airplanePlusSolo, .airplanePlusPair:
                let play = suggestAirplanePlay(playerCards: cards, lastPlay: lastPlay!)
                if play.count != 0 {
                    listPlays.append(play)
                }
            case .spaceShuttle, .spaceShuttlePlusFourSolo, .spaceShuttlePlusFourPair:
                let play = suggestSpaceShuttlePlay(playerCards: cards, lastPlay: lastPlay!)
                if play.count != 0 {
                    listPlays.append(play)
                }
            default:
                listPlays = []
            }
        }
        
        return listPlays
    }
    
    private func canPass() -> Bool {
        return self.id != self.lastPlayedPlayer && self.currentPlay != nil
    }
    
    private func findBestPlay() -> [Card] {
        if self.dump {
            if canPass() {
                return suggestPlay(playerCards: self.getCards(), lastPlay: self.currentPlay ?? Play())
            }
            return suggestNewPlay(playerCards: self.getCards())
        }
        
        let possiblePlays: [[Card]] = findAllPossiblePlays(cards: self.getCards(), lastPlay: canPass() ? self.currentPlay : nil)
        
        // no possible play, simply return
        if possiblePlays.count == 0 {
            return []
        }
        
        var bestScore: Double = 0, bestPlay: [Card] = []
        var firstScore: Bool = true
        
        for play in possiblePlays {
            do {
                let p = try Play(play)
                let score = conductBRS(depth: 1, playerTurn: false, playerCards: getRemainingCardsAfterPlay(cards: self.getCards(), play: play), otherCards: self.cardsLeft, lastPlay: p, playerMadeLastPlay: true)
                if score > bestScore || firstScore {
                    bestScore = score
                    bestPlay = play
                    firstScore = false
                }
                
                if bestScore == Double(Int.max) {
                    break
                }
            } catch {
                continue
            }
        }
        
        if canPass() { // check if pass is a better solution
            let score = conductBRS(depth: 1, playerTurn: false, playerCards: self.getCards(), otherCards: self.cardsLeft, lastPlay: self.currentPlay!, playerMadeLastPlay: false)
            if score > bestScore {
                bestScore = score
                bestPlay = []
            }
        }
        
        return bestPlay
    }
    
    private func getRemainingCardsAfterPlay(cards: [Card], play: [Card]) -> [Card] {
        var remainingCards: [Card] = []
        for card in cards {
            var isPlayed: Bool = false
            for playedCard in play {
                if card.getIdentifier() == playedCard.getIdentifier() {
                    isPlayed = true
                    break
                }
            }
            if !isPlayed {
                remainingCards.append(card)
            }
        }
        return remainingCards
    }
    
    // this function checks whether the AI 'think' the landlord has played all the cards, this is done by check whether the number of cards left by the other farmer is less than or equal to the amount of cards left
    private func checkIfLandlordHasFinishedHisPlay(leftCards: [Card]) -> Bool {
        if self.landlordID == self.player2 {
            return leftCards.count <= 17 - self.player3PlayedCards.count
        } else {
            return leftCards.count <= 17 - self.player2PlayedCards.count
        }
    }
    
    private func conductBRS(depth: Int, playerTurn: Bool, playerCards: [Card], otherCards: [Card], lastPlay: Play, playerMadeLastPlay: Bool) -> Double {
        if depth == 3 { // search for a depth of 4
            return calculateHeuristic(playerCards)
        } else if playerCards.count == 0 { // player played all his card, he won the game, so return maximum score
            return Double(Int.max)
        } else if (self.landlordID == self.id && otherCards.count == 0) || (self.landlordID != self.id && checkIfLandlordHasFinishedHisPlay(leftCards: otherCards)) { // other player win the game has played all the cards as a team, or the landlord may have spent all the cards
            return Double(Int.min)
        }
        
        if playerTurn {
            let possiblePlays: [[Card]] = findAllPossiblePlays(cards: playerCards, lastPlay: playerMadeLastPlay ? nil : lastPlay)
            
            if possiblePlays.count == 0 {
                return conductBRS(depth: depth+1, playerTurn: false, playerCards: playerCards, otherCards: otherCards, lastPlay: lastPlay, playerMadeLastPlay: false)
            }
            
            var bestScore: Double = 0
            
            for play in possiblePlays {
                do {
                    let p = try Play(play)
                    let score = conductBRS(depth: depth+1, playerTurn: false, playerCards: getRemainingCardsAfterPlay(cards: playerCards, play: play), otherCards: otherCards, lastPlay: p, playerMadeLastPlay: true)
                    
                    if score > bestScore {
                        bestScore = score
                    }
                    
                    if bestScore == Double(Int.max) {
                        break
                    }
                } catch {
                    continue
                }
            }
            
            if !playerMadeLastPlay { // player may choose to pass
                let score = conductBRS(depth: depth+1, playerTurn: false, playerCards: playerCards, otherCards: otherCards, lastPlay: lastPlay, playerMadeLastPlay: false)
                
                if score > bestScore {
                    bestScore = score
                }
            }
            
            return bestScore
        }
        
        let possiblePlays: [[Card]] = findAllPossiblePlays(cards: otherCards, lastPlay: playerMadeLastPlay ? lastPlay : nil)
        
        if possiblePlays.count == 0 {
            return conductBRS(depth: depth+1, playerTurn: true, playerCards: playerCards, otherCards: otherCards, lastPlay: lastPlay, playerMadeLastPlay: true)
        }
        
        var worstScore: Double = Double(Int.max)
        
        for play in possiblePlays {
            do {
                let p = try Play(play)
                let score = conductBRS(depth: depth+1, playerTurn: true, playerCards: playerCards, otherCards: getRemainingCardsAfterPlay(cards: otherCards, play: play), lastPlay: p, playerMadeLastPlay: false)
                
                if score < worstScore {
                    worstScore = score
                }
                
                if worstScore == Double(Int.min) {
                    break
                }
            } catch {
                continue
            }
        }
        
        if playerMadeLastPlay { // other player may choose to pass
            let score = conductBRS(depth: depth+1, playerTurn: true, playerCards: playerCards, otherCards: otherCards, lastPlay: lastPlay, playerMadeLastPlay: true)
            
            if score < worstScore {
                worstScore = score
            }
        }
        
        return worstScore
    }
}
