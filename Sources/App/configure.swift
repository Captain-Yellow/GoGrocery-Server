import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // connecting db to server
    app.databases.use(.postgres(configuration: .init(coreConfiguration: .init(host: "localhost", username: "postgres", password: "", database: "gogrocerydb", tls: .disable))), as: .psql)

    // creat migation
    app.migrations.add(CreateUserTableMigration())
    
    // register the route collection
    try app.register(collection: UserController())
    
    // set jwt token generation method
    app.jwt.signers.use(.hs256(key: "GOGROCERYSERVERAPP"))
    
    // register routes
    try routes(app)
}
