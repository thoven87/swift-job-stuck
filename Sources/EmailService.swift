import Logging
@preconcurrency import SMTPKitten

struct EmailService: Sendable {
    let logger: Logger
    let smtpClient: SMTPClient
    let username: String
    let password: String

    init(client: SMTPClient, username: String, password: String, logger: Logger)
        async throws
    {
        self.logger = logger
        self.username = username
        self.password = password
        self.smtpClient = client
    }

    func send(emailParameters: JobController.EmailParameters) async throws {
        
        let emailText = "Hello from Hummingbird"
        let emailHtml = "<p>Hello from Hummingbird</p>"
        do {
            let mail = Mail(
                from: MailUser(name: "SwiftJobs", email: "swiftjobs@hummingbird.org"),
                to: [MailUser(name: "Hummingbird", email: emailParameters.to.first!)],
                subject: emailParameters.subject) {
                    Mail.Content.alternative(emailText, html: emailHtml)
                }

            try await smtpClient.login(
                user: username,
                password: password)

            try await smtpClient.sendMail(mail)
        } catch {
            logger.info("\(error)")
            logger.info(
                "Failed to send email",
                metadata: [
                    "error.message": "\(String(reflecting: error))"
                ])
            throw error
        }
    }
}
