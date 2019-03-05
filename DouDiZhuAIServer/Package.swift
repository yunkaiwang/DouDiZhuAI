// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "DouDiZhuAIServer",
	dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(url:"https://github.com/PerfectlySoft/Perfect-WebSockets.git", from: "3.0.0"),
	],
	targets: [
		.target(name: "DouDiZhuAIServer", dependencies: ["PerfectHTTPServer", "PerfectWebSockets"])
	]
)
