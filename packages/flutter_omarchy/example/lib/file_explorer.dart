import 'package:flutter_omarchy/flutter_omarchy.dart';

class FileExplorerApp extends StatelessWidget {
  const FileExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const FileExplorerPage(),
    );
  }
}

// Fake file system models
enum FileType { folder, textFile, imageFile, audioFile, videoFile, pdfFile }

class FileItem {
  final String path;
  final FileType type;
  final DateTime modified;
  final int size; // in bytes
  final List<FileItem> children;

  const FileItem({
    required this.path,
    required this.type,
    required this.modified,
    required this.size,
    this.children = const [],
  });

  String get name {
    return path.split('/').last;
  }

  bool get isFolder => type == FileType.folder;

  IconData get icon {
    switch (type) {
      case FileType.folder:
        return OmarchyIcons.codFolder;
      case FileType.textFile:
        return OmarchyIcons.codFile;
      case FileType.imageFile:
        return OmarchyIcons.faImage;
      case FileType.audioFile:
        return OmarchyIcons.faAudible;
      case FileType.videoFile:
        return OmarchyIcons.faVideo;
      case FileType.pdfFile:
        return OmarchyIcons.setiPdf;
    }
  }

  String get formattedSize {
    if (isFolder) return '--';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    return '${modified.day}/${modified.month}/${modified.year} ${modified.hour}:${modified.minute.toString().padLeft(2, '0')}';
  }
}

// Fake file system data
class FileSystem {
  static final FileItem root = FileItem(
    path: '/root',
    type: FileType.folder,
    modified: DateTime.now().subtract(const Duration(days: 30)),
    size: 0,
    children: [
      FileItem(
        path: '/root/Documents',
        type: FileType.folder,
        modified: DateTime.now().subtract(const Duration(days: 5)),
        size: 0,
        children: [
          FileItem(
            path: '/root/Documents/Project Proposal.pdf',
            type: FileType.pdfFile,
            modified: DateTime.now().subtract(const Duration(days: 2)),
            size: 2540000,
          ),
          FileItem(
            path: '/root/Documents/Meeting Notes.txt',
            type: FileType.textFile,
            modified: DateTime.now().subtract(const Duration(hours: 5)),
            size: 12500,
          ),
          FileItem(
            path: '/root/Documents/Budget.txt',
            type: FileType.textFile,
            modified: DateTime.now().subtract(const Duration(days: 1)),
            size: 5200,
          ),
        ],
      ),
      FileItem(
        path: '/root/Pictures',
        type: FileType.folder,
        modified: DateTime.now().subtract(const Duration(days: 10)),
        size: 0,
        children: [
          FileItem(
            path: '/root/Pictures/Vacation.jpg',
            type: FileType.imageFile,
            modified: DateTime.now().subtract(const Duration(days: 15)),
            size: 4500000,
          ),
          FileItem(
            path: '/root/Pictures/Family.jpg',
            type: FileType.imageFile,
            modified: DateTime.now().subtract(const Duration(days: 20)),
            size: 3200000,
          ),
          FileItem(
            path: '/root/Pictures/Screenshots',
            type: FileType.folder,
            modified: DateTime.now().subtract(const Duration(days: 3)),
            size: 0,
            children: [
              FileItem(
                path: '/root/Pictures/Screenshots/Screenshot1.png',
                type: FileType.imageFile,
                modified: DateTime.now().subtract(const Duration(days: 3)),
                size: 1200000,
              ),
              FileItem(
                path: '/root/Pictures/Screenshots/Screenshot2.png',
                type: FileType.imageFile,
                modified: DateTime.now().subtract(const Duration(days: 2)),
                size: 1500000,
              ),
            ],
          ),
        ],
      ),
      FileItem(
        path: '/root/Music',
        type: FileType.folder,
        modified: DateTime.now().subtract(const Duration(days: 7)),
        size: 0,
        children: [
          FileItem(
            path: '/root/Music/Favorite Song.mp3',
            type: FileType.audioFile,
            modified: DateTime.now().subtract(const Duration(days: 7)),
            size: 8500000,
          ),
          FileItem(
            path: '/root/Music/New Album',
            type: FileType.folder,
            modified: DateTime.now().subtract(const Duration(days: 1)),
            size: 0,
            children: [
              FileItem(
                path: '/root/Music/New Album/Track 1.mp3',
                type: FileType.audioFile,
                modified: DateTime.now().subtract(const Duration(days: 1)),
                size: 7200000,
              ),
              FileItem(
                path: '/root/Music/New Album/Track 2.mp3',
                type: FileType.audioFile,
                modified: DateTime.now().subtract(const Duration(days: 1)),
                size: 6800000,
              ),
            ],
          ),
        ],
      ),
      FileItem(
        path: '/root/Videos',
        type: FileType.folder,
        modified: DateTime.now().subtract(const Duration(days: 12)),
        size: 0,
        children: [
          FileItem(
            path: '/root/Videos/Holiday.mp4',
            type: FileType.videoFile,
            modified: DateTime.now().subtract(const Duration(days: 12)),
            size: 1250000000,
          ),
        ],
      ),
      FileItem(
        path: '/root/System',
        type: FileType.folder,
        modified: DateTime.now().subtract(const Duration(days: 60)),
        size: 0,
        children: [
          FileItem(
            path: '/root/System/Config.txt',
            type: FileType.textFile,
            modified: DateTime.now().subtract(const Duration(days: 45)),
            size: 1200,
          ),
          FileItem(
            path: '/root/System/Log.txt',
            type: FileType.textFile,
            modified: DateTime.now(),
            size: 45000,
          ),
        ],
      ),
    ],
  );

  static final List<FileItem> favorites = [
    FileSystem.root,
    FileSystem.root.children[0], // Documents
    FileSystem.root.children[1], // Pictures
    FileSystem.root.children[2], // Music
  ];
}

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({super.key});

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  FileItem _currentFolder = FileSystem.root;
  bool _showLeadingMenu = true;

  void _navigateToFolder(FileItem folder) {
    if (folder.isFolder) {
      setState(() {
        _currentFolder = folder;
      });
    }
  }

  void _navigateUp() {
    final segments = _currentFolder.path.split('/');
    if (segments.length <= 1) {
      return; // Already at root
    }
    final parentPath = segments.sublist(0, segments.length - 1).join('/');

    final parent = FileSystem.root.children.firstWhere(
      (item) => item.path == parentPath,
      orElse: () => FileSystem.root,
    );

    setState(() {
      _currentFolder = parent;
    });
  }

  void _createNewItem(bool isFolder) {
    final name = isFolder ? 'New Folder' : 'New File.txt';
    final type = isFolder ? FileType.folder : FileType.textFile;

    // In a real app, we would add this to the actual file system
    // Here we're just updating our fake data model
    setState(() {
      final newItem = FileItem(
        path: '${_currentFolder.path}/$name',
        type: type,
        modified: DateTime.now(),
        size: isFolder ? 0 : 0,
        children: isFolder ? [] : const [],
      );

      // Create a new list with the added item
      final updatedChildren = List<FileItem>.from(_currentFolder.children)
        ..add(newItem);

      // Create a new current folder with the updated children
      _currentFolder = FileItem(
        path: _currentFolder.path,
        type: _currentFolder.type,
        modified: _currentFolder.modified,
        size: _currentFolder.size,
        children: updatedChildren,
      );
    });
  }

  void _toggleLeadingMenu() {
    setState(() {
      _showLeadingMenu = !_showLeadingMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);

    return OmarchyScaffold(
      navigationBar: OmarchyNavigationBar(
        title: Text(_currentFolder.name),

        leading: [
          OmarchyButton(
            onPressed: _toggleLeadingMenu,
            child: const Icon(OmarchyIcons.codMenu),
          ),

          if (_currentFolder.path != FileSystem.root.path)
            OmarchyButton(
              onPressed: _navigateUp,
              child: const Icon(OmarchyIcons.codArrowUp),
            ),
        ],
        trailing: [
          OmarchyPopOver(
            popOverDirection: OmarchyPopOverDirection.down,
            builder: (context, show) => OmarchyButton(
              onPressed: show,
              child: const Icon(OmarchyIcons.codAdd),
            ),
            offset: Offset(-7, 0),
            popOverBuilder: (context, size, hide) => OmarchyPopOverContainer(
              child: ListView(
                shrinkWrap: true,
                children: [
                  OmarchyTile(
                    onTap: () {
                      _createNewItem(true);
                      hide();
                    },
                    title: Row(
                      children: [
                        Icon(OmarchyIcons.codFolder, size: 16),
                        const SizedBox(width: 8),
                        const Text('New Folder'),
                      ],
                    ),
                  ),
                  OmarchyTile(
                    onTap: () {
                      _createNewItem(false);
                      hide();
                    },
                    title: Row(
                      children: [
                        Icon(OmarchyIcons.codFile, size: 16),
                        const SizedBox(width: 8),
                        const Text('New File'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      leadingPanel: _showLeadingMenu
          ? ListView(
              children: [
                for (final favorite in FileSystem.favorites)
                  Selected(
                    isSelected: _currentFolder == favorite,
                    child: OmarchyTile(
                      //leading: Icon(favorite.icon),
                      title: Text(favorite.name),
                      onTap: () => _navigateToFolder(favorite),
                    ),
                  ),
              ],
            )
          : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colors.border)),
            ),
            child: Headers(),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final item in _currentFolder.children)
                  FileTile(
                    item,
                    onTap: item.isFolder ? () => _navigateToFolder(item) : null,
                  ),
              ],
            ),
          ),
        ],
      ),
      status: OmarchyStatusBar(
        leading: [
          OmarchyStatus(child: Text('${_currentFolder.children.length} items')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(_currentFolder.path),
          ),
        ],
        trailing: [OmarchyStatus(child: Text('Free space: 128.5 GB'))],
      ),
    );
  }
}

class Headers extends StatelessWidget {
  const Headers({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return LayoutBuilder(
      builder: (context, layout) {
        return Row(
          children: [
            const SizedBox(width: 32), // Icon space
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Name',
                    style: theme.text.bold.copyWith(
                      color: theme.colors.normal.white,
                    ),
                  ),
                ],
              ),
            ),
            if (layout.maxWidth > 400) ...[
              SizedBox(
                width: 160,
                child: Text(
                  'Date Modified',
                  style: theme.text.bold.copyWith(
                    color: theme.colors.normal.white,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Size',
                  style: theme.text.bold.copyWith(
                    color: theme.colors.normal.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class FileTile extends StatelessWidget {
  const FileTile(this.item, {super.key, required this.onTap});
  final FileItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return OmarchyTile(
      title: LayoutBuilder(
        builder: (context, layout) {
          return Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 8,
                  children: [Icon(item.icon, size: 24), Text(item.name)],
                ),
              ),
              if (layout.maxWidth > 400) ...[
                SizedBox(
                  width: 160,
                  child: Text(
                    item.formattedDate,
                    style: TextStyle(color: theme.colors.normal.white),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    item.formattedSize,
                    style: TextStyle(color: theme.colors.normal.white),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      onTap: onTap,
    );
  }
}

