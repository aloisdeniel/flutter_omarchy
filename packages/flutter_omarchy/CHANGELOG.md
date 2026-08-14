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
