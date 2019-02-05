import App

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"

import swidamio
import Vapor

let config = try Config()

try config.setupProviders()
try config.setupPreparations()


var drop = try! Droplet(config)
try drop.setup()

guard let projectPropertiesPath = getEnv("PROJECT_PROPERTIES_PATH") else {
	fatalError("PROJECT_PROPERTIES_PATH env must be set!")
}

try! addMicroserviceContractEndpoints(drop: drop, metadata: ServiceMetadataBuilder.default.metadata)

try! drop.run()
