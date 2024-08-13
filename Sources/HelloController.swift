import Hummingbird
import HummingbirdRouter
import Jobs
import JobsRedis

struct HelloController {
    typealias Context = AppContext
    let emailJob: JobQueue<RedisJobQueue>

    var endpoints: some RouterMiddleware<Context> {
        RouteGroup("hello") {
            Get(handler: hello)
        }
    }

    init(queue: JobQueue<RedisJobQueue>) {
        self.emailJob = queue
    }

    @Sendable
    func hello(_ req: Request, context: Context) async throws -> HTTPResponse.Status {
        do {
            let to = "test@email.com"
            try await emailJob.push(
                JobController.EmailParameters(
                    to: [to],
                    subject: "Hello",
                    message: "Sent from Hummingbird, swift jobs and SMTPKitten"
                )
            )
            return .ok
        } catch {
            context.logger.info(
                "Failed to created user",
                metadata: [
                    "message": "\(String(reflecting: error))"
                ])
            throw error
        }
    }
}
