import Hummingbird
import HummingbirdRouter
import NIOCore

struct AppContext: RouterRequestContext, RequestContext {

    var coreContext: CoreRequestContextStorage

    var routerContext: RouterBuilderContext

    let channel: Channel?

    /// Connected host address
    var remoteAddress: SocketAddress? {
        guard let channel else { return nil }
        return channel.remoteAddress
    }

    init(source: Source) {
        self.coreContext = .init(source: source)
        self.routerContext = .init()
        self.channel = source.channel
    }
}
