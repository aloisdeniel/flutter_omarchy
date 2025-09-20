import 'package:flutter_omarchy/flutter_omarchy.dart';

import 'package:markdown_widget/widget/all.dart';

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const MarkdownEditorPage(),
    );
  }
}

class MarkdownEditorPage extends StatefulWidget {
  const MarkdownEditorPage({super.key});

  @override
  State<MarkdownEditorPage> createState() => _MarkdownEditorPageState();
}

class _MarkdownEditorPageState extends State<MarkdownEditorPage> {
  final MarkdownEditingController _controller = MarkdownEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OmarchyScaffold(
      status: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return OmarchyStatusBar(
            trailing: [
              OmarchyStatus(
                child: Text('${_controller.text.length} characters'),
              ),
            ],
          );
        },
      ),
      child: Column(
        children: [
          OmarchyTabs(
            children: [
              OmarchyTab.closable(
                isActive: true,
                title: Text('README.md'),
                onTap: () {},
                onClose: () {},
              ),
              OmarchyTab.closable(
                title: Text('DOC.md'),
                onTap: () {},
                onClose: () {},
              ),
            ],
          ),
          Expanded(
            child: OmarchySplitPanel(
              direction: TextDirection.rtl,
              panelInitialSize: PanelSize.ratio(0.5),
              panel: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return MarkdownPreview(markdown: _controller.text);
                },
              ),
              child: OmarchyTextInput(
                controller: _controller,
                padding: const EdgeInsets.all(24),
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkdownEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = buildSpans(text, context, style);
    return TextSpan(children: spans);
  }

  List<TextSpan> buildSpans(
    String text,
    BuildContext context,
    TextStyle? style,
  ) {
    final theme = OmarchyTheme.of(context);
    final spans = <TextSpan>[];

    if (text.isEmpty) {
      return spans;
    }

    final md = consecutiveAggregatedSpans(text);

    var previousEnd = 0;
    for (final span in md) {
      if (span.start > previousEnd) {
        // Add normal text for the gap
        spans.add(
          TextSpan(
            text: text.substring(previousEnd, span.start),
            style: style ?? const TextStyle(),
          ),
        );
      }
      previousEnd = span.end;
      TextStyle spanStyle = style ?? const TextStyle();
      for (final attr in span.attributes) {
        switch (attr) {
          case MarkdownAttribute.bold:
            spanStyle = spanStyle.merge(theme.text.bold);
          case MarkdownAttribute.italic:
            spanStyle = spanStyle.merge(theme.text.italic);
          case MarkdownAttribute.strikethrough:
            spanStyle = spanStyle.merge(
              const TextStyle(decoration: TextDecoration.lineThrough),
            );
          case MarkdownAttribute.code:
            spanStyle = spanStyle.merge(theme.text.italic);
          case MarkdownAttribute.link:
            spanStyle = spanStyle.merge(
              theme.text.normal.copyWith(
                color: theme.colors.bright.blue,
                decoration: TextDecoration.underline,
              ),
            );
          case MarkdownAttribute.image:
            spanStyle = spanStyle.merge(
              theme.text.normal.copyWith(color: theme.colors.bright.green),
            );
          case MarkdownAttribute.heading1:
            spanStyle = spanStyle.merge(
              theme.text.bold.copyWith(color: theme.colors.bright.magenta),
            );
          case MarkdownAttribute.heading2:
            spanStyle = spanStyle.merge(
              theme.text.bold.copyWith(color: theme.colors.bright.magenta),
            );
          case MarkdownAttribute.heading3:
            spanStyle = spanStyle.merge(
              theme.text.bold.copyWith(color: theme.colors.bright.magenta),
            );
          case MarkdownAttribute.heading4:
            spanStyle = spanStyle.merge(
              theme.text.bold.copyWith(color: theme.colors.bright.magenta),
            );
          case MarkdownAttribute.heading5:
            spanStyle = spanStyle.merge(
              theme.text.bold.copyWith(color: theme.colors.bright.magenta),
            );
          case MarkdownAttribute.heading6:
            spanStyle = spanStyle.merge(
              theme.text.bold.copyWith(color: theme.colors.bright.magenta),
            );
          case MarkdownAttribute.blockquote:
            spanStyle = spanStyle.merge(
              style?.copyWith(
                    color: theme.colors.bright.yellow,
                    fontStyle: FontStyle.italic,
                  ) ??
                  TextStyle(
                    color: theme.colors.bright.yellow,
                    fontStyle: FontStyle.italic,
                  ),
            );
          case MarkdownAttribute.codeblock:
            spanStyle = spanStyle.merge(
              theme.text.italic.copyWith(
                backgroundColor: theme.colors.normal.black.withValues(
                  alpha: 0.1,
                ),
              ),
            );
          case MarkdownAttribute.listItem:
            // No specific style for list items; handled in block parsing if needed
            break;
          case MarkdownAttribute.taskTodo:
            spanStyle = spanStyle.merge(
              style?.copyWith(
                    color: theme.colors.bright.red,
                    fontWeight: FontWeight.bold,
                  ) ??
                  TextStyle(
                    color: theme.colors.bright.red,
                    fontWeight: FontWeight.bold,
                  ),
            );
          case MarkdownAttribute.taskDone:
            spanStyle = spanStyle.merge(
              style?.copyWith(
                    color: theme.colors.bright.green,
                    fontWeight: FontWeight.bold,
                  ) ??
                  TextStyle(
                    color: theme.colors.bright.green,
                    fontWeight: FontWeight.bold,
                  ),
            );
        }
        spans.add(
          TextSpan(
            text: text.substring(span.start, span.end),
            style: spanStyle,
          ),
        );
      }
    }

    if (text.length > previousEnd) {
      // Add normal text for the gap
      spans.add(
        TextSpan(
          text: text.substring(previousEnd, text.length),
          style: style ?? const TextStyle(),
        ),
      );
    }

    return spans;
  }
}

class MarkdownPreview extends StatelessWidget {
  final String markdown;

  const MarkdownPreview({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Container(
      color: theme.colors.normal.black.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(right: 2, bottom: 2, top: 2),
      child: MarkdownWidget(data: markdown, padding: const EdgeInsets.all(24)),
    );
  }
}

// Minimal Markdown parser that returns ranges (start, end) for common elements.
// Notes:
// - Indexes are 0-based, end-exclusive.
// - Inline matches are skipped if they fall inside fenced code blocks.
// - Italic tries to avoid double-counting the inner part of bold (**...** / __...__).

// ==== Your data types from the prompt ====
enum MarkdownAttribute {
  bold,
  italic,
  strikethrough,
  code,
  link,
  image,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  blockquote,
  codeblock,
  listItem,
  taskTodo,
  taskDone,
}

class MarkdownMergedSpan {
  const MarkdownMergedSpan(this.start, this.end, this.attributes);
  final int start;
  final int end;
  final List<MarkdownAttribute> attributes;
}

class MarkdownSpan {
  const MarkdownSpan(this.start, this.end, this.attribute);
  final int start;
  final int end;
  final MarkdownAttribute attribute;

  @override
  String toString() =>
      'MarkdownSpan(start: $start, end: $end, attr: $attribute)';
}

// ==== Parser ====
class MarkdownParser {
  const MarkdownParser();

  List<MarkdownSpan> parseMarkdown(String document) {
    final spans = <MarkdownSpan>[];
    final added = <String>{}; // to dedupe (start:end:attr)
    final codeBlockRanges = <_Range>[];

    bool overlapsAny(int start, int end, List<_Range> ranges) {
      for (final r in ranges) {
        if (start < r.end && end > r.start) return true;
      }
      return false;
    }

    void addSpan(int start, int end, MarkdownAttribute attr) {
      if (start < 0 || end <= start || end > document.length) return;
      final key = '$start:$end:${attr.index}';
      if (added.contains(key)) return;
      spans.add(MarkdownSpan(start, end, attr));
      added.add(key);
    }

    // ---------- 1) Fenced code blocks ``` or ~~~ ----------
    // We pair fence lines 0-1, 2-3, ...; if an odd one remains, it spans to EOF.
    final fenceLine = RegExp(r'^(?:```|~~~)[^\n]*$', multiLine: true);
    final fenceMatches = fenceLine.allMatches(document).toList();
    for (int i = 0; i < fenceMatches.length; i += 2) {
      final start = fenceMatches[i].start;
      final end = (i + 1 < fenceMatches.length)
          ? fenceMatches[i + 1].end
          : document.length;
      addSpan(start, end, MarkdownAttribute.codeblock);
      codeBlockRanges.add(_Range(start, end));
    }

    // Helper to skip anything inside a fenced code block.
    bool inCodeBlock(int s, int e) => overlapsAny(s, e, codeBlockRanges);

    // ---------- 2) Headings (# to ###### at line start) ----------
    final heading = RegExp(r'^(#{1,6})[ \t]+.*$', multiLine: true);
    for (final m in heading.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      final level = m.group(1)!.length;
      final attr = [
        MarkdownAttribute.heading1,
        MarkdownAttribute.heading2,
        MarkdownAttribute.heading3,
        MarkdownAttribute.heading4,
        MarkdownAttribute.heading5,
        MarkdownAttribute.heading6,
      ][level - 1];
      addSpan(start, end, attr);
    }

    // ---------- 3) Blockquotes (lines starting with '>') ----------
    final blockquote = RegExp(r'^[ \t]*> ?.*$', multiLine: true);
    for (final m in blockquote.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.blockquote);
    }

    // ---------- 4) Task items ----------
    // - [ ] todo, - [x] done (also accept +/* as bullet symbols)
    final task = RegExp(
      r'^[ \t]*[-+*][ \t]+\[( |x|X)\][ \t]+.*$',
      multiLine: true,
    );
    final taskRanges = <_Range>[];
    for (final m in task.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      final marker = m.group(1)!;
      final attr = (marker == ' ')
          ? MarkdownAttribute.taskTodo
          : MarkdownAttribute.taskDone;
      addSpan(start, end, attr);
      addSpan(
        start,
        end,
        MarkdownAttribute.listItem,
      ); // tasks are list items too
      taskRanges.add(_Range(start, end));
    }

    // ---------- 5) Generic list items (bulleted or numbered) ----------
    // Skip ones already tagged as task lines.
    final listItem = RegExp(
      r'^[ \t]*(?:[-+*]|[0-9]+\.)(?:[ \t]+).*$',
      multiLine: true,
    );
    for (final m in listItem.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      if (overlapsAny(start, end, taskRanges)) continue; // already added above
      addSpan(start, end, MarkdownAttribute.listItem);
    }

    // ---------- 6) Images ----------
    final image = RegExp(r'!\[[^\]]*\]\([^)]+\)');
    for (final m in image.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.image);
    }

    // ---------- 7) Links (avoid picking up images which start with '!') ----------
    final link = RegExp(r'\[[^\]]+\]\([^)]+\)');
    for (final m in link.allMatches(document)) {
      final start = m.start;
      if (start > 0 && document[start - 1] == '!') continue; // it's an image
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.link);
    }

    // ---------- Inline spans (skip inside fenced code blocks) ----------
    final inlineCodeRanges = <_Range>[];

    // 8) Inline code: `code`
    final inlineCode = RegExp(r'`[^`\n]+`');
    for (final m in inlineCode.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.code);
      inlineCodeRanges.add(_Range(start, end));
    }
    bool inInlineCode(int s, int e) => overlapsAny(s, e, inlineCodeRanges);

    // 9) Bold: **...** and __...__
    final boldAsterisk = RegExp(r'\*\*[^\s*][^*\n]*?[^\s*]\*\*');
    for (final m in boldAsterisk.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end) || inInlineCode(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.bold);
    }
    final boldUnderscore = RegExp(r'__[^ \n_][^_\n]*?[^ \n_]__');
    for (final m in boldUnderscore.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end) || inInlineCode(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.bold);
    }

    // 10) Italic: *...* and _..._
    // We try to avoid counting parts of bold (**...** / __...__) as italic by checking adjacent chars.
    final italicAsterisk = RegExp(r'\*[^ \n*][^*\n]*?[^ \n*]\*');
    for (final m in italicAsterisk.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end) || inInlineCode(start, end)) continue;
      // If adjacent to another '*', it's likely part of **...**; skip.
      final before = (start - 1 >= 0) ? document[start - 1] : null;
      final after = (end < document.length) ? document[end] : null;
      if (before == '*' || after == '*') continue;
      addSpan(start, end, MarkdownAttribute.italic);
    }
    final italicUnderscore = RegExp(r'_[^ \n_][^_\n]*?[^ \n_]_');
    for (final m in italicUnderscore.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end) || inInlineCode(start, end)) continue;
      final before = (start - 1 >= 0) ? document[start - 1] : null;
      final after = (end < document.length) ? document[end] : null;
      if (before == '_' || after == '_') continue; // part of __...__
      addSpan(start, end, MarkdownAttribute.italic);
    }

    // 11) Strikethrough: ~~...~~
    final strike = RegExp(r'~~[^ \n~][^~\n]*?[^ \n~]~~');
    for (final m in strike.allMatches(document)) {
      final start = m.start;
      final end = m.end;
      if (inCodeBlock(start, end) || inInlineCode(start, end)) continue;
      addSpan(start, end, MarkdownAttribute.strikethrough);
    }

    // ---------- Done ----------
    spans.sort((a, b) {
      final c = a.start.compareTo(b.start);
      return c != 0 ? c : a.end.compareTo(b.end);
    });
    return spans;
  }
}

// Optional: top-level helper matching your requested signature exactly.
List<MarkdownSpan> parseMarkdown(String document) {
  return const MarkdownParser().parseMarkdown(document);
}

// Internal simple range holder
class _Range {
  _Range(this.start, this.end);
  final int start;
  final int end;
}

/// A span that covers a consecutive slice of the document and may
/// have multiple Markdown attributes active at once.
class ConsecutiveMarkdownSpan {
  const ConsecutiveMarkdownSpan(this.start, this.end, this.attributes);

  final int start; // inclusive
  final int end; // exclusive
  final Set<MarkdownAttribute> attributes;

  @override
  String toString() =>
      'ConsecutiveMarkdownSpan(start: $start, end: $end, attrs: $attributes)';
}

/// Build consecutive, non-overlapping spans that cover the entire document,
/// aggregating all attributes active over each span.
/// - Indexes are 0-based, end-exclusive.
/// - If no markdown feature applies to a slice, its `attributes` is an empty set.
List<ConsecutiveMarkdownSpan> consecutiveAggregatedSpans(String document) {
  final baseSpans = parseMarkdown(document); // uses the parser from earlier
  return _consecutiveAggregatedSpansFromSpans(document, baseSpans);
}

/// Same as above, but lets you pass precomputed spans if you have them.
List<ConsecutiveMarkdownSpan> consecutiveAggregatedSpansFromParsed(
  String document,
  List<MarkdownSpan> spans,
) {
  return _consecutiveAggregatedSpansFromSpans(document, spans);
}

// ---- Implementation ----

List<ConsecutiveMarkdownSpan> _consecutiveAggregatedSpansFromSpans(
  String document,
  List<MarkdownSpan> spans,
) {
  // 1) Collect all boundary points where attributes can change.
  final points = <int>{0, document.length};
  for (final s in spans) {
    // Clamp to document just in case.
    final start = (s.start < 0)
        ? 0
        : (s.start > document.length ? document.length : s.start);
    final end = (s.end < 0)
        ? 0
        : (s.end > document.length ? document.length : s.end);
    if (end > start) {
      points.add(start);
      points.add(end);
    }
  }
  final cuts = points.toList()..sort();

  // 2) Build minimal consecutive slices between every adjacent pair of cuts.
  final raw = <ConsecutiveMarkdownSpan>[];
  for (var i = 0; i < cuts.length - 1; i++) {
    final start = cuts[i];
    final end = cuts[i + 1];
    if (end <= start) continue;

    // Aggregate all attributes that fully cover this slice.
    final attrs = <MarkdownAttribute>{};
    for (final s in spans) {
      if (s.start <= start && s.end >= end) {
        attrs.add(s.attribute);
      }
    }
    raw.add(ConsecutiveMarkdownSpan(start, end, attrs));
  }

  // 3) Merge adjacent slices that ended up with identical attribute sets
  //    (can happen when multiple spans start/end at the same offset).
  final merged = <ConsecutiveMarkdownSpan>[];
  for (final s in raw) {
    if (merged.isEmpty) {
      merged.add(s);
    } else {
      final last = merged.last;
      if (_sameAttrSet(last.attributes, s.attributes) && last.end == s.start) {
        merged[merged.length - 1] = ConsecutiveMarkdownSpan(
          last.start,
          s.end,
          last.attributes,
        );
      } else {
        merged.add(s);
      }
    }
  }
  return merged;
}

bool _sameAttrSet(Set<MarkdownAttribute> a, Set<MarkdownAttribute> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  // Fast path: compare as bitmasks.
  return _mask(a) == _mask(b);
}

int _mask(Set<MarkdownAttribute> s) {
  var m = 0;
  for (final a in s) {
    m |= (1 << a.index);
  }
  return m;
}
