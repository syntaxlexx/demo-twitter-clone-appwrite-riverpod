import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common.dart';
import '../../../core/utils.dart';
import '../../../theme/theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/user_profile_controller.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  static MaterialPageRoute route() => MaterialPageRoute(builder: (context) => const EditProfileView());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameCtr;
  late TextEditingController bioCtr;
  File? bannerFile;
  File? profileFile;

  @override
  void initState() {
    super.initState();
    nameCtr = TextEditingController(text: ref.read(currentUserDetailsProvider).value?.name ?? '');
    bioCtr = TextEditingController(text: ref.read(currentUserDetailsProvider).value?.bio ?? '');
  }

  @override
  void dispose() {
    nameCtr.dispose();
    bioCtr.dispose();
    super.dispose();
  }

  Future<void> selectBannerImage() async {
    final image = await pickImage();
    if (image != null) {
      setState(() {
        bannerFile = image;
      });
    }
  }

  Future<void> selectProfileImage() async {
    final image = await pickImage();
    if (image != null) {
      setState(() {
        profileFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              if (currentUser == null) return;

              ref.watch(userProfileControllerProvider.notifier).updateUserProfile(
                    user: currentUser.copyWith(
                      bio: bioCtr.text,
                      name: nameCtr.text,
                    ),
                    context: context,
                    bannerFile: bannerFile,
                    profileFile: profileFile,
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: isLoading || currentUser == null
          ? const Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bannerFile != null
                              ? Image.file(
                                  bannerFile!,
                                  fit: BoxFit.cover,
                                )
                              : currentUser.bannerPic != null && currentUser.bannerPic!.isNotEmpty
                                  ? Image.network(
                                      currentUser.bannerPic!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Pallete.blueColor,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child: profileFile != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(profileFile!),
                                  radius: 40,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(currentUser.profilePic!),
                                  radius: 40,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameCtr,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: bioCtr,
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 4,
                )
              ],
            ),
    );
  }
}
