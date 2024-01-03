import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    if let databaseUrl = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: databaseUrl) {
        postgresConfig.tlsConfiguration = .makeClientConfiguration()
        postgresConfig.tlsConfiguration?.certificateVerification = .none
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        // connecting db to server
        app.databases.use(
            .postgres(configuration:
                    .init(coreConfiguration:
                            .init(
                                host: Environment.get("DB_HOST_NAME") ?? "localhost",
                                username: Environment.get("DB_USER_NAME") ?? "postgres",
                                password: Environment.get("DB_PASSWORD") ?? "",
                                database: Environment.get("DB_NAME") ?? "gogrocerydb",
                                tls: .disable)
                    )
            ),
            as: .psql)
    }

    // creat migation
    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateGroceryCategoryTableMigration())
    app.migrations.add(CreateGroceryItemTableMigration())

    // register the route collection
    try app.register(collection: UserController())
    try app.register(collection: GroceryController())
    
    // set jwt token generation method
    app.jwt.signers.use(.hs256(key: Environment.get("HS_KEY") ?? "GOGROCERYSERVERAPP"))
    
    // register routes
    try routes(app)
}
