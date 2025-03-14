import Foundation
import Amplify
import AWSPluginsCore

#if os(iOS) || os(macOS) || os(visionOS)
extension AWSAuthWebUISignInTask {
    
    func log(message: String) {
        log.verbose("\(message)")
    }
}
#endif