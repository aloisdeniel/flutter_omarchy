## 0.3.0

### New widgets

* `OmarchyDialog`, `showOmarchyDialog` and `showOmarchyConfirmDialog` for modal dialogs.
* `OmarchyContextMenuArea` and `showOmarchyContextMenu` for right-click context menus (with icons, shortcut hints, accents, disabled items and dividers).
* `showOmarchyToast` for transient notifications stacked at the bottom right of the screen.
* `OmarchySlider`, a horizontal slider with divisions and keyboard support.
* `OmarchyRadio`, a radio button for single-choice groups.
* `OmarchyBadge`, a small status/count label (filled and outlined).

### Improvements

* `OmarchyTab.closable` now actually invokes `onClose` when the close icon is pressed (with its own hover feedback).
* `OmarchyCommandPanel` keyboard navigation (arrows, Enter, Escape) now works, and the item list refreshes when `items` changes.
* `OmarchySelect` now highlights the currently selected option in the dropdown.
* `OmarchyCheckbox`, `OmarchyToggle` and the new `OmarchyRadio` accept a `focusNode` and show a focus highlight; `OmarchyButton` gained `autofocus`.
* `OmarchyTile` gained a `trailing` widget slot.
* `OmarchyResizeDivider` uses the correct resize cursor for vertical splits.
* `OmarchySplitPanel` respects `minPanelSize`/`maxPanelSize` while dragging and sizes the panel correctly in vertical orientation.
* `PanelSize.absolute` now resolves to its own size instead of the available space.
* `OmarchyStatusBar` renders `trailing` statuses with proper grouping.
* The Linux runner of the example (and the `omarchy_app` template) now waits for Flutter's first frame before showing the window, removing the black window at startup. See the README section "Avoid the Black Window at Startup".
* Lifecycle fixes: external `OmarchySidePanelController`s are no longer disposed by the panel, `OmarchyFocusBorder` disposes its internal focus node, and theme config reloads no longer call `setState` after unmount.

### Breaking changes

* `OmarchyDivider` semantics were inverted and have been fixed: `direction` is now the axis along which the line extends (`OmarchyDivider.horizontal()` is a full-width line for columns, `OmarchyDivider.vertical()` a full-height line for rows). The default is now horizontal.
* Removed the unused `padding` parameter of `OmarchyButton` (use the style's `padding` instead).
* Removed the unused `alignment` parameter of `OmarchyPopOverContainer`.
* Removed the unimplemented `OmarchyBordered` placeholder.

## 0.2.0

* Support for the latest Omarchy theming system: colors are now read from the canonical `~/.local/state/omarchy/current/theme/colors.toml` palette.
* Theme changes are now detected by watching the Omarchy state directory (the SIGUSR2 signal is kept for backwards compatibility with older Omarchy versions).
* Added `accent`, `selection`, `muted` and `brightness` to `OmarchyColorThemeData`.
* ANSI black now maps to the theme's `lighter_background` so that secondary surfaces and borders (dividers, tab bars, status bar) stay distinguishable from the background.
* Regenerated the fallback themes from the current stock Omarchy themes (now including all 22 of them).
* Removed the obsolete Walker CSS configuration (`WalkerConfig`).

## 0.1.15

* Added tile leading widget.
* Added OmarchyCommandPanel.
* Added OmarchyToggle.

## 0.1.14

* Added pop over animated transitions.

## 0.1.13

* Added OmarchyTree.
* Documentation.

## 0.1.12

* Fixed preview urls.
* Fixed SIGUSR2 listener logic.

## 0.1.11

* Removed debug prints.

## 0.1.10

* Listening for SIGUSR2 to trigger a theme reload.

## 0.1.9

* Exposing side panel.

## 0.1.8

* Exposing missing utils.
* Added icon logo.

## 0.1.7

* Added OmarchyPreview.

## 0.1.6

* Added SimulatedTap.

## 0.1.4

* Fixed status bar.

## 0.1.3

* Fixed text input web plarform.

## 0.1.2

* Fixed localization delegates on mobile.
* Added ProgressBar widget.

## 0.1.0

* Initial release of the package.
