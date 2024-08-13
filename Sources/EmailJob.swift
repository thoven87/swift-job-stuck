import Jobs
import Logging

struct JobController {
    struct EmailParameters: JobParameters {
        static let jobName: String = "SendEmail"
        let to: [String]
        var from: String = "noreply@swift.org"
        let subject: String
        let message: String
    }

    init(queue: borrowing JobQueue<some JobQueueDriver>, emailService: EmailService, logger: Logger)
    {
        queue.registerJob(
            parameters: EmailParameters.self,
            maxRetryCount: 10
        ) { (parameters: EmailParameters, _) in
            do {
                try await emailService.send(emailParameters: parameters)
            } catch {
                logger.info(
                    "Failed to send semail: \(error.localizedDescription)",
                    metadata: [
                        "error": "\(String(reflecting: error))"
                    ])
                throw error
            }
        }
    }
}
