import UIKit
import YogaKit
import JavaScriptCore

class ViewController: UIViewController {

    static var nextTimerId = 0
    static var timerRegistry = [Int: Timer]()

    lazy var jsContext: JSContext? = {
        let context: JSContext = JSContext()

        // expose initialRender and applyPatches to JS global context
        let initialRender: @convention(block) ([String : Any], [[String : Any]]) -> Void = { (view, handlerList) in
            var handlerList = handlerList
            Renderer.initialRender(view: view, handlers: handlerList)
        }
        context.setObject(initialRender, forKeyedSubscript: "initialRender" as (NSCopying & NSObjectProtocol)!)

        let applyPatches: @convention(block) ([String : Any]) -> Void = { (patches) in
            var patches = patches
            Renderer.applyPatches(&patches)
        }
        context.setObject(applyPatches, forKeyedSubscript: "applyPatches" as (NSCopying & NSObjectProtocol)!)

        // expose Swift implementations of setTimeout, setInterval, and clearInterval to JS global context
        let setTimeout: @convention(block) (JSValue, Double) -> Void = { (function, timeout) in
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: { () -> Void in
                function.call(withArguments: [])
            })
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as (NSCopying & NSObjectProtocol)!)

        let setInterval: @convention(block) (JSValue, Double) -> Int = { (function, interval) in
            let timer = Timer.scheduledTimer(timeInterval: interval / 1000.0, repeats: true, action: { (timer) in
                function.call(withArguments: [])
            })

            let timerId = nextTimerId
            timerRegistry[timerId] = timer
            nextTimerId += 1
            return timerId
        }
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as (NSCopying & NSObjectProtocol)!)

        let clearInterval: @convention(block) (Int) -> Void = { id in
            if let timer = timerRegistry[id] {
                timer.invalidate()
                objc_setAssociatedObject(timer, TimerActionFunctionProtocolAssociatedObjectKey, nil, .OBJC_ASSOCIATION_RETAIN)
                timerRegistry.removeValue(forKey: id)
            }
        }
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as (NSCopying & NSObjectProtocol)!)

        // expose Swift implementations of console.* to JS global context
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("JS Console: " + message)
        }
        context.setObject(consoleLog, forKeyedSubscript: "consoleLog" as (NSCopying & NSObjectProtocol)!)

        // log JS exceptions
        context.exceptionHandler = { context, exception in
            print("JS Error: \(exception?.description ?? "unknown error")")
        }

        // load compiled Elm program
        guard let appJsPath = Bundle.main.path(forResource: "compiledElm", ofType: "js") else {
            return nil
        }

        do {
            let app = try String(contentsOfFile: appJsPath, encoding: String.Encoding.utf8)
            _ = context.evaluateScript(app)
        } catch (let error) {
            print("Error while processing script file: \(error)")
        }

        return context
    }()

    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)

        let containerSize: CGSize = self.view.bounds.size

        let root = self.view!
        root.backgroundColor = .white
        root.configureLayout { (layout) in
            layout.isEnabled = true
            layout.width = YGValue(containerSize.width)
            layout.height = YGValue(containerSize.height)
        }

        // launch Elm program once everything is loaded
        _ = jsContext?.objectForKeyedSubscript("Elm").objectForKeyedSubscript("Main").objectForKeyedSubscript("start").call(withArguments: [])
    }

    // recompute the layout when the device is rotated
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.configureLayout { (layout) in
            layout.width = YGValue(size.width)
            layout.height = YGValue(size.height)
        }
        redrawRootView()
    }

    // helper for adding the "pseudo root view" to the root view
    func addToRootView(subview: UIView) {
        self.view.addSubview(subview)
    }

    // helper for recomputing the entire layout
    func redrawRootView() {
        self.view.yoga.applyLayout(preservingOrigin: true)
    }

    // Swift interface for the handleEvent JS function that manages callbacks
    func handleEvent(id: UInt64, name: String, data: Any) {
        _ = jsContext?.objectForKeyedSubscript("Elm").objectForKeyedSubscript("Main").objectForKeyedSubscript("handleEvent").call(withArguments: [id, name, data])
    }

}


// Timers using Swift closures (polyfill for < iOS 10.0)


class TimerActionTrampoline: NSObject {
    var action: (Timer) -> Void
    init(action: @escaping (Timer) -> Void) {
        self.action = action
    }
    @objc func timerFireMethod(timer: Timer) {
        action(timer)
    }
}

let TimerActionFunctionProtocolAssociatedObjectKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

protocol TimerActionFunctionProtocol {}
extension TimerActionFunctionProtocol {
    static func scheduledTimer(timeInterval: Double, repeats: Bool, action: @escaping (Timer) -> Void) -> Timer {
        let trampoline = TimerActionTrampoline(action: action)
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: trampoline, selector: #selector(TimerActionTrampoline.timerFireMethod(timer:)), userInfo: nil, repeats: repeats)
        objc_setAssociatedObject(timer, TimerActionFunctionProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
        return timer
    }
}
extension Timer: TimerActionFunctionProtocol {}
