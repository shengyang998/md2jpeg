## Context

The app currently presents markdown editing and rendered preview in a fixed layout. This supports live preview but does not let users quickly prioritize one mode (editing or preview) at full screen. The requested interaction is a bottom-anchored preview drawer that users can pull up to focus on preview and dismiss downward to return to full-screen editing.

This change is UI- and interaction-heavy, and it touches editor container layout, gesture coordination, and preview visibility state, while preserving existing markdown rendering and export behavior.

## Goals / Non-Goals

**Goals:**
- Introduce a bottom drawer presentation for preview with clear collapsed and expanded states.
- Allow upward drag to expand preview to full screen.
- Allow downward gesture to collapse/hide preview so editing occupies full screen.
- Keep current markdown rendering behavior and content fidelity unchanged.
- Ensure transitions are smooth and do not break text editing responsiveness.

**Non-Goals:**
- Redesign markdown rendering pipeline, theme system, or export implementation.
- Add new markdown syntax support.
- Introduce multi-stop drawer states beyond what is needed for hidden and full preview.

## Decisions

- Use an explicit drawer state machine (`hidden`, `dragging`, `expanded`) owned by the editor/preview container view model/controller.  
  - Rationale: Centralized state avoids ad-hoc constraint updates and makes behavior testable.
  - Alternative considered: deriving state solely from layout constraint values; rejected because behavior becomes harder to reason about and unit test.

- Implement gesture-driven transitions with threshold and velocity-based settling.  
  - Rationale: Users expect bottom-sheet interactions to settle naturally based on drag distance and swipe intent.
  - Alternative considered: fixed toggle button only; rejected because it does not satisfy the requested draw-up / scroll-down interaction.

- Keep preview web view mounted while drawer is hidden, but clipped/off-screen.  
  - Rationale: Avoid expensive re-initialization and preserve fast reveal with already-rendered content.
  - Alternative considered: destroying/recreating preview view on each open; rejected due to potential rendering flicker and state loss.

- Gate gesture handling to avoid conflict with markdown editor scrolling.  
  - Rationale: Downward collapse should be recognized primarily when preview is at top and user intent is to dismiss, while editing should remain smooth when drawer is hidden.
  - Alternative considered: global pan recognizer that always wins; rejected due to poor text editing ergonomics.

- Add UI and interaction tests around drawer state transitions and editing focus restoration.  
  - Rationale: Gesture behavior can regress easily without scenario-based test coverage.

## Risks / Trade-offs

- Gesture conflict between preview scroll and drawer drag could cause accidental collapse/expand. -> Mitigation: require top-edge conditions and velocity/distance thresholds before state transition.
- Layout animation jank on older devices. -> Mitigation: animate constraint updates on main thread with minimal recomposition and avoid unnecessary web view reloads.
- Keyboard and safe-area interactions may produce clipped content during transitions. -> Mitigation: explicitly account for bottom safe-area and keyboard frame changes in drawer layout calculations.
- Hidden-but-mounted preview consumes memory. -> Mitigation: retain single web view instance and avoid duplicate previews; monitor with existing memory-bounded export safeguards.
