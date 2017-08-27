import UIKit
import YogaKit
import JavaScriptCore

class Renderer: NSObject {

    typealias Json = [String : Any]

    // access the root view controller
    static var rootView : UIView? = nil
    static let viewController : ViewController = {
        let window = UIApplication.shared.keyWindow!
        return window.rootViewController as! ViewController
    }()


    // RENDER


    static func initialRender(view: Json, handlers: [Json]) {
        var handlersIndex = 0
        if let renderedView = render(virtualView: view, offset: 0, handlers: handlers, handlersIndex: &handlersIndex) {
            rootView = renderedView
            viewController.addToRootView(subview: renderedView)
            viewController.redrawRootView()
        }
    }

    static func render(virtualView: Json, offset: Int, handlers: [Json], handlersIndex: inout Int) -> UIView? {
        if let type = virtualView["type"] as? String {
            switch type {
            case "thunk":
                if let node = virtualView["node"] as? Json {
                    return render(virtualView: node, offset: offset, handlers: handlers, handlersIndex: &handlersIndex)
                }
            case "tagger":
                if let node = virtualView["node"] as? Json {
                    return render(virtualView: node, offset: offset + 1, handlers: handlers, handlersIndex: &handlersIndex)
                }
            case "parent":
                if let facts = virtualView["facts"] as? Json, let children = virtualView["children"] as? [Json] {
                    let view: UIView = UIView()

                    applyFacts(view: view, facts: facts, tag: "parent")

                    var offsetRef = offset
                    for child in children {
                        offsetRef += 1
                        if let renderedChild = render(virtualView: child, offset: offsetRef, handlers: handlers, handlersIndex: &handlersIndex) {
                            view.addSubview(renderedChild)
                        }
                        offsetRef += child["descendantsCount"] as? Int ?? 0
                    }

                    return view
                }
            case "leaf":
                if let tag = virtualView["tag"] as? String, let facts = virtualView["facts"] as? Json {
                    switch tag {
                    case "label":
                        let label: UILabel = UILabel()
                        applyFacts(view: label, facts: facts, tag: tag)
                        return label
                    case "button":
                        let button: UIButton = UIButton(type: .system)

                        applyFacts(view: button, facts: facts, tag: tag)

                        if !handlers.isEmpty {
                            let handlerNode = handlers[handlersIndex] as Json
                            if let handlerOffset = handlerNode["offset"] as? Int, handlerOffset == offset, let funcs = handlerNode["funcs"] as? Json, let eventId = handlerNode["eventId"] as? UInt64 {
                                addControlHandlers(funcs, id: eventId, view: button)
                                handlersIndex += 1
                            }
                        }

                        return button
                    case "image":
                        if let src = facts["src"] as? String, let imageUrl = URL(string: "assets/" + src) {
                            let fileName = imageUrl.deletingPathExtension().lastPathComponent
                            let fileExtension = imageUrl.pathExtension
                            let directory = imageUrl.deletingLastPathComponent().absoluteString

                            if let imagePath = Bundle.main.path(forResource: fileName, ofType: fileExtension, inDirectory: directory), let imageData = UIImage(contentsOfFile: imagePath) {
                                let image: UIImageView = UIImageView(image: imageData)

                                applyFacts(view: image, facts: facts, tag: tag)

                                return image
                            }
                        }
                        return nil
                    default:
                        return nil
                    }
                }
            default:
                return nil
            }
        }
        return nil
    }


    // ADD UIKIT NODES TO PATCHES


    static func addUIKitNodes(view: UIView, patch: inout Json) {
        if let ctor = patch["ctor"] as? String {
            switch ctor {
            case "change":
                patch["node"] = view
                break
            case "at":
                if let index = patch["index"] as? Int, var subpatch = patch["patch"] as? Json {
                    addUIKitNodes(view: view.subviews[index], patch: &subpatch)
                    patch["patch"] = subpatch
                }
                break
            case "batch":
                if var patches = patch["patches"] as? [Json] {
                    for i in 0..<patches.count {
                        addUIKitNodes(view: view, patch: &patches[i])
                    }
                    patch["patches"] = patches
                }
                break
            default:
                break
            }
        }
    }


    // APPLY PATCHES


    static func applyPatches(_ patches: inout Json) {
        if let root = rootView {
            addUIKitNodes(view: root, patch: &patches)
            applyPatchesHelp(patches)
            root.yoga.applyLayout(preservingOrigin: true)
        }
    }

    static func applyPatchesHelp(_ patch: Json) {
        if let ctor = patch["ctor"] as? String {
            switch ctor {
            case "change":
                applyPatch(patch)
                break
            case "at":
                if let subpatch = patch["patch"] as? Json {
                    applyPatchesHelp(subpatch)
                }
                break
            case "batch":
                if let patches = patch["patches"] as? [Json] {
                    for p in patches {
                        applyPatchesHelp(p)
                    }
                }
                break
            default:
                break
            }
        }
    }

    static func applyPatch(_ patch: Json) {
        if let type = patch["type"] as? String, let node = patch["node"] as? UIView {
            switch type {
            case "redraw":
                if let data = patch["data"] as? Json, let vNode = data["vNode"] as? Json, let handlerList = data["handlerList"] as? [Json], let offset = data["offset"] as? Int {
                    var handlersIndex = 0
                    if let newNode = render(virtualView: vNode, offset: offset, handlers: handlerList, handlersIndex: &handlersIndex), let parent = node.superview {
                        if offset == 0 {
                            rootView = newNode
                            viewController.addToRootView(subview: newNode)
                            node.removeFromSuperview()
                            viewController.redrawRootView()
                        } else {
                            parent.insertSubview(newNode, belowSubview: node)
                            node.removeFromSuperview()
                        }
                    }
                }
                return
            case "facts":
                if let facts = patch["data"] as? Json, let tag = facts["tag"] as? String {
                    applyFacts(view: node, facts: facts, tag: tag)
                }
                return
            case "append":
                if let data = patch["data"] as? Json, let children = data["vNode"] as? [Json], let handlerList = data["handlerList"] as? [Json], let offset = data["offset"] as? Int {
                    var handlersIndex = 0
                    for virtualChild in children {
                        if let child = render(virtualView: virtualChild, offset: offset, handlers: handlerList, handlersIndex: &handlersIndex) {
                            node.addSubview(child)
                        }
                    }
                }
                return
            case "remove-last":
                if var amount = patch["data"] as? Int {
                    let subviews : [UIView] = node.subviews
                    let subviewsLength = subviews.count
                    amount = min(amount, subviewsLength)
                    while amount > 0 {
                        subviews[subviewsLength - amount].removeFromSuperview()
                        amount -= 1;
                    }
                }
                return
            case "add-handlers":
                if let data = patch["data"] as? Json, let funcs = data["funcs"] as? Json, let id = data["eventId"] as? UInt64, let control = node as? UIControl {
                    addControlHandlers(funcs, id: id, view: control)
                }
                return
            case "remove-handlers":
                if let handlers = patch["data"] as? [String], let control = node as? UIControl {
                    removeControlHandlers(handlers, view: control)
                }
                return
            case "remove-all-handlers":
                if let control = node as? UIControl {
                    control.removeTarget(nil, action: nil, for: .allEvents)
                    objc_setAssociatedObject(control, UIControlActionFunctionProtocolAssociatedObjectKey, nil, .OBJC_ASSOCIATION_RETAIN)
                }
                return
            default:
                return
            }
        }
    }


    /* APPLY HANDLERS */


    static func addControlHandlers(_ handlers: Json, id: UInt64, view: UIControl) {
        for name in handlers.keys {
            if let eventType = extractEventType(name) {
                view.addAction(event: eventType, { (_, event) in
                    viewController.handleEvent(id: id, name: name, data: event)
                })
            }
        }
    }

    static func removeControlHandlers(_ handlers: [String], view: UIControl) {
        for handlerName in handlers {
            if let eventType = extractEventType(handlerName) {
                view.removeTarget(nil, action: nil, for: eventType)
            }
        }
    }


    /* APPLY FACTS */


    static func applyFacts(view: UIView, facts: Json, tag: String) {
        switch tag {
        case "label":
            applyLabelFacts(label: view as! UILabel, facts: facts)
            break
        case "button":
            applyButtonFacts(button: view as! UIButton, facts: facts)
            break
        case "parent":
            applyViewFacts(view: view, facts: facts)
            break
        default:
            break
        }

        if let yogaFacts = facts["YOGA"] as? Json {
            applyYogaFacts(view: view, facts: yogaFacts)
        } else {
            view.yoga.isEnabled = true
        }
    }

    static func applyLabelFacts(label: UILabel, facts: Json) {
        for key in facts.keys {
            switch key {
            case "text":
                if let value = facts[key] as? String {
                    label.text = value
                } else {
                    label.text = nil
                }
                label.yoga.markDirty()
                break
            case "textColor":
                if let value = facts[key] as? [Float] {
                    label.textColor = extractColor(value)
                } else {
                    label.textColor = .black
                }
                break
            case "textAlignment":
                if let value = facts[key] as? String {
                    if let alignment = extractTextAlignment(value) {
                        // store as Int in JSON and use rawValue
                        label.textAlignment = alignment
                    }
                } else {
                    label.textAlignment = .natural // prior to iOS 9.0, `left` was the default
                }
                break
            case "font":
                if let value = facts[key] as? String {
                    label.font = UIFont(name: value, size: label.font.pointSize)
                } else {
                    label.font = UIFont.systemFont(ofSize: label.font.pointSize)
                }
                break
            case "fontSize":
                if let value = facts[key] as? CGFloat {
                    label.font = label.font.withSize(value)
                } else {
                    label.font = label.font.withSize(UIFont.systemFontSize)
                }
                break
            case "numberOfLines":
                if let value = facts[key] as? Int {
                    label.numberOfLines = value
                } else {
                    label.numberOfLines = 1
                }
                break
            case "lineBreakMode":
                if let value = facts[key] as? String {
                    if let lineBreakMode = extractLineBreakMode(value) {
                        // store as Int in JSON and use rawValue
                        label.lineBreakMode = lineBreakMode
                    }
                } else {
                    label.lineBreakMode = .byTruncatingTail
                }
                break
            case "shadowColor":
                if let value = facts[key] as? [Float] {
                    label.shadowColor = extractColor(value)
                } else {
                    label.shadowColor = nil
                }
                break
            case "shadowOffset":
                if let value = facts[key] as? [Double] {
                    label.shadowOffset = CGSize(width: value[0], height: value[1])
                } else {
                    label.shadowOffset = CGSize(width: 0, height: -1)
                }
                break
            default:
                break
            }
        }
    }

    static func applyButtonFacts(button: UIButton, facts: Json) {
        for key in facts.keys {
            switch key {
            case "text":
                if let value = facts[key] as? String {
                    button.setTitle(value, for: .normal)
                    button.yoga.markDirty()
                } else {
                    // TODO double check that nil is the default value
                    button.setTitle(nil, for: .normal)
                }
                break
            case "textColor":
                if let value = facts[key] as? [Float] {
                    button.setTitleColor(extractColor(value), for: .normal)
                } else {
                    button.setTitleColor(extractColor([0.0, 122.0, 255.0, 1.0]), for: .normal)
                }
            case "shadowColor":
                if let value = facts[key] as? [Float] {
                    button.setTitleShadowColor(extractColor(value), for: .normal)
                } else {
                    // TODO double check that nil is the default value
                    button.setTitleShadowColor(nil, for: .normal)
                }
            default:
                break
            }
        }

        if let label = button.titleLabel {
            applyLabelFacts(label: label, facts: facts)
        }
    }

    static func applyViewFacts(view: UIView, facts: Json) {
        for key in facts.keys {
            switch key {
            case "backgroundColor":
                if let value = facts[key] as? [Float] {
                    view.backgroundColor = extractColor(value)
                } else {
                    view.backgroundColor = nil
                }
                break
            default:
                break
            }
        }
    }

    static func applyYogaFacts(view: UIView, facts: Json) {
        view.configureLayout { (layout) in
            layout.isEnabled = true

            for key in facts.keys {
                switch key {
                case "flexDirection":
                    if let value = facts[key] as? String {
                        if let flexDirection = extractFlexDirection(value) {
                            // store as Int in JSON and use rawValue
                            layout.flexDirection = flexDirection
                        }
                    } else {
                        layout.flexDirection = .column
                    }
                    break
                case "justifyContent":
                    if let value = facts[key] as? String {
                        if let justify = extractJustify(value) {
                            // store as Int in JSON and use rawValue
                            layout.justifyContent = justify
                        }
                    } else {
                        layout.justifyContent = .flexStart
                    }
                    break
                case "flexWrap":
                    if let value = facts[key] as? String {
                        if let wrap = extractWrap(value) {
                            // store as Int in JSON and use rawValue
                            layout.flexWrap = wrap
                        }
                    } else {
                        layout.flexWrap = .noWrap
                    }
                    break
                case "alignItems":
                    if let value = facts[key] as? String {
                        if let align = extractAlign(value) {
                            // store as Int in JSON and use rawValue
                            layout.alignItems = align
                        }
                    } else {
                        layout.alignItems = .stretch
                    }
                    break
                case "alignContent":
                    if let value = facts[key] as? String {
                        if let align = extractAlign(value) {
                            // store as Int in JSON and use rawValue
                            layout.alignContent = align
                        }
                    } else {
                        layout.alignContent = .flexStart
                    }
                    break
                case "direction":
                    if let value = facts[key] as? String {
                        if let direction = extractTextDirection(value) {
                            layout.direction = direction
                        }
                    } else {
                        layout.direction = .inherit
                        // default for root is actually LTR, but I think using pseudo root handles this
                    }
                    break
                case "alignSelf":
                    if let value = facts[key] as? String {
                        if let align = extractAlign(value) {
                            // store as Int in JSON and use rawValue
                            layout.alignSelf = align
                        }
                    } else {
                        layout.alignSelf = .auto
                    }
                    break
                case "position":
                    if let value = facts[key] as? String {
                        if let position = extractPositionType(value) {
                            layout.position = position
                        }
                    } else {
                        layout.position = .relative
                    }
                    break
                case "flexBasis":
                    if let value = facts[key] as? Float {
                        layout.flexBasis = YGValue(value)
                    } else {
                        layout.flexBasis = YGValue(Float.nan)
                    }
                    break
                case "left":
                    if let value = facts[key] as? Float {
                        layout.left = YGValue(value)
                    } else {
                        layout.left = YGValue(Float.nan)
                    }
                    break
                case "top":
                    if let value = facts[key] as? Float {
                        layout.top = YGValue(value)
                    } else {
                        layout.top = YGValue(Float.nan)
                    }
                    break
                case "right":
                    if let value = facts[key] as? Float {
                        layout.right = YGValue(value)
                    } else {
                        layout.right = YGValue(Float.nan)
                    }
                    break
                case "bottom":
                    if let value = facts[key] as? Float {
                        layout.bottom = YGValue(value)
                    } else {
                        layout.bottom = YGValue(Float.nan)
                    }
                    break
                case "start":
                    if let value = facts[key] as? Float {
                        layout.start = YGValue(value)
                    } else {
                        layout.start = YGValue(Float.nan)
                    }
                    break
                case "end":
                    if let value = facts[key] as? Float {
                        layout.end = YGValue(value)
                    } else {
                        layout.end = YGValue(Float.nan)
                    }
                    break
                case "minWidth":
                    if let value = facts[key] as? Float {
                        layout.minWidth = YGValue(value)
                    } else {
                        layout.minWidth = YGValue(Float.nan)
                    }
                    break
                case "minHeight":
                    if let value = facts[key] as? Float {
                        layout.minHeight = YGValue(value)
                    } else {
                        layout.minHeight = YGValue(Float.nan)
                    }
                    break
                case "maxWidth":
                    if let value = facts[key] as? Float {
                        layout.maxWidth = YGValue(value)
                    } else {
                        layout.maxWidth = YGValue(Float.nan)
                    }
                    break
                case "maxHeight":
                    if let value = facts[key] as? Float {
                        layout.maxHeight = YGValue(value)
                    } else {
                        layout.maxHeight = YGValue(Float.nan)
                    }
                    break
                case "width":
                    if let value = facts[key] as? Float {
                        layout.width = YGValue(value)
                    } else {
                        layout.width = YGValue(Float.nan)
                    }
                    break
                case "height":
                    if let value = facts[key] as? Float {
                        layout.height = YGValue(value)
                    } else {
                        layout.height = YGValue(Float.nan)
                    }
                    break
                case "margin":
                    if let value = facts[key] as? Float {
                        layout.margin = YGValue(value)
                    } else {
                        layout.margin = YGValue(Float.nan)
                    }
                    break
                case "marginLeft":
                    if let value = facts[key] as? Float {
                        layout.marginLeft = YGValue(value)
                    } else {
                        layout.marginLeft = YGValue(Float.nan)
                    }
                    break
                case "marginTop":
                    if let value = facts[key] as? Float {
                        layout.marginTop = YGValue(value)
                    } else {
                        layout.marginTop = YGValue(Float.nan)
                    }
                    break
                case "marginRight":
                    if let value = facts[key] as? Float {
                        layout.marginRight = YGValue(value)
                    } else {
                        layout.marginRight = YGValue(Float.nan)
                    }
                    break
                case "marginBottom":
                    if let value = facts[key] as? Float {
                        layout.marginBottom = YGValue(value)
                    } else {
                        layout.marginBottom = YGValue(Float.nan)
                    }
                    break
                case "marginStart":
                    if let value = facts[key] as? Float {
                        layout.marginStart = YGValue(value)
                    } else {
                        layout.marginStart = YGValue(Float.nan)
                    }
                    break
                case "marginEnd":
                    if let value = facts[key] as? Float {
                        layout.marginEnd = YGValue(value)
                    } else {
                        layout.marginEnd = YGValue(Float.nan)
                    }
                    break
                case "marginVertical":
                    if let value = facts[key] as? Float {
                        layout.marginVertical = YGValue(value)
                    } else {
                        layout.marginVertical = YGValue(Float.nan)
                    }
                    break
                case "marginHorizontal":
                    if let value = facts[key] as? Float {
                        layout.marginHorizontal = YGValue(value)
                    } else {
                        layout.marginHorizontal = YGValue(Float.nan)
                    }
                    break
                case "padding":
                    if let value = facts[key] as? Float {
                        layout.padding = YGValue(value)
                    } else {
                        layout.padding = YGValue(Float.nan)
                    }
                    break
                case "paddingLeft":
                    if let value = facts[key] as? Float {
                        layout.paddingLeft = YGValue(value)
                    } else {
                        layout.paddingLeft = YGValue(Float.nan)
                    }
                    break
                case "paddingTop":
                    if let value = facts[key] as? Float {
                        layout.paddingTop = YGValue(value)
                    } else {
                        layout.paddingTop = YGValue(Float.nan)
                    }
                    break
                case "paddingRight":
                    if let value = facts[key] as? Float {
                        layout.paddingRight = YGValue(value)
                    } else {
                        layout.paddingRight = YGValue(Float.nan)
                    }
                    break
                case "paddingBottom":
                    if let value = facts[key] as? Float {
                        layout.paddingBottom = YGValue(value)
                    } else {
                        layout.paddingBottom = YGValue(Float.nan)
                    }
                    break
                case "paddingStart":
                    if let value = facts[key] as? Float {
                        layout.paddingStart = YGValue(value)
                    } else {
                        layout.paddingStart = YGValue(Float.nan)
                    }
                    break
                case "paddingEnd":
                    if let value = facts[key] as? Float {
                        layout.paddingEnd = YGValue(value)
                    } else {
                        layout.paddingEnd = YGValue(Float.nan)
                    }
                    break
                case "paddingVertical":
                    if let value = facts[key] as? Float {
                        layout.paddingVertical = YGValue(value)
                    } else {
                        layout.paddingVertical = YGValue(Float.nan)
                    }
                    break
                case "paddingHorizontal":
                    if let value = facts[key] as? Float {
                        layout.paddingHorizontal = YGValue(value)
                    } else {
                        layout.paddingHorizontal = YGValue(Float.nan)
                    }
                    break
                case "flexGrow":
                    if let value = facts[key] as? Float {
                        layout.flexGrow = CGFloat(value)
                    } else {
                        layout.flexGrow = 0.0
                    }
                    break
                case "flexShrink":
                    if let value = facts[key] as? Float {
                        layout.flexShrink = CGFloat(value)
                    } else {
                        layout.flexShrink = 0.0
                    }
                    break

                case "borderWidth":
                    if let value = facts[key] as? Float {
                        layout.borderWidth = CGFloat(value)
                    } else {
                        layout.borderWidth = CGFloat(Float.nan)
                    }
                    break
                case "borderLeftWidth":
                    if let value = facts[key] as? Float {
                        layout.borderLeftWidth = CGFloat(value)
                    } else {
                        layout.borderLeftWidth = CGFloat(Float.nan)
                    }
                    break
                case "borderTopWidth":
                    if let value = facts[key] as? Float {
                        layout.borderTopWidth = CGFloat(value)
                    } else {
                        layout.borderTopWidth = CGFloat(Float.nan)
                    }
                    break
                case "borderRightWidth":
                    if let value = facts[key] as? Float {
                        layout.borderRightWidth = CGFloat(value)
                    } else {
                        layout.borderRightWidth = CGFloat(Float.nan)
                    }
                    break
                case "borderBottomWidth":
                    if let value = facts[key] as? Float {
                        layout.borderBottomWidth = CGFloat(value)
                    } else {
                        layout.borderBottomWidth = CGFloat(Float.nan)
                    }
                    break
                case "borderStartWidth":
                    if let value = facts[key] as? Float {
                        layout.borderStartWidth = CGFloat(value)
                    } else {
                        layout.borderStartWidth = CGFloat(Float.nan)
                    }
                    break
                case "borderEndWidth":
                    if let value = facts[key] as? Float {
                        layout.borderEndWidth = CGFloat(value)
                    } else {
                        layout.borderEndWidth = CGFloat(Float.nan)
                    }
                    break
                case "aspectRatio":
                    if let value = facts[key] as? Float {
                        layout.aspectRatio = CGFloat(value)
                    } else {
                        layout.aspectRatio = CGFloat(Float.nan)
                    }
                    break
                default:
                    break
                }
            }
        }
    }


    // Enum values from String


    static func extractEventType(_ handler: String) -> UIControlEvents? {
        switch handler {
        case "valueChanged":
            return .valueChanged
        case "touchUpInside":
            return .touchUpInside
        case "touchUpOutside":
            return .touchUpOutside
        case "touchDown":
            return .touchDown
        case "touchDownRepeat":
            return .touchDownRepeat
        case "touchCancel":
            return .touchCancel
        case "touchDragInside":
            return .touchDragInside
        case "touchDragOutside":
            return .touchDragOutside
        case "touchDragEnter":
            return .touchDragEnter
        case "touchDragExit":
            return .touchDragExit
        case "allTouchEvents":
            return .allTouchEvents
        default:
            return nil
        }
    }

    static func extractTextAlignment(_ alignment: String) -> NSTextAlignment? {
        switch alignment {
        case "left":
            return .left
        case "right":
            return .right
        case "center":
            return .center
        case "justified":
            return .justified
        case "natural":
            return .natural
        default:
            return nil
        }
    }

    static func extractColor(_ rgba: [Float]) -> UIColor {
        return UIColor(red: CGFloat(rgba[0] / 255), green: CGFloat(rgba[1] / 255), blue: CGFloat(rgba[2] / 255), alpha: CGFloat(rgba[3]))
    }

    static func extractLineBreakMode(_ lineBreakMode: String) -> NSLineBreakMode? {
        switch lineBreakMode {
        case "byWordWrapping":
            return .byWordWrapping
        case "byCharWrapping":
            return .byCharWrapping
        case "byClipping":
            return .byClipping
        case "byTruncatingHead":
            return .byTruncatingHead
        case "byTruncatingTail":
            return .byTruncatingTail
        case "byTruncatingMiddle":
            return .byTruncatingMiddle
        default:
            return nil
        }
    }

    static func extractFlexDirection(_ direction: String) -> YGFlexDirection? {
        switch direction {
        case "row":
            return .row
        case "colum":
            return .column
        case "rowReverse":
            return .rowReverse
        case "columnReverse":
            return .columnReverse
        default:
            return nil
        }
    }

    static func extractJustify(_ justify: String) -> YGJustify? {
        switch justify {
        case "flexStart":
            return .flexStart
        case "flexEnd":
            return .flexEnd
        case "center":
            return .center
        case "spaceBetween":
            return .spaceBetween
        case "spaceAround":
            return .spaceAround
        default:
            return nil
        }
    }

    static func extractWrap(_ wrap: String) -> YGWrap? {
        switch wrap {
        case "noWrap":
            return .noWrap
        case "wrap":
            return .wrap
        case "wrapReverse":
            return .wrapReverse
        default:
            return nil
        }
    }

    static func extractAlign(_ align: String) -> YGAlign? {
        switch align {
        case "auto":
            return .auto
        case "baseline":
            return .baseline
        case "spaceAround":
            return .spaceAround
        case "spaceBetween":
            return .spaceBetween
        case "stretch":
            return .stretch
        case "flexStart":
            return .flexStart
        case "flexEnd":
            return .flexEnd
        case "center":
            return .center
        default:
            return nil
        }
    }

    static func extractTextDirection(_ direction: String) -> YGDirection? {
        switch direction {
        case "inherit":
            return .inherit
        case "LTR":
            return .LTR
        case "RTL":
            return .RTL
        default:
            return nil
        }
    }

    static func extractPositionType(_ position: String) -> YGPositionType? {
        switch position {
        case "absolute":
            return .absolute
        case "relative":
            return .relative
        default:
            return nil

        }
    }

}


// Target-Action with Swift closures


class ActionTrampoline<T>: NSObject {
    var action: (T, UIEvent) -> Void
    init(action: @escaping (T, UIEvent) -> Void) {
        self.action = action
    }
    @objc func execute(sender: UIControl, forEvent event: UIEvent) {
        action(sender as! T, event)
    }
}

let UIControlActionFunctionProtocolAssociatedObjectKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

protocol UIControlActionFunctionProtocol {}
extension UIControlActionFunctionProtocol where Self: UIControl {
    func addAction(event: UIControlEvents, _ action: @escaping (Self, UIEvent) -> Void) {
        if let trampoline = objc_getAssociatedObject(self, UIControlActionFunctionProtocolAssociatedObjectKey) {
            self.addTarget(trampoline, action: #selector(ActionTrampoline<Self>.execute(sender:forEvent:)), for: event)
        } else {
            let trampoline = ActionTrampoline(action: action)
            self.addTarget(trampoline, action: #selector(ActionTrampoline<Self>.execute(sender:forEvent:)), for: event)
            objc_setAssociatedObject(self, UIControlActionFunctionProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)

        }
    }
}
extension UIControl: UIControlActionFunctionProtocol {}
