# SolderScope Milestones

This document outlines the development milestones, epics, and individual tasks for SolderScope.

---

## Milestone 0: Project Scaffolding

**Goal:** App runs, shows empty canvas, menus and shortcuts wired.

### Epic 0.1: Xcode Project Setup
- [ ] Create new macOS app project (SwiftUI lifecycle)
- [ ] Configure deployment target (macOS 13.0+)
- [ ] Set up code signing and entitlements
- [ ] Add camera usage description to Info.plist
- [ ] Configure sandbox entitlements for camera access

### Epic 0.2: Project Structure
- [ ] Create folder structure (Capture, Renderer, Calibration, Recording, Persistence, Utilities)
- [ ] Add placeholder files for core modules
- [ ] Set up basic logging utility (os.log)
- [ ] Create Constants.swift with app-wide values

### Epic 0.3: Basic App Shell
- [ ] Implement main window with placeholder view
- [ ] Add menu bar items (File, Edit, View, Window, Help)
- [ ] Wire up keyboard shortcuts (Space, S, R, I, B, 0, Esc)
- [ ] Create basic SettingsStore for UserDefaults

---

## Milestone 1: Camera Capture + Live Preview

**Goal:** Smooth live video, stable for 30+ minutes, low latency.

### Epic 1.1: Camera Enumeration
- [ ] Implement CameraDevice model (id, name, formats)
- [ ] Create CaptureManager class with AVCaptureSession
- [ ] Enumerate available video devices (AVCaptureDevice.DiscoverySession)
- [ ] Filter to external cameras (exclude FaceTime, etc.)
- [ ] Handle camera permission request flow

### Epic 1.2: Session Configuration
- [ ] Select best format (highest resolution, highest fps)
- [ ] Configure pixel format (BGRA preferred)
- [ ] Create dedicated capture queue (background)
- [ ] Implement AVCaptureVideoDataOutputSampleBufferDelegate
- [ ] Handle CMSampleBuffer → CVPixelBuffer conversion

### Epic 1.3: Frame Display
- [ ] Create MicroscopeView (NSViewRepresentable wrapping CIImage rendering)
- [ ] Implement CIContext for GPU-backed rendering
- [ ] Display frames with minimal latency
- [ ] Implement frame dropping under load (prefer latest frame)

### Epic 1.4: Camera UI
- [ ] Add camera selector dropdown to toolbar
- [ ] Show current camera name in window title or HUD
- [ ] Handle camera connect/disconnect events gracefully
- [ ] Show error state when no camera available

### Epic 1.5: Performance Monitoring
- [ ] Implement FPS counter
- [ ] Add optional FPS overlay (HUD)
- [ ] Log frame timing for performance analysis
- [ ] Verify 30+ minute stability

---

## Milestone 2: Zoom/Pan Controls

**Goal:** Feels like a microscope viewer—no jitter, no weird jumps.

### Epic 2.1: Transform State
- [ ] Create ViewTransform model (zoomFactor, panOffset)
- [ ] Implement base fit-to-window transform (letterboxing)
- [ ] Combine transforms: fit → zoom → pan
- [ ] Add rotation/flip state (for future use)

### Epic 2.2: Zoom Interaction
- [ ] Handle scroll wheel events
- [ ] Implement zoom around cursor position
- [ ] Set min/max zoom limits (0.1x to 20x suggested)
- [ ] Smooth zoom animation (optional)

### Epic 2.3: Pan Interaction
- [ ] Handle mouse drag events
- [ ] Update panOffset during drag
- [ ] Constrain pan to keep image partially visible
- [ ] Change cursor to grabbing hand during drag

### Epic 2.4: View Reset
- [ ] Implement double-click to reset view
- [ ] Wire `0` key to reset
- [ ] Animate reset transition (optional)

### Epic 2.5: Window Resize Handling
- [ ] Recalculate fit transform on resize
- [ ] Maintain view center (or cursor position) during resize
- [ ] Handle aspect ratio changes correctly

### Epic 2.6: Coordinate Utilities
- [ ] Implement CoordinateTransform utility
- [ ] Add viewToImage() function
- [ ] Add imageToView() function
- [ ] Unit tests for coordinate transforms

---

## Milestone 3: Scale Bar + Calibration

**Goal:** User can calibrate in <10 seconds, bar updates correctly with zoom.

### Epic 3.1: Calibration Data Model
- [ ] Define Calibration struct (cameraID, width, height, micronsPerPixel)
- [ ] Implement CalibrationManager for storage/retrieval
- [ ] Store calibrations in UserDefaults or JSON file
- [ ] Key calibrations by camera+resolution

### Epic 3.2: Scale Bar Toggle
- [ ] Add scale bar toggle button to toolbar
- [ ] Wire `B` key shortcut
- [ ] Store toggle state in SettingsStore
- [ ] Default to OFF

### Epic 3.3: Calibration Mode UI
- [ ] Detect missing calibration when scale bar enabled
- [ ] Show calibration mode overlay/prompt
- [ ] Implement line drawing tool (start point, end point)
- [ ] Show line preview during drawing
- [ ] Display line length in pixels

### Epic 3.4: Calibration Input
- [ ] Show length input dialog after line drawn
- [ ] Add preset buttons (0402=1.0mm, 0603=1.6mm, header=2.54mm, custom)
- [ ] Compute micronsPerPixel from line length and user input
- [ ] Save calibration to CalibrationManager
- [ ] Handle cancel (Esc key)

### Epic 3.5: Scale Bar Rendering
- [ ] Create ScaleBarCalculator utility
- [ ] Calculate effective µm per screen pixel (accounting for zoom)
- [ ] Select "nice" bar length from set [10,20,50,100,200,500,1000,2000,5000] µm
- [ ] Target bar width 120-250 screen pixels
- [ ] Format label (µm, mm, or cm as appropriate)

### Epic 3.6: Scale Bar Overlay
- [ ] Create OverlayRenderer for scale bar
- [ ] Position scale bar (bottom-left or bottom-right)
- [ ] Render bar with contrasting outline/shadow for visibility
- [ ] Update bar on zoom changes
- [ ] Add "Recalibrate..." menu item

---

## Milestone 4: Snapshots + Freeze Frame

**Goal:** Snapshots are easy and reliable.

### Epic 4.1: Freeze Frame
- [ ] Add freeze state to app model
- [ ] Wire Space key to toggle freeze
- [ ] Add freeze button to toolbar
- [ ] Show visual indicator when frozen (border, icon, or tint)
- [ ] Capture frame continues in background (for buffer)

### Epic 4.2: Snapshot Capture
- [ ] Implement SnapshotManager
- [ ] Capture current displayed frame (with current transforms)
- [ ] Option: capture with or without overlays
- [ ] Default: include overlays (scale bar is useful)

### Epic 4.3: Snapshot Export
- [ ] Generate filename: SolderScope_YYYYMMDD_HHMMSS.png
- [ ] Determine save location (Pictures folder or configurable)
- [ ] Save as PNG (fast, lossless enough)
- [ ] Optional: save as TIFF for truly lossless
- [ ] Wire `S` key shortcut
- [ ] Show save confirmation (subtle HUD or sound)

### Epic 4.4: Clipboard Support
- [ ] Add "Copy to Clipboard" option
- [ ] Copy current snapshot to pasteboard
- [ ] Optional keyboard shortcut (Cmd+C when frozen?)

---

## Milestone 5: Video Recording

**Goal:** Records >5 minutes without drift or frame drops beyond tolerance.

### Epic 5.1: Recording Setup
- [ ] Implement RecordingManager with AVAssetWriter
- [ ] Configure video codec (H.264 default, HEVC optional)
- [ ] Match input resolution and frame rate
- [ ] Set output location (Movies folder or configurable)
- [ ] Generate filename: SolderScope_YYYYMMDD_HHMMSS.mov

### Epic 5.2: Recording Pipeline
- [ ] Create AVAssetWriterInput for video
- [ ] Create pixel buffer adaptor
- [ ] Handle frame timing (presentation timestamps)
- [ ] Write frames from capture pipeline
- [ ] Handle frame drops gracefully (log, don't crash)

### Epic 5.3: Recording UI
- [ ] Add record button to toolbar
- [ ] Wire `R` key shortcut
- [ ] Show recording indicator (red dot, pulsing)
- [ ] Display elapsed time counter
- [ ] Stop recording on button press or `R` key

### Epic 5.4: Recording Options
- [ ] Choose: record raw feed vs processed (with overlays)
- [ ] Default: processed (what user sees)
- [ ] Settings UI for recording preferences
- [ ] Option: include audio from system mic (likely skip for v1)

### Epic 5.5: Recording Reliability
- [ ] Handle disk space warnings
- [ ] Handle camera disconnect during recording
- [ ] Ensure file is properly finalized on stop
- [ ] Test 5+ minute recordings
- [ ] Verify playback in QuickTime

---

## Milestone 6: Frame Integration

**Goal:** N-frame averaging visibly reduces noise on static scenes without ruining latency during motion.

### Epic 6.1: Frame Buffer
- [ ] Implement ring buffer for N frames
- [ ] Store frames as floating-point accumulators (or 16-bit)
- [ ] Handle buffer initialization and wraparound
- [ ] Clear buffer on integration N change

### Epic 6.2: Integration Processing
- [ ] Implement running sum/average
- [ ] Start with CPU implementation (Accelerate/vImage)
- [ ] Convert accumulated result back to display format
- [ ] Profile performance at 1080p and 4K

### Epic 6.3: Integration UI
- [ ] Add integration cycle button to toolbar
- [ ] Display current N value
- [ ] Wire `I` key shortcut
- [ ] Cycle: 1 → 2 → 4 → 8 → 16 → 1
- [ ] Default: 1 (lowest latency)

### Epic 6.4: Motion-Aware Integration (Optional)
- [ ] Detect user interaction (pan/zoom)
- [ ] Temporarily drop to N=1 during motion
- [ ] Return to selected N after interaction ends
- [ ] Make behavior optional in settings

### Epic 6.5: GPU Acceleration (If Needed)
- [ ] Profile CPU implementation at high resolutions
- [ ] If needed: implement Core Image or Metal version
- [ ] Maintain same API for swappable implementations

---

## Milestone 7: Measurement Tools (Stretch)

**Goal:** Draw and measure distances on the image.

### Epic 7.1: Measurement Mode
- [ ] Add measurement tool button
- [ ] Enter/exit measurement mode
- [ ] Show cursor change in measurement mode

### Epic 7.2: Line Measurements
- [ ] Draw measurement lines (separate from calibration)
- [ ] Calculate length using calibration data
- [ ] Display length label on line (µm/mm/in)
- [ ] Support multiple lines

### Epic 7.3: Measurement Management
- [ ] Select existing measurements (click)
- [ ] Delete measurements (Delete key or context menu)
- [ ] Clear all measurements option
- [ ] Optional: persist measurements with session

### Epic 7.4: Additional Tools (Future)
- [ ] Angle measurement tool
- [ ] Rectangle/area tool
- [ ] Circle/diameter tool

---

## Stretch Goals

These are valuable but not critical for v1:

### Quality of Life
- [ ] Auto exposure lock toggle
- [ ] White balance lock toggle
- [ ] Sharpness/contrast sliders
- [ ] Fullscreen mode (optimized for bench)
- [ ] Always-on-top window option
- [ ] "Bench mode" UI with large buttons
- [ ] Rotate/flip controls for microscope mounting

### Export Enhancements
- [ ] Include EXIF metadata in snapshots (scale, timestamp)
- [ ] Export measurements as CSV
- [ ] Annotate snapshots before saving

### Settings
- [ ] Preferences window
- [ ] Customizable save locations
- [ ] Customizable keyboard shortcuts
- [ ] Theme options (light/dark/auto)

---

## Testing Checklist

### Stability
- [ ] Run for 1+ hour continuously
- [ ] Resize window repeatedly
- [ ] Connect/disconnect camera multiple times
- [ ] Switch between cameras

### Calibration
- [ ] Calibrate with 2.54mm header pitch
- [ ] Verify against 0402 component (1.0mm)
- [ ] Check scale bar at multiple zoom levels

### Recording
- [ ] Record 5+ minute video
- [ ] Verify playback in QuickTime
- [ ] Check file sizes are reasonable

### Snapshots
- [ ] Verify PNG opens in Preview
- [ ] Check resolution matches expectations
- [ ] Confirm overlays appear when enabled

---

## Issue Labels

Use these labels when creating GitHub issues:

- `milestone:0-scaffolding`
- `milestone:1-capture`
- `milestone:2-zoom-pan`
- `milestone:3-scale-bar`
- `milestone:4-snapshot`
- `milestone:5-recording`
- `milestone:6-integration`
- `milestone:7-measurement`
- `type:feature`
- `type:bug`
- `type:enhancement`
- `type:documentation`
- `priority:high`
- `priority:medium`
- `priority:low`
