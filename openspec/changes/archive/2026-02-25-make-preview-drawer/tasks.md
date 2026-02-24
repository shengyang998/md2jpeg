## 1. Drawer state and layout foundation

- [x] 1.1 Add preview drawer state model (`hidden`, `dragging`, `expanded`) in the editor/preview container layer.
- [x] 1.2 Refactor editor/preview layout constraints so preview is bottom-anchored and can transition between hidden and full-screen states.
- [x] 1.3 Ensure the preview web view remains mounted across drawer transitions without triggering renderer reinitialization.

## 2. Gesture and interaction behavior

- [x] 2.1 Implement upward drag gesture handling with distance/velocity thresholds to settle into expanded full-screen preview.
- [x] 2.2 Implement downward drag/scroll-to-dismiss behavior from expanded preview to hidden drawer with threshold-based settling.
- [x] 2.3 Add gesture coordination rules to avoid conflicts between preview content scrolling and drawer transition gestures.

## 3. Editor/preview experience integration

- [x] 3.1 Update editor visibility/focus behavior so hidden drawer restores full-screen editing and expanded drawer prioritizes preview.
- [x] 3.2 Preserve live markdown rendering updates and rendered content continuity during and after drawer transitions.
- [x] 3.3 Handle keyboard and safe-area adjustments so drawer animation and editor layout remain stable across device states.

## 4. Validation and regression protection

- [x] 4.1 Add or update unit/UI tests for drawer state transitions (hidden <-> expanded) and gesture threshold behavior.
- [ ] 4.2 Add tests ensuring preview content (including tables and Mermaid diagrams) remains rendered correctly after expand/collapse flows.
- [ ] 4.3 Execute regression checks for editing responsiveness and existing export behavior after drawer integration.
