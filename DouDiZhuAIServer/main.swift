//
//  main.swift
//  COpenSSL
//
//  Created by yunkai wang on 2019-02-13.
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets
import PerfectLib

func makeRoutes() -> Routes {
    var routes = Routes()
    
    // Add the endpoint for the WebSocket example system
    routes.add(method: .get, uri: "/game", handler: {
        request, response in
        
        // To add a WebSocket service, set the handler to WebSocketHandler.
        // Provide your closure which will return your service handler.
        WebSocketHandler(handlerProducer: {
            (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
            
            // Return our service handler.
            return GameHandler()
        }).handleRequest(request: request, response: response)
    })
    
    return routes
}

do {
    // Launch the HTTP server on port 8181
    try HTTPServer.launch(name: "localhost", port: 8181, routes: makeRoutes())
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
