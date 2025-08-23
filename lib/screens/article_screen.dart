import 'package:facebook_replication/models/article_model.dart';
import 'package:facebook_replication/services/article_service.dart';
import 'package:facebook_replication/widgets/custom_text.dart';
import 'package:facebook_replication/screens/article_details_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> _futureArticles;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureArticles = _getAllArticles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Article>> _getAllArticles() async {
    final response = await ArticleService().getAllArticle();
    final articles = (response).map((e) => Article.fromJson(e)).toList();
    _allArticles = articles;
    _filteredArticles = articles;
    return articles;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArticles = _allArticles
          .where((article) =>
              article.title.toLowerCase().contains(query) ||
              article.body.toLowerCase().contains(query))
          .toList();
    });
  }

  // add
  Future<void> _openAddArticleDialog() async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isActive = true;

    await showDialog(
      context: context,
      barrierDismissible: !isSaving, 
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            List<String> _toList(String raw) {
              return raw 
                  .split(RegExp(r'[\n,]'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
                }

                Future<void> save() async {
                if (isSaving) return;
                if (!formKey.currentState!.validate()) return;

                setLocalState(() => isSaving = true);
                try {
                  final payload = {
                    'title': titleController.text.trim(),
                    'name': authorController.text.trim(),
                    'content': _toList(contentController.text),
                    'isActive': isActive,
                  };

                  final Map res = await ArticleService().createArticle(payload);
                  final created = (res['article'] ?? res);
                  final newArticle = Article.fromJson(created);

                  setState(() {
                    _allArticles.insert(0, newArticle);
                    _filteredArticles;
                  });

                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article added.')),
                    );
                  }
                } catch (e) {
                  setLocalState(() => isSaving = false);
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
                  }
                }
              }

              return AlertDialog(
                title: const Text('Add Article'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' :
                            null,
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: authorController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Author / Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' :
                              null,
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: contentController,
                            minLines: 3,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText:
                                  'Content (one item per line or comma-separated)',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            validator: (v) {
                              final items = v == null 
                                  ? []
                                  : v
                                          .trim()
                                          .split(RegExp(r'[\n,]'))
                                          .where((s) => s.trim().isNotEmpty)
                                          .toList();
                              return items.isEmpty
                                  ? 'At least one content item'
                                  : null;
                            },
                          ),
                          SizedBox(height: 8.h),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: isActive,
                            onChanged: (val) => setLocalState(() => isActive = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSaving ? null : () => Navigator.of(ctx).pop(), 
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {  },
                      label: const Text('cancel'),
                    )
                  ],
                );
              },
            );
          },
        );
      }

    Widget _statusChip(bool active) {
      return Chip(
        label: Text(active ? 'Active' : 'Inactive'),
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: active ? Colors.green : Colors.grey),
      );
    }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddArticleDialog, 
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search articles...",
                  hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),

            FutureBuilder<void>(
              future: _loadFuture, 
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CustomText(
                          text: 'No equipment article to display...',
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: ScreenUtil().screenHeight * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                          SizedBox(height: 10.h),
                          const CustomText(
                            text: 
                                  'Waiting for the equipment artciles to display...',
                            ),
                          ],
                      ),
                    ),
                  );
                }

                if (_filteredArticles.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: const Center(
                      child: CustomText(
                        text: 'No equipment article to display...',
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    shrinkWrap: true,
                    itemCount: _filteredArticles.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final article = _filteredArticles[index];
                      final preview = article.content.isNotEmpty
                          ? article.content.first
                          : '';
                      return Card(
                        elevation: 1,
                        child: InkWell(
                          onTap: () {
                            debugPrint('Tapped index $index: ${article.aid}');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(15),
                              vertical: ScreenUtil().setHeight(15),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: CustomText(
                                              text: article.title.isEmpty
                                                  ? 'Untitled'
                                                  : article.title,
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.bold,
                                              maxLines: 2,
                                              ),
                                            ),
                                            _statusChip(article.isActive),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomText(
                                          text: article.name,
                                          fontSize: 13.sp,
                                        ),
                                        if (preview.isNotEmpty) ...[
                                          SizedBox(height: 6.h),
                                          CustomText(
                                            text: preview,
                                            fontSize: 12.sp,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
}