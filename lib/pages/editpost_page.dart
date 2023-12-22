import 'package:art_app/components/tag_capsule.dart';
import 'package:art_app/components/text_fields.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/services/firebase_service.dart';
import 'package:art_app/services/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPost extends StatefulWidget {
  const EditPost({
    super.key,
    required this.title,
    required this.email,
    required this.description,
    required this.tags,
    required this.price,
    required this.images,
  });
  final List<String> images;
  final String title;
  final String email;
  final String description;
  final List<String> tags;
  final int price;

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late List<String> interests;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price.toString());
    interests = widget.tags;
  }

  @override
  Widget build(BuildContext context) {
    var buildtextfield = BuildTextField();
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: notifier.surface,
          title: const Text('Edit Post'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
                onPressed: () => {
                      Modals.showAlertConfirm(
                          context,
                          'This will delete this post permanently. You cannot undo this action.',
                          'Are you sure you want to delete this post?', () {
                        Navigator.pop(context);
                        Modals.loaderPopup(context, 'Please wait');
                        FirestoreService()
                            .deleteShopItem(widget.title)
                            .then((value) => {
                                  if (value)
                                    {
                                      Navigator.pop(context),
                                      Modals.showAlertWithButton(
                                          context,
                                          'The post would no longer be accessible',
                                          'Post deleted successfully',
                                          'Okay', () {
                                        PageTransitions()
                                            .popToPageHome(context, 4);
                                      }),
                                    }
                                });
                      }),
                    },
                child: const Text('Delete Post'))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height:
                    200, // Adjust the height of the horizontal list as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      width: MediaQuery.of(context).size.width,
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: CachedNetworkImage(
                          imageUrl: widget.images[index],
                          placeholder: (context, url) =>
                              const SizedBox.expand(),
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildtextfield.fullTextFormField(_titleController, 'Title'),
                    const SizedBox(
                      height: 15,
                    ),
                    buildtextfield.fullTextFormField(
                        _descriptionController, 'Description'),
                    const SizedBox(
                      height: 15,
                    ),
                    buildtextfield.fullTextFormFieldNumber(
                        _priceController, 'Price'),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TagDisplay(
                            interests: interests,
                            onDelete: (String deletedTag) {
                              setState(() {
                                interests.remove(deletedTag);
                              });
                            },
                            onTagAdded: (String addedTag) {
                              setState(() {
                                interests.add(addedTag);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
