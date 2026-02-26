## REMOVED Requirements

### Requirement: Preview is presented as a bottom drawer
**Reason**: The bottom-sheet preview drawer is replaced by a full-screen preview mode accessed via the Raw/Preview segmented toggle. The preview now occupies the entire screen when active instead of being a draggable drawer.
**Migration**: Preview is shown by tapping the "Preview" segment in the floating bottom bar toggle. No drawer drag interaction exists.

### Requirement: Drawer transitions preserve rendered content continuity
**Reason**: With the drawer removed, there are no drawer transitions to preserve. Content continuity is now handled by the blur morph transition between raw and preview modes, and by keeping the WKWebView loaded in background.
**Migration**: The WKWebView remains alive and updated reactively. Switching to preview mode reveals the latest rendered content without reload.
