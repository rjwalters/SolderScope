import SwiftUI
import CoreImage

struct MicroscopeView: NSViewRepresentable {
    let captureManager: CaptureManager
    @Binding var transform: ViewTransform
    let isFrozen: Bool

    func makeNSView(context: Context) -> MicroscopeNSView {
        let view = MicroscopeNSView()
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: MicroscopeNSView, context: Context) {
        nsView.transform = transform
        nsView.isFrozen = isFrozen

        // Update frame if not frozen
        if !isFrozen, let frame = captureManager.latestFrame {
            nsView.setFrame(frame)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: MicroscopeNSViewDelegate {
        let parent: MicroscopeView

        init(_ parent: MicroscopeView) {
            self.parent = parent
        }

        func microscopeView(_ view: MicroscopeNSView, didZoom factor: CGFloat, at point: CGPoint) {
            guard let imageSize = view.imageSize else { return }
            parent.transform.zoom(
                by: factor,
                around: point,
                imageSize: imageSize,
                viewSize: view.bounds.size
            )
        }

        func microscopeView(_ view: MicroscopeNSView, didPan delta: CGPoint) {
            parent.transform.pan(by: delta)
        }

        func microscopeViewDidDoubleClick(_ view: MicroscopeNSView) {
            parent.transform.reset()
        }
    }
}

// MARK: - Delegate Protocol

protocol MicroscopeNSViewDelegate: AnyObject {
    func microscopeView(_ view: MicroscopeNSView, didZoom factor: CGFloat, at point: CGPoint)
    func microscopeView(_ view: MicroscopeNSView, didPan delta: CGPoint)
    func microscopeViewDidDoubleClick(_ view: MicroscopeNSView)
}

// MARK: - NSView Implementation

class MicroscopeNSView: NSView {
    weak var delegate: MicroscopeNSViewDelegate?

    var transform: ViewTransform = ViewTransform() {
        didSet { needsDisplay = true }
    }

    var isFrozen: Bool = false

    private var currentFrame: CIImage?
    private var frozenFrame: CIImage?
    private var ciContext: CIContext?

    private var isDragging: Bool = false
    private var lastDragPoint: CGPoint = .zero

    var imageSize: CGSize? {
        (isFrozen ? frozenFrame : currentFrame)?.extent.size
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor

        // Create CI context for rendering
        ciContext = CIContext(options: [
            .useSoftwareRenderer: false,
            .priorityRequestLow: false
        ])

        // Enable mouse tracking
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }

    func setFrame(_ image: CIImage) {
        if isFrozen {
            if frozenFrame == nil {
                frozenFrame = image
            }
        } else {
            currentFrame = image
            frozenFrame = nil
            needsDisplay = true
        }
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext,
              let ciContext = ciContext else { return }

        // Fill background
        context.setFillColor(NSColor.black.cgColor)
        context.fill(bounds)

        // Get the frame to display
        let frameToDisplay = isFrozen ? frozenFrame : currentFrame
        guard let image = frameToDisplay else { return }

        let imageSize = image.extent.size

        // Calculate transform
        let displayTransform = transform.applying(to: imageSize, in: bounds.size)

        // Apply transform and render
        context.saveGState()

        // Create transformed image
        let transformedImage = image.transformed(by: displayTransform)

        // Render to CGContext
        ciContext.draw(
            transformedImage,
            in: bounds,
            from: transformedImage.extent
        )

        context.restoreGState()
    }

    // MARK: - Mouse Events

    override func scrollWheel(with event: NSEvent) {
        let zoomFactor: CGFloat
        if event.hasPreciseScrollingDeltas {
            // Trackpad - use smaller increments
            zoomFactor = 1.0 + event.scrollingDeltaY * 0.01
        } else {
            // Mouse wheel
            zoomFactor = event.scrollingDeltaY > 0 ? 1.1 : 0.9
        }

        let location = convert(event.locationInWindow, from: nil)
        delegate?.microscopeView(self, didZoom: zoomFactor, at: location)
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            delegate?.microscopeViewDidDoubleClick(self)
        } else {
            isDragging = true
            lastDragPoint = convert(event.locationInWindow, from: nil)
            NSCursor.closedHand.push()
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }

        let currentPoint = convert(event.locationInWindow, from: nil)
        let delta = CGPoint(
            x: currentPoint.x - lastDragPoint.x,
            y: currentPoint.y - lastDragPoint.y
        )

        delegate?.microscopeView(self, didPan: delta)
        lastDragPoint = currentPoint
    }

    override func mouseUp(with event: NSEvent) {
        if isDragging {
            isDragging = false
            NSCursor.pop()
        }
    }

    override func cursorUpdate(with event: NSEvent) {
        if isDragging {
            NSCursor.closedHand.set()
        } else {
            NSCursor.openHand.set()
        }
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .openHand)
    }

    // MARK: - Keyboard Events

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        // Let the app handle keyboard shortcuts
        super.keyDown(with: event)
    }
}
