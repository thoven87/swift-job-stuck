import Hummingbird
import HummingbirdRedis
import HummingbirdRouter
import Jobs
import JobsRedis
import Logging
import SMTPKitten

protocol SwiftJobsServiceArguments {
    var hostname: String { get }
    var logLevel: Logger.Level { get }
    var port: Int { get }
}
let SERVICENAME = "SwiftJobsService"
func buildApplication(
    _ arguments: some SwiftJobsServiceArguments
) async throws -> some ApplicationProtocol {
    let env = Environment()

    let logger = {
        var logger = Logger(label: SERVICENAME)
        logger.logLevel = arguments.logLevel
        return logger
    }()

    let redisConnectionPoolService = try RedisConnectionPoolService(
        .init(
            hostname: env.get("REDIS_HOST") ?? "localhost",
            port: env.get("REDIS_PORT", as: Int.self) ?? 6379),
        logger: logger
    )

    let jobQueue = JobQueue(
        .redis(
            redisConnectionPoolService.pool
        ),
        numWorkers: env.get("JOB_QUEUE_WORKERS", as: Int.self) ?? 4,
        logger: logger
    )

    let smtpClient = try await SMTPClient.connect(
        hostname: env.get("SMTP_HOSTNAME") ?? "sandbox.smtp.mailtrap.io",
        port: env.get("SMTP_PORT", as: Int.self) ?? 587,
        ssl: .startTLS(configuration: .default))

    let _ = try await JobController(
        queue: jobQueue,
        emailService: .init(
            client: smtpClient,
            username: env.get("SMTP_USERNAME") ?? "",  // mail trap user id
            password: env.get("SMTP_PASSWORD") ?? "",  // mail trap password
            logger: logger
        ),
        logger: logger)

    let router = RouterBuilder(context: AppContext.self) {
        RouteGroup("api/v1") {
            HelloController(queue: jobQueue).endpoints
        }
    }

    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: SERVICENAME),
        logger: logger)

    app.logger.logLevel = arguments.logLevel

    app.addServices(redisConnectionPoolService, jobQueue)

    return app
}
